//
//  addTravelViewController.h
//  Vanilla3.0
//
//  Created by BAO on 13-12-10.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addTravelViewDelegate.h"


@interface addTravelViewController : UITableViewController<UITextFieldDelegate ,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ideasTextView;
@property(strong,nonatomic) id<addTravelViewDelegate> delegate;
- (void)viewDidLoad;
@end


