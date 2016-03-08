//
//  LPRefreshIndicator.h
//  LPRefresh
//
//  Created by FineexMac on 16/1/6.
//  Copyright © 2016年 LPiOS. All rights reserved.
//
//  作者GitHub主页 https://github.com/SwiftLiu
//  作者邮箱 1062014109@qq.com
//  下载链接 https://github.com/SwiftLiu/LPRefresh.git

#import <UIKit/UIkit.h>

///最小高度
#define MinHeight 36
///最大高度，即开始刷新的高度
#define MaxHeight 90

@interface LPRefreshIndicator : UIView
{
    //绘制视图
    CALayer *drawLayer;
    //指示器
    UIActivityIndicatorView *indicatorView;
    //提示标签
    UILabel *capionLabel;
    //执行控制
    BOOL shouldDo;
}

///状态
@property (assign, nonatomic) BOOL refreshing;
///下拉进度
@property (assign, nonatomic) CGFloat pullProgress;

///刷新结果
- (void)refreshSuccess:(BOOL)isSuccess;

@end
