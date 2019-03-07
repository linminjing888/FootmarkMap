//
//  LMJBaseNaviController.m
//  FootmarkMap
//
//  Created by MinJing_Lin on 2019/1/25.
//  Copyright © 2019 MinJing_Lin. All rights reserved.
//

#import "LMJBaseNaviController.h"

@interface LMJBaseNaviController ()

@end

@implementation LMJBaseNaviController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
 load是只要类所在文件被引用就会被调用,所以如果类没有被引用进项目，就不会有load调用；
 initialize是在类或者其子类的第一个方法被调用前调用。但即使类文件被引用进来，但是没有使用，那么initialize也不会被调用。
 */
+ (void)initialize {
    // 设置为不透明
    //    [[UINavigationBar appearance] setTranslucent:NO];
    // 设置导航栏背景颜色
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    
    // 设置导航栏标题文字颜色
    NSMutableDictionary * color = [NSMutableDictionary dictionary];
    color[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    color[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
    [[UINavigationBar appearance] setTitleTextAttributes:color];
    
    //1.获取当前类下全局的UIBarButtonItem, 这里的self指[MJBaseNaviController class]
    // 设置导航栏按钮文字颜色
    UIBarButtonItem * item = [UIBarButtonItem appearance];
    item.tintColor = [UIColor darkGrayColor];
    // 设置字典的字体大小
    NSMutableDictionary * atts = [NSMutableDictionary dictionary];
    atts[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    atts[NSForegroundColorAttributeName] = [UIColor darkGrayColor];;
    // 将字典给item
    [item setTitleTextAttributes:atts forState:UIControlStateNormal];
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
