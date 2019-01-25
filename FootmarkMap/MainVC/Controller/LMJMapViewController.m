//
//  LMJMapViewController.m
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/24.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import "LMJMapViewController.h"
#import "WGMapCommonView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UILabel+Color.h"

#define Color_Yellow [UIColor colorWithRed:247/255.0 green:290/255.0 blue:32/255.0 alpha:1]
static const CGFloat MapViewScale = 0.8;


@interface LMJMapViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) WGMapCommonView *mapView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation LMJMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.provinceArr.count == 0) {
        return;
    }
    
    [self setupUI];
}

- (void)setupUI {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveImage)];
    
    UIScrollView *bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, LSCREENW, LSCREENH)];
    bgScrollView.backgroundColor = COLOR_BG;
    bgScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:bgScrollView];
    
    if (@available(iOS 11.0, *)) {
        bgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 设置放大缩小的比例
    bgScrollView.multipleTouchEnabled = YES;//打开多指触控
    bgScrollView.maximumZoomScale = 2.0;
    bgScrollView.minimumZoomScale = 1.0;
    bgScrollView.zoomScale = 1.0;
    bgScrollView.delegate = self;
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, LSCREENW, LSCREENW)];
    bgView.center = CGPointMake(LSCREENW * 0.5, LSCREENH * 0.5);
    bgView.backgroundColor = [UIColor colorWithRed:70/255.0 green:113/255.0 blue:151/255.0 alpha:1];
    [self.view addSubview:bgView];
    
    NSString *provinceCount = [NSString stringWithFormat:@"%ld",self.provinceArr.count];
    NSString *cityCount = [NSString stringWithFormat:@"%ld",self.cityArr.count];
    UILabel *titleLabe = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LSCREENW, LSCREENW * 0.1)];
    titleLabe.text = [NSString stringWithFormat:@"踏足中国 %@ 个省区，%@ 个城市",provinceCount,cityCount];
    titleLabe.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabe];
    
    [titleLabe changeStrokeColorWithTextStrikethroughColor:Color_Yellow changeText:provinceCount];
    [titleLabe changeStrokeColorWithTextStrikethroughColor:Color_Yellow changeText:cityCount];
    
    //地图
    [bgView addSubview:self.mapView];
    
    UIImage *shareImage = [self getImageFromView:bgView];

    bgView.hidden = YES;

    UIImageView *imageView = [[UIImageView alloc]initWithImage:shareImage];
    imageView.bounds = CGRectMake(0, 0, LSCREENW, LSCREENW);
    imageView.center = self.view.center;
    [bgScrollView addSubview:imageView];
    self.imageView = imageView;

}

#pragma mark - Lazy
- (WGMapCommonView *)mapView {
    if (!_mapView) {
        _mapView = [[WGMapCommonView alloc] init];
        CGFloat scale = 0.62;
        _mapView.transform = CGAffineTransformMakeScale(scale, scale);//宽高伸缩比例
        _mapView.frame = CGRectMake(0, 0, LSCREENW, LSCREENW * MapViewScale);
        _mapView.center = CGPointMake(LSCREENW * 0.5, LSCREENW * 0.5);
        _mapView.pathFileName = @"ChinaMapPaths.plist";
        _mapView.infoFileName = @"provinceInfo.plist";
        _mapView.clickEnable = NO;
        _mapView.lineColor = [UIColor whiteColor];
        _mapView.backColorD = [UIColor colorWithWhite:0.8 alpha:1];
        _mapView.backColorH = Color_Yellow;
        _mapView.seletedAry = self.provinceArr;
        _mapView.nameColor = [UIColor blackColor];
    }
    return _mapView;
}

#pragma mark - UIScrollview delegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

// scrollView的contentSize会跟随这个子视图改变
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

/*
 * 截取view中的图片
 */
- (UIImage *)getImageFromView:(UIView *)orgView{
    
    UIGraphicsBeginImageContextWithOptions(orgView.bounds.size, orgView.opaque, 0);
    [orgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

#pragma mark - 保存图片到相册
- (void)saveImage {
    UIImage *saveImage = self.imageView.image;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(saveImage,
                                       self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error) {
        NSLog(@"保存失败");
    }
    else {
        NSLog(@"Success");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
