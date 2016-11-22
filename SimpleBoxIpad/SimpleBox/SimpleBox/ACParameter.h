//
//  ACParameter.h
//  SimpleBox
//
//  Created by fnst001 on 12/14/15.
//  Copyright © 2015 FUJISTU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Simplebox_hacv.pb.h"

@interface ACParameter : NSObject <NSCoding>

@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, assign) NSInteger leftTemp;
@property (nonatomic, assign) NSInteger rightTemp;
@property (nonatomic, assign) BOOL isMax;
@property (nonatomic, assign) BOOL isFrontDeforst;
@property (nonatomic, assign) BOOL isBackDeforst;
@property (nonatomic, assign) BlowMode fanMode;
@property (nonatomic, assign) NSInteger fanSpeed;
@property (nonatomic, assign) BOOL isAC;
@property (nonatomic, assign) CycMode cycleMode;
@property (nonatomic, assign) BOOL isDual;

@end