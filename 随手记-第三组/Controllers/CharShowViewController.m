//
//  CharShowViewController.m
//  随手记-第三组
//
//  Created by xiaoGXHZC on 14-6-10.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "CharShowViewController.h"
#import "Bill.h"
#import "DatabaseManager.h"

@interface CharShowViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableDictionary *typeDic;
@property (nonatomic,strong) NSArray *typeList;

@end

@implementation CharShowViewController

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
    //TODO:tableView的代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //TODO:今天的bill数据
    NSDate *now=[NSDate date];
    NSString *date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    date = [formatter stringFromDate:now];
//    self.array = [[DatabaseManager ShareDBManager]billListInDay:date InWeek:nil InMonth:nil];
    
    self.typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - talbeView实现
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.array count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Bill *aBill = self.array[indexPath.row];
    
    UILabel *typeLabel = (UILabel *)[cell viewWithTag:1];
    self.typeList = [self.typeDic objectForKey:@"big"];
    spendingType *aType = self.typeList[indexPath.row];
    typeLabel.text =aType.spendName;
    
    UILabel *moneyAmountLabel = (UILabel *)[cell viewWithTag:2];
    moneyAmountLabel.text = [NSString stringWithFormat:@"%.2f",aBill.moneyAmount];
    
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:3];
    
    //对字符串2014-06-09进行拆分，在组装成你想要。
    NSArray *timeList = [aBill.billTime componentsSeparatedByString:@"-"];
    NSString *timeStr = timeList[1];
    NSString *timeStr1 = [timeStr substringWithRange:NSMakeRange(0, 1)];
    NSString *timeStr2 = [timeStr substringWithRange:NSMakeRange(1, 1)];
    
    NSString *timeStr3 = timeList[2];
    NSString *timeStr4 = [timeStr3 substringWithRange:NSMakeRange(0, 1)];
    NSString *timeStr5 = [timeStr3 substringWithRange:NSMakeRange(1, 1)];
    NSString *fristStr;
    if ([timeStr1 isEqualToString:@"0"]) {
        fristStr = timeStr2;
    }else{
        fristStr = timeStr;
    }
    NSString *secondStr;
    if ([timeStr4 isEqualToString:@"0"]) {
        secondStr = timeStr5;
    }else{
        secondStr = timeStr3;
    }
    
    timeLabel.text = [NSString stringWithFormat:@"%@月%@日",fristStr,secondStr];
    return cell;
}

#pragma mark - 传值
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];//根据tableView的cell(sender)来找到你所点击的行。
    Bill *aBill = self.array[indexPath.row];
    
    NSObject *nextVC=[segue destinationViewController];//destinationViewController找你到你要传值的controller
    if ([segue.identifier isEqualToString:@"char2Edit"]) {
        [nextVC setValue:aBill forKey:@"aBill"];
    }
}

@end
