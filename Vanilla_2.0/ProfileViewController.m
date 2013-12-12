//
//  ProfileViewController.m
//  Vanilla3.0
//
//  Created by BAO on 13-12-10.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import "ProfileViewController.h"

@implementation ProfileViewController
{
    NSArray * first_deminsion;
}
static CGFloat WindowHeight = 200.0;
static CGFloat ImageHeight  = 300.0;

#pragma mark - Parallax effect

- (void)viewDidLoad
{
    [super viewDidLoad];
    //load data
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"userInfo" withExtension:@"plist"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    self.userinfo = dictionary;
    
    NSMutableArray *supports = [[NSMutableArray alloc] initWithCapacity:4];
    [supports addObject:@"服务条款"];
    [supports addObject:@"隐私政策"];
    [supports addObject:@"关于我们"];
    [supports addObject:@"反馈"];
    self.supports = supports;
    NSArray *second_deminsion_one = [[NSArray alloc]initWithObjects:@"用户名"   ,@"简介" ,nil];
    NSArray *second_deminsion_two = [[NSArray alloc]initWithObjects:@"电子邮件"   ,@"地区" ,@"手机" ,nil];
    first_deminsion = [[NSArray alloc] initWithObjects:second_deminsion_one,second_deminsion_two, nil];
    
    self.headUrl = @"头像.png";
    
    _imageScroller  = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _imageScroller.backgroundColor                  = [UIColor clearColor];
    _imageScroller.showsHorizontalScrollIndicator   = NO;
    _imageScroller.showsVerticalScrollIndicator     = NO;
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"北京"]];
    
    
    [_imageScroller addSubview:_imageView];
    
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor              = [UIColor clearColor];
    _tableView.dataSource                   = self;
    _tableView.delegate                     = self;
    _tableView.separatorStyle               = UITableViewCellSeparatorStyleSingleLine;
    
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.allowsSelection = YES;
    [self.view addSubview:_imageScroller];
    [self.view addSubview:_tableView];
    
}

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }else if (section == 1)
        return 2;
    else if (section ==2)
        return 3;
    else
        return 4;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier   = @"RBParallaxTableViewCell";
    static NSString *windowReuseIdentifier = @"RBParallaxTableViewWindow";
    static NSString *supportCellIdentifier = @"SupportCell";
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:windowReuseIdentifier];
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:windowReuseIdentifier] ;
            cell.backgroundColor             = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle              = UITableViewCellSelectionStyleNone;
            UIImageView *headView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:self.headUrl]];
            [headView setFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
            [headView setCenter:CGPointMake(240.0f, 120.0f)];
            [cell.contentView addSubview:headView];
        }
        return cell;
    }
    else if (indexPath.section < 3) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.textLabel.text =[[ first_deminsion objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
            return cell;
        }
        
        }
    else if (indexPath.section == 3 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:supportCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:supportCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.textLabel.text = [self.supports objectAtIndex:indexPath.row];
            cell.accessoryType =    UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        
    }else
        return cell;
                // Configure the cell...
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return WindowHeight;
    }else
    {
        return 40;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section ==1 )
        return @"个人";
    else if (section ==2)
        return @"账号";
    else    if(section ==3)
        return @"支持";
    else
        return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 150;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - Table View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateOffsets];
}

#pragma mark - Dealloc


-(UITableViewCell*) getUserInfoCell:(NSString *)identifier
{
    UITableViewCell * cell =[_tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == Nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = identifier;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


@end
