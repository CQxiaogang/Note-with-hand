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
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
        
//        NSLog(@"%@",dic);
        
//        NSDictionary *dic = [[DatabaseManager ShareDBManager] billDicInMonth:date];
        [self.timeList addObject:[NSString stringWithFormat:@"%i",i]];
        NSArray *list = dic[@"billList"];
        [self.billList addObject:list];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.billList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
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
            int newDay = [timeStr integerValue];
            int day = [[dayList lastObject] integerValue];
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
    else{
        static NSString *CellIdentifier = @"Cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
       
        UILabel *monthLabel = (UILabel *)[cell viewWithTag:10];//月份显示
        
        //日期显示
        NSString *aBilltimeStr = self.timeList[indexPath.section];
        monthLabel.text = [NSString stringWithFormat:@"%@月",aBilltimeStr];
        
//        //判断是否有这个类
//        int section = self.selectIndex.section;
//        NSArray *array = [self.billList objectAtIndex:section];
//        id obj = [array objectAtIndex:0];
//        if (![obj isKindOfClass:[Bill class]]) {
//            return cell;
//        }
        
//        NSArray *aBillList=self.billList[indexPath.row];
//        Bill *aBill = aBillList[indexPath.row];
        
//        NSArray *timeArray = [aBilltimeStr componentsSeparatedByString:@"-"];
//        NSString *timeStr = timeArray[1];
//        NSString *timeStr1 = [timeStr substringWithRange:NSMakeRange(0, 1)];
//         NSString *timeStr2 = [timeStr substringWithRange:NSMakeRange(1, 1)];
//        if ([timeStr1 isEqualToString:@"0"]) {
//            NSString *time=[NSString stringWithFormat:@"%@月",timeStr2];
//            monthLabel.text = time;
//        }else{
//            NSString *time=[NSString stringWithFormat:@"%@月",timeStr];
//            monthLabel.text = time;
//        }
        
//        UILabel *dateLabel = (UILabel *)[cell viewWithTag:11];//时间
//        UILabel *spendLabel = (UILabel *)[cell viewWithTag:12];//支出
//        NSArray *spendList=self.billList[indexPath.row];
//        for (int i=0; i<spendList.count; i++) {
//            NSString *spendStr = [NSString stringWithFormat:@"%.2f",[aBillList[i] moneyAmount]];
//            spendLabel.text = spendStr;
//        }
        
        
//        UILabel *incomeLabel = (UILabel *)[cell viewWithTag:13];//收入
        
        return cell;
    }
    
    
    // Configure the cell...
    
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    
    self.isOpen = firstDoInsert;
    
    
	[self.tableView beginUpdates];//重新加载tableView的数据
	
    int section = self.selectIndex.section;
    NSArray *array = [self.billList objectAtIndex:section];
    
    int contentCount;
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
        //        NSDictionary *dic = [_dataList objectAtIndex:indexPath.section];
        //        NSArray *list = [dic objectForKey:@"list"];
        //        NSString *item=[[NSString alloc]init];
        //        if ([list[0] isKindOfClass:[NSString class]]) {
        //            item=@"没有记录";
        //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:item message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
        //            [alert show];
        //        }else{
        //            Bill *abill=list[indexPath.row-1];
        //            [self performSegueWithIdentifier:@"toUpdate" sender:abill];
        //        }
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
    int count = list.count;
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
    }
}
@end
