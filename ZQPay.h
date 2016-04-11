//
//  ZQPay.h
//  微信支付
//


#import <Foundation/Foundation.h>

@interface ZQPay : NSObject

/**
 *  通过微信支付
 *
 *  @param orderName 订单名
 *  @param price     价格
 */
+ (NSString *)payWXWithOrderName:(NSString *)orderName price:(NSString *)price tradeNo:(NSString *)tradeNo  attach:(NSString *)attach;

@end
