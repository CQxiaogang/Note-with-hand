//
//  ShowViewController.m
//  随手记-第三组
//
//  Created by student on 14-6-9.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "ShowViewController.h"
#import "DatabaseManager.h"
#import "Bill.h"
#import "member.h"
#import "NoDataView.h"

@interface ShowViewController ()

@property (nonatomic,strong) NSMutableArray *billArray;
@property (weak , nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableDictionary *typeDic;
@property (nonatomic,strong) NSArray *typeList;

@end

@implementation ShowViewController

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
    //TODO:tableView的代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //TODO:今天的bill数据
    NSDate *now=[NSDate date];
    NSString *date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    date = [formatter stringFromDate:now];
    self.billArray = [[DatabaseManager ShareDBManager]billListInDay:date InWeek:nil InMonth:nil];
    
    self.typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:YES];
    
    //TODO:- 有数据属性tableView，没有数据不显示tableView
    if (self.billArray.count == 0) {
        [self.tableView removeFromSuperview];
        NoDataView *noDataView = [[NoDataView alloc] init];
        [self.view addSubview: [noDataView noDataView:self.view]];
    }else{
        [self.tableView reloadData];
    }
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
    
    spendingType *aType = [[DatabaseManager ShareDBManager]selectTypeByTypeID:[NSString stringWithFormat:@"%d",aBill.spendID] andIsPayout:YES];
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
    
   spendingType *aType = [[DatabaseManager ShareDBManager]selectTypeByTypeID:[NSString stringWithFormat:@"%d",aBill.spendID] andIsPayout:YES];
    
    member *aMember = [[DatabaseManager ShareDBManager] selectMemberID:aBill.memberID];
    
    NSObject *nextVC=[segue destinationViewController];//destinationViewController找你到你要传值的controller
    if ([segue.identifier isEqualToString:@"dayShow2Edit"]) {
        [nextVC setValue:aBill forKey:@"aBill"];
        [nextVC setValue:aType forKey:@"aType"];
        [nextVC setValue:aMember forKey:@"aMember"];
        
        NSString *identifierStr = @"dayShow2Edit";
        [nextVC setValue:identifierStr forKey:@"identifierStr"];
    }
}

@end
