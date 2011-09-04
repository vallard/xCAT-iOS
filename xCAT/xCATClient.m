//
//  xCATClient.m
//  xCAT
//
//  Created by Vallard Benincosa on 9/3/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "xCATClient.h"

@implementation xCATClient
@synthesize theData;
@synthesize outputStream;
@synthesize inputStream;

// Make this a singleton class?  Or make a new class every time we connect?
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [theData release];
    [inputStream release];
    [outputStream release];
    [super dealloc];
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
            
            NSLog(@"The string is %@", self.message);
            
            // convert this string to data so we can send it. 
            NSData *data = [self.message dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
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
            //NSString *theFinalOutput = [[NSString alloc] initWithFormat:@""];
            while ([inputStream hasBytesAvailable]) {
                len =  [inputStream read:buffer maxLength:sizeof(buffer)];
                NSString *myOutput = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                //NSData *theData = [[NSData alloc] initWithBytes:buffer length:len];
                if (nil != myOutput ) {
                    //NSLog(@"This is the data we read: %@", myOutput );
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
            
            self.theData = [self.theData dataUsingEncoding:NSUTF8StringEncoding];
            
            
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
