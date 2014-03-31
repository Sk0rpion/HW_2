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
}
@property (weak, nonatomic) IBOutlet UILabel *livesLabel;
@property (nonatomic, assign) int livesCount;
@property (nonatomic, weak) IBOutlet UIView* boardView;
@property (nonatomic, assign) int currentHamster;
@property (nonatomic, strong) UIImage *hamsterImg;
@property (nonatomic, strong) UIImage *holeImg;
@end

@implementation GAGameController
@synthesize livesCount = _livesCount, boardView, currentHamster;

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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateHolesPosition];
}

#pragma mark - UI
- (void)updateHolesPosition
{
    float rowHeight = 60;
    float colWidth = 55;
    int holesInRow = (int) boardView.frame.size.width / colWidth;
    for (int i = 0; i < _holesCount; i++)
    {
        UIButton *butt = holeButtonsArray[i];
        CGRect frame = CGRectMake((i % holesInRow) * colWidth, (i / holesInRow) * rowHeight, colWidth, rowHeight);
        [butt setFrame:frame];
    }
}

- (void)cleanUp
{
    NSArray *subviews = [boardView subviews];
    for (id subview in subviews)
    {
        [boardView delete:subview];
    }
}

- (void)updateLivesLabel
{
    _livesLabel.text = [NSString stringWithFormat:@"Жизней: %d", _livesCount];
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
    _hamsterImg = [UIImage imageNamed:@"hamster"];
    _holeImg = [UIImage imageNamed:@"hole"];
    for(int i = 0; i < _holesCount; i++){
        UIButton *holeButt = [UIButton new];
        [holeButt setOpaque:NO];
        [holeButt sizeThatFits:buttonSize];
        [holeButt setImage:_holeImg forState:UIControlStateNormal];
        [holeButt addTarget:self action:@selector(hamsterPressed:) forControlEvents:UIControlEventTouchUpInside];
        [holeButtonsArray addObject:holeButt];
        [boardView addSubview:holeButt];
    }
    [self updateLivesLabel];
    currentHamster = -1;
    [self updateHolesPosition];
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(gameTimerCall) userInfo:nil repeats:YES];
}

- (void)gameTimerCall
{
    if(timerCallCount <= 0)
    {
        [self gameOver:YES];
        return;
    }
    timerCallCount--;
    
    
    [self randomHamsterArrise];
}

- (BOOL)minusLive
{
    self.livesCount--;
    [self updateLivesLabel];
    return self.livesCount > 0;
}

- (void)randomHamsterArrise
{
    int randomNum = arc4random() % holeButtonsArray.count;
    if (currentHamster != -1)
    {
        if ([self minusLive] == NO)
        {
            [self gameOver:NO];
        }
        else
        {
            [holeButtonsArray[currentHamster] setImage:_holeImg forState:UIControlStateNormal];
        }
    }
    currentHamster = randomNum;
    [holeButtonsArray[currentHamster] setImage:_hamsterImg forState:UIControlStateNormal];
}

- (void)hamsterPressed:(UIButton*)holeButt
{
    int hamsterNumb = [holeButtonsArray indexOfObject:holeButt];
    if (hamsterNumb == currentHamster)
    {
        [holeButtonsArray[currentHamster] setImage:_holeImg forState:UIControlStateNormal];
        currentHamster = -1;
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
}

- (IBAction)backPressed:(id)sender
{
    [gameTimer invalidate];
    gameTimer = nil;
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
