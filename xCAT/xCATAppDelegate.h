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
@class xCATNode;

@interface xCATAppDelegate : NSObject <UIApplicationDelegate> {
    Connection *xCATConnection;
    NSArray *nodelist;  // holds an array of node objects.
    NSMutableDictionary *xSessions;  // an array of sessions that are being called for different views and actions.
    NSDateFormatter *dateFormatter;
}
@property (nonatomic, copy) NSArray *nodelist;

@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@property (nonatomic, retain) Connection *xCATConnection;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;


//- (NSArray *)parsePowerOutput:(xCATClient *)xC;
- (void)parseEventLog:(xCATClient *)xC;
- (void)parseVitals:(xCATClient *)xC;
- (void)parseInv:(xCATClient *)xC;
- (void)parseNodeStat:(xCATClient *)xC;
- (void)parseROutput:(xCATClient *)xClient cmd:(NSString *)cmd;
- (xCATNode *)getNode:(NSString *)node;
- (void)xcmd:(NSString *)cmd noderange:(NSString *)nr subcommand:(NSString *)subCmd;
- (void)processxCATData:(NSNotification *)notification;

@end
