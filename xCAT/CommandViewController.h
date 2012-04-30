//
//  CommandViewController.h
//  xCAT
//
//  Created by Vallard Benincosa on 9/24/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "xCATClient.h"
#import "EventLogViewController.h"
#import "xCATNode.h"

@interface CommandViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    NSArray *supportedCommands;
    NSString *hostName;
    UIButton *loadingSquare;
    xCATNode *node;
    BOOL cellsAreDisabled;
    UITableView *theTable;
    NSString *currentCommand;
    EventLogViewController *eventLogViewController;
    UISwitch *powerSwitch;
    UISwitch *ledSwitch;


    
}

@property (nonatomic, retain) NSArray *supportedCommands;
@property (nonatomic, retain) NSString *hostName;
@property (nonatomic, retain) UIButton *loadingSquare;
@property (nonatomic, retain) IBOutlet UITableView *theTable;
@property (nonatomic, retain) IBOutlet UISwitch *powerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *ledSwitch;



- (void)displayWaitStatus:(NSString *)message;
- (void)switchToggled;
- (void)ledSwitchToggled;

@end
