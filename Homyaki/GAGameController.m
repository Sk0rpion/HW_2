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
    BOOL hamerExist;
    int k;
}
@property (nonatomic, assign) int livesCount;
@property (nonatomic, weak) IBOutlet UIView* boardView;
@property (nonatomic, weak) IBOutlet UILabel *lableOFLives;

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

//вызывается при повороте экрана
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateHolesPosition];
}

#pragma mark - UI
- (void)updateHolesPosition
{
    float rowHeight = 60;
    float colWidth = 50;
    //задайте правильные позиции кнопок чтобы не вылезали за границы boardView
    float bsize = boardView.frame.size.width;
    int hcount = bsize/ colWidth;
    
       for (int i = 0; i < _holesCount; i++)
           {
                 CGRect frame = CGRectMake((i % hcount) * colWidth, (i / hcount) * rowHeight, colWidth, rowHeight);
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
    //удаляем все кнопки с доски
    if (holeButtonsArray){
        for (int i=0; i<holeButtonsArray.count; i++) {
            [holeButtonsArray[i] removeFromSuperview];
            
    }
        
      [holeButtonsArray removeAllObjects];
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
    _livesCount = 3;
    timerCallCount = 10;
    NSString *lives = [NSString stringWithFormat:@"Жизней: %d", _livesCount];
    self.lableOFLives.text = lives;
    
    //hamerExist = 0;                    //             ..............           //???
    holeButtonsArray = [NSMutableArray new];
    CGSize buttonSize = [UIImage imageNamed:@"hamster"].size;
//    NSString *livesCounter = [NSString stringWithFormat:@"Жизней: %d", _livesCount];
//    self.lableOFLives.text = livesCounter;
    for(int i = 0; i < _holesCount; i++){
        //создаем кнопки
        UIButton *holeButton = [[UIButton alloc] init];
        [holeButton setImage:[UIImage imageNamed:@"hole"] forState:UIControlStateNormal];
        [holeButtonsArray addObject:holeButton];   ///........???
    }
    [self updateHolesPosition];
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(gameTimerCall) userInfo:nil repeats:YES];
}

- (void)gameTimerCall
{
    timerCallCount--;
    
    //.........
    if (hamerExist == YES) {
        [self minusLive];
         }
    if(self.livesCount == 0)
        [self gameOver:NO];
    
    else
        if(timerCallCount <= 0){
      [self gameOver:YES];
    }
     else
         if (hamerExist && k!=-10)
             [holeButtonsArray[k] setImage:[UIImage imageNamed:@"hole"] forState:UIControlStateNormal];
    [self randomHamsterArrise];
    
    
}

- (BOOL)minusLive
{
    self.livesCount--;
    self.lableOFLives.text = [NSString stringWithFormat:@"Жизней: %d", _livesCount];
    return self.livesCount > 0;
}

- (void)randomHamsterArrise
{
    int randomNum = arc4random() % (holeButtonsArray.count+1);
    k = randomNum;
    for(int i = 0; i < holeButtonsArray.count; i++){
        //...........
        UIButton *hamer = holeButtonsArray[randomNum];
            [hamer setImage:[UIImage imageNamed:@"hamster"] forState:UIControlStateNormal];
            hamerExist = true;
        [holeButtonsArray[randomNum] addTarget:self action:@selector(hamsterPressed:)forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)hamsterPressed:(UIButton*)holeButt
{
    //...........
    UIImageView *hamstaHole = [[UIImageView alloc]initWithImage:[UIImage imageNamed: @"hamster.png"]];
     for (int i = 0; i<holeButtonsArray.count; i++){
     UIButton *destroy = holeButtonsArray[i];
    
     if (CGRectEqualToRect(destroy.frame, holeButt.frame)){
             [holeButtonsArray[i] setImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
             hamerExist = FALSE;
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
