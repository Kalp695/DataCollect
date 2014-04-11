//
//  NSString+EncodingUTF8Additions.m
//  DataCollect
//
//  Created by liucc on 14-1-10.
//  Copyright (c) 2014年 liucc. All rights reserved.
//

#import "NSString+EncodingUTF8Additions.h"

@implementation NSString (EncodingUTF8Additions)


-(NSString *)URLEncodingUTF8String{
    
    NSString *encodedXmlString=(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,%#[]"), kCFStringEncodingUTF8));

    return encodedXmlString;
}
-(NSString *)URLDecodingUTF8String{
    NSString *encodedXmlString=(NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR("!*'();:@&=+$,%#[]"), kCFStringEncodingUTF8));
    return encodedXmlString;
}

+ (NSString *)replaceUnicode:(NSString *)unicodeStr {
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"&#x" withString:@"\\U"];
    NSString *tempStrB=[tempStr1 stringByReplacingOccurrencesOfString:@";" withString:@""];
    NSString *tempStr2 = [tempStrB stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    //NSLog(@"Output = %@", returnStr);
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}
@end
