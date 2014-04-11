//
//  GetTemplateInfo.m
//  DataCollect
//
//  Created by liucc on 14-1-2.
//  Copyright (c) 2014年 liucc. All rights reserved.
//

#import "GetTemplateInfo.h"
#import "TFHpple.h"
#import <DDXML.h>
#import <DDXMLElementAdditions.h>
@implementation GetTemplateInfo


//-(void)accessInfo{
//    NSString *path=[[NSBundle mainBundle]pathForResource:@"t_sjyfi_vssb" ofType:@"xml"];
//    NSString *text=[[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"%@",text);
//    
//}
//-(NSMutableArray *)getDataArray{
//    NSMutableArray *templateInfoArray;
//    NSString *sourcePath=[[NSBundle mainBundle]pathForResource:@"t_sjyfi_vssb" ofType:@"xml"];
//    NSString *sourceText=[[NSString alloc]initWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//    NSData *sourceData=[sourceText dataUsingEncoding:NSUTF8StringEncoding];
//
//    TFHpple *xpathParse=[[TFHpple alloc]initWithXMLData:sourceData];
//    NSArray *elements=[xpathParse searchWithXPathQuery:@"//item"];
//    for (TFHppleElement *item in elements) {
//        TemplateInfo *data =[[TemplateInfo alloc]init];
//        NSArray *itemInfoArray=item.children;
//        NSMutableArray *itemDetailArray=[[NSMutableArray alloc]init];
//        for (int i=0; i<itemInfoArray.count; i++) {
//            TFHppleElement *itemDetail=[itemInfoArray objectAtIndex: i];
//            NSLog(@"%@=%@",itemDetail.firstTextChild.tagName, itemDetail.firstTextChild.content);
//        }
//    }
//
//    return templateInfoArray;
//}


+ (GetTemplateInfo *)templateAccess
{
    static GetTemplateInfo *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

-(NSMutableArray *)getDataArray{
    NSMutableArray *templateInfoArray=[[NSMutableArray alloc]init];

    
    NSString *sourcePath=[[NSBundle mainBundle]pathForResource:@"t_sjyfi_vssb" ofType:@"xml"];
    NSData *sourceData=[NSData dataWithContentsOfFile:sourcePath];
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:sourceData options:0 error:nil];
    


    
    //利用XPath来定位节点（XPath是XML语言中的定位语法，类似于数据库中的SQL功能）
    NSArray *items = [xmlDoc nodesForXPath:@"//item" error:nil];
    for (DDXMLElement *item in items) {
//        DDXMLElement *keyEle = [user elementForName:@"key"];
//
//        NSLog(@"User key:%@",[keyEle stringValue]);
//        
//        DDXMLElement *nameEle = [user elementForName:@"name"];
//        if (nameEle) {
//            NSLog(@"User name:%@",[nameEle stringValue]);
//        }
//        
//        DDXMLElement *ageEle = [user elementForName:@"attribute"];
//        if (ageEle) {
//            NSLog(@"User age:%@",[ageEle stringValue]);
//        }
        TemplateInfo *data=[[TemplateInfo alloc]init];
        DDXMLElement *keyEle=[item elementForName:@"key"];
        DDXMLElement *nameEle=[item elementForName:@"name"];
        DDXMLElement *atrEle=[item elementForName:@"attribute"];
        DDXMLElement *valueEle=[item elementForName:@"value"];
        DDXMLElement *emptyEle=[item elementForName:@"empty"];
        DDXMLElement *displayEle=[item elementForName:@"display"];
        data.key=[keyEle stringValue];
        data.name=[nameEle stringValue];
        data.attribute=[atrEle stringValue];
        data.value=[valueEle stringValue];
        data.ifEmpty=[[emptyEle stringValue]boolValue];
        data.ifDisplay=[[displayEle stringValue]boolValue];
        [templateInfoArray addObject:data];
    }
    return templateInfoArray;
}
-(void)logNodeArray{
//    NSString *sourcePath=[[NSBundle mainBundle]pathForResource:@"xmlTest" ofType:@"xml"];
//    NSData *sourceData=[NSData dataWithContentsOfFile:sourcePath];
//    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:sourceData options:0 error:nil];
//    NSArray *items=[xmlDoc nodesForXPath:@"//root" error:nil];
//    NSLog(@"the count is =%d",[items count]);
//    for (DDXMLElement *item in items) {
//        NSArray *attributes=item.attributes;
//        NSLog(@"this is %@",attributes);
//    }
    
    
    NSMutableArray *templateInfoArray;
    NSString *sourcePath=[[NSBundle mainBundle]pathForResource:@"nodeTest" ofType:@"xml"];
    NSString *sourceText=[[NSString alloc]initWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    NSData *sourceData=[sourceText dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParse=[[TFHpple alloc]initWithXMLData:sourceData];
    NSArray *elements=[xpathParse searchWithXPathQuery:@"//node"];
    NSLog(@"the count %d",[elements count]);
    for (TFHppleElement *item in elements) {
//        TemplateInfo *data =[[TemplateInfo alloc]init];
//        NSArray *itemInfoArray=item.children;
//        NSMutableArray *itemDetailArray=[[NSMutableArray alloc]init];
//        for (int i=0; i<itemInfoArray.count; i++) {
//            TFHppleElement *itemDetail=[itemInfoArray objectAtIndex: i];
//            NSLog(@"%@=%@",itemDetail.firstTextChild.tagName, itemDetail.firstTextChild.content);
//        }
        
    }
}

-(NSMutableArray *)getTemInfoFromTp{
    NSMutableArray *templateInfoArray=[[NSMutableArray alloc]init];
    
    
    NSString *sourcePath=[[NSBundle mainBundle]pathForResource:@"t_sjyfi_vtp" ofType:@"xml"];
    NSData *sourceData=[NSData dataWithContentsOfFile:sourcePath];
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:sourceData options:0 error:nil];
    
    //利用XPath来定位节点（XPath是XML语言中的定位语法，类似于数据库中的SQL功能）
    NSArray *items = [xmlDoc nodesForXPath:@"//item" error:nil];
    for (DDXMLElement *item in items) {
        TemplateInfo *data=[[TemplateInfo alloc]init];
        DDXMLElement *keyEle=[item elementForName:@"key"];
        DDXMLElement *nameEle=[item elementForName:@"name"];
        DDXMLElement *atrEle=[item elementForName:@"attribute"];
        DDXMLElement *valueEle=[item elementForName:@"value"];
        DDXMLElement *emptyEle=[item elementForName:@"empty"];
        DDXMLElement *displayEle=[item elementForName:@"display"];
        data.key=[keyEle stringValue];
        data.name=[nameEle stringValue];
        data.attribute=[atrEle stringValue];
        data.value=[valueEle stringValue];
        data.ifEmpty=[[emptyEle stringValue]boolValue];
        data.ifDisplay=[[displayEle stringValue]boolValue];
        [templateInfoArray addObject:data];
    }
    return templateInfoArray;
}

-(NSMutableArray *)getAniTemInfoFromTp{
    NSMutableArray *infoArray=[@[]mutableCopy];
    NSString *sourcePath=[[NSBundle mainBundle]pathForResource:@"t_sjyfi_aib" ofType:@"xml"];
    NSData *sourceData=[NSData dataWithContentsOfFile:sourcePath];
    DDXMLDocument *xmldoc=[[DDXMLDocument alloc]initWithData:sourceData options:0 error:nil];
    
    NSArray *items=[xmldoc nodesForXPath:@"//item" error:nil];
    for (DDXMLElement *item in items ) {
        TemplateInfo *data=[[TemplateInfo alloc]init];
        DDXMLElement *keyEle=[item elementForName:@"key"];
        DDXMLElement *nameEle=[item elementForName:@"name"];
        DDXMLElement *atrEle=[item elementForName:@"attribute"];
        DDXMLElement *valueEle=[item elementForName:@"value"];
        DDXMLElement *emptyEle=[item elementForName:@"empty"];
        DDXMLElement *displayEle=[item elementForName:@"display"];
        data.key=[keyEle stringValue];
        data.name=[nameEle stringValue];
        data.attribute=[atrEle stringValue];
        data.value=[valueEle stringValue];
        data.ifEmpty=[[emptyEle stringValue]boolValue];
        data.ifDisplay=[[displayEle stringValue]boolValue];
        [infoArray addObject:data];
    }
    return infoArray;
}

-(NSMutableArray *)getAnidTemInfoFromTp{
    NSMutableArray *infoArray=[@[]mutableCopy];
    NSString *sourcePath=[[NSBundle mainBundle]pathForResource:@"t_sjyfi_aid" ofType:@"xml"];
    NSData *sourceData=[NSData dataWithContentsOfFile:sourcePath];
    DDXMLDocument *xmldoc=[[DDXMLDocument alloc]initWithData:sourceData options:0 error:nil];
    
    NSArray *items=[xmldoc nodesForXPath:@"//item" error:nil];
    for (DDXMLElement *item in items ) {
        TemplateInfo *data=[[TemplateInfo alloc]init];
        DDXMLElement *keyEle=[item elementForName:@"key"];
        DDXMLElement *nameEle=[item elementForName:@"name"];
        DDXMLElement *atrEle=[item elementForName:@"attribute"];
        DDXMLElement *valueEle=[item elementForName:@"value"];
        DDXMLElement *emptyEle=[item elementForName:@"empty"];
        DDXMLElement *displayEle=[item elementForName:@"display"];
        data.key=[keyEle stringValue];
        data.name=[nameEle stringValue];
        data.attribute=[atrEle stringValue];
        data.value=[valueEle stringValue];
        data.ifEmpty=[[emptyEle stringValue]boolValue];
        data.ifDisplay=[[displayEle stringValue]boolValue];
        [infoArray addObject:data];
    }
    return infoArray;
}
-(NSString *)getTitleFromTemplate:(NSString *)fileName{
    NSString *title;
    
    
    return title;
    
}



@end
