//
//  xCATAppDelegate.h
//  xCAT
//
//  Created by Vallard Benincosa on 6/6/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class xCATViewController;

@interface xCATAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet xCATViewController *viewController;

@end
