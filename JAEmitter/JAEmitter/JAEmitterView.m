//
//  JAEmitterView.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/15.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAEmitterView.h"
#import "JANumberView.h"
#import "UIView+Extension.h"

#define kNumAniDuration 0.3    // 数字绘制动画总时长
#define kNeedAniNum1 20        // 鼓励 - 加油
#define kNeedAniNum2 40        // 加油 - 太棒了
#define kPathwayCount 5        // 轨道个数

#define kAngleArray @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9)]   // 角度分段
#define KAngleMargin 13                // 角度间隔数
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)   // 角度转弧度
//#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))  // 弧度转角度

typedef NS_ENUM(NSUInteger, JAFireAngleType) {
    JAFireAngleTypeLeft,
    JAFireAngleTypeRight,
    JAFireAngleTypeVertical,
};

@interface JAEmitterView ()
@property (nonatomic, strong) JANumberView *numView;
@property (nonatomic, assign) BOOL needAni;

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSInteger drawNum;

@property (nonatomic, assign) NSInteger type;
@end

@implementation JAEmitterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchDown)];
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownTwo:)];
        longG.minimumPressDuration = 0.4;
        [self addGestureRecognizer:longG];
    }
    return self;
}

- (instancetype) initWithType:(NSInteger)type
{
    self = [super init];
    if (self) {
        
        self.clipsToBounds = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchDown)];
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownTwo:)];
        longG.minimumPressDuration = 0.4;
        [self addGestureRecognizer:longG];
        
        self.type = type;
    }
    
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (_type == 100) {
        
        return CGRectMake((self.width - 34) / 2, 1, 34, 34);
    }else{
        return [super imageRectForContentRect:contentRect];
    }
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    if (_type == 100) {
        
        return CGRectMake((self.width - 100) / 2, self.imageView.bottom - 2, 100, 12);
    }else{
        return [super titleRectForContentRect:contentRect];
    }
}



- (void)touchDown
{
    if ([self.delegate respondsToSelector:@selector(emitterViewClickSingle:)]) {
        [self.delegate emitterViewClickSingle:self];
    }
    
    if (!self.selected) {
        return;
    }
    
    self.drawNum = self.drawNum + 1;
    [self beginDrawNum:self.drawNum];
    [self beginEmitterAnimte:kPathwayCount from:self.beginAngle direction:self.direction];
}

- (void)touchDownTwo:(UILongPressGestureRecognizer *)longG
{
    if (longG.state == UIGestureRecognizerStateBegan) {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animiateEmitter) userInfo:nil repeats:YES];
    }else if(longG.state != UIGestureRecognizerStateChanged){
        [self.timer invalidate];
        self.timer = nil;
    }
}

// 长按
- (void)animiateEmitter
{
    if ([self.delegate respondsToSelector:@selector(emitterViewClickLongSingle:)]) {
        [self.delegate emitterViewClickLongSingle:self];
    }
    
    if (!self.selected) {
        return;
    }
    
    self.drawNum = self.drawNum + 1;
    [self beginDrawNum:self.drawNum];
    [self beginEmitterAnimte:kPathwayCount from:self.beginAngle direction:self.direction];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (!selected) {
        self.drawNum = 0;
        [self beginDrawNum:self.drawNum];
    }
}

- (JANumberView *)numView
{
    if (_numView == nil) {
        _numView = [[JANumberView alloc] init];
        _numView.frame = CGRectZero;
        _numView.backgroundColor = [UIColor clearColor];
        _numView.height = 45;
        _numView.userInteractionEnabled = NO;
        [[[[UIApplication sharedApplication] delegate] window] addSubview:_numView];
    }
    
    return _numView;
}


// 重置
- (void)resetEmitter
{
    self.drawNum = 0;
    [self beginDrawNum:self.drawNum];
}

// 开始动画
- (void)beginEmitterAnimte:(NSInteger)count from:(NSInteger)from direction:(NSInteger)direction
{
    NSArray *angleArr = [self arraySortBreak];  // 数组
    
    for (NSInteger i = 0; i < count; i++) {
        
        CAEmitterLayer *emitter = [[CAEmitterLayer alloc] init];
        emitter.emitterShape = kCAEmitterLayerPoint;
        emitter.emitterMode = kCAEmitterLayerVolume;
        emitter.emitterPosition = [self convertPoint:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) toView:[[[UIApplication sharedApplication] delegate] window]];
        emitter.birthRate = 0;

        CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = [NSNumber numberWithFloat:1.0];
        animation.toValue = [NSNumber numberWithFloat:0.0];
        animation.duration = 0.8f;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [emitter addAnimation:animation forKey:nil];
//
        CAEmitterCell *cell = [[CAEmitterCell alloc] init];
        
        NSInteger emoji = (arc4random() % 40) + 1;
        NSString *imageName =[NSString stringWithFormat:@"emoji-%ld",emoji];
        
        cell.contents = (id) [UIImage imageNamed:imageName].CGImage;
        cell.scale = 0.6;
        cell.lifetime = 0.8;
        cell.birthRate = 1;
//        cell.alphaSpeed = -1;
        
        // 计算角度 1 获取当前可选的角度区间
        NSInteger angleM = [angleArr[i] integerValue];
        
        NSInteger ranRngle = [self getRandomNumberToNum:angleM];   // 随机角度
        
        if (direction == 0) {   // 逆时针
            cell.emissionLongitude = DEGREES_TO_RADIANS(from) - DEGREES_TO_RADIANS(ranRngle);
            
            if (abs((int)(from - ranRngle)) > 180) {
                cell.emissionLongitude = DEGREES_TO_RADIANS(180 - abs((int)(from - ranRngle)) + 180);
            }
            
        }else{  // 顺时针
            
            cell.emissionLongitude = DEGREES_TO_RADIANS(from) + DEGREES_TO_RADIANS(ranRngle);
        }
        
        // 初始速度
        CGFloat v = (arc4random() % 300 + 200) * ([UIScreen mainScreen].scale) / 0.8;
        
        // y 轴的加速度
        CGFloat yA = - v * sin(cell.emissionLongitude) + 300;
        
        // x 轴的加速度
        CGFloat xA = - (v * cos(cell.emissionLongitude));
        
        cell.velocity = v;
        cell.yAcceleration = yA;
        cell.xAcceleration = xA;
        
        emitter.emitterCells = @[cell];
//        [self.layer addSublayer:emitter];
        [[[[[UIApplication sharedApplication] delegate] window] layer] addSublayer:emitter];
        emitter.beginTime = CACurrentMediaTime() - 1;
        emitter.birthRate = 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            emitter.birthRate = 0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [emitter removeFromSuperlayer];
            });
        });
    }
}

#pragma mark - 计算弧度
// 获取角度随机区间的随机值
-(NSInteger)getRandomNumberToNum:(NSInteger)to
{
    NSInteger from = to - 1;
    
    return (NSInteger)((from * KAngleMargin + 1) + (arc4random() % (KAngleMargin + 1)));
}

- (NSArray *)arraySortBreak{
    
    NSArray *array = kAngleArray;
    
    NSArray *result = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        if (arc4random_uniform(2) == 0) {
            return [obj2 compare:obj1]; //降序
        }
        else{
            return [obj1 compare:obj2]; //升序
        }
    }];
    
    return result;
    
}

// 绘制数字
- (void)beginDrawNum:(NSInteger)count
{
    
    if (_numView.alpha < 1 || count == kNeedAniNum1 || count == kNeedAniNum2 || _numView == nil) {
        _numView.alpha = 1;
        
        self.needAni = YES;
    }
    
    self.numView.isValid = YES;
    
    // 计算宽度
    NSString *str = [NSString stringWithFormat:@"%ld",count];
    CGFloat w = str.length * 20;
    if (count < 20) {
        self.numView.width = 60 + w;
    }else if (count < 40){
        self.numView.width = 77 + w;
    }else{
        self.numView.width = 89 + w;
    }
    
    // 坐标转换
    CGPoint numViewP = [self.superview convertPoint:CGPointMake(self.x, self.y) toView:[[[UIApplication sharedApplication] delegate] window]];
    
    if (self.x > [UIScreen mainScreen].bounds.size.width * 0.5) {  // 按钮在右边
        self.numView.x = numViewP.x + self.width - self.numView.width;
        
    }else{  // 按钮在左边
        self.numView.centerX = numViewP.x + self.width * 0.5 + 20;
        
    }
    
    self.numView.y = numViewP.y -10 - self.numView.height;
    
    
    // d动画
    if (self.needAni) {
        self.needAni = NO;
        [self numViewAnimate:self.y to:0];

    }else{
        [self numviewSpringAnimate:count];
    }
    
    self.numView.beginNumber = count;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeNumView) object:nil];
    [self performSelector:@selector(removeNumView) withObject:nil afterDelay:kNumAniDuration + 0.1];
}

- (void)removeNumView
{
    _numView.isValid = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _numView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        if (!_numView.isValid) {
            [_numView removeFromSuperview];
            _numView = nil;
        }
    }];
}

// 数字出来的时候的动画
- (void)numViewAnimate:(CGFloat)from to:(CGFloat)to
{
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation1.beginTime = 0;
    animation1.duration = kNumAniDuration - 0.1;
    animation1.fromValue = [NSNumber numberWithFloat:from];
    animation1.toValue = [NSNumber numberWithFloat:to]; // 終点

    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation2.beginTime = animation1.beginTime;
    animation2.duration = animation1.duration;
    animation2.fromValue = [NSNumber numberWithFloat:0.1]; // 开始时的倍率
    animation2.toValue = [NSNumber numberWithFloat:1.2]; // 结束时的倍率

    CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation3.beginTime = animation1.beginTime + animation1.duration;
    animation3.duration = (kNumAniDuration - animation1.duration) * 0.5;
    animation3.fromValue = [NSNumber numberWithFloat:1.2]; // 开始时的倍率
    animation3.toValue = [NSNumber numberWithFloat:0.9]; // 结束时的倍率

    CABasicAnimation *animation4 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation4.beginTime = animation3.beginTime + animation3.duration;
    animation4.duration = animation3.duration;
    animation4.fromValue = [NSNumber numberWithFloat:0.9]; // 开始时的倍率
    animation4.toValue = [NSNumber numberWithFloat:1.0]; // 结束时的倍率

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = kNumAniDuration;
    group.repeatCount = 1;
    
    // 添加动画
    group.animations = [NSArray arrayWithObjects:animation1,animation2,animation3,animation4,nil];
    [self.numView.layer addAnimation:group forKey:@"move-rotate-layer"];
}

// 有数字时候的弹性动画
- (void)numviewSpringAnimate:(NSInteger)count;
{
    if (count % 10 == 0) {
        
        CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.duration = 0.2;
        
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        animation.values = values;
        [self.numView.layer addAnimation:animation forKey:@"move-frame-layer"];
    }
}
@end
