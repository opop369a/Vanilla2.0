//
//  TravelPieceManageController.h
//  Vanilla_2.0
//
//  Created by BAO on 13-12-7.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SpotAnnotation.h"
#import "TravelPieceDetailViewController.h"

@class TravelPieceManageController;

@protocol TravelPieceManageViewControllerDelegate <NSObject>

-(void)TravelPieceManageViewControllerUpdateData:(TravelPieceManageController *)controller;


@end
@interface TravelPieceManageController : UITableViewController <MKMapViewDelegate,
                                                           TravelPieceDetailViewControllerDelegate,
                                                           CLLocationManagerDelegate>
{
    NSMutableArray *travelItems;
    NSMutableArray *itemAnnotations;
    CLLocationManager *locationManager;
    MKMapView *_mapView;
    MKPolyline *routeLine;
    CLLocationCoordinate2D user_location;
    NSString * user_spot;
    SpotAnnotation *user_current_annotation;
    
    bool isShowMe;
    
}

@property(nonatomic, assign) NSInteger tid;
@property (nonatomic, weak)id<TravelPieceManageViewControllerDelegate> delegate;

-(IBAction)addPiece:(id)sender;

@end
