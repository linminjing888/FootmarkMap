//
//  ViewController.m
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/21.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import "LMJViewController.h"
#import "LMJCollectionViewController.h"
#import "LMJCategoryCell.h"
#import "LMJProvinceModel.h"
#import "LMJMapViewController.h"

@interface LMJViewController ()<UITableViewDelegate,UITableViewDataSource,LMJCollectionCityDelegate>

@property (nonatomic, strong) UITableView * categoriesTableView;
@property (nonatomic, strong) LMJCollectionViewController *productsController;
@property (nonatomic, strong) UIButton *commitBtn;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *provinceNameArr;
@property (nonatomic, strong) NSMutableArray *cityNameArr;

@end

@implementation LMJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR_BG;
    self.title = @"脚步地图";
    
    [self setUpcategoriesTableView];
    [self setUpProductsTableView];
    [self.view addSubview:self.commitBtn];
    
    [self loadData];
}

- (void)loadData {
    
    __weak __typeof(self) weakSelf = self;
    [LMJProvinceModel loadLocationInfo:^(NSArray *dataArr, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        if (dataArr.count == 0) {
            return;
        }
        strongSelf.dataArray = dataArr;
        [strongSelf.categoriesTableView reloadData];
        
        [strongSelf.categoriesTableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        strongSelf.productsController.provinceModel = dataArr[0];
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMJCategoryCell *cell = [LMJCategoryCell cellWithTable:tableView];
    cell.provinceModel = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.productsController.provinceModel = self.dataArray[indexPath.row];
    [self.categoriesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - ProductsDelegate

- (void)LMJCollectionCityCount:(NSInteger)count Name:(NSString *)name {
    [self.dataArray enumerateObjectsUsingBlock:^(LMJProvinceModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:name]) {
            obj.count = count;
            [self.categoriesTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:(UITableViewRowAnimationNone)];
            [self.categoriesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            *stop = YES;
        }
    }];
    
    [self reloaProvinceAndCityArray];
}

- (void)reloaProvinceAndCityArray {
    if (self.provinceNameArr.count != 0) {
        [self.provinceNameArr removeAllObjects];
    }
    if (self.cityNameArr.count != 0) {
        [self.cityNameArr removeAllObjects];
    }
    [self.dataArray enumerateObjectsUsingBlock:^(LMJProvinceModel *provinceModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (provinceModel.count > 0) {
            [self.provinceNameArr addObject:provinceModel.name];
            [provinceModel.city enumerateObjectsUsingBlock:^(LMJCityModel *cityModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if (cityModel.isSelected) {
                    [self.cityNameArr addObject:cityModel];
                }
            }];
        }
    }];
    if (self.cityNameArr.count > 0) {
        self.commitBtn.enabled = YES;
    }else{
        self.commitBtn.enabled = NO;
    }
}

- (void)commitBtnClicked {
    
    if (self.cityNameArr.count == 0) {
        return;
    }
    LMJMapViewController *mapVC = [[LMJMapViewController alloc]init];
    mapVC.provinceArr = [self.provinceNameArr copy];
    mapVC.cityArr = [self.cityNameArr copy];
    [self.navigationController pushViewController:mapVC animated:YES];
    
}

#pragma mark - setter/getter

- (void)setUpcategoriesTableView {
    self.categoriesTableView = ({
        UITableView *tabView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        tabView.delegate = self;
        tabView.dataSource = self;
        tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tabView.backgroundColor = COLOR_BG;
        tabView.showsVerticalScrollIndicator = NO;
        tabView;
    });
    [self.view addSubview:self.categoriesTableView];
    [self.categoriesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.leading.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.width.mas_equalTo(self.view).multipliedBy(0.25);
    }];
}

- (void)setUpProductsTableView {
    
    self.productsController = [[LMJCollectionViewController alloc]init];
    [self addChildViewController:self.productsController];
    [self.view addSubview:self.productsController.view];
    self.productsController.delegate =self;
}

- (UIButton *)commitBtn {
    if (!_commitBtn) {
        _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _commitBtn.frame = CGRectMake(LSCREENW * 0.3, LSCREENH-80, LSCREENW*0.65, 50);
        _commitBtn.backgroundColor = COLOR_BG;
        _commitBtn.layer.cornerRadius = 10.0f;
        _commitBtn.clipsToBounds = YES;
        [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commitBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_commitBtn setBackgroundImage:[UIImage lmj_createImageWithColor:COLOR_YELLOW] forState:UIControlStateNormal];
        [_commitBtn setBackgroundImage:[UIImage lmj_createImageWithColor:COLOR_BG] forState:UIControlStateDisabled];
        [_commitBtn addTarget:self action:@selector(commitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _commitBtn.enabled = NO;
    }
    return _commitBtn;
}

- (NSMutableArray *)provinceNameArr {
    if (!_provinceNameArr) {
        _provinceNameArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _provinceNameArr;
}

- (NSMutableArray *)cityNameArr {
    if (!_cityNameArr) {
        _cityNameArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _cityNameArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

