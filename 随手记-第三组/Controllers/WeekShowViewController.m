//
//  WeekShowViewController.m
//  随手记-第三组
//
//  Created by student on 14-6-9.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "WeekShowViewController.h"
#import "DatabaseManager.h"
#import "Bill.h"

@interface WeekShowViewController ()

@property(nonatomic,strong)NSMutableArray *billArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *typeList;

@end

@implementation WeekShowViewController

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
    NSDate *nowDate = [[NSDate alloc] init];
    NSString *weekStr = [self stringWeekForDate:nowDate];
    self.billArray = [[DatabaseManager ShareDBManager]billListInDay:nil InWeek:weekStr InMonth:nil];
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

//TODO:删除tableView
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Bill *aBill = self.billArray[indexPath.row];
        [[DatabaseManager ShareDBManager]deleteBill:aBill];
        [self.billArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [tableView reloadData];
}

//给定一个日期，得到它处于一年的那一周
- (NSString *)stringWeekForDate:(NSDate *)date{
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekOfYearCalendarUnit fromDate:date];
    int weekday = [componets weekOfYear];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *dateStr=[dateFormatter stringFromDate:date];
    NSString *str=[NSString stringWithFormat:@"%@-%@",dateStr,@(weekday-1)];
    return str;
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
