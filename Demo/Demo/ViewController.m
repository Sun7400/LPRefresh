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
#import "UIScrollView+LPRefresh.h"

@interface ViewController ()
{
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
        NSLog(@"开始刷新");
    }];
}


- (IBAction)success:(id)sender {
    //刷新成功
    [scollView endRefreshingSuccess];
}

- (IBAction)fail:(id)sender {
    //刷新失败
    [scollView endRefreshingFail];
}


@end
