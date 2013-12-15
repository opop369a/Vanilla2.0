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
#import "UIImageView+AFNetworking.h"

static NSString * const BaseURL = @"http://172.17.228.37/~ClarkWong/vanilla/";

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
@synthesize tid;

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
        spot = @"";
        images = [[NSMutableArray alloc] initWithCapacity:3];
        imageURLs = [[NSMutableArray alloc] initWithCapacity:3];
        PhotoCount = 0;
        pid = 0;
        tid = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    imageViews = [[NSArray alloc] initWithObjects:imageView1, imageView2, imageView3, nil];
    
    if (itemToEdit != nil) {
        self.title = @"编辑记录";
        NSLog(@"%@", itemToEdit.imageURLs);
        self.coordinate = itemToEdit.coordinate;
        self.spot = itemToEdit.spot;
        imageURLs = itemToEdit.imageURLs;
        PhotoCount = [imageURLs count];
        pid = itemToEdit.pid;
        if (PhotoCount>0) {
            hasPhoto = TRUE;
        }else{
            hasPhoto = FALSE;
        }
        description = itemToEdit.description;
        [self showURLImages];
    } else {
        self.title = @"新增记录";
        hasPhoto = FALSE;
        NSLog(@"%@", spot);
        NSLog(@"%f", coordinate.latitude);
        NSLog(@"%f", coordinate.longitude);
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

- (void)uploadImage:(UIImage *)image withFileName:(NSString *)fileName
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:BaseURL]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    NSString *imageurl = [NSString stringWithFormat:@"Image/%@", fileName];
    NSNumber *o_pid = [[NSNumber alloc]initWithInteger:pid];
    NSDictionary *parameters = @{@"pid": o_pid, @"imgurl":imageurl};
    
    [manager POST:@"upload.php" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", [operation responseString]);
        [self.delegate TravelPieceDetailViewControllerUpdateData:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)uploadImagesToServer
{
    if ([images count]>0) {
        for (UIImage *image in images) {
            NSNumber *timeval = [[NSNumber alloc]initWithDouble:[NSDate timeIntervalSinceReferenceDate]*1000000];
            NSString *fileName = [NSString stringWithFormat:@"%lld.jpg", timeval.longLongValue];
            NSString *filePath = [NSString stringWithFormat:@"Image/%@", fileName];
            NSLog(@"%@", fileName);
            [self uploadImage:image withFileName:fileName];
            [imageURLs addObject:filePath];
            
        }
        
    } else {
        return;
    }
}

- (void)uploadNewPieceToServerWithSpot:(NSString *)pspot Description:(NSString *)pdescription Latitude:(float)latitude Longitude:(float)longitude DateString:(NSString *)dateString Travelid:(NSInteger)ptid
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:BaseURL]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSNumber *o_latitude = [[NSNumber alloc] initWithFloat:latitude];
    NSNumber *o_longitude = [[NSNumber alloc] initWithFloat:longitude];
    NSNumber *o_tid = [[NSNumber alloc] initWithInteger:ptid];
    NSDictionary *parameters = @{@"spot":pspot, @"description":pdescription, @"latitude":o_latitude, @"longitude":o_longitude, @"date": dateString, @"tid":o_tid};
    [manager POST:@"newPiece.php" parameters:parameters success:
     ^(AFHTTPRequestOperation *operation, id responseObject){
         NSLog(@"%@", [operation responseString]);
         NSString *requestTmp = [NSString stringWithString:operation.responseString];
         NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
         //系统自带JSON解析
         NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
         NSNumber *o_pid = [resultDic objectForKey:@"pid"];
         pid = [o_pid integerValue];
         
         [self uploadImagesToServer];
         
         TravelItem *item = [[TravelItem alloc] initWithDateString:dateString spot:spot latitude:coordinate.latitude longitude:coordinate.longitude description:description imageURLs:imageURLs pid:pid];
         
         [self.delegate travelPieceDetailViewController:self didFinishAddingItem:item];

     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%@", error);
     }];
}

- (void)editPieceToServerWithDescription:(NSString *)pdescription Pieceid:(NSInteger)ppid
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:BaseURL]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSNumber *o_pid = [[NSNumber alloc] initWithInteger:ppid];
    NSDictionary *parameters = @{@"description":pdescription, @"pid":o_pid};
    [manager POST:@"editPiece.php" parameters:parameters success:
     ^(AFHTTPRequestOperation *operation, id responseObject){
         NSLog(@"%@", [operation responseString]);
         
         [self uploadImagesToServer];
         
         [self.delegate travelPieceDetailViewController:self didFinishEditingItem:self.itemToEdit];
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%@", error);
     }];


}

- (IBAction)cancel:(id)sender
{
    [self.delegate travelPieceDetailViewControllerDidCancel:self];
}
- (IBAction)done:(id)sender
{
    if (itemToEdit == nil) {
         description = self.descriptionView.text;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
         NSString *s_date = [formatter stringFromDate:[NSDate date]];
        
        [self uploadNewPieceToServerWithSpot:spot Description:description Latitude:coordinate.latitude Longitude:coordinate.longitude DateString:s_date Travelid:tid];
        
    } else {
        //self.itemToEdit.description = self.descriptionView.text;
        description = self.descriptionView.text;
        
        if (![description isEqualToString:self.itemToEdit.description]) {
            self.itemToEdit.description = description;
            
            [self editPieceToServerWithDescription:description Pieceid:pid];
        }else {
            [self uploadImagesToServer];
            
            [self.delegate travelPieceDetailViewController:self didFinishEditingItem:self.itemToEdit];
        }
     }
  }

- (IBAction)uploadFromLibrary:(id)sender
{
    if (PhotoCount>2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"图片不能超过三张哦=。=" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.filterType = QBImagePickerFilterTypeAllPhotos;
    imagePickerController.showsCancelButton = YES;
    imagePickerController.fullScreenLayoutEnabled = YES;
    imagePickerController.allowsMultipleSelection = YES;
    
    imagePickerController.limitsMaximumNumberOfSelection = YES;
    imagePickerController.maximumNumberOfSelection = 3-PhotoCount;
    
    UINavigationController *navigationController=[[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self.navigationController presentViewController:navigationController animated:YES completion:NULL];
    }

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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [images addObject:img];
    
    PhotoCount++;
    
    hasPhoto = true;
    
    [self showLocalImages];
    
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

- (void)showURLImages
{
    NSInteger n = [imageURLs count];
    for (int i = 0; i < n; i++) {
        NSString *imgstr = [BaseURL stringByAppendingString:[imageURLs objectAtIndex:i]];
        NSURL *imgurl = [[NSURL alloc] initWithString:imgstr];
        UIImageView *imgview =[imageViews objectAtIndex:i];
        [imgview setImageWithURL:imgurl placeholderImage:[UIImage imageNamed:@"loading.png"]];
        imgview.hidden = NO;
        
    }
}

- (void)showLocalImages
{
    NSInteger localcount = [images count];
    NSInteger urlcount = [imageURLs count];
    for (NSInteger i = urlcount; i < urlcount+localcount; i++) {
        UIImageView *imgview =[imageViews objectAtIndex:i];
        imgview.image = [images objectAtIndex:i-urlcount];
        imgview.hidden = NO;
    }
}

- (void)QBImagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    if (imagePickerController.allowsMultipleSelection) {
        
        NSArray *mediaInfoArray = (NSArray *)info;
        NSInteger countOfPhotos = mediaInfoArray.count;
        NSLog(@"Selected %ld photos", (long)countOfPhotos);
        
        PhotoCount += countOfPhotos;
        
        for (NSDictionary* infoDict in mediaInfoArray) {
            UIImage *img = [infoDict objectForKey:UIImagePickerControllerOriginalImage];
            [images addObject:img];
        }
        
        hasPhoto = true;
        
        [self showLocalImages];
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
