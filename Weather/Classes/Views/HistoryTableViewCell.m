//
//  HistoryTableViewCell.m
//  Weather
//
//  Created by Helene Willis on 28/03/2018.
//  Copyright © 2018 Felix Boquet. All rights reserved.
//

#import "HistoryTableViewCell.h"

@implementation HistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellWithAddress:(NSString*)adresse andTemp:(NSString*)temp andDate:(NSString*)date andImage:(NSData*)img {
    
    self.adresseLabel.text = adresse;
    self.temperatureLabel.text = temp;
    self.dateMajLabel.text = date;
    self.imageView.image = [UIImage imageWithData:img];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
