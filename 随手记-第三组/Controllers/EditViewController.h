//
//  EditViewController.h
//  随手记-第三组
//
//  Created by student on 14-5-9.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    NSArray *_childArray;
}
@property(nonatomic,strong)NSMutableDictionary *typeDic;
@end
