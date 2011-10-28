//
//  xCATViewController.m
//  xCAT
//
//  Created by Vallard Benincosa on 6/6/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "xCATViewController.h"
#import "xCATAppDelegate.h"
#import "LoginViewController.h"
#import "CommandViewController.h"
#import "xCATNode.h"

@implementation xCATViewController
@synthesize xClient;
@synthesize xParser;
@synthesize myConnection;
@synthesize message;
@synthesize spinner;
@synthesize nodeListTable;
@synthesize xCAT;
@synthesize logOutButton;


// action to close up shop and log out of xCAT server.
//- (IBAction)logOut:(id)sender { 


- (void)dealloc
{
    [logOutButton release];
    [xParser release];
    [xCAT release];
    [spinner release];
    [xClient release];
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
 
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];

    nodelist = theApp.nodelist;
    if ([nodelist count] == 0) {
        nodeListTable.hidden = YES;
        UILabel *myNotice = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 50 )];
        myNotice.backgroundColor = [UIColor clearColor];
        myNotice.text = @"No Nodes Defined";
        myNotice.textAlignment = UITextAlignmentCenter;
        self.view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:myNotice];
        [myNotice release];
    }else{
        NSLog(@"In here ready to run rpower");
        // run rpower command on nodes!
        [self signUpForNotifications];
        theApp.xClient = nil;
        [theApp.xClient release];
        theApp.xClient = [[xCATClient alloc] initWithConnection:theApp.xCATConnection];
        [theApp.xClient runCmd:@"rpower" noderange:@"/.*" arguments:[NSArray arrayWithObjects:@"stat", nil]];
    }
    
    
    UIImage *xLogo = [UIImage imageNamed:@"xCAT-logo-white-navbar.png"];
    
    self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:xLogo] autorelease];
    [super viewDidLoad];
}

- (void)signUpForNotifications {
    
    // Sign up for notifications for xCAT events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetxCATData) name:@"didGetxCATData" object:nil];
}

- (void)didGetxCATData {
    
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
    [theApp parseRpowerOutput];
    [self.nodeListTable reloadData];
    
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ran rpower!" message:@"rpower was run" delegate:self cancelButtonTitle:@"Ok, I'm good" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
     */
}


- (void)viewDidUnload
{
    self.logOutButton = nil;
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

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (nodelist == nil) {
        return 0;  
    }else{
        return [nodelist count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    xCATNode *xNode = [nodelist objectAtIndex:[indexPath row]];
    cell.textLabel.text = xNode.name;
    switch (xNode.powerState) {
        case kUnknown:
            cell.imageView.image = [UIImage imageNamed:@"amber-light.png"];
            break;
        case kOn:
            cell.imageView.image = [UIImage imageNamed:@"green-light.png"];
            break; 
        case kOff:
            cell.imageView.image = [UIImage imageNamed:@"gray-light.png"];
            break;
        case kError:
            cell.imageView.image = [UIImage imageNamed:@"red-light.png"];
            break;
        default:
            break;
    }
    cell.detailTextLabel.text = xNode.statusMessage;
    //cell.textLabel.text = [nodelist objectAtIndex:[indexPath row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CommandViewController *commandViewController = [[ CommandViewController alloc] initWithNibName:@"CommandViewController" bundle:nil];
    
    xCATNode *xNode = [nodelist objectAtIndex:[indexPath row]];
    commandViewController.hostName = xNode.name;
    
    if(self.navigationController){
        [self.navigationController pushViewController:commandViewController animated:YES];
    }else{
        NSLog(@"Navigation controller is nil");
    }
    [commandViewController release];
}

@end
