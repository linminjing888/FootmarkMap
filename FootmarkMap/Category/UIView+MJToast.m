//
//  UIView+MJToast.m
//  MJToast
//
//  Created by YXCZ on 2017/11/21.
//  Copyright © 2017年 JingJing_Lin. All rights reserved.
//

#import "UIView+MJToast.h"
#import <objc/runtime.h>

//----------------------- 位置------------------
NSString * MJToastPositionTop                       = @"MJToastPositionTop";
NSString * MJToastPositionCenter                    = @"MJToastPositionCenter";
NSString * MJToastPositionBottom                    = @"MJToastPositionBottom";

//----------------------- Runtime Toast views 关联键值------------------
static const NSString * MJToastCompletionKey        = @"MJToastCompletionKey";
static const NSString * MJToastDurationKey          = @"MJToastDurationKey";
static const NSString * MJToastPositionKey          = @"MJToastDurationKey";
static const NSString * MJToastTimerKey             = @"MJToastDurationKey";

//----------------------- Runtime self views 关联键值------------------
static const NSString * MJToastActiveKey            =  @"MJToastActiveKey";
static const NSString * MJToastQueueKey             =  @"MJToastQueueKey";
static const NSString * MJToastActivityViewKey          = @"MJToastActivityViewKey";

@interface UIView (ToastPrivate)

/**
 私有方法 以“MJ”为前缀，避免与其他命名方法冲突，简化API
 */
-(void)mj_showToast:(UIView*)toast duration:(NSTimeInterval)duration position:(id)position;

-(void)mj_hideToast:(UIView*)toast;
-(void)mj_hideToast:(UIView*)toast fromTap:(BOOL)fromTap;
-(void)mj_toastTimerDidFinish:(NSTimer*)timer;
-(void)mj_handleToastTapped:(UITapGestureRecognizer*)recognizer;

-(CGPoint)mj_centerPointForPositon:(id)point withToast:(UIView*)toast;

@end


@implementation UIView (MJToast)

#pragma mark - Make Toast Methods

-(void)makeToast:(NSString*)message{
    [self makeToast:message duration:[MJToastManager defaultDuration] position:[MJToastManager defaultPosition] style:nil];
}
-(void)makeToast:(NSString*)message
        duration:(NSTimeInterval)duration
        position:(id)position{
    [self makeToast:message duration:duration position:position style:nil];
}

-(void)makeToast:(NSString*)message
        duration:(NSTimeInterval)duration
        position:(id)position
           style:(MJToastStyle*)style{
    
    UIView * toast = [self toastViewForMessage:message title:nil image:nil style:style];
    [self showToast:toast duration:duration position:position completion:nil];
}

-(void)makeToast:(NSString*)message
        duration:(NSTimeInterval)duration
        position:(id)position
           title:(NSString*)title
           image:(UIImage*)image
           style:(MJToastStyle*)style
      completion:(void(^)(BOOL didTap))completion{
    UIView * toast = [self toastViewForMessage:message title:title image:image style:style];
    [self showToast:toast duration:duration position:position completion:completion];
}

#pragma mark - Show Toast Methods
-(void)showToast:(UIView*)toast{
    [self showToast:toast duration:[MJToastManager defaultDuration] position:[MJToastManager defaultPosition] completion:nil];
}
/// 显示 Toast 视图
-(void)showToast:(UIView*)toast duration:(NSTimeInterval)duration position:(id)position completion:(void(^)(BOOL didTap))completion{
    
    if (toast == nil) {
        return;
    }
    /**
     id object : 表示关联者，是一个对象
     const void key: 获取被关联者的索引key
     id value : 被关联者
     objc_AssociationPolicy policy : 关联时采用的协议，有assign，retain，copy等协议，一般使用OBJC_ASSOCIATION_RETAIN_NONATOMIC
     */
    objc_setAssociatedObject(toast, &MJToastCompletionKey, completion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([MJToastManager isQueueEnabled] && [[self mj_activeToasts]count]>0) {
//        //注： 另外一种方式，屏幕已经出现toast时，点击无反应，可以在这处理
//        NSLog(@"点击无反应");
        
        // toast 动态绑定时间和位置
        objc_setAssociatedObject(toast, &MJToastDurationKey, @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(toast, &MJToastPositionKey, position, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        /// enqueue
        [[self mj_toastQuene] addObject:toast];
    }else{
        [self mj_showToast:toast duration:duration position:position];
    }
}

#pragma mark - Hide Toast Methods

-(void)hideToast{
    [self hideToast:[[self mj_activeToasts]firstObject]];
}

-(void)hideToast:(UIView*)toast{
    if (!toast || ![[self mj_activeToasts]containsObject:toast]) {
        return;
    }
    [self mj_hideToast:toast];
}

-(void)hideAllToast{
    [self hideAllToast:NO clearQueue:YES];
}

-(void)hideAllToast:(BOOL)includeActivity clearQueue:(BOOL)clearQueue{
    if (clearQueue) {
        [self clearToastQueue];
    }
    for (UIView * toast in [self mj_activeToasts]) {
        [self hideToast:toast];
    }
    
    if (includeActivity) {
        [self hideToastActivity];
    }
}

-(void)clearToastQueue{
    [[self mj_toastQuene]removeAllObjects];
}

#pragma mark - Private Show/Hide Methods
-(void)mj_showToast:(UIView*)toast duration:(NSTimeInterval)duration position:(id)position{
    toast.center = [self mj_centerPointForPositon:position withToast:toast];
    toast.alpha = 0;
    
    if ([MJToastManager isTapToDismissEnabled]) {
        UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mj_handleToastTapped:)];
        [toast addGestureRecognizer:recognizer];
        toast.userInteractionEnabled = YES;
        /** 接受事件时的排他性,
         当UIView的exclusiveTouch属性设置为YES时，UIView可以独占当前窗口的touch事件。在手指离开屏幕之前，其他视图都无法触发touch事件。
         */
        toast.exclusiveTouch = YES;
    }
    [[self mj_activeToasts]addObject:toast];
    [self addSubview:toast];
    
    [UIView animateWithDuration:[[MJToastManager sharedStyle]fadeDuration]
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         toast.alpha = 1.0;
    }
                     completion:^(BOOL finished) {
                         NSTimer * timer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(mj_toastTimerDidFinish:) userInfo:toast repeats:NO];
                         [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
                         objc_setAssociatedObject(toast, &MJToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
    
}
-(void)mj_hideToast:(UIView*)toast{
    [self mj_hideToast:toast fromTap:NO];
}
-(void)mj_hideToast:(UIView*)toast fromTap:(BOOL)fromTap{
    
    NSTimer * timer = (NSTimer*)objc_getAssociatedObject(toast, &MJToastTimerKey);
    [timer invalidate];
    
    [UIView animateWithDuration:[[MJToastManager sharedStyle]fadeDuration]
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toast.alpha = 0.0;
    }
                     completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                         
                         [[self mj_activeToasts]removeObject:toast];
                         
                         void (^completion)(BOOL didTap) = objc_getAssociatedObject(toast, &MJToastCompletionKey);
                         if (completion) {
                             completion(fromTap);
                         }
                         
                         //dequeue 出队列
                         if ([[self mj_toastQuene]count] > 0) {
                             UIView * nextToast = [[self mj_toastQuene]firstObject];
                             [[self mj_toastQuene]removeObjectAtIndex:0];
                             
                             // 展示 toast 
                             NSTimeInterval duration = [objc_getAssociatedObject(nextToast, &MJToastDurationKey)doubleValue];
                             id position = objc_getAssociatedObject(nextToast, &MJToastPositionKey);
                             [self mj_showToast:nextToast duration:duration position:position];
                             
                         }
                     }];
}
#pragma mark - Storage 存储
/// 所有要显示的toasts数组
-(NSMutableArray*)mj_activeToasts{
    NSMutableArray * mj_activeToasts = objc_getAssociatedObject(self, &MJToastActiveKey);
    if (mj_activeToasts == nil) {
        mj_activeToasts = [[NSMutableArray alloc]init];
        objc_setAssociatedObject(self, &MJToastActiveKey, mj_activeToasts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mj_activeToasts;
}

/// 排队显示的toasts数组 enqueue
-(NSMutableArray*)mj_toastQuene{
    NSMutableArray * mj_toastQuene = objc_getAssociatedObject(self, &MJToastQueueKey);
    if (mj_toastQuene == nil) {
        mj_toastQuene = [[NSMutableArray alloc]init];
        objc_setAssociatedObject(self, &MJToastQueueKey, mj_toastQuene, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mj_toastQuene;
}

#pragma mark - Events
-(void)mj_toastTimerDidFinish:(NSTimer*)timer{
    [self mj_hideToast:(UIView*)timer.userInfo];
}

-(void)mj_handleToastTapped:(UITapGestureRecognizer*)recognizer{
    UIView * toast = recognizer.view;
    NSTimer * timer = (NSTimer*)objc_getAssociatedObject(toast, &MJToastTimerKey);
    [timer invalidate];
    
    [self mj_hideToast:toast fromTap:YES];
}

#pragma mark - Helpers

/**
 获取toast的位置中心点
 */
-(CGPoint)mj_centerPointForPositon:(id)point withToast:(UIView*)toast{
    MJToastStyle * style = [MJToastManager sharedStyle];
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0,*)) {
        safeInsets = self.safeAreaInsets;
    }
    
    CGFloat topPadding = style.verticalPadding + safeInsets.top;
    CGFloat bottomPadding = style.verticalPadding + safeInsets.bottom;
    
    if ([point isKindOfClass:[NSString class]]) {
        if ([point caseInsensitiveCompare:MJToastPositionTop]==NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2.0, topPadding + (toast.frame.size.height / 2.0));
        }else if ([point caseInsensitiveCompare:MJToastPositionCenter]==NSOrderedSame){
            return CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        }
    }else if ([point isKindOfClass:[NSValue class]]){
        return [point CGPointValue];
    }
    
    // 默认 bottom
    return CGPointMake(self.bounds.size.width / 2.0, (self.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding);
}

#pragma mark - Activity Methods
-(void)makeToastActivity:(id)position{
    
    UIView * existingActivityView = (UIView*)objc_getAssociatedObject(self, &MJToastActivityViewKey);
    if (existingActivityView != nil) { /// 如果上次的仍存在，不作处理
        return;
    }
    MJToastStyle * style = [MJToastManager sharedStyle];
    
    UIView * activityView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, style.activitySize.width, style.activitySize.height)];
    activityView.center = [self mj_centerPointForPositon:position withToast:activityView];
    activityView.backgroundColor = style.backgroundColor;
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = style.cornerRadius;
    
    if (style.displayShadow) {
        activityView.layer.shadowColor = style.shadowColor.CGColor;
        activityView.layer.shadowOpacity = style.shadowOpacity;
        activityView.layer.shadowRadius = style.shadowRadius;
        activityView.layer.shadowOffset = style.shadowOffset;
    }
    
    UIActivityIndicatorView * activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height /2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    objc_setAssociatedObject(self, &MJToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addSubview:activityView];
    
    [UIView animateWithDuration:style.fadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        activityView.alpha = 1.0;
    } completion:nil];
}

-(void)hideToastActivity{
    UIView * existingActivityView = (UIView*)objc_getAssociatedObject(self, &MJToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:[[MJToastManager sharedStyle]fadeDuration]
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
            existingActivityView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [existingActivityView removeFromSuperview];
            
            objc_setAssociatedObject(self, &MJToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];
    }
}

#pragma mark - View Construction
/// 返回 Toast 完整视图
-(UIView*)toastViewForMessage:(NSString*)message title:(NSString*)title image:(UIImage*)image style:(MJToastStyle*)style{
    if (message == nil && title == nil && image == nil) {
        return nil;
    }
    if (style == nil) {
        style = [MJToastManager sharedStyle];
    }
    // 动态创建控件
    UILabel * messageLabel = nil;
    UILabel * titleLabel = nil;
    UIImageView * imageView = nil;
    
    /// 包裹视图
    UIView * wrapperView = [[UIView alloc]init];
    /// IOS有两大自动布局利器：autoresizing 和 autolayout（autolayout是IOS6以后新增
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = style.cornerRadius;
    
    /// 阴影判断
    if (style.displayShadow) {
        wrapperView.layer.shadowColor = style.shadowColor.CGColor;
        wrapperView.layer.shadowOpacity = style.shadowOpacity;
        wrapperView.layer.shadowRadius = style.shadowRadius;
        wrapperView.layer.shadowOffset = style.shadowOffset;
    }
    wrapperView.backgroundColor = style.backgroundColor;
    
//----------------------- 设置控件------------------
    
    if (image != nil) {
        imageView = [[UIImageView alloc]initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(style.horizontalPadding, style.verticalPadding, style.imageSize.width, style.imageSize.height);
    }
    /// 图片尺寸
    CGRect imageRect = CGRectZero;
    
    if (imageView != nil) {
        imageRect.origin.x = style.horizontalPadding;
        imageRect.origin.y = style.verticalPadding;
        imageRect.size.width = imageView.bounds.size.width;
        imageRect.size.height = imageView.bounds.size.height;
    }
    
    if (title != nil) {
        titleLabel = [[UILabel alloc]init];
        titleLabel.numberOfLines = style.titleNumberOfLines;
        titleLabel.font = style.titleFont;
        titleLabel.textAlignment = style.titleAlignment;
        titleLabel.textColor = style.titleColor;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;
        
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * style.maxWidthPercentage)-imageRect.size.width, self.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeTitle = [titleLabel sizeThatFits:maxSizeTitle];
        // 当行数为1的时候 防止返回尺寸超过最大尺寸
        expectedSizeTitle = CGSizeMake(MIN(maxSizeTitle.width, expectedSizeTitle.width), MIN(maxSizeTitle.height, expectedSizeTitle.height));
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }
    /// 标题尺寸
    CGRect titleRect = CGRectZero;
    
    if (titleLabel != nil) {
        titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding;
        titleRect.origin.y = style.verticalPadding;
        titleRect.size.width = titleLabel.bounds.size.width;
        titleRect.size.height = titleLabel.bounds.size.height;
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc]init];
        messageLabel.numberOfLines = style.messageNumberOfLines;
        messageLabel.font = style.messageFont;
        messageLabel.textAlignment = style.messageAlignment;
        messageLabel.textColor = style.messageColor;
        messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * style.maxWidthPercentage)-imageRect.size.width, self.bounds.size.height * style.maxHeightPercentage);
        //1、sizeThatFits方法会返回最适合内容的当前接收者的宽度和高度，但是不会改变当前接收者的frame。
        // 2、sizeToFit方法会返回最适合内容的当前接收者的宽度和高度，会直接改变当前接收者的frame；
        CGSize expectedSizeMessage = [messageLabel sizeThatFits:maxSizeMessage];
        // 当行数为1的时候 防止返回尺寸超过最大尺寸
        expectedSizeMessage = CGSizeMake(MIN(maxSizeMessage.width, expectedSizeMessage.width), MIN(maxSizeMessage.height, expectedSizeMessage.height));
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }
    
    /// 内容尺寸
    CGRect messageRect = CGRectZero;
    if (messageLabel !=nil) {
        messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding;
        messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding;
        messageRect.size.width = messageLabel.bounds.size.width;
        messageRect.size.height = messageLabel.bounds.size.height;
    }
    
    CGFloat longerWidth = MAX(titleRect.size.width,messageRect.size.width);
    CGFloat longerX = MAX(titleRect.origin.x, messageRect.origin.x);
    
    CGFloat wrapperWidth = MAX(imageRect.size.width + (style.horizontalPadding * 2.0), (longerX + longerWidth + style.horizontalPadding));
    CGFloat wrapperHeight = MAX((messageRect.origin.y + messageRect.size.height + style.verticalPadding), (imageRect.size.height + (style.verticalPadding * 2.0)));
    
    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);

//----------------------- 添加控件------------------
    
    if (titleLabel != nil) {
        titleLabel.frame = titleRect;
        [wrapperView addSubview:titleLabel];
    }
    
    if (messageLabel != nil) {
        messageLabel.frame = messageRect;
        [wrapperView addSubview:messageLabel];
    }
    
    if (imageView != nil) {
        [wrapperView addSubview:imageView];
    }
    
    return wrapperView;
}
@end

@implementation MJToastStyle

-(instancetype)initWithDefaultStyle{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
        self.titleColor = [UIColor whiteColor];
        self.messageColor = [UIColor whiteColor];
        self.maxWidthPercentage = 0.8;
        self.maxHeightPercentage = 0.8;
        self.horizontalPadding = 10.0;
        self.verticalPadding = 10.0;
        self.cornerRadius = 10.0;
        self.titleFont = [UIFont boldSystemFontOfSize:16.0];
        self.messageFont = [UIFont systemFontOfSize:16.0];
        self.titleAlignment = NSTextAlignmentLeft;
        self.messageAlignment = NSTextAlignmentLeft;
        self.titleNumberOfLines = 0;
        self.messageNumberOfLines = 0;
        self.displayShadow = NO;
        self.shadowOpacity = 0.8;
        self.shadowRadius = 6.0;
        self.shadowOffset = CGSizeMake(4.0, 4.0);
        self.imageSize = CGSizeMake(80.0, 80.0);
        self.activitySize = CGSizeMake(100.0, 100.0);
        self.fadeDuration = 0.2;
    }
    return self;
}
-(void)setMaxWidthPercentage:(CGFloat)maxWidthPercentage{
    _maxWidthPercentage = MAX(MIN(maxWidthPercentage, 1.0), 0.0);
}
-(void)setMaxHeightPercentage:(CGFloat)maxHeightPercentage{
    _maxHeightPercentage = MAX(MIN(maxHeightPercentage, 1.0), 0.0);
}
@end

@interface MJToastManager()

@property (strong, nonatomic) MJToastStyle * shareStyle;
/**
 为了语意更明确，自定义访问器的名字：如
 @property (nonatomic,getter = isHidden ) BOOL hidden;
 */
@property (assign, nonatomic,getter=isTapToDismissEnabled) BOOL tapToDismissEnabled;
@property (assign, nonatomic,getter=isQueueEnabled) BOOL queueEnabled;
@property (assign, nonatomic) NSTimeInterval defaultDuration;
@property (strong, nonatomic) id defaultPosition;

@end
@implementation MJToastManager

#pragma mark --- 构造函数
+(instancetype)shareManager{
    static MJToastManager * _shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [[self alloc]init];
    });
    return _shareManager;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        self.shareStyle = [[MJToastStyle alloc]initWithDefaultStyle];
        self.tapToDismissEnabled = YES;
        self.queueEnabled = NO;
        self.defaultDuration = 3.0;
        self.defaultPosition = MJToastPositionBottom;
    }
    return self;
}
#pragma mark --- 单例方法

+(void)setSharedStyle:(MJToastStyle *)sharedStyle{
    [[self shareManager]setShareStyle:sharedStyle];
}

+(MJToastStyle*)sharedStyle{
    return [[self shareManager]shareStyle];
}

+(void)setTapToDismissEnabled:(BOOL)tapToDismissEnabled{
    [[self shareManager]setTapToDismissEnabled:tapToDismissEnabled];
}

+(BOOL)isTapToDismissEnabled{
    return [[self shareManager] isTapToDismissEnabled];
}

+(void)setQueueEnabled:(BOOL)queueEnabled{
    [[self shareManager]setQueueEnabled:queueEnabled];
}

+(BOOL)isQueueEnabled{
    return [[self shareManager]isQueueEnabled];
}

+ (void)setDefaultDuration:(NSTimeInterval)duration {
    [[self shareManager] setDefaultDuration:duration];
}

+ (NSTimeInterval)defaultDuration {
    return [[self shareManager] defaultDuration];
}

+ (void)setDefaultPosition:(id)position {
    if ([position isKindOfClass:[NSString class]] || [position isKindOfClass:[NSValue class]]) {
        [[self shareManager] setDefaultPosition:position];
    }
}

+ (id)defaultPosition {
    return [[self shareManager] defaultPosition];
}



@end
