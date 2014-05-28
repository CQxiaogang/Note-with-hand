//
//  ChartViewController.h
//  随手记-第三组
//
//  Created by student on 14-5-27.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EColumnChart.h"

@interface ChartViewController : UIViewController<EColumnChartDataSource,EColumnChartDelegate>
@property (strong, nonatomic) EColumnChart *eColumnChart;

@end
