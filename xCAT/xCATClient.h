//
//  xCATClient.h
//  xCAT
//
//  Created by Vallard Benincosa on 9/3/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

@interface xCATClient : NSObject <NSStreamDelegate> {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    //NSData *theData;
    NSString *theData;
    NSString *theOutput;
    NSString *cmd;
    Connection *myConn;
    
}
@property (nonatomic,retain) NSInputStream *inputStream;
@property (nonatomic,retain) NSOutputStream *outputStream;
@property (nonatomic,retain) NSString *theData;
@property (nonatomic,copy) NSString *theOutput;
@property (nonatomic,copy) NSString *cmd;
@property (nonatomic, retain) Connection *myConn;

- (void)handleOutputStream:(NSStreamEvent)eventCode;
- (void)handleInputStream:(NSStreamEvent)eventCode;
- (id)initWithConnection:(Connection *)connection;
- (void)runCmd:(NSString *)command noderange:(NSString *)nr arguments:(NSArray *)args;
- (void)startConnection;
@end
