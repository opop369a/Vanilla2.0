//
//  TravelPieceDetailViewController.h
//  Vanilla_2.0
//
//  Created by 王晨Clark on 13-12-9.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "QBImagePickerController.h"

@class TravelPieceDetailViewController;
@class TravelItem;

@protocol TravelPieceDetailViewControllerDelegate <NSObject>

- (void)travelPieceDetailViewControllerDidCancel:(TravelPieceDetailViewController *)controller;

- (void)travelPieceDetailViewController:(TravelPieceDetailViewController *)controller didFinishAddingItem:(TravelItem *)item;

- (void)travelPieceDetailViewController:(TravelPieceDetailViewController *)controller didFinishEditingItem:(TravelItem *)item;

@end

@interface TravelPieceDetailViewController : UITableViewController
                                            <MKMapViewDelegate,
                                             UIImagePickerControllerDelegate,
                                             UINavigationControllerDelegate,
                                             UITextViewDelegate,
                                             QBImagePickerControllerDelegate>
{
    
    BOOL hasPhoto;
    NSMutableArray *images;
    NSInteger PhotoCount;
    NSString *description;
    
}
@property (nonatomic, assign)CLLocationCoordinate2D coordinate;
@property (nonatomic, copy)NSString *spot;

@property (nonatomic, weak)id<TravelPieceDetailViewControllerDelegate> delegate;
@property (nonatomic, strong)TravelItem *itemToEdit;

@property (nonatomic, strong) IBOutlet UIImageView* imageView1;
@property (nonatomic, strong) IBOutlet UIImageView* imageView2;
@property (nonatomic, strong) IBOutlet UIImageView* imageView3;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UITextView *descriptionView;

-(IBAction)cancel:(id)sender;
-(IBAction)done:(id)sender;
-(IBAction)uploadFromLibrary:(id)sender;
-(IBAction)uploadFromCamera:(id)sender;

@end
