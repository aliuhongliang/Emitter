//
//  JANumberView.m
//  Emitter
//
//  Created by 刘宏亮 on 2017/12/15.
//  Copyright © 2017年 刘宏亮. All rights reserved.
//

#import "JANumberView.h"
#define kAniNumWidth 20
#define kAniNumHeight 27

#define kAniWordOneWidth 60
#define kAniWordOneHeight 37

#define kAniWordTwoWidth 77
#define kAniWordTwoHeight 41

#define kAniWordThreeWidth 89
#define kAniWordThreeHeight 45

@interface JANumberView ()

@property (nonatomic, strong) NSString *drawNumber;

@end

@implementation JANumberView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _beginNumber = 0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // 从传入的数值获得字符串和翻转图形上下文
    NSString *numString = self.drawNumber;
    
    if (numString.integerValue <= 0) {
        return;
    }
    // 获取当前图形上下文
    CGContextRef imageContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(imageContext, 0, rect.size.height);
    CGContextScaleCTM(imageContext, 1.0, -1.0);
    
    // 绘制数字
    for (NSUInteger index = 0; index<numString.length; index++)
    {
        NSString *digit = [numString substringWithRange:NSMakeRange(index, 1)];
        
        UIImage *digitImage = [UIImage imageNamed: [NSString stringWithFormat:@"num_%@", digit]];
        
        // 绘制到合适位置
        CGRect drawRect = CGRectMake(kAniNumWidth * (index), (self.frame.size.height - kAniNumHeight) * 0.5, kAniNumWidth, kAniNumHeight);
        CGContextDrawImage(imageContext, drawRect, digitImage.CGImage);
    }
    
    // 绘制文字
    CGFloat num = numString.integerValue;
    CGFloat len = numString.length;
    if (num < 20) {
        UIImage *crossImage = [UIImage imageNamed:@"num_one"];
        CGRect crossRect = CGRectMake(len * kAniNumWidth - 2, (self.frame.size.height - kAniWordOneHeight) * 0.5, kAniWordOneWidth, kAniWordOneHeight);
        CGContextDrawImage(imageContext, crossRect, crossImage.CGImage);
    }else if (num < 40){
        UIImage *crossImage = [UIImage imageNamed:@"num_two"];
        CGRect crossRect = CGRectMake(len * kAniNumWidth - 2, (self.frame.size.height - kAniWordTwoHeight) * 0.5, kAniWordTwoWidth, kAniWordTwoHeight);
        CGContextDrawImage(imageContext, crossRect, crossImage.CGImage);
    }else{
        UIImage *crossImage = [UIImage imageNamed:@"num_three"];
        CGRect crossRect = CGRectMake(len * kAniNumWidth - 2, (self.frame.size.height - kAniWordThreeHeight) * 0.5, kAniWordThreeWidth, kAniWordThreeHeight);
        CGContextDrawImage(imageContext, crossRect, crossImage.CGImage);
    }
}

- (void)setBeginNumber:(NSInteger)beginNumber
{
    _beginNumber = beginNumber;
    
    [self drawAgain];
}


- (void)drawAgain
{
    _drawNumber = [NSString stringWithFormat:@"%ld",_beginNumber];
    [self setNeedsDisplay];
    
//    [self animate];
}


@end
