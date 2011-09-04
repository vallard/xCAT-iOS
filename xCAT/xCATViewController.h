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

@interface xCATViewController : UIViewController  {
    UILabel *xCAT;
    xCATClient *xclient;
    Connection *myConnection;
    NSString *message;
  
}

@property (nonatomic, retain) UILabel *xCAT;
@property (nonatomic,retain) NSString *message;
@property (nonatomic, retain) xCATClient *xclient;
@property (nonatomic, retain) Connection *myConnection;

@end
