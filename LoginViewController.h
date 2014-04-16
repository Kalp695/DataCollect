//
//  LoginViewController.h
//  DataCollect
//
//  Created by liucc on 1/14/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UITextField *userNameField;

@property (strong, nonatomic) IBOutlet UITextField *passWordField;

- (IBAction)loginClicked:(id)sender;

- (IBAction)registerClicked:(id)sender;

@end
