//
//  xCATClient.m
//  xCAT
//
//  Created by Vallard Benincosa on 9/3/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "xCATClient.h"
#import "xCATAppDelegate.h"

@implementation xCATClient
@synthesize theOutput;
@synthesize cmd;
@synthesize outputStream;
@synthesize inputStream;
@synthesize theData;
@synthesize myConn;


// Make this a singleton class?  Or make a new class every time we connect?
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithConnection:(Connection *)connection {
    self = [super init];
    if(self){
        myConn = connection;
        [self startConnection];
    }
    return self;
}

- (void)dealloc
{
    [myConn release];
    [cmd release];
    [theOutput release];
    [theData release];
    [inputStream release];
    [outputStream release];
    [super dealloc];
}

- (void)startConnection {


    //self.message = [NSString stringWithFormat:@"<xcatrequest><becomeuser><username>%@</username><password>%@</password></becomeuser><command>nodels</command></xcatrequest>\n", userid, passwd];
 
    // initialize native socket handle
    //NSString *myHost = @"walrus.benincosa.com";
    //NSURL *xCATUrl = [NSURL URLWithString:myHost];
    //CFStringRef host = CFSTR("benincosa.com");
    //UInt32 port = 3001;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
 
 
    //CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)[xCATUrl host], 3000, &readStream, &writeStream);
 
 
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)myConn.host, myConn.port, &readStream, &writeStream);
    if (readStream == nil || writeStream == nil) {
        NSLog(@"Error making connection");
        return;
    }
    
    self.inputStream = (NSInputStream *)readStream;
    self.outputStream = (NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
 
    // schedule on the main run loop
    dispatch_async(dispatch_get_main_queue(), ^ {
 
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
    });
 //[sSettings release];        
 
 
 /*NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xCATUrl];
 
 
 NSLog(@"This is it: %@", xmlParser);
 [xmlParser release];
 */

}

- (void)runCmd:(NSString *)command noderange:(NSString *)nr arguments:(NSArray *)args {

    self.cmd = [NSString stringWithFormat:@"<xcatrequest><becomeuser><username>%@</username><password>%@</password></becomeuser><command>%@</command></xcatrequest>\n", myConn.user, myConn.passwd, command];

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
            // this is where we send the first message
            
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
                NSLog(@"Command Sent");
                [outputStream close];
            }
            break;
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Output Stream: Opened completed");
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
            NSLog(@"Input Stream:  Reading data from the server!");
            uint8_t buffer[1024];
            int len;
            while ([inputStream hasBytesAvailable]) {
                len =  [inputStream read:buffer maxLength:sizeof(buffer)];
                NSString *myOutput = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                //NSData *theData = [[NSData alloc] initWithBytes:buffer length:len];
                if (nil != myOutput ) {
                    NSLog(@"This is the data we read: %@", myOutput );
                    //self.receivedMessage = [NSString stringWithFormat:@"%@%@", self.receivedMessage, myOutput];
                    
                    // append data to the existing data stream.
                    self.theData = [NSString stringWithFormat:@"%@%@", self.theData, myOutput];
                
                    
                }
            }
            //NSLog(@"This is the final message: %@", theFinalOutput);
            //self.receivedMessage = [NSString stringWithFormat:@"%@%@", self.receivedMessage, theFinalOutput];
            break;
        }
            
        case NSStreamEventEndEncountered:
            NSLog(@"Input Stream: Event End encountered");
            // here is the final message
            NSLog(@"The final message is: %@", self.theData);
            // here is where we now have the final message.  We could now decode it, or add it to some type of
            // XML entity.
            
            //self.theOutput = [self.theData dataUsingEncoding:NSUTF8StringEncoding];
            //self.theOutput = [[NSString alloc] initWithData:self.theData encoding:NSUTF8StringEncoding];
            
            //self.theOutput = [[NSString alloc] initWithData:self.theData encoding:NSUTF8StringEncoding];
            
            self.theOutput = self.theData;
            // some how we need to trigger the view controller that we are finished running the command.
            
            // call app deligate root and tell it we are ready to go?
            //xCATAppDelegate *myApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetxCATData" object:nil];
            
            //UCS_CheatSheetAppDelegate *sharedApp = (UCS_CheatSheetAppDelegate *)[[UIApplication sharedApplication] delegate];
            //NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:xmlData] autorelease];
            
            break;
        case NSStreamEventErrorOccurred:
        {
            NSError *theError = [self.inputStream streamError];
            NSLog(@"Error: %@", theError);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Input Stream Error" message:[NSString stringWithFormat:@"Error %i: %@", [theError code], [theError localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [theAlert show];
            [theAlert release];
            break;
        }
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"Ready to read!");
            break;
        case NSStreamEventNone:
            break;
        default:
            break;
    }  
}

#pragma mark -
#pragma mark nsstream delegate method

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    //NSLog(@"Stream:handleevent: is invoked...");
    //NSLog(@"The eventCode is %@", (NSString *)eventCode);
    if (aStream == outputStream) {
        [self handleOutputStream:eventCode];
    }else if (aStream == inputStream){
        [self handleInputStream:eventCode];
    }
}


@end
