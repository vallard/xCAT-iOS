//
//  Node.h
//  xCAT
//
//  Created by Vallard Benincosa on 10/27/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kOff,
    kOn,
    kUnknown,
    kError
    } PowerState;

@interface xCATNode : NSObject {
    NSString *name;
    PowerState powerState;
    NSString *statusMessage;
}
@property PowerState powerState;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *statusMessage;

- (id)initWithName:(NSString *)theName;


@end
