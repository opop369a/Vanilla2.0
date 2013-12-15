//
//  TravelManageViewController.m
//  Vanilla3.0
//
//  Created by BAO on 13-12-10.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import "TravelManageViewController.h"
#import "addTravelViewController.h"
#import "TravelPieceManageController.h"
#import "UIImageView+AFNetworking.h"


@interface TravelManageViewController ()

@end

@implementation TravelManageViewController
static CGFloat WindowHeight = 200.0;
static CGFloat ImageHeight  = 300.0;
static NSString *const baseUrl =@"http://172.17.228.37/vanilla/";
static NSString *const baseImageUrl =@"http://172.17.228.37/vanilla/";

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
    //获取数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username": @"tangwei"};
    [manager POST:[baseUrl stringByAppendingString:@"travelsinfo.php"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        NSArray *array = [dic objectForKey:@"travels"];
        self.content = [[NSMutableArray alloc] initWithCapacity:3];
        [self.content addObjectsFromArray:array];
        NSLog(@"%lu" , (unsigned long)self.content.count);
        [_tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    NSString *headName=@"北京";
    
//    if (self.content == nil) {
//        self.content = [[NSMutableArray alloc]initWithCapacity:3 ];
//        //加载表格数据
//        NSMutableDictionary *three_turple = [[NSMutableDictionary alloc]initWithCapacity:3];
//        [three_turple setObject:@"我的丽江之行" forKey:@"mainTitleKey"  ];
//        [three_turple setObject:@"这次十一去丽江给人很大启发" forKey:@"secondaryTitleKey"];
//        [three_turple setObject:@"丽江" forKey:@"imageKey"];
//        [self.content addObject:three_turple];
//        three_turple = [[NSMutableDictionary alloc]initWithCapacity:3];
//        [three_turple setObject:@"我的北京之行" forKey:@"mainTitleKey"  ];
//        [three_turple setObject:@"这次十一去北京给人很大启发" forKey:@"secondaryTitleKey"];
//        [three_turple setObject:@"北京" forKey:@"imageKey"];
//        [self.content addObject:three_turple];
//        three_turple = [[NSMutableDictionary alloc]initWithCapacity:3];
//        [three_turple setObject:@"我的西藏之行" forKey:@"mainTitleKey"  ];
//        [three_turple setObject:@"这次十一去西藏给人很大启发" forKey:@"secondaryTitleKey"];
//        [three_turple setObject:@"西藏" forKey:@"imageKey"];
//        [self.content addObject:three_turple];
//        
//    }
    
    _imageScroller  = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _imageScroller.backgroundColor                  = [UIColor clearColor];
    _imageScroller.showsHorizontalScrollIndicator   = NO;
    _imageScroller.showsVerticalScrollIndicator     = NO;
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:headName]];
    [_imageScroller addSubview:_imageView];
    
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor              = [UIColor clearColor];
    _tableView.dataSource                   = self;
    _tableView.delegate                     = self;
    _tableView.separatorStyle               = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:_imageScroller];
    [self.view addSubview:_tableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Parallax effect

- (void)updateOffsets {
    CGFloat yOffset   = _tableView.contentOffset.y;
    CGFloat threshold = ImageHeight - WindowHeight;
    
    if (yOffset > -threshold && yOffset < 0) {
        _imageScroller.contentOffset = CGPointMake(0.0, floorf(yOffset / 2.0));
    } else if (yOffset < 0) {
        _imageScroller.contentOffset = CGPointMake(0.0, yOffset + floorf(threshold / 2.0));
    } else {
        _imageScroller.contentOffset = CGPointMake(0.0, yOffset);
    }
}

#pragma mark - View Layout
- (void)layoutImage {
    CGFloat imageWidth   = _imageScroller.frame.size.width;
    CGFloat imageYOffset = floorf((WindowHeight  - ImageHeight) / 2.0);
    CGFloat imageXOffset = 0.0;
    
    _imageView.frame             = CGRectMake(imageXOffset, imageYOffset, imageWidth, ImageHeight);
    _imageScroller.contentSize   = CGSizeMake(imageWidth, self.view.bounds.size.height);
    _imageScroller.contentOffset = CGPointMake(0.0, 0.0);
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect bounds = self.view.bounds;
    
    _imageScroller.frame        = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    _tableView.backgroundView   = nil;
    _tableView.frame            = bounds;
    
    [self layoutImage];
    [self updateOffsets];
}

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { return 1;  }
    else              { return self.content.count; }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { return WindowHeight; }
    else                        { return 60.0;         }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellReuseIdentifier   = @"RBParallaxTableViewCell";
    static NSString *windowReuseIdentifier = @"RBParallaxTableViewWindow";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:windowReuseIdentifier];
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:windowReuseIdentifier] ;
            cell.backgroundColor             = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle              = UITableViewCellSelectionStyleNone;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
        }
    }
    
    if (indexPath.row > self.content.count || indexPath.section == 0) {
        return cell;
    }
    NSDictionary *item = (NSDictionary *)[self.content objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"mainTitleKey"];
    cell.detailTextLabel.text = [item objectForKey:@"secondaryTitleKey"];
    [cell.imageView setImageWithURL:
     [NSURL URLWithString:[baseImageUrl stringByAppendingString:[item objectForKey:@"imageKey"]]] placeholderImage:[UIImage imageNamed:@"loading.png"]];
    [cell setEditing:YES];
//    cell.editingStyle = UITableViewCellEditingStyleDelete;
    return cell;
}

#pragma mark - Table View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateOffsets];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if (section == 1) {
//        return 100;
//    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"travelPiece" sender:[self.content objectAtIndex:indexPath.row]];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addTravel"]) {
    UINavigationController *nav = segue.destinationViewController;
    addTravelViewController* addViewController = [nav.viewControllers objectAtIndex:0];
    addViewController.delegate = self; 
    }else if([segue.identifier isEqualToString:@"travelPiece"]){
    TravelPieceManageController *mcontroller = segue.destinationViewController;
        mcontroller.delegate = self;
        NSNumber * num = (NSNumber *)[(NSDictionary*)sender objectForKey:@"tid"];
        mcontroller.tid = [num integerValue];
        NSLog(@"%@" , self.content);
    }
    
}

-(void) done:(NSMutableDictionary *)dictionary
{
    [self.content addObject:dictionary];
    [self addRecord:dictionary];
    [_tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return  NO;
    }
    return YES;
}

//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:YES animated:YES];
    return UITableViewCellEditingStyleDelete;
}

//进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deleteRecord: [[self.content objectAtIndex:indexPath.row] objectForKey:@"tid"]];
    [self.content removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(void) deleteRecord:(id)tid
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"tid": [NSString stringWithFormat:@"%@" ,tid]};
    NSLog(@"%@" , tid);
    [manager POST:[baseUrl stringByAppendingString:@"deletetravel.php"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)addRecord:(NSMutableDictionary*)record
{
    NSLog(@"%@" , record);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[baseUrl stringByAppendingString:@"addtravel.php"] parameters:record success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        NSString*result = [dic objectForKey:@"result"];
        if ([result isEqualToString:@"success"]) {
            NSString*tid = [dic objectForKey:@"tid"];
            NSLog(@"success %@" , tid);
            [[self.content lastObject] setObject:tid forKey:@"tid"];
//            [record setObject:tid forKey:@"tid"];
        }
        else
        {
            NSLog(@"add failed !");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)TravelPieceManageViewControllerUpdateData:(TravelPieceManageController *)controller
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username": @"tangwei"};
    [manager POST:[baseUrl stringByAppendingString:@"recenttravels.php"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        NSArray *array = [dic objectForKey:@"travels"];
        //            [self.content addObjectsFromArray:array];
        self.content = [array mutableCopy];
        NSLog(@"%@" ,dic );
        [_tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"xxxError: %@", error);
    }];

    
}



@end
