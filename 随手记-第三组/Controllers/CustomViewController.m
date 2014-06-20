//
//  CustomViewController.m
//  随手记-第三组
//
//  Created by student on 14-6-9.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "CustomViewController.h"
#import "TestViewController.h"

@interface CustomViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
        return 2;
    }
    return 1;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    static NSString *switchCellIdentifier = @"SwitchCell";
    UITableViewCell *cell;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
         cell = [tableView dequeueReusableCellWithIdentifier:switchCellIdentifier forIndexPath:indexPath];
        
        
        
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:10];
        if (indexPath.section == 0 && indexPath.row == 1) {
            cellLabel.text = @"密码修改";
        }else if (indexPath.section == 1){
            cellLabel.text = @"关于我们";
        }
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

- (IBAction)switchOfPassword:(UISwitch *)sender {
    if (sender.on == YES) {//on为Yes时switch为打开状态
        //输入新密码
        TestViewController *lockVc = [[TestViewController alloc]init];
        lockVc.infoLabelStatus = InfoStatusFirstTimeSetting;
        [self.navigationController presentViewController:lockVc animated:YES completion:^{
            //
        }];
        
    }else{
        //输入原密码，并关闭
        TestViewController *lockVc = [[TestViewController alloc]init];
        lockVc.infoLabelStatus = InfoStatusNormal;
        [self.navigationController presentViewController:lockVc animated:YES completion:^{
            
        }];
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSObject *nextVC = [segue destinationViewController];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"cell2view"]) {
        NSLog(@"section=%d,row=%d",indexPath.section,indexPath.row);
        if (indexPath.section==0 && indexPath.row == 1) {
            NSString *password = @"password";
            [nextVC setValue:password forKey:@"password"];
        }else if (indexPath.section==1 && indexPath.row == 0) {
            NSString *aboutUs = @"aboutUs";
            [nextVC setValue:aboutUs forKey:@"aboutUs"];
        }
    }
}


@end
