//
//  Connection.h
//  xCAT
//
//  Created by Vallard Benincosa on 9/3/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Connection : NSObject {
    NSString *user;
    NSString *passwd;
    NSString *host;
    UInt32 port;
}
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *passwd;
@property (nonatomic, copy) NSString *host;
@property UInt32 port;

//- (id)initWithUser:theUser passwd:thePasswd host:theHost port:thePort;
- (id)initWithUser:(NSString *)theUser passwd:(NSString *)thePasswd host:(NSString  *)theHost port:(UInt32)thePort;
@end
