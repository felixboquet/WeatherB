//
//  PreferencesViewController.m
//  Weather
//
//  Created by Helene Willis on 26/03/2018.
//  Copyright © 2018 Felix Boquet. All rights reserved.
//

#import "PreferencesViewController.h"

@interface PreferencesViewController ()


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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)savePreferences:(id)sender {
    
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goBack:(id)sender {
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
