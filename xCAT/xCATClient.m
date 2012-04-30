//
//  xCATClient.m
//  xCAT
//
//  Created by Vallard Benincosa on 9/3/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "xCATClient.h"
#import "xCATAppDelegate.h"
#define DEBUG 1

@implementation xCATClient
@synthesize theOutput;
@synthesize cmd;
@synthesize outputStream;
@synthesize inputStream;
@synthesize theData;
@synthesize myConn;
@synthesize identifier;
@synthesize command;
@synthesize noderange;
@synthesize args;

// Make this a singleton class?  Or make a new class every time we connect?
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString *)generateRandomString {
    NSString *string = @"thisIsASampleString";
    NSUInteger strLength = [string length];
    NSString *letterToAdd;
    NSArray *charArray = [[NSArray alloc] initWithObjects: @"a", @"b", @"c", @"d", @"e", @"f",
                          @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"o", @"p", @"q", @"r", @"s",
                          @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
  
    NSMutableString *randomString = [NSMutableString stringWithCapacity: 18];
        
    for (int i = 0; i < strLength; i++) {
        letterToAdd = [charArray objectAtIndex: arc4random() % [charArray count]];
        [randomString insertString: letterToAdd atIndex: i];
           
    }
    return randomString;
}

- (id)initWithConnection:(Connection *)connection {
    self = [super init];
    if(self){
        self.identifier = [self generateRandomString];
        myConn = connection;
        [self startConnection];
    }
    return self;
}

- (void)dealloc
{
    [identifier release];
    [self stopConnectionTimeoutTimer];
    [theOutput release];
    [myConn release];
    [cmd release];
    [theOutput release];
    [theData release];
    [inputStream release];
    [outputStream release];
    [super dealloc];
}


// stop the timeout before you time out!
- (void)stopConnectionTimeoutTimer {
    if (connectionTimeoutTimer) {
        [connectionTimeoutTimer invalidate];
        //[connectionTimeoutTimer release];
        connectionTimeoutTimer = nil;
    }
}

- (void)startConnectionTimeoutTimer {
    [self stopConnectionTimeoutTimer]; // make sure we stopped!
    NSTimeInterval interval = kConnectionTimeOut; // give it a few seconds to connect.
    connectionTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(connectionDidTimeOut) userInfo:nil repeats:NO];
}


/* this code is for when the timeout for contacting the xCAT server hits.  We close
We close all connections and send a notification to the view.
 
 */
- (void)connectionDidTimeOut {
    //NSLog(@"We timed out! %d", ++timesCalled);
    [self closeConnection];
    [self stopConnectionTimeoutTimer];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetConnectionTimeOutError" object:nil];
}


- (void)startConnection {

    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
 
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)myConn.host, myConn.port, &readStream, &writeStream);
    
    if (readStream == nil || writeStream == nil) {
        NSLog(@"Error making connection");
        return;
    }
    NSLog(@"Connection made to xCAT server");
    self.inputStream = (NSInputStream *)readStream;
    self.outputStream = (NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
 
    // schedule on the main run loop
    //dispatch_async(dispatch_get_main_queue(), ^ {
 
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
        
        // Need to create a timeout here so that app doesn't hang forever.
        // See: http://stackoverflow.com/questions/3687177/iphone-catching-a-connection-error-with-nsstream
        [self startConnectionTimeoutTimer];
    //});
}

- (void)closeConnection {
    if (self.inputStream != nil) {
        NSLog(@"Closing inputstream");
        self.inputStream.delegate = nil;
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inputStream close];
        self.inputStream = nil;
    }
    
    if (self.outputStream != nil) {
        NSLog(@"Closing output streatm");
        self.outputStream.delegate = nil;
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream close];
        self.outputStream = nil;
    }
    
    // need to invalidate the queue
}
// runCmd:cmd noderange:nr arguments:[NSArray arrayWithObjects:subCmd, nil]];
- (void)runCmd:(NSString *)comm noderange:(NSString *)nr arguments:(NSArray *)theArgs {
    
    if (DEBUG > 0) {
        NSLog(@"xCATClient:runCmd, nr is %@", nr);
        NSLog(@"#################################");
    }
    self.command = comm;
    self.noderange = nr;
    
    if (nr) {
    
        self.cmd = [NSString stringWithFormat:@"<xcatrequest><becomeuser><username>%@</username><password>%@</password></becomeuser><command>%@</command><noderange>%@</noderange><arg>%@</arg></xcatrequest>\n", myConn.user, myConn.passwd, comm, nr, [theArgs objectAtIndex:0]];
            

    }else {
        self.cmd = [NSString stringWithFormat:@"<xcatrequest><becomeuser><username>%@</username><password>%@</password></becomeuser><command>%@</command></xcatrequest>\n", myConn.user, myConn.passwd, comm];
    }
}

// error handling for bad network connections.

- (void)stopNetworkWithError:(NSError *)theError {
    NSString *errorMessage;
    // kill the timeout if its going:
    [self stopConnectionTimeoutTimer];
    
    if ([theError.domain isEqualToString:(NSString *)kCFErrorDomainCFNetwork]) {
        errorMessage = [NSString stringWithFormat:@"Unable to resolve %@", self.myConn.host];
        // post that we're not able to resolve this:
        [[NSNotificationCenter defaultCenter] postNotificationName:@"canNotResolve" object:nil];
        [self closeConnection];
        return;
        
    }

    NSLog(@"Error: %@", theError);
    errorMessage = [theError localizedDescription];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetConnectionError" object:nil];
    [self closeConnection];

   
    
    
}

- (void)handleOutputStream:(NSStreamEvent)eventCode {
    //NSLog(@"Output Stream eventCode %u", eventCode);
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            NSLog(@"Output Stream: hasBytesAvailable");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"Output Stream: endEvent");
            break;
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"Output Stream: Event Error Occurred");
            NSError *theError = [self.outputStream streamError];
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Output Stream Error" message:[NSString stringWithFormat:@"Error %i: %@", [theError code], [theError localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [theAlert show];
            [theAlert release];
            break;
        }
        case NSStreamEventHasSpaceAvailable:
            // If we've made it here, we've established communication so we can send our command.
            [self stopConnectionTimeoutTimer];
            NSLog(@"Output Stream: Space Available!");
            if (self.cmd == nil) {
                break;
            }
            NSLog(@"The command is %@", self.cmd);
            
            // convert this string to data so we can send it. 
            NSData *data = [self.cmd dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            const uint8_t *bytes = (const uint8_t*)[data bytes];
            
            int data_len = [data length];
            NSLog(@"Writing to output stream...");
            
            int len;
            len = [outputStream write:bytes  maxLength:data_len];
            if (len > 0){
                // create notification that command has sent.
                if(DEBUG >0) {
                    NSLog(@"Command Sent");
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didSendxCATData" object:nil];
                [outputStream close];
            }
            break;
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Output Stream: Opened completed");
            NSLog(@"Can now send data");
            NSLog(@"my command is: %@", self.cmd);
            break;
        case NSStreamEventNone:
            NSLog(@"Output Stream: Event None");
            break;
        default:
            NSLog(@"Output Stream: how did I get here?");
            break;
    }
}

// input stream is used to read data
- (void)handleInputStream:(NSStreamEvent)eventCode {
    NSLog(@"Input Stream: EventCode %u", eventCode);
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
        { 
            if (DEBUG > 0) { NSLog(@"Input Stream:  Reading data from the server!"); }
            uint8_t buffer[1024];
            int len;
            while ([inputStream hasBytesAvailable]) {
                len =  [inputStream read:buffer maxLength:sizeof(buffer)];
                NSString *myOutput = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                //NSData *theData = [[NSData alloc] initWithBytes:buffer length:len];
                if (nil != myOutput ) {
                    
                    if (DEBUG >0) {
                        NSLog(@"This is the data we read: %@", myOutput );
                    }
                    self.theData = [NSString stringWithFormat:@"%@%@", self.theData, myOutput];
                
                    
                }
            }
            break;
        }
            
        // This case is called when the xCAT server is finished responding.  Now we take this and send it back.
        case NSStreamEventEndEncountered:
            if (DEBUG >0) {
                NSLog(@"Input Stream: Event End encountered");
                // here is the final message
                NSLog(@"The final message is: %@", self.theData);
            }
            self.theOutput = self.theData;
            [self serverDidFinishResponding];
            
            break;
        case NSStreamEventErrorOccurred:
        {
            [self stopNetworkWithError:[self.inputStream streamError]]; 
            break;
        }
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventOpenCompleted:
            if (DEBUG >0) {
                NSLog(@"Ready to read!");
            }
            break;
        case NSStreamEventNone:
            break;
        default:
            break;
    }  
}

-(void)serverDidFinishResponding {
    // This is where we respond to whoever called us to do the command.  
    
    [self closeConnection];
    NSLog(@"Closed connection to server");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetxCATData" object:self userInfo:[NSDictionary dictionaryWithObject:self.identifier forKey:@"key"]];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"didGetxCATData" object:nil];
}


#pragma mark -
#pragma mark nsstream delegate method

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
 
    if (aStream == outputStream) {
        [self handleOutputStream:eventCode];
    }else if (aStream == inputStream){
        [self handleInputStream:eventCode];
    }
}


@end
