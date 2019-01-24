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

@interface LMJMapViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) WGMapCommonView *mapView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation LMJMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
    if (self.provinceArr.count == 0) {
        return;
    }
    
    [self setupUI];
}

- (void)setupUI {
    UIScrollView *bgScrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
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
    
    //地图
    self.mapView = [[WGMapCommonView alloc] init];
    CGFloat scale = 0.62;
    self.mapView.transform = CGAffineTransformMakeScale(scale, scale);//宽高伸缩比例
    self.mapView.frame = CGRectMake(0, 0, LSCREENW, LSCREENW * 0.8);
    self.mapView.center = CGPointMake(LSCREENW * 0.5, LSCREENW * 0.5);
    self.mapView.pathFileName = @"ChinaMapPaths.plist";
    self.mapView.infoFileName = @"provinceInfo.plist";
    self.mapView.clickEnable = NO;
    self.mapView.lineColor = [UIColor whiteColor];
    self.mapView.backColorD = [UIColor colorWithWhite:0.8 alpha:1];
    self.mapView.backColorH =  [UIColor colorWithRed:247/255.0 green:290/255.0 blue:32/255.0 alpha:1];
    self.mapView.seletedAry = self.provinceArr;
    self.mapView.nameColor = [UIColor blackColor];
    [self.view addSubview:_mapView];
    
    UIImage *shareImage = [self getImageFromView:self.mapView];
    
    self.mapView.hidden = YES;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:shareImage];
    imageView.bounds = CGRectMake(0, 0, LSCREENW, LSCREENW * 0.8);
    imageView.center = self.view.center;
    [bgScrollView addSubview:imageView];
    self.imageView = imageView;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(shareImage,
                                       self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    });
}

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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error) {
        if (error.code == ALAssetsLibraryWriteDiskSpaceError) {
            // 磁盘空间不足.
        }
        else if (error.code == ALAssetsLibraryDataUnavailableError) {
            // 没有相册访问权限.
        }
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
