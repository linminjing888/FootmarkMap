//
//  UILabel+Color.h
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/25.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Color)

#pragma mark - 改变字的颜色
/**
 *  改变所有字段的颜色
 */
- (void)changeStrokeColorWithTextStrikethroughColor:(UIColor *)textStrokeColor;

/**
 改变句中某些字段的颜色
 
 @param textStrokeColor 改变的颜色
 @param text 改变的字段
 */
- (void)changeStrokeColorWithTextStrikethroughColor:(UIColor *)textStrokeColor changeText:(NSString *)text;

@end
