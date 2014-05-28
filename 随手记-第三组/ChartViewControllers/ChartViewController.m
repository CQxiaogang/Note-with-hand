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

@interface ChartViewController ()

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
- (IBAction)leftButton:(UIButton *)sender;
- (IBAction)rightButton:(UIButton *)sender;

@property (nonatomic, strong) NSArray *data; //存储数据的数组
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
    
    NSMutableArray *temp=[NSMutableArray array];
    NSMutableDictionary *typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:YES];
    NSArray *nameList = [typeDic objectForKey:@"big"];
    for (int i=0;i<nameList.count; i++) {
        spendingType *aType = nameList[i];
        //生成对应的柱状图
        int value = aType.budgetMoneyValue.intValue;
        EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:[NSString stringWithFormat:@"%@",aType.spendName] value:value index:i unit:@"￥"];//根据柱状图的X坐标名称、对应的值、ID、单位 对一条柱状图进行赋值
        [temp addObject:eColumnDataModel];//添加柱形到数组中
    }
    self.data = [NSArray arrayWithArray:temp];
    
    self.eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(40, 150, 250, 200)];
    [self.eColumnChart setColumnsIndexStartFromLeft:YES];//默认从左到右排序
	[self.eColumnChart setDelegate:self];
    [self.eColumnChart setDataSource:self];
    
    [self.view addSubview:self.eColumnChart];//添加外面的XY坐标系
    
    self.valueLabel.layer.cornerRadius=10;//定义控件的圆角
//    self.valueLabel.layer.borderColor=[UIColor blackColor].CGColor;//定义边框颜色
//    self.valueLabel.layer.borderWidth=0.5;//定义边框大小
//    self.valueLabel.layer.masksToBounds=YES;//定义边界 不越界
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma -mark- EColumnChartDataSource 类似tableview的显示
//条形图的个数
- (NSInteger)numberOfColumnsInEColumnChart:(EColumnChart *)eColumnChart
{
    return [_data count];
}

//最小显示多少个柱形
- (NSInteger)numberOfColumnsPresentedEveryTime:(EColumnChart *)eColumnChart
{
    return 5;
}

//返回柱状图中value最高的一条
- (EColumnDataModel *)highestValueEColumnChart:(EColumnChart *)eColumnChart
{
    EColumnDataModel *maxDataModel = nil;
    float maxValue = -FLT_MIN;//FLT_MIN是一个常量，代表了FLOAT所能表示的最小值
    for (EColumnDataModel *dataModel in _data)
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
    if (index >= [_data count] || index < 0) return nil;
    return [_data objectAtIndex:index];
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
    
    //    [self performSegueWithIdentifier:@"column2Viewtwo" sender:nil];
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
        _eFloatBox = [[EFloatBox alloc] initWithPosition:CGPointMake(eFloatBoxX, eFloatBoxY) value:eColumn.eColumnDataModel.value unit:@"kWh" title:@"Title"];
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

//调用向左、右移动的函数
- (IBAction)leftButton:(UIButton *)sender {
    if (self.eColumnChart == nil) return;
    [self.eColumnChart moveLeft];
}

- (IBAction)rightButton:(UIButton *)sender {
    if (self.eColumnChart == nil) return;
    [self.eColumnChart moveRight];
}
@end
