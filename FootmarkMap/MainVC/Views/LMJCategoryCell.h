//
//  LMJCategoryCell.h
//  BeeQuick_One
//
//  Created by MinJing_Lin on 16/10/22.
//  Copyright © 2016年 MinJing_Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMJProvinceModel;
@interface LMJCategoryCell : UITableViewCell

+ (instancetype)cellWithTable:(UITableView *)tableView;

@property (nonatomic, strong) LMJProvinceModel *provinceModel;

@end
