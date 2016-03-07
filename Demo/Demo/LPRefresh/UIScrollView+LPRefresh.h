//
//  UIScrollView+LPRefresh.h
//  LPRefresh
//
//  Created by FineexMac on 16/3/2.
//  Copyright © 2016年 LPiOS. All rights reserved.
//
//  作者GitHub主页 https://github.com/SwiftLiu
//  作者邮箱 1062014109@qq.com
//  下载链接 https://github.com/SwiftLiu/LPRefresh.git

#import <UIKit/UIKit.h>
#import "LPRefreshIndicator.h"

@class LPRefreshIndicator;

@interface UIScrollView (LPRefresh)

//刷新主件
@property (strong, nonatomic) LPRefreshIndicator *indicator;

///添加刷新事件
- (void)addRefreshWithBlock:(void (^)())block;

///刷新
- (void)refresh;
///结束刷新
- (void)endRefreshing;

@end
