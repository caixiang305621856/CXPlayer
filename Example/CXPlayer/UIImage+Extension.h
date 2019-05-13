//
//  UIImage+Extension.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/12.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extension)
/** 缩放到指定大小 */
- (UIImage*)imageCompressWithSimple:(UIImage*)image scaledToSize:(CGSize)size;

/** 根据颜色和圆的半径来创建一个 Image */
+ (UIImage *)createImageWithColor:(UIColor *)color radius:(CGFloat)radius;

/** 根据一个view来创建一个 Image */
+ (UIImage*)creatImageWithView:(UIView *)theView;

@end

NS_ASSUME_NONNULL_END
