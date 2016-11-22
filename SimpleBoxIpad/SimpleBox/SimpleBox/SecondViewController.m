//
//  SecondViewController.m
//  SimpleBox
//
//  Created by fnst1 on 15/12/11.
//  Copyright © 2015年 FUJISTU. All rights reserved.
//

#import "SecondViewController.h"
#import "SimpleBoxHandler.h"
#import "RotateImage.h"
#import "SimpleBoxMenu.h"

@interface SecondViewController ()<SimpleBoxAirConditionerDelegate,menuDidSelectedDelegate>
@property (nonatomic,assign) BOOL isCool;
@property (nonatomic,assign) BOOL cycModeInner;
@property (nonatomic,assign) BOOL isAuto;
@property (nonatomic,strong) NSArray *pictures;
@property (nonatomic,strong) SimpleBoxMenu *rightACMenu;
@property (nonatomic,strong) SimpleBoxMenu *leftACMenu;
@property (nonatomic,strong) SimpleBoxHandler *handler;
@property (nonatomic,strong) SimpleBoxAirConditioner *conditioner;
@property (weak, nonatomic) IBOutlet UIButton *titleInnerBtn;
@property (weak, nonatomic) IBOutlet UIButton *titleouterBtn;
@property (weak, nonatomic) IBOutlet UIButton *titleAutoBtn;
@property (weak, nonatomic) IBOutlet UIButton *titleOffBtn;
@property (weak, nonatomic) IBOutlet UIButton *titleTemBtn;
@property (strong, nonatomic) IBOutlet UIButton *cycMode;
@property (strong, nonatomic) IBOutlet UIButton *rightACCycMode;
- (IBAction)autoClickBtn;
- (IBAction)offClickBtn;
- (IBAction)temClickBtn;
- (IBAction)backHome:(id)sender;
- (IBAction)changeRightACCycMode:(id)sender;
- (IBAction)changeWindSpeed:(id)sender;
- (IBAction)changeCycMode:(id)sender;
- (IBAction)innerBtn:(UIButton *)button;
- (IBAction)outerBtn:(UIButton *)button;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RotateImage *rotate = [RotateImage alloc];
    rotate.imageWidth = 217;
    rotate = [rotate initWithFrame:CGRectMake(18, 97, 225, 225)];
    RotateImage *rotate2 = [RotateImage alloc];
    rotate2.imageWidth = 217;
    rotate2 = [rotate2 initWithFrame:CGRectMake(504, 97, 225, 225)];
    [self.view addSubview:rotate];
    [self.view addSubview:rotate2];
    self.handler = [SimpleBoxHandler sharedInstance];
    self.cycModeInner = YES;
    self.isAuto = YES;
    self.isCool = YES;
    [self.titleInnerBtn setImage:[UIImage imageNamed:_cycModeInner?@"内循环开":@"内循环关.png"] forState:UIControlStateNormal];
    [self.titleouterBtn setImage:[UIImage imageNamed:_cycModeInner?@"外循环关.png":@"外循环开.png"] forState:UIControlStateNormal];
    [self.titleAutoBtn setImage:[UIImage imageNamed:_isAuto?@"AUTO开.png":@"AUTO关.png"] forState:UIControlStateNormal];
    [self.titleOffBtn setImage:[UIImage imageNamed:_isAuto?@"OFF关.png":@"OFF开.png"] forState:UIControlStateNormal];
    [self.titleTemBtn setImage:[UIImage imageNamed:_isCool?@"雪花开.png":@"雪花关.png"] forState:UIControlStateNormal];
    
    self.leftACMenu = [self createACMenu:CGPointMake(CGRectGetMidX(self.cycMode.frame)-40, CGRectGetMidY(self.cycMode.frame)-40) cycModeTag:10];
    
    self.rightACMenu = [self createACMenu:CGPointMake(CGRectGetMidX(self.rightACCycMode.frame)-40, CGRectGetMidY(self.rightACCycMode.frame)-40) cycModeTag:20];
    
    [_handler setSimpleBoxACDelegate:self];
    self.pictures = @[@"吹头开.png",@"吹头开.png",@"吹头吹脚开.png",@"吹头吹脚开.png"];
    if (![_handler sendACParameterGetReq]) {
        [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
    }
    //    [_handler getData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma  mark  -- SimpleBoxAirConditionerDelegate

- (void)updateSimpleBoxACParameter:(SimpleBoxAirConditioner *)AirConditioner
{
    _conditioner = AirConditioner;
}


#pragma mark -- AlertDelegate
- (void)updateWindSpeed:(int)selectIndex
{
    
}

//- (IBAction)innerBtn:(UIButton *)button
//{
//    self.cycModeInner = true;
//    _conditioner.cycMode = CYC_MODE_INSIDE;
//    CABasicAnimation *theAnimation = [self buttonAnimation];
//    [self.titleInnerBtn.layer addAnimation:theAnimation forKey:@"animateTransform"];
//    [self.titleInnerBtn setImage:[UIImage imageNamed:_cycModeInner?@"内循环开.png":@"内循环关.png"] forState:UIControlStateNormal];
//    [self.titleouterBtn setImage:[UIImage imageNamed:_cycModeInner?@"外循环关.png":@"外循环开.png"] forState:UIControlStateNormal];
//    //    [_handler sendACParameterSetReq];
//}

//- (IBAction)outerBtn:(UIButton *)button
//{
//    self.cycModeInner = false;
//    _conditioner.cycMode = CYC_MODE_OUTER;
//    CABasicAnimation *theAnimation = [self buttonAnimation];
//    [self.titleouterBtn.layer addAnimation:theAnimation forKey:@"animateTransform"];
//    [self.titleInnerBtn setImage:[UIImage imageNamed:_cycModeInner?@"内循环开.png":@"内循环关.png"] forState:UIControlStateNormal];
//    [self.titleouterBtn setImage:[UIImage imageNamed:_cycModeInner?@"外循环关.png":@"外循环开.png"] forState:UIControlStateNormal];
//    //    [_handler sendACParameterSetReq];
//}

- (CABasicAnimation *)buttonAnimation
{
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimation.duration=0.1;
    theAnimation.removedOnCompletion = YES;
    theAnimation.fromValue = [NSNumber numberWithFloat:1];
    theAnimation.toValue = [NSNumber numberWithFloat:0.7];
    return theAnimation;
}
- (IBAction)backHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissSuccess");
    }];
}

- (IBAction)autoClickBtn {
    self.isAuto = YES;
    self.titleInnerBtn.userInteractionEnabled = YES;
    self.titleouterBtn.userInteractionEnabled = YES;
    self.titleTemBtn.userInteractionEnabled = YES;
    [self.titleAutoBtn setImage:[UIImage imageNamed:_isAuto?@"AUTO开.png":@"AUTO关.png"] forState:UIControlStateNormal];
    [self.titleOffBtn setImage:[UIImage imageNamed:_isAuto?@"OFF关.png":@"OFF开.png"] forState:UIControlStateNormal];
}

- (void)showAlertView:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}
- (IBAction)offClickBtn {
    self.isAuto = NO;
    self.isCool = NO;
    self.titleTemBtn.userInteractionEnabled = NO;
    [self.titleTemBtn setImage:[UIImage imageNamed:_isCool?@"雪花开.png":@"雪花关.png"] forState:UIControlStateNormal];
    [self.titleAutoBtn setImage:[UIImage imageNamed:_isAuto?@"AUTO开.png":@"AUTO关.png"] forState:UIControlStateNormal];
    [self.titleOffBtn setImage:[UIImage imageNamed:_isAuto?@"OFF关.png":@"OFF开.png"] forState:UIControlStateNormal];
    [self.titleInnerBtn setImage:[UIImage imageNamed:@"内循环关.png"] forState:UIControlStateNormal];
    [self.titleouterBtn setImage:[UIImage imageNamed:@"外循环关.png"] forState:UIControlStateNormal];
    self.titleInnerBtn.userInteractionEnabled = NO;
    self.titleouterBtn.userInteractionEnabled = NO;
}
- (IBAction)temClickBtn {
    [self.titleTemBtn.layer addAnimation:[self buttonAnimation] forKey:@"animateTransform"];
    if (_isCool) {
        _isCool = NO;
    }
    else
    {
        _isCool = YES;
    }
    [self.titleTemBtn setImage:[UIImage imageNamed:_isCool?@"雪花开.png":@"雪花关.png"] forState:UIControlStateNormal];
    
}

- (IBAction)changeCycMode:(id)sender {
    [_leftACMenu tapToSwitchOpenOrClose];
}

- (IBAction)changeRightACCycMode:(id)sender {
    [_rightACMenu tapToSwitchOpenOrClose];
}

- (IBAction)changeWindSpeed:(id)sender {
//    [self.view addSubview:_windSpeedView];
}
- (UIView *)createACMenu:(CGPoint)origin cycModeTag:(int) flag
{
    SimpleBoxMenu *menu = [[SimpleBoxMenu alloc] initWithOrigin:origin
                                                    andDiameter:72
                                                    andDelegate:self
                                                     themeColor:[UIColor grayColor]
                                                      menuColor:[UIColor clearColor]];
    menu.menuDelegate = self;
    menu.radius = 20;
    menu.extraDistance = 45;
    menu.MenuCount = 4;
    menu.flag = flag;
    menu.pictures =  @[@"吹头关.png",@"吹头关.png",@"吹头吹脚关.png",@"吹头吹脚关.png"];
    return menu;
}

- (void)menuDidSelected:(NSInteger)index
{
    switch (index/10) {
        case 1:
            [self.cycMode setImage:[UIImage imageNamed:[self.pictures objectAtIndex:index-_leftACMenu.flag-1]] forState:UIControlStateNormal];
            break;
        case 2:
            [self.rightACCycMode setImage:[UIImage imageNamed:[self.pictures objectAtIndex:index-_rightACMenu.flag-1]] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_leftACMenu.isOpened && _rightACMenu.isOpened) {
        [_leftACMenu tapToSwitchOpenOrClose];
        [_rightACMenu tapToSwitchOpenOrClose];
    }else if(_leftACMenu.isOpened){
        [_leftACMenu tapToSwitchOpenOrClose];
    }else if(_rightACMenu.isOpened){
        [_rightACMenu tapToSwitchOpenOrClose];
    }
}


@end
