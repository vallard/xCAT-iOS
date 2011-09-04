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


- (void)dealloc
{
    [xCATClient release];
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

    myConnection = [[Connection alloc] initWithUser:@"vallard" passwd:@"$1$A6TX6cyX$ojzJTKUbhIUQzjNEBMOCb0" host:CFSTR("benincosa.com") port:3001 ];
    
    self.message = [NSString stringWithFormat:@"<xcatrequest><becomeuser><username>%@</username><password>%@</password></becomeuser><command>nodels</command></xcatrequest>\n", userid, passwd];
    
    // initialize native socket handle
    //NSString *myHost = @"walrus.benincosa.com";
    //NSURL *xCATUrl = [NSURL URLWithString:myHost];
    CFStringRef host = CFSTR("benincosa.com");
    UInt32 port = 3001;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    //CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)[xCATUrl host], 3000, &readStream, &writeStream);
    CFStreamCreatePairWithSocketToHost(NULL, host, port, &readStream, &writeStream);
    self.inputStream = (NSInputStream *)readStream;
    self.outputStream = (NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
  
    
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    
    [inputStream open];
    [outputStream open];
    
    
    // do some SSL now:
    
    [inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
    [outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
    
    //SSL fails because security isn't valid on SSL.  So we add these properties:
    // See: http://iphonedevelopment.blogspot.com/2010/05/nsstream-tcp-and-ssl.html
    // For the below to work, you also need to go to the project sidebar and clicke on it, then under
    // link binary with libraries include the CFNetwork.framework
    
    NSDictionary *streamSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
                               [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
                               [NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain, 
                               kCFNull, kCFStreamSSLPeerName,
                               nil];
    
    CFReadStreamSetProperty((CFReadStreamRef)self.inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)streamSettings);
    CFWriteStreamSetProperty((CFWriteStreamRef)self.outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)streamSettings);
                  
    //[sSettings release];        
                
            
    /*NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xCATUrl];
    
    
    NSLog(@"This is it: %@", xmlParser);
    [xmlParser release];
    */
     [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.inputStream = nil;
    self.outputStream = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
