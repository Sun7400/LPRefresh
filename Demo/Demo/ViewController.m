//
//  ViewController.m
//  Demo
//
//  Created by FineexMac on 16/3/7.
//  Copyright © 2016年 iOS_LiuLiuLiu. All rights reserved.
//
//  作者GitHub主页 https://github.com/SwiftLiu
//  作者邮箱 1062014109@qq.com
//  下载链接 https://github.com/SwiftLiu/LPRefresh.git

#import "ViewController.h"
#import "LPRefresh/LPRefresh.h"

@interface ViewController ()
{
    __weak IBOutlet UITableView *table;
    __weak IBOutlet UIView *line;
    __weak IBOutlet UIScrollView *scollView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    line.frame = CGRectMake(0, 0, 600, 0.5);
    scollView.contentSize = CGSizeMake(scollView.bounds.size.width, scollView.bounds.size.height+1);
    
    //添加刷新控件
    [scollView addRefreshWithBlock:^{
        NSLog(@"刷新");
    }];
    
    [table addRefreshWithBlock:^{
        NSLog(@"刷新3");
    }];
}

- (IBAction)endRefresh:(UIButton *)sender {
    //结束刷新
    [scollView endRefreshing];
}

@end
