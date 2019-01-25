//
//  UILabel+Color.m
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/25.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import "UILabel+Color.h"

@implementation UILabel (Color)

#pragma mark - 改变字的颜色
- (void)changeStrokeColorWithTextStrikethroughColor:(UIColor *)textStrokeColor
{
    [self changeStrokeColorWithTextStrikethroughColor:textStrokeColor changeText:self.text];
}
- (void)changeStrokeColorWithTextStrikethroughColor:(UIColor *)textStrokeColor changeText:(NSString *)text {
    
    if (!text) {
        return;
    }
    NSMutableAttributedString *changeStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    if([self.text containsString:text]) {
        
        NSArray *commpentArr = [self.text componentsSeparatedByString:text];
        NSInteger location =0;
        for(int i=0; i < commpentArr.count-1; i++) {
            
            NSString*str = commpentArr[i];
            location += (i >0 ? (str.length+text.length):str.length);
            [changeStr addAttribute:NSForegroundColorAttributeName value:textStrokeColor range:NSMakeRange(location,text.length)];
        }
    }
    self.attributedText = changeStr;
    
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
//    NSRange textRange = [self.text rangeOfString:text options:NSCaseInsensitiveSearch];
//    if (textRange.location != NSNotFound) {
//        [attributedString addAttribute:NSForegroundColorAttributeName value:textStrokeColor range:textRange];
//    }
//    self.attributedText = attributedString;
    
}

@end
