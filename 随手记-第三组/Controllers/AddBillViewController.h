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
#import "Bill.h"
#import "spendingType.h"
#import "member.h"

@interface AddBillViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate/*相机协议*/,UIActionSheetDelegate>{
    NSString *_fatherTypeStr;//存放大type的string
    NSString *_typeStr;//存放小type的string
    NSString *_memberStr;//存放成员的string
    NSString *_spendName;//类别名称
    NSString *_dateStr;//存放时间的string
    BOOL _isTypePicker;//重用一个pickerView
    NSDate *_date;
}

@property (nonatomic,strong) Bill *aBill;
@property (nonatomic,strong) spendingType *aType;
@property (nonatomic,strong) member *aMember;
@property (nonatomic,strong) NSMutableArray *array;
@property (nonatomic,copy)   NSString *identifierStr;

@end
