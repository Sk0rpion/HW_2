//
//  UIHamsterButton.h
//  Homyaki
//
//  Created by Игорь Савельев on 26/03/14.
//  Copyright (c) 2014 Alex Gra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIHamsterButton : UIButton

@property (nonatomic, assign, readonly) BOOL hamsterHidden;

- (void)showHamster:(BOOL)show;

@end
