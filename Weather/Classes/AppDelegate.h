//
//  AppDelegate.h
//  Weather
//
//  Created by Felix Boquet on 20/03/2018.
//  Copyright © 2018 Felix Boquet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

