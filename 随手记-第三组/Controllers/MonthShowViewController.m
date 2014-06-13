//
//  MonthShowViewController.m
//  随手记-第三组
//
//  Created by student on 14-6-9.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "MonthShowViewController.h"
#import "DatabaseManager.h"
#import "Bill.h"

@interface MonthShowViewController ()

@property(nonatomic,strong)NSMutableArray *billArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *typeList;

@end

@implementation MonthShowViewController

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
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *nowDate;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;//分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit 可查年、月、周开始结束 “某个时间点”所在的“单元”的起始时间，以及起始时间距离“某个时间点”的时差（单位秒）
    nowDate=[NSDate date];
    comps = [calendar components:unitFlags fromDate:nowDate];
    NSString *monthStr = [self stringMonthForDate:nowDate];
    
    self.billArray = [[DatabaseManager ShareDBManager]billListInDay:nil InWeek:nil InMonth:monthStr];
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
    return [self.billArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Bill *aBill = self.billArray[indexPath.row];
    
    UILabel *typeLabel = (UILabel *)[cell viewWithTag:1];
    //找到子类别
    spendingType *aType =  [[DatabaseManager ShareDBManager]selectTypeByTypeID:[NSString stringWithFormat:@"%d",aBill.spendID] andIsPayout:YES];
    //找到父类别
    aType = [[DatabaseManager ShareDBManager]selectTypeByTypeID:[NSString stringWithFormat:@"%d",aType.fatherType.spendID] andIsPayout:YES];
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


//date装换为str
- (NSString *)stringMonthForDate:(NSDate *)date{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *dateStr=[dateFormatter stringFromDate:date];
    return dateStr;
}

//传值
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];//根据tableView的cell(sender)来找到你所点击的行。
    Bill *aBill = self.billArray[indexPath.row];
    
    //找到子类别
    spendingType *aType =  [[DatabaseManager ShareDBManager]selectTypeByTypeID:[NSString stringWithFormat:@"%d",aBill.spendID] andIsPayout:YES];
    
    member *aMember = [[DatabaseManager ShareDBManager] selectMemberID:aBill.memberID];
    
    NSObject *nextVC=[segue destinationViewController];//destinationViewController找你到你要传值的controller
    if ([segue.identifier isEqualToString:@"show2edit"]) {
        [nextVC setValue:aBill forKey:@"aBill"];
        [nextVC setValue:aType forKey:@"aType"];
        [nextVC setValue:aMember forKey:@"aMember"];
    }
}

@end
