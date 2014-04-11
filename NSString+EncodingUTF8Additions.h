//
//  NSString+EncodingUTF8Additions.h
//  DataCollect
//
//  Created by liucc on 14-1-10.
//  Copyright (c) 2014年 liucc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EncodingUTF8Additions)


-(NSString *) URLEncodingUTF8String;//编码
-(NSString *) URLDecodingUTF8String;//解码
+ (NSString *)replaceUnicode:(NSString *)unicodeStr;


@end
