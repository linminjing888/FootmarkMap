//
//  LMJCollectionViewController.h
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/21.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMJProvinceModel;

@protocol LMJCollectionCityDelegate<NSObject>

- (void)collectionCityCount:(NSInteger)count Name:(NSString *)name;

@end

@interface LMJCollectionViewController : UIViewController

@property (nonatomic, weak) id<LMJCollectionCityDelegate>delegate;

@property (nonatomic, strong) LMJProvinceModel *provinceModel;

@end
