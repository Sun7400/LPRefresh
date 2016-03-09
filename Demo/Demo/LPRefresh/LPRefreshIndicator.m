//
//  LPRefreshIndicator.m
//  LPRefresh
//
//  Created by FineexMac on 16/1/6.
//  Copyright © 2016年 LPiOS. All rights reserved.
//
//  作者GitHub主页 https://github.com/SwiftLiu
//  作者邮箱 1062014109@qq.com
//  下载链接 https://github.com/SwiftLiu/LPRefresh.git

#import "LPRefreshIndicator.h"

#define LPRefreshMainColor(_alpha) [UIColor colorWithWhite:0.7 alpha:_alpha]

const CGFloat LPRefreshMargin = 3;
const NSTimeInterval LPRefreshAnimateDuration = 0.5;

@interface LPRefreshIndicator ()
{
    //绘制视图
    CALayer *drawLayer;
    //指示器
    UIActivityIndicatorView *indicatorView;
    //提示标签
    UILabel *capionLabel;
    //状态
    BOOL refreshing;
    //执行控制
    BOOL shouldDo;
    
    //是否在进行回弹动画
    BOOL backing;
    //回弹动画结束立即执行结束的动画
    void (^backCompleteBlock)();
}
@end

@implementation LPRefreshIndicator

#pragma mark - 设置拉伸进度
- (void)setPullProgress:(CGFloat)pullProgress
{
    CGRect frame = self.frame;
    if (!refreshing) {
        //①开始拖出
        if (pullProgress <= MinHeight) {
            if (_pullProgress<=0 && pullProgress>_pullProgress) {
                shouldDo = YES;
                capionLabel.alpha = 0;
                [self drawHeight:MinHeight isBack:NO];//绘制圆
            }
        }
        //②拉伸阶段
        else if (pullProgress < MaxHeight) {
            frame.size.height = pullProgress;
            frame.origin.y = -frame.size.height;
            if (shouldDo) [self drawHeight:pullProgress isBack:NO];//绘制橡皮筋
        }
        //③开始刷新
        else {
            if (shouldDo) {
                shouldDo = NO;
                refreshing = YES;
                if (_refreshBlock) _refreshBlock();//执行刷新代码
                [self animateHeight:MaxHeight time:0.0005];//回弹动画
            }
            //高度不变
            frame.size.height = MaxHeight;
            frame.origin.y = -pullProgress;
        }
    }else {
        //④高度不变
        if (pullProgress > MaxHeight) {
            frame.size.height = MaxHeight;
            frame.origin.y = -pullProgress;
        }
        //⑤高度减小
        else if (pullProgress > MinHeight) {
            frame.size.height = pullProgress;
            frame.origin.y = -frame.size.height;
        }
        //⑥刷新状态下回弹需停顿
        else if (_pullProgress > MinHeight) {
            [self superviewScrollTo:-MinHeight];//滚动
            frame.size.height = MinHeight;
            frame.origin.y = -frame.size.height;
        }
    }
    self.frame = frame;
    _pullProgress = pullProgress;
}

#pragma mark - 橡皮筋自动回弹动画
- (void)animateHeight:(CGFloat)animateH time:(NSTimeInterval)t
{
    backing = YES;//回弹动画执行中
    //橡皮筋回弹
    if (animateH >= MinHeight+15) {
        animateH -= 0.7;
        if (animateH <= MinHeight+25) t += 0.0002;
        [self drawHeight:animateH isBack:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateHeight:animateH time:t];
        });
    }
    //显示指示器
    else{
        drawLayer.contents = nil;
        [indicatorView startAnimating];
        
        backing = NO;//回弹动画执行结束
        if (backCompleteBlock) {
            backCompleteBlock();
            backCompleteBlock = nil;
        }
    }
}

#pragma mark - 结束刷新
- (void)refreshSuccess:(BOOL)isSuccess
{
    if (refreshing) {
        //正在进行回弹动画时，结束动画放在回弹动画结束后执行
        if (backing) {
            __weak LPRefreshIndicator *weakSelf = self;
            backCompleteBlock = ^{
                refreshing = NO;
                [weakSelf endAnimate:isSuccess];
            };
        }
        //未进行回弹动画时，直接执行结束动画
        else {
            refreshing = NO;
            [self endAnimate:isSuccess];
        }
    }
}

//结束动画
- (void)endAnimate:(BOOL)isSuccess
{
    UIImage *img;//提示图标
    NSString *capion;//提示文字
    if (isSuccess) {
        img = [UIImage imageNamed:@"LPRefresh.bundle/LPRefresh_ok"];
        capion = @"刷新成功";
    }else{
        img = [UIImage imageNamed:@"LPRefresh.bundle/LPRefresh_fail"];
        capion = @"刷新失败";
    }
    //提示图标
    NSTextAttachment *attachment = [NSTextAttachment new];
    attachment.image = img;
    attachment.bounds = CGRectMake(0, -2, img.size.width, img.size.height);
    NSAttributedString *imgAttrStr = [NSAttributedString attributedStringWithAttachment:attachment];
    //提示文字
    NSString *str = [NSString stringWithFormat:@" %@", capion];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
    [attrString insertAttributedString:imgAttrStr atIndex:0];
    capionLabel.attributedText = attrString;
    
    //结束动画
    [indicatorView stopAnimating];
    [UIView animateWithDuration:0.6 animations:^{
        capionLabel.alpha = 1;
    } completion:^(BOOL finished) {
        if (_pullProgress==MinHeight) [self superviewScrollTo:0];//滚动到顶部
    }];
}

#pragma mark - 绘制
- (void)drawHeight:(CGFloat)h isBack:(BOOL)isBack
{
    if (h == _pullProgress) return;
    //初始化画布
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = drawLayer.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    //拉伸度
    CGFloat s = (h-MinHeight) / (MaxHeight-MinHeight);
    
    // ①绘制橡皮筋部分
    //阴影颜色
    drawLayer.shadowColor = [UIColor colorWithWhite:0 alpha:.4+.6*s].CGColor;
    //填充颜色
    CGColorRef color = LPRefreshMainColor(1).CGColor;
    if (refreshing) color = LPRefreshMainColor(.4+.6*s).CGColor;
    CGContextSetFillColorWithColor(ctx, color);
    //大圆半径
    CGFloat w = size.width / 2.l;
    CGFloat R;
    if (isBack) R = w*.7;
    else R = w - w*.3*s;
    //坐标移动至大圆圆心
    CGContextTranslateCTM(ctx, w, w+LPRefreshMargin);
    //小圆半径
    CGFloat r;
    if (isBack) r = R*.5 - (R*.5-3)*s;
    else r = w - (w-3)*s;
    //小圆圆心
    CGPoint o = CGPointMake(0, h-w-r-LPRefreshMargin*2);
    //各曲线交点
    double agl = M_PI_2 / 9.l;
    CGPoint a1 = CGPointMake(-R*cos(agl), R*sin(agl));
    CGPoint a2 = CGPointMake(-a1.x, a1.y);
//    CGPoint b1 = CGPointMake(-r, o.y);
    CGPoint b2 = CGPointMake(r, o.y);
    //贝塞尔曲线控制点
    CGPoint c1 = CGPointMake(-r, o.y/2.l);
    CGPoint c2 = CGPointMake(-c1.x, c1.y);
    //路径
    CGContextMoveToPoint(ctx, a2.x, a2.y);
    CGContextAddArc(ctx, 0, 0, R, agl, 2*M_PI+agl, NO);
    CGContextAddQuadCurveToPoint(ctx, c2.x, c2.y, b2.x, b2.y);
    CGContextAddArc(ctx, o.x, o.y, r, 0, M_PI, NO);
    CGContextAddQuadCurveToPoint(ctx, c1.x, c1.y, a1.x, a1.y);
    //绘制路径
    CGContextDrawPath(ctx, kCGPathFill);
    
    // ②绘制图片
    UIImage *image = [UIImage imageNamed:@"LPRefresh.bundle/LPRefresh_pull"];
    CGFloat wide = 2*R*0.7l;
    CGRect frame = CGRectMake(-wide/2.l, -wide/2.l, wide, wide);
    //旋转坐标系
    CGContextRotateCTM(ctx, s * M_PI*1.5);
    [image drawInRect:frame];
    
    //提取绘制图像
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(ctx);
    CGContextRelease(ctx);
    UIGraphicsEndImageContext();
    drawLayer.contents = (__bridge id _Nullable)(img.CGImage);
}


#pragma mark - 重写
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bounds = CGRectMake(0, 0, 0, MinHeight);
        self.clipsToBounds = YES;
        
        //图层
        drawLayer = [CALayer layer];
        CGFloat wide = MinHeight-2*LPRefreshMargin;
        drawLayer.frame = CGRectMake(0, 0, wide, MaxHeight);
        [self.layer addSublayer:drawLayer];
        drawLayer.shadowRadius = 1;
        drawLayer.shadowOffset = CGSizeMake(0, 1);
        drawLayer.shadowOpacity = 0.1;
        
        //绘制大圆
        [self drawHeight:MinHeight isBack:NO];
        
        //指示器
        indicatorView = [UIActivityIndicatorView new];
        indicatorView.center = CGPointMake(0, MinHeight/2.l);
        indicatorView.color = [UIColor grayColor];
        [self addSubview:indicatorView];
        
        //提示标签
        capionLabel = [UILabel new];
        capionLabel.bounds = CGRectMake(0, 0, 300, 30);
        capionLabel.center = indicatorView.center;
        capionLabel.alpha = 0;
        capionLabel.textColor = [UIColor colorWithWhite:.45 alpha:1];
        capionLabel.textAlignment = NSTextAlignmentCenter;
        capionLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:capionLabel];
    }
    return self;
}

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


//drawLayer居中
- (void)centerSub:(CGFloat)width
{
    CGRect frame = drawLayer.frame;
    frame.origin.x = (width - frame.size.width) / 2.l;
    drawLayer.frame = frame;
    
    CGPoint center = indicatorView.center;
    center.x = width / 2.l;
    indicatorView.center = center;
    capionLabel.center = center;
}


#pragma mark - 辅助方法
//滚动
- (void)superviewScrollTo:(CGFloat)offsetY
{
    UIScrollView *scrollView = (UIScrollView *)[self superview];
    if (scrollView) {
        CGPoint offset = scrollView.contentOffset;
        offset.y = offsetY;
        [scrollView setContentOffset:offset animated:YES];
    }
}

@end
