//
//  BubblingViewController.m
//  CoreMotionStudy
//
//  Created by 索晓晓 on 16/8/17.
//  Copyright © 2016年 SXiao.RR. All rights reserved.
//

#import "BubblingViewController.h"
#import <Masonry.h>

@interface BubblingViewController ()

//@property (nonatomic ,strong)CALayer *bublingLayer;

@property (nonatomic ,strong)NSMutableArray *images;

@end

@implementation BubblingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"冒泡" forState:0];
    [btn setBackgroundColor:[UIColor magentaColor]];
    [btn addTarget:self action:@selector(bubblindStart) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    [self.view addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_offset(CGSizeMake(44, 44));
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-50);
    }];
    
    _images = [NSMutableArray arrayWithArray:@[@"ic_menu_bluepig",
                                               @"ic_menu_bluepig2",
                                               @"ic_menu_greenpig",
                                               @"ic_menu_greenpig2",
                                               @"ic_menu_pinkpig",
                                               @"ic_menu_pinkpig2",
                                               @"ic_menu_purplepig",
                                               @"ic_menu_purplepig2",
                                               @"ic_menu_yellowpig",
                                               @"ic_menu_yellowpig2"]];
    
}

- (void)bubblindStart
{
    NSLog(@"%s",__func__);
    
    [self bublindImage:[UIImage imageNamed:@"love"]];
    [self bublindImage:[UIImage imageNamed:[_images objectAtIndex:arc4random_uniform((int)_images.count)]]];
}

- (void)bublindImage:(UIImage *)image
{
    
    CALayer *tempLayer = [CALayer layer];
    tempLayer.opacity = 0.0f;
    CGFloat width = 28.0f;
    CGFloat x = self.view.center.x - width/2;
    CGFloat height = width * image.size.height/image.size.width;
    CGFloat y = self.view.frame.size.height - 50 - 44 - height;
    tempLayer.frame = CGRectMake(x,y,width,height);
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0, 0, width, height);
    maskLayer.contents = (__bridge id)image.CGImage;
    maskLayer.contentsGravity = kCAGravityResizeAspect;
    
    tempLayer.mask = maskLayer;
    tempLayer.backgroundColor = [self getColor];
    
    //这里遮盖的意思是  显示tempLayer上  在遮盖层不透明像素的地方
    //也就是说  maskLayer遮盖层控制的是形状  maskLayer有内容的地方显示 没有内容的地方不显示   tempLayer控制的是颜色
    
    [self.view.layer addSublayer:tempLayer];
    
    [self startAnimationWithLayer:tempLayer];
}

- (CGColorRef)getColor
{
    return [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0].CGColor;
}

- (void)startAnimationWithLayer:(CALayer *)animationLayer
{
    //位置动画
    CAKeyframeAnimation *posAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    int rangeNum = 60;
    CGFloat destination_x = animationLayer.position.x + arc4random_uniform(rangeNum) - rangeNum/2;
    CGFloat destinaion_y = animationLayer.position.y / 2;
    CGPoint po1 = CGPointMake(destination_x, destinaion_y);
    
    posAnimation.values = @[[NSValue valueWithCGPoint:animationLayer.position],[NSValue valueWithCGPoint:po1]];
    posAnimation.repeatCount = 1;
    posAnimation.removedOnCompletion = NO;
    posAnimation.autoreverses = NO;
    posAnimation.fillMode = kCAFillModeForwards;
    posAnimation.calculationMode = kCAAnimationLinear;
    posAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionLinear];
    
    //透明度动画
    CAKeyframeAnimation *alphaAnimation =
    [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.values = @[@1.0,@1.0,@0.0];
    alphaAnimation.keyTimes = @[@0.0,@0.90,@1.0];
    
    //旋转动画
    CABasicAnimation *angleAnimation =
    [CABasicAnimation animationWithKeyPath:@"transform"];
    [angleAnimation setFromValue:
     [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)]];
    CATransform3D destTrans =
    CATransform3DMakeRotation(M_PI/4, 0, 0, (arc4random() % 2000) /1000.0f -1);
    destTrans = CATransform3DScale(destTrans, 1.5f, 1.5f, 1.5f);
    [angleAnimation setToValue:[NSValue valueWithCATransform3D:destTrans]];
    angleAnimation.beginTime = 0.2;
    
    //缩放
    CABasicAnimation *scaleAnimation =
    [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [scaleAnimation setFromValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1f, 0.1f, 1.0f)]];
    CATransform3D scaleTrans = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
    [scaleAnimation setToValue:[NSValue valueWithCATransform3D:scaleTrans]];
    scaleAnimation.duration = 0.2;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    [groupAnimation setAnimations:@[posAnimation,alphaAnimation,angleAnimation]];
    [groupAnimation setDuration:2];
    [groupAnimation setRemovedOnCompletion:YES];

    
    groupAnimation.delegate = self;
    [groupAnimation setValue:animationLayer
                      forKey:@"group"];
    
    [animationLayer addAnimation:groupAnimation forKey:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    CALayer *animationLayer = [anim valueForKey:@"group"];
    
    if (animationLayer) {
        
        [animationLayer removeFromSuperlayer];
        
    }
}


@end
