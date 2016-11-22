//
//  SimpleBoxAirConditioner.m
//  SimpleBox
//
//  Created by fnst001 on 11/30/15.
//  Copyright (c) 2015 FUJISTU. All rights reserved.
//

#import "SimpleBoxAirConditioner.h"
#import <SimpleBoxServer/server.h>


#define ACGETPARAMETERID        0X0803
#define ACSETPARAMETERID        0X0802

#define ACGETPARAMETRSQID       0x4803
#define ACSETPARAMETRSQID       0x4802

@interface SimpleBoxAirConditioner ()

@end

@implementation SimpleBoxAirConditioner

//- (BOOL)sendACParameterGetReq
//{
    // sunlf: for protobuf
//    ACParameterGetReqBuilder *builder = [[ACParameterGetReqBuilder alloc] init];
//    [builder setGetAcopen:YES];
//    [builder setOnOff:YES];
//    [builder setGetCycMode:YES];
//    [builder setGetBlowMode0:YES];
//    [builder setGetBlowMode1:YES];
//    [builder setGetTemperature0:YES];
//    [builder setGetTemperature1:YES];
//    [builder setGetWindSpeed:YES];
//    ACParameterGetReq *acParameter = [builder build];
//    NSData *data = [acParameter data];
//    char *reqData = (char *)[data bytes];
//  /Users/li/Desktop/交接项目/SimpleBox/SimpleBox车载/SimpleBoxIpad/SimpleBox/SimpleBox.xcodeproj  uint length = (uint)[data length];
//    printf("Send AC Get\n");
//    return [self sendData:ACGETPARAMETERID buff:reqData length:length];
//    return YES;
//}

//- (BOOL)sendACParameterSetReq:(ACParameter *)parameter
//{
//    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
    // 空调开关
//    [builder setOnOff:parameter.isOn];
    // 左侧温度
//    for (int i = 0; i < parameter.leftTemp; i++) {
//        [builder setTempOption0:<#(TempOption)#>];
//    }
    // 右侧温度
//    for (int i = 0; i < parameter.rightTemp; i++) {
//        [builder setTempOption1:<#(TempOption)#>];
//    }
    // 最大
//    if (parameter.isMax) {
//        [builder set];
//    }
//    else
//    {
//        
//    }
//    // 前窗除霜
//    [builder setFrontDefrostSwitch:parameter.isFrontDeforst];
//    // 后窗除霜
//    [builder setBackDefrostSwitch:parameter.isBackDeforst];
//    // 吹风模式
//    [builder setBlowModeSwitch:YES];
//    // 风速
//    if (parameter.fanSpeed) {
//        for (int i = 0; i < parameter.fanSpeed; i++) {
//            [builder setWindOption:WindOptionSpeedUp];
//        }
//    }
//    // AC开关
//    [builder setAcopen:parameter.isAC];
//    // 循环模式
//    [builder setCycModeSwitch:YES];
//    // 联动
//    [builder setDualOpen:parameter.isDual];

//    BOOL ACOpen = parameter.isRefrigerationMode?YES:NO;
//    BOOL onOff = parameter.isOFF?NO:YES;
//    CycMode cycMode = parameter.isInnerCycMode?CycModeCycModeInside:CycModeCycModeOuter;
//    BlowMode blowModeL = (SInt32)parameter.leftBlowModeActiveIndex;
//    BlowMode blowModeR = (SInt32)parameter.rightBlowModeActiveIndex;
//    NSInteger windSpeed = parameter.windSpeedImageIndex;
//    NSInteger temperatureL = (parameter.leftACTemperature*1000000)/100000;
//    NSInteger temperatureR = (parameter.rightACTemperature*1000000)/100000;
//    NSLog(@"temperatureL = %d",temperatureL);
//    NSLog(@"temperatureR = %d",temperatureR);
//    ACParameterSetReqBuilder *builder = [[ACParameterSetReqBuilder alloc] init];
//    [builder setAcopen:ACOpen];
//    [builder setOnoff:onOff];
//    [builder setBlowMode0:blowModeL];
//    [builder setBlowMode1:blowModeR];
//    [builder setCycMode:cycMode];
//    [builder setTemperature0:(UInt32)temperatureL];
//    [builder setTemperature1:(UInt32)temperatureR];
//    [builder setWindSpeed:(UInt32)windSpeed];
//    ACParameterSetReq *acParameter = [builder build];
//    NSData *data = [acParameter data];
//    char *reqData = (char *)[data bytes];
//    uint length = (uint)[data length];
//    return [self sendData:ACSETPARAMETERID buff:reqData length:length];
//}

- (BOOL)sendData:(unichar)businessId buff:(char *)buff length:(uint)length
{
    int reqCode = send_data(businessId, buff, length);
    if (reqCode != 0) {
        return NO;
    }
    return true;
}

// sunlf: protobuf
-(void)getACParameterSetRsqData:(unichar) resBusinessId ACParameterBuff:(char *)buff length:(int)length
{
    if (length <= 0) {
        NSLog(@"Get Conditioner data wrong\n");
        return;
    }
    NSData *data = [NSData dataWithBytes:buff length:length];
//    HacvSetRsp *acParameter = [HacvSetRsp parseFromData:data];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ACParameterSetRsqNotification"
//                                                            object:acParameter
//                                                          userInfo:nil];
}

- (void)getACParameterRsqData:(unichar)resBusinessId ACParameterBuff:(char*)buff length:(int)length
{
    if (length <= 0) {
        NSLog(@"Get Conditioner data wrong\n");
        return;
    }
    NSData *data = [NSData dataWithBytes:buff length:length];
//    ACParameterRsp *acParameter = [ACParameterRsp parseFromData:data];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ACParameterGetReqNotification"
//                                                        object:acParameter userInfo:nil];
}

- (void)getACParameterNotifyData:(unichar)resBusinessId ACParameterBuff:(char *)buff length:(int)length
{
    if (length <= 0) {
        NSLog(@"Get Conditioner data wrong\n");
        return;
    }
    NSData *data = [NSData dataWithBytes:buff length:length];
    ACParameterNotify *acParameter = [ACParameterNotify parseFromData:data];
    // 初始数据持久化
    if (acParameter) {
        [[NSUserDefaults standardUserDefaults] setObject:@{@"isON": acParameter.onOff? @1: @0, @"leftTemp": [NSNumber numberWithInt:acParameter.temperature0], @"rightTemp": [NSNumber numberWithInt:acParameter.temperature1], @"isMax": acParameter.autoOpen? @1: @0, @"isFrontDeforst": acParameter.frontDefrost? @1: @0, @"isBackDeforst": acParameter.backDefrost? @1: @0, @"fanMode": [NSNumber numberWithInt:acParameter.blowMode], @"fanSpeed": [NSNumber numberWithInt:acParameter.windSpeed], @"isAC": acParameter.acOpen? @1: @0, @"cycleMode": [NSNumber numberWithInt:acParameter.cycMode], @"isDual": acParameter.dualOpen? @1: @0} forKey:@"InitialACParameter"];
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ACParameterNotifyNotification"
//                                                        object:acParameter];
}

@end
