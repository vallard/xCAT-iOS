//
//  LoginViewController.m
//  xCAT
//
//  Created by Vallard Benincosa on 9/13/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "xCATAppDelegate.h"
#import "Connection.h"
#import "xCATClient.h"
#import "xCATParser.h"
#import "xCATViewController.h"





@implementation LoginViewController

@synthesize signInButton;
@synthesize signInTable;
@synthesize loggingInSpinner;
@synthesize serverTextField;
@synthesize loadingSquare;
@synthesize userTextField;
@synthesize passwordTextField;
@synthesize savedServer;
@synthesize savedLogin;


- (IBAction)signIn:(id)sender {
    
    // Verify all fields have been filled in
    NSString *inputUser = userTextField.text;
    NSString *inputServer = serverTextField.text;
    NSString *inputPassword = passwordTextField.text;
    if (! inputUser ){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Missing User!" message:@"Please enter a user name, or your name is mud." delegate:self cancelButtonTitle:@"Ok, sorry!" otherButtonTitles:nil, nil];
        [error show];
        [error release];
        userTextField.text = @"mud";
        return;
    }
    
    if (! inputServer ){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Missing Server!" message:@"What xCAT are you trying to connect to?. Enter Server: e.g: 172.20.0.1" delegate:self cancelButtonTitle:@"Ok, sorry!" otherButtonTitles:nil, nil];
        [error show];
        [error release];
        serverTextField.text = @"172.20.0.1";
        return;
    }
    
    if (! inputPassword) {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Missing Password!" message:@"Sorry, empty passwords aren't supported. Please enter something." delegate:self cancelButtonTitle:@"Ok, brother!" otherButtonTitles:nil, nil];
        [error show];
        [error release];
        return;
    }
    

    
    // turn off the keyboard and user input.
    [self backgroundTap:self];
    signInButton.enabled = NO;
    userTextField.enabled = NO;
    serverTextField.enabled = NO;
    passwordTextField.enabled = NO;
    
    
    //UIButton *loadingSquare = [[[UIButton alloc] initWithFrame:CGRectMake(85, 155, 155, 155)] autorelease];

    loadingSquare = [UIButton buttonWithType:UIButtonTypeCustom];
    
    loadingSquare.frame = CGRectMake(85, 100, 155, 155 );
    //[loadingSquare setTitle:@"Loading..." forState:UIControlStateNormal];
    loadingSquare.backgroundColor = [UIColor blackColor];
    loadingSquare.alpha = 0.85;
    loadingSquare.layer.cornerRadius = 14.0f;
    
    
    //Logging In Spinner
    loggingInSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    // Put this in the middle
    loggingInSpinner.frame = CGRectMake(52.5, 52.5, 50, 50);
    loggingInSpinner.hidden = NO;
    [loggingInSpinner startAnimating];
    [loadingSquare addSubview:loggingInSpinner];
    
    // Put this at the bottom
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 135, 25)];
    [loadingLabel setAdjustsFontSizeToFitWidth:YES];
    loadingLabel.text = @"Connecting...";
    loadingLabel.tag = 100;
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.textAlignment = UITextAlignmentCenter;
    
    [loadingSquare addSubview:loadingLabel];
    [loadingLabel release];
    [loggingInSpinner release];
    
    
    
    
    //loadingSquare.buttonType = UIButtonTypeRoundedRect;
    [self.view addSubview:loadingSquare];

    // now do some work:
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
    // clean up if we've been down this road before.
        
    if (theApp.xCATConnection) {
        [theApp.xCATConnection release];
        theApp.xCATConnection = nil;
    }
    
    
    theApp.xCATConnection = [[Connection alloc] initWithUser:inputUser passwd:inputPassword host:inputServer port:3001];
    [theApp xcmd:@"nodels" noderange:nil subcommand:nil];

    [self saveLoginInfo ];
    
    
}

// Save the login information upon a successful login.

- (void)saveLoginInfo {

    NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.userTextField.text, self.serverTextField.text, nil] forKeys:[NSArray arrayWithObjects:@"loginInfo", @"serverInfo", nil]];
    
    NSString *wFilePath = [self dataFilePath];
    
    NSLog(@"Writing to %@", wFilePath);
    if(! [dic writeToFile:wFilePath atomically:YES]){
        NSLog(@"error writing datafile of server");
    }
    
}

- (void)didGetCanNotResolveError {
    dispatch_async(dispatch_get_main_queue(), ^{
        xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *message = [NSString stringWithFormat:@"Can not resolve %@", serverTextField.text];
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:message delegate:self cancelButtonTitle:@"Bummer" otherButtonTitles:nil, nil];
        [al show];
        [al release];
        // have to troubleshoot here, but lets just see if it works:
        signInButton.enabled = YES;
        userTextField.enabled = YES;
        serverTextField.enabled = YES;
        passwordTextField.enabled = YES;
        [loadingSquare removeFromSuperview];
        theApp.nodelist = nil;
    });
}


- (void)signUpForNotifications {
    
    // Sign up for notifications for xCAT events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendxCATData) name:@"didSendxCATData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetxCATData) name:@"didLogIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetConnectionError) name:@"didGetConnectionError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetConnectionTimeOutError) name:@"didGetConnectionTimeOutError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAuthenticationError) name:@"didGetAuthenticationError" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCanNotResolveError) name:@"canNotResolve" object:nil];
}

- (void)unregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSendxCATData" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didLogIn" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didGetConnectionError" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didGetAuthenticationError" object:nil];
}

// didSendxCATData is called when the server sends data to xCAT server and is now waiting for response.
- (void)didSendxCATData {
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *loadingLabel = (UILabel *)[loadingSquare viewWithTag:100];
        loadingLabel.text = @"Waiting For Server Response..."; 
    });
}



- (void)didGetAuthenticationError {
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"made it here");
        
        // have to troubleshoot here, but lets just see if it works:
        signInButton.enabled = YES;
        userTextField.enabled = YES;
        serverTextField.enabled = YES;
        passwordTextField.enabled = YES;
      
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Authentication Error" message:@"User ID and Password combination was not recognized.  Please verify your settings." delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil, nil];
        [theAlert show];
        [theAlert release];
        if (loadingSquare != nil) {
            [loadingSquare removeFromSuperview];
        }
    });
}


/* called when we get the xCAT data from the query.  This will flip the screen over and add xNavController */

- (void)didGetxCATData {
    //dispatch_async(dispatch_get_main_queue(), ^{
        
        
        //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetxCATData) name:@"didGetxCATData" object:nil];

        // Get rid of the black square
        if (loadingSquare != nil) {
            [loadingSquare removeFromSuperview];
        }

        signInButton.enabled = YES;
        userTextField.enabled = YES;
        serverTextField.enabled = YES;
        passwordTextField.enabled = YES;
        passwordTextField.text = nil;
        
        
        [self unregisterNotifications ];        
       
    
        // Get everything ready for animation to transition to the node list.
        
        xCATViewController *xViewController = [[xCATViewController alloc] init];
        //xViewController.delegate = self;
        
        UINavigationController *theController = [[UINavigationController alloc] initWithRootViewController:xViewController];
        
        // add flip button:
        UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] 
                                       initWithTitle:@"LogOut"                                            
                                       style:UIBarButtonItemStyleBordered 
                                       target:self 
                                       action:@selector(logOut)];
       
        theController.topViewController.navigationItem.leftBarButtonItem = flipButton;
        theController.navigationBar.barStyle = UIBarStyleBlack;
        
        [flipButton release];
        
        
        
        
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:[[UIApplication sharedApplication] keyWindow]  
                                 cache:NO];
        
        [self presentModalViewController:theController animated:NO];
        
        [UIView commitAnimations];
        
        // [theController release];
        //[xViewController release];
     
   // });

    
}

// Called when the xCAT View controller is done!
- (IBAction)logOut { 
    
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];

    theApp.nodelist = nil;
   
    theApp.xCATConnection = nil;

    
    [theApp.nodelist release];
    [theApp.xCATConnection release];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:[[UIApplication sharedApplication] keyWindow]  
                             cache:NO];
    
    [self dismissModalViewControllerAnimated:YES];
    [UIView commitAnimations];
}




- (void)didGetConnectionError {
    dispatch_async(dispatch_get_main_queue(), ^{
        xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"There seems to be some issue with your xCAT server" delegate:self cancelButtonTitle:@"Bummer" otherButtonTitles:nil, nil];
        [al show];
        [al release];
        // have to troubleshoot here, but lets just see if it works:
        signInButton.enabled = YES;
        userTextField.enabled = YES;
        serverTextField.enabled = YES;
        passwordTextField.enabled = YES;
        [loadingSquare removeFromSuperview];
        theApp.nodelist = nil;
    });
}


- (void)didGetConnectionTimeOutError {
    //NSLog(@"notification told us we got a connection timeout");
    dispatch_async(dispatch_get_main_queue(), ^{
        // have to troubleshoot here, but lets just see if it works:
        signInButton.enabled = YES;
        userTextField.enabled = YES;
        serverTextField.enabled = YES;
        passwordTextField.enabled = YES;
        if (loadingSquare) {
            [loadingSquare removeFromSuperview];
            loadingSquare = nil;
        }
        //xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
        
       /* NSString *tErrorMessage = [NSString stringWithFormat:@"Could not connect to xCAT server.  Verify %@ is reachable from this network", theApp.xClient.myConn.host];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Time out!" message:tErrorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        */
    });
}


- (IBAction)backgroundTap:(id)sender {
    [serverTextField resignFirstResponder];
    [userTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSString *)dataFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	//NSLog(@"Documents Directory: %@", documentsDirectory);
	return [documentsDirectory stringByAppendingPathComponent:kLoginInfo];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    
    // load up the last server and login entered
    NSString *filePath = [self dataFilePath];
   /* if (DEBUG) {
        NSLog(@"filepath: %@", filePath);
    } */
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        savedServer = [dic valueForKey:@"serverInfo"];
        savedLogin = [dic valueForKey:@"loginInfo"];

    }
    
    self.signInTable.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    // Sign up for notifications just the first time!
    [self signUpForNotifications];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    signInTable = nil;
    signInButton = nil;
    loggingInSpinner = nil;
    serverTextField = nil;
    userTextField = nil;
    passwordTextField = nil;
    loadingSquare = nil;
    savedLogin = nil;
    savedServer = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [savedLogin release];
    [savedServer release];
    [loadingSquare release];
    [signInButton release];
    [signInTable release];
    [loggingInSpinner release];
    [serverTextField release];
    [userTextField release];
    [passwordTextField release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableView Data Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3; /* server, login, password */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *loginTableIdentifier = @"LoginTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loginTableIdentifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:loginTableIdentifier] autorelease];
    }
    
    NSUInteger row = [indexPath row];
    switch (row) {
        case 0:
            if (serverTextField == nil) {
                serverTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
                serverTextField.adjustsFontSizeToFitWidth = YES;
                serverTextField.textColor = [UIColor blackColor];
                serverTextField.placeholder = @"mgmt";
                serverTextField.keyboardType = UIKeyboardTypeURL;
                serverTextField.returnKeyType = UIReturnKeyNext;
                serverTextField.backgroundColor = [UIColor clearColor];
                serverTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                serverTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                serverTextField.textAlignment = UITextAlignmentLeft;
                serverTextField.tag = 0;
                serverTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [serverTextField setEnabled:YES];
                [serverTextField setDelegate:self];
                if (self.savedServer != nil) {
                    serverTextField.text = self.savedServer;
                }

            }
            cell.textLabel.text = @"Server";
            [cell addSubview:serverTextField];
            break;
        case 1:
            if (userTextField == nil) {
                userTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
                userTextField.adjustsFontSizeToFitWidth = YES;
                userTextField.textColor = [UIColor blackColor];
                userTextField.placeholder = @"root";
                // keep the root as default, don't clear.
                userTextField.clearsOnBeginEditing = NO;
                userTextField.keyboardType = UIKeyboardTypeURL;
                userTextField.returnKeyType = UIReturnKeyNext;
                userTextField.backgroundColor = [UIColor clearColor];
                userTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                userTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                userTextField.textAlignment = UITextAlignmentLeft;
                userTextField.tag = 0;
                userTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [userTextField setEnabled:YES];
                [userTextField setDelegate:self];
                if (self.savedLogin != nil) {
                    userTextField.text = self.savedLogin;
                }

            }
            cell.textLabel.text = @"Login";
            [cell addSubview:userTextField];

            break;
        case 2:
            if (passwordTextField == nil) {
                passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
                passwordTextField.adjustsFontSizeToFitWidth = YES;
                passwordTextField.textColor = [UIColor blackColor];
                passwordTextField.secureTextEntry = YES; // this is a password!
                //passwordTextField.placeholder = @"\U000025cf\U000025cf\U000025cf\U000025cf\U000025cf\U000025cf\U000025cf\U000025cf";
                passwordTextField.keyboardType = UIKeyboardTypeURL;
                passwordTextField.returnKeyType = UIReturnKeyGo;
                passwordTextField.backgroundColor = [UIColor clearColor];
                passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                passwordTextField.textAlignment = UITextAlignmentLeft;
                passwordTextField.tag = 0;
                passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [passwordTextField setEnabled:YES];
                [passwordTextField setDelegate:self];
                
            }
            cell.textLabel.text = @"Password";
            [cell addSubview:passwordTextField];

            break;
        default:
            cell.textLabel.text = @"the thing that should not be";
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.backgroundColor = [UIColor whiteColor];
    //cell.textLabel.textColor = [UIColor blackColor];
    
    cell.backgroundColor = [UIColor whiteColor];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // make it so that cell doesn't change on selected
    // do nothing!
}

#pragma mark -
#pragma mark UITextFieldDelegate functions

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == serverTextField) {
        [userTextField becomeFirstResponder];
        return NO;
    }else if (textField == userTextField){
        [passwordTextField becomeFirstResponder];
        return NO;
    }else {
        [self signIn:textField];
        return YES;
    }
}
// called when textfield runs resignFirstResponder.
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField  {
    //[textField resignFirstResponder];
    return YES;
}

@end
