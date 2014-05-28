//
//  DatabaseManager.h
//  随手记-第三组
//
//  Created by student on 14-5-5.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Bill.h"
#import "spendingType.h"
#import "member.h"
#import "budget.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"

@interface DatabaseManager : NSObject
+(instancetype)ShareDBManager;//单例
-(instancetype)init;//初始化

//账单
-(BOOL)addNewBill:(Bill *)aBill;//添加
-(BOOL)deleteBill:(Bill *)aBill;//删除
-(BOOL)modifyBill:(Bill *)aBill;//修改

-(NSMutableDictionary *)billListWithDate:(NSDate *)startDate toDate:(NSDate *)endDate inType:(spendingType *)aType inMember:(member *)amember isPayout:(BOOL)isPayout;//根据时间和type查询账单(分为收入、支出)
-(NSMutableDictionary *)billListByDate:(NSDate *)date andIsPayout:(BOOL)isPayout isWeek:(NSString *)string;//按日期分别查询本周、本月的所有账单，以供分组tableView显示

//分开写的账单查询语句
-(NSMutableArray *)billListInDay:(NSString *)day InWeek:(NSString *)week InMonth:(NSString *)month;
-(double)billInDay:(NSString *)day InWeek:(NSString *)week InMonth:(NSString *)month IsPayOut:(BOOL)isPayOut;
-(NSMutableArray *)billListInMonth:(NSString *)month IsPayOut:(BOOL)isPayOut;
-(NSDictionary *)billDicInMonth:(NSString *)month; //首界面里面的本月cell点击后显示的tableview调用


//消费类别
-(BOOL)addNewSpendType:(spendingType *)aSpengType;//添加
-(BOOL)deleteSpendType:(spendingType *)aSpengType;//删除
-(BOOL)modifySpendType:(spendingType *)aSpengType;//修改
-(NSMutableDictionary *)readSpendTypeList:(spendingType *)aSpendType andIsPayout:(BOOL)isPayout;//用字典返回类别表中的所有类别
-(spendingType *)selectTypeByTypeName:(NSString *)typeName;//按照类别名称
-(NSMutableArray *)selectTypeListByFatherTypeID:(int)fatherTypeID andIsPayout:(BOOL)isPayout;


//成员
-(BOOL)addNewMember:(member *)aMember;//添加
-(BOOL)deleteMenber:(member*)aMember;//删除
-(BOOL)modifyMember:(member *)aMember;//修改
-(member *)selectMember:(NSString *)memberName;//按照名字查询
-(NSMutableArray *)readAllMemberList;

//计算函数  每个类别在支出时占这个月的比例
-(float)calculateDifferenceWithType:(spendingType *)mainType;//单个大类别的预算和支出的差

@end
