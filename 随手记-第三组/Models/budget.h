//
//  budget.h
//  随手记-第三组
//
//  Created by student on 14-5-5.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface budget : NSObject
@property(nonatomic,assign)int budgetID;//预算消费ID
@property(nonatomic,assign)int budgetFatheID;//父类别ID
@property(nonatomic,copy)NSNumber *budgetMoneyValue;//金额
@end
