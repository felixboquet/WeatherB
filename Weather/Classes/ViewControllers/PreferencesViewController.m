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
    
    // On recherche les préférences
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Preferences"];
    
    self.preferences = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    
    // Affichage des données enregistrées
    if ([self.preferences count] != 0) {
        self.adresseParDefautTextField.text = [[self.preferences valueForKey:@"adresseParDefaut"] objectAtIndex:0];
    }
    
//    [self.uniteSegmentedControl setSelectedSegmentIndex:[[self.preferences valueForKey:@"uniteMesure"] integerValue]];
}

#pragma mark - Actions

- (IBAction)savePreferences:(id)sender {
    
    // On cherche si il y a déjà des préférences enregistrées
    NSManagedObject *preferences;
    if ([self.preferences count] == 0) {
        preferences = [NSEntityDescription insertNewObjectForEntityForName:@"Preferences" inManagedObjectContext:[self managedObjectContext]];
    } else {
        preferences = [self.preferences objectAtIndex:0];
    }
    
    [preferences setValue:self.adresseParDefautTextField.text forKey:@"adresseParDefaut"];
    [preferences setValue:[NSNumber numberWithInteger:self.uniteSegmentedControl.selectedSegmentIndex] forKey:@"uniteMesure"];
    
    // Sauvegarde
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Erreur sauvegarde des préférences %@ %@", error, [error localizedDescription]);
    }
    
    // Retour à l'accueil
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
