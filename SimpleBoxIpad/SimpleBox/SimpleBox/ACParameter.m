//
//  ACParameter.m
//  SimpleBox
//
//  Created by fnst001 on 12/14/15.
//  Copyright © 2015 FUJISTU. All rights reserved.
//

#import "ACParameter.h"

@implementation ACParameter

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(_isOn) forKey:@"isOn"];
    [aCoder encodeObject:@(_leftTemp) forKey:@"leftTemp"];
    [aCoder encodeObject:@(_rightTemp) forKey:@"rightTemp"];
    [aCoder encodeObject:@(_isMax) forKey:@"isMax"];
    [aCoder encodeObject:@(_isFrontDeforst) forKey:@"isFrontDeforst"];
    [aCoder encodeObject:@(_isBackDeforst) forKey:@"isBackDeforst"];
    [aCoder encodeObject:@(_fanMode) forKey:@"fanMode"];
    [aCoder encodeObject:@(_fanSpeed) forKey:@"fanSpeed"];
    [aCoder encodeObject:@(_isAC) forKey:@"isAC"];
    [aCoder encodeObject:@(_cycleMode) forKey:@"cycleMode"];
    [aCoder encodeObject:@(_isDual) forKey:@"isDual"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.isOn = [(NSNumber *)[aDecoder decodeObjectForKey:@"isOn"] boolValue];
        self.leftTemp = [(NSNumber *)[aDecoder decodeObjectForKey:@"leftTemp"] integerValue];
        self.rightTemp = [(NSNumber *)[aDecoder decodeObjectForKey:@"rightTemp"] integerValue];
        self.isMax = [(NSNumber *)[aDecoder decodeObjectForKey:@"isMax"] boolValue];
        self.isFrontDeforst = [(NSNumber *)[aDecoder decodeObjectForKey:@"isFrontDeforst"] boolValue];
        self.isBackDeforst = [(NSNumber *)[aDecoder decodeObjectForKey:@"isBackDeforst"] boolValue];
        self.fanMode = (BlowMode)[(NSNumber *)[aDecoder decodeObjectForKey:@"fanMode"] integerValue];
        self.fanSpeed = [(NSNumber *)[aDecoder decodeObjectForKey:@"fanSpeed"] integerValue];
        self.isAC = [(NSNumber *)[aDecoder decodeObjectForKey:@"isAC"] boolValue];
        self.cycleMode = (CycMode)[(NSNumber *)[aDecoder decodeObjectForKey:@"cycleMode"] integerValue];
        self.isDual = [(NSNumber *)[aDecoder decodeObjectForKey:@"isDual"] boolValue];
    }
    return self;
}

@end
