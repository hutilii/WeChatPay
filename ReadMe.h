//
//  ReadMe.h
//

#ifndef ReadMe_h
#define ReadMe_h
/**
 * 
 1.在做微信支付以前导入
    libc++.tbd
    libsqlite3.0.tbd
    libz.tbd
    SystemConfiguration.framework
    CoreTelephony.framework
    Security.framework
 导入以后在ReadMe.h中填写相关信息
 2.在AppDelegate 的
 导入头文件 #import "WXApi.h" 挂上代理 WXApiDelegate
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{} 写下
 [WXApi registerApp:@"APPID" withDescription:@"应用描述"];
 
添加系统方法(直接复制就可以)
 - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
 return  [WXApi handleOpenURL:url delegate:self];
 }
 
 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
 
 return [WXApi handleOpenURL:url delegate:self];
 }
 
 
 #pragma mark 微信回调代理方法
 - (void)onResp:(BaseResp *)resp {
 if ([resp isKindOfClass:[PayResp class]]) {
 PayResp *response = (PayResp *)resp;
 switch (response.errCode) {
 case WXSuccess:
 NSLog(@"suceess");
 break;
 default:
 NSLog(@"failed");
 break;
 }
 }
 }
 3. 在targets中info中添加 urltypes添加一个
 在 identifier自己起一个名称(最好软件英文名字) 在 URL schemes 中写下APPID
 4.支付按钮调用 
[ZQPay payWXWithOrderName:@"订单名称" price:@"价格" tradeNo:订单号码 attach:@"订单描述"];
  
 
 */



//APPID 一般以wx开头
static NSString *const ZQAppID = @"APPID";
//appsecret
static NSString *const ZQAppSecret = @"appsecret";
//商户号，填写商户对应参数
static NSString *const ZQMchID = @"商户号";
//商户API密钥，填写相应参数
static NSString *const ZQPartnerID = @"商户API密钥";

// 预支付请求路径固定可以不改变
static NSString *const ZQPrePayURL = @"https://api.mch.weixin.qq.com/pay/unifiedorder";
// // 支付回调页面(异步)（https://api.mch.weixin.qq.com/pay/unifiedorder）（异步处理支付调用返回数据）
static NSString *const ZQPayNotifyURL = @"支付回调页面";
// 获取服务器端支付数据地址(自定义)
static NSString *const ZQPayURL = @"https://custom";
#endif /* ReadMe_h */
