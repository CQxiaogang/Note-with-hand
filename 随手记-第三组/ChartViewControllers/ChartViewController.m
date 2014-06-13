//
//  ChartViewController.m
//  随手记-第三组
//
//  Created by student on 14-5-27.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "ChartViewController.h"
#import "DatabaseManager.h"
#import "EColumnDataModel.h" //一条柱形
#import "EColumnChartLabel.h" //显示数据的label
#import "EFloatBox.h" //按住时弹出的详细信息显示
#import "EColor.h" //显示的颜色类别，用宏名定义所有要用的颜色
#include <stdlib.h>

@interface ChartViewController (){
    NSString *_currentMonthStr;//月份
    int _monthNumber;//月份的Number
}

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isPayoutSegmented;
- (IBAction)lastMonth:(id)sender;
- (IBAction)nextMonth:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *eColumnView;
- (IBAction)isPayoutSegmented:(UISegmentedControl *)sender;

@property (nonatomic, strong) NSMutableArray *columnDataList; //存储数据的数组
@property (nonatomic, strong) NSMutableArray *bigTypeList;//存放大类别的数组
@property (nonatomic, strong) EFloatBox *eFloatBox;//弹出的详细信息

@property (nonatomic, strong) EColumn *eColumnSelected;//view
@property (nonatomic, strong) UIColor *tempColor;//零时的颜色




@end

@implementation ChartViewController

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
    
    self.eColumnView.hidden = YES;
    
    NSDate *now=[NSDate date];
    NSString *date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM"];
    date = [formatter stringFromDate:now];
    
    NSDate *nowDate = [NSDate new];
    NSString *nowStr = [self stringMonthForDate:nowDate];
    _currentMonthStr = nowStr;
    NSArray *timeList = [nowStr componentsSeparatedByString:@"-"];
    NSString *monthStr = timeList[1];
    int month = monthStr.intValue;
    _monthNumber = month;
    
    NSMutableDictionary *moneyValueDic = [self getBillTotalMoneyByMonth:_currentMonthStr andIsPayout:YES];//得到每个类别的账单总额
    
    NSMutableDictionary *typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:YES];//得到所有的类别
    self.bigTypeList = typeDic[@"big"];
    self.columnDataList = [NSMutableArray array];
    
    if (self.bigTypeList.count==0) {
        spendingType *aType = [[spendingType alloc] init];
        aType.spendName = @"无数据";
        self.bigTypeList = [NSMutableArray arrayWithObjects:aType, nil];
        EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:[NSString stringWithFormat:@"%@",aType.spendName] value:0 index:0 unit:@"￥"];//根据柱状图的X坐标名称、对应的值、ID、单位 对一条柱状图进行赋值
        [self.columnDataList addObject:eColumnDataModel];
    }else{
        
        for (int i=0; i<self.bigTypeList.count; i++) {
            
            spendingType *bigType = self.bigTypeList[i];
            NSNumber *moneyValue = moneyValueDic[bigType.spendName];
            float value = moneyValue.floatValue;
            if (value != 0) {//
                EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:[NSString stringWithFormat:@"%@",bigType.spendName] value:value index:i unit:@"￥"];//根据柱状图的X坐标名称、对应的值、ID、单位 对一条柱状图进行赋值
                [self.columnDataList addObject:eColumnDataModel];//添加柱形到数组中
                NSLog(@"i=%d",i);
            }
        }
    }
    
    self.eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(40, 200, 250, 200)];
    [self.eColumnChart setColumnsIndexStartFromLeft:YES];//默认从左到右排序
	[self.eColumnChart setDelegate:self];
    [self.eColumnChart setDataSource:self];
    
    [self.view addSubview:self.eColumnChart];//添加外面的XY坐标系
    
    self.valueLabel.layer.cornerRadius=10;//定义控件的圆角
//    self.valueLabel.layer.borderColor=[UIColor blackColor].CGColor;//定义边框颜色
//    self.valueLabel.layer.borderWidth=0.5;//定义边框大小
//    self.valueLabel.layer.masksToBounds=YES;//定义边界 不越界
    
    //TODO:柱状图左右滑动手势
    //向左
    UISwipeGestureRecognizer *oneFingerSwipeLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(Swipe:)];
    oneFingerSwipeLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    oneFingerSwipeLeft.delegate=self;
    [self.eColumnChart addGestureRecognizer:oneFingerSwipeLeft];
    //向右
    UISwipeGestureRecognizer *oneFingerSwipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(Swipe:)];
    oneFingerSwipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    oneFingerSwipeRight.delegate=self;
    [self.eColumnChart addGestureRecognizer:oneFingerSwipeRight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark- EColumnChartDataSource 类似tableview的显示
//条形图的个数 控制个数
- (NSInteger)numberOfColumnsInEColumnChart:(EColumnChart *)eColumnChart
{
    return [self.columnDataList count];
}

//最多显示多少个柱形
- (NSInteger)numberOfColumnsPresentedEveryTime:(EColumnChart *)eColumnChart
{
    return 5;
}

//返回柱状图中value最高的一条
- (EColumnDataModel *)highestValueEColumnChart:(EColumnChart *)eColumnChart
{
    EColumnDataModel *maxDataModel = nil;
    float maxValue = -FLT_MIN;//FLT_MIN是一个常量，代表了FLOAT所能表示的最小值
    for (EColumnDataModel *dataModel in self.columnDataList)
    {
        if (dataModel.value > maxValue)
        {
            maxValue = dataModel.value;
            maxDataModel = dataModel;
        }
    }
    return maxDataModel;//返回最高的那个条形图
}

//得到index相对应的一条柱型
- (EColumnDataModel *)eColumnChart:(EColumnChart *)eColumnChart valueForIndex:(NSInteger)index
{
    if (index >= [self.columnDataList count] || index < 0) return nil;
    return [self.columnDataList objectAtIndex:index];
}


#pragma -mark- EColumnChartDelegate

//点击的那个柱形图，做出对应的显示
- (void)eColumnChart:(EColumnChart *)eColumnChart
     didSelectColumn:(EColumn *)eColumn
{
    NSLog(@"Index: %d  Value: %f", eColumn.eColumnDataModel.index, eColumn.eColumnDataModel.value);
    
    if (_eColumnSelected)
    {
        _eColumnSelected.barColor = _tempColor;
    }
    _eColumnSelected = eColumn;//用全局变量记住选中的柱状
    _tempColor = eColumn.barColor;//用全局变量记住选中的柱状的颜色
    eColumn.barColor = [UIColor redColor];//barColor：选中时的颜色
    
    _valueLabel.text = [NSString stringWithFormat:@"%.1f",eColumn.eColumnDataModel.value];//试图最顶端的label显示点击的柱状的值
    BOOL isPayout;
    if (self.isPayoutSegmented.selectedSegmentIndex == 0) {
        isPayout = YES;
    }else{
        isPayout = NO;
    }
    NSMutableDictionary *billDic = [self getBillDicTotalMoneyByMonth:@"2014-06" andIsPayout:isPayout];
    spendingType *aBigType = self.bigTypeList[eColumn.eColumnDataModel.index];
    NSArray *billList = billDic[aBigType.spendName];
    [self performSegueWithIdentifier:@"chart2show" sender:billList];
}

//手指按住并且拖动的情况下的响应函数
- (void)eColumnChart:(EColumnChart *)eColumnChart
fingerDidEnterColumn:(EColumn *)eColumn
{
    /**The EFloatBox here, is just to show an example of
     taking adventage of the event handling system of the Echart.
     You can do even better effects here, according to your needs.*/
    NSLog(@"Finger did enter %d", eColumn.eColumnDataModel.index);
    CGFloat eFloatBoxX = eColumn.frame.origin.x + eColumn.frame.size.width * 1.25;
    CGFloat eFloatBoxY = eColumn.frame.origin.y + eColumn.frame.size.height * (1-eColumn.grade);
    if (_eFloatBox)
    {
        [_eFloatBox removeFromSuperview];
        _eFloatBox.frame = CGRectMake(eFloatBoxX, eFloatBoxY, _eFloatBox.frame.size.width, _eFloatBox.frame.size.height);
        [_eFloatBox setValue:eColumn.eColumnDataModel.value];
        [eColumnChart addSubview:_eFloatBox];
    }
    else
    {
        _eFloatBox = [[EFloatBox alloc] initWithPosition:CGPointMake(eFloatBoxX, eFloatBoxY) value:eColumn.eColumnDataModel.value unit:@"￥" title:eColumn.eColumnDataModel.label];
        _eFloatBox.alpha = 0.0;
        [eColumnChart addSubview:_eFloatBox];
        
    }
    eFloatBoxY -= (_eFloatBox.frame.size.height + eColumn.frame.size.width * 0.25);
    _eFloatBox.frame = CGRectMake(eFloatBoxX, eFloatBoxY, _eFloatBox.frame.size.width, _eFloatBox.frame.size.height);
    //简单动画
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _eFloatBox.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
    
}

//当手指离开点击时做什么
- (void)eColumnChart:(EColumnChart *)eColumnChart
fingerDidLeaveColumn:(EColumn *)eColumn
{
    NSLog(@"Finger did leave %d", eColumn.eColumnDataModel.index);
    
}

//完成离开显示做得动画
- (void)fingerDidLeaveEColumnChart:(EColumnChart *)eColumnChart
{
    if (_eFloatBox)
    {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
            _eFloatBox.alpha = 0.0;
            _eFloatBox.frame = CGRectMake(_eFloatBox.frame.origin.x, _eFloatBox.frame.origin.y + _eFloatBox.frame.size.height, _eFloatBox.frame.size.width, _eFloatBox.frame.size.height);
        } completion:^(BOOL finished) {
            [_eFloatBox removeFromSuperview];
            _eFloatBox = nil;
        }];
    }
}

//TODO:柱状图 滑动手势响应函数 - 调用向左、右移动的函数
-(void)Swipe:(UISwipeGestureRecognizer *)sender{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.eColumnChart == nil) return;
        [self.eColumnChart moveRight];
        
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        if (self.eColumnChart == nil) return;
        [self.eColumnChart moveLeft];
    }
}

//TODO:得到这个月分类别下的账单金额的总和
- (NSMutableDictionary *)getBillTotalMoneyByMonth:(NSString *)month andIsPayout:(BOOL)isPayout{
    
    NSDictionary *billDic = [[DatabaseManager ShareDBManager] billDicInMonth:month];//得到这个月所有的账单
    NSArray *billList = billDic[@"billList"];//账单数组
    
    NSMutableDictionary *typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:isPayout];//得到所有的类别
    NSArray *bigTypeList = typeDic[@"big"];
    NSMutableDictionary *billOfTypeDic = [NSMutableDictionary dictionary];//将billList按大类别组建字典;
    self.bigTypeList = [bigTypeList mutableCopy];
    float totalMoney;
    if (isPayout == YES) {
        if ([billList[0] isKindOfClass:[Bill class]]) {//判断bill数组中第一个是不是Bill类型
            for (spendingType *bigType in bigTypeList) {
                NSArray *subList = [typeDic objectForKey:bigType.spendName];
                totalMoney = 0.0;
                for (spendingType *subType in subList) {
                    for (Bill *aBill in billList) {
                        if (aBill.spendID == subType.spendID && aBill.isPayout == isPayout) {
                            totalMoney +=aBill.moneyAmount;
                        }
                    }// 3 for end
                }
                if (totalMoney!=0) {
                    NSNumber *totalNum = [NSNumber numberWithFloat:totalMoney];
                    [billOfTypeDic setObject:totalNum forKey:bigType.spendName];
                }
            }// 1 for end
        }
    }else{
        if ([billList[0] isKindOfClass:[Bill class]]) {
            for (spendingType *bigType in bigTypeList) {
                totalMoney = 0.0;
                for (Bill *aBill in billList) {
                    if (aBill.spendID == bigType.spendID && aBill.isPayout == isPayout) {
                        totalMoney +=aBill.moneyAmount;
                    }
                }// 2 for end
                if (totalMoney!=0) {
                    NSNumber *totalNum = [NSNumber numberWithFloat:totalMoney];
                    [billOfTypeDic setObject:totalNum forKey:bigType.spendName];
                }//if end
            }
        }//if end
    }
    
    return billOfTypeDic;
}

//TODO:得到对应类别下的账单数组
- (NSMutableDictionary *)getBillDicTotalMoneyByMonth:(NSString *)month andIsPayout:(BOOL)isPayout{
    
    NSDictionary *billDic = [[DatabaseManager ShareDBManager] billDicInMonth:month];//得到这个月所有的账单
    NSArray *billList = billDic[@"billList"];//账单数组
    
    NSMutableDictionary *typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:isPayout];//得到所有的类别
    NSArray *bigTypeList = typeDic[@"big"];
    
    NSMutableDictionary *billListOfTypeDic = [NSMutableDictionary dictionary];//将billList按大类别组建字典
    
    
    for (spendingType *bigType in bigTypeList) {
        NSMutableArray *billofTypeList = [NSMutableArray array];
        NSArray *subList = [typeDic objectForKey:bigType.spendName];
        for (spendingType *subType in subList) {
            for (Bill *aBill in billList) {
                if (aBill.spendID == subType.spendID) {
                    [billofTypeList addObject:aBill];
                }
            }// 3 for end
        }
        [billListOfTypeDic setObject:billofTypeList forKey:bigType.spendName];
    }// 1 for end
    
    return billListOfTypeDic;
}

#pragma mark - 日期转换函数

- (NSString *)stringMonthForDate:(NSDate *)date{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *dateStr=[dateFormatter stringFromDate:date];
    return dateStr;
}

#pragma mark - 上、下月的切换
- (IBAction)lastMonth:(id)sender {//上个月
    
    UILabel *monethLabel = (UILabel *)[self.view viewWithTag:23];
    if (_monthNumber>1) {//点击一次加一次。
        _monthNumber-=1;
        
    }
    [self.columnDataList removeAllObjects];
    [self.eColumnChart removeFromSuperview];
    
    NSString *monthStr;
    if (_monthNumber>=1 && _monthNumber<=9) {
        monthStr = [NSString stringWithFormat:@"2014-0%d",_monthNumber];
    }else if(_monthNumber>=10 && _monthNumber<=12){
        monthStr = [NSString stringWithFormat:@"2014-%d",_monthNumber];
    }
    monethLabel.text = monthStr;
    NSMutableDictionary *moneyValueDic = [self getBillTotalMoneyByMonth:monthStr andIsPayout:YES];//得到每个类别的账单总额
    if ([moneyValueDic allKeys].count == 0) {
        self.eColumnView.hidden = NO;
        
    }else{
        self.eColumnView.hidden = YES;
        NSMutableDictionary *typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:YES];//得到所有的类别
        self.bigTypeList = typeDic[@"big"];
        
        for (int i=0; i<self.bigTypeList.count; i++) {
            spendingType *bigType = self.bigTypeList[i];
            NSNumber *moneyValue = moneyValueDic[bigType.spendName];
            float value = moneyValue.floatValue;
            if (value != 0) {//
                EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:[NSString stringWithFormat:@"%@",bigType.spendName] value:value index:i unit:@"￥"];//根据柱状图的X坐标名称、对应的值、ID、单位 对一条柱状图进行赋值
                [self.columnDataList addObject:eColumnDataModel];//添加柱形到数组中
            }
        }
        self.eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(40, 200, 250, 200)];
        [self.eColumnChart setColumnsIndexStartFromLeft:YES];//默认从左到右排序
        [self.eColumnChart setDelegate:self];
        [self.eColumnChart setDataSource:self];
        
        [self.view addSubview:self.eColumnChart];//添加外面的XY坐标系
    }
    
    
}

- (IBAction)nextMonth:(id)sender {//下个月
    UILabel *monethLabel = (UILabel *)[self.view viewWithTag:23];
    
    if (_monthNumber<12) {
        _monthNumber+=1;
    }
    
    [self.columnDataList removeAllObjects];
    
    NSString *monthStr;
    if (_monthNumber>=1 && _monthNumber<=9) {
        monthStr = [NSString stringWithFormat:@"2014-0%d",_monthNumber];
    }else if(_monthNumber>=10 && _monthNumber<=12){
        monthStr = [NSString stringWithFormat:@"2014-%d",_monthNumber];
    }
    monethLabel.text = monthStr;
    NSMutableDictionary *moneyValueDic = [self getBillTotalMoneyByMonth:monthStr andIsPayout:YES];//得到每个类别的账单总额
    
    NSMutableDictionary *typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:YES];//得到所有的类别
    self.bigTypeList = typeDic[@"big"];
    
    for (int i=0; i<self.bigTypeList.count; i++) {
        spendingType *bigType = self.bigTypeList[i];
        NSNumber *moneyValue = moneyValueDic[bigType.spendName];
        float value = moneyValue.floatValue;
        if (value != 0) {//
            EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:[NSString stringWithFormat:@"%@",bigType.spendName] value:value index:i unit:@"￥"];//根据柱状图的X坐标名称、对应的值、ID、单位 对一条柱状图进行赋值
            [self.columnDataList addObject:eColumnDataModel];//添加柱形到数组中
        }
    }
    
    [self.eColumnChart reloadData];
    
}
#pragma mark - 改变支出收入
- (IBAction)isPayoutSegmented:(UISegmentedControl *)sender {
    
    NSMutableDictionary *moneyValueDic;
    NSString *monthStr;
    
    if (_monthNumber>=1 && _monthNumber<=9) {
        monthStr = [NSString stringWithFormat:@"2014-0%d",_monthNumber];
    }else if(_monthNumber>=10 && _monthNumber<=12){
        monthStr = [NSString stringWithFormat:@"2014-%d",_monthNumber];
    }
    BOOL isPayout;
    if (sender.selectedSegmentIndex == 0) {
        moneyValueDic = [self getBillTotalMoneyByMonth:monthStr andIsPayout:YES];//得到每个类别的账单总额
        isPayout = YES;
    }else if (sender.selectedSegmentIndex == 1){
        moneyValueDic = [self getBillTotalMoneyByMonth:monthStr andIsPayout:NO];//得到每个类别的账单总额
        isPayout = NO;
    }
    
    [self.columnDataList removeAllObjects];
    [self.eColumnChart removeFromSuperview];
    
    if ([moneyValueDic allKeys].count == 0) {
        self.eColumnView.hidden = NO;
        
    }else{
        self.eColumnView.hidden = YES;
        NSMutableDictionary *typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:isPayout];//得到所有的类别
        NSArray *bigTypeList = typeDic[@"big"];
        
        for (int i=0; i<bigTypeList.count; i++) {
            spendingType *bigType = bigTypeList[i];
            NSNumber *moneyValue = moneyValueDic[bigType.spendName];
            float value = moneyValue.floatValue;
            if (value != 0) {//
                EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:[NSString stringWithFormat:@"%@",bigType.spendName] value:value index:i unit:@"￥"];//根据柱状图的X坐标名称、对应的值、ID、单位 对一条柱状图进行赋值
                [self.columnDataList addObject:eColumnDataModel];//添加柱形到数组中
            }
        }
        self.eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(40, 200, 250, 200)];
        [self.eColumnChart setColumnsIndexStartFromLeft:YES];//默认从左到右排序
        [self.eColumnChart setDelegate:self];
        [self.eColumnChart setDataSource:self];
        
        [self.view addSubview:self.eColumnChart];//添加外面的XY坐标系
    }
    
}

#pragma mark - 传值
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSObject *nextVC=[segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"chart2show"]) {
        [nextVC setValue:sender forKey:@"array"];
    }
}


@end
