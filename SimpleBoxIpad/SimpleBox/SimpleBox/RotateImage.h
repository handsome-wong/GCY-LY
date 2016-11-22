//
//  RotateImage.h
//  旋转图片
//
//  Created by fnst1 on 15/12/8.
//  Copyright © 2015年 zhoujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ImgeWidth 295

@protocol rotateImageDelegate <NSObject>

- (void)receiveACTemperature:(float)temperature withTag:(long)tag;

@end

@interface RotateImage : UIControl
@property (nonatomic,assign) float fromAngle;
@property (nonatomic,assign) float imageWidth;
@property (nonatomic,assign) float toAngle;
@property (nonatomic,assign) float originalR;
@property (nonatomic,assign) float totoalRadians;
@property (nonatomic,assign) float lastTem;
@property (nonatomic,retain) UIImageView *rotateImgView;
@property (nonatomic,assign) float lengthY;
@property (nonatomic,weak) id<rotateImageDelegate> delegate;
-(void)setTheTem:(float)tem;
@end
