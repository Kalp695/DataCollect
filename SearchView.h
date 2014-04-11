//
//  SearchView.h
//  DataCollect
//
//  Created by liucc on 3/19/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchViewDelegate <NSObject>

-(void)showSearchMapByRect;
-(void)showListByAuthor:(NSString *)author;
-(void)showListByKeyplace:(NSString *)place;
-(void)showListByName:(NSString *)name;

@end

@interface SearchView : UIView
@property (strong, nonatomic) IBOutlet UIView *view;
@property(nonatomic,assign)BOOL isShow;

@property(nonatomic,assign)id<SearchViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextField *authorField;
@property (strong, nonatomic) IBOutlet UITextField *keyPlaceField;
@property (strong, nonatomic) IBOutlet UITextField *nameField;

- (IBAction)searhByAuthor:(id)sender;
-(IBAction)searchByKeyplace:(id)sender;
-(IBAction)searchByName:(id)sender;

@end
