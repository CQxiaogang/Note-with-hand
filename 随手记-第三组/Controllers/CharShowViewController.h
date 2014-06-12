//
//  CharShowViewController.h
//  随手记-第三组
//
//  Created by xiaoGXHZC on 14-6-10.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharShowViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray *array;

@end
