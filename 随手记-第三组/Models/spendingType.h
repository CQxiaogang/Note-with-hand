//
//  spendingType.h
//  随手记-第三组
//
//  Created by student on 14-5-5.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface spendingType : NSObject

@property(nonatomic,assign)int spendID;//消费类别ID
@property(nonatomic,copy)NSString *spendName;//名称
@property(nonatomic,strong) spendingType *fatherType;//父类别（相当于链表结构，通过判断父类别有无确认类别是那级的）存入数据库中时，就只存ID，相当于上面的fatherID
@property(nonatomic,strong)NSNumber *budgetMoneyValue;//预算金额
@property(nonatomic,assign) BOOL isPayout;//默认是支出

@end
