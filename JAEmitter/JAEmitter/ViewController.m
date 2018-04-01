//
//  ViewController.m
//  JAEmitter
//
//  Created by 刘宏亮 on 2018/4/1.
//  Copyright © 2018年 刘宏亮. All rights reserved.
//

#import "ViewController.h"
#import "JAEmitterView.h"
#import "UIView+Extension.h"

@interface ViewController ()<JAEmitterViewDelegate>
@property (nonatomic, strong) UIView *backview;
@property (nonatomic, weak) JAEmitterView *agreeButton; // 点赞
@property (nonatomic, assign) NSTimeInterval frontTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.backview = [[UIView alloc] init];
    [self.view addSubview:self.backview];
    
    JAEmitterView *agreeButton = [[JAEmitterView alloc] initWithType:100];
    [agreeButton setImage:[UIImage imageNamed:@"voice_agree_nor"] forState:UIControlStateNormal];
    [agreeButton setImage:[UIImage imageNamed:@"voice_agree_nor"] forState:UIControlStateHighlighted];
    [agreeButton setImage:[UIImage imageNamed:@"voice_agree_sel"] forState:UIControlStateSelected];
    [agreeButton setImage:[UIImage imageNamed:@"voice_agree_sel"] forState:UIControlStateSelected|UIControlStateHighlighted];
    agreeButton.imageView.contentMode = UIViewContentModeCenter;

    agreeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    agreeButton.delegate = self;
    [self.backview addSubview:agreeButton];
    self.agreeButton = agreeButton;
    
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.backview.y = 200;
    self.backview.x = 100;
    self.backview.width = 30;
    self.backview.height = 60;
    
    self.agreeButton.width = 30;
    self.agreeButton.height = 30;
    self.agreeButton.y = self.agreeButton.height;
    
    
    
}

#pragma mark - 点赞的代理方法
- (void)emitterViewClickSingle:(JAEmitterView *)button
{
    if (button.selected) {
        
        if ([self checkTimeMargin]) {
            [self agreeAction:button];
        }
    }else{
        
        [self agreeAction:button];
    }
}

// 判断时间间隔是否大于0.3
- (BOOL)checkTimeMargin
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    if (interval - self.frontTime > 1300) {
        
        self.frontTime = interval;
        return YES;
    }
    self.frontTime = interval;
    return NO;
}

- (void)emitterViewClickLongSingle:(JAEmitterView *)button
{
    if (!button.selected) {
        [self agreeAction:button];
    }
}


- (void)agreeAction:(JAEmitterView *)sender {
    
    sender.selected = !sender.selected;
}
@end
