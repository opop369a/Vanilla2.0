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

-(IBAction)addPiece:(id)sender;

@end
