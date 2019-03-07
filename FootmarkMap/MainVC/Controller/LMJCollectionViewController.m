//
//  LMJCollectionViewController.m
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/21.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import "LMJCollectionViewController.h"
#import "LMJCollectionViewCell.h"
#import "LMJProvinceModel.h"

static const CGFloat ColectionViewSpacingW = 10.0f;
static const CGFloat ColectionViewScale = 0.75;

@interface LMJCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView           *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray             *dataArray;

@end

@implementation LMJCollectionViewController

- (void)loadView {
    self.view = [[UIView alloc]initWithFrame:CGRectMake(LSCREENW * (1 - ColectionViewScale), 20, LSCREENW * ColectionViewScale, LSCREENH - 20)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionView DataSource Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMJCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_CollectionView forIndexPath:indexPath];
    LMJCityModel *model = self.dataArray[indexPath.row];
    cell.cityModel = model;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((LSCREENW * ColectionViewScale - ColectionViewSpacingW * 4) / 3, 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LMJCityModel *model = self.dataArray[indexPath.row];
    model.isSelected = !model.isSelected;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:indexPath.row inSection:0]]];
    
    __block NSInteger cityCount = 0;
    [self.dataArray enumerateObjectsUsingBlock:^(LMJCityModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelected == YES) {
            cityCount++;
        }
    }];
    [self.delegate collectionCityCount:cityCount Name:self.provinceModel.name];
}

#pragma mark getter/setter

- (void)setProvinceModel:(LMJProvinceModel *)provinceModel {
    _provinceModel = provinceModel;
    self.dataArray = [self.provinceModel.city mutableCopy];
    [self.collectionView reloadData];
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.minimumInteritemSpacing = ColectionViewSpacingW;
        _flowLayout.minimumLineSpacing = ColectionViewSpacingW;
        _flowLayout.sectionInset = UIEdgeInsetsMake(ColectionViewSpacingW, ColectionViewSpacingW, ColectionViewSpacingW, ColectionViewSpacingW);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        //注册cell
        [_collectionView registerClass:[LMJCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier_CollectionView];
    }
    return _collectionView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
