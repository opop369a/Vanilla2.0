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

- (void)setImageURLs:(NSMutableArray *)imageURLs
{
    _imageURLs = [imageURLs mutableCopy];
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

- (id)initWithDateString:(NSString *)dateString spot:(NSString *)spot latitude:(float)latitude longitude:(float)longitude description:(NSString *)description imageURLs:(NSMutableArray *)imageURLs pid:(NSInteger)pid
{
    if (self = [super init]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        self.date = [formatter dateFromString:dateString];
        self.spot = spot;
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        self.description = description;
        self.imageURLs = imageURLs;
        self.pid = pid;
    }
    return self;
}

@end
