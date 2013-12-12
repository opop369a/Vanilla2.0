//
//  TravelPieceDetailViewController.m
//  Vanilla_2.0
//
//  Created by 王晨Clark on 13-12-9.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import "TravelPieceDetailViewController.h"
#import "SpotAnnotation.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "QBImagePickerController.h"
#import "TravelItem.h"

@interface TravelPieceDetailViewController ()

@end

@implementation TravelPieceDetailViewController

@synthesize coordinate;
@synthesize spot;
@synthesize imageView1;
@synthesize imageView2;
@synthesize imageView3;
@synthesize mapView;
@synthesize descriptionView;

@synthesize delegate;
@synthesize itemToEdit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        description = @"";
        images = [[NSMutableArray alloc] initWithCapacity:3];
        PhotoCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (itemToEdit != nil) {
        self.title = @"编辑记录";
        self.coordinate = itemToEdit.coordinate;
        self.spot = itemToEdit.spot;
        images = itemToEdit.images;
        PhotoCount = [images count];
        if (PhotoCount>0) {
            hasPhoto = TRUE;
        }else{
            hasPhoto = FALSE;
        }
        description = itemToEdit.description;
        [self showMultiImages];
    }
    
    mapView.delegate = self;
    MKCoordinateRegion region = [mapView region];
    region.center = coordinate;
    region.span.latitudeDelta = 0.02;
    region.span.longitudeDelta = 0.02;
    [mapView setRegion:region animated:YES];
    
    
    SpotAnnotation *ann = [[SpotAnnotation alloc] init];
    [ann setCoordinate:coordinate];
    [ann setTitle:spot];
    [mapView addAnnotation:ann];
    
    descriptionView.text = description;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.delegate travelPieceDetailViewControllerDidCancel:self];
}
- (IBAction)done:(id)sender
{
    if (itemToEdit == nil) {
         description = self.descriptionView.text;
         TravelItem *item = [[TravelItem alloc] initWithDate:[NSDate date] spot:spot latitude:coordinate.latitude longitude:coordinate.longitude description:description images:images];
    
         [self.delegate travelPieceDetailViewController:self didFinishAddingItem:item];
    } else {
         self.itemToEdit.description = self.descriptionView.text;
         self.itemToEdit.images = images;
         [self.delegate travelPieceDetailViewController:self didFinishEditingItem:self.itemToEdit];
    }
   }

- (IBAction)uploadFromLibrary:(id)sender
{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.filterType = QBImagePickerFilterTypeAllPhotos;
    imagePickerController.showsCancelButton = YES;
    imagePickerController.fullScreenLayoutEnabled = YES;
    imagePickerController.allowsMultipleSelection = YES;
    
    imagePickerController.limitsMaximumNumberOfSelection = YES;
    imagePickerController.maximumNumberOfSelection = 3;
    
    UINavigationController *navigationController=[[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self.navigationController presentViewController:navigationController animated:YES completion:NULL];

}

- (IBAction)uploadFromCamera:(id)sender
{
    if (PhotoCount>2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"图片不能超过三张哦=。=" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"记录美好瞬间...";
    }else if (section == 1) {
        return spot;
    }else if (section == 2) {
        return @"这一刻，你的感受...";
    }else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (hasPhoto) {
            return 108;
        } else {
            return 0;
        }
    }
    
    if (indexPath.section == 1) {
        return 200;
    }
    
    if (indexPath.section == 2) {
        return 88;
    }
    
    return 44;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [images addObject:img];
    
    PhotoCount++;
    
    hasPhoto = true;
    
    [self showMultiImages];
    
    [self.tableView reloadData];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMultiImages
{
    self.imageView1.image = nil;
    self.imageView2.image = nil;
    self.imageView3.image = nil;
    
    if (PhotoCount>0) {
        self.imageView1.image = [images objectAtIndex:0];
        self.imageView1.hidden=NO;
    }
    if (PhotoCount>1) {
        self.imageView2.image = [images objectAtIndex:1];
        self.imageView2.hidden=NO;
    }
    if (PhotoCount>2) {
        self.imageView3.image = [images objectAtIndex:2];
        self.imageView3.hidden=NO;
    }
}

- (void)QBImagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    if (imagePickerController.allowsMultipleSelection) {
        
        NSArray *mediaInfoArray = (NSArray *)info;
        NSInteger countOfPhotos = mediaInfoArray.count;
        NSLog(@"Selected %ld photos", (long)countOfPhotos);
        
        PhotoCount = countOfPhotos;
        
        if ([images count]>0) {
            [images removeAllObjects];
        }
        
        for (NSDictionary* infoDict in mediaInfoArray) {
            UIImage *img = [infoDict objectForKey:UIImagePickerControllerOriginalImage];
            [images addObject:img];
        }
        
        hasPhoto = true;
        
        [self showMultiImages];
        [self.tableView reloadData];
        
    } else {
        
        NSDictionary *mediaInfo = (NSDictionary *)info;
        NSLog(@"Selected: %@", mediaInfo);
        
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)QBImagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"Cancel");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    description = [descriptionView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    description = descriptionView.text;
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath != nil && indexPath.section == 2 && indexPath.row == 0) {
        return;
    }
    
    [self.descriptionView resignFirstResponder];
}

@end
