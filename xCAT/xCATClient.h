//
//  xCATClient.h
//  xCAT
//
//  Created by Vallard Benincosa on 9/3/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

#define kConnectionTimeOut 10.0
@interface xCATClient : NSObject <NSStreamDelegate> {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    //NSData *theData;
    NSString *theData;
    NSString *theOutput;
    NSString *cmd;
    Connection *myConn;
    NSTimer *connectionTimeoutTimer;
    int timesCalled;
    NSString *identifier;  // key used to identify this xCAT client.
    NSString *command;
    NSString *noderange;
    NSString *args;
    
}
@property (nonatomic,retain) NSInputStream *inputStream;
@property (nonatomic,retain) NSOutputStream *outputStream;
@property (nonatomic,retain) NSString *theData;
@property (nonatomic,copy) NSString *theOutput;
@property (nonatomic,copy) NSString *cmd;
@property (nonatomic, retain) Connection *myConn;
@property (nonatomic, retain) NSString *identifier;

@property (nonatomic, retain) NSString *command;
@property (nonatomic, retain) NSString *noderange;
@property (nonatomic, retain) NSString *args;

- (void)handleOutputStream:(NSStreamEvent)eventCode;
- (void)handleInputStream:(NSStreamEvent)eventCode;
- (id)initWithConnection:(Connection *)connection;
- (void)runCmd:(NSString *)command noderange:(NSString *)nr arguments:(NSArray *)args;
- (void)startConnection;
- (void)closeConnection;
- (void)stopConnectionTimeoutTimer;
- (void)startConnectionTimeoutTimer;
- (void)connectionDidTimeOut;
- (void)serverDidFinishResponding;
@end
