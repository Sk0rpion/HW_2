//
//  GAAppDelegate.h
//  Homyaki
//
//  Created by Alexandr on 25.11.13.
//  Copyright (c) 2013 Alex Gra. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAStartGameController;
@interface GAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) GAStartGameController* rootController;

@end
