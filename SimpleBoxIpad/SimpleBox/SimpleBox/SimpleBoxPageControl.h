//
//  SimpleBoxPageControl.h
//  SimpleBox
//
//  Created by fnst001 on 11/30/15.
//  Copyright (c) 2015 FUJISTU. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SimpleBoxPageControlDelegate <NSObject>

- (void)updateScrollView;

@end

@interface SimpleBoxPageControl : UIPageControl

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;
- (void)updateCurrentPageDisplay;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) BOOL defersCurrentPageDisplay;
@property (nonatomic, assign) BOOL hidesForSinglePage;
@property (nonatomic, assign) BOOL wrap;

@property (nonatomic, retain) UIColor *otherColour;
@property (nonatomic, retain) UIColor *currentColor;
@property (nonatomic, assign) CGFloat controlSpacing;
@property (nonatomic, assign) CGFloat controlSize;
@property (nonatomic, strong) id<SimpleBoxPageControlDelegate> delegate;
@end
