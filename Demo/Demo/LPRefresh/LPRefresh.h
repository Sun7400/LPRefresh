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

// UIScrollView延展，UITableView也可用
// 不建议使用模拟器运行，模拟器动画渲染效果不佳
@interface UIScrollView (LPRefresh)

///添加刷新事件
- (void)addRefreshWithBlock:(void (^)())block;

///刷新成功
- (void)endRefreshingSuccess;
///刷新失败
- (void)endRefreshingFail;

@end
