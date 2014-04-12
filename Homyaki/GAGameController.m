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
    BOOL isHamster;
    int randomNum;
}
@property (nonatomic, weak) IBOutlet UILabel *lives;
@property (nonatomic, assign) int livesCount;
@property (nonatomic, weak) IBOutlet UIView* boardView;
@property (nonatomic, weak) IBOutlet UILabel *time;
@end

@implementation GAGameController
@synthesize livesCount = _livesCount, boardView,lives,time;

- (id)initWithHolesCount:(int)holesCount andTime:(int)time
{
    self = [super init];
    if (self) {
        _holesCount = holesCount;
        timerCallCount=time;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //делаем дополнительную инициализацию представления после загрузки из xib
    isHamster=YES;
    boardView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grass_bg"]];
    boardView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
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
    float rowHeight = 60;
    float colWidth = 55;
    int colCount=boardView.frame.size.width/colWidth;
    int rowCount=holeButtonsArray.count/colCount;
    if(holeButtonsArray.count%colCount!=0){
        rowCount++;
    }
    for(int i=0;i<rowCount;i++){
        for(int j=0;j<colCount;j++){
            if(i*colCount+j<holeButtonsArray.count){
                CGRect holePlace=CGRectMake((j) * colWidth,i * rowHeight,colWidth, rowHeight);
                [holeButtonsArray[i*colCount+j] setFrame:holePlace];
                [boardView addSubview:holeButtonsArray[i*colCount+j]];
            }
        }
    }
    //задайте правильные позиции кнопок чтобы не вылезали за границы boardView
}

- (void)setLivesCount:(int)livesCount
{
    _livesCount = livesCount;
    lives.text=[NSString stringWithFormat:@"Жизней: %d", _livesCount];
}

- (void)cleanUp
{
    //удаляем все кнопки с доски
    for(int i=0 ; i<holeButtonsArray.count;i++){
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
    [self setLivesCount:_livesCount];
    time.text=[NSString stringWithFormat:@"%d",timerCallCount ];
    randomNum=-1;
    holeButtonsArray = [NSMutableArray new];
    CGSize buttonSize = [UIImage imageNamed:@"hamster"].size;
    for(int i = 0; i < _holesCount; i++){
        UIButton *holeButton = [[UIButton alloc]init];
        [holeButton setImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
        [holeButton addTarget:self action:@selector(hamsterPressed:) forControlEvents:UIControlEventTouchUpInside];
        [holeButtonsArray addObject:holeButton];
        //создаем кнопки
    }
    [self updateHolesPosition];
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(gameTimerCall) userInfo:nil repeats:YES];
}

- (void)gameTimerCall
{
    [self randomHamsterArrise];
    if(!isHamster){
        _livesCount--;
        if(_livesCount>=0){
            [self setLivesCount:_livesCount];
        }
    }
    if(timerCallCount <= 0 || _livesCount<0){
        if(_livesCount>=0){
            [self gameOver:YES];
        }else{
            [self gameOver:NO];
        }
    }else{
        timerCallCount--;
        time.text=[NSString stringWithFormat:@"%d",timerCallCount ];
        isHamster=false;
    }
    
    
    
    //.........
    
    
}

- (BOOL)minusLive
{
    self.livesCount--;
    return self.livesCount > 0;
}

- (void)randomHamsterArrise
{
    if(randomNum>=0){
    [holeButtonsArray[randomNum] setImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
    }
    randomNum = arc4random() % holeButtonsArray.count;
    [holeButtonsArray[randomNum] setImage:[UIImage imageNamed:@"hamster.png"] forState:UIControlStateNormal];
}

- (void)hamsterPressed:(UIButton*)holeButt
{
    if(randomNum>=0){
        if(holeButt==holeButtonsArray[randomNum]){
            isHamster=YES;
            [holeButtonsArray[randomNum] setImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
        }else{
            isHamster=NO;
            [holeButtonsArray[randomNum] setImage:[UIImage imageNamed:@"hole.png"] forState:UIControlStateNormal];
        }
    }
    //...........
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
