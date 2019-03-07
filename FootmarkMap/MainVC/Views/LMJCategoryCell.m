//
//  LMJCategoryCell.m
//  BeeQuick_One
//
//  Created by MinJing_Lin on 16/10/22.
//  Copyright © 2016年 MinJing_Lin. All rights reserved.
//

#import "LMJCategoryCell.h"
#import "LMJProvinceModel.h"

@interface LMJCategoryCell()

@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIView      *yellowView;
@property (nonatomic, strong) UIView      *lineView;
@property (nonatomic, strong) UILabel     *numLabel;

@end

@implementation LMJCategoryCell

+ (instancetype)cellWithTable:(UITableView *)tableView {
    static NSString *cellId = @"CategoryCellID";
    LMJCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[LMJCategoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _backImageView = [[UIImageView alloc]init];
        _backImageView.image = [UIImage lmj_createImageWithColor:COLOR_BG];
        _backImageView.highlightedImage = [UIImage lmj_createImageWithColor:[UIColor whiteColor]];
        [self.contentView addSubview:_backImageView];
        
        _yellowView = [[UIView alloc]init];
        _yellowView.backgroundColor = COLOR_YELLOW;
        [self.contentView addSubview:_yellowView];
        
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = COLOR_Line;
        [self.contentView addSubview:_lineView];
        
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = kFont(14);
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.highlightedTextColor = [UIColor blackColor];
        [self.contentView addSubview:_nameLabel];
        
        _numLabel = [[UILabel alloc]init];
        _numLabel.backgroundColor = [UIColor redColor];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.font = kFont(12);
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.layer.cornerRadius = 8.0f;
        _numLabel.clipsToBounds = YES;
        [self.contentView addSubview:_numLabel];
        
        [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsMake(0, 0, 0, 20));
        }];
        [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-5);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(16, 16));
        }];
        [_yellowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.width.mas_equalTo(5);
        }];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.nameLabel.highlighted = selected;
    self.yellowView.hidden = !selected;
    self.backImageView.highlighted = selected;
}

- (void)setProvinceModel:(LMJProvinceModel *)provinceModel {
    _provinceModel = provinceModel;
    self.nameLabel.text = _provinceModel.name;
    if (provinceModel.count > 0) {
        self.numLabel.hidden = NO;
        self.numLabel.text = [NSString stringWithFormat:@"%ld",provinceModel.count];
    }else{
        self.numLabel.hidden = YES;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



@end
