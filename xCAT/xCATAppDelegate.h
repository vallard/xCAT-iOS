//
//  xCATAppDelegate.h
//  xCAT
//
//  Created by Vallard Benincosa on 6/6/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>



@class xCATViewController;
@class LoginViewController;
@class Connection;
@class xCATClient;
@class xCATParser;

@interface xCATAppDelegate : NSObject <UIApplicationDelegate> {
    Connection *xCATConnection;
    xCATClient *xClient;
    xCATParser *xParser;
    NSArray *nodelist;  // holds an array of node objects.
}
@property (nonatomic, retain) NSArray *nodelist;

@property (nonatomic, retain) xCATParser *xParser;

@property (nonatomic, retain) xCATClient *xClient;

@property (nonatomic, retain) Connection *xCATConnection;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;

- (void)createNodeList;
- (void)parseRpowerOutput;

@end
