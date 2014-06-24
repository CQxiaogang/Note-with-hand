//
//  UnlocViewController.m
//  随手记-第三组
//
//  Created by student on 14-6-24.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "UnlocViewController.h"
#import "MJPasswordView.h"
#import "DatabaseManager.h"

@interface UnlocViewController ()

@property (nonatomic,assign) ePasswordSate state;

@property (nonatomic,copy) NSString* password;

@property (nonatomic,retain) UIButton* clearButton;

@property (nonatomic,retain) UILabel* infoLabel;

@property (nonatomic,retain) MJPasswordView* passwordView;

@end

@implementation UnlocViewController

- (void)dealloc
{
    self.infoLabel = nil;
    self.passwordView = nil;
}

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
    self.state = ePasswordUnset;
    
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 180, 300, 30)];
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.textAlignment =  NSTextAlignmentCenter;
    self.infoLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.infoLabel];
    
    CGRect frame = CGRectMake(20, 220, kPasswordViewSideLength, kPasswordViewSideLength);
    self.passwordView = [[MJPasswordView alloc] initWithFrame:frame] ;
    self.passwordView.delegate = self;
    [self.view addSubview:self.passwordView];
    
    [self updateInfoLabel];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateInfoLabel
{
    NSString* infoText;
    switch (self.state)
    {
        case ePasswordUnset:
            infoText = @"请输入密码";
            break;
            
        case ePasswordRepeat:
            infoText = [NSString stringWithFormat:@"密码不正确，请再次输入"];
            break;
            
        case ePasswordExist:
            infoText = [NSString stringWithFormat:@"密码正确"];
            break;
            
        default:
            break;
    }
    
    self.infoLabel.text = infoText;
}

- (void)passwordView:(MJPasswordView*)passwordView withPassword:(NSString*)password
{
    //UserManager *userManager=[[UserManager alloc]init];
    Password *aPassword = [[DatabaseManager ShareDBManager]searchPassword:0];
    switch (self.state)
    {
        case ePasswordUnset:
            self.password = password;
            if ([self.password isEqualToString:aPassword.password]) {
                [self performSegueWithIdentifier:@"go2View" sender:self];
            }else{
                self.state = ePasswordRepeat;
            }
            break;
            
        case ePasswordRepeat:
            self.password = password;
            if ([password isEqualToString:aPassword.password])
            {
                [self performSegueWithIdentifier:@"go2View" sender:self];
            }
            break;
        case ePasswordExist:
            break;
            //        default:
            //            break;
    }
    
    [self updateInfoLabel];
}


@end
