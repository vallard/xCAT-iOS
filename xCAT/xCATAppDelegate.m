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

@synthesize nodelist;

@synthesize dateFormatter;




// master runcmd.  Runs xCAT commands
- (void)xcmd:(NSString *)cmd noderange:(NSString *)nr subcommand:(NSString *)subCmd{
    /*if (DEBUG ){ 
        NSLog(@"xCATAppDelegate:xcmd");
        NSLog(@"####################");
    }*/
    //dispatch_queue_t q = dispatch_queue_create("com.benincosa.xcat", NULL);
    dispatch_async(dispatch_get_main_queue(), ^{
    xCATClient *thisxcmd = [[xCATClient alloc] initWithConnection:self.xCATConnection ];
    [thisxcmd runCmd:cmd noderange:nr arguments:[NSArray arrayWithObjects:subCmd, nil]];
    [xSessions setObject:thisxcmd forKey:thisxcmd.identifier];
    });
}

// master callback for whenever xCAT session finishes running a command.
- (void)processxCATData:(NSNotification *)notification {
    
    /*if (DEBUG ){ 
        NSLog(@"xCATAppDelegate:processxCATData");
        NSLog(@"####################");
    }*/
    // whenever xCAT client finishes it returns sends an alert to NSNotification center informing us that it got data.
    // we go here and get the info from this xCAT connection and process it.  
    NSString *key = (NSString*)[notification.userInfo objectForKey:@"key"];
    //NSString *key = nil;

    NSLog(@"Key is %@", key);
    
    xCATClient *thisClient = [xSessions objectForKey:key];
    NSLog(@"command: %@", thisClient.command);
    // running revent log
    if ([thisClient.command isEqualToString:@"reventlog"]) {
        // this is reventlog, so we parse it then notify the eventlog viewer (if its up) to redisplay
        [self parseEventLog:thisClient];
        [thisClient release];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"eventLogUpdated" object:nil];
    }else if ([thisClient.command isEqualToString:@"rvitals"]){
        [self parseVitals:thisClient];
        [thisClient release];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"vitalsUpdated" object:nil];
    }else if ([thisClient.command isEqualToString:@"rinv"]){
        [self parseInv:thisClient];
        [thisClient release];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"invUpdated" object:nil];
    }else if ([thisClient.command isEqualToString:@"nodestat"]){
        [self parseNodeStat:thisClient];
        [thisClient release];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"nodeStatUpdated" object:nil];
        // this is the log in screen:
    }else if ([thisClient.command isEqualToString:@"nodels"]){
       
        xCATParser *myParser = [[xCATParser alloc] init];
        [myParser start:thisClient.theOutput];
        
        if (myParser.thereAreErrors) {
            // there are errors so finish execution.  Don't proceed.
            return;
        }
        self.nodelist = myParser.xNodes;
        [myParser release];
        //[thisClient release];
        [xSessions removeObjectForKey:key];
        thisClient = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didLogIn" object:nil];
        
    }else if ([thisClient.command isEqualToString:@"rpower"]){
        [self parseROutput:thisClient cmd:thisClient.command];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"powerUpdated" object:nil];
    }else if ([thisClient.command isEqualToString:@"rbeacon"]){
        [self parseROutput:thisClient cmd:thisClient.command];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"powerUpdated" object:nil];
    }
    // when we finish updating the model, we now send callback data to the views (or whoever is listening telling them to update thier view
    // we may not be on the view when the object is updated.  That is ok, it just gets ignored.
  
}



- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processxCATData:) name:@"didGetxCATData" object:nil];
}





- (xCATNode *)getNode:(NSString *)node {
    NSEnumerator *eX = [self.nodelist objectEnumerator];
    xCATNode *xNode;
    while (xNode = [eX nextObject]) {
        if ([xNode.name isEqualToString:node]) {
            return xNode;
        }
    }
    return nil;
}

- (NSArray* )formatEvent:(NSString *)event key:(NSUInteger )key {
    // see what this looks like:
    if (event == nil) {
        return nil;
    }
    // events come in 12/27/2011 23:49:22 "blah blah blah"
    if (event.length > 19  ) {
        
        NSDate *date = [dateFormatter dateFromString:[event substringToIndex:19]];
        
        if (date == nil) {
            return [NSArray arrayWithObjects:event, [NSDate date] , nil];
        }
        //NSDictionary *dateHash = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:[event substringFromIndex:17]] forKeys:[NSArray arrayWithObject:date]];
        NSArray *dateArray = [NSArray arrayWithObjects:[event substringFromIndex:17], date, nil];
        return dateArray;
    }
    return [NSArray arrayWithObjects:event, [NSString stringWithFormat:@"%d", key ] , nil];    
}

// everytime we call this we are erasing any eventlog that may have already been cached.
- (void)parseEventLog:(xCATClient *)xC {
   /* if (DEBUG >0) {
        NSLog(@"Inside xCATAppDelegate:parseEventLog");
        NSLog(@"#######################################");
    }
    */
    NSMutableArray *parsedNodes = [[NSMutableArray alloc] init ];
    xCATParser *parser = [[xCATParser alloc] init ];
    // parse what we have
    [parser start:xC.theOutput];

    NSEnumerator *eP = [parser.xNodes objectEnumerator];
    xCATNode *parsedNode;
    
    // go through all the nodes we just parsed.  
    /* The output of eventlog will give a bunch of nodes.  Each node will only contain one
     eventlog entry.  */
    NSUInteger x = 1;
    while (parsedNode = (xCATNode *)[eP nextObject]) {
        // See if thise node is inside our parsedNode list already
        NSEnumerator *eN = [parsedNodes objectEnumerator];
        xCATNode *existingNode = nil;
        xCATNode *currNode = nil;
        while (existingNode = (xCATNode *)[eN nextObject]) {
            if ([parsedNode.name isEqualToString:existingNode.name]) {
                currNode = existingNode;
                //currNode = existingNode;
                break;
            }
        }
        if (! currNode) {
            // get this node from the nodelist.
            xCATNode *currNode = [self getNode:parsedNode.name];
            // see if there is an error in the node.
            if (parsedNode.xError) {
                currNode.events = [NSDictionary dictionaryWithObject:parsedNode.xError forKey:@"Error"];
            // if no error, assign the events to the first contents.
            
            }else {
                
                //currNode.events = [NSDictionary dictionaryWithObject:parsedNode.contents forKey:[NSString stringWithFormat:@"%d",x++]];
                NSArray *contents = [self formatEvent:parsedNode.contents key:x++];
                if (contents == nil) {
                    currNode.events = nil;
                }else {
                    currNode.events = [NSDictionary dictionaryWithObjectsAndKeys:[contents objectAtIndex:0], [contents objectAtIndex:1],nil];
                }
            }
            // keep track of this node by adding it to the parsedNodes list.
            [parsedNodes addObject:currNode];
        
        }else{
            // we've already added this node into the list, so just append the log message
            //NSMutableArray *tmp = [NSMutableArray arrayWithArray:currNode.events];
            //[tmp addObject:[self formatEvent:parsedNode.contents]];
            NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:currNode.events];
            NSArray *contents = [self formatEvent:parsedNode.contents key:x++];
            [theDict setObject:[contents objectAtIndex:0] forKey:[contents objectAtIndex:1]];
            currNode.events = theDict;
            
        }
    }
    [parsedNodes release];
    [parser release];
}


// parse vitals output
- (void)parseVitals:(xCATClient *)xC {
    /*if (DEBUG >0) {
        NSLog(@"Inside xCATAppDelegate:parseVitals");
        NSLog(@"#######################################");
    }*/
    
    NSMutableArray *parsedNodes = [[NSMutableArray alloc] init ];
    xCATParser *parser = [[xCATParser alloc] init ];
    // parse what we have
    [parser start:xC.theOutput];
    
    NSEnumerator *eP = [parser.xNodes objectEnumerator];
    xCATNode *parsedNode;
    
    // go through all the nodes we just parsed.  
    while (parsedNode = (xCATNode *)[eP nextObject]) {
        // See if thise node is inside our parsedNode list already
        NSEnumerator *eN = [parsedNodes objectEnumerator];
        xCATNode *existingNode = nil;
        xCATNode *currNode = nil;
        while (existingNode = (xCATNode *)[eN nextObject]) {
            if ([parsedNode.name isEqualToString:existingNode.name]) {
                currNode = existingNode;
                //currNode = existingNode;
                break;
            }
        }
        if (! currNode) {
            // get this node from the nodelist.
            xCATNode *currNode = [self getNode:parsedNode.name];
            // see if there is an error in the node.
            if (parsedNode.xError) {
                currNode.vitals = [NSDictionary dictionaryWithObject:parsedNode.xError forKey:@"Error"];
                // if no error, assign the events to the first contents.
                
            }else {
                
                if (parsedNode.contents == nil || parsedNode.desc == nil) {
                    currNode.vitals = nil;
                }else {
                    currNode.vitals = [NSDictionary dictionaryWithObject:parsedNode.contents forKey:parsedNode.desc];
                }
            }
            // keep track of this node by adding it to the parsedNodes list.
            [parsedNodes addObject:currNode];
            
        }else{
            // we've already added this node into the list, so just append the log message
            //NSMutableArray *tmp = [NSMutableArray arrayWithArray:currNode.events];
            //[tmp addObject:[self formatEvent:parsedNode.contents]];
            NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:currNode.vitals];
            [theDict setObject:parsedNode.contents forKey:parsedNode.desc];
            currNode.vitals = theDict;
            
        }
    }
    [parsedNodes release];
    [parser release];
}



// Parse rinv output

- (void)parseInv:(xCATClient *)xC {
    /*if (DEBUG >0) {
        NSLog(@"Inside xCATAppDelegate:parseInv");
        NSLog(@"#######################################");
    }*/
    
    NSMutableArray *parsedNodes = [[NSMutableArray alloc] init ];
    xCATParser *parser = [[xCATParser alloc] init ];
    // parse what we have
    [parser start:xC.theOutput];
    
    NSEnumerator *eP = [parser.xNodes objectEnumerator];
    xCATNode *parsedNode;
    
    // go through all the nodes we just parsed.  
    while (parsedNode = (xCATNode *)[eP nextObject]) {
        // See if thise node is inside our parsedNode list already
        NSEnumerator *eN = [parsedNodes objectEnumerator];
        xCATNode *existingNode = nil;
        xCATNode *currNode = nil;
        while (existingNode = (xCATNode *)[eN nextObject]) {
            if ([parsedNode.name isEqualToString:existingNode.name]) {
                currNode = existingNode;
                //currNode = existingNode;
                break;
            }
        }
        if (! currNode) {
            // get this node from the nodelist.
            xCATNode *currNode = [self getNode:parsedNode.name];
            // see if there is an error in the node.
            if (parsedNode.xError) {
                currNode.inv = [NSDictionary dictionaryWithObject:parsedNode.xError forKey:@"Error"];
                // if no error, assign the events to the first contents.
                
            }else {
                
                if (parsedNode.contents == nil || parsedNode.desc == nil) {
                    currNode.inv = nil;
                }else {
                    currNode.inv = [NSDictionary dictionaryWithObject:parsedNode.contents forKey:parsedNode.desc];
                }
            }
            // keep track of this node by adding it to the parsedNodes list.
            [parsedNodes addObject:currNode];
            
        }else{
            // we've already added this node into the list, so just append the log message
            //NSMutableArray *tmp = [NSMutableArray arrayWithArray:currNode.events];
            //[tmp addObject:[self formatEvent:parsedNode.contents]];
            NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:currNode.inv];
            [theDict setObject:parsedNode.contents forKey:parsedNode.desc];
            currNode.inv = theDict;
            
        }
    }
    [parsedNodes release];
    [parser release];
}






// this is for rpower on all the nodes from the main xCAT view.
// it updates the main list and gives all power status.

- (void)parseROutput:(xCATClient *)xClient cmd:(NSString *)cmd{
    // this method is for when rpower is called and we get the output of the command.
   
    xCATParser *xParser = [[xCATParser alloc] init];
    [xParser start:xClient.theOutput];
    
    // since we already have the node list, we just update the parts of this node.
    

    NSEnumerator *eP = [xParser.xNodes objectEnumerator];
    xCATNode *parsedNode;
    while (parsedNode = [eP nextObject]) {
        xCATNode *xNode = [self getNode:parsedNode.name];
        // update status message
        if (parsedNode.xError) {
            if (xNode.xError) {
                [xNode.statusMessage stringByAppendingFormat:@", %@", parsedNode.xError];
                [xNode.xError stringByAppendingFormat:@", %@", parsedNode.xError];
            }else {
                xNode.statusMessage =  [NSString stringWithFormat:@"%@",parsedNode.xError];
                xNode.xError = parsedNode.xError;

            }
        }else {
            xNode.statusMessage = [NSString stringWithFormat:@"%@",parsedNode.contents];
        }
        
        if ([cmd isEqualToString:@"rpower"]) {
            if ([parsedNode.contents isEqualToString:@"off"]) {
                xNode.powerState = kOff;
            }else if ([parsedNode.contents isEqualToString:@"on"]){
                xNode.powerState = kOn;
            }else {
                xNode.powerState = kError;
            }
        }else if([cmd isEqualToString:@"rbeacon"]){
            if ([parsedNode.contents isEqualToString:@"off"]) {
                xNode.beaconState = kOff;
            }else if ([parsedNode.contents isEqualToString:@"on"]){
                xNode.beaconState = kOn;
            }else {
                xNode.beaconState = kError;
            }
        }
        
    }
    // Try different way:  Go through all our nodes then go through the updates and append?
    if (xParser.thereAreErrors) {
        // there are errors so finish execution.  Don't proceed.
        NSLog(@"There are errors parsing");
        // probably should send an alert that there are errors parsing.
        return;
    }
}


// this is for rpower on all the nodes from the main xCAT view.
// it updates the main list and gives all power status.

- (void)parseNodeStat:(xCATClient *)xC{
    // this method is for when rpower is called and we get the output of the command.
    
    xCATParser *xParser = [[xCATParser alloc] init];
    [xParser start:xC.theOutput];
    
    // since we already have the node list, we just update the parts of this node.
    
    
    NSEnumerator *eP = [xParser.xNodes objectEnumerator];
    xCATNode *parsedNode;
    while (parsedNode = [eP nextObject]) {
        xCATNode *xNode = [self getNode:parsedNode.name];
        // update status message
        if (parsedNode.xError) {
            if (xNode.xError) {
                [xNode.statusMessage stringByAppendingFormat:@", %@", parsedNode.xError];
                [xNode.xError stringByAppendingFormat:@", %@", parsedNode.xError];
            }else {
                xNode.statusMessage =  [NSString stringWithFormat:@"%@",parsedNode.xError];
                xNode.xError = parsedNode.xError;
                
            }
        }else {
            xNode.statusMessage = [NSString stringWithFormat:@"%@",parsedNode.contents];
        }
        
        xNode.nodeStat = parsedNode.data;
    }
    // Try different way:  Go through all our nodes then go through the updates and append?
    if (xParser.thereAreErrors) {
        // there are errors so finish execution.  Don't proceed.
        NSLog(@"There are errors parsing");
        // probably should send an alert that there are errors parsing.
        return;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    
    //
    xSessions = [[NSMutableDictionary alloc] init ];
    [self registerForNotifications];
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
    [xSessions release];
    [nodelist release];
    [xCATConnection release];
    [_window release];
    [LoginViewController release];
    //[xNavController release];
    [super dealloc];
}

@end
