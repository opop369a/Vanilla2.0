//
//  TravelItem.h
//  Vanilla_2.0
//
//  Created by 王晨Clark on 13-12-7.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TravelItem : NSObject

@property(nonatomic, assign) NSInteger pid;
@property(nonatomic, copy) NSDate *date;
@property(nonatomic, copy) NSString *spot;
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *description;
@property(nonatomic, copy) NSMutableArray *images;
@property(nonatomic, copy) NSMutableArray *imageURLs;

- (id)initWithDate:(NSDate *)date spot:(NSString *)spot latitude:(float)latitude longitude:(float)longitude description:(NSString *)description images:(NSMutableArray *)images;

- (id)initWithDateString:(NSString *)dateString spot:(NSString *)spot latitude:(float)latitude longitude:(float)longitude description:(NSString *)description imageURLs:(NSMutableArray *)imageURLs pid:(NSInteger)pid;

@end
