//
//  xCATParser.h
//  xCAT
//
//  Created by Vallard Benincosa on 9/9/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface xCATParser : NSObject <NSXMLParserDelegate> {
    NSXMLParser *xmlParser;
    NSMutableString *currentElement;
    NSString *currentNode;
    NSMutableArray *nodes;
    BOOL thereAreErrors;
}

@property (retain, nonatomic) NSMutableArray *nodes;
@property ( nonatomic) BOOL thereAreErrors;


- (void)start:(NSString *)theData;
@end
