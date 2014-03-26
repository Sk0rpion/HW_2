//
//  UIHamsterButton.m
//  Homyaki
//
//  Created by Игорь Савельев on 26/03/14.
//  Copyright (c) 2014 Alex Gra. All rights reserved.
//

#import "UIHamsterButton.h"

@implementation UIHamsterButton {
    UIImageView *hamsterView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializations];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializations];
    }
    return self;
}

- (void)initializations {
    CGRect frame = self.frame;
    frame.size = CGSizeMake(45, 50);
    self.frame = frame;
    
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
    //[self setImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
    
    [self setClipsToBounds:YES];
     
     hamsterView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hamster.png"]];
     hamsterView.frame = CGRectMake(0, 50.0f, 45, 50);
     [self addSubview:hamsterView];
    
    
    _hamsterHidden = YES;
}

- (void)showHamster:(BOOL)show {
    if (show) {
        CGRect frame = CGRectMake(0, 0, 45, 50);
        [UIView animateWithDuration:0.1 animations:^{
            [hamsterView setFrame:frame];
        } completion:^(BOOL finished) {
            _hamsterHidden = NO;
        }];
    } else {
        CGRect frame = CGRectMake(0, 50.0f, 45, 50);
        [UIView animateWithDuration:0.1 animations:^{
            [hamsterView setFrame:frame];
        } completion:^(BOOL finished) {
            _hamsterHidden = YES;
        }];
    }
}

@end
