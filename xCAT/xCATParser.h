//
//  xCATParser.h
//  xCAT
//
//  Created by Vallard Benincosa on 9/9/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  xCATNode;
@interface xCATParser : NSObject <NSXMLParserDelegate> {
    NSXMLParser *xmlParser;
    NSMutableString *currentElement;
    xCATNode *xNode;
    NSMutableArray *xNodes;
    BOOL thereAreErrors;
}

@property (retain, nonatomic) NSMutableArray *xNodes;

@property ( nonatomic) BOOL thereAreErrors;


- (void)start:(NSString *)theData;
@end
