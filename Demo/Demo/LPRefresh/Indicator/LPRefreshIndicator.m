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

@implementation LPRefreshIndicator

#pragma mark - 设置状态
- (void)setRefreshing:(BOOL)refreshing
{
    if (!refreshing && _refreshing) {
        [indicatorView stopAnimating];
        [UIView animateWithDuration:0.5 animations:^{
            capionLabel.alpha = 1;
        } completion:^(BOOL finished) {
            //滚动到顶部
            [self superviewScrollTo:0];
        }];
    }
    else if (refreshing && !_refreshing) {
        //回弹动画
        [self animateHeight:self.maxHeight time:0.0005];
    }
    _refreshing = refreshing;
}

#pragma mark - 设置拉伸进度
- (void)setPullProgress:(CGFloat)pullProgress
{
    CGRect frame = self.frame;
    if (!self.refreshing) {
        //①开始拖出
        if (pullProgress <= self.minHeight) {
            if (pullProgress > _pullProgress) {
                capionLabel.alpha = 0;
                [self drawHeight:self.minHeight isBack:NO];
            }
        }
        //②拉伸阶段
        else if (pullProgress < self.maxHeight) {
            frame.size.height = pullProgress;
            frame.origin.y = -frame.size.height;
            [self drawHeight:pullProgress isBack:NO];
        }
        //③开始刷新动画
        else {
            self.refreshing = YES;
        }
    }else {
        //④高度不变
        if (pullProgress > self.maxHeight) {
            frame.size.height = self.maxHeight;
            frame.origin.y = -pullProgress;
        }
        //⑤高度减小
        else if (pullProgress > self.minHeight) {
            frame.size.height = pullProgress;
            frame.origin.y = -frame.size.height;
        }
        //⑥刷新状态下回弹需停顿
        else if (_pullProgress > self.minHeight) {
            [self superviewScrollTo:-self.minHeight];
            frame.size.height = self.minHeight;
            frame.origin.y = -frame.size.height;
        }
    }
    self.frame = frame;
    _pullProgress = pullProgress;
}

#pragma mark - 橡皮筋自动回弹动画
- (void)animateHeight:(CGFloat)animateH time:(NSTimeInterval)t
{
    //橡皮筋回弹
    if (animateH >= self.minHeight+15) {
        animateH -= 0.7;
        if (animateH <= self.minHeight+25) t += 0.0002;
        [self drawHeight:animateH isBack:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateHeight:animateH time:t];
        });
    }
    //显示指示器
    else{
        drawLayer.contents = nil;
        [indicatorView startAnimating];
    }
}

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
    CGFloat s = (h-self.minHeight) / (self.maxHeight-self.minHeight);
    
    // ①绘制橡皮筋部分
    //阴影颜色
    drawLayer.shadowColor = [UIColor colorWithWhite:0 alpha:.2+.8*s].CGColor;
    //填充颜色
    CGColorRef color = LPRefreshMainColor(1).CGColor;
    if (self.refreshing) color = LPRefreshMainColor(.2+.8*s).CGColor;
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
    CGPoint b1 = CGPointMake(-r, o.y);
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
        self.bounds = CGRectMake(0, 0, 0, self.minHeight);
        self.clipsToBounds = YES;
        //图层
        drawLayer = [CALayer layer];
        CGFloat wide = self.minHeight-2*LPRefreshMargin;
        drawLayer.frame = CGRectMake(0, 0, wide, self.maxHeight);
        [self.layer addSublayer:drawLayer];
        drawLayer.shadowRadius = 1;
        drawLayer.shadowOffset = CGSizeMake(0, 1);
        drawLayer.shadowOpacity = 0.1;
        
        //绘制大圆
        [self drawHeight:self.minHeight isBack:NO];
        
        //指示器
        indicatorView = [UIActivityIndicatorView new];
        indicatorView.center = CGPointMake(0, self.minHeight/2.l);
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
        //提示图标
        NSTextAttachment *attachment = [NSTextAttachment new];
        UIImage *img = [UIImage imageNamed:@"LPRefresh.bundle/LPRefresh_ok"];
        attachment.image = img;
        attachment.bounds = CGRectMake(0, -2, img.size.width, img.size.height);
        NSAttributedString *imgAttrStr = [NSAttributedString attributedStringWithAttachment:attachment];
        //提示文字
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@" 刷新成功"];
        [attrString insertAttributedString:imgAttrStr atIndex:0];
        capionLabel.attributedText = attrString;
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

- (CGFloat)maxHeight
{
    return 90;
}

- (CGFloat)minHeight
{
    return 36;
}

@end
