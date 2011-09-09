//
//  xCATViewController.m
//  xCAT
//
//  Created by Vallard Benincosa on 6/6/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "xCATViewController.h"


@implementation xCATViewController
@synthesize xclient;
@synthesize myConnection;
@synthesize message;
@synthesize spinner;
@synthesize xCAT;



- (void)dealloc
{
    [xCAT release];
    [spinner release];
    [xclient release];
    [myConnection release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [spinner startAnimating];
    
    // register for notification of updates.
    
    [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(didGetxCATData) name:@"didGetxCATData" object:nil];
    // create a thread and get the server updates.
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        myConnection = [[Connection alloc] initWithUser:@"vallard" passwd:@"$1$A6TX6cyX$ojzJTKUbhIUQzjNEBMOCb0" host:@"benincosa.com" port:3001 ];
        xclient = [[xCATClient alloc] initWithConnection:myConnection];
        [xclient runCmd:@"nodels" noderange:nil arguments:nil];
    });

    
    [super viewDidLoad];
}


// This method is registered with xCATClient so that whenever we get an update from the server, we update the contents of the table.
// See: http://stackoverflow.com/questions/5873450/calling-method-in-current-view-controller-from-app-delegate-in-ios

- (void)didGetxCATData {
    NSLog(@"Got the update");
    dispatch_async(dispatch_get_main_queue(), ^{
        xCAT.text = xclient.theOutput; 
        [spinner stopAnimating];
        spinner.hidden = TRUE;
    });
    
}

- (void)viewDidUnload
{
    self.spinner = nil;
    self.xCAT = nil;
    self.myConnection = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
