//
//  LoveViewController.m
//  CoreMotionStudy
//
//  Created by 索晓晓 on 16/8/16.
//  Copyright © 2016年 SXiao.RR. All rights reserved.
//

#import "LoveViewController.h"
#import <Masonry.h>
#import <CoreMotion/CoreMotion.h>

@interface LoveViewController ()


@property (nonatomic ,strong)UIButton                   *startBtn;

@property (nonatomic ,strong)UIButton                   *endBtn;

//运动管理  效果器
@property (nonatomic, strong)  CMMotionManager          * motionMManager;
//动力学
@property (nonatomic , strong) UIDynamicAnimator        * animator;
//碰撞运动设置
@property (nonatomic , strong) UICollisionBehavior      * collisionBehavitor;
//重力
@property (nonatomic , strong) UIGravityBehavior        * gravityBehavior;
//运动辅助设置
@property (nonatomic , strong) UIDynamicItemBehavior    * itemBehavitor;
@property (strong, nonatomic)  NSMutableArray           *dropsArray;
//@property (strong, nonatomic)  UIImageView              *leftShoot;
//@property (strong, nonatomic)  UIImageView              *rightShoot;
@property (strong, nonatomic)  UIView                   *giftView;
@property (nonatomic, strong)  dispatch_source_t        timer;

@property (assign,nonatomic) BOOL isDropping;

@property (assign,nonatomic) int page;

@end


@implementation LoveViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"LOVE";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    
    self.giftView = [[UIView alloc] init];
    //    self.giftView.frame = self.view.bounds;
    [self.view addSubview:self.giftView];
    
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startBtn setTitle:@"开始" forState:0];
    [self.startBtn addTarget:self action:@selector(startLoveAnimation) forControlEvents:UIControlEventTouchUpInside];
    self.startBtn.backgroundColor = [UIColor redColor];
    self.startBtn.layer.cornerRadius = 5;
    self.startBtn.layer.masksToBounds = YES;
    [self.giftView addSubview:self.startBtn];
    
    
    self.endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.endBtn setTitle:@"取消" forState:0];
    [self.endBtn addTarget:self action:@selector(endLoveAnimation) forControlEvents:UIControlEventTouchUpInside];
    self.endBtn.backgroundColor = [UIColor cyanColor];
    self.endBtn.layer.cornerRadius = 5;
    self.endBtn.layer.masksToBounds = YES;
    [self.giftView addSubview:self.endBtn];
    
    [self.giftView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(self.view.frame.size);
        make.center.equalTo(self.view);
    }];
    
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.giftView).with.offset(84); //有效
        make.right.equalTo(self.endBtn.mas_left).with.offset(-20);//OK
        make.left.equalTo(self.giftView).with.offset(20);//有效
        make.width.equalTo(self.endBtn);
        make.height.mas_equalTo(44);//有效
    }];
    
    [self.endBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.startBtn); //有效
        make.left.equalTo(self.startBtn.mas_right).with.offset(20); //OK
        make.right.equalTo(self.giftView).with.offset(-20);//有效
        make.height.equalTo(self.startBtn); //有效
        
    }];
    
    //初始化陀螺仪
    _motionMManager = [[CMMotionManager alloc] init];
    //设置陀螺仪
    [self setUpMotion];
    
    _isDropping = NO;
    self.dropsArray = [NSMutableArray array];
    
    // Do any additional setup after loading the view, typically from a nib.
}
// MARK: 心形开始
- (void)startLoveAnimation
{
    [self setUpMotion];
    NSLog(@"%s",__func__);
    UIImage *love = [UIImage imageNamed:@"love"];
    
    [self dropWithCount:30 images:@[love]];
    
    [self start];
}

- (NSMutableArray *)dropWithCount:(int)count images:(NSArray *)images
{
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < count; i++) {
        
        UIImage *image = [images objectAtIndex:rand()%[images count]];
        UIImageView * imageView =[[UIImageView alloc ]initWithImage:image];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.center = CGPointMake(50, 100);
        imageView.tag = 11;
        
        if (i%2 == 0) {
            imageView.center = CGPointMake(self.view.frame.size.width - 50, 100);
            imageView.tag = 22;
        }
        [viewArray addObject:imageView];
    }
    [self.dropsArray addObject:viewArray];
    return _dropsArray;
    
}

- (void)start
{
    if (_isDropping) return ;
    _isDropping = YES;
    dispatch_queue_t queue = dispatch_get_main_queue();
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));/**< 延迟一秒执行*/
    uint64_t interval = (uint64_t)(0.05 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        if (self.dropsArray.count == 0) return;
        NSMutableArray *currentDrops = self.dropsArray[0];
        
        if ([currentDrops count]) {
            
            if (currentDrops.count == 0) return;
            //拿到这个image
            UIImageView * dropView = currentDrops[0];
            [currentDrops removeObjectAtIndex:0];
            //添加到gifiView上面
            [self.giftView addSubview:dropView];
            
            //运动学push方式
            UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[dropView] mode:UIPushBehaviorModeInstantaneous];
            //添加到效果器中
            [self.animator addBehavior:pushBehavior];
            
            //角度范围 ［0.6 1.0］
            float random = ((int)(2 + (arc4random() % (10 - 4 + 1))))*0.1;
            
            pushBehavior.pushDirection = CGVectorMake(0.6,random);
            if (dropView.tag != 11) {
                pushBehavior.pushDirection = CGVectorMake(-0.6,random);
            }
            //连续力矢量
            pushBehavior.magnitude = 0.3;
            
            
            [self.gravityBehavior addItem:dropView];
            [self.collisionBehavitor addItem:dropView];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dropView.alpha = 0;
                [self.gravityBehavior removeItem:dropView];
                [self.collisionBehavitor removeItem:dropView];
                [pushBehavior removeItem:dropView];
                [self.animator removeBehavior:pushBehavior];
                [dropView removeFromSuperview];
            });
            
        }
        else{
            dispatch_source_cancel(self.timer);
            [self.dropsArray removeObject:currentDrops];
            _isDropping = NO;
            if (self.dropsArray.count) {
                [self start];
            }
        }
        
        
    });
    dispatch_source_set_cancel_handler(_timer, ^{
        
    });
    //启动
    dispatch_resume(self.timer);
}

// MARK: 心形结束
- (void)endLoveAnimation
{
    NSLog(@"%s",__func__);
    
    // 停止陀螺仪
    [_motionMManager stopAccelerometerUpdates];
    _isDropping = NO;
    if (_timer) { //停止定时器
        
        dispatch_cancel(_timer);
        _timer = nil;
    }
    //将添加到陀螺仪管理的效果引用的view删除掉
    for (UIDynamicBehavior *behavior in _animator.behaviors)
    {
        if (behavior == self.gravityBehavior)
        {
            for (UIImageView *v in self.gravityBehavior.items)
            {
                [self.gravityBehavior removeItem:v];
                if (v.superview)[v removeFromSuperview];
            }
            continue;
        }
        else if (behavior == self.collisionBehavitor)
        {
            for (UIImageView *v in self.collisionBehavitor.items) {
                [self.collisionBehavitor removeItem:v];
                if (v.superview)[v removeFromSuperview];
            }
            continue;
        }
        else [_animator removeBehavior:behavior];;
    }
    self.animator = nil;
    //清空数据
    [self.dropsArray removeAllObjects];
}

- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.giftView];
        
        // MARK: 重力效果
        self.gravityBehavior = [[UIGravityBehavior alloc] init];
        //        self.gravityBehavior.gravityDirection = CGVectorMake(0.5,1);
        // MARK: 碰撞效果
        self.collisionBehavitor = [[UICollisionBehavior alloc] init];
        //触碰边缘
        [self.collisionBehavitor setTranslatesReferenceBoundsIntoBoundary:YES];
        
        //添加效果
        [_animator addBehavior:self.gravityBehavior];
        [_animator addBehavior:self.collisionBehavitor];
        
    }
    return _animator;
}

- (void)setUpMotion
{
    if(_motionMManager.accelerometerAvailable)/// 检查传感器到底在设备上是否可用
    {
        if (!_motionMManager.accelerometerActive)
        {
            _motionMManager.accelerometerUpdateInterval = 1.0/3.0;
            // 告诉manager，更新频率是100Hz
            
            __unsafe_unretained typeof(self) weakSelf = self;
            [_motionMManager
             startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {        //push 的方式
                 
                 if (error)
                 {
                     NSLog(@"CoreMotion Error : %@",error);
                     [_motionMManager stopAccelerometerUpdates];
                 }
                 CGFloat a = accelerometerData.acceleration.x;
                 CGFloat b = accelerometerData.acceleration.y;
                 CGVector gravityDirection = CGVectorMake(a,-b);
                 weakSelf.gravityBehavior.gravityDirection = gravityDirection;
             }];
        }
        
    }
    else
    {
        NSLog(@"The accelerometer is unavailable");
    }
}

void testMasonry()
{
    //    UIView *view1 = [[UIView alloc] init];
    //    view1.backgroundColor = [UIColor redColor];
    //    [self.view addSubview:view1];
    //位置: CGRectMake(0,0,WIDTH,HEIGHT - 49);
    //第一种
    //    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.view).with.offset(64);
    //        make.bottom.equalTo(self.view).with.offset(-49);
    //        make.left.equalTo(self.view).with.offset(0);
    //        make.right.equalTo(self.view).with.offset(0);
    //    }];
    
    //第二种
    //    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    //
    //        make.left.and.right.mas_offset(0);
    //        make.top.equalTo(self.view).with.offset(64);
    //        make.bottom.equalTo(self.view).with.offset(-49);
    //    }];
    
    //第三种
    //    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    //
    //        make.center.equalTo(self.view);
    //        make.size.mas_equalTo(CGSizeMake(100, 100));
    //    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
