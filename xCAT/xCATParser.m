//
//  xCATParser.m
//  xCAT
//
//  Created by Vallard Benincosa on 9/9/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "xCATParser.h"

@implementation xCATParser

@synthesize nodes;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)dealloc {
    [currentElement release];
    [currentNode release];
    [nodes release];
    [xmlParser release];
    [super dealloc];
}


- (void)start:(NSString *)theData {
    nodes = [[NSMutableArray alloc] init ];
    NSString *encapsulatedResponse = [NSString stringWithFormat:@"<xcat>%@</xcat>", theData];
    xmlParser = [[NSXMLParser alloc] initWithData:[encapsulatedResponse dataUsingEncoding:NSUTF8StringEncoding]];
    [xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
}

#pragma mark NSXMLParser Parsing Callbacks
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"Starting to parse", nil);
    
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"starting element %@", elementName);
    if ([elementName isEqualToString:@"name"]) {
        currentElement = nil;
        currentNode = nil;
        return;
    }
    
    if ([elementName isEqualToString:@"error"]) {
        currentElement = nil;
        return;
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (! currentElement) {
        currentElement = [[NSMutableString alloc] initWithCapacity:50];
    }
    [currentElement appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"node"]) {
        [nodes addObject:currentElement];
        [currentElement release];
    }
    
    if([elementName isEqualToString:@"error"]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *uhoh = [[UIAlertView alloc] initWithTitle:@"xCAT Error" message:currentElement delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [uhoh show];
            [uhoh release];
            [currentElement release];
            
        });
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *uhoh = [[UIAlertView alloc] initWithTitle:@"Invalid Response from xCAT Server" message:[parseError localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [uhoh show];
        [uhoh release];
    });
}

@end
