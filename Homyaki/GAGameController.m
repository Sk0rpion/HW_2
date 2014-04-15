//
//  GAGameController.m
//  Homyaki
//
//  Created by Alexandr on 25.11.13.
//  Copyright (c) 2013 Alex Gra. All rights reserved.
//

#import "GAGameController.h"

@interface GAGameController ()
{
    int _holesCount;
    NSMutableArray* holeButtonsArray;
    NSTimer* gameTimer;
    int timerCallCount;
    bool isHamsterHere;
   
    
}
@property (nonatomic, assign) int livesCount;
@property (nonatomic, weak) IBOutlet UIView* boardView;
@property (weak, nonatomic) IBOutlet UILabel *lives;
@end

@implementation GAGameController
@synthesize livesCount = _livesCount, boardView;

- (id)initWithHolesCount:(int)holesCount
{
    self = [super init];
    if (self) {
        _holesCount = holesCount;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //делаем дополнительную инициализацию представления после загрузки из xib
    boardView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grass_bg"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self startGame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

//вызывается при повороте экрана
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateHolesPosition];
}

#pragma mark - UI
- (void)updateHolesPosition
{
    float rowHeight = 60;
    float colWidth = 52;
    float t = boardView.frame.size.width;
    int a = t/colWidth;
    
    
    for (int i = 0; i<_holesCount; i++){
        CGRect frame = CGRectMake((i % a) * colWidth, (i / a) * rowHeight, colWidth, rowHeight);
        [holeButtonsArray[i] setFrame:frame];
        [boardView addSubview: holeButtonsArray[i]];
    }
    
}

- (void)setLivesCount:(int)livesCount
{
    _livesCount = livesCount;
}

- (void)cleanUp
{
    if (holeButtonsArray){
    for (int i = 0; i<holeButtonsArray.count; i++){
        [holeButtonsArray[i] removeFromSuperview];
    }
       [holeButtonsArray removeAllObjects ];
    }
}

#pragma mark - Game logic
- (void)startGame
{
    if(_holesCount <= 0){
        NSLog(@"Holes count must be grether 0");
        return;
    }
    [self cleanUp];
    self.livesCount = 3;
    timerCallCount = 10;
    holeButtonsArray = [NSMutableArray new];
    CGSize buttonSize = [UIImage imageNamed:@"hamster"].size;
 
    NSString *livesCounter = [NSString stringWithFormat:@"Жизней: %d", _livesCount];
    self.lives.text = livesCounter;
    for(int i = 0; i < _holesCount; i++){
        UIButton *hole = [[UIButton alloc]init];
        [hole setImage:[UIImage imageNamed:@"hole.png" ] forState:UIControlStateNormal];
        holeButtonsArray[i] = hole;
    }
    [self updateHolesPosition];
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(gameTimerCall) userInfo:nil repeats:YES];
}

- (void)gameTimerCall
{
    timerCallCount--;
    if (isHamsterHere == YES){
        [self minusLive];
    }
    
    if(self.livesCount == 0)
        [self gameOver:NO];
    
    else if(timerCallCount <= 0){
        [self gameOver:YES];
    }
    
    
    else [self randomHamsterArrise];
}

- (BOOL)minusLive
{
    self.livesCount--;
    
    self.lives.text = [@"Жизней: " stringByAppendingString:[NSString stringWithFormat:@"%d", _livesCount]];
    return self.livesCount > 0;
}

- (void)randomHamsterArrise
{
    
    int randomNum = arc4random() % holeButtonsArray.count;
    for(int i = 0; i < holeButtonsArray.count; i++){
        UIButton *hamster = holeButtonsArray[randomNum];
        [hamster setImage:[UIImage imageNamed:@"hamster.png"] forState:UIControlStateNormal];
        isHamsterHere = YES;
        [holeButtonsArray[randomNum] addTarget:self action:@selector(hamsterPressed:)forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)hamsterPressed:(UIButton*)holeButt
{
   
    
    UIImageView *holeView = [[UIImageView alloc]initWithImage:[UIImage imageNamed: @"hamster.png"]];
    for (int i = 0; i<holeButtonsArray.count; i++){
   
        UIButton *disapp = holeButtonsArray[i];
        if (CGRectEqualToRect(disapp.frame, holeButt.frame)){
            [holeButtonsArray[i] setImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
            isHamsterHere = FALSE;
          
        }
    }
   
    
}

- (void)gameOver:(BOOL)isWin
{
    [gameTimer invalidate];
    gameTimer = nil;
    
    NSString* message = isWin? @"От хомяков не осталось и следа!" : @"Хомяки вас захватили!";
    NSString* okTitle = isWin? @"Да у них нет шансов" : @"Я ничтожество";
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:okTitle
                                              otherButtonTitles:nil];
    
    [alertView show];
    [self cleanUp];
}

- (IBAction)backPressed:(id)sender
{
    [gameTimer invalidate];
    gameTimer = nil;
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
