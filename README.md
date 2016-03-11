# LPRefresh
模仿QQ橡皮筋刷新的控件，动画流畅、渲染高效。UIScrollView延展，只需一行代码。

####演示
![演示](https://github.com/SwiftLiu/LPRefresh/blob/master/movie_LPRefresh.gif?raw=true)

####使用说明
######安装
[下载](https://github.com/SwiftLiu/LPRefresh.git)压缩包，将.frmaework和.bundle文件，直接导入工程。

![演示](https://github.com/SwiftLiu/LPRefresh/blob/master/guide.png?raw=true)

若该静态库无法引用请自行设置framework搜索路径。

同时Demo中也提供源代码，如果有好的建议需要交流，请发邮件到作者邮箱1062014109@qq.com。

######初始化
```objc 
// UIScrollView延展，UITableView也可用
@interface UIScrollView (LPRefresh)
///添加刷新事件
- (void)addRefreshWithBlock:(void (^)())block;
```
######结束刷新
```objc
///刷新成功
- (void)endRefreshingSuccess;
///刷新失败
- (void)endRefreshingFail;
```
