//
//  UnlocViewController.m
//  随手记-第三组
//
//  Created by student on 14-6-24.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "UnlocViewController.h"
#import "DatabaseManager.h"

@interface UnlocViewController ()

@property (nonatomic,copy) NSString* password;

@property (nonatomic,retain) UIButton* clearButton;

@property (nonatomic,retain) UILabel* infoLabel;

@end

@implementation UnlocViewController

- (void)dealloc
{
    self.infoLabel = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    Password *aPassword = [[DatabaseManager ShareDBManager]searchPassword:0];
    if (aPassword.password.length == 0) {
        [self performSegueWithIdentifier:@"go2View" sender:self];
    }
    self.view.backgroundColor=[UIColor lightGrayColor];
    self.imageView.layer.cornerRadius=40;
    self.imageView.layer.masksToBounds=YES;
    self.imageView.layer.borderWidth=3;
    self.imageView.layer.borderColor=[[UIColor whiteColor]CGColor];
    self.password = @"";
    
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 180, 300, 30)];
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.textAlignment =  NSTextAlignmentCenter;
    self.infoLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.infoLabel];
}
@end
