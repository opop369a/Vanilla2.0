//
//  TravelPieceManageController.m
//  Vanilla_2.0
//
//  Created by BAO on 13-12-7.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import "TravelPieceManageController.h"
#import "TravelItem.h"
#import "SpotAnnotation.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TravelPieceDetailViewController.h"
#import "UIImageView+AFNetworking.h"


static NSString * const BaseURL = @"http://172.17.228.37/~ClarkWong/vanilla/";

@interface TravelPieceManageController ()

@end

@implementation TravelPieceManageController

@synthesize tid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    isShowMe = false;
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0 , 0, 330, 250)];
   
    //开始定位
    //[self startUpdates];
    
    _mapView.delegate = self;
    
    [_mapView setShowsUserLocation:TRUE];
    
    travelItems = [[NSMutableArray alloc] initWithCapacity:20];
    itemAnnotations = [[NSMutableArray alloc] initWithCapacity:20];
    
    [self getPiecesFromServer:tid];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPiece:(id)sender
{
    if (user_spot) {
        [self performSegueWithIdentifier:@"addPiece" sender:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位失败" message:@"当前尚未获得用户地理位置，请检查网络连接，稍后再试哦=。=" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

}

#pragma -mark AFNetworking

- (void)getPiecesFromServer:(NSInteger)travelid
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:BaseURL]];
    NSDictionary *parameters = @{@"tid":@1};
    [manager POST:@"getPieces.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"Success: %@", operation.responseString);
        
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"%@", resultDic);
        NSArray *pieces = [resultDic objectForKey:@"pieces"];
        for (NSDictionary *pdict in pieces) {
            //NSLog(@"%@", pdict);
            NSString *s_date = [pdict objectForKey:@"date"];
            NSString *spot = [pdict objectForKey:@"spot"];
            NSString *description = [pdict objectForKey:@"description"];
            NSMutableArray *images = [pdict objectForKey:@"images"];
            float latitude =[(NSNumber *)[pdict objectForKey:@"latitude"] floatValue];
            float longitude =[(NSNumber *)[pdict objectForKey:@"longitude"] floatValue];
            NSInteger pid = [[pdict objectForKey:@"pid"] integerValue];
            NSLog(@"date:%@", s_date);
            NSLog(@"spot:%@", spot);
            NSLog(@"description:%@", description);
            NSLog(@"latitude:%f", latitude);
            NSLog(@"longitude:%f", longitude);
            NSLog(@"images:%@", images);
            NSLog(@"pid:%ld", (long)pid);
            TravelItem *item = [[TravelItem alloc]initWithDateString:s_date spot:spot latitude:latitude longitude:longitude description:description imageURLs:images pid:pid];
            [travelItems addObject:item];
        }
        [self addAnnotations];
        [_mapView addOverlay:[self makePolylineWithLocations:travelItems]];
        [self.tableView reloadData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)deletePieceFromServer:(NSInteger)pid
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:BaseURL]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSNumber *o_pid = [[NSNumber alloc] initWithInteger:pid];
    NSDictionary *parameters = @{@"pid":o_pid};
    [manager POST:@"deletePiece.php" parameters:parameters success:
     ^(AFHTTPRequestOperation *operation, id responseObject){
         NSLog(@"%@", [operation responseString]);
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%@", error);
     }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [travelItems count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell= [[UITableViewCell alloc] init];
        [[cell contentView] addSubview:_mapView];
        return cell;
    }else{
        UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"TravelManageItem"];
        UILabel *datelabel = (UILabel *)[cell viewWithTag:1001];
        UILabel *spotLabel = (UILabel *)[cell viewWithTag:1002];
        UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:1003];
        UIImageView *imageView =(UIImageView *)[cell viewWithTag:1000];
    
        TravelItem *item = [travelItems objectAtIndex:indexPath.row-1];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        datelabel.text = [dateFormatter stringFromDate:item.date];
        spotLabel.text = item.spot;
        descriptionLabel.text = item.description;
        if ([item.imageURLs count]>0) {
            NSString *imgstr = [BaseURL stringByAppendingString:[item.imageURLs objectAtIndex:0]];
            NSURL *imgurl = [[NSURL alloc] initWithString:imgstr];
            [imageView setImageWithURL:imgurl placeholderImage:[UIImage imageNamed:@"loading.png"]];
        }else{
            imageView.image = nil;
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 250;
    }else{
        return 109;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row>0) {
         TravelItem *item = [travelItems objectAtIndex:indexPath.row-1];
         [self performSegueWithIdentifier:@"editPiece" sender:item];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == 0) {
        return NO;
    }else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
        TravelItem *itemTodelete = [travelItems objectAtIndex:indexPath.row-1];
        NSInteger pid = itemTodelete.pid;
        [self deletePieceFromServer:pid];
    
        [travelItems removeObjectAtIndex:indexPath.row-1];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        SpotAnnotation *ann = [itemAnnotations objectAtIndex:indexPath.row-1];
        [_mapView removeAnnotation:ann];
        [itemAnnotations removeObject:ann];
        
        [_mapView removeOverlay:routeLine];
        [_mapView addOverlay:[self makePolylineWithLocations:travelItems]];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
//    if (0.00001>[mapView userLocation].location.coordinate.latitude) {
//        [self performSelector:@selector(mapViewDidFinishLoadingMap:)withObject:mapView afterDelay:1.0];
//        return;
//    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!isShowMe) {
    user_location =[mapView userLocation].location.coordinate;
    MKCoordinateRegion region = [mapView region];
    region.center = user_location;
    region.span.latitudeDelta = 0.04;
    region.span.longitudeDelta = 0.04;
    [mapView setRegion:region animated:YES];
    
    NSLog(@"lat:%f lng:%f",region.center.latitude, region.center.longitude);
    
    if (user_current_annotation!=nil) {
        [mapView removeAnnotation:user_current_annotation];
    }
    user_current_annotation = [[SpotAnnotation alloc] init];
    [user_current_annotation setCoordinate:user_location];
    
    [self doRevGeocodeUsingLat:[mapView userLocation].location.coordinate.latitude andLng:[mapView userLocation].location.coordinate.longitude withAnnotation:user_current_annotation];
    [mapView addAnnotation:user_current_annotation];
        
    isShowMe = false;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[SpotAnnotation class]]) {
        return nil;
    }
    
    NSString *dqref = @"spotanno";
    id annoview = [mapView dequeueReusableAnnotationViewWithIdentifier:dqref];
    if (annoview == nil) {
        annoview = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:dqref];
        [annoview setPinColor:MKPinAnnotationColorRed];
        [annoview setAnimatesDrop:YES];
        [annoview setCanShowCallout:YES];
    }
    return annoview;
}

- (void)doRevGeocodeUsingLat:(float)lat andLng:(float)lng withAnnotation:(SpotAnnotation *)annotation
{
    CLLocation *c = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    [revGeo reverseGeocodeLocation:c completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && [placemarks count]>0) {
            NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
            user_spot = [dict objectForKey:@"Street"];
            NSLog(@"street address:%@", user_spot);
            [annotation setTitle:[dict objectForKey:@"Street"]];
        }else
        {
            NSLog(@"Error:%@", error);
        }
    }];
}

- (void)startUpdates
{
    if (locationManager == nil)
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.activityType = CLActivityTypeFitness;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.distanceFilter = 100;
        [locationManager startUpdatingLocation];
}

#pragma location

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * curLocation = [locations lastObject];
    NSLog(@"lat:%f", curLocation.coordinate.latitude);
    NSLog(@"lgn:%f", curLocation.coordinate.longitude);
    
}

- (void)addAnnotations
{
    NSInteger n = [travelItems count];
    for (int i=0; i<n; i++) {
        TravelItem * item = [travelItems objectAtIndex:i];
        SpotAnnotation * ann = [[SpotAnnotation alloc] init];
        [ann setTitle:item.spot];
        [ann setCoordinate:item.coordinate];
        [itemAnnotations addObject:ann];
        [_mapView addAnnotation:ann];
    }
}

- (MKPolyline *)makePolylineWithLocations:(NSMutableArray *)newLocations{
    MKMapPoint *pointArray = malloc(sizeof(CLLocationCoordinate2D)* newLocations.count);
    for(int i = 0; i < newLocations.count; i++)
    {
        // break the string down even further to latitude and longitude fields.
        TravelItem * currentPoint = [newLocations objectAtIndex:i];
        
        CLLocationCoordinate2D coordinate = currentPoint.coordinate;
        //        NSLog(@"point-> %f", point.x);
        
        pointArray[i] = MKMapPointForCoordinate(coordinate);
    }
    
    routeLine = [MKPolyline polylineWithPoints:pointArray count:newLocations.count];
    free(pointArray);
    return routeLine;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    NSLog(@"return overLayView...");
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *routeLineView = [[MKPolylineView alloc] initWithPolyline:routeLine];
        routeLineView.strokeColor = [UIColor greenColor];
        routeLineView.lineWidth = 8;
        return routeLineView;
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addPiece"]) {
        UINavigationController *navi = segue.destinationViewController;
        TravelPieceDetailViewController *travelPieceDetail = (TravelPieceDetailViewController *)navi.topViewController;
        
        travelPieceDetail.spot = user_spot;
        travelPieceDetail.coordinate = user_location;
        travelPieceDetail.tid = tid;
        travelPieceDetail.delegate = self;
    }else if ([segue.identifier isEqualToString:@"editPiece"]) {
        UINavigationController *navi = segue.destinationViewController;
        TravelPieceDetailViewController *travelPieceDetail = (TravelPieceDetailViewController *)navi.topViewController;
        
        travelPieceDetail.tid = tid;
        travelPieceDetail.delegate = self;
        travelPieceDetail.itemToEdit = sender;
    }
}

#pragma mark - TravelPieceDetailViewControllerDelegate

- (void)travelPieceDetailViewController:(TravelPieceDetailViewController *)controller didFinishAddingItem:(TravelItem *)item
{
    NSInteger newRowIndex = [travelItems count]+1;
    [travelItems addObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    SpotAnnotation * ann = [[SpotAnnotation alloc] init];
    [ann setTitle:item.spot];
    [ann setCoordinate:item.coordinate];
    [itemAnnotations addObject:ann];
    [_mapView addAnnotation:ann];
    
    [_mapView removeOverlay:routeLine];
    [_mapView addOverlay:[self makePolylineWithLocations:travelItems]];
}

- (void)travelPieceDetailViewController:(TravelPieceDetailViewController *)controller didFinishEditingItem:(TravelItem *)item
{
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)travelPieceDetailViewControllerDidCancel:(TravelPieceDetailViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)TravelPieceDetailViewControllerUpdateData:(TravelPieceDetailViewController *)controller
{
    [self.tableView reloadData];
}
@end
