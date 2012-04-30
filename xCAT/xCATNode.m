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
@synthesize beaconState;
@synthesize statusMessage;
@synthesize nodeStat;
@synthesize contents;
@synthesize desc;
@synthesize data;
@synthesize xError;
@synthesize events;
@synthesize inv;
@synthesize vitals;


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
        statusMessage = @"collecting status...";
    }
    return self;
}

- (void)dealloc {
    [xError release];
    [contents release];
    [desc release];
    [name release];
    [statusMessage release];
    [data release];
    [nodeStat release];
    [super dealloc];
}

- (NSString *)statToString {
    switch (self.powerState) {
        case kOff:
            return @"off";
            break;
        case kOn:
            return @"on";
            break;
        case kError:
            return @"error";
            break;
        case kUnknown:
            return @"unknown";
            break;
        default:
            return nil;
            break;
    }
    return  nil;
    
}

- (NSString *)beaconStat {
    switch (self.beaconState) {
        case kOff:
            return @"off";
            break;
        case kOn:
            return @"on";
            break;
        case kError:
            return @"error";
            break;
        case kUnknown:
            return @"unknown";
            break;
        default:
            return nil;
            break;
    }
    return  nil;
}


@end
