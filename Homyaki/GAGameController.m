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
@property (nonatomic, assign) int livesCount;
@property (nonatomic, weak) IBOutlet UIView* boardView;
@property (nonatomic, assign) float numberOfcolumn;
@property (nonatomic, assign) float space;
@property (nonatomic, assign) int currentHamster;
@property (weak, nonatomic) IBOutlet UILabel *lives;
@property (nonatomic, nonatomic) BOOL catch;
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
    _catch = NO;
    //делаем дополнительную инициализацию представления после загрузки из xib
    boardView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grass_bg"]];
    [boardView forwardingTargetForSelector:@selector(backPressed:)];
    
    
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
    [self cleanUp];
    float space = 50;
    float currX = 20;
    float currY = 0;
    CGRect rect;
    CGSize buttonSize = [UIImage imageNamed:@"hamster"].size;
    for (int i=0; i<_holesCount;i++) {
        if (currX + space > boardView.frame.size.width-50) {
            currY = currY + space;
            currX = 20;
        }
        else {
            if (i != 0)
                currX = currX + space;
        }
        rect = CGRectMake(currX, currY,  buttonSize.width, buttonSize.height);
        [holeButtonsArray[i] setFrame:rect];
        [boardView addSubview:holeButtonsArray[i]];
    }
}

- (void)setLivesCount:(int)livesCount
{
    _livesCount = livesCount;
}

- (void)cleanUp
{
    //удаляем все кнопки с доски
    for(int i = 0; i < _holesCount; i++){
        [[holeButtonsArray objectAtIndex:i] removeFromSuperview];
    }
}

#pragma mark - Game logic
- (void)startGame
{
    [self takePlace];
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
    self.livesCount--;
    return self.livesCount > 0;
}

- (void)randomHamsterArrise
{
    int randomNum = arc4random() % holeButtonsArray.count;
    
    for(int i = 0; i < holeButtonsArray.count; i++){
        
        if (i == randomNum) {
            
            [holeButtonsArray[_currentHamster] setImage:[UIImage imageNamed:@"hole"] forState:UIControlStateNormal];
            [holeButtonsArray[i] setImage:[UIImage imageNamed:@"hamster"] forState:UIControlStateNormal];
            _currentHamster = i;
            if(!_catch && (timerCallCount!=9)) {
                if (_livesCount > 0) {
                    _livesCount= _livesCount - 1;
                    _lives.text = [NSString stringWithFormat:@"Жизней: %d",_livesCount];
                }
                else {
                    [self gameOver:NO];
                }
            }
            // _catch = NO;
        }
    }
    
}

- (void)hamsterPressed:(UIButton*)holeButt
{
    if ([holeButtonsArray[_currentHamster] isEqual:holeButt]) {
        _catch = YES;
        [holeButt setImage:[UIImage imageNamed:@"hole"] forState:UIControlStateNormal];
    }
    else {
        
        if (_livesCount > 0) {
            [holeButtonsArray[_currentHamster] setImage:[UIImage imageNamed:@"hole"] forState:UIControlStateNormal];
            _livesCount= _livesCount - 1;
            _lives.text = [NSString stringWithFormat:@"Жизней: %d",_livesCount];
            _catch = NO;
        }
        else {
            [self gameOver:NO];
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

-(void)takePlace
{
    if(_holesCount <= 0){
        NSLog(@"Holes count must be grether 0");
        return;
    }
    [self cleanUp];
    self.livesCount = 3;
    _lives.text = [NSString stringWithFormat:@"Жизней: %d",_livesCount];
    timerCallCount = 10;
    holeButtonsArray = [NSMutableArray new];
    CGSize buttonSize = [UIImage imageNamed:@"hamster"].size;
    
    for(int i = 0; i < _holesCount; i++){
        CGRect frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
        holeButtonsArray[i] = [[UIButton alloc]initWithFrame:frame];
        [holeButtonsArray[i] setImage:[UIImage imageNamed:@"hole"] forState:UIControlStateNormal];
        [holeButtonsArray[i] addTarget:self action:@selector(hamsterPressed:) forControlEvents:UIControlEventTouchUpInside];
        [boardView addSubview:holeButtonsArray[i]];
        
    }
    [self updateHolesPosition];
    
}
@end
