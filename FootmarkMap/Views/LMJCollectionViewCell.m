//
//  LMJCollectionCellCollectionViewCell.m
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/21.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import "LMJCollectionViewCell.h"
#import "LMJProvinceModel.h"

@interface LMJCollectionViewCell ()

@property (nonatomic, strong) UILabel *name;

@end

@implementation LMJCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = COLOR_BG;
        self.layer.cornerRadius = 5.0;
        self.clipsToBounds = YES;
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.name.font = [UIFont systemFontOfSize:13];
        self.name.numberOfLines = 0;
        self.name.adjustsFontSizeToFitWidth = YES;
        self.name.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.name];
    }
    return self;
}

- (void)setCityModel:(LMJCityModel *)cityModel {
    _cityModel = cityModel;
    self.name.text = _cityModel.name;
    if (_cityModel.isSelected) {
       self.backgroundColor = COLOR_YELLOW;
    }else{
       self.backgroundColor = COLOR_BG;
    }
}

@end
