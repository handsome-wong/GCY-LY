//
//  SimpleBoxHandler.m
//  SimpleBox
//
//  Created by fnst001 on 11/30/15.
//  Copyright (c) 2015 FUJISTU. All rights reserved.
//

#import "SimpleBoxHandler.h"
#import <SimpleBoxServer/server.h>
#import <UIKit/UIKit.h>
#import <ifaddrs.h>
#import <net/if.h>

// Business ID
#define ACGETPARAMETERID        0X0803
#define ACSETPARAMETERID        0X0802
#define ACGETPARAMETRSQID       0x4803
#define ACSETPARAMETRSQID       0x4802
#define ACPARAMETERNOTIFY       0x8804
#define REVERSESTATUSID         0x8906
#define REVERSESTATUSRSPID      0x4906
#define SERVERCLOSED            0xFFFF

@interface SimpleBoxHandler ()

@property (nonatomic, strong) SimpleBoxAirConditioner *simpleBoxAC;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SimpleBoxHandler

+ (instancetype)sharedInstance
{
    static SimpleBoxHandler *handler;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        handler = [[SimpleBoxHandler alloc] init];
        handler.simpleBoxAC = [[SimpleBoxAirConditioner alloc] init];
        handler.isConnected = NO;
    });
    return handler;
}

/**
 *  设置参数，发请求连接box
 *
 *  @param ip   socket地址
 *  @param port 端口
 */
- (void)connectBox:(NSString *)ip withPort:(int)port
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const char * address = [ip UTF8String];
        NSString *deviceSn = @"1";
        NSString *softwareVer = @"1";
        char *rsp = (char *)malloc(128);
        
        ConnectReq *connectReq = [[[[ConnectReq builder] setDeviceSn:deviceSn]
                                   setSoftwareVersion:softwareVer]
                                  build];
        NSData *data = [connectReq data];
        char *connectData = (char *)[data bytes];
        uint length = (uint)[data length];
        int ret = connect_box(connectData, length, address, port, rsp);
        if (ret <= 0) {
            NSLog(@"Recv connect data wrong.\n");
            _isConnected = NO;
            if ([_delegate respondsToSelector:@selector(connectBoxResult:)]) {
                [_delegate connectBoxResult:_isConnected];
            }
            return;
        }
        
        NSData *rspData = [NSData dataWithBytes:rsp length:ret];
        ConnectRsp *connectRsp = [ConnectRsp parseFromData:rspData];
        BOOL isConnectBox = (connectRsp.result == RspCodeSuccess)?true:false;
        self.isConnected = isConnectBox;
        if (isConnectBox) {
            start_pthread();
            [self getData];
        }
        if ([_delegate respondsToSelector:@selector(connectBoxResult:)]) {
            [_delegate connectBoxResult:isConnectBox];
        }
        
    });
}

- (BOOL)sendACParameterGetReq
{
    return [_simpleBoxAC sendACParameterGetReq];
}

- (BOOL)sendACParameterSetReq:(ACParameter *)acParameter
{
    return [_simpleBoxAC sendACParameterSetReq:acParameter];
}

- (void)getData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UINT16 resBusinessId;
        char buff[256] = "";
        while (self.isConnected) {
            memset(buff, 0, strlen(buff));
            // 先发送报文
            int res = send_data(ACGETPARAMETERID, NULL, 0);
            // 成功就获取结果
            int ret = 0;
            if (0 == res) {
                sleep(5);
                ret = get_data(&resBusinessId, buff, 256); // sunlf: fix bug
            }
            if (ret > 0) {
                switch (resBusinessId) {
                    case ACGETPARAMETRSQID:
                        [_simpleBoxAC getACParameterRsqData:resBusinessId ACParameterBuff:buff length:ret];
                        break;
                    case ACSETPARAMETRSQID:
                        // sunlf: protobuf
                        [_simpleBoxAC getACParameterSetRsqData:resBusinessId ACParameterBuff:buff length:ret];
                        break;
                    case ACPARAMETERNOTIFY:
                        [_simpleBoxAC getACParameterNotifyData:resBusinessId ACParameterBuff:buff length:ret];
                        break;
                    case REVERSESTATUSID:
                        [self getReverStatusNotifyData:resBusinessId reverStatusBuff:buff length:ret];
                        break;
                    case SERVERCLOSED:
                    {
                        disconnect_box(SERVERCLOSED);
                        self.isConnected = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"通信异常");
                            if (_timer == nil) {
                                self.timer = [NSTimer scheduledTimerWithTimeInterval:30
                                                                              target:self
                                                                            selector:@selector(connectBox)
                                                                            userInfo:nil
                                                                             repeats:YES];
                            }
                            [_timer fire];
                        });
                        
                    }
                        break;
                    default:
                        break;
                }
            }else{
                NSLog(@"Recv data wrong from get_data");
            }
        }
    });
}


- (void)getReverStatusNotifyData:(unichar)resBusinessId reverStatusBuff:(char *)buff length:(int)length
{
    if (length <= 0) {
        NSLog(@"Get Conditioner data wrong\n");
        return;
    }
    NSData *data = [NSData dataWithBytes:buff length:length];
    //    ReverseStatusNotification *acParameter = [ReverseStatusNotification parseFromData:data];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReverseStatusNotification"
    //                                                        object:acParameter];
    
}

//- (BOOL)sendReverseStatusNotificationRsp
//{
    //    ReverseStatusNotificationRspBuilder *builder = [[ReverseStatusNotificationRspBuilder alloc] init];
    //    [builder setNReverseResult:1];
    //    ReverseStatusNotificationRsp *parameter = [builder build];
    //    NSData *data = [parameter data];
    //    char *reqData = (char *)[data bytes];
    //    uint length = (uint)[data length];
    //    int reqCode = send_data(REVERSESTATUSRSPID,reqData,length);
    //    if (reqCode != 0) {
    //        return NO;
    //    }
//    return true;
//    
//}

- (void)connectBox
{
    if (self.isConnected) {
        [_timer invalidate];
        _timer = nil;
        return;
    }
    [self connectBox:BOXIP withPort:BOXPORT];
}

@end
