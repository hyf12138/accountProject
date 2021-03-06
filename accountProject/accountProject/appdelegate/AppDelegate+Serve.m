//
//  AppDelegate+Serve.m
//  accountProject
//
//  Created by 弘鼎 on 2017/12/29.
//  Copyright © 2017年 贺亚飞. All rights reserved.
//

#import "AppDelegate+Serve.h"
#import "DWTabBarController.h"
#import "SingleUser.h"

@implementation AppDelegate (Serve)
#pragma mark ————— 初始化window —————
-(void)initWindow{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = KWhiteColor;
    [self.window makeKeyAndVisible];
    [[UIButton appearance] setExclusiveTouch:YES];
    self.window.rootViewController = [[DWTabBarController alloc] init];;
    
    
}
-(SingleUser *)getusermodel{
    
    // 从本地（@"weather" 文件中）获取.
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"weather"];
    // data.
    NSData *data = [NSData dataWithContentsOfFile:file];
    // 反归档.
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    // 获取@"model" 所对应的数据
    SingleUser *usermodel = [unarchiver decodeObjectForKey:kUserinfoKey];
    // 反归档结束.
    [unarchiver finishDecoding];
    return usermodel;
}
//查看报警信息
- (void)checkWarningMessages{
    return;
    SingleUser *usermodel = [self getusermodel];
    NSDictionary *pareDic = @{@"account":usermodel.account};
    [[HttpRequest sharedInstance] postWithURLString:SearchWarningMagUrl parameters:pareDic success:^(id responseObject) {
        
        NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([Dic[@"success"] boolValue]) {
            NSString *numStr = Dic[@"number"];
            if ([numStr integerValue]>0) {
                DWTabBarController *tabbarVC = (DWTabBarController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
                [tabbarVC.tabBar.items[1] showBadge];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
    
    
}
@end
