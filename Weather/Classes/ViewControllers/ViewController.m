//
//  ViewController.m
//  Weather
//
//  Created by Felix Boquet on 20/03/2018.
//  Copyright © 2018 Felix Boquet. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wundergroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *villeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateMajLabel;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *preferencesButton;

@property (nonatomic, strong) NSArray *json;
@property (nonatomic, strong) NSString *ville;
@property (nonatomic, strong) NSString *temperature;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSMutableArray *preferences;
@property (nonatomic, strong) NSString *favoriteCity;
@property (nonatomic) NSInteger favUnit;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadPreferences];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadPreferences];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)updateLocationWithCompletion:(void(^)(void))callback {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.location = self.locationManager.location;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            return;
            
        }
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        self.ville = placemark.locality;
        NSLog(@"%@", placemark.locality);
        // Téléchargement des données météo
        [self downloadWundergroundWeatherForCity:placemark.locality AndCompletion:callback];
    }];
}

- (void)downloadWundergroundWeatherForCity:(NSString*)city AndCompletion:(void(^)(void))callback {
    
    // Url pour accéder à la météo
    // Pour faciliter le traitement dans un 1er temps, on considère qu'on est en France
    NSString *url = [[@"https://api.wunderground.com/api/b896f62d3c17257f/conditions/q/FR/" stringByAppendingString:city] stringByAppendingString:@".json"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                NSLog(@"RESPONSE: %@",response);
                NSLog(@"DATA: %@",data);
                
                if (!error) {
                    // Success
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        NSError *jsonError;
                        self.json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                        
                        if (jsonError) {
                            // Error Parsing JSON
                            NSLog(@"JSON error : %@", jsonError.description);
                        } else {
                            // Success Parsing JSON
                            NSMutableDictionary *observation = [[self.json valueForKey:@"current_observation"]mutableCopy];
                            if (self.favUnit == 0) {
                                self.temperature = [[[observation objectForKey:@"temp_c"] stringValue] stringByAppendingString:@" C°"];
                            } else {
                                self.temperature = [[[observation objectForKey:@"temp_f"] stringValue] stringByAppendingString:@" °F"];
                            }
                            self.ville = city;
                            
                            if ([observation objectForKey:@"icon_url"]) {
                                NSMutableString *httpsUrl = [NSMutableString stringWithString:[observation objectForKey:@"icon_url"]];
                                [httpsUrl insertString:@"s" atIndex:4];
                                [self downloadImageFromURL:httpsUrl AndCompletion:callback];
                            }
                            
                        }
                    }
                } else {
                    // Fail
                    NSLog(@"error : %@", error.description);
                }
            }
      ] resume];
}

- (void)downloadImageFromURL:(NSString *)fileURL AndCompletion:(void(^)(void))callback {
    
    // On va chercher l'image de la météo
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:[NSURL URLWithString:fileURL]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (!error) {
                    self.image = [UIImage imageWithData:data];
                    callback();
                } else {
                    NSLog(@"error : %@", error);
                }
            }
      ] resume];
    
}

- (void)loadPreferences {
    // On récupère les préférences
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Preferences"];
    
    self.preferences = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    self.favoriteCity = [[self.preferences valueForKey:@"adresseParDefaut"] objectAtIndex:0];
    self.favUnit = [[[self.preferences valueForKey:@"uniteMesure"] objectAtIndex:0] integerValue];
}

#pragma mark - IBActions

- (IBAction)refreshAction:(id)sender {
    
    // On recharge les données de météo avec la géolocalisation
    [self updateLocationWithCompletion:^{
        // Date de mise à jour de la météo
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM HH:mm"];
        // Pour exécuter la modif des labels dans le thread principal sinon il y a un warning
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dateMajLabel.text = [@"MAJ " stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
            self.villeLabel.text = self.ville;
            self.temperatureLabel.text = self.temperature;
            
            [self.wundergroundImageView setImage:self.image];
        });
    }];
}

- (IBAction)favoriteCityAction:(id)sender {
    
    // On télécharge la météo avec la ville favorite si on en a une
    if ([self.preferences count] != 0) {
        
        [self downloadWundergroundWeatherForCity:self.favoriteCity AndCompletion:^{
            // Date de mise à jour de la météo
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd/MM HH:mm"];
            // Pour exécuter la modif des labels dans le thread principal sinon il y a un warning
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dateMajLabel.text = [@"MAJ " stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
                self.villeLabel.text = self.ville;
                self.temperatureLabel.text = self.temperature;
                
                [self.wundergroundImageView setImage:self.image];
            });
        }];
    } else {
        // Popup pour indiquer à l'utilisateur qu'il n'a pas saisi de ville par défaut
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Attention"
                                                                       message:@"Veuillez choisir une ville par défaut dans vos préférences"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:nil];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)goToPreferencesAction:(id)sender {
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(persistentContainer)]) {
        context = [delegate persistentContainer].viewContext;
    }
    
    return context;
}

@end
