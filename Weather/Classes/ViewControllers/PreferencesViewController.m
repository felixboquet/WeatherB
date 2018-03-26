//
//  PreferencesViewController.m
//  Weather
//
//  Created by Felix Boquet on 26/03/2018.
//  Copyright © 2018 Felix Boquet. All rights reserved.
//

#import "PreferencesViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface PreferencesViewController ()

@property (weak, nonatomic) IBOutlet UITextField *adresseParDefautTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *uniteSegmentedControl;

@property (nonatomic, strong) NSMutableArray *preferences;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Enregistrer"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(savePreferences:)];
    
    self.navigationItem.rightBarButtonItem = save;
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Annuler"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Preferences"];
    
    self.preferences = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    
    // TODO : Affichage des données enregistrées
    
    if ([[self.preferences valueForKey:@"adresseParDefaut"] isKindOfClass:[NSString class]]) {
        self.adresseParDefautTextField.text = [self.preferences valueForKey:@"adresseParDefaut"];
    }
//    [self.uniteSegmentedControl setSelectedSegmentIndex:[[self.preferences valueForKey:@"uniteMesure"] integerValue]];
}

#pragma mark - Actions

- (IBAction)savePreferences:(id)sender {
    
    NSManagedObject *preferences = [NSEntityDescription insertNewObjectForEntityForName:@"Preferences" inManagedObjectContext:[self managedObjectContext]];

//    [preferences setAdresseParDefaut:self.adresseParDefautTextField.text];
//    [preferences setUniteMesure:[NSNumber numberWithInteger:self.uniteSegmentedControl.selectedSegmentIndex]];
    
    [preferences setValue:self.adresseParDefautTextField.text forKey:@"adresseParDefaut"];
    [preferences setValue:[NSNumber numberWithInteger:self.uniteSegmentedControl.selectedSegmentIndex] forKey:@"uniteMesure"];
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Erreur sauvegarde des préférences %@ %@", error, [error localizedDescription]);
    }
    
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goBack:(id)sender {
    // Retour à l'accueil
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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
