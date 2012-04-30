//
//  EventLogViewController.h
//  xCAT
//
//  Created by Vallard Benincosa on 12/23/11.
//  Copyright (c) 2011 Benincosa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "xCATClient.h"

@interface EventLogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate > {
    NSString *noderange;
    NSDictionary *events;
    xCATClient *xC;
    UITableView *theTable;
    UIToolbar *bottomToolBar;
    NSString *function;  // show event log? what?
    
}

@property (nonatomic, retain) NSString *function;
@property (nonatomic, retain) NSString *noderange;
@property (nonatomic, retain) NSDictionary *events;
@property (nonatomic, retain) IBOutlet UITableView *theTable;
@property (nonatomic, retain) IBOutlet UIToolbar *bottomToolBar;

- (IBAction)forwardActions:(id)sender;
-(void)displayMailComposerSheet;

@end
