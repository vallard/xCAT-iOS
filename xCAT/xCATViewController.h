//
//  xCATViewController.h
//  xCAT
//
//  Created by Vallard Benincosa on 6/6/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface xCATViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    UILabel *xCAT;
    NSString *message;
    UIActivityIndicatorView *spinner;
    UITableView *nodeListTable;
    UINavigationItem *logOutButton;
    UIToolbar *toolBar;
    NSString *currentCommand;
  
}

@property (nonatomic, retain) IBOutlet UILabel *xCAT;
@property (nonatomic, retain) IBOutlet UITableView *nodeListTable;
@property (nonatomic, retain) IBOutlet UINavigationItem *logOutButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic,retain) NSString *message;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
//- (IBAction)logOut:(id)sender;
- (void)signUpForNotifications;
- (IBAction)refreshPowerStat;
- (IBAction)forwardActions:(id)sender;
- (void)showActivity;


@end
