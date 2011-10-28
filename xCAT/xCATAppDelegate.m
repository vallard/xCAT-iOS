//
//  xCATAppDelegate.m
//  xCAT
//
//  Created by Vallard Benincosa on 6/6/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "xCATAppDelegate.h"

#import "LoginViewController.h"

#import "Connection.h"

#import "xCATClient.h"

#import "xCATParser.h"

#import "xCATNode.h"

@implementation xCATAppDelegate


@synthesize window=_window;

@synthesize loginViewController;

@synthesize xCATConnection;

@synthesize xClient;

@synthesize xParser;

@synthesize nodelist;


// take information from the parser and create a node objects from it.
- (void)createNodeList {
    self.nodelist = self.xParser.nodes;
    NSMutableArray *ma = [[NSMutableArray alloc] initWithCapacity:[self.xParser.nodes count]];
    NSEnumerator *e = [self.xParser.nodes objectEnumerator];
    NSString *nName;
    while (nName = [e nextObject]) {
        [ma addObject:[[[xCATNode alloc] initWithName:nName] autorelease]];
        
    }
    self.nodelist = ma;
    [ma release];
}

- (void)parseRpowerOutput {
    // this method is for when rpower is called and we get the output of the command.
    self.xParser = nil;
    [self.xParser release];
    self.xParser = [[xCATParser alloc] init];
    [self.xParser start:self.xClient.theOutput];
    
    // since we already have the node list, we just update the parts of this node.
    
    //.nodelist = nil;
    //[theApp.nodelist release];
    
    if (self.xParser.thereAreErrors) {
        // there are errors so finish execution.  Don't proceed.
        NSLog(@"There are errors parsing");
        return;
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    self.window.rootViewController = self.loginViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [nodelist release];
    [xParser release];
    [xClient release];
    [xCATConnection release];
    [_window release];
    [LoginViewController release];
    //[xNavController release];
    [super dealloc];
}

@end
