//
//  AppDelegate.m
//  WxPay
//
//  Created by apple on 15/6/9.
//  Copyright (c) 2015年 tqh. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"
@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if([WXApi registerApp:@"wx3296b3afb8de42ce"]){
        //检测是否装了微信软件
              if ([WXApi isWXAppInstalled]){
                  NSLog(@"安装了");
              }else{
                  NSLog(@"没安装");
              }
           if ([WXApi isWXAppSupportApi]){
               NSLog(@"支持");
           }else{
               NSLog(@"不支持");
           }
           
    }
    
   
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//处理微信通过URL启动App时传递的数据

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp{
    if([resp isKindOfClass:[SendAuthResp class]]){
        SendAuthResp *resp2 = (SendAuthResp *)resp;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wxLogin" object:resp2];
    }else{
        NSLog(@"授权失败");
    }
//    NSString * wxPayResult;
//     if([resp isKindOfClass:[SendAuthResp class]]){
//           SendAuthResp *resp2 = (SendAuthResp *)resp;
//        switch(resp2.errCode){
//            case WXSuccess:
//                //服务器端查询支付通知或查询API返回的结果再提示成功
//                //                NSLog(@"支付成功");
//                //                [[QAlertView sharedInstance]showAlertText:@"支付成功" fadeTime:1.5f];
//                wxPayResult = @"success";
//                break;
//            default:
//                //                NSLog(@"支付失败，retcode=%d",resp.errCode);
//                wxPayResult = @"faile";
//                break;
//        }
//    }
}



@end
