//
//  LMJProvinceModel.m
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/22.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import "LMJProvinceModel.h"

@implementation LMJProvinceModel

+(NSDictionary*)mj_objectClassInArray {
    return @{@"city":NSStringFromClass([LMJCityModel class])};
}

+ (void)loadLocationInfo:(InfoCompleteBlock)complete {
    
    NSMutableArray *listArr = [NSMutableArray arrayWithCapacity:0];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LocationJson" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSArray *temArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    listArr = [LMJProvinceModel mj_objectArrayWithKeyValuesArray:temArray];
    complete([listArr copy],nil);
}

@end

@implementation LMJCityModel


@end
