//
//  BarcodeView.m
//  
//
//  Created by 赵群涛 on 15/12/7.
//  Copyright (c) 2015年 赵群涛. All rights reserved.
//

#import "BarcodeView.h"
#import "SEFilterControl.h"

#define WIDTH ([UIScreen  mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define VH(view) CGRectGetMaxY(view.frame)

@interface BarcodeView ()
@property (nonatomic,assign) int selectedIndex;
@end

@implementation BarcodeView
- (id)initWithMuen:(NSString *)addMeun{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH)];
        view.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(canceButtonClcik)];
        [view addGestureRecognizer:tap];
//        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
//        effectView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
//        [effectView addGestureRecognizer:tap];
        
        [self addSubview:view];
        self.alpha = 1.0;
        [self creatView:addMeun];
        self.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        self.selectedIndex = 0;
        
    }
    return self;
}

- (void)startAnimation
{
    [UIView transitionWithView:self duration:2.0f
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:NULL
                    completion:NULL];
}
- (void)creatView:(NSString *)addMeun {
    //取消按钮
    UIView *bgView = [[UIView alloc] init];
    bgView.alpha = 1;
    bgView.backgroundColor = [UIColor grayColor];
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 400, 40)];
    title.text = @"设置";
    title.textAlignment = NSTextAlignmentCenter;
    title.backgroundColor = [UIColor blackColor];
    title.textColor = [UIColor whiteColor];
    [bgView addSubview:title];
    
    SEFilterControl *filter = [[SEFilterControl alloc]initWithFrame:CGRectMake(0, 50,400, 70) Titles:[NSArray arrayWithObjects:@"小", @"中", @"中大", @"大", @"特大", nil]];
    [filter addTarget:self action:@selector(filterValueChanged:) forControlEvents:UIControlEventValueChanged];
    filter.progressColor = [UIColor whiteColor];
    filter.SelectedIndex = _selectedIndex;
    [bgView addSubview:filter];
    
    //确认按钮
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake(0, 160,400, 40);
    [sureButton setTitle:@"确认" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:sureButton];
    
    
    bgView.frame = CGRectMake(0, 0, 400, 200);
    bgView.layer.cornerRadius = 10;
    bgView.center = CGPointMake(WIDTH/2, HEIGHT/2);
    bgView.layer.masksToBounds = YES;
    bgView.clipsToBounds = YES;
    [self addSubview:bgView];
}

//点击空白处取消按钮
- (void)canceButtonClcik
{
    if ([_delegate respondsToSelector:@selector(updateWindSpeed:)]) {
        [_delegate updateWindSpeed:_selectedIndex];
    }
    [self removeFromSuperview];
    
}
//点击取消按钮
- (void)sureButtonClick:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(updateWindSpeed:)]) {
        [_delegate updateWindSpeed:_selectedIndex];
    }
    [self removeFromSuperview];
    
}
-(void)filterValueChanged:(SEFilterControl *) sender{
    self.selectedIndex = sender.SelectedIndex;
}

@end
