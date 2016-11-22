//
//  SimpleBoxHandler.h
//  SimpleBox
//
//  Created by fnst001 on 11/30/15.
//  Copyright (c) 2015 FUJISTU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleBoxAirConditioner.h"
#import "ACParameter.h"

#define BOXIP                     @"192.168.43.1"
//#define BOXIP                     @"192.168.31.4"
//#define BOXIP                     @"192.168.31.117"
#define BOXPORT                   1234

@protocol SimpleBoxHanderDelegate <NSObject>
- (void)connectBoxResult:(BOOL)connected;
@end

@interface SimpleBoxHandler : NSObject
@property (nonatomic,weak) id<SimpleBoxHanderDelegate> delegate;
@property (nonatomic,assign) BOOL isConnected;
+(instancetype)sharedInstance;
- (void)getData;
- (BOOL)sendACParameterGetReq;
- (BOOL)sendACParameterSetReq:(ACParameter*)acParameter;
- (BOOL)sendReverseStatusNotificationRsp;
- (void)connectBox:(NSString *)ip withPort:(int)port;
@end

