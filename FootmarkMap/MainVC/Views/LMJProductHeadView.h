//
//  LMJProductHeadView.h
//  BeeQuick_One
//
//  Created by MinJing_Lin on 16/10/22.
//  Copyright © 2016年 MinJing_Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMJProductHeadView : UITableViewHeaderFooterView

+ (instancetype)headerCellWith:(UITableView *)tableView;

@property (nonatomic, copy) NSString *title;

@end
