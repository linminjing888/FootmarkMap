//
//  LMJCollectionCellCollectionViewCell.h
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/21.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMJProvinceModel.h"

#define kCellIdentifier_CollectionView @"CollectionViewCell"

@interface LMJCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) LMJCityModel *cityModel;

@end
