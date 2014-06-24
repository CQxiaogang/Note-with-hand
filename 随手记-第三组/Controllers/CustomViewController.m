//
//  CustomViewController.m
//  随手记-第三组
//
//  Created by student on 14-6-9.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "CustomViewController.h"
#import "Password.h"
#import "DatabaseManager.h"


@interface CustomViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *list;
@property(nonatomic,strong)Password *aPassword;
@property(nonatomic,assign)BOOL switchViewIsOn;
@property(nonatomic,strong)NSString *judgmentString;//判断
@end

@implementation CustomViewController

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
    self.list = [[NSMutableArray alloc]initWithObjects:@"是否设置密码",@"修改密码", nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated{
    self.aPassword = [[DatabaseManager ShareDBManager] searchPassword:0];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.list.count;
    }
    return 1;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
//         cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UILabel *textLabel = (UILabel *)[cell viewWithTag:11];
        textLabel.text = self.list[indexPath.row];

        UISwitch *switchView = (UISwitch *)[cell viewWithTag:10];
        switchView.hidden = YES;
        if (0 == indexPath.row) {
            switchView.hidden = NO;
            [switchView addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
            if (0 == self.aPassword.password.length) {
                [switchView setOn:NO];
            }else{
                [switchView setOn:YES];
            }
        }
        
    }else{
        //cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UISwitch *switchView = (UISwitch *)[cell viewWithTag:10];
        switchView.hidden = YES;
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:11];
        cellLabel.text = @"关于我们";
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"密码设置";
    }else{
        return @"关于我们";
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"section %d row %d",indexPath.section,indexPath.row);
    if (indexPath.section==0 && indexPath.row == 1) {
        if (self.aPassword.password.length == 0) {
            UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"请先设置密码！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [view show];
        }else{
            self.judgmentString = @"修改";
            [self performSegueWithIdentifier:@"toPassword" sender:nil];
        }
    }
    if (indexPath.section==1&&indexPath.row==0) {
        [self performSegueWithIdentifier:@"toAbout" sender:self];
    }
}

-(void)updateSwitchAtIndexPath:(id)sender{
    UISwitch *switchView = (UISwitch *)sender;
    if ([switchView isOn]) {
        //[self.navigationController popViewControllerAnimated:YES];
        self.switchViewIsOn = YES;
        self.judgmentString = @"";
        [self performSegueWithIdentifier:@"toPassword" sender:nil];
    }
    else{
        self.switchViewIsOn = NO;
        self.judgmentString = @"";
        [self performSegueWithIdentifier:@"toPassword" sender:nil];
    }
}

//- (IBAction)switchOfPassword:(UISwitch *)sender {
//    if (sender.on == YES) {//on为Yes时switch为打开状态
////        //输入新密码
////        TestViewController *lockVc = [[TestViewController alloc]init];
////        lockVc.infoLabelStatus = InfoStatusFirstTimeSetting;
////        [self.navigationController presentViewController:lockVc animated:YES completion:^{
////            //
////        }];
//        
//        self.switchViewIsOn = YES;
//        self.judgmentString = @"";
//        [self performSegueWithIdentifier:@"toPassword" sender:nil];
//        
//    }else{
//        //输入原密码，并关闭
////        TestViewController *lockVc = [[TestViewController alloc]init];
////        lockVc.infoLabelStatus = InfoStatusNormal;
////        [self.navigationController presentViewController:lockVc animated:YES completion:^{
////            
////        }];
//        self.switchViewIsOn = NO;
//        self.judgmentString = @"";
//        [self performSegueWithIdentifier:@"toPassword" sender:nil];
//    }
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    NSObject *nextVC = [segue destinationViewController];
//    
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"toPassword"]) {
        
        [segue.destinationViewController setValue:@(self.switchViewIsOn) forKey:@"switchViewIsOn"];
        [segue.destinationViewController setValue:self.judgmentString forKey:@"judgmentString"];
//        NSLog(@"section %d row %d",indexPath.section,indexPath.row);
//        if (indexPath.section==0 && indexPath.row == 1) {
//            NSString *password = @"password";
//            [nextVC setValue:password forKey:@"password"];
//        }else if (indexPath.section==1 && indexPath.row == 0) {
//            NSString *aboutUs = @"aboutUs";
//            [nextVC setValue:aboutUs forKey:@"aboutUs"];
//        }
    }
}


@end
