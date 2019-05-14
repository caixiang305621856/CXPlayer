//
//  UIImage+Extension.m
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/12.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "UIImage+CXExtension.h"

#define PI 3.14159265358979323846

@implementation UIImage (Extension)
//缩放到指定大小
- (UIImage*)imageCompressWithSimple:(UIImage*)image scaledToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//根据颜色和圆的半径来创建一个圆形图片
+ (UIImage *)createImageWithColor:(UIColor *)color radius:(CGFloat)radius {
    CGRect rect = CGRectMake(0.0f, 0.0f,radius * 2 + 4, radius * 2 + 4);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,1,1,1,1.0);//画笔线的颜色
    CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    CGContextSetLineWidth(context, 4.0);//线的宽度

    CGContextAddArc(context, radius + 2,radius + 2, radius, 0, 2*PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
    
    UIImage *myImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return myImage;
}

//根据一个view来创建一个 Image
+ (UIImage*)creatImageWithView:(UIView *)theView {
    CGRect rect = theView.frame;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)imageWithColors:(NSArray<UIColor *>*)colors
                        size:(CGSize)size leftToRight:(BOOL)leftToRight {
    @autoreleasepool {
        NSMutableArray* alphaGradientColors = [@[] mutableCopy];
        [colors enumerateObjectsUsingBlock:^(UIColor *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [alphaGradientColors addObject:(id)obj.CGColor];
        }];
        NSArray *gradientColors = [alphaGradientColors copy];
        CFArrayRef cfcolors = (__bridge CFArrayRef)gradientColors;
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGGradientRef gradientRef = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (CFArrayRef)cfcolors,  (CGFloat[]){
            0.0f,       // 对应起点颜色位置
            1.0f // 对应终点颜色位置
        });
        CGContextSaveGState(ctx);
        CGContextAddRect(ctx, rect);
        CGContextClip(ctx);//裁剪
        if (leftToRight) {
            CGContextDrawLinearGradient(ctx, gradientRef, CGPointMake(0, 0), CGPointMake(size.width,0), kCGGradientDrawsBeforeStartLocation);
        } else{
            CGContextDrawLinearGradient(ctx, gradientRef, CGPointMake(0, 0), CGPointMake(0,size.height), kCGGradientDrawsBeforeStartLocation);
        }
        CGContextRestoreGState(ctx);//恢复状态
        CGGradientRelease(gradientRef);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    }
}

+ (UIImage *)cx_imageNamedFromMyBundle:(NSString *)name {
    return [self cx_imagePathWithName:name bundle:@"CXPlayer" targetClass:NSClassFromString(@"CXPlayerView")];
}

+ (instancetype)cx_imagePathWithName:(NSString *)imageName bundle:(NSString *)bundle targetClass:(Class)targetClass {
    NSBundle *currentBundle = [NSBundle bundleForClass:targetClass];
    NSString *name = [NSString stringWithFormat:@"%@@2x",imageName];
    NSString *dir = [NSString stringWithFormat:@"%@.bundle",bundle];
    NSString *path = [currentBundle pathForResource:name ofType:@"png" inDirectory:dir];
    return path ? [UIImage imageWithContentsOfFile:path] : [UIImage new];
}

@end
