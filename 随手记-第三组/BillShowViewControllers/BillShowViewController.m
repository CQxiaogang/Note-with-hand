//
//  BillShowViewController.m
//  随手记-第三组
//
//  Created by student on 14-5-28.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "BillShowViewController.h"

@interface BillShowViewController ()


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign)BOOL isOpen;
@property (nonatomic,retain)NSIndexPath *selectIndex;
@property (nonatomic,strong)NSIndexPath *deleteIndexPath;
@property (strong,nonatomic)NSMutableArray *billList;
@property (nonatomic,strong)NSMutableArray *timeList;

@end

@implementation BillShowViewController

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
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSDate *now=[NSDate date];
    NSString *date;
    self.billList = [[NSMutableArray alloc]init];
    self.timeList = [[NSMutableArray alloc]init];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM"];
    date = [formatter stringFromDate:now];
    NSLog(@"%@",date);
    for (int i =1; i < 13;  i++) {
        
        NSString *time;
        if (i<10) {
            time=[NSString stringWithFormat:@"0%d",i];
        }else
        {
            time=[NSString stringWithFormat:@"%d",i];
        }
        
        NSDictionary *dic = [[DatabaseManager ShareDBManager] billDicInMonth:[NSString stringWithFormat:@"2014-%@",time]];

        [self.timeList addObject:[NSString stringWithFormat:@"%i",i]];
        NSArray *list = dic[@"billList"];
        [self.billList addObject:list];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.billList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
            NSInteger ret = [[self.billList objectAtIndex:section] count]+1;
            return ret;
        }
        NSArray *list =[self.billList objectAtIndex:section];
        
        if(list.count == 0){
            return 2;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView.separatorStyle = NO;//separatorStyle == tableView的分离线
    if (self.isOpen&&self.selectIndex.section == indexPath.section&&indexPath.row!=0) {
        if ([[[self.billList objectAtIndex:indexPath.section] firstObject] isKindOfClass:[NSString class]]) {
            //显示第三个cell
            static NSString *CellIdentifier = @"Cell3";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            UILabel *label = (UILabel*)[cell viewWithTag:41];
            label.textColor = [UIColor blackColor];
            label.font = [UIFont fontWithName:@"STHeiti-Medium.ttc" size:10];
            label.text = @"记账也是一种回忆！快记账吧！";
            return cell;
        }
        //显示第二个cell
        static NSString *CellIdentifier = @"Cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        NSMutableArray *aBillList=self.billList[indexPath.section];
        aBillList = [self billListPaixu:aBillList];
        Bill *aBill = aBillList[indexPath.row-1];
        
        //日期显示
        UILabel *dayLabel = (UILabel *)[cell viewWithTag:1];//显示
        
        NSString *aBilltimeStr;
        if (10 == aBill.billTime.length) {
             aBilltimeStr = aBill.billTime;
        }
        
        NSArray *timeArray = [aBilltimeStr componentsSeparatedByString:@"-"];
        NSString *timeStr = timeArray[2];
        NSString *timeStr1 = [timeStr substringWithRange:NSMakeRange(0, 1)];
        NSString *timeStr2 = [timeStr substringWithRange:NSMakeRange(1, 1)];
        
        UIView *lineView = (UIView*)[cell viewWithTag:7];
        
        if (indexPath.row == 1) {
            if ([timeStr1 isEqualToString:@"0"]) {
                NSString *time=[NSString stringWithFormat:@"%@号",timeStr2];
                dayLabel.text = time;
            }else{
                NSString *time=[NSString stringWithFormat:@"%@号",timeStr];
                dayLabel.text = time;
            }
        }
        else{
            Bill *oldBill = aBillList[indexPath.row-2];
            NSArray *dayList = [oldBill.billTime componentsSeparatedByString:@"-"];
            NSInteger newDay = [timeStr integerValue];
            NSInteger day = [[dayList lastObject] integerValue];
            if (newDay == day) {
                dayLabel.text = @"";
                lineView.backgroundColor = [UIColor clearColor];
            }
            else{
                if ([timeStr1 isEqualToString:@"0"]) {
                    NSString *time=[NSString stringWithFormat:@"%@号",timeStr2];
                    dayLabel.text = time;
                }else{
                    NSString *time=[NSString stringWithFormat:@"%@号",timeStr];
                    dayLabel.text = time;
                }
            }
            
        }
        //获得大类别显示在typeLabel上
        UILabel *typeLabel = (UILabel *)[cell viewWithTag:4];//类别
        //查出小类别
        spendingType *aType = [[DatabaseManager ShareDBManager] selectTypeByTypeID:[NSString stringWithFormat:@"%d",aBill.spendID] andIsPayout:YES];
        //在根据小类别的id查到大类别。因为大类别是一样的
        aType =  [[DatabaseManager ShareDBManager]selectTypeByTypeID:[NSString stringWithFormat:@"%d",aType.fatherType.spendID] andIsPayout:YES];
        typeLabel.text = aType.spendName;
        
        UILabel *spendLabel = (UILabel *)[cell viewWithTag:6];//支出
        NSString *spendStr = [NSString stringWithFormat:@"%.2f",aBill.moneyAmount];
        spendLabel.text = spendStr;
        
        return cell;
        
    }
    else{//第一个cell
        static NSString *CellIdentifier = @"Cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
       
        UILabel *monthLabel = (UILabel *)[cell viewWithTag:10];//月份显示
        
        //日期显示
        NSString *aBilltimeStr = self.timeList[indexPath.section];
    
        monthLabel.text = [NSString stringWithFormat:@"%@月",aBilltimeStr];
        UILabel *isPayout = (UILabel *)[cell viewWithTag:12];
        UILabel *notPayout = (UILabel *)[cell viewWithTag:13];
        UILabel *remain = (UILabel *)[cell viewWithTag:14];
        if (aBilltimeStr.intValue<10) {
            notPayout.text=[NSString stringWithFormat:@"%.2f",[[DatabaseManager ShareDBManager] billInDay:nil InWeek:nil InMonth:[NSString stringWithFormat:@"2014-0%@",aBilltimeStr] IsPayOut:YES]];
            isPayout.text=[NSString stringWithFormat:@"%.2f",[[DatabaseManager ShareDBManager] billInDay:nil InWeek:nil InMonth:[NSString stringWithFormat:@"2014-0%@",aBilltimeStr] IsPayOut:NO]];
            remain.text=[NSString stringWithFormat:@"%.2f",notPayout.text.doubleValue-isPayout.text.doubleValue];
        }else{
            notPayout.text=[NSString stringWithFormat:@"%.2f",[[DatabaseManager ShareDBManager] billInDay:nil InWeek:nil InMonth:[NSString stringWithFormat:@"2014-%@",aBilltimeStr] IsPayOut:YES]];
            isPayout.text=[NSString stringWithFormat:@"%.2f",[[DatabaseManager ShareDBManager] billInDay:nil InWeek:nil InMonth:[NSString stringWithFormat:@"2014-%@",aBilltimeStr] IsPayOut:NO]];
            remain.text=[NSString stringWithFormat:@"%.2f",notPayout.text.doubleValue-isPayout.text.doubleValue];
        }
        
        return cell;
    }
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    
    self.isOpen = firstDoInsert;
    
    
	[self.tableView beginUpdates];//重新加载tableView的数据
	
    NSInteger section = self.selectIndex.section;
    NSArray *array = [self.billList objectAtIndex:section];
    
    NSInteger contentCount;
    if (array.count == 0) {
        contentCount = 1;
    }
    else
    {
        contentCount = [array count];//获取每个section的cell个数
    }
    
	NSMutableArray *rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
    //此处i＝1是由于我们展开section是从第1个cell开始加载的
	if (firstDoInsert)
    {
        [self.tableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationRight];
        //给tableview插入指定IndexPath,UITableViewRowAnimationLeft 是指定子cell的出现方法
    }else
    {
        [self.tableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationRight];
        //给tableview删除指定IndexPath
    }
	[self.tableView endUpdates];
    //重新加载tableView的数据
    
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [self.tableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (self.isOpen) [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    //UITableViewScrollPositionBottom指定section的动画方式为向下展开；此方法默认为UITableViewScrollPositionBottom 还有：  UITableViewScrollPositionTop等
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        if ([indexPath isEqual:self.selectIndex]) {
            self.isOpen = NO;
            [self didSelectCellRowFirstDo:NO nextDo:NO];
            self.selectIndex = nil;
        }else
        {
            if (!self.selectIndex) {
                self.selectIndex = indexPath;
                [self didSelectCellRowFirstDo:YES nextDo:NO];//调用MyMethod方法给tableView绑定相关要求；
            }else
            {
                [self didSelectCellRowFirstDo:NO nextDo:YES];
            }
        }
    }
    else{
       
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //选中后的反显颜色即刻消失 一切操作结束才取消反映色
}

//TODO:tableView的删除
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //从数组删除
        NSMutableArray *array = self.billList[indexPath.section];
        Bill *aBill = array[indexPath.row-1];
        //从数据库删除
        [[DatabaseManager ShareDBManager] deleteBill:aBill];
        [array removeObjectAtIndex:indexPath.row-1];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView reloadData];
}

//对日期进行排序
-(NSMutableArray*)billListPaixu:(NSMutableArray*)list{
    NSInteger count = list.count;
    for (int i = 0;  i < count-1; i++) {
        for (int k = 0; k < count -1; k++) {
            
            
            Bill *currentBill = [list objectAtIndex:k];
            Bill *nextBill = [list objectAtIndex:k+1];
            
            int a = [[currentBill.billTime substringWithRange:NSMakeRange(8, 2)] intValue];
            int b = [[nextBill.billTime substringWithRange:NSMakeRange(8, 2)] intValue];
            
            if (a > b) {
                [list exchangeObjectAtIndex:k withObjectAtIndex:k+1];//- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;比较大小后,交换两个对象
            }
           
        }
    }
    return list;
}
#pragma mark - 传值
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSIndexPath  *indexPath = [self.tableView indexPathForCell:sender];//根据tableView的cell(sender)来找到你所点击的行
    NSArray *billArr = self.billList[indexPath.section];
    Bill *aBill = billArr[indexPath.row-1];
    
    spendingType *aType = [[DatabaseManager ShareDBManager] selectTypeByTypeID:[NSString stringWithFormat:@"%d",aBill.spendID] andIsPayout:YES];
    
    member *aMember = [[DatabaseManager ShareDBManager] selectMemberID:aBill.memberID];
    
    NSObject *nextVC=[segue destinationViewController];
    if ([segue.identifier isEqualToString:@"billShow2Modify"]) {
        [nextVC setValue:aBill forKey:@"aBill"];
        [nextVC setValue:aType forKey:@"aType"];
        [nextVC setValue:aMember forKey:@"aMember"];
        
        NSString *identifierStr = @"billShow2Modify";
        [nextVC setValue:identifierStr forKey:@"identifierStr"];
    }
}
@end
