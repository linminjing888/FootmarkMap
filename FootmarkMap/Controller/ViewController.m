//
//  ViewController.m
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/21.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import "ViewController.h"
#import "LMJCollectionViewController.h"
#import "CategoryCell.h"
#import "LMJProvinceModel.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,ProductsDelegate>

@property (nonatomic, strong) UITableView * categoriesTableView;
@property (nonatomic, strong) LMJCollectionViewController *productsController;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =COLOR_YELLOW;
    
    [self setUpcategoriesTableView];
    
    [self setUpProductsTableView];
    
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
        make.top.equalTo(self.view).offset(64);
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

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCell *cell = [CategoryCell cellWithTable:tableView];
    cell.provinceModel = self.dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.productsController.provinceModel = self.dataArray[indexPath.row];
}

#pragma mark - ProductsDelegate

- (void)willDislayHeaderView:(NSInteger)section {
    [self.categoriesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:section inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)didEndDislayHeaderView:(NSInteger)section {
    [self.categoriesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:section+1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

