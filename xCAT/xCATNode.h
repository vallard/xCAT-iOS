//
//  Node.h
//  xCAT
//
//  Created by Vallard Benincosa on 10/27/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kUnknown,
    kOff,
    kOn,
    kError
    } PowerState;


@interface xCATNode : NSObject {
    NSString *name;
    PowerState powerState;
    PowerState beaconState;
    NSString *statusMessage;
    NSString *contents;
    NSString *desc;
    NSString *xError;
    NSString *data;
    NSString *nodeStat;
    NSDictionary *events;
    NSDictionary *inv;
    NSDictionary *vitals;
}

@property PowerState powerState;
@property PowerState beaconState;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) NSString *data; // this is for commands like nodestat that just return data
@property (nonatomic, retain) NSString *desc;  // some output gives it in desc
@property (nonatomic, retain) NSString *contents;
@property (nonatomic, retain) NSString *xError;
@property (nonatomic, retain) NSString *nodeStat;
@property (nonatomic, retain) NSDictionary *events;  // for event log caching. date is the key.
@property (nonatomic, retain) NSDictionary *inv;
@property (nonatomic, retain) NSDictionary *vitals;


- (id)initWithName:(NSString *)theName;
- (NSString *)statToString;
- (NSString *)beaconStat;

@end
