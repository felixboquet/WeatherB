//
//  HistoryTableViewCell.h
//  Weather
//
//  Created by Helene Willis on 28/03/2018.
//  Copyright © 2018 Felix Boquet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *adresseLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateMajLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *meteoImageView;

- (void)updateCellWithAddress:(NSString*)adresse andTemp:(NSString*)temp andDate:(NSString*)date andImage:(NSData*)img;

@end
