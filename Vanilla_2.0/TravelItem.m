//
//  TravelItem.m
//  Vanilla_2.0
//
//  Created by 王晨Clark on 13-12-7.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import "TravelItem.h"

@implementation TravelItem

- (void)setImages:(NSMutableArray *)images
{
    _images = [images mutableCopy];
}

- (id)initWithDate:(NSDate *)date spot:(NSString *)spot latitude:(float)latitude longitude:(float)longitude description:(NSString *)description images:(NSMutableArray *)images
{
    if (self = [super init]) {
        self.date = date;
        self.spot = spot;
        self.coordinate =CLLocationCoordinate2DMake(latitude, longitude);
        self.description = description;
        self.images = images;
    }
    
    return self;
}

@end
