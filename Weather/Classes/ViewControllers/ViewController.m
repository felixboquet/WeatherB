//
//  ViewController.m
//  Weather
//
//  Created by Felix Boquet on 20/03/2018.
//  Copyright © 2018 Felix Boquet. All rights reserved.
//

#import "ViewController.h"

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

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    NSString *url = [[@"https://api.wunderground.com/api/b896f62d3c17257f/conditions/q/CA/" stringByAppendingString:city] stringByAppendingString:@".json"];
    
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
                            self.temperature = [[observation objectForKey:@"temp_c"] stringValue];
                            
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

#pragma mark - IBActions

- (IBAction)refreshAction:(id)sender {
    
    // S'exécute au clic sur le bouton
    
    // On recharge les données de météo
    [self updateLocationWithCompletion:^{
        // Date de mise à jour de la météo
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM HH:mm"];
        // Pour exécuter la modif des labels dans le thread principal sinon il y a un warning
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dateMajLabel.text = [@"MAJ " stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
            self.villeLabel.text = self.ville;
            self.temperatureLabel.text = [self.temperature stringByAppendingString:@"°"];
            
            [self.wundergroundImageView setImage:self.image];
        });
    }];
}

- (IBAction)goToPreferencesAction:(id)sender {
}


@end
