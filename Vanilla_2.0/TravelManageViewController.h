//
//  TravelManageViewController.h
//  Vanilla3.0
//
//  Created by BAO on 13-12-10.
//  Copyright (c) 2013年 Bao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addTravelViewDelegate.h"

@interface TravelManageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,addTravelViewDelegate> {
    UIImageView     *_imageView;
    UIScrollView    *_imageScroller;
    UITableView     *_tableView;
}
-(void) done:(NSDictionary*) dictionary;
@property NSMutableArray *content;
@end
