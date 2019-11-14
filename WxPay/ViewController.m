//
//  ViewController.m
//  WxPay
//
//  Created by apple on 15/6/9.
//  Copyright (c) 2015年 tqh. All rights reserved.
//

#import "ViewController.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <AFNetworking/AFNetworking.h>


@interface ViewController ()<WXApiDelegate> {
//    enum WXScene _scene;
    NSString *Token;
    long token_time;
    NSString *_code;//用户换取access_token的code，仅在ErrCode为0时有效
    NSString*appId;
    NSString*appSecret;
    #define WX_OPEN_ID  @"WX_OPEN_ID"//
    #define WX_ACCESS_TOKEN @"WX_ACCESS_TOKEN" //
    #define WX_REFRESH_TOKEN  @"WX_REFRESH_TOKEN"//
    UILabel *cityLabel ;
    UILabel *countryLabel ;
    UILabel *languageLabel ;
    UILabel *nicknameLabel ;
    UILabel *provinceLabel ;
    UILabel *sexLabel ;
    UIImageView *headimgurl;
    
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    //微信支付
    UIButton *but2 = [[UIButton alloc]initWithFrame:CGRectMake(130, 140, 100, 40)];
    [but2 setTitle:@"微信登陆" forState:UIControlStateNormal];
    but2.backgroundColor = [UIColor lightGrayColor];
    [but2 addTarget:self action:@selector(wxLogin) forControlEvents:UIControlEventTouchUpInside];
    [but2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:but2];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxLogin:) name:@"wxLogin" object:nil];

    UILabel*city = [[UILabel alloc]initWithFrame:CGRectMake(100, 200, 40, 25)];
    city.text = @"城市";
    city.textColor = [UIColor blackColor];
    city.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:city];
    
    cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, 200,100, 25)];
    cityLabel.textColor = [UIColor blackColor];
    cityLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:cityLabel];
    
    UILabel*  country = [[UILabel alloc]initWithFrame:CGRectMake(100, 220, 40, 25)];
      country.text = @"国家";
      country.textColor = [UIColor blackColor];
      country.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:  country];
    
    countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, 220,100, 25)];
    countryLabel.textColor = [UIColor blackColor];
    countryLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:countryLabel];
    
    UILabel*language = [[UILabel alloc]initWithFrame:CGRectMake(100, 240, 40, 25)];
    language.text = @"语言";
    language.textColor = [UIColor blackColor];
    language.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:language];
    
    languageLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, 240,100, 25)];
    languageLabel.textColor = [UIColor blackColor];
    languageLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:languageLabel];
    
    UILabel*nickname = [[UILabel alloc]initWithFrame:CGRectMake(100, 260, 40, 25)];
    nickname.text = @"昵称";
    nickname.textColor = [UIColor blackColor];
    nickname.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:nickname];
    
    nicknameLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, 260,100, 25)];
    nicknameLabel.textColor = [UIColor blackColor];
    nicknameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:nicknameLabel];
    UILabel*province = [[UILabel alloc]initWithFrame:CGRectMake(100, 280, 40, 25)];
    province.text = @"省份";
    province.textColor = [UIColor blackColor];
    province.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:province];
    
    provinceLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, 280,100, 25)];
    provinceLabel.textColor = [UIColor blackColor];
    provinceLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:provinceLabel];
    
    UILabel*sex = [[UILabel alloc]initWithFrame:CGRectMake(100, 300, 40, 25)];
    sex.text = @"性别";
    sex.textColor = [UIColor blackColor];
    sex.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:sex];
    
    sexLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, 300,100, 25)];
    sexLabel.textColor = [UIColor blackColor];
    sexLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    [self.view addSubview:sexLabel];
    

    headimgurl = [[UIImageView alloc] initWithFrame:CGRectMake(150, 50, 80, 80)];
    [self.view addSubview:headimgurl];
    
    
    
}

- (void)wxLogin:(NSNotification*)noti{
    //获取到code
    SendAuthResp *resp = noti.object;
    
    NSLog(@"%@",resp.code);
  
    if (resp.errCode == 0) {
        _code = resp.code;
        appId =@"";
        appSecret =@"";
    }else{
        NSLog(@"%d",resp.errCode);
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"授权失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alter show];
    }
    

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=%@",appId,appSecret,_code,@"authorization_code"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSMutableSet *mgrSet = [NSMutableSet set];
    mgrSet.set = manager.responseSerializer.acceptableContentTypes;
    [mgrSet addObject:@"text/html"];
    //因为微信返回的参数是text/plain 必须加上 会进入fail方法
    [mgrSet addObject:@"text/plain"];
    [mgrSet addObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = mgrSet;

    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success");
        NSDictionary *resp = (NSDictionary*)responseObject;
        NSString *openid = resp[@"openid"];
        NSString *unionid = resp[@"unionid"];
        NSString *accessToken = resp[@"access_token"];
        NSString *refreshToken = resp[@"refresh_token"];
        if(accessToken && ![accessToken isEqualToString:@""] && openid && ![openid isEqualToString:@""]){
            [[NSUserDefaults standardUserDefaults] setObject:openid forKey:WX_OPEN_ID];
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:WX_ACCESS_TOKEN];
            [[NSUserDefaults standardUserDefaults] setObject:refreshToken forKey:WX_REFRESH_TOKEN];
            NSLog(@"%@---openid",openid);
            NSLog(@"%@---unionid",unionid);
            NSLog(@"%@---accessToken",accessToken);
            NSLog(@"%@---refreshToken",refreshToken);
            //命令直接同步到文件里，来避免数据的丢失
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self getUserInfo];


    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
    
}
- (void)getUserInfo{
    //获取个人信息
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",[[NSUserDefaults standardUserDefaults] objectForKey:WX_ACCESS_TOKEN],[[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID]];
    
    NSMutableSet *mgrSet = [NSMutableSet set];
    mgrSet.set = manager.responseSerializer.acceptableContentTypes;
    [mgrSet addObject:@"text/html"];
    //因为微信返回的参数是text/plain 必须加上 会进入fail方法
    [mgrSet addObject:@"text/plain"];
    [mgrSet addObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = mgrSet;
    
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success");
        
        NSLog(@"%@",responseObject);
        NSDictionary *resp = (NSDictionary*)responseObject;
        cityLabel.text = resp[@"city"];
        sexLabel.text = [resp[@"sex"] intValue] == 1 ? @"男" : @"女";
        countryLabel.text = resp[@"country"];
        languageLabel.text = resp[@"language"];
        nicknameLabel.text = resp[@"nickname"];
        provinceLabel.text = resp[@"province"];
        NSString *str =resp[@"headimgurl"];
        NSURL *photourl = [NSURL URLWithString:str];
        UIImage *images = [UIImage imageWithData:[NSData dataWithContentsOfURL:photourl]];//通过网络url获取uiimage
        headimgurl.image = images;
        
        [self.view layoutSubviews];
//        self->_nicknameLabel.text = resp[@"nickname"];
//        self->_sexLabel.text = [resp[@"sex"] intValue] == 1 ? @"男" : @"女";
//        self->_addressLabel.text = [NSString stringWithFormat:@"%@%@%@",resp[@"country"],resp[@"province"],resp[@"city"]];
//        [self showInfo];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"fail");
        NSLog(@"%@",task.response);
    }];
}
-(void)showInfo{
    
}
-(void)wxLogin{
    NSLog(@"123123");
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo";
    req.state = @"1";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
//    [WXApi sendAuthReq:req viewController:self delegate:self];
}

////微信支付
//- (void)wxpay
//{
//    //商户号
//    NSString *PARTNER_ID    = @"1900000109";
//    //商户密钥
//    NSString *PARTNER_KEY   = @"8934e7d15453e97507ef794cf7b0519d";
//    //APPID
//    NSString *APPI_ID       = @"wxd930ea5d5a258f4f";
//    //appsecret
//    NSString *APP_SECRET	= @"db426a9829e4b49a0dcac7b4162da6b6";
//    //支付密钥
//    NSString *APP_KEY       = @"L8LrMqqeGRxST5reouB0K66CaYAWpqhAVsq7ggKkxHCOastWksvuX1uvmvQclxaHoYd3ElNBrNO2DHnnzgfVG9Qs473M3DTOZug5er46FhuGofumV8H2FVR9qkjSlC5K";
//
//    //支付结果回调页面
//    NSString *NOTIFY_URL    = @"http://localhost/pay/wx/notify_url.asp";
//    //订单标题
//    NSString *ORDER_NAME    = @"Ios客户端签名支付 测试";
//    //订单金额,单位（分）
//    NSString *ORDER_PRICE   = @"1";
//
//    //创建支付签名对象
//    payRequsestHandler *req = [payRequsestHandler alloc];
//    //初始化支付签名对象
//    [req init:APPI_ID app_secret:APP_SECRET partner_key:PARTNER_KEY app_key:APP_KEY];
//
//    //判断Token过期时间，10分钟内不重复获取,测试帐号多个使用，可能造成其他地方获取后不能用，需要即时获取
//    time_t  now;
//    time(&now);
//    //if ( (now - token_time) > 0 )//非测试帐号调试请启用该条件判断
//    {
//        //获取Token
//        Token                   = [req GetToken];
//        //设置Token有效期为10分钟
//        token_time              = now + 600;
//        //日志输出
//        NSLog(@"获取Token： %@\n",[req getDebugifo]);
//    }
//    if ( Token != nil){
//        //================================
//        //预付单参数订单设置
//        //================================
//        NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
//        [packageParams setObject: @"WX"                                             forKey:@"bank_type"];
//        [packageParams setObject: ORDER_NAME                                        forKey:@"body"];
//        [packageParams setObject: @"1"                                              forKey:@"fee_type"];
//        [packageParams setObject: @"UTF-8"                                          forKey:@"input_charset"];
//        [packageParams setObject: NOTIFY_URL                                        forKey:@"notify_url"];
//        [packageParams setObject: [NSString stringWithFormat:@"%ld",time(0)]        forKey:@"out_trade_no"];
//        [packageParams setObject: PARTNER_ID                                        forKey:@"partner"];
//        [packageParams setObject: @"196.168.1.1"                                    forKey:@"spbill_create_ip"];
//        [packageParams setObject: ORDER_PRICE                                       forKey:@"total_fee"];
//
//        NSString    *package, *time_stamp, *nonce_str, *traceid;
//        //获取package包
//        package		= [req genPackage:packageParams];
//
//        //输出debug info
//        NSString *debug     = [req getDebugifo];
//        NSLog(@"gen package: %@\n",package);
//        NSLog(@"生成package: %@\n",debug);
//
//        //设置支付参数
//        time_stamp  = [NSString stringWithFormat:@"%ld", now];
//        nonce_str	= [TenpayUtil md5:time_stamp];
//        traceid		= @"mytestid_001";
//        NSMutableDictionary *prePayParams = [NSMutableDictionary dictionary];
//        [prePayParams setObject: APPI_ID                                            forKey:@"appid"];
//        [prePayParams setObject: APP_KEY                                            forKey:@"appkey"];
//        [prePayParams setObject: nonce_str                                          forKey:@"noncestr"];
//        [prePayParams setObject: package                                            forKey:@"package"];
//        [prePayParams setObject: time_stamp                                         forKey:@"timestamp"];
//        [prePayParams setObject: traceid                                            forKey:@"traceid"];
//
//        //生成支付签名
//        NSString    *sign;
//        sign		= [req createSHA1Sign:prePayParams];
//        //增加非参与签名的额外参数
//        [prePayParams setObject: @"sha1"                                            forKey:@"sign_method"];
//        [prePayParams setObject: sign                                               forKey:@"app_signature"];
//
//        //获取prepayId
//        NSString *prePayid;
//        prePayid            = [req sendPrepay:prePayParams];
//        //输出debug info
//        debug               = [req getDebugifo];
//        NSLog(@"提交预付单： %@\n",debug);
//
//        if ( prePayid != nil) {
//            //重新按提交格式组包，微信客户端5.0.3以前版本只支持package=Sign=***格式，须考虑升级后支持携带package具体参数的情况
//            //package       = [NSString stringWithFormat:@"Sign=%@",package];
//            package         = @"Sign=WXPay";
//            //签名参数列表
//            NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
//            [signParams setObject: APPI_ID                                          forKey:@"appid"];
//            [signParams setObject: APP_KEY                                          forKey:@"appkey"];
//            [signParams setObject: nonce_str                                        forKey:@"noncestr"];
//            [signParams setObject: package                                          forKey:@"package"];
//            [signParams setObject: PARTNER_ID                                       forKey:@"partnerid"];
//            [signParams setObject: time_stamp                                       forKey:@"timestamp"];
//            [signParams setObject: prePayid                                         forKey:@"prepayid"];
//
//            //生成签名
//            sign		= [req createSHA1Sign:signParams];
//
//            //输出debug info
//            debug     = [req getDebugifo];
//            NSLog(@"调起支付签名： %@\n",debug);
//
//            //调起微信支付
//            PayReq* req = [[PayReq alloc] init];
//            req.openID      = APPI_ID;
//            req.partnerId   = PARTNER_ID;
//            req.prepayId    = prePayid;
//            req.nonceStr    = nonce_str;
//            req.timeStamp   = now;
//            req.package     = package;
//            req.sign        = sign;
//            [WXApi safeSendReq:req];
//        }else{
//            /*long errcode = [req getLasterrCode];
//             if ( errcode == 40001 )
//             {//Token实效，重新获取
//             Token                   = [req GetToken];
//             token_time              = now + 600;
//             NSLog(@"获取Token： %@\n",[req getDebugifo]);
//             };*/
//            NSLog(@"获取prepayid失败\n");
//            [self alert:@"提示信息" msg:debug];
//        }
//    }else{
//        NSLog(@"获取Token失败\n");
//        [self alert:@"提示信息" msg:@"获取Token失败"];
//    }
//
//}

//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
}

//- (void)onReq:(BaseReq *)req {
//    NSLog(@"qwe123");
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
