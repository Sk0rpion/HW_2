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
    
    [button1 addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventAllTouchEvents];
    button1.tag=101;
    button2.tag = 102;
    button3.tag = 103;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grass_bg"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (IBAction)buttonPressed:(id)sender
{
   NSLog(@"hohohoh");
    int holesCount = -1;
    //задайте количество норок
    
    if(sender==self.button1.i){
        holesCount = 10;
        NSLog(@"button1 is pressed");
    }else
        if([sender tag]==button2.tag){
            holesCount = 20;
            
            NSLog(@"button2 is pressed");
        }else
            if ([sender tag]==button3.tag){
                holesCount = 30;
                
                NSLog(@"button3 is pressed");
            }
    NSLog(@"==1==");
    
    
    if(holesCount <= 0)return;
    
    GAGameController* gameController = [[GAGameController alloc] initWithHolesCount:holesCount];
    NSLog(@"==2==");
    [self presentModalViewController:gameController animated:YES];
}

@end
