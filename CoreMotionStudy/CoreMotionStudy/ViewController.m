//
//  ViewController.m
//  CoreMotionStudy
//
//  Created by 索晓晓 on 16/8/16.
//  Copyright © 2016年 SXiao.RR. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "LoveViewController.h"
#import "BubblingViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    UIButton *loveJet = [UIButton buttonWithType:UIButtonTypeCustom];
    [loveJet setTitle:@"心形喷射" forState:0];
    [loveJet addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
    loveJet.backgroundColor = [UIColor redColor];
    loveJet.layer.cornerRadius = 5;
    loveJet.layer.masksToBounds = YES;
    [self.view addSubview:loveJet];
    
    
    UIButton *bubbling = [UIButton buttonWithType:UIButtonTypeCustom];
    [bubbling setTitle:@"冒泡" forState:0];
    [bubbling addTarget:self action:@selector(bubbling) forControlEvents:UIControlEventTouchUpInside];
    bubbling.backgroundColor = [UIColor cyanColor];
    bubbling.layer.cornerRadius = 5;
    bubbling.layer.masksToBounds = YES;
    [self.view addSubview:bubbling];
    
    
    [loveJet mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view).with.offset(84);//有效
        make.height.mas_equalTo(44);
        make.left.equalTo(self.view).with.offset(20);
        make.right.equalTo(self.view).with.offset(-20);
        make.bottom.equalTo(bubbling.mas_top).with.offset(-20);
        
    }];
    
    [bubbling mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.and.right.and.height.equalTo(loveJet);
        make.top.equalTo(loveJet.mas_bottom).with.offset(20);
        
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)love
{
    LoveViewController *love = [[LoveViewController alloc] init];
    
    [self.navigationController pushViewController:love animated:YES];
}

- (void)bubbling
{
    BubblingViewController *bubbling = [[BubblingViewController alloc] init];
    
    [self.navigationController pushViewController:bubbling animated:YES];
}

//void testMasonry()
//{
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
    
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
