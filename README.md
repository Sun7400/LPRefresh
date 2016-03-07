# LPRefresh
模仿QQ橡皮筋刷新的控件，动画流畅、渲染高效，只需一行代码

下载地址 https://github.com/SwiftLiu/LPRefresh.git

####初始化

    @interface UIScrollView (LPRefresh)
    ///添加刷新事件
    - (void)addRefreshWithBlock:(void (^)())block;


####结束刷新

    - (void)endRefreshing;
