//
//  HistoryViewController.m
//  Weather
//
//  Created by Helene Willis on 28/03/2018.
//  Copyright © 2018 Felix Boquet. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@property (nonatomic, strong) NSMutableArray *history;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

# pragma mark -TableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];

    return cell;
}

@end
