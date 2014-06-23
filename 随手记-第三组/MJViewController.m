//
//  MJViewController.m
//  MJPasswordView
//
//  Created by tenric on 13-6-29.
//  Copyright (c) 2013年 tenric. All rights reserved.
//

#import "MJViewController.h"
#import "MJPasswordView.h"
#import "UserManager.h"
@interface MJViewController ()

@property (nonatomic,assign) ePasswordSate state;

@property (nonatomic,copy) NSString* password;

@property (nonatomic,retain) UIButton* clearButton;
- (IBAction)clearButton:(id)sender;

@property (nonatomic,retain) UILabel* infoLabel;

@property (nonatomic,retain) MJPasswordView* passwordView;
@property(nonatomic,strong)UserManager *userManger;
@property(nonatomic,strong)Password *aPassword;
@property(nonatomic,assign)BOOL switchViewIsOn;
@property(nonatomic,strong)NSString *judgmentString;
@end

@implementation MJViewController

- (void)dealloc
{
    self.infoLabel = nil;
    self.passwordView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.state = ePasswordUnset;
    self.view.backgroundColor=[UIColor orangeColor];
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 300, 30)];
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.textAlignment =  NSTextAlignmentCenter;
    self.infoLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.infoLabel];
    
    CGRect frame = CGRectMake(20, 220, kPasswordViewSideLength, kPasswordViewSideLength);
    self.passwordView = [[MJPasswordView alloc] initWithFrame:frame] ;
    self.passwordView.delegate = self;
    [self.view addSubview:self.passwordView];
    self.aPassword = [[Password alloc]init];
    self.aPassword = [[NoteManager shareDatabaseManager]searchPassword:0];
    
    [self updateInfoLabel];
    
    if ([self.judgmentString isEqualToString:@"修改"]) {
    }else{
        if (self.switchViewIsOn == NO) {
            UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"关闭密码会删除密码！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [view show];
    }
    
    }
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
            if ([self.judgmentString isEqualToString:@"修改"]) {
                infoText = @"请输入已保存的密码";
            }else{
                if (self.switchViewIsOn == NO) {
                    infoText = @"请输入已保存的密码";
                }else{
                    if (self.aPassword.password.length==0) {
                        infoText = @"设置密码";
                    }
                }
            }
            break;
            
        case ePasswordRepeat:
            if ([self.judgmentString isEqualToString:@"修改"]) {
                if ([self.aPassword.password isEqualToString:self.password]) {
                    infoText = @"密码正确,请输入新密码";
                }else{
                    infoText = @"密码错误或修改错误,请重新输入密码";
                    self.state = ePasswordUnset;
                }
            }else{
                if (self.switchViewIsOn == NO) {
                    infoText = @"密码错误,请重新输入密码";
                }else{
                    infoText = [NSString stringWithFormat:@"请再次输入刚才的密码"];
            }
            }
            break;
            
        case ePasswordExist:
            if ([self.judgmentString isEqualToString:@"修改"]) {
                    infoText = [NSString stringWithFormat:@"请再次输入密码"];
            }
            
            break;
            
        default:
            break;
    }
    
    self.infoLabel.text = infoText;
}

- (void)clearPassword
{
    self.password = @"";
    self.state = ePasswordUnset;
    
    [self updateInfoLabel];
}

- (void)passwordView:(MJPasswordView*)passwordView withPassword:(NSString*)password
{
    switch (self.state)
    {
        case ePasswordUnset:
            if ([self.judgmentString isEqualToString:@"修改"]) {
                self.password = password;
                if ([self.aPassword.password isEqualToString:password]) {
                    self.state = ePasswordRepeat;
                }else{
                    self.state = ePasswordRepeat;
                }
            }else{
                if (self.switchViewIsOn == NO) {
                    if ([self.aPassword.password isEqualToString:password]) {
                        [[NoteManager shareDatabaseManager]deletePassword];
                        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"关闭密码成功！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [view show];
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        self.state = ePasswordRepeat;
                    }
                }else{
                    if (self.aPassword.password.length==0) {
                        self.password = password;
                        self.state = ePasswordRepeat;
                    }else{
                        self.infoLabel.text =[NSString stringWithFormat:@"请输入密码"];
                    }
                }
            }
            break;
            
        case ePasswordRepeat:
            if ([self.judgmentString isEqualToString:@"修改"]) {
                    self.password = password;
                    self.state =ePasswordExist;
            }else{
                if (self.switchViewIsOn == NO) {
                    if ([self.aPassword.password isEqualToString:password]) {
                        [[NoteManager shareDatabaseManager]deletePassword];
                        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"关闭密码成功！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [view show];
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        self.state = ePasswordRepeat;
                    }
                }else{
                    if ([password isEqualToString:self.password])
                    {
                        self.state = ePasswordExist;
    //                    self.userManger.aUser.password=self.password;
    //                    self.userManger.aUser.isProtected=YES;
                        Password *aPassword = [[Password alloc]init];
                        aPassword.password = self.password;
                        [[NoteManager shareDatabaseManager]addPassword:aPassword];
                        //[self.userManger saveUser];
                        
                        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"密码设置成功！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [view show];
                        [self.navigationController popViewControllerAnimated:YES];
                    }else if (![password isEqualToString:self.password]){
    //                    self.infoLabel.text = [NSString stringWithFormat:@"两次密码不一致，请重试"];
                        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"两次密码不一致,请重新输入！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [view show];
                        self.state = ePasswordUnset;
                    }
                }
            }
            break;
            
        case ePasswordExist:
            if ([self.judgmentString isEqualToString:@"修改"]) {
                if ([password isEqualToString:self.password]) {
                    [[NoteManager shareDatabaseManager]deletePassword];
                    
                    Password *aPassword = [[Password alloc]init];
                    aPassword.password = password;
                    [[NoteManager shareDatabaseManager]addPassword:aPassword];
                    UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"修改密码成功！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [view show];
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    self.state = ePasswordRepeat;
                    UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"两次密码不一致,请重新输入！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [view show];
                }
            }
//            if ([password isEqualToString:self.password])
//            {
//                UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"密码正确！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [view show];
//            }
            break;
            
        default:
            break;
    }
    
    [self updateInfoLabel];
}
- (IBAction)clearButton:(id)sender {
    self.state = ePasswordUnset;
    [self updateInfoLabel];
}
@end
