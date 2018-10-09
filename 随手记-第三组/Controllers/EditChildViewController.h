//
//  EditChildViewController.h
//  随手记-第三组
//
//  Created by student on 14-5-9.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spendingType.h"

@interface EditChildViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    
}
@property(nonatomic,strong)NSMutableArray *childArray;
@property(nonatomic,strong) NSNumber *fatherID;
@end
