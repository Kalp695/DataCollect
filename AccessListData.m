//
//  AccessListData.m
//  DataCollect
//
//  Created by liucc on 13-12-25.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "AccessListData.h"
#import "ListData.h"

@interface AccessListData()

@property(nonatomic,strong)NSFileManager *fileManager;
@property(nonatomic,strong)NSString *documentPath;
@property(nonatomic,strong)NSString *listPath;

@end

@implementation AccessListData
-(NSFileManager *)fileManager{
    if (!_fileManager) {
        _fileManager=[NSFileManager defaultManager];
    }
    return _fileManager;
}

-(NSString *)documentPath{
    if (!_documentPath) {
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentPath=[paths firstObject];
    }
    
    return _documentPath;
}
-(NSString *)listPath{
    if (!_listPath) {
        _listPath=[self.documentPath stringByAppendingPathComponent:@"list"];
    }
    return _listPath;
}

-(NSArray *)getDataArray{
    NSArray *dirs=[self.fileManager subpathsAtPath:self.documentPath];
    return dirs;
}

@end
