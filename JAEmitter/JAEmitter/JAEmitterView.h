//
//  JAEmitterView.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/15.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAEmitterView;

@protocol JAEmitterViewDelegate <NSObject>  

// 单击的代理
- (void)emitterViewClickSingle:(JAEmitterView *)button;
// 长按的代理
- (void)emitterViewClickLongSingle:(JAEmitterView *)button;
@end

@interface JAEmitterView : UIButton

- (instancetype) initWithType:(NSInteger)type;

/// 绘制的开始角度 (角度值)
@property (nonatomic, assign) NSInteger beginAngle;
/// 绘制的方向 （0 逆时针 1顺时针）
@property (nonatomic, assign) NSInteger direction;

@property (nonatomic, weak) id <JAEmitterViewDelegate> delegate;

// 重置
- (void)resetEmitter;
@end
