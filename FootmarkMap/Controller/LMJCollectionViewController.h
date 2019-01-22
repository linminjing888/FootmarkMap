//
//  LMJCollectionViewController.h
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/21.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMJProvinceModel;

@protocol ProductsDelegate<NSObject>

- (void)willDislayHeaderView:(NSInteger)section;
- (void)didEndDislayHeaderView:(NSInteger)section;

@end

@interface LMJCollectionViewController : UIViewController

@property (nonatomic, weak) id<ProductsDelegate>delegate;

@property (nonatomic, strong) LMJProvinceModel *provinceModel;

@end
