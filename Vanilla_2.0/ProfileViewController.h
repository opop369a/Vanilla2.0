//
//  ProfileViewController.h
//  Vanilla3.0
//
//  Created by BAO on 13-12-10.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController :   UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UIImageView     *_imageView;
    UIScrollView    *_imageScroller;
    UITableView     *_tableView;
}

//- (id)initWithImage:(UIImage *)image;
@property NSArray *supports;
@property NSDictionary *userinfo;
@property        NSString    *headUrl;
@end
