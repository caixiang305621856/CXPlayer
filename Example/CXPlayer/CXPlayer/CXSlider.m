//
//  CXSlider.m
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/12.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "CXSlider.h"

@interface CXSlider() {
    CGRect _frame;
}
@property (nonatomic, strong) UIImageView *trackImageView;  //缓冲轨道
@property (nonatomic, strong) UIImageView *bufferImageView;//缓冲进度
@property (nonatomic, strong) UIImageView *thumbValueImageView;//滑块进度

@property (nonatomic, strong) UIView *thumb;               //滑块的父视图（不可见）
@property (nonatomic, strong) UIImageView *thumbImageView; //用于显示滑块的ImageView（可视

@end

@implementation CXSlider

- (void)layoutSubviews {
    [super layoutSubviews];
    _frame = self.frame;
    _thumbTouchSize = _frame.size.height;
    _thumbVisibleSize = 10;
    _trackHeight = 2;
    [self updateFrame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.trackImageView.backgroundColor = [UIColor grayColor];
        self.bufferImageView.backgroundColor = [UIColor whiteColor];
        self.thumbValueImageView.backgroundColor = [UIColor redColor];
        self.thumb.backgroundColor = [UIColor clearColor];
        self.thumbImageView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)updateFrame{
    self.trackImageView.frame = CGRectMake(0, (_frame.size.height - _trackHeight) * 0.5, _frame.size.width, _trackHeight);
    self.bufferImageView.frame = CGRectMake(0, (_frame.size.height - _trackHeight) * 0.5, _bufferProgress * _frame.size.width, _trackHeight);
    
    self.thumbValueImageView.frame = CGRectMake(0, (_frame.size.height - _trackHeight) * 0.5, _value * _frame.size.width, _trackHeight);
    self.thumb.frame = CGRectMake(0, 0, _thumbTouchSize, _thumbTouchSize);
    self.thumb.center = [self getThumbCenterWithValue:_value];
    self.thumbImageView.frame = CGRectMake((_thumbTouchSize - _thumbVisibleSize) * 0.5, (_thumbTouchSize - _thumbVisibleSize) * 0.5, _thumbVisibleSize, _thumbVisibleSize);
}

- (CGPoint)getThumbCenterWithValue:(CGFloat)value{
    CGFloat thumbX = _thumbVisibleSize * 0.5 + (_frame.size.width - _thumbVisibleSize) * value;
    CGFloat thumbY = _frame.size.height * 0.5;
    return CGPointMake(thumbX, thumbY);
}

- (UIImageView *)trackImageView{
    if (!_trackImageView) {
        _trackImageView = [[UIImageView alloc] init];
        _trackImageView.layer.masksToBounds = YES;
        [self addSubview:_trackImageView];
    }
    return _trackImageView;
}

- (UIImageView *)bufferImageView{
    if (!_bufferImageView) {
        _bufferImageView = [[UIImageView alloc] init];
        _bufferImageView.layer.masksToBounds = YES;
        [self addSubview:_bufferImageView];
    }
    return _bufferImageView;
}

- (UIImageView *)thumbValueImageView{
    if (!_thumbValueImageView) {
        _thumbValueImageView = [[UIImageView alloc] init];
        _thumbValueImageView.layer.masksToBounds = YES;
        [self addSubview:_thumbValueImageView];
    }
    return _thumbValueImageView;
}

- (UIView *)thumb{
    if (!_thumb) {
        _thumb = [[UIView alloc] init];
        _thumb.layer.masksToBounds = YES;
        _thumb.userInteractionEnabled = NO;
        [self addSubview:_thumb];
    }
    return _thumb;
}

- (UIImageView *)thumbImageView{
    if (!_thumbImageView) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.layer.masksToBounds = YES;
        [self.thumb addSubview:_thumbImageView];
    }
    return _thumbImageView;
}

- (void)setTrackColor:(UIColor *)trackColor{
    self.trackImageView.backgroundColor = trackColor;
}

- (void)setBufferColor:(UIColor *)bufferColor{
    self.bufferImageView.backgroundColor = bufferColor;
}

- (void)setThumbValueColor:(UIColor *)thumbValueColor{
    self.thumbImageView.backgroundColor = thumbValueColor;
}

- (void)setTrackHeight:(CGFloat)trackHeight{
    _trackHeight = trackHeight;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setThumbVisibleSize:(CGFloat)thumbVisibleSize{
    _thumbVisibleSize = thumbVisibleSize;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setBufferProgress:(CGFloat)bufferProgress{
    bufferProgress = [self valid:bufferProgress];
    if (_bufferProgress == bufferProgress) {
        return;
    }
    _bufferProgress = bufferProgress;
    self.bufferImageView.frame = CGRectMake(0, (_frame.size.height - _trackHeight) * 0.5, _bufferProgress * _frame.size.width, _trackHeight);
}

- (void)setValue:(CGFloat)value {
    value = [self valid:value];
    if (_value == value) {
        return;
    }
    _value = value;
    
    self.thumb.center = [self getThumbCenterWithValue:_value];
    self.thumbValueImageView.frame = CGRectMake(0, (_frame.size.height - _trackHeight) * 0.5, _value * _frame.size.width, _trackHeight);
}

- (float)valid:(float)f {
    if (isnan(f)) {
        return 0.0;
    }
    if (f < 0.005) {
        return 0.0;
    }
    else if (f > 0.995) {
        f = 1.0;
    }
    return f;
}

- (void)setThumbImage:(UIImage *)thumbImage forState:(UIControlState)state{
    if (state == UIControlStateNormal) {
        self.thumbImageView.image = thumbImage;
        self.thumbImageView.backgroundColor = [UIColor clearColor];
    }
    else if (state == UIControlStateHighlighted) {
        self.thumbImageView.highlightedImage = thumbImage;
        self.thumbImageView.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    if (!CGRectContainsPoint(self.thumb.frame, location)) {
        return NO;
    }
    self.thumbImageView.highlighted = YES;
    [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    
    if (location.x <= CGRectGetWidth(self.bounds) + 10 && location.x >= - 10) {
        self.thumbImageView.highlighted = YES;
        self.value = location.x / CGRectGetWidth(self.bounds);
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.thumbImageView.highlighted = NO;
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}


@end
