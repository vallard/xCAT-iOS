//
//  xCATParser.m
//  xCAT
//
//  Created by Vallard Benincosa on 9/9/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "xCATParser.h"
#import "xCATNode.h"
#import <regex.h>

@implementation xCATParser


@synthesize xNodes;
@synthesize thereAreErrors;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)dealloc {
    //[currentElement release];
    //[xNode release];
    [xNodes release];
    [xmlParser release];
    [super dealloc];
}


- (void)start:(NSString *)theData {
   
    NSString *encapsulatedResponse = [NSString stringWithFormat:@"<xcat>%@</xcat>", theData];

   // NSLog(@"encapsolated Response: %@", encapsulatedResponse);
    xmlParser = [[NSXMLParser alloc] initWithData:[encapsulatedResponse dataUsingEncoding:NSUTF8StringEncoding]];
    [xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];

}

#pragma mark NSXMLParser Parsing Callbacks
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    //NSLog(@"Starting to parse");
    
}


- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    NSLog(@"This is not a valid XML doc!");
}


- (void)parserDidEndDocument:(NSXMLParser *)parser {
    //NSLog(@"Finished parsing");
   
}



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    
    
    if ([elementName isEqualToString:@"name"]) {
        currentElement = nil;
        return;
    }
    
    if ([elementName isEqualToString:@"contents"]) {
        currentElement = nil;
        return;
    }
    
    if ([elementName isEqualToString:@"desc"]) {
        currentElement = nil;
        return;
    }
    
    // Node is the beginning of a new xml packet of information.
    if ([elementName isEqualToString:@"node"]) {
        //NSLog(@"starting new node");
        // this is the beginning of a new node.
        xNode = [[xCATNode alloc] init ];
        currentElement = nil;
        return;
    }
    
    
    if ([elementName isEqualToString:@"error"]) {
        currentElement = nil;
        return;
    }
    
    // right now we don't do much with data but go deeper into it
    if ([elementName isEqualToString:@"data"]) {
        currentElement = nil;
        return;
    }
    
    if ([elementName isEqualToString:@"serverdone"]) {
        currentElement = nil;
        return;
    }
    /*
    if ([elementName isEqualToString:@"errorcode"]) {
        currentElement = nil;
        return;
    }
     */
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (! currentElement) {
        currentElement = [[NSMutableString alloc] initWithCapacity:50];
    }
    // get rid of new lines and white space.
    //NSLog(@"Found characters: %@", string);
    [currentElement appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"node"]) {
        //NSLog(@"Ending New node");
        // this means we're done getting the information.
        if (!xNodes) {
           // NSLog(@"Creating a new xNodes array");
            xNodes = [[NSMutableArray alloc] initWithObjects:xNode , nil ];
        }else {
            [xNodes addObject:xNode];
        }
        //NSLog(@"Current xNode: %@, power status: %@", xNode.name, xNode.contents);
        [xNode release];
        [currentElement release];
        
    }
    
    // get node name here.
    if ([elementName isEqualToString:@"name"]) {
        xNode.name = currentElement;
    }
    
    // get contents here.
    if ([elementName isEqualToString:@"contents"]) {
        xNode.contents = currentElement;
        
    }
    
    if ([elementName isEqualToString:@"desc"]) {
        xNode.desc = currentElement;
    }
    
    if ([elementName isEqualToString:@"data"]) {
        xNode.data = currentElement;
    }
    
    // case of bad authentication
    
    if([@"error" isEqualToString:elementName]){
        // If this is a login Error signal to message center.
        if ([currentElement isEqualToString:@"Authentication failure"]) {
            //NSLog(@"Authentication Error");
            thereAreErrors = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetAuthenticationError" object:nil];

        }else {
            NSLog(@"Error is: %@", currentElement);
            xNode.xError = currentElement;
            NSLog(@"XNode.name: %@", xNode.name);
        }
    }
    /*
    if ([elementName isEqualToString:@"errorcode"]) {
        NSLog(@"Errorcode is: %@", currentElement);
    }
     */
   
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *uhoh = [[UIAlertView alloc] initWithTitle:@"Invalid Response from xCAT Server" message:[parseError localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [uhoh show];
        [uhoh release];
    });
}

@end
