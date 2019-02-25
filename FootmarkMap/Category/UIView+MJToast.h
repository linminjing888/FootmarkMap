//
//  UIView+MJToast.h
//  MJToast
//
//  Created by YXCZ on 2017/11/21.
//  Copyright © 2017年 JingJing_Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const NSString * MJToastPositionTop;
extern const NSString * MJToastPositionCenter;
extern const NSString * MJToastPositionBottom;

@class MJToastStyle;
/**
 显示
 */
@interface UIView (MJToast)

-(void)makeToast:(NSString*)message;

-(void)makeToast:(NSString*)message
        duration:(NSTimeInterval)duration
        position:(id)position;

-(void)makeToast:(NSString*)message
        duration:(NSTimeInterval)duration
        position:(id)position
           style:(MJToastStyle*)style;

-(void)makeToast:(NSString*)message
        duration:(NSTimeInterval)duration
        position:(id)position
           title:(NSString*)title
           image:(UIImage*)image
           style:(MJToastStyle*)style
      completion:(void(^)(BOOL didTap))completion;

-(UIView*)toastViewForMessage:(NSString*)message
                        title:(NSString*)title
                        image:(UIImage*)image
                        style:(MJToastStyle*)style;


-(void)showToast:(UIView*)toast;

-(void)showToast:(UIView*)toast
        duration:(NSTimeInterval)duration
        position:(id)position
      completion:(void(^)(BOOL didTap))completion;



-(void)hideToast;

-(void)hideToast:(UIView*)toast;

-(void)hideAllToast;

-(void)hideAllToast:(BOOL)includeActivity clearQueue:(BOOL)clearQueue;

-(void)clearToastQueue;

/// 展示风火轮
-(void)makeToastActivity:(id)position;

/// 隐藏风火轮
-(void)hideToastActivity;

@end

/**
 风格样式
 */
@interface MJToastStyle: NSObject

/// 背景颜色  Default is `[UIColor blackColor]` at 80% opacity.
@property (strong, nonatomic) UIColor * backgroundColor;

/// 标题颜色 Default is `[UIColor whiteColor]`.
@property (strong, nonatomic) UIColor * titleColor;

/// 内容颜色 Default is `[UIColor whiteColor]`.
@property (strong, nonatomic) UIColor * messageColor;

/// 最大宽度占父视图宽度的百分比 Default is 0.8 (0.0 to 1.0)
@property (assign, nonatomic) CGFloat maxWidthPercentage;

/// 最大高度占父视图高度的百分比 Default is 0.8 (0.0 to 1.0)
@property (assign, nonatomic) CGFloat maxHeightPercentage;

/// 文本水平间隔 Default is 10.0.
@property (assign, nonatomic) CGFloat horizontalPadding;

/// 文本竖直间隔 Default is 10.0.
@property (assign, nonatomic) CGFloat verticalPadding;

/// 角半径 Default is 10.0.
@property (assign, nonatomic) CGFloat cornerRadius;

/// 标题字体 Default is `[UIFont boldSystemFontOfSize:16.0]`.
@property (strong, nonatomic) UIFont *titleFont;

/// 内容字体 Default is `[UIFont systemFontOfSize:16.0]`.
@property (strong, nonatomic) UIFont *messageFont;

/// 标题队列 Default is `NSTextAlignmentLeft`.
@property (assign, nonatomic) NSTextAlignment titleAlignment;

/// 内容队列 Default is `NSTextAlignmentLeft`.
@property (assign, nonatomic) NSTextAlignment messageAlignment;

/// 标题最大行数 The default is 0 (no limit).
@property (assign, nonatomic) NSInteger titleNumberOfLines;

/// 内容最大行数 The default is 0 (no limit).
@property (assign, nonatomic) NSInteger messageNumberOfLines;

/// 是否有阴影 Default is `NO`.
@property (assign, nonatomic) BOOL displayShadow;

/// 阴影颜色 Default is `[UIColor blackColor]`.
@property (strong, nonatomic) UIColor *shadowColor;

/// 阴影透明度 Default is 0.8（ 0.0 to 1.0）
@property (assign, nonatomic) CGFloat shadowOpacity;

/// 阴影角半径 Default is 6.0.
@property (assign, nonatomic) CGFloat shadowRadius;

/// The shadow offset The default is `CGSizeMake(4.0, 4.0)`.
@property (assign, nonatomic) CGSize shadowOffset;

/// 图片尺寸 The default is `CGSizeMake(80.0, 80.0)`.
@property (assign, nonatomic) CGSize imageSize;

/// the toast activity  Default is `CGSizeMake(100.0, 100.0)`.
@property (assign, nonatomic) CGSize activitySize;

/// 淡入/淡出动画持续时间 Default is 0.2.
@property (assign, nonatomic) NSTimeInterval fadeDuration;


/// 创建一个新的实例CSToastStyle 设置所有默认值。NS_DESIGNATED_INITIALIZER：指定初始化函数，进行完整的初始化并调用父类的init方法。
- (instancetype)initWithDefaultStyle NS_DESIGNATED_INITIALIZER;

/// 不可用 必须使用 NS_DESIGNATED_INITIALIZER 初始化 CSToastStyle 类
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 管理
 */
@interface MJToastManager: NSObject

/**
 设置风格单例
 */
+ (void)setSharedStyle:(MJToastStyle *)sharedStyle;

/**
 获取风格单例
 */
+ (MJToastStyle *)sharedStyle;

/**
 点击后，是否重叠出现 Default is `YES`.
 */
+ (void)setTapToDismissEnabled:(BOOL)tapToDismissEnabled;

/**
 如果点击后重叠出现，返回YES，否则返回NO. Default is `YES`.
 */
+ (BOOL)isTapToDismissEnabled;

/**
 排队出现，一个消失后，另一个才会出现 Default is `NO`. 不影响 the toast activity view
 */
+ (void)setQueueEnabled:(BOOL)queueEnabled;


/**
 获取是否排队出现，如果是，返回YES，否则返回NO.  Default is `NO`.
 */
+ (BOOL)isQueueEnabled;

/**
 设置默认时间  Default is 3.0.
 */
+ (void)setDefaultDuration:(NSTimeInterval)duration;

/**
 获取默认时间  Default is 3.0.
 */
+ (NSTimeInterval)defaultDuration;

/**
 设置默认位置  `makeToast:` and `showToast:` 不需要设置，默认为 ‘CSToastPositionBottom’

 @param position 默认为中心点，可能是预定义的 MJToastPosition,或者是“NSValue”对象的CGPoint
 */
+ (void)setDefaultPosition:(id)position;

/**
 获取默认位置  默认为 ‘CSToastPositionBottom’

 @return 默认为中心点，可能是预定义的 MJToastPosition,或者是“NSValue”对象的CGPoint
 */
+ (id)defaultPosition;
@end
