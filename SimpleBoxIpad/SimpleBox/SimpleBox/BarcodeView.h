//
//  BarcodeView.h
//  
//
//  Created by 赵群涛 on 15/12/7.
//  Copyright (c) 2015年 赵群涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol alertDeleagte <NSObject>
@optional
- (void)updateWindSpeed:(int)selectIndex;
@end


@interface BarcodeView : UIView

@property (nonatomic ,assign) id<alertDeleagte>delegate;
- (id)initWithMuen:(NSString *)addMeun;
- (void)startAnimation;
@end
