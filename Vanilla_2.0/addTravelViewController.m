//
//  addTravelViewController.m
//  Vanilla3.0
//
//  Created by BAO on 13-12-10.
//  Copyright (c) 2013年 HY Bao. All rights reserved.
//

#import "addTravelViewController.h"
#import "TravelManageViewController.h"
#import "VanillaViewController.h"

@interface addTravelViewController ()

@end

@implementation addTravelViewController
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) init
{
    [self viewDidLoad];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.nameTextField.delegate = self;
//    self.ideasTextView.delegate = self;
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {//调用代理

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:3];
    [dic setObject:self.nameTextField.text forKey:@"mainTitleKey"];
    [dic setObject:self.ideasTextView.text forKey:@"secondaryTitleKey"];
    [dic setObject:@"北京" forKey:@"imageKey"];

    if (!_delegate) {
        NSLog(@"no delegate");
    }
    [_delegate done:dic];
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.text = @"";
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nameTextField resignFirstResponder];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    [self.nameTextField resignFirstResponder];
    [self.ideasTextView resignFirstResponder];
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

@end
