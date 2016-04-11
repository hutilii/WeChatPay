//
//  ZQDeVice.h
//  微信支付
//


#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
@interface ZQDeVice : NSObject

/**
 *  获取设备ip地址
 *
 *  @return ip
 */
+ (NSString *)deviceIPAdress;
@end
