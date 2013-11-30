//
//  GAStartGameController.m
//  Homyaki
//
//  Created by Alexandr on 25.11.13.
//  Copyright (c) 2013 Alex Gra. All rights reserved.
//

#import "GAStartGameController.h"
#import "GAGameController.h"

@interface GAStartGameController ()
@property (nonatomic, weak) IBOutlet UIButton* button1;
@property (nonatomic, weak) IBOutlet UIButton* button2;
@property (nonatomic, weak) IBOutlet UIButton* button3;
@end

@implementation GAStartGameController
@synthesize button1, button2, button3;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grass_bg"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (IBAction)buttonPressed:(id)sender
{
    int holesCount = -1;
    //задайте количество норок
    
    if(holesCount <= 0)return;
    
    GAGameController* gameController = [[GAGameController alloc] initWithHolesCount:holesCount];
    [self presentModalViewController:gameController animated:YES];
}

@end
