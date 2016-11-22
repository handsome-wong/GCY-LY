//
//  SimpleBoxACSeatViewController.m
//  SimpleBox
//
//  Created by fnst001 on 12/3/15.
//  Copyright (c) 2015 FUJISTU. All rights reserved.
//

#import "SimpleBoxACSeatViewController.h"
#import <SimpleBoxServer/server.h>
#import "SimpleBoxHandler.h"
#import "ACParameter.h"

// Business ID
#define ACGETPARAMETERID        0X0803
#define ACSETPARAMETERID        0X0802
#define ACGETPARAMETRSQID       0x4803
#define ACSETPARAMETRSQID       0x4802
#define ACPARAMETERNOTIFY       0x8804
#define REVERSESTATUSID         0x8906
#define REVERSESTATUSRSPID      0x4906
#define SERVERCLOSED            0xFFFF

#define ACPARAMETERSETRSQNOTRFICATION   @"ACParameterSetRsqNotification"
#define ACPARAMETERGETREQNOTIFICATION   @"ACParameterGetReqNotification"
#define ACPARAMETERNOTIFYNOTIFICATION   @"ACParameterNotifyNotification"

@interface SimpleBoxACSeatViewController ()

@property (nonatomic, strong) SimpleBoxHandler *handler;
@property (nonatomic, strong) ACParameter *acParameter;

@property (weak, nonatomic) IBOutlet UIButton *maxButton;
@property (weak, nonatomic) IBOutlet UIButton *leftTempDownButton;
@property (weak, nonatomic) IBOutlet UIImageView *leftTempIV;
@property (weak, nonatomic) IBOutlet UIButton *leftTempUpButton;
@property (weak, nonatomic) IBOutlet UIButton *frontDefrostButton;
@property (weak, nonatomic) IBOutlet UIButton *powButton;
@property (weak, nonatomic) IBOutlet UIButton *backDefrostButton;
@property (weak, nonatomic) IBOutlet UIButton *fanSpeedDownButton;
@property (weak, nonatomic) IBOutlet UIButton *fanModeButton;
@property (weak, nonatomic) IBOutlet UIImageView *fanSpeedIV;
@property (weak, nonatomic) IBOutlet UIButton *onButton;
@property (weak, nonatomic) IBOutlet UIButton *cycleModeButton;
@property (weak, nonatomic) IBOutlet UIButton *fanSpeedUpButton;
@property (weak, nonatomic) IBOutlet UIButton *acButton;
@property (weak, nonatomic) IBOutlet UIButton *rightTempDownButton;
@property (weak, nonatomic) IBOutlet UIImageView *rightTempIV;
@property (weak, nonatomic) IBOutlet UIButton *rightTempUpButton;
@property (weak, nonatomic) IBOutlet UIButton *dualButton;

@end

@implementation SimpleBoxACSeatViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self updateView];
//    self.handler = [SimpleBoxHandler sharedInstance];
//    if (![_handler sendACParameterGetReq]) {
//        [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
//    }
    _acParameter = [[ACParameter alloc] init];
    [self getACParameter];
}

/**
 *  实时获取box数据并更新界面(统一获取数据)
 */
- (void)getACParameter
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UINT16 resBusinessId;
        char buff[256] = "";
        while (1) {
            

            [NSThread sleepForTimeInterval:0.3f];
            
            buff[256] = "";
            int length = get_data(&resBusinessId, buff, 256);
            if (length > 0) {
                switch (resBusinessId) {
                    case ACPARAMETERNOTIFY:
                    {
                        NSData *data = [NSData dataWithBytes:buff length:length];
                        ACParameterNotify *acParameter = [ACParameterNotify parseFromData:data];
                        // 数据持久化
                        if (acParameter) {
                            [[NSUserDefaults standardUserDefaults] setObject:@{@"isON": acParameter.onOff? @1: @0, @"leftTemp": [NSNumber numberWithInt:acParameter.temperature0], @"rightTemp": [NSNumber numberWithInt:acParameter.temperature1], @"isMax": acParameter.autoOpen? @1: @0, @"isFrontDeforst": acParameter.frontDefrost? @1: @0, @"isBackDeforst": acParameter.backDefrost? @1: @0, @"fanMode": [NSNumber numberWithInt:acParameter.blowMode], @"fanSpeed": [NSNumber numberWithInt:acParameter.windSpeed], @"isAC": acParameter.acOpen? @1: @0, @"cycleMode": [NSNumber numberWithInt:acParameter.cycMode], @"isDual": acParameter.dualOpen? @1: @0} forKey:@"InitialACParameter"];
                        }
                        NSDictionary *ACParameterDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"InitialACParameter"];
                        _acParameter.isOn = [[ACParameterDic objectForKey:@"isON"] boolValue];
                        _acParameter.leftTemp = [[ACParameterDic objectForKey:@"leftTemp"] integerValue];
                        _acParameter.rightTemp = [[ACParameterDic objectForKey:@"rightTemp"] integerValue];
                        _acParameter.isMax = [[ACParameterDic objectForKey:@"isMax"] boolValue];
                        _acParameter.isFrontDeforst = [[ACParameterDic objectForKey:@"isFrontDeforst"] boolValue];
                        _acParameter.isBackDeforst = [[ACParameterDic objectForKey:@"isBackDeforst"] boolValue];
                        _acParameter.fanMode = (BlowMode)[[ACParameterDic objectForKey:@"fanMode"] integerValue];
                        _acParameter.fanSpeed = [[ACParameterDic objectForKey:@"fanSpeed"] integerValue];
                        _acParameter.isAC = [[ACParameterDic objectForKey:@"isAC"] boolValue];
                        _acParameter.cycleMode = (CycMode)[[ACParameterDic objectForKey:@"cycleMode"] integerValue];
                        _acParameter.isDual = [[ACParameterDic objectForKey:@"isDual"] boolValue];
                        [self updateView];
                    }
                        break;
                    case ACGETPARAMETRSQID:
//                        [_simpleBoxAC getACParameterRsqData:resBusinessId ACParameterBuff:buff length:ret];
                        break;
                    case ACSETPARAMETRSQID:
                        // sunlf: protobuf
//                        [_simpleBoxAC getACParameterSetRsqData:resBusinessId ACParameterBuff:buff length:ret];
                        break;
                    case REVERSESTATUSID:
//                        [self getReverStatusNotifyData:resBusinessId reverStatusBuff:buff length:ret];
                        break;
                    case SERVERCLOSED:
                    {
                        disconnect_box(SERVERCLOSED);
//                        self.isConnected = NO;
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            NSLog(@"通信异常");
//                            if (_timer == nil) {
//                                self.timer = [NSTimer scheduledTimerWithTimeInterval:30
//                                                                              target:self
//                                                                            selector:@selector(connectBox)
//                                                                            userInfo:nil
//                                                                             repeats:YES];
//                            }
//                            [_timer fire];
//                        });
                    }
                        break;
                    default:
                        break;
                }
            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self updateView];
//            });
        }
    });
}

#pragma mark - event response

/**
 *  关空调事件
 *
 *  @param sender 关按钮
 */
- (IBAction)turnOnAirConditioningAction:(id)sender {
    // 只能关不能开
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setOnOff:NO];
    [self updateWithACParameterSetReqBuilder:builder];
    // 初始化空调界面
    [self initView];
}

- (IBAction)leftTempUpAction:(id)sender {
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setTempOption0:TempOptionTempUp];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)leftTempDownAction:(id)sender {
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setTempOption0:TempOptionTempDown];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)maxAction:(id)sender {
    UIButton *max = (UIButton *)sender;
    max.selected = !max.selected;
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setAutoOpen:max.selected];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)frontDefrostAction:(id)sender {
    UIButton *front = (UIButton *)sender;
    front.selected = !front.selected;
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setFrontDefrostSwitch:front.selected];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)backDefrostAction:(id)sender {
    UIButton *back = (UIButton *)sender;
    back.selected = !back.selected;
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setBackDefrostSwitch:back.selected];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)fanModeAction:(id)sender {
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setBlowModeSwitch:YES];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)fanSpeedDownAction:(id)sender {
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setWindOption:WindOptionSpeedDown];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)fanSpeedUpAction:(id)sender {
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setWindOption:WindOptionSpeedUp];
    [self updateWithACParameterSetReqBuilder:builder];
}

/**
 *  开空调事件
 *
 *  @param sender AC按钮
 */
- (IBAction)acAction:(id)sender {
    UIButton *ac = (UIButton *)sender;
    ac.selected = !ac.selected;
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setAcopen:ac.selected];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)cycleModeAction:(id)sender {
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setCycModeSwitch:YES];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)dualAction:(id)sender {
    UIButton *dual = (UIButton *)sender;
    dual.selected = !dual.selected;
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setDualOpen:dual.selected];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)rightTempUpAction:(id)sender {
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setTempOption1:TempOptionTempUp];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)rightTempDownAction:(id)sender {
    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    [builder setTempOption1:TempOptionTempDown];
    [self updateWithACParameterSetReqBuilder:builder];
}

- (IBAction)back:(id)sender {
    [self writeACParameterFromFile];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACPARAMETERGETREQNOTIFICATION object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACPARAMETERSETRSQNOTRFICATION object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACPARAMETERNOTIFYNOTIFICATION object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  - private methods

//- (void)initACParameter
//{
//    [self createACParameterFile];
//    [self readACParameterFromFile];
//    _acParameter = [[ACParameter alloc] init];
//    NSDictionary *ACParameterDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"InitialACParameter"];
//    _acParameter.isOn = [[ACParameterDic objectForKey:@"isON"] boolValue];
//    _acParameter.leftTemp = [[ACParameterDic objectForKey:@"leftTemp"] integerValue];
//    _acParameter.rightTemp = [[ACParameterDic objectForKey:@"rightTemp"] integerValue];
//    _acParameter.isMax = NO;
//    _acParameter.isFrontDeforst = [[ACParameterDic objectForKey:@"isFrontDeforst"] boolValue];
//    _acParameter.isBackDeforst = [[ACParameterDic objectForKey:@"isBackDeforst"] boolValue];
//    _acParameter.fanMode = (BlowMode)[[ACParameterDic objectForKey:@"fanMode"] integerValue];
//    _acParameter.fanSpeed = [[ACParameterDic objectForKey:@"fanSpeed"] integerValue];
//    _acParameter.isAC = [[ACParameterDic objectForKey:@"isAC"] boolValue];
//    _acParameter.cycleMode = (CycMode)[[ACParameterDic objectForKey:@"cycleMode"] integerValue];
//    _acParameter.isDual = [[ACParameterDic objectForKey:@"isDual"] boolValue];
//    [self writeACParameterFromFile];
//}

- (NSString *)createACParameterFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[self acParameterDocumentDirectory] stringByAppendingPathComponent:@"acParameter.txt"];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}

- (NSString *)acParameterDocumentDirectory
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return documentDirectory;
}

- (void)readACParameterFromFile
{
    NSMutableData *mData = [NSMutableData dataWithContentsOfFile:[self createACParameterFile]];
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:mData];
    _acParameter = [unArchiver decodeObjectForKey:@"ACParameter"];
}

- (void)writeACParameterFromFile
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_acParameter forKey:@"ACParameter"];
    [archiver finishEncoding];
    [data writeToFile:[self createACParameterFile] atomically:YES];
}

/**
 *  初始化空调界面
 */
- (void)initView
{
    // 左侧
    self.maxButton.enabled = NO;
    self.leftTempDownButton.enabled = NO;
    self.leftTempUpButton.enabled = NO;
    self.frontDefrostButton.enabled = NO;
    // 中间
    self.powButton.selected = NO;
    self.onButton.selected = NO;
    self.backDefrostButton.enabled = NO;
    self.fanSpeedDownButton.enabled = NO;
    self.fanModeButton.enabled = NO;
    self.cycleModeButton.enabled = NO;
    self.fanSpeedUpButton.enabled = NO;
    // 右侧
    [self.acButton setImage:[UIImage imageNamed:@"AirConditioning_AC_Normal"] forState:UIControlStateNormal];
    self.acButton.selected = NO;
    self.acButton.enabled = YES;
    self.rightTempDownButton.enabled = NO;
    self.rightTempUpButton.enabled = NO;
    self.dualButton.enabled = NO;
}

/**
 *  发送设置数据事件(只管发送)
 *
 *  @param builder builder
 */
- (void)updateWithACParameterSetReqBuilder:(ACParameterSetReqBuilder *)builder
{
    ACParameterSetReq *acParameter = [builder build];
    NSData *data = [acParameter data];
    char *reqData = (char *)[data bytes];
    uint length = (uint)[data length];
    if ([self sendData:ACSETPARAMETERID buff:reqData length:length]) {
        NSLog(@"发送成功");
    }
    else
    {
        NSLog(@"发送失败");
    }
}

/**
 *  发送设置数据事件
 *
 *  @param businessId 信道
 *  @param buff       发送的数据
 *  @param length     发送的数据长度
 *
 *  @return 成功与否
 */
- (BOOL)sendData:(unichar)businessId buff:(char *)buff length:(uint)length
{
    int reqCode = send_data(businessId, buff, length);
    if (reqCode != 0) {
        return NO;
    }
    return YES;
}

/**
 *  更新空调界面
 */
- (void)updateView
{
    NSLog(@"%@",_acParameter);
    NSLog(@"左侧温度：%ld",(long)_acParameter.leftTemp);
    NSLog(@"右侧温度：%ld",(long)_acParameter.rightTemp);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_acParameter.isOn) {
            // 左侧
            self.maxButton.enabled = YES;
            self.leftTempDownButton.enabled = YES;
            self.leftTempUpButton.enabled = YES;
            self.frontDefrostButton.enabled = YES;
            // 中间
            self.powButton.selected = YES;
            self.onButton.selected = YES;
            self.backDefrostButton.enabled = YES;
            self.fanSpeedDownButton.enabled = YES;
            self.fanModeButton.enabled = YES;
            self.cycleModeButton.enabled = YES;
            self.fanSpeedUpButton.enabled = YES;
            // 右侧
            self.acButton.enabled = YES;
            self.rightTempDownButton.enabled = YES;
            self.rightTempUpButton.enabled = YES;
            self.dualButton.enabled = YES;
        }
        else
        {
            [self initView];
        }
        // 左侧温度
        if (_acParameter.isOn) {
            switch (_acParameter.leftTemp) {
                case 1:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp7"];
                    break;
                case 2:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp6"];
                    break;
                case 3:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp5"];
                    break;
                case 4:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp4"];
                    break;
                case 5:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp3"];
                    break;
                case 6:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp2"];
                    break;
                case 7:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp1"];
                    break;
                case 8:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp1"];
                    break;
                case 9:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp2"];
                    break;
                case 10:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp3"];
                    break;
                case 11:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp4"];
                    break;
                case 12:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp5"];
                    break;
                case 13:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp6"];
                    break;
                case 14:
                    self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp7"];
                    break;
                default:
                    break;
            }
            // 右侧温度
            switch (_acParameter.rightTemp) {
                case 1:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp7"];
                    break;
                case 2:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp6"];
                    break;
                case 3:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp5"];
                    break;
                case 4:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp4"];
                    break;
                case 5:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp3"];
                    break;
                case 6:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp2"];
                    break;
                case 7:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_LeftTemp1"];
                    break;
                case 8:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp1"];
                    break;
                case 9:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp2"];
                    break;
                case 10:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp3"];
                    break;
                case 11:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp4"];
                    break;
                case 12:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp5"];
                    break;
                case 13:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp6"];
                    break;
                case 14:
                    self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_RightTemp7"];
                    break;
                default:
                    break;
            }
        }
//        else
//        {
//            self.leftTempIV.image = [UIImage imageNamed:@"AirConditioning_TempSlider_Disable"];
//            self.rightTempIV.image = [UIImage imageNamed:@"AirConditioning_TempSlider_Disable"];
//        }
        // MAX
        if (_acParameter.isMax) {
            self.maxButton.selected = YES;
        }
        else
        {
            self.maxButton.selected = NO;
        }
        // 前窗除霜
        if (_acParameter.isFrontDeforst) {
            self.frontDefrostButton.selected = YES;
        }
        else
        {
            self.frontDefrostButton.selected = NO;
        }
        // 后窗除霜
        if (_acParameter.isBackDeforst) {
            self.backDefrostButton.selected = YES;
        }
        else
        {
            self.backDefrostButton.selected = NO;
        }
        // 吹风模式
        switch (_acParameter.fanMode) {
            case 0:
                [self.fanModeButton setImage:[UIImage imageNamed:@"AirConditioning_FanMode_Face"] forState:UIControlStateNormal];
                break;
            case 1:
                [self.fanModeButton setImage:[UIImage imageNamed:@"AirConditioning_FanMode_Foot"] forState:UIControlStateNormal];
                break;
            case 2:
                [self.fanModeButton setImage:[UIImage imageNamed:@"AirConditioning_FanMode_FaceFoot"] forState:UIControlStateNormal];
                break;
            case 3:
                [self.fanModeButton setImage:[UIImage imageNamed:@"AirConditioning_FanMode_FootDefrost"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        // 风速
        if (_acParameter.isOn) {
            switch (_acParameter.fanSpeed) {
                case 1:
                {
                    self.fanSpeedIV.image = [UIImage imageNamed:@"AirConditioning_FanSpeed1"];
                }
                    break;
                case 2:
                {
                    self.fanSpeedIV.image = [UIImage imageNamed:@"AirConditioning_FanSpeed2"];
                }
                    break;
                case 3:
                {
                    self.fanSpeedIV.image = [UIImage imageNamed:@"AirConditioning_FanSpeed3"];
                }
                    break;
                case 4:
                {
                    self.fanSpeedIV.image = [UIImage imageNamed:@"AirConditioning_FanSpeed4"];
                }
                    break;
                case 5:
                {
                    self.fanSpeedIV.image = [UIImage imageNamed:@"AirConditioning_FanSpeed5"];
                }
                    break;
                case 6:
                {
                    self.fanSpeedIV.image = [UIImage imageNamed:@"AirConditioning_FanSpeed6"];
                }
                    break;
                case 7:
                {
                    self.fanSpeedIV.image = [UIImage imageNamed:@"AirConditioning_FanSpeed7"];
                }
                    break;
                default:
                    break;
            }
        }
        else
        {
            
        }
        // AC
        if (_acParameter.isAC) {
            self.acButton.selected = YES;
        }
        else
        {
            self.acButton.selected = NO;
        }
        // 循环模式
        switch (_acParameter.cycleMode) {
            case 0:
                self.cycleModeButton.selected = YES;
                break;
            case 1:
                self.cycleModeButton.selected = NO;
                break;
            default:
                break;
        }
        // DUAL
        if (_acParameter.isDual) {
            self.dualButton.selected = YES;
        }
        else
        {
            self.dualButton.selected = NO;
        }
    });
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (void)updateACParameter
//{
//    // 获取结果
//    UINT16 resBusinessId;
//    char buff[256] = "";
//    int length = get_data(&resBusinessId, buff, 256);
//    if (length > 0) {
//        switch (resBusinessId) {
//            case ACPARAMETERNOTIFY:
//            {
//                NSData *data = [NSData dataWithBytes:buff length:length];
//                ACParameterNotify *acParameter = [ACParameterNotify parseFromData:data];
//                // 初始数据持久化
//                if (acParameter) {
//                    [[NSUserDefaults standardUserDefaults] setObject:@{@"isON": acParameter.onOff? @1: @0, @"leftTemp": [NSNumber numberWithInt:acParameter.temperature0], @"rightTemp": [NSNumber numberWithInt:acParameter.temperature1], @"isMax": acParameter.autoOpen? @1: @0, @"isFrontDeforst": acParameter.frontDefrost? @1: @0, @"isBackDeforst": acParameter.backDefrost? @1: @0, @"fanMode": [NSNumber numberWithInt:acParameter.blowMode], @"fanSpeed": [NSNumber numberWithInt:acParameter.windSpeed], @"isAC": acParameter.acOpen? @1: @0, @"cycleMode": [NSNumber numberWithInt:acParameter.cycMode], @"isDual": acParameter.dualOpen? @1: @0} forKey:@"InitialACParameter"];
//                }
//                NSDictionary *ACParameterDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"InitialACParameter"];
//                _acParameter.isOn = [[ACParameterDic objectForKey:@"isON"] boolValue];
//                _acParameter.leftTemp = [[ACParameterDic objectForKey:@"leftTemp"] integerValue];
//                _acParameter.rightTemp = [[ACParameterDic objectForKey:@"rightTemp"] integerValue];
//                _acParameter.isMax = [[ACParameterDic objectForKey:@"isMax"] boolValue];
//                _acParameter.isFrontDeforst = [[ACParameterDic objectForKey:@"isFrontDeforst"] boolValue];
//                _acParameter.isBackDeforst = [[ACParameterDic objectForKey:@"isBackDeforst"] boolValue];
//                _acParameter.fanMode = (BlowMode)[[ACParameterDic objectForKey:@"fanMode"] integerValue];
//                _acParameter.fanSpeed = [[ACParameterDic objectForKey:@"fanSpeed"] integerValue];
//                _acParameter.isAC = [[ACParameterDic objectForKey:@"isAC"] boolValue];
//                _acParameter.cycleMode = (CycMode)[[ACParameterDic objectForKey:@"cycleMode"] integerValue];
//                _acParameter.isDual = [[ACParameterDic objectForKey:@"isDual"] boolValue];
//            }
//                break;
//            case ACGETPARAMETRSQID:
//                [_simpleBoxAC getACParameterRsqData:resBusinessId ACParameterBuff:buff length:ret];
//                break;
//            case ACSETPARAMETRSQID:
//                // sunlf: protobuf
//                [_simpleBoxAC getACParameterSetRsqData:resBusinessId ACParameterBuff:buff length:ret];
//                break;
//            case REVERSESTATUSID:
//                [self getReverStatusNotifyData:resBusinessId reverStatusBuff:buff length:ret];
//                break;
//            case SERVERCLOSED:
//            {
//                disconnect_box(SERVERCLOSED);
//                self.isConnected = NO;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSLog(@"通信异常");
//                    if (_timer == nil) {
//                        self.timer = [NSTimer scheduledTimerWithTimeInterval:30
//                                                                      target:self
//                                                                    selector:@selector(connectBox)
//                                                                    userInfo:nil
//                                                                     repeats:YES];
//                    }
//                    [_timer fire];
//                });
//
//            }
//                break;
//            default:
//                break;
//        }
//    }
//}

//- (IBAction)windSpeedReduce:(id)sender {
//    _acParameter.isOFF = NO;
//    _acParameter.isAuto = NO;
//    [self.titleAutoBtn setImage:[UIImage imageNamed:@"AUTO关.png"] forState:UIControlStateNormal];
//    [self.speedWindDown setImage:[UIImage imageNamed:@"风量减开.png"] forState:UIControlStateHighlighted];
//    _acParameter.windSpeedImageIndex--;
//    if (_acParameter.windSpeedImageIndex < 0) {
//        _acParameter.windSpeedImageIndex = 0;
//        return;
//    }
//
//    if (_acParameter.windSpeedImageIndex == 0) {
//        [self resetACParameter];
//    }
//
//    [self.windSpeedImage setImage:[UIImage imageNamed:[_windSpeedImages objectAtIndex:_acParameter.windSpeedImageIndex]]];
//
//    if (![_handler sendACParameterSetReq:_acParameter]) {
//        [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
//    }
//}

//- (IBAction)windSpeedAdd:(id)sender {
//    _acParameter.isOFF = NO;
//    _acParameter.isAuto = NO;
//    [self.titleAutoBtn setImage:[UIImage imageNamed:@"AUTO关.png"] forState:UIControlStateNormal];
//    [self.speedWindUp setImage:[UIImage imageNamed:@"风量增开.png"] forState:UIControlStateHighlighted];
//
//    _acParameter.windSpeedImageIndex++;
//    if (_acParameter.windSpeedImageIndex > 5) {
//        _acParameter.windSpeedImageIndex = 5;
//        return;
//    }
//    [self.windSpeedImage setImage:[UIImage imageNamed:[_windSpeedImages objectAtIndex:_acParameter.windSpeedImageIndex]]];
//    [self activeACParameter];
//    if (![_handler sendACParameterSetReq:_acParameter]) {
//        [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
//    }
//}

//- (IBAction)changeCycMode:(id)sender {
//    _acParameter.isAuto = NO;
//    [self.titleAutoBtn setImage:[UIImage imageNamed:@"AUTO关.png"] forState:UIControlStateNormal];
//    _acParameter.isInnerCycMode = _acParameter.isInnerCycMode?NO:YES;
//    [self.cycMode setImage:[UIImage imageNamed:_acParameter.isInnerCycMode?@"内循环开.png":@"外循环开.png"] forState:UIControlStateNormal];
//    if (![_handler sendACParameterSetReq:_acParameter]) {
//        [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
//    }
//}

//- (CABasicAnimation *)buttonAnimation
//{
//    CABasicAnimation *theAnimation;
//    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    theAnimation.duration=0.1;
//    theAnimation.removedOnCompletion = YES;
//    theAnimation.fromValue = [NSNumber numberWithFloat:1];
//    theAnimation.toValue = [NSNumber numberWithFloat:0.7];
//    return theAnimation;
//}

//- (IBAction)autoClickBtn {
//    [self acAutoMode];
//    if (![_handler sendACParameterSetReq:_acParameter]) {
//        [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
//    }
//}

//- (IBAction)offClickBtn {
//    [self resetACParameter];
//    if (![_handler sendACParameterSetReq:_acParameter]) {
//        [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
//    }
//}

//- (IBAction)changeLeftACBlowMode:(id)sender{
//    _acParameter.isAuto = NO;
//    [self.titleAutoBtn setImage:[UIImage imageNamed:_acParameter.isAuto?@"AUTO开.png":@"AUTO关.png"] forState:UIControlStateNormal];
//    [_leftACMenu tapToSwitchOpenOrClose];
//}

//- (IBAction)changeRightACBlowMode:(id)sender{
//    _acParameter.isAuto = NO;
//    [self.titleAutoBtn setImage:[UIImage imageNamed:_acParameter.isAuto?@"AUTO开.png":@"AUTO关.png"] forState:UIControlStateNormal];
//    [_rightACMenu tapToSwitchOpenOrClose];
//}

//- (SimpleBoxMenu *)createACMenu:(CGPoint)origin cycModeTag:(int) flag
//{
//    SimpleBoxMenu *menu = [[SimpleBoxMenu alloc] initWithOrigin:origin
//                                                    andDiameter:72
//                                                    andDelegate:self
//                                                     themeColor:[UIColor grayColor]
//                                                      menuColor:[UIColor clearColor]];
//    menu.menuDelegate = self;
//    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
//        menu.radius = 20;
//        menu.extraDistance = 35;
//
//    }
//    else
//    {
//        menu.radius = 30;
//        menu.extraDistance = 55;
//    }
//    menu.MenuCount = 3;
//    menu.flag = flag;
//    menu.pictures = _inActivePictures;
//    return menu;
//}


//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    if (_leftACMenu.isOpened && _rightACMenu.isOpened) {
//        [_leftACMenu tapToSwitchOpenOrClose];
//        [_rightACMenu tapToSwitchOpenOrClose];
//    }else if(_leftACMenu.isOpened){
//        [_leftACMenu tapToSwitchOpenOrClose];
//    }else if(_rightACMenu.isOpened){
//        [_rightACMenu tapToSwitchOpenOrClose];
//    }
//}

//- (IBAction)refrigerationMode:(id)sender {
//    _acParameter.isAuto = NO;
//    _acParameter.isRefrigerationMode = _acParameter.isRefrigerationMode?NO:YES;
//    [self.titleAutoBtn setImage:[UIImage imageNamed:_acParameter.isAuto?@"AUTO开.png":@"AUTO关.png"] forState:UIControlStateNormal];
//    [_refrigerationMode  setImage:[UIImage imageNamed:_acParameter.isRefrigerationMode?@"制冷开.png":@"制冷关.png"] forState:UIControlStateNormal];
//    self.refrigerationImageLeft.hidden = _acParameter.isRefrigerationMode?NO:YES;
//    self.refrigerationImageRight.hidden = _acParameter.isRefrigerationMode?NO:YES;
//    if (![_handler sendACParameterSetReq:_acParameter]) {
//        [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
//    }
//}

//- (void)acAutoMode
//{
//    _acParameter.isOFF = NO;
//    _acParameter.isAuto = YES;
//    _acParameter.windSpeedImageIndex = 3;
//    _acParameter.isInnerCycMode = NO;
//    _acParameter.leftBlowModeActiveIndex = 1;
//    _acParameter.rightBlowModeActiveIndex = 1;
//    _acParameter.leftACTemperature = 24.0;
//    _acParameter.rightACTemperature = 24.0;
//
//    [self.titleAutoBtn setImage:[UIImage imageNamed:_acParameter.isAuto?@"AUTO开.png":@"AUTO关.png"] forState:UIControlStateNormal];
//    [self.cycMode setImage:[UIImage imageNamed:_acParameter.isInnerCycMode?@"内循环开.png":@"外循环开.png"] forState:UIControlStateNormal];
//    [self.windSpeedImage setImage:[UIImage imageNamed:[_windSpeedImages objectAtIndex:_acParameter.windSpeedImageIndex]]];
//
//    [self.leftACBlowMode setImage:[UIImage imageNamed:[_activePictures objectAtIndex:_acParameter.leftBlowModeActiveIndex]] forState:UIControlStateNormal];
//
//    [self.rightACBlowMode setImage:[UIImage imageNamed:[_activePictures objectAtIndex:_acParameter.rightBlowModeActiveIndex]] forState:UIControlStateNormal];
//    [self.leftRotate setTheTem:_acParameter.leftACTemperature];
//    [self.rightRotate setTheTem:_acParameter.rightACTemperature];
//
//    self.refrigerationImageLeft.hidden = _acParameter.isRefrigerationMode?NO:YES;
//    self.refrigerationImageRight.hidden = _acParameter.isRefrigerationMode?NO:YES;
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionFade;
//    animation.duration = 0.5;
//
//    [self.leftACTemperatureImageView.layer addAnimation:animation forKey:nil];
//    self.leftACTemperatureImageView.hidden = NO;
//    [self.rightACTemperatureImageView.layer addAnimation:animation forKey:nil];
//    self.rightACTemperatureImageView.hidden = NO;
//
//    self.leftActualTemperature.text = _acParameter.leftActualTemperature;
//    [self.leftActualTemperature.layer addAnimation:animation forKey:nil];
//    self.leftActualTemperature.hidden = NO;
//    self.rightActualTemperature.text = _acParameter.rightActualTemperature;
//    [self.rightActualTemperature.layer addAnimation:animation forKey:nil];
//    self.rightActualTemperature.hidden = NO;
//
//    self.refrigerationMode.enabled = YES;
//    self.leftACBlowMode.enabled = YES;
//    self.rightACBlowMode.enabled = YES;
//    self.cycMode.enabled = YES;
//
//}

//- (void)resetACParameter
//{
//    _acParameter.isOFF = YES;
//    _acParameter.isAuto = NO;
//
//    [self.titleAutoBtn setImage:[UIImage imageNamed:_acParameter.isAuto?@"AUTO开.png":@"AUTO关.png"] forState:UIControlStateNormal];
//    [self.titleOffBtn setImage:[UIImage imageNamed:@"OFF关.png"] forState:UIControlStateNormal];
//    [self.titleOffBtn setImage:[UIImage imageNamed:@"OFF开.png"] forState:UIControlStateHighlighted];
//    [self.cycMode setImage:[UIImage imageNamed:_acParameter.isInnerCycMode?@"内循环关.png":@"外循环关.png"] forState:UIControlStateNormal];
//    [self.refrigerationMode setImage:[UIImage imageNamed:@"制冷关.png"] forState:UIControlStateNormal];
//    self.refrigerationImageLeft.hidden = YES;
//    self.refrigerationImageRight.hidden = YES;
//
//    [self.leftACBlowMode setImage:[UIImage imageNamed:[_inActivePictures objectAtIndex:_acParameter.leftBlowModeActiveIndex]] forState:UIControlStateNormal];
//    [self.rightACBlowMode setImage:[UIImage imageNamed:[_inActivePictures objectAtIndex:_acParameter.rightBlowModeActiveIndex]] forState:UIControlStateNormal];
//
//    self.leftACTemperatureImageView.hidden = YES;
//    self.rightACTemperatureImageView.hidden = YES;
//
//    [self.leftRotate setTheTem:_acParameter.leftACTemperature];
//    [self.rightRotate setTheTem:_acParameter.rightACTemperature];
//
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionFade;
//    animation.duration = 0.5;
//
//    [self.rightActualTemperature.layer addAnimation:animation forKey:nil];
//    [self.leftActualTemperature.layer addAnimation:animation forKey:nil];
//    self.leftActualTemperature.hidden = YES;
//    self.rightActualTemperature.hidden = YES;
//
//    _acParameter.windSpeedImageIndex = 0;
//    [self.windSpeedImage setImage:[UIImage imageNamed:[_windSpeedImages objectAtIndex:_acParameter.windSpeedImageIndex]]];
//
//    if (_leftACMenu.isOpened && _rightACMenu.isOpened) {
//        [_leftACMenu tapToSwitchOpenOrClose];
//        [_rightACMenu tapToSwitchOpenOrClose];
//    }else if(_leftACMenu.isOpened){
//        [_leftACMenu tapToSwitchOpenOrClose];
//    }else if(_rightACMenu.isOpened){
//        [_rightACMenu tapToSwitchOpenOrClose];
//    }
//
//    self.refrigerationMode.enabled = NO;
//    self.leftACBlowMode.enabled = NO;
//    self.rightACBlowMode.enabled = NO;
//    self.cycMode.enabled = NO;
//}

//- (void)activeACParameter
//{
//    _acParameter.isAuto = NO;
//    [self.cycMode setImage:[UIImage imageNamed:_acParameter.isInnerCycMode?@"内循环开.png":@"外循环开.png"] forState:UIControlStateNormal];
//
//    [self.leftACBlowMode setImage:[UIImage imageNamed:[_activePictures objectAtIndex:_acParameter.leftBlowModeActiveIndex]] forState:UIControlStateNormal];
//    [self.rightACBlowMode setImage:[UIImage imageNamed:[_activePictures objectAtIndex:_acParameter.rightBlowModeActiveIndex]] forState:UIControlStateNormal];
//
//    [self.windSpeedImage setImage:[UIImage imageNamed:[_windSpeedImages objectAtIndex:_acParameter.windSpeedImageIndex]]];
//
//    [self.leftRotate setTheTem:_acParameter.leftACTemperature];
//    [self.rightRotate setTheTem:_acParameter.rightACTemperature];
//
//    [self.refrigerationMode setImage:[UIImage imageNamed:_acParameter.isRefrigerationMode?@"制冷开.png":@"制冷关.png"] forState:UIControlStateNormal];
//    self.refrigerationImageLeft.hidden = _acParameter.isRefrigerationMode?NO:YES;
//    self.refrigerationImageRight.hidden = _acParameter.isRefrigerationMode?NO:YES;
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionFade;
//    animation.duration = 0.5;
//
//    [self.leftACTemperatureImageView.layer addAnimation:animation forKey:nil];
//    self.leftACTemperatureImageView.hidden = NO;
//    [self.rightACTemperatureImageView.layer addAnimation:animation forKey:nil];
//    self.rightACTemperatureImageView.hidden = NO;
//
//    if (self.leftActualTemperature.hidden) {
//        self.leftActualTemperature.hidden = NO;
//    }
//    self.leftActualTemperature.text = _acParameter.leftActualTemperature;
//    [self.leftActualTemperature.layer addAnimation:animation forKey:nil];
//
//    if (self.rightActualTemperature.hidden) {
//        self.rightActualTemperature.hidden = NO;
//    }
//    self.rightActualTemperature.text = _acParameter.rightActualTemperature;
//    [self.rightActualTemperature.layer addAnimation:animation forKey:nil];
//    self.refrigerationMode.enabled = YES;
//    self.leftACBlowMode.enabled = YES;
//    self.rightACBlowMode.enabled = YES;
//    self.cycMode.enabled = YES;
//}

//- (RotateImage *)createRotateView:(CGRect)frame andWith:(float)width andTag:(long)tag
//{
//    RotateImage *rotate = [RotateImage alloc];
//    rotate.imageWidth = width;
//    rotate = [rotate initWithFrame:frame];
//    rotate.delegate = self;
//    rotate.tag = tag;
//    return rotate;
//}

//#pragma mark - SimpleBoxAirConditionerDelegate
//
//- (void)updateSimpleBoxACParameter:(SimpleBoxAirConditioner *)AirConditioner
//{
//    _conditioner = AirConditioner;
//}

//#pragma  mark  -- menuDidSelectedDelegate
//- (void)menuDidSelected:(NSInteger)index
//{
//    switch (index/10) {
//        case ACLEFTBLOWMODE:
//        {
//            _acParameter.leftBlowModeActiveIndex = index-_leftACMenu.flag-1;
//            [self.leftACBlowMode setImage:[UIImage imageNamed:[self.activePictures objectAtIndex:_acParameter.leftBlowModeActiveIndex]] forState:UIControlStateNormal];
//            if (![_handler sendACParameterSetReq:_acParameter]) {
//                [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
//            }
//        }
//        break;
//        case ACRIGHTBLOWMODE:
//        {
//            _acParameter.rightBlowModeActiveIndex = index-_rightACMenu.flag-1;
//            [self.rightACBlowMode setImage:[UIImage imageNamed:[self.activePictures objectAtIndex:_acParameter.rightBlowModeActiveIndex]] forState:UIControlStateNormal];
//            if (![_handler sendACParameterSetReq:_acParameter]) {
//                [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
//            }
//        }
//        break;
//        default:
//            break;
//    }
//}

//#pragma mark -- rotateImageDelegate
//- (void)receiveACTemperature:(float)temperature withTag:(long)tag
//{
//    if (tag == 1) {
//        _acParameter.leftACTemperature = temperature;
//    }else{
//        _acParameter.rightACTemperature = temperature;
//    }
//
//    if (!_acParameter.isOFF) {
//        if (![_handler sendACParameterSetReq:_acParameter]) {
//            [self showAlertView:@"发送数据" message:@"发送数据失败，请检查与盒子的连接是否正常"];
//        }
//    }
//}

//#pragma mark -- notification
//- (void)getACParameterSetRsq:(NSNotification*)notification
//{
//    HacvSetRsp *acParameter = [notification object];
//    if (acParameter.rspCode == RspCodeFailed) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self showAlertView:@"数据响应失败" message:@"数据响应失败，请检查与盒子的连接是否正常"];
//        });
//        }
//    if ([acParameter hasOnOff]) {
//        BOOL onOff = acParameter.onOff;
//        self.acParameter.isOFF = onOff?NO:YES;
//    }
//    if ([acParameter hasAcopen]) {
//        BOOL ACOpen = acParameter.acopen;
//        self.acParameter.isRefrigerationMode = ACOpen?YES:NO;
//    }
//    if ([acParameter hasCycMode]) {
//        CycMode cycMode = acParameter.cycMode;
//        self.acParameter.isInnerCycMode = cycMode == CycModeCycModeInside ? YES:NO;
//    }
//    if ([acParameter hasBlowMode0]) {
//        BlowMode blowModeL = acParameter.blowMode0;
//        self.acParameter.leftBlowModeActiveIndex = blowModeL;
//    }
//    if ([acParameter hasBlowMode1]) {
//        BlowMode blowModeR = acParameter.blowMode1;
//        self.acParameter.rightBlowModeActiveIndex = blowModeR;
//    }
//    if ([acParameter hasTemperature0]) {
//        NSInteger actureTemperatureL = acParameter.temperature0;
//        float leftActualTemperature = actureTemperatureL/10.0;
//        self.acParameter.leftActualTemperature = [NSString stringWithFormat:@"%.1f℃",leftActualTemperature];
//    }
//    if ([acParameter hasTemperature1]) {
//        NSInteger actureTemperatureR = acParameter.temperature1;
//        float rightActualTemperature = actureTemperatureR/10.0;
//        self.acParameter.rightActualTemperature = [NSString stringWithFormat:@"%.1f℃",rightActualTemperature];
//    }
//    if ([acParameter hasDesTemperature0]) {
//        NSInteger temperatureL = acParameter.desTemperature0;
//        self.acParameter.leftACTemperature = temperatureL/10.0;
//    }
//    if ([acParameter hasDesTemperature1]) {
//        NSInteger temperatureR = acParameter.desTemperature1;
//        self.acParameter.rightACTemperature = temperatureR/10.0;
//    }
//    if ([acParameter hasWindSpeed]) {
//        NSInteger windSpeed = acParameter.windSpeed;
//        self.acParameter.windSpeedImageIndex = windSpeed;
//    }
//    [self updateView];
//}
//
//- (void)getACParameterGetRsq:(NSNotification *)notification
//{
//
//    ACParameterRsp *acParameter = [notification object];
//    if (acParameter.rspCode == RspCodeFailed) {
//        [self showAlertView:@"数据响应失败" message:@"数据响应失败，请检查与盒子的连接是否正常"];
//        return;
//    }
//    if (acParameter.rspCode == RspCodeSuccess) {
//
//        if ([acParameter hasAcOpen]) {
//            BOOL ACOpen = [acParameter acOpen];
//            self.acParameter.isRefrigerationMode = ACOpen?YES:NO;
//        }
//
//        if ([acParameter hasOnOff]) {
//            BOOL onOff = acParameter.onOff;
//            self.acParameter.isOFF = onOff?NO:YES;
//        }
//
//        if ([acParameter hasCycMode]) {
//            CycMode cycMode = acParameter.cycMode;
//            self.acParameter.isInnerCycMode = cycMode == CycModeCycModeInside ? YES:NO;
//        }
//
//        if ([acParameter hasBlowMode0]) {
//            BlowMode blowModeL = acParameter.blowMode0;
//            self.acParameter.leftBlowModeActiveIndex = blowModeL;
//        }
//
//        if ([acParameter hasBlowMode1]) {
//            BlowMode blowModeR = acParameter.blowMode1;
//            self.acParameter.rightBlowModeActiveIndex = blowModeR;
//        }
//
//        if ([acParameter hasWindSpeed]) {
//            NSInteger windSpeed = acParameter.windSpeed;
//            self.acParameter.windSpeedImageIndex = windSpeed;
//        }
//
//        if ([acParameter hasTemperature0]) {
//            NSInteger actureTemperatureL = acParameter.temperature0;
//            float leftActualTemperature = actureTemperatureL/10.0;
//            self.acParameter.leftActualTemperature = [NSString stringWithFormat:@"%.1f℃",leftActualTemperature];
//            NSLog(@"leftActualTemperature = %@",self.acParameter.leftActualTemperature);
//        }
//
//        if ([acParameter hasTemperature1]) {
//            NSInteger actureTemperatureR = acParameter.temperature1;
//            float rightActualTemperature = actureTemperatureR/10.0;
//            self.acParameter.rightActualTemperature = [NSString stringWithFormat:@"%.1f℃",rightActualTemperature];
//            NSLog(@"rightActualTemperature = %@",self.acParameter.rightActualTemperature);
//        }
//         [self updateView];
//    }
//
//}

//- (void)getACParameterNotify:(NSNotification *)notification
//{
//    ACParameterNotify *acParameter = [notification object];
//    if ([acParameter hasAcOpen]) {
//        BOOL ACOpen = [acParameter acOpen];
//        self.acParameter.isRefrigerationMode = ACOpen?YES:NO;
//    }
//    if ([acParameter hasOnOff]) {
//        BOOL onOff = acParameter.onOff;
//        self.acParameter.isOFF = onOff?NO:YES;
//    }
//    if ([acParameter hasCycMode]) {
//        CycMode cycMode = acParameter.cycMode;
//        self.acParameter.isInnerCycMode = cycMode == CycModeCycModeInside ? YES:NO;
//    }
//    if ([acParameter hasBlowMode0]) {
//        BlowMode blowModeL = acParameter.blowMode0;
//        self.acParameter.leftBlowModeActiveIndex = blowModeL;
//    }
//    if ([acParameter hasBlowMode1]) {
//        BlowMode blowModeR = acParameter.blowMode1;
//        self.acParameter.rightBlowModeActiveIndex = blowModeR;
//    }
//    if ([acParameter hasWindSpeed]) {
//       NSInteger windSpeed = acParameter.windSpeed;
//       self.acParameter.windSpeedImageIndex = windSpeed;
//    }
//    if ([acParameter hasTemperature0]) {
//        NSInteger actureTemperatureL = acParameter.temperature0;
//        NSLog(@"temperatureL = %d",actureTemperatureL);
//        float leftActualTemperature = actureTemperatureL/10.0;
//        self.acParameter.leftActualTemperature = [NSString stringWithFormat:@"%.1f℃",leftActualTemperature];
//    }
//    if ([acParameter hasTemperature1]){
//        NSInteger actureTemperatureR = acParameter.temperature1;
//        NSLog(@"temperatureR = %d",actureTemperatureR);
//        float rightActualTemperature = actureTemperatureR/10.0;
//        self.acParameter.rightActualTemperature = [NSString stringWithFormat:@"%.1f℃",rightActualTemperature];
//    }
//    [self updateView];
//}

//- (void)updateView
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (_acParameter.windSpeedImageIndex == 0 || _acParameter.isOFF) {
//            [self resetACParameter];
//        }else{
//            [self activeACParameter];
//        }
//    });
//}

@end
