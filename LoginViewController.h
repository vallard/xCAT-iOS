//
//  LoginViewController.h
//  xCAT
//
//  Created by Vallard Benincosa on 9/13/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kLoginInfo @"loginInfo.plist"

@interface LoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate > {
    UITableView *signInTable;
    UIButton *signInButton;
    UIActivityIndicatorView *loggingInSpinner;
    UITextField *serverTextField;
    UITextField *userTextField;
    UITextField *passwordTextField;
    UIButton *loadingSquare;
    NSString *savedServer;
    NSString *savedLogin;
    
}

@property (nonatomic, retain) IBOutlet UIButton *loadingSquare;
@property (nonatomic, retain) IBOutlet UITableView *signInTable;
@property (nonatomic, retain) IBOutlet UIButton *signInButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loggingInSpinner;
@property (nonatomic, retain) IBOutlet UITextField *serverTextField;
@property (nonatomic, retain) IBOutlet UITextField *userTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@property (nonatomic, retain) NSString *savedServer;
@property (nonatomic, retain) NSString *savedLogin;


// these two functions are used for getting and saving data.
- (NSString *)dataFilePath;
- (void)saveLoginInfo;

- (IBAction)signIn:(id)sender;
- (IBAction)logOut;
- (IBAction)backgroundTap:(id)sender;
- (void) signUpForNotifications;

@end
