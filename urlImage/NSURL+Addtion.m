//
//  NSURL+Addtion.m
//  waterFlow
//
//  Created by liucc on 13-8-5.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "NSURL+Addtion.h"

@implementation NSURL (Addtion)

+(BOOL)isWebURL:(NSURL *)URL{
    if (!URL.scheme) {
        return  NO;
    }else{
        return [URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame
        || [URL.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame
        || [URL.scheme caseInsensitiveCompare:@"ftp"] == NSOrderedSame
        || [URL.scheme caseInsensitiveCompare:@"ftps"] == NSOrderedSame
        || [URL.scheme caseInsensitiveCompare:@"data"] == NSOrderedSame
        || [URL.scheme caseInsensitiveCompare:@"file"] == NSOrderedSame;
    }
}
@end
