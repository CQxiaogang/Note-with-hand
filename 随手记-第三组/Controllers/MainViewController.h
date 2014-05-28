//
//  MainViewController.h
//  随手记-第三组
//
//  Created by student on 14-5-6.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseManager.h"
//自定义键盘-------
#import "Config.h"
#import "ZenKeyboard.h"
//---------------
#import "RBCustomDatePickerView.h" //自定义的datePickerView

@interface MainViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate, UIImagePickerControllerDelegate/*相机协议*/,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>{
    NSString *_fatherTypeStr;
    NSString *_typeStr;
    float _todayTotal;
    float _weekTotal;
    float _monthTotal;
}
@property (nonatomic,strong) NSMutableArray *fatherType;

@property(nonatomic,strong)ZenKeyboard *keyboardView;

@end 
