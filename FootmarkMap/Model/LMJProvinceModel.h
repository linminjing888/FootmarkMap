//
//  LMJProvinceModel.h
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/22.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^InfoCompleteBlock)(NSArray *dataArr, NSError *error) ;

@interface LMJProvinceModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *city;

+ (void)loadLocationInfo:(InfoCompleteBlock)complete;

@end

@interface LMJCityModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *area;
/// 是否选中
@property (nonatomic, assign) BOOL isSelected;


@end
