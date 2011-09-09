//
//  Connection.m
//  xCAT
//
//  Created by Vallard Benincosa on 9/3/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "Connection.h"

@implementation Connection
@synthesize user;
@synthesize passwd;
@synthesize host;
@synthesize port;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithUser:(NSString *)theUser passwd:(NSString *)thePasswd host:(NSString *)theHost port:(UInt32)thePort{
    self = [super init];
    if (self) {
        self.user = theUser;
        self.passwd = thePasswd;
        self.host = theHost;
        self.port = thePort;
    }
    
    return self;
}

- (void)dealloc {
    [user release];
    [passwd release];
    [super dealloc];
}
@end
