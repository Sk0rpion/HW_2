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
    BOOL isHamsterEnabled;
    int beforeRandomNum;
}
@property (nonatomic, assign) int livesCount;
@property (nonatomic, weak) IBOutlet UIView* boardView;
@property (weak, nonatomic) IBOutlet UILabel *lievesCountLabel;
@end

@implementation GAGameController
@synthesize livesCount = _livesCount, boardView;

- (id)initWithHolesCount:(int)holesCount
{
    self = [super init];
    if (self) {
        _holesCount = holesCount;
        NSLog(@"holes count: %i",_holesCount);
        
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
    [self cleanUp];
    
    float rowHeight = 60;
    float colWidth = 55;
    
    //счетчики для расположения hole по строчкам и столбцам
    float x = 20;
    float y = 20;
    
    int selfWidth = boardView.frame.size.width;
    
    //заполняем hole'ми borderView
    int i = 0;
    while ( i < _holesCount)
    {
        
        if (x+colWidth >= selfWidth)
        {
            y += rowHeight;
            x = 20;
        }
        
        while(i < _holesCount && x+colWidth < selfWidth)
        {
            CGRect frame = CGRectMake(x, y, colWidth, rowHeight);
            [holeButtonsArray[i] setFrame:frame];
            [boardView addSubview:holeButtonsArray[i]];
            
            x += colWidth;
            i++;
        }
    }
    
}

- (void)setLivesCount:(int)livesCount
{
    _livesCount = livesCount;
}

- (void)cleanUp
{
    //удаляем все кнопки с доски
    
    for (int i=0;i<[holeButtonsArray count];i++)
    {
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
    self.lievesCountLabel.text=[@"Жизней: " stringByAppendingString: [NSString stringWithFormat:@"%i", _livesCount]];
    timerCallCount = 10;
    isHamsterEnabled = NO;
    beforeRandomNum = -1;
    holeButtonsArray = [NSMutableArray new];
    CGSize buttonSize = [UIImage imageNamed:@"hamster"].size;
    CGRect frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    UIButton *but;
    
    //заполняем массив holeButtonsArray hole'сами
    for(int i = 0; i < _holesCount; i++){
        but = [[UIButton alloc] initWithFrame:frame];
        [holeButtonsArray addObject:but];
        [holeButtonsArray[i] setBackgroundImage: [UIImage imageNamed:@"hole"] forState:UIControlStateNormal];
        but = nil;
    }
    
    [self updateHolesPosition];
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(gameTimerCall) userInfo:nil repeats:YES];
}



- (void)gameTimerCall
{
    if(_livesCount == 0)
    {
        [self gameOver:NO];
    }
    
    if(timerCallCount <= 0)
        [self gameOver:YES];
    timerCallCount--;
    
    if (!isHamsterEnabled)
        [self minusLive];
    //удаляем предыдущего хомячка с borderView, если он есть
    if (beforeRandomNum != -1 && !isHamsterEnabled)
    {
        [holeButtonsArray[beforeRandomNum] setImage:nil forState:UIControlStateNormal];
    }
    
    [self randomHamsterArrise];
}

- (BOOL)minusLive
{
    self.livesCount--;
    
    //задаем количество жизней на лейбле
    if(_livesCount < 0)
    {
        self.lievesCountLabel.text = @"X_X";
    }else
        self.lievesCountLabel.text = [@"Жизней: " stringByAppendingString: [NSString stringWithFormat:@"%i", _livesCount]];
    
    return self.livesCount > 0;
}

- (void)randomHamsterArrise
{
    
    int randomNum = arc4random() % holeButtonsArray.count;
    for(int i = 0; i < holeButtonsArray.count; i++)
    {
        
        //присваиваем рандомной hole своего hamster'a
        [holeButtonsArray[randomNum] setImage:[UIImage imageNamed:@"hamster"] forState:UIControlStateNormal];
        [holeButtonsArray[randomNum] addTarget:self action:@selector(hamsterPressed:) forControlEvents:UIControlEventTouchUpInside];
        //запоминаем значение randomNum в beforeRandomNum, чтобы удалить предыдущего хомячка с borderView
        beforeRandomNum = randomNum;
        
    }
}

- (void)hamsterPressed:(UIButton*)holeButt
{
    //удаляем хомячка, если на него нажали
    [holeButtonsArray[[holeButtonsArray indexOfObject:holeButt]] setImage:nil forState:UIControlStateNormal];
    //пишем в булеву переменную isHamsterEnabled YES, чтобы жизни не отбирались
    isHamsterEnabled = YES;
}

- (void)gameOver:(BOOL)isWin
{
    //после окончания игры стираем ямки и хомячков
    [self cleanUp];
    
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
