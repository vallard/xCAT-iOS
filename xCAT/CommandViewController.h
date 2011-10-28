//
//  CommandViewController.h
//  xCAT
//
//  Created by Vallard Benincosa on 9/24/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommandViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *supportedCommands;
    NSString *hostName;
}

@property (nonatomic, retain) NSArray *supportedCommands;
@property (nonatomic, retain) NSString *hostName;

@end
