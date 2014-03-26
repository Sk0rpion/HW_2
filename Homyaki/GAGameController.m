//
//  GAGameController.m
//  Homyaki
//
//  Created by Alexandr on 25.11.13.
//  Copyright (c) 2013 Alex Gra. All rights reserved.
//

#import "GAGameController.h"
#import "UIHamsterButton.h"

#define HOLE_WIDTH 45.0f
#define HOLE_HEIGHT 50.0f

@interface GAGameController ()
{
    int _holesCount;
    NSMutableArray* holeButtonsArray;
    NSTimer* gameTimer;
    int timerCallCount;
}
@property (weak, nonatomic) IBOutlet UILabel *livesCountLabel;
@property (nonatomic, assign) int livesCount;
@property (nonatomic, weak) IBOutlet UIView* boardView;
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
    [boardView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
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
- (void)updateHolesPosition {
    int columns = boardView.frame.size.width / (HOLE_WIDTH+10);
    int rows = _holesCount / columns;
    if (_holesCount % columns != 0) {
        rows++;
    }
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
            int index = i*columns + j;
            
            if (index >= _holesCount) {
                break;
            }
            
            UIButton *button = nil;
            if (index < holeButtonsArray.count) {
                button = [holeButtonsArray objectAtIndex:index];
            } else {
                button = [UIHamsterButton buttonWithType:UIButtonTypeCustom];
                [button addTarget:self action:@selector(hamsterPressed:) forControlEvents:UIControlEventTouchUpInside];
                [holeButtonsArray addObject:button];
                
                [boardView addSubview:button];
            }
            [button setFrame:CGRectMake(j*(HOLE_WIDTH+10), i*(HOLE_HEIGHT+10), HOLE_WIDTH, HOLE_HEIGHT)];
        }
    }
}

- (void)setLivesCount:(int)livesCount
{
    _livesCount = livesCount;
    [_livesCountLabel setText:[NSString stringWithFormat:@"Жизней: %d", livesCount]];
}

- (void)cleanUp {
    for (UIHamsterButton *button in holeButtonsArray) {
        [button showHamster:NO];
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
    [self cleanUp];
    holeButtonsArray = [NSMutableArray new];
    [self updateHolesPosition];
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(gameTimerCall) userInfo:nil repeats:YES];
}

- (void)gameTimerCall
{
    if(timerCallCount <= 0) {
        [self gameOver:YES];
        return;
    }
    
    timerCallCount--;
    
    BOOL allHamstersHidden = YES;
    for(int i = 0; i < holeButtonsArray.count; i++){
        UIHamsterButton *button = holeButtonsArray[i];
        if (![button hamsterHidden]) {
            [button showHamster:NO];
            allHamstersHidden = NO;
            break;
        }
    }
    
    if (!allHamstersHidden && ![self minusLive]) {
        [self gameOver:NO];
    } else {
        [self randomHamsterArrise];
    }
    
}

- (BOOL)minusLive
{
    self.livesCount--;
    return self.livesCount > 0;
}

- (void)randomHamsterArrise
{
    int randomNum = arc4random() % holeButtonsArray.count;
    
    UIHamsterButton *button = [holeButtonsArray objectAtIndex:randomNum];
    [button showHamster:YES];
}

- (void)hamsterPressed:(UIButton*)holeButt
{
    UIHamsterButton *button = (UIHamsterButton *)holeButt;
    if (![button hamsterHidden]) {
        [button showHamster:NO];
    }
}

- (void)gameOver:(BOOL)isWin
{
    [gameTimer invalidate];
    gameTimer = nil;
    [self cleanUp];
    
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
