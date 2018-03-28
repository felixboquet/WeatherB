//
//  HistoryViewController.m
//  Weather
//
//  Created by Helene Willis on 28/03/2018.
//  Copyright © 2018 Felix Boquet. All rights reserved.
//

#import "HistoryViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface HistoryViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, strong) NSMutableArray *history;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Bouton retour
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(goBack:)];
    [back setTintColor:[UIColor whiteColor]];
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Historique"];
    item.leftBarButtonItem = back;
    item.hidesBackButton =YES;
    [self.navigationBar pushNavigationItem:item animated:NO];
    
    // On charge l'historique
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Historique"];
    
    self.history = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

# pragma mark -TableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // On construit l'historique
    NSString *adresse = [[self.history valueForKey:@"adresse"] objectAtIndex:indexPath.row];
    NSString *temp = [[self.history valueForKey:@"temperature"] objectAtIndex:indexPath.row];
    NSString *date = [[self.history valueForKey:@"date"] objectAtIndex:indexPath.row];
    NSData *image = [[self.history valueForKey:@"image"] objectAtIndex:indexPath.row];
    
    // On remplit la cellule
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    [cell updateCellWithAddress:adresse andTemp:temp andDate:date andImage:image];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
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
