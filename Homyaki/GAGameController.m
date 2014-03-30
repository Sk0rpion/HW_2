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
    int pressedHamster;
    int randomHamsterGeneratedNumber;
}

@property (weak, nonatomic) IBOutlet UILabel *livesCounterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *livesIndicator;
@property (nonatomic, assign) int livesCount;
@property (nonatomic, weak) IBOutlet UIView* boardView;
@end

@implementation GAGameController
@synthesize livesCount = _livesCount, boardView;

+ (NSString *)enemyImageName:(NSInteger)number {
    NSArray *enemies = [NSArray arrayWithObjects:@"enemy1", @"enemy2", @"enemy3", nil];
    if (number < enemies.count) {
        return [enemies objectAtIndex:number];
    }
    return [enemies objectAtIndex:0];
}

- (id)initWithHolesCount:(int)holesCount
{
    self = [super init];
    if (self) {
        _holesCount = holesCount;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //делаем дополнительную инициализацию представления после загрузки из xib
    boardView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ios-galaxy-bg"]];
    boardView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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

#define VERTICAL_MAX_SQUARES 5
#define HORIZONTAL_MAX_SQUARES 7

- (void)updateHolesPosition
{
    //float rowHeight = 60;
    //float colWidth = 55;
    //задайте правильные позиции кнопок чтобы не вылезали за границы boardView
    
    CGSize buttonSize = [UIImage imageNamed:@"galaxy-hole"].size;
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    NSLog(@"%d", deviceOrientation);
    
    int valueOfRow = 0;
    if (deviceOrientation == 1 || deviceOrientation == 2) {
        valueOfRow = VERTICAL_MAX_SQUARES;
    }
    else valueOfRow = HORIZONTAL_MAX_SQUARES;
    
    for(int i = 0; i < _holesCount; i++) {
        CGRect frame = CGRectMake(
                                  [GAGameController getPositionForButton:i withSize:buttonSize forSquareMaxNumber:valueOfRow].width,
                                  [GAGameController getPositionForButton:i withSize:buttonSize forSquareMaxNumber:valueOfRow].height,
                                  buttonSize.width, buttonSize.height);
        
        UIButton *holeButton = [holeButtonsArray objectAtIndex:i];
        holeButton.frame = frame;
    }
}

- (void)setLivesCount:(int)livesCount
{
    _livesCount = livesCount;
}

- (void)cleanUp
{
    for (UIButton *button in holeButtonsArray) {
        [holeButtonsArray removeObject:button];
    }
}


//-------------------------------------------------------------------
#pragma mark - Game logic

#define ROUND 10
#define MAX_HEALTH 100
- (void)startGame
{
    if(_holesCount <= 0){
        NSLog(@"Holes count must be grether 0");
        return;
    }
    
    [self cleanUp];
    
    self.livesCounterLabel.text = [NSString stringWithFormat:@"HP: %d", MAX_HEALTH];
    
    
    self.livesCount = 3;
    timerCallCount = ROUND;
    holeButtonsArray = [NSMutableArray new];
    CGSize buttonSize = [UIImage imageNamed:@"galaxy-hole"].size;
    
    for(int i = 0; i < _holesCount; i++) {
        CGRect frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height); // nice size but wrong position
        UIButton *holeButton = [[UIButton alloc] initWithFrame:frame];
        [holeButton setImage:[UIImage imageNamed:@"galaxy-hole"] forState:UIControlStateNormal];
        [holeButton setImage:[UIImage imageNamed:@"galaxy-hole"] forState:UIControlStateHighlighted];
        [holeButton setImage:[UIImage imageNamed:@"galaxy-hole"] forState:UIControlStateSelected];
        [holeButton addTarget:self action:@selector(hamsterPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [holeButtonsArray addObject:holeButton];
        [self.view addSubview:holeButton];
    }
    [self updateHolesPosition];
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(gameTimerCall) userInfo:nil repeats:YES];
}

- (void)gameTimerCall
{
    if(timerCallCount <= 0)
        [self gameOver:YES];
    timerCallCount--;
    
    [self randomHamsterArrise];
}

- (BOOL)minusLive
{
    NSLog(@"%d", self.livesCount);
    self.livesCount--;
    if (self.livesCount == 2) {
        self.livesIndicator.image = [UIImage imageNamed:@"hearts2"];
    }
    else if (self.livesCount == 1) {
        self.livesIndicator.image = [UIImage imageNamed:@"hearts1"];
    }
    self.livesCounterLabel.text = [NSString stringWithFormat:@"HP: %d", (100 / 3 * self.livesCount)];
    return self.livesCount > 0;
}

- (void)randomHamsterArrise
{
    pressedHamster = randomHamsterGeneratedNumber;
    int randomNum = arc4random() % holeButtonsArray.count;
    
    UIButton *button = [holeButtonsArray objectAtIndex:randomNum];
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFromBottom];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [button.layer addAnimation:animation forKey:@"EaseOut"];
    NSString *imageName = [GAGameController enemyImageName:(arc4random() % 3)];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];
    randomHamsterGeneratedNumber++;
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hollWood) userInfo:nil repeats:NO];
}

- (void)hollWood {
    if (pressedHamster != randomHamsterGeneratedNumber) {
        if (![self minusLive]) {
            [self gameOver:NO];
        }
    }
    
    for(int i = 0; i < holeButtonsArray.count; i++){
        UIButton *button = [holeButtonsArray objectAtIndex:i];
        [button setImage:[UIImage imageNamed:@"galaxy-hole"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"galaxy-hole"] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"galaxy-hole"] forState:UIControlStateSelected];

    }
}

- (void)hamsterPressed:(UIButton*)holeButt
{
    if (holeButt.currentImage == [UIImage imageNamed:@"enemy1"] ||
        holeButt.currentImage == [UIImage imageNamed:@"enemy2"] ||
        holeButt.currentImage == [UIImage imageNamed:@"enemy3"]) {
        pressedHamster++;
        [holeButt setImage:[UIImage imageNamed:@"galaxy-hole"] forState:UIControlStateNormal];
        [holeButt setImage:[UIImage imageNamed:@"galaxy-hole"] forState:UIControlStateHighlighted];
        [holeButt setImage:[UIImage imageNamed:@"galaxy-hole"] forState:UIControlStateSelected];
    }
}

- (void)gameOver:(BOOL)isWin
{
    [gameTimer invalidate];
    gameTimer = nil;
    
    NSString* message = isWin? @"Победа" : @"Пускай сегодня не повезло";
    NSString* okTitle = isWin? @"Еще разок" : @"Попробовать заного";
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:okTitle
                                              otherButtonTitles:nil];
    [alertView show];
    [self backPressed:nil];
}

- (IBAction)backPressed:(id)sender
{
    [gameTimer invalidate];
    gameTimer = nil;
    
    [self dismissModalViewControllerAnimated:YES];
}


#define TOP_OFFSET 80
#define LEFT_OFFSET 15
#define PADDING 10

+ (CGSize)getPositionForButton:(NSInteger)number withSize:(CGSize)size forSquareMaxNumber:(NSInteger)squares {
    
    int rows = number / squares;
    number %=squares;
    int x = number * (size.width + PADDING) + LEFT_OFFSET;
    int y = rows * (size.height + PADDING) + TOP_OFFSET;
        
    CGSize position = CGSizeMake(x, y);
    return position;
}

@end
