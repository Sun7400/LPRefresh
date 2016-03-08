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
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:nil];
}

//监听实现
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:KEY_PATH]) {
        //获取offset
        CGPoint newPoint;
        [change[@"new"] getValue:&newPoint];
        CGFloat new = -newPoint.y;
        
        //下拉进度
        if (new >= 0) self.indicator.pullProgress = new;
    }
}

//移除观察者
- (void)dealloc
{
    [self removeObserver:self forKeyPath:KEY_PATH context:nil];
}

//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    if (self.indicator.refreshing) {
//        CGPoint offset = self.contentOffset;
//        offset.y = -MinHeight;
//        [self setContentOffset:offset animated:YES];//滚动
//    }
//}


#pragma mark - 结束刷新
- (void)endRefreshingSuccess
{
    [self.indicator refreshSuccess:YES];
    NSLog(@"刷新成功");
}

- (void)endRefreshingFail
{
    [self.indicator refreshSuccess:NO];
    NSLog(@"刷新失败");
}

@end
