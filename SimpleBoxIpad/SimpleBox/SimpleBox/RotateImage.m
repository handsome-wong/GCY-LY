//
//  RotateImage.m
//  旋转图片
//
//  Created by fnst1 on 15/12/8.
//  Copyright © 2015年 zhoujun. All rights reserved.
//

#import "RotateImage.h"
#define MaxTem 4.715924

@implementation RotateImage

-(id)initWithFrame:(CGRect)frame
{
    self  = [super initWithFrame:frame];
    if (self) {
        self.fromAngle = 0.0;
        self.originalR = 0.0;
        self.rotateImgView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-self.imageWidth)/2, (frame.size.height-self.imageWidth)/2, self.imageWidth, self.imageWidth)];
        self.rotateImgView.image  = [UIImage imageNamed:@"大齿轮.png"];
        self.rotateImgView.layer.masksToBounds = YES;
        self.rotateImgView.layer.cornerRadius = self.imageWidth/2;
        [self addSubview:self.rotateImgView];
    }
    return  self;
}



-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    CGPoint point = [touch locationInView:self];
    self.lengthY = point.y;
    CGPoint center  = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.originalR = [self angleFromNorth:center And:point];
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint point = [touch locationInView:self];
    CGPoint center  = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    float rotation = [self angleFromNorth:center And:point];
    self.toAngle = self.fromAngle+(rotation-self.originalR);
    if (self.toAngle>2.0*M_PI)
    {
        self.toAngle -= 2.0*M_PI;
    }
    else if (self.toAngle<0)
    {
        self.toAngle += 2.0*M_PI;
    }
    else
    {
    }
    if(self.toAngle>(7.0/4)*M_PI&&self.toAngle<2.0*M_PI)
    {
        self.toAngle = 0;
    }
    if(self.toAngle>MaxTem&&self.toAngle<7.0/4*M_PI)
    {
        self.toAngle = MaxTem;
    }
    NSLog(@"self.toAngle=======%f",self.toAngle);
    [self imgAnimation:self.fromAngle ToValue:self.toAngle];
    self.fromAngle = self.toAngle;
    self.originalR = rotation;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
//    NSDictionary *dic = self.angleOfPointDic;
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    NSMutableDictionary *dic2 = [[NSMutableDictionary alloc] init];
//    for (int i = 0; i<[dic allKeys].count; i++) {
//        float a = fabsf([[dic valueForKey:[NSString stringWithFormat:@"%d",16+i]] floatValue]-self.toAngle);
//        [array addObject:[NSString stringWithFormat:@"%f",a]];
//        [dic2 setObject:[NSString stringWithFormat:@"%d",16+i] forKey:[NSString stringWithFormat:@"%f",a]];
//    }
//    NSNumber *minNum = [array valueForKeyPath:@"@min.floatValue"];
//    float b = [minNum floatValue];
//    int terminal = [[dic2 valueForKey:[NSString stringWithFormat:@"%f",b]] intValue];
//    self.lastTem = terminal;
    float mid = (self.toAngle/MaxTem)*12+16;
    NSString *str = [NSString stringWithFormat:@"%.1f",mid];
    self.lastTem = [str floatValue];
    NSLog(@"%f",self.lastTem);
    if ([_delegate respondsToSelector:@selector(receiveACTemperature: withTag:)]) {
        [_delegate receiveACTemperature:_lastTem withTag:self.tag];
    }
}

-(void)imgAnimation:(float)fromValue ToValue:(float)toValue
{
    if(fabsf(fromValue-toValue)<1.5*M_PI){
    CABasicAnimation *roTationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    roTationAnimation.fromValue = [NSNumber numberWithFloat:fromValue];
    roTationAnimation.toValue = [NSNumber numberWithFloat:toValue];
    roTationAnimation.duration = 0.0;
    roTationAnimation.cumulative = YES;
    roTationAnimation.removedOnCompletion = NO;
    roTationAnimation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:roTationAnimation forKey:@"transform.rotation"];
    }
}

-(CGFloat)angleFromNorth:(CGPoint)p1 And:(CGPoint)p2
{
    CGPoint v = CGPointMake(p2.x-p1.x, p2.y-p1.y);
    double vmag = sqrt((v.x*v.x)+(v.y*v.y));
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y, v.x);
    return (radians >=0 ? radians : radians + 2*M_PI);
}

-(void)setTheTem:(float)tem
{
    [self imgAnimation:self.toAngle ToValue:(tem-16)/12*MaxTem];
    self.toAngle = (tem-16)/12*MaxTem;
    self.fromAngle = self.toAngle;
    self.lastTem = tem;
}
@end
