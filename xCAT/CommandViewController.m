//
//  CommandViewController.m
//  xCAT
//
//  Created by Vallard Benincosa on 9/24/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "CommandViewController.h"
#import "QuartzCore/QuartzCore.h"  // for layer corner radius
#import "xCATAppDelegate.h"
#import "xCATNode.h"


#define DEBUG 1
//#define kPowerOn 0
//#define kPowerOff 1
#define kPowerStat 0
/*#define kBeaconOn 0
#define kBeaconOff 1
#define kInventory 0
#define kEventLog 2
#define kVitals 1
*/
@implementation CommandViewController


@synthesize supportedCommands;
@synthesize hostName;
@synthesize loadingSquare;
@synthesize theTable;
@synthesize ledSwitch;
@synthesize powerSwitch;



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    cellsAreDisabled = NO;
    self.theTable.backgroundColor = [UIColor clearColor];
    self.title = self.hostName;
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];

    node = [theApp getNode:self.hostName];

    //self.tableView.backgroundView = [
    [super viewDidLoad];

    /* power */
    /* power on | off  (put warning alarms)*/
    /* check status: on
     
    Locator LED
     on | off 
     
     */
    
    NSArray *powerCmds = [[NSArray alloc] initWithObjects:@"Status", @"On/Off", nil];
    NSArray *ledCmds = [[NSArray alloc] initWithObjects:@"On/Off", nil];
    NSArray *utilCmds = [[NSArray alloc] initWithObjects:@"Hardware Inventory", @"Hardware Vitals", @"Hardware Event Log", nil];
    supportedCommands = [[NSArray alloc ] initWithObjects:powerCmds, ledCmds, utilCmds, nil] ;
    
    [powerCmds release];
    [ledCmds release];
    [utilCmds release];
    //supportedCommands = [[NSArray alloc] initWithObjects:@"Power On", @"Power Off", @"Power Status", @"Locator LED On", @"Locator LED Off", @"Inventory", @"BMC Log", @"Vitals", nil];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.hostName = nil;
    self.loadingSquare = nil;
    self.supportedCommands = nil;
    self.ledSwitch = nil;
    self.powerSwitch = nil;
}

- (void)dealloc {
    [self.hostName release];
    [self.supportedCommands release];
    [self.ledSwitch release];
    [self.powerSwitch release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // sign up for alerts
    // for power and rbeacon commands.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCommandResponse) name:@"powerUpdated" object:nil];
    
    [self.theTable deselectRowAtIndexPath:[self.theTable indexPathForSelectedRow] animated:YES];



}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // get rid of alerts
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"powerUpdated" object:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//warning Potentially incomplete method implementation.
    // Return the number of sections.
    NSLog(@"Number of sections: %d", [supportedCommands count]);
    
    return [supportedCommands count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSArray *subSection = [supportedCommands objectAtIndex:section];
    NSLog(@"Number of subSections: %d", [subSection count]);
    return [subSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSArray *subSection = [supportedCommands objectAtIndex:indexPath.section];
    
    cell.textLabel.text = [subSection objectAtIndex:indexPath.row];
    // Configure the cell...
    if (cellsAreDisabled) {
        // don't change colors when tapped.
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;

    // all sections with hardware vitals, inv, eventlog have disclosure indicator.
    if (indexPath.section == 2) {
        // put on disclosure indicator
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([cell.textLabel.text isEqualToString:@"On/Off"] && indexPath.section == 0) {
        // put in an on off button in this table cell
        CGRect frameSwitch = CGRectMake(215.0, 10.0, 94.0, 27.0);
        
        // memory leak here by creating a new one all the time?
        if (powerSwitch) {
            [powerSwitch release];
        }
        powerSwitch = [[UISwitch alloc] initWithFrame:frameSwitch];
        switch (node.powerState) {
            case kOn:
                powerSwitch.on = YES;
                [powerSwitch addTarget:self action:@selector(switchToggled) forControlEvents:UIControlEventValueChanged];
                break;
            case kOff:
                powerSwitch.on = NO;
                [powerSwitch addTarget:self action:@selector(switchToggled) forControlEvents:UIControlEventValueChanged];
                break;
            default:
                powerSwitch.enabled = NO;
                break;
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = powerSwitch;
    }
    if ([cell.textLabel.text isEqualToString:@"Status"]){
        UIImageView *imageView;
        switch (node.powerState) {
            case kOn:
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green-light.png"]];
                break;
            case kOff:
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray-light.png"]];
                break;
            case kError:
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red-light.png"]];
                break;
            default:
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"amber-light.png"]];
                cell.detailTextLabel.text = @"Power status Unknown";
                break;
        };
        cell.accessoryView = imageView;
    }
    
    // locator LED
    if ([cell.textLabel.text isEqualToString:@"On/Off"] && indexPath.section == 1) {
        // put in an on off button in this table cell
        CGRect frameSwitch = CGRectMake(215.0, 10.0, 94.0, 27.0);
        
        // memory leak here by creating a new one all the time?
        if (ledSwitch) {
            [ledSwitch release];
        }
        ledSwitch = [[UISwitch alloc] initWithFrame:frameSwitch];
        switch (node.beaconState) {
            case kOn:
                ledSwitch.on = YES;
                [ledSwitch addTarget:self action:@selector(ledSwitchToggled) forControlEvents:UIControlEventValueChanged];
                UIImage *image = [UIImage imageNamed:@"blue-light.png"];
                cell.imageView.image = image;
                break;
            // just assume its off if we don't know the status.
            default:
                ledSwitch.on = NO;
                [ledSwitch addTarget:self action:@selector(ledSwitchToggled) forControlEvents:UIControlEventValueChanged];
                cell.imageView.image = nil;
                break;
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = ledSwitch;
    }
    return cell;
}

- (void)disableTableInput:(UITableView *)tableView {
    cellsAreDisabled = YES;
    [tableView reloadData];
    
}

- (void)enableTableInput:(UITableView *)tableView {
    cellsAreDisabled = NO;
    [tableView reloadData];
}



- (void)displayWaitStatus:(NSString *)message {
    loadingSquare = [UIButton buttonWithType:UIButtonTypeCustom];
    
    loadingSquare.frame = CGRectMake(85, 100, 155, 155 );
    //[loadingSquare setTitle:@"Loading..." forState:UIControlStateNormal];
    loadingSquare.backgroundColor = [UIColor blackColor];
    loadingSquare.alpha = 0.85;
    loadingSquare.layer.cornerRadius = 14.0f;
    
    
    //Logging In Spinner
    UIActivityIndicatorView *loggingInSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    // Put this in the middle
    loggingInSpinner.frame = CGRectMake(52.5, 52.5, 50, 50);
    loggingInSpinner.hidden = NO;
    [loggingInSpinner startAnimating];
    [loadingSquare addSubview:loggingInSpinner];
    
    // Put this at the bottom
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 135, 25)];
    [loadingLabel setAdjustsFontSizeToFitWidth:YES];

    loadingLabel.text = message;
    loadingLabel.tag = 100;
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.textAlignment = UITextAlignmentCenter;
    
    [loadingSquare addSubview:loadingLabel];
    [loadingLabel release];
    [loggingInSpinner release];
    //loadingSquare.buttonType = UIButtonTypeRoundedRect;
    [self.view addSubview:loadingSquare];
}


// called after rpower/rbeacon command finishes
- (void)didGetCommandResponse {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (DEBUG > 0) {
            NSLog(@"In CommandViewController didGetPowerStat");
        }
        
        xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
        /*
        if ( [nodeStat count] < 1) {
            // in this case, the previous screen hit before we got the response.  Wait for another response?
            UILabel *loadingLabel = (UILabel *)[loadingSquare viewWithTag:100];
            loadingLabel.text = @"Still Trying...";
            return;
            
        }
         */
        [loadingSquare removeFromSuperview];
        node = [theApp getNode:self.hostName];
        
        NSString *title;
        NSString *message;

        if (node.xError) {
            title = [NSString stringWithFormat:@"Error: %@", self.hostName];
            message = [NSString stringWithFormat:@"%@", node.statusMessage];
        }else{
            title = [NSString stringWithFormat:@"%@", self.hostName];
            if ([currentCommand isEqualToString:@"rpower"]) {
                message = [NSString stringWithFormat:@"Power is %@", [node statToString]];

            }else if([currentCommand isEqualToString:@"rbeacon"]){
                message = [NSString stringWithFormat:@"LED is %@", [node beaconStat]];
            }
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        [self enableTableInput:self.theTable]; 
    });
}

- (void)switchToggled {
    NSString *message;
    if ([powerSwitch isOn]) {
        message = [NSString stringWithFormat:@"You are about to power %@ on", self.hostName];
    }else {
        message = [NSString stringWithFormat:@"Powering off %@ may have disastrous consequences", self.hostName];
    }
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, I'm Sure", nil];
    al.tag = 505;
    
    [al show];
    [al release];
    
}


- (void)ledSwitchToggled {
    NSString *operation;
    if ([ledSwitch isOn]) {
        // turn it off!
        operation = @"on";
    }else {
        // turn it on!
        operation = @"off";
    }
    [self disableTableInput:theTable];
    [self displayWaitStatus:[NSString stringWithFormat:@"Locator LED %@", operation]];
    currentCommand = @"rbeacon";
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
    [theApp xcmd:currentCommand  noderange:self.hostName subcommand:operation];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (cellsAreDisabled) {
        return;
    }
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            /*case kPowerOn:
                [self disableTableInput:tableView];
                [self displayWaitStatus:[NSString stringWithFormat:@"Powering on...", self.hostName]];
                currentCommand = @"rpower";
                [theApp xcmd:@"rpower"  noderange:self.hostName subcommand:@"on"];    
                break;
            case kPowerOff:
                [self disableTableInput:tableView];
                [self displayWaitStatus:[NSString stringWithFormat:@"Powering off...", self.hostName]];
                currentCommand = @"rpower";
                [theApp xcmd:@"rpower"  noderange:self.hostName subcommand:@"off"];    
                break; */
            case kPowerStat:
                [self disableTableInput:tableView];
                [self displayWaitStatus:[NSString stringWithFormat:@"Getting Power State...", self.hostName]];
                currentCommand = @"rpower";
                [theApp xcmd:@"rpower"  noderange:self.hostName subcommand:@"stat"];    
                break;
            default:
                break;
        };
    }else if (indexPath.section == 1) {
        return;
        /*switch (indexPath.row) {

            case 0:
                [self disableTableInput:tableView];
                [self displayWaitStatus:[NSString stringWithFormat:@"Locator LED On", self.hostName]];
                currentCommand = @"rbeacon";
                [theApp xcmd:@"rbeacon"  noderange:self.hostName subcommand:@"on"];    
                break;
            case 1:
                [self disableTableInput:tableView];
                [self displayWaitStatus:[NSString stringWithFormat:@"Locator LED Off", self.hostName]];
                currentCommand = @"rbeacon";
                [theApp xcmd:@"rbeacon"  noderange:self.hostName subcommand:@"off"];    
                break;
            default:
                break;
        };*/
    }else {
        switch (indexPath.row) {
            case 0:
                /*[self disableTableInput:tableView];
                [self displayWaitStatus:[NSString stringWithFormat:@"Getting Hardware Inventory...", self.hostName]];*/
                // hardware inventory
                eventLogViewController = [[ EventLogViewController alloc] init];
                eventLogViewController.noderange = self.hostName;
                eventLogViewController.function = @"rinv";
                if(self.navigationController){
                    [self.navigationController pushViewController:eventLogViewController animated:YES];
                }
                [eventLogViewController release];
                break;
            
            case 1:
                // vitals
                eventLogViewController = [[ EventLogViewController alloc] init];
                eventLogViewController.noderange = self.hostName;
                eventLogViewController.function = @"rvitals";
                if(self.navigationController){
                    [self.navigationController pushViewController:eventLogViewController animated:YES];
                }
                [eventLogViewController release];
                break;
                
            case 2:
                eventLogViewController = [[ EventLogViewController alloc] init];
                eventLogViewController.noderange = self.hostName;
                eventLogViewController.function = @"reventlog";
                if(self.navigationController){
                    [self.navigationController pushViewController:eventLogViewController animated:YES];
                }
                [eventLogViewController release];
                break;
            default:
                break;
            };
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor blackColor];
	headerLabel.highlightedTextColor = [UIColor blackColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:20];
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    
	// If you want to align the header text as centered
	// headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    switch (section) {
        case 0:
            headerLabel.text = @"Power";
            break;
        case 1:
            headerLabel.text = @"Locator LED";
            break;
        case 2:
            headerLabel.text = @"Collection Commands";
            break;
        default:
            headerLabel.text = @"???";
            break;
    }
	[customView addSubview:headerLabel];
    
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44.0;
}

#pragma mark -
#pragma mark uialertview 
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (actionSheet.tag != 505) {
        return;  
    }
    
    if (buttonIndex == 0)
    {
        NSLog(@"ok");
        if ([powerSwitch isOn]) {
            [powerSwitch setOn:NO animated:YES];
        }else {
            [powerSwitch setOn:YES animated:YES];
        }
    }
    else
    {
        xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self disableTableInput:self.theTable];
        NSString *operation;
        if ([powerSwitch isOn]) {
            NSLog(@"powerSwitch is off");
            // turn it off!
            operation = @"on";
        }else {
            NSLog(@"powerSwitch is on");
            // turn it on!
            operation = @"off";
        }
        [self displayWaitStatus:[NSString stringWithFormat:@"Powering %@", operation]];
        currentCommand = @"rpower";
        [theApp xcmd:@"rpower"  noderange:self.hostName subcommand:operation];
    }
}

@end
