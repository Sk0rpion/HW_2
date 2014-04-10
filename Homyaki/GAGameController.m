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
    BOOL hamster;
    int random;
}

@property (nonatomic, assign) int livesCount;
@property (nonatomic, weak) IBOutlet UIView* boardView;
@property (weak, nonatomic) IBOutlet UILabel *livesLabel;
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
    boardView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grass_bg"]];
    boardView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
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
    [self cleanUp];
    float rowHeight = 60;
    float colWidth = 50;
    float boardSize = boardView.frame.size.width;
    int holeCount = boardSize / colWidth;
    for (int i = 0; i < _holesCount; i++)
    {
        CGRect frame = CGRectMake((i % holeCount) * colWidth, (i / holeCount) * rowHeight, colWidth, rowHeight);
        [holeButtonsArray[i] setFrame:frame];
        [boardView addSubview:holeButtonsArray[i]];
    }
}

- (void)setLivesCount:(int)livesCount
{
    _livesCount = livesCount;
}

- (void)cleanUp
{
    for(int i = 0; i < [holeButtonsArray count]; i++) {
        [holeButtonsArray[i] removeFromSuperview];
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
    NSString *lives = [NSString stringWithFormat:@"Жизней: %d", _livesCount];
    self.livesLabel.text = lives;
    timerCallCount = 10;
    hamster = NO;
    random = -1;
    holeButtonsArray = [NSMutableArray new];
    for(int i = 0; i < _holesCount; i++){
        UIButton *holes = [UIButton new];
        [holes setImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
        [holeButtonsArray addObject:holes];
    }
    [self updateHolesPosition];
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(gameTimerCall) userInfo:nil repeats:YES];
}

- (void)gameTimerCall
{
    if(_livesCount <= 0)
        [self gameOver:NO];
    if(timerCallCount <= 0)
        [self gameOver:YES];
    timerCallCount--;
    if (hamster == YES) {
        [self minusLive];
    }
    if(random != -1 && hamster == YES) {
        [holeButtonsArray[random] setImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
    }
    [self randomHamsterArrise];
}

- (BOOL)minusLive
{
    self.livesCount--;
    self.livesLabel.text = [@"Жизней: " stringByAppendingString:[NSString stringWithFormat:@"%d", _livesCount]];
    return self.livesCount > 0;
}

- (void)randomHamsterArrise
{
    random = arc4random() % holeButtonsArray.count;
    UIButton *holeHamster= holeButtonsArray[random];
    CGRect hamsterFrame = holeHamster.frame;
    UIButton *hamster1 = [UIButton new];
    hamster = YES;
    [holeHamster setImage:[UIImage imageNamed:@"hamster.png"] forState:UIControlStateNormal];
    [holeButtonsArray[random] addTarget:self action:@selector(hamsterPressed:) forControlEvents:UIControlEventTouchUpInside];
    [holeHamster setFrame:hamsterFrame];
    [boardView addSubview:hamster1];
}

- (void)hamsterPressed:(UIButton*)holeButt
{
    for(int i = 0; i < [holeButtonsArray count]; i++) {
        UIButton *button = [holeButtonsArray objectAtIndex:i];
        if(CGRectEqualToRect(holeButt.frame, button.frame)) {
            [holeButtonsArray[i] setImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
            hamster = NO;
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
}

- (IBAction)backPressed:(id)sender
{
    [gameTimer invalidate];
    gameTimer = nil;
    [self dismissModalViewControllerAnimated:YES];
}

@end
