//
//  MainViewController.h
//  Vanilla3.0
//
//  Created by BAO on 13-12-10.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addTravelViewDelegate.h"

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,addTravelViewDelegate> {
    UIImageView     *_imageView;
    UIScrollView    *_imageScroller;
    UITableView     *_tableView;
    
}
@property NSMutableArray *content;
@property (nonatomic) BOOL haveTravels;
@end
