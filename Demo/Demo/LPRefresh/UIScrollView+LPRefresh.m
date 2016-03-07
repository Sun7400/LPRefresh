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

#import "UIScrollView+LPRefresh.h"
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
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
}

#pragma mark - 添加刷新事件
- (void)addRefreshWithBlock:(void (^)())block
{
    //刷新主件
    self.indicator = [LPRefreshIndicator new];
    CGRect frame = self.indicator.frame;
    frame.origin.y = -frame.size.height;
    frame.size.width = self.bounds.size.width;
    self.indicator.frame = frame;
    
    //添加观察者，监听contentOffset
    [self addObserver:self
           forKeyPath:KEY_PATH
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:(__bridge void * _Nullable)(block)];
}

//监听实现
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:KEY_PATH]) {
        //获取offset
        CGPoint newPoint, oldPoint;
        [change[@"new"] getValue:&newPoint];
        [change[@"old"] getValue:&oldPoint];
        CGFloat new = -newPoint.y;
        CGFloat old = -oldPoint.y;
        
        //下拉进度
        if (new >= 0) self.indicator.pullProgress = new;
        
        //开始刷新
        if (new>=self.indicator.maxHeight && old<self.indicator.maxHeight) {
            void (^block)() = (__bridge void (^)())(context);
            if (block) block();
        }
    }
}

//移除观察者
- (void)dealloc
{
    [self removeObserver:self forKeyPath:KEY_PATH context:nil];
}

#pragma mark - 刷新
- (void)refresh
{
    
}

#pragma mark - 结束刷新
- (void)endRefreshing
{
    self.indicator.refreshing = NO;
    NSLog(@"结束刷新");
}

@end
