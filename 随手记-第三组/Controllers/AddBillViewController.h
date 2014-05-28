//
//  AddBillViewController.h
//  随手记-第三组
//
//  Created by student on 14-5-15.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "ZenKeyboard.h"
#import "RBCustomDatePickerView.h" //自定义的datePickerView

@interface AddBillViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextViewDelegate>{
    NSString *_fatherTypeStr;//存放大type的string
    NSString *_typeStr;//存放小type的string
    NSString *_memberStr;//存放成员的string
    NSString *_spendName;//类别名称
    NSString *_dateStr;//存放时间的string
    BOOL _isTypePicker;
    NSDate *_date;
}

@property (nonatomic,strong) NSMutableArray *typeList;//存放type
@property (nonatomic,strong) NSMutableArray *memberList;//存放成员
@property (nonatomic,strong) NSMutableArray *budgetClasslist;//消费类别数组

@end
