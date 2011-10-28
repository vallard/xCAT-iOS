//
//  xCATViewController.h
//  xCAT
//
//  Created by Vallard Benincosa on 6/6/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "xCATClient.h"
#import "Connection.h"
#import "xCATParser.h"

@interface xCATViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UILabel *xCAT;
    xCATClient *xClient;
    xCATParser *xParser;
    Connection *myConnection;
    NSString *message;
    UIActivityIndicatorView *spinner;
    UITableView *nodeListTable;
    NSArray *nodelist;
    UINavigationItem *logOutButton;
  
}

@property (nonatomic, retain) IBOutlet UILabel *xCAT;
@property (nonatomic, retain) IBOutlet UITableView *nodeListTable;
@property (nonatomic, retain) IBOutlet UINavigationItem *logOutButton;
@property (nonatomic,retain) NSString *message;
@property (nonatomic, retain) xCATClient *xClient;
@property (nonatomic, retain) xCATParser *xParser;
@property (nonatomic, retain) Connection *myConnection;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
//- (IBAction)logOut:(id)sender;
- (void)signUpForNotifications;

@end
