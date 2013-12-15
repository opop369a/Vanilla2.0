//
//  MainViewController.m
//  Vanilla3.0
//
//  Created by BAO on 13-12-10.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import "MainViewController.h"
#import "addTravelViewController.h"
#import "TravelManageViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    UINavigationController * add;
}

static CGFloat WindowHeight = 200.0;
static CGFloat ImageHeight  = 300.0;
static NSString *const baseUrl =@"http://172.17.178.95/~BAO/";
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
    self.content = [[NSMutableArray alloc]initWithCapacity:3 ];
    
    //加载视图数据
    self.haveTravels = NO;
//
//    //加载表格数据
//    if (self.haveTravels) {
    
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
//            self.haveTravels = YES;
//            [_tableView reloadData];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
//            self.haveTravels =NO;
        }];

        
//        NSBundle *bundle = [NSBundle mainBundle];
//        NSURL *plistURL = [bundle URLForResource:@"RecentTravelPlist" withExtension:@"plist"];
//        self.content= [[NSArray arrayWithContentsOfURL:plistURL] mutableCopy];
//    }
    _imageScroller  = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _imageScroller.backgroundColor                  = [UIColor clearColor];
    _imageScroller.showsHorizontalScrollIndicator   = NO;
    _imageScroller.showsVerticalScrollIndicator     = NO;
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"丽江.png"]];
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
    if (_haveTravels) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { return 1;  }
    else    if(_haveTravels && section != 1 )          { return self.content.count; }
    else if (_haveTravels && section == 1)      return 1;
    else    {return 2;};
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { return WindowHeight; }
    else   if(_haveTravels)   {     return 60;    }
    else    {return 80; }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellReuseIdentifier   = @"RBParallaxTableViewCell";
    static NSString *windowReuseIdentifier = @"RBParallaxTableViewWindow";
    NSLog(@"%@" , indexPath);
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:windowReuseIdentifier];
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:windowReuseIdentifier] ;
            cell.backgroundColor             = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle              = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    
    if (!_haveTravels) {
        if (indexPath.section == 1 && indexPath.row ==0) {
            cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20.0f, 0.0f, 280.0f, 60.0f)];
                label.text = @"有多久没去旅行了?";
                [cell.contentView addSubview:label ];
            }
            return cell;
        }else if (indexPath.section == 1 && indexPath.row ==1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 280.0f, 60.0f)];
                button.backgroundColor = [[UIColor alloc] initWithRed:(CGFloat)209/255 green:(CGFloat)112/255 blue:(CGFloat)95/255 alpha:1];
                [button.titleLabel setTextColor:[UIColor whiteColor]];
                [button setTitle:@"开始新旅行" forState:UIControlStateNormal];
                [button showsTouchWhenHighlighted];
                [cell.contentView addSubview:button ];
                [button setEnabled:YES];
                [button addTarget:self action:@selector(goStart) forControlEvents:UIControlEventTouchDown];
            }
            return cell;
        }
        else
        {
            
            if (indexPath.section == 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
                    cell.textLabel.text = @"最近的旅行";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                return cell;
            }
            
            //获取recent travel数据
            cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                NSDictionary *item = (NSDictionary *)[self.content objectAtIndex:indexPath.row];
                cell.textLabel.text = [item objectForKey:@"mainTitleKey"];
                cell.detailTextLabel.text = [item objectForKey:@"secondaryTitleKey"];
                [cell.imageView setImageWithURL:
                 [NSURL URLWithString:[baseImageUrl stringByAppendingString:[item objectForKey:@"imageKey"]]] placeholderImage:[UIImage imageNamed:@"loading.png"]];
            }
            return  cell;

        }
        
    }
    /*
    else if(!_haveTravels && indexPath.section == 1 && indexPath.row ==0 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20.0f, 0.0f, 280.0f, 60.0f)];
            label.text = @"有多久没去旅行了?";
            [cell.contentView addSubview:label ];
        }
    }else if(!_haveTravels && indexPath.section == 1 && indexPath.row == 1 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
            //            cell.contentView.backgroundColor = [UIColor blueColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 280.0f, 60.0f)];
            button.backgroundColor = [[UIColor alloc] initWithRed:(CGFloat)209/255 green:(CGFloat)112/255 blue:(CGFloat)95/255 alpha:1];
            [button.titleLabel setTextColor:[UIColor whiteColor]];
            [button setTitle:@"开始新旅行" forState:UIControlStateNormal];
            [button showsTouchWhenHighlighted];
            [cell.contentView addSubview:button ];
            [button setEnabled:YES];
            [button addTarget:self action:@selector(goStart) forControlEvents:UIControlEventTouchDown];
        }
    }
    else if (_haveTravels && indexPath.row < self.content.count)
    {
        if (indexPath.section == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
                cell.textLabel.text = @"最近的旅行";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        
        //获取recent travel数据
        cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            NSDictionary *item = (NSDictionary *)[self.content objectAtIndex:indexPath.row];
            cell.textLabel.text = [item objectForKey:@"mainTitleKey"];
            cell.detailTextLabel.text = [item objectForKey:@"secondaryTitleKey"];
            [cell.imageView setImageWithURL:
             [NSURL URLWithString:[@"http://172.17.178.95/vanilla/" stringByAppendingString:[item objectForKey:@"imageKey"]]] placeholderImage:[UIImage imageNamed:@"loading.png"]];
            return cell;
        }
     
     
        
    } */
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        
    return cell;
}

#pragma mark - Table View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateOffsets];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section == 1 && !_haveTravels) {
//        return 150;
//    }else if (section == 2 && _haveTravels)
//        return 150;
//    return 0;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_haveTravels && indexPath.section == 1 && indexPath.row == 1) {
       UITableViewCell * cell =  [tableView cellForRowAtIndexPath:indexPath];
        for (UIView * view in cell.contentView.subviews)
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton * button = (UIButton*)view;
                button.selected =YES;
                button.highlighted=YES;
                NSLog(@"button" );
        }
    }
}

-(void) goStart
{
    add =[self.storyboard instantiateViewControllerWithIdentifier:@"addTravel"];
    addTravelViewController *addt =(addTravelViewController*) [add topViewController];
    addt.delegate = self;
    [self.navigationController presentViewController:add animated:YES completion:nil];
}

-(void) done:(NSMutableDictionary *)dictionary
{
    [self addRecord:dictionary];
//    [self.content addObject:dictionary];
//
//    [_imageScroller removeFromSuperview];
//    [_tableView removeFromSuperview];
//    _haveTravels = YES;
//    _imageScroller  = [[UIScrollView alloc] initWithFrame:CGRectZero];
//    _imageScroller.backgroundColor                  = [UIColor clearColor];
//    _imageScroller.showsHorizontalScrollIndicator   = NO;
//    _imageScroller.showsVerticalScrollIndicator     = NO;
//    
//    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"丽江.png"]];
//    [_imageScroller addSubview:_imageView];
//    
//    _tableView = [[UITableView alloc] init];
//    _tableView.backgroundColor              = [UIColor clearColor];
//    _tableView.dataSource                   = self;
//    _tableView.delegate                     = self;
//    _tableView.separatorStyle               = UITableViewCellSeparatorStyleNone;
//    _tableView.showsVerticalScrollIndicator = NO;
//    
//    
//    [self.view addSubview:_imageScroller];
//    [self.view addSubview:_tableView];

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
            [record setObject:tid forKey:@"tid"];
        }
        else
        {
            NSLog(@"add failed !");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


@end
