//
//  Node.m
//  xCAT
//
//  Created by Vallard Benincosa on 10/27/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "xCATNode.h"

@implementation xCATNode
@synthesize name;
@synthesize powerState;
@synthesize statusMessage;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithName:(NSString *)theName {
    self = [super init];
    if (self) {
        name = theName;
        powerState = kUnknown;
        statusMessage = @"Querying Power status...";
    }
    return self;
}

- (void)dealloc {
    [name release];
    [statusMessage release];
    [super dealloc];
}

@end
