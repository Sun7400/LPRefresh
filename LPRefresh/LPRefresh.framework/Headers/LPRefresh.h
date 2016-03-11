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

/* ************** 缺点：
① 在UITableView调用reloadSections:withRowAnimation:这个方法时，该组件会出现一些小问题，请尽量使用reloadData来刷新对应的UITableView。有好多建议可以联系作者，谢谢！
************** */

// UIScrollView延展，UITableView也可用
@interface UIScrollView (LPRefresh)

///添加刷新组件，block为刷新执行闭包
- (void)addRefreshWithBlock:(void (^)())block;

///刷新成功
- (void)endRefreshingSuccess;
///刷新失败
- (void)endRefreshingFail;

@end
