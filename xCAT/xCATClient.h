//
//  xCATClient.h
//  xCAT
//
//  Created by Vallard Benincosa on 9/3/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface xCATClient : NSObject <NSStreamDelegate> {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString *theData;
}
@property (nonatomic,retain) NSInputStream *inputStream;
@property (nonatomic,retain) NSOutputStream *outputStream;
@property (nonatomic,copy) NSString *theData;

- (void)handleOutputStream:(NSStreamEvent)eventCode;
- (void)handleInputStream:(NSStreamEvent)eventCode;
@end
