//
//  CXSlider.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/12.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_STATIC_INLINE UIEdgeInsets play_viewSafeArea(UIView *view) {
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
#endif
    return UIEdgeInsetsZero;
}

NS_ASSUME_NONNULL_BEGIN

@interface CXSlider : UIControl

/**
 0 - 1. 播放进度
 */
@property (nonatomic, assign) CGFloat value;

/**
 0 - 1. 缓冲进度
 */
@property (nonatomic, assign) CGFloat bufferProgress;

/**
 轨道高度
 */
@property (nonatomic, assign) CGFloat trackHeight;

/**
 滑块触发大小的宽高
 */
@property (nonatomic, assign) CGFloat thumbTouchSize;

/**
 滑块可视大小的宽高
 */
@property (nonatomic, assign) CGFloat thumbVisibleSize;

/**
 轨道的颜色
 */
@property (nonatomic, strong) UIColor *trackColor;

/**
 缓冲的颜色
 */
@property (nonatomic, strong) UIColor *bufferColor;

/**
 播放进度的颜色
 */
@property (nonatomic, strong) UIColor *thumbValueColor; 

/**
 为滑块设置图片

 @param thumbImage 滑块图片
 @param state 状态
 */
- (void)setThumbImage:(UIImage *)thumbImage forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
