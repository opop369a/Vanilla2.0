//
//  addTravelViewDelegate.h
//  Vanilla3.0
//
//  Created by BAO on 13-12-10.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface addTravelViewDelegate : NSObject

@end
@protocol addTravelViewDelegate <NSObject>
@required -(void) done:(NSDictionary*)dictionary;
@end
