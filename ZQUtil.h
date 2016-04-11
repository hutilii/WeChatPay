//
//  ZQUtil.h
//  微信支付
//

#import <Foundation/Foundation.h>

@interface ZQUtil : NSObject

/*
 加密实现MD5和SHA1
 */
+ (NSString *)stringMd5WithString:(NSString *)str;
+ (NSString *)stringSha1WithString:(NSString *)str;


/**
 实现http GET/POST 解析返回的json数据
 */
+ (NSData *)httpSend:(NSString *)url method:(NSString *)method data:(NSString *)data;



@end
