//
//  UIScrollView+LPRefresh.m
//  LPRefresh
//
//  Created by FineexMac on 16/3/2.
//  Copyright © 2016年 LPiOS. All rights reserved.
//
//  作者GitHub主页 https://github.com/SwiftLiu
//  作者邮箱 1062014109@qq.com
//  下载链接 https://github.com/SwiftLiu/LPRefresh.git

#import "LPRefresh.h"
#import <objc/runtime.h>
#import "LPRefreshIndicator.h"

static NSString *KEY_PATH = @"contentOffset";

@implementation UIScrollView (LPRefresh)

#pragma mark - 属性getter和setter方法(rumtime机制)
static char LPRefreshIndicatorKey;
- (void)setIndicator:(LPRefreshIndicator *)indicator
{
    if (indicator != self.indicator) {
        [self.indicator removeFromSuperview];
        
        [self willChangeValueForKey:@"indicator"];
        objc_setAssociatedObject(self, &LPRefreshIndicatorKey,
                                 indicator,
                                 OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"indicator"];
        
        [self addSubview:indicator];
    }
}
- (LPRefreshIndicator *)indicator
{
    return objc_getAssociatedObject(self, &LPRefreshIndicatorKey);
}


#pragma mark - 重写
- (void)setFrame:(CGRect)frame
{
    if (self.frame.size.width != frame.size.width) {
        [self centerSub:frame.size.width];
    }
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
    if (self.bounds.size.width != bounds.size.width) {
        [self centerSub:bounds.size.width];
    }
    [super setBounds:bounds];
}
//indicator居中
- (void)centerSub:(CGFloat)width
{
    CGRect frame = self.indicator.frame;
    frame.size.width = width;
    frame.origin.x = (width - frame.size.width) / 2.l;
    self.indicator.frame = frame;
}


#pragma mark - 添加刷新事件
- (void)addRefreshWithBlock:(void (^)())block
{
    self.delaysContentTouches = NO;
    
    //刷新主件
    self.indicator = [LPRefreshIndicator new];
    CGRect frame = self.indicator.frame;
    frame.origin.y = -frame.size.height;
    frame.size.width = self.bounds.size.width;
    self.indicator.frame = frame;
    self.indicator.refreshBlock = block;
    
    //添加观察者，监听contentOffset
    [self addObserver:self
           forKeyPath:KEY_PATH
              options:NSKeyValueObservingOptionNew
              context:nil];
}

- (void)didChangeValueForKey:(NSString *)key
{
    //下拉进度
    if ([key isEqualToString:KEY_PATH] && self.contentOffset.y <= 0) {
        self.indicator.pullProgress = -self.contentOffset.y;
    }
}

//移除观察者
- (void)dealloc
{
//    [self removeObserver:self forKeyPath:KEY_PATH context:nil];
}


#pragma mark - 结束刷新
- (void)endRefreshingSuccess
{
    [self.indicator refreshSuccess:YES];
}

- (void)endRefreshingFail
{
    [self.indicator refreshSuccess:NO];
}

@end
