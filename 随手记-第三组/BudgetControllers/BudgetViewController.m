//
//  BudgetViewController.m
//  随手记-第三组
//
//  Created by xiaoGXHZC on 14-5-26.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "BudgetViewController.h"
#import "LDProgressView.h"
#import "DatabaseManager.h"

@interface BudgetViewController ()
{
    int _i;
    float _budgetTotalMoney;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)trashButton:(UIBarButtonItem *)sender;
@property (nonatomic, strong) NSMutableArray *progressViews;//进度条数组
@property (nonatomic,strong) NSMutableDictionary *typeDic;
@property (nonatomic,strong)  NSMutableArray *fatherType;
@property(nonatomic,strong)ZenKeyboard *keyboardView;//键盘

@end

@implementation BudgetViewController

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
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    self.typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:YES];
    self.fatherType = [self.typeDic objectForKey:@"big"];
    
    //自定义键盘
//    _keyboardView= [[ZenKeyboard alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
//    self.keyboardView.textField = self.tfIncome;
//    self.automaticallyAdjustsScrollViewInsets=NO;
//    self. extendedLayoutIncludesOpaqueBars=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fatherType.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    spendingType *aType=self.fatherType[indexPath.row];
    UILabel *typeLabel=(UILabel *)[cell viewWithTag:1];
    typeLabel.text=aType.spendName;
    
    UILabel *moneyLabel=(UILabel *)[cell viewWithTag:2];
    moneyLabel.text=aType.budgetMoneyValue.stringValue;
    
    UILabel *balanceLabel = (UILabel *)[cell viewWithTag:3];//余额
    balanceLabel.text = @"得到本月消费进行操作";
    
    //自定义progressView
    self.progressViews = [NSMutableArray array];
    LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(120, 14, self.view.frame.size.width-200, 15)];
    //    progressView.showText = @NO;//progressView中得值
    
//    progressView.progress = 0.80;//设置值
    _budgetTotalMoney=aType.budgetMoneyValue.floatValue;
    float money = _budgetTotalMoney/_budgetTotalMoney;
    progressView.progress = [NSString stringWithFormat:@"%2f",money].floatValue;
    progressView.borderRadius = @0;//设置progressView的外形
    progressView.type = LDProgressSolid;//设置progressView的type
    progressView.color = [UIColor greenColor];
    [self.progressViews addObject:progressView];
    [cell addSubview:progressView];
    
    return cell;
}

//点击cell完成事件,此方法如同把cell变成一个button。可以进行点击操作
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _i=indexPath.row;
    //弹出含有输入textfiled的提示框
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"预算" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    //设置textfiled的风格,密码等风格
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    //提示框输入框所用键盘风格
//    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
    
    UITextField *numberText = [alert textFieldAtIndex:0];//给输入框命名
    //自定义键盘
    _keyboardView= [[ZenKeyboard alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    self.keyboardView.textField = numberText;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self. extendedLayoutIncludesOpaqueBars=NO;
    
    [[alert textFieldAtIndex:0] becomeFirstResponder];
    alert.tag = 1001;
    [alert show];
}

//清除按钮
- (IBAction)trashButton:(UIBarButtonItem *)sender {
    
    UIAlertView *alert  = [[UIAlertView alloc]initWithTitle:@"信息" message:@"确定清空本月预算" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.tag = 1000;
    [alert show];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        if (buttonIndex==0) {
            NSString *textStr = [alertView textFieldAtIndex:0].text;
            
            spendingType *aType = self.fatherType[_i];
            
            aType.budgetMoneyValue = [NSNumber numberWithInt:textStr.intValue];
            
            [[DatabaseManager ShareDBManager] modifySpendType:aType];
            
            [self.tableView reloadData];
            
        }
    }//end
    else if (alertView.tag == 1000){
        if (buttonIndex==0) {
            //清空所以的预算数据
            for (spendingType *aType in self.fatherType) {
        
                aType.budgetMoneyValue = 0;
            
                [[DatabaseManager ShareDBManager] modifySpendType:aType];
            }
            
            [self.tableView reloadData];
        }
    }
}
@end
