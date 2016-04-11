//
//  ZQPay.m
//  微信支付
//


#import "ZQPay.h"
#import "ReadMe.h"
#import "ZQUtil.h"
#import "ZQXMLHelper.h"
#import "ZQDevice.h"
#import "WXApi.h"
#import "WXApiObject.h"


@implementation ZQPay

/**
 *  通过微信支付
 *
 *  @param orderName 订单名
 *  @param price     价格
 */
+ (NSString *)payWXWithOrderName:(NSString *)orderName price:(NSString *)price tradeNo:(NSString *)tradeNo  attach:(NSString *)attach{
    // 获取预支付参数
    NSMutableDictionary *orderParas = [self createPreOrderParasWithOrderName:orderName price:price tradeNo:tradeNo  attach:attach];
    
    // 获取prepayId（预支付交易会话标识）
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:[self payWithPrepay:orderParas]];
    
    NSString *prepayID = dic[@"prepay_id"];
    
    if (prepayID != nil) {  // 预支付成功
        // 获取确认支付参数
        NSDictionary *signParas = [self createWXRequestParameterWith:prepayID];
        
        // 发起支付
        [self payWXWithDictionary:signParas];
        return @"success";
    }else{
        return dic[@"err_code_des"];
    }
    
}

/**
 *  获取预支付所需参数
 *
 *  @param orderName 订单名
 *  @param price     价格, 单位为分
 */
+ (NSMutableDictionary *)createPreOrderParasWithOrderName:(NSString *)orderName price:(NSString *)price  tradeNo:(NSString *)tradeNo attach:(NSString *)attach{
    //订单标题，展示给用户
    NSString *order_name = orderName;
    //订单金额,单位（分）
    NSString *order_price = price;//1分钱测试
    
    //================================
    //预付单参数订单设置
    //================================
    /*如果订单号可以自己需要自己生成 解开以下三句话，并把*/
   //    srand( (unsigned)time(0) );
//    NSString *orderno   = [NSString stringWithFormat:@"%ld",time(0)];
  //  tradeNo=orderno;
   NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    NSMutableDictionary *orderParas = [NSMutableDictionary dictionary];
    
    [orderParas setObject: ZQAppID           forKey:@"appid"];       //开放平台appid
    [orderParas setObject: ZQMchID           forKey:@"mch_id"];//商户号
    [orderParas setObject: @"APP-001"        forKey:@"device_info"]; //支付设备号或门店号
    [orderParas setObject: noncestr          forKey:@"nonce_str"];   //随机串
    [orderParas setObject: @"APP"            forKey:@"trade_type"];  //支付类型，固定为APP
    [orderParas setObject: order_name        forKey:@"body"];        //订单描述，展示给用户
    [orderParas setObject: ZQPayNotifyURL    forKey:@"notify_url"];  //支付结果异步通知
    [orderParas setObject: tradeNo           forKey:@"out_trade_no"];//商户订单号
    [orderParas setObject: [ZQDeVice deviceIPAdress]    forKey:@"spbill_create_ip"];//发起支付的机器ip
    [orderParas setObject: order_price       forKey:@"total_fee"];       //订单金额，单位为分
    [orderParas setObject:attach forKey:@"attach"];//订单详细描述
    
    return orderParas;
}

/**
 *  获取确认支付所需参数
 *
 *  @param prepayID 获取到的预支付标记
 */
+ (NSMutableDictionary *)createWXRequestParameterWith:(NSString *)prepayID {
    //获取到prepayid后进行第二次签名
    NSString    *package, *time_stamp, *nonce_str;
    
    //设置支付参数
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str	= [ZQUtil stringMd5WithString:time_stamp];
    
    // 重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
    // package       = [NSString stringWithFormat:@"Sign=%@",package];
    package         = @"Sign=WXPay";
    
    // 第二次签名参数列表
    NSMutableDictionary *signParas = [NSMutableDictionary dictionary];
    [signParas setObject: ZQAppID        forKey:@"appid"];
    [signParas setObject: nonce_str    forKey:@"noncestr"];
    [signParas setObject: package      forKey:@"package"];
    [signParas setObject: ZQMchID        forKey:@"partnerid"];
    [signParas setObject: time_stamp   forKey:@"timestamp"];
    [signParas setObject: prepayID     forKey:@"prepayid"];
    //[signParams setObject: @"MD5"       forKey:@"signType"];
    
    // 生成签名
    NSString *sign  = [self createMd5Sign:signParas];
    
    // 添加签名
    [signParas setObject: sign         forKey:@"sign"];
    
    return signParas;
}

/**
 *  获取支付所需的参数 : 预支付交易会话标识 "prepay_id"
 *
 *  @param prePayParams https://pay.weixin.qq.com/wiki/doc/api/app.php?chapter=9_1 官方文档所必须的参数
 *
 *  @return prepay_id
 */
+ (NSMutableDictionary *)payWithPrepay:(NSMutableDictionary *)prePayParams {
    NSString *prepayid = nil;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    //获取提交支付
    NSString *send = [self payParameterFormat:prePayParams];
    
    //发送请求post xml数据
    NSData *res = [ZQUtil httpSend:ZQPrePayURL method:@"POST" data:send];
    
    ZQXMLHelper *xml  = [[ZQXMLHelper alloc] init];
    //开始解析
    [xml startParse:res];
    NSMutableDictionary *resParams = [xml getDict];
    
    //判断返回
    NSString *return_code = [resParams objectForKey:@"return_code"];
    NSString *result_code = [resParams objectForKey:@"result_code"];
     NSString *codeDes = [resParams objectForKey:@"err_code_des"];
    if ( [return_code isEqualToString:@"SUCCESS"] )
    {
        //生成返回数据的签名
        NSString *sign      = [self createMd5Sign:resParams];
        NSString *send_sign =[resParams objectForKey:@"sign"] ;
        
        //验证签名正确性
        if( [sign isEqualToString:send_sign]){
            if( [result_code isEqualToString:@"SUCCESS"]) {
                //验证业务处理状态
                prepayid    = [resParams objectForKey:@"prepay_id"];
                return_code = 0;
            }
        }
    }
    [dic setValue:prepayid forKey:@"prepay_id"];
    [dic setValue:codeDes forKey:@"err_code_des"];
    return dic;
}

/**
 *  按照官方要求格式化参数
 *
 *  @param paras https://pay.weixin.qq.com/wiki/doc/api/app.php?chapter=4_3
 *
 *  @return 格式化的参数字典
 */
+ (NSString *)payParameterFormat:(NSMutableDictionary *)paras {
    NSString *sign;
    NSMutableString *reqPars = [NSMutableString string];
    
    //生成xml的package
    NSArray *keys = [paras allKeys];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in keys) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [paras objectForKey:categoryId],categoryId];
    }
    
    //生成签名,并将签名添加到签名包中
    sign = [self createMd5Sign:paras];
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    
    return [NSString stringWithString:reqPars];
}

/**
 *  按照官方要求生成签名
 *
 *  @param dict https://pay.weixin.qq.com/wiki/doc/api/app.php?chapter=4_3
 *
 *  @return 签名
 */
+ (NSString *)createMd5Sign:(NSMutableDictionary *)dict {
    NSMutableString *contentString = [NSMutableString string];
    NSArray *keys = [dict allKeys];
    // 按字母顺序排序, 官方要求参数必须按照参数名ASCII码从小到大排序（字典序）
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", ZQPartnerID];
    
    //返回得到MD5 sign签名
    return [ZQUtil stringMd5WithString:contentString];
}

/**
 *  发起支付
 *
 *  @param paras 支付相关信息
 */
+ (void)payWXWithDictionary:(NSDictionary *)paras {
    
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = [paras objectForKey:@"appid"];
    req.partnerId           = [paras objectForKey:@"partnerid"];
    req.prepayId            = [paras objectForKey:@"prepayid"];
    req.nonceStr            = [paras objectForKey:@"noncestr"];
    req.timeStamp           = [[paras objectForKey:@"timestamp"] intValue];
    req.package             = [paras objectForKey:@"package"];
    req.sign                = [paras objectForKey:@"sign"];
    
    // 发起微信支付
    [WXApi sendReq:req];
    //日志输出
  //     NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
}
@end
