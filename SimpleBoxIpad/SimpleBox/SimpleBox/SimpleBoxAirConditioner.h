//
//  SimpleBoxAirConditioner.h
//  SimpleBox
//
//  Created by fnst001 on 11/30/15.
//  Copyright (c) 2015 FUJISTU. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Simplebox_test.pb.h"
#import "Simplebox_hacv.pb.h"
#import "ACParameter.h"

@interface SimpleBoxAirConditioner : NSObject

- (BOOL)sendACParameterGetReq;
- (BOOL)sendACParameterSetReq:(ACParameter *)parameter;

// sunlf: protobuf
- (void)getACParameterSetRsqData:(unichar) resBusinessId ACParameterBuff:(char *)buff length:(int)length;
- (void)getACParameterRsqData:(unichar)resBusinessId ACParameterBuff:(char*)buff length:(int)length;
- (void)getACParameterNotifyData:(unichar)resBusinessId ACParameterBuff:(char*)buff length:(int)length;
@end

