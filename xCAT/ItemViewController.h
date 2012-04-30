//
//  ItemViewController.h
//  xCAT
//
//  Created by Vallard Benincosa on 1/21/12.
//  Copyright (c) 2012 Benincosa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemViewController : UIViewController {
    UILabel *itemLabel;
    NSString *item;
}

@property (nonatomic, retain) IBOutlet UILabel *itemLabel;
@property (nonatomic, retain) NSString *item;

@end
