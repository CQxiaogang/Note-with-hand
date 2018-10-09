//
//  DatabaseManager.m
//  随手记-第三组
//
//  Created by student on 14-5-5.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "DatabaseManager.h"
#define kDBName @"shuiShouji.db"
#define kBillTableName @"BillTable"
#define kSpendTypeName @"SpengdTypeTable"
#define kMemberName @"MemberTable"
#define kBudgetName @"BudgetTable"
#define kPassword @"password"

@interface DatabaseManager ()

@property(nonatomic,strong)FMDatabase *databade;

@end

@implementation DatabaseManager

static DatabaseManager *sharedManager=nil;
+(instancetype)ShareDBManager{
    if (sharedManager==nil) {
        sharedManager=[[super alloc]init];
    }
    return sharedManager;
}

-(NSString *)DBPath{
    NSArray * dirList=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[dirList firstObject];
    NSString *dbPath = [path stringByAppendingPathComponent:kDBName];
    NSLog(@"%@",dbPath);
    return dbPath;
}

-(instancetype)init{
    self=[super init];
    if (self) {
        
        //数据库的copy，作用：在copy工程时，可以吧数据库一起copy。当在别的机器上运行时，就可以读取数据库中的文件。
        NSFileManager *filemanager=[NSFileManager defaultManager];//文件管理
        if (![filemanager fileExistsAtPath:[self DBPath]]) {//判断是否有这个数据库文件
            NSString *name=[[NSBundle mainBundle]pathForResource:@"shuiShouji" ofType:@"db"];//找到当前数据库文件
            [filemanager copyItemAtPath:name toPath:[self DBPath] error:nil];//把数据库文件copy到当前的数据库文件中
        }
        
        self.databade=[FMDatabase databaseWithPath:[self DBPath]];
        if (![self.databade open]) {
            NSLog(@"数据库打开失败");
        }
        NSLog(@"成功");
        //建Bill表
        NSString *createSql=[NSString stringWithFormat:@"create table if not exists %@(billID integer primary key autoincrement,spendID integer,memberID integer,moneyAmount integer,billImageData blob,billTime text,billRemarks text,isPayOut bool)",kBillTableName];
        if (![self.databade executeUpdate:createSql]) {
            NSLog(@"建表/打开表: %@ 失败",kBillTableName);
        }
        NSLog(@"成功");
        //建SpengdingType表
        createSql=[NSString stringWithFormat:@"create table if not exists %@(spendID integer primary key autoincrement,spendName text,spendfatherID integer,budgetMoneyValue integer,isPayOut bool)",kSpendTypeName];
        if (![self.databade executeUpdate:createSql]) {
            NSLog(@"建表/打开表: %@ 失败",kSpendTypeName);
        }
        NSLog(@"成功");
        //建member表
        createSql=[NSString stringWithFormat:@"create table if not exists %@(memberID integer primary key autoincrement,memberName text)",kMemberName];
        if (![self.databade executeUpdate:createSql]) {
            NSLog(@"建表/打开表: %@ 失败",kMemberName);
        }
        
        NSString *passwordTable = [NSString stringWithFormat:@"create table if not exists %@ (passwordID integer primary key autoincrement,password text)",kPassword];
        [self.databade executeUpdate:passwordTable];
    }
    return self;
}

/*
 *TODO:对账单的操作
 */
//账单

//billID integer
//spendID integer
//memberID integer
//moneyAmount integer
//billImageData blob
//billTime text
//billRemarks text
//isPayOut bool

-(BOOL)addNewBill:(Bill *)aBill{
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@ (spendID, memberID, moneyAmount, billImageData, billTime, billRemarks, isPayOut) values (?,?,?,?,?,?,?)",kBillTableName];
    BOOL isSucced = NO;
    isSucced = [self.databade executeUpdate:sqlStr,@(aBill.spendID),@(aBill.memberID),@(aBill.moneyAmount),aBill.billImageData,aBill.billTime,aBill.billRemarks, @(aBill.isPayout)];
    
    return isSucced;
}

-(BOOL)deleteBill:(Bill *)aBill{
    NSString *deleteSQL=[NSString stringWithFormat:@"delete from %@ where billID='%d'",kBillTableName,aBill.billID];
    if ([self.databade executeUpdate:deleteSQL]) {
        NSLog(@"删除成功");
    }
    return YES;
}

-(BOOL)modifyBill:(Bill *)aBill{
    
    NSString *sqlStr=[NSString stringWithFormat:@"update %@ set  spendID=?,memberID= ?,moneyAmount= ?,billImageData= ?,billTime= ?,billRemarks= ?, isPayOut= ? where BillID = ?",kBillTableName];
    
    BOOL succeed=[self.databade executeUpdate:sqlStr,@(aBill.spendID), @(aBill.memberID),@(aBill.moneyAmount),aBill.billImageData,aBill.billTime,aBill.billRemarks,@(aBill.isPayout),@(aBill.billID)];
    
    return succeed;
}
//********************************************
//分情况查询账单
 -(NSMutableDictionary *)billListWithDate:(NSDate *)startDate toDate:(NSDate *)endDate inType:(spendingType *)aType inMember:(member *)amember isPayout:(BOOL)isPayout{
     NSMutableDictionary *billDic=[[NSMutableDictionary alloc] init];
     NSString *SQLStr;
     if (startDate==nil && endDate==nil && aType==nil && amember ==  nil) {//返回所有的bill
         SQLStr=[NSString stringWithFormat:@"select * from %@ ",kBillTableName];
         FMResultSet *rs=[self.databade executeQuery:SQLStr];
         NSMutableArray *array = [NSMutableArray array];
         while ([rs next]) {
             Bill *aBill=[[Bill alloc]init];
             aBill.billID=[rs intForColumn:@"billID"];
             aBill.spendID=[rs intForColumn:@"spendID"];
             aBill.memberID=[rs intForColumn:@"memberID"];
             aBill.moneyAmount = [rs doubleForColumn:@"moneyAmount"];
             aBill.billImageData=[rs dataForColumn:@"billImageData"];
             aBill.billTime=[rs stringForColumn:@"billTime"];
             aBill.billRemarks=[rs stringForColumn:@"billRemarks"];
             aBill.isPayout = [rs boolForColumn:@"isPayOut"];
             [array addObject:aBill];
         }
         [billDic setObject:array forKey:@"allBills"];
     }else{
         if (startDate == nil && endDate == nil && amember == nil) {//只按类别查询
             SQLStr=[NSString stringWithFormat:@"select * from %@ where spendID = %d and isPayOut = %@",kBillTableName,aType.spendID,@(isPayout)];//按类别ID查询（类别不分大小）
             FMResultSet *rs=[self.databade executeQuery:SQLStr];
             NSMutableArray *array = [NSMutableArray array];
             while ([rs next]) {
                 Bill *aBill=[[Bill alloc]init];
                 aBill.billID=[rs intForColumn:@"billID"];
                 aBill.spendID=[rs intForColumn:@"spendID"];
                 aBill.memberID=[rs intForColumn:@"memberID"];
                 aBill.billImageData=[rs dataForColumn:@"billImageData"];
                 aBill.billTime=[rs stringForColumn:@"billTime"];
                 aBill.billRemarks=[rs stringForColumn:@"billRemarks"];
                 [array addObject:aBill];
             }
             [billDic setObject:array forKey:aType.spendName];
         }else{
             if (startDate==nil && endDate==nil && aType == nil) {//只按成员查询
                 SQLStr=[NSString stringWithFormat:@"select * from %@ where memberID = %d and isPayOut = %@",kBillTableName,amember.memberID,@(isPayout)];//按成员ID查询
                 
                 FMResultSet *rs=[self.databade executeQuery:SQLStr];
                 while ([rs next]) {
                 Bill *aBill=[[Bill alloc]init];
                 aBill.billID=[rs intForColumn:@"billID"];
                 aBill.spendID=[rs intForColumn:@"spendID"];
                 aBill.memberID=[rs intForColumn:@"memberID"];
                 aBill.billImageData=[rs dataForColumn:@"billImageData"];
                 aBill.billTime=[rs stringForColumn:@"billTime"];
                 aBill.billRemarks=[rs stringForColumn:@"billRemarks"];
                 [billDic setObject:aBill forKey:amember.memberName];
             }
         
         }else if (aType == nil && amember == nil){//按时间查询
             NSTimeInterval secondsBetweenDates= [startDate timeIntervalSinceDate:endDate];
             int howTime = secondsBetweenDates /(60*60*24);
             if (howTime > 1) {
                 SQLStr=[NSString stringWithFormat:@"select * from %@ where strftime('%%Y-%%m-%%d',billDate)=='%@' and isPayout = %@",kBillTableName,startDate,@(isPayout)];//按天查找
             }
             if (howTime > 30) {
                 SQLStr=[NSString stringWithFormat:@"select * from %@ where strftime('%%Y-%%m',billDate)=='%@' and isPayout = %@",kBillTableName,startDate,@(isPayout)];//按月查找
             }else if (howTime > 365){
                 SQLStr=[NSString stringWithFormat:@"select * from %@ where strftime('%%Y',billDate)=='%@' and isPayout = %@",kBillTableName,startDate,@(isPayout)];//按年查找
             }
         
             FMResultSet *rs=[self.databade executeQuery:SQLStr];
             NSMutableArray *array = [NSMutableArray array];
             while ([rs next]) {
                 Bill *aBill=[[Bill alloc]init];
                 aBill.billID=[rs intForColumn:@"billID"];
                 aBill.spendID=[rs intForColumn:@"spendID"];
                 aBill.memberID=[rs intForColumn:@"memberID"];
                 aBill.billImageData=[rs dataForColumn:@"billImageData"];
                 aBill.billTime=[rs stringForColumn:@"billTime"];
                 aBill.billRemarks=[rs stringForColumn:@"billRemarks"];
                 [array addObject:aBill];
             }
             
             [billDic setObject:array forKey:[startDate description]];
            }
         }
     }
     return billDic;
}

/*
 *TODO:分开写的bill查询
 */

//一个月份的所有bill显示 moth = 201405
-(NSDictionary *)billDicInMonth:(NSString *)month{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    NSString *sql=[NSString stringWithFormat:@"select * from %@ where strftime('%%Y-%%m',billTime)=='%@'",kBillTableName,month];
    FMResultSet *rs=[self.databade executeQuery:sql];
    Bill *abill;
    while ([rs next]) {
        abill=[[Bill alloc]init];
        
        abill.billID=[rs intForColumn:@"billID"];
        abill.memberID=[rs intForColumn:@"memberID"];
        abill.spendID=[rs intForColumn:@"spendID"];
        abill.billTime=[rs stringForColumn:@"billTime"];
        abill.moneyAmount=[rs intForColumn:@"moneyAmount"];
        abill.isPayout=[rs boolForColumn:@"isPayout"];
        abill.billImageData=[rs dataForColumn:@"billImageData"];
        abill.billRemarks=[rs stringForColumn:@"billRemarks"];
        
        [array addObject:abill];
    }
    if (array.count == 0) {
        [array addObject:@"没有记录"];
    }
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:array,@"billList",month,@"name", nil];
    return dic;
}

//根据时间查询账单，分为这一年的一天，一周，一个月
-(NSMutableArray *)billListInDay:(NSString *)day InWeek:(NSString *)week InMonth:(NSString *)month{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    NSString *sql;
    FMResultSet *rs;
    if (day.length!=0) {
        sql=[NSString stringWithFormat:@"select * from %@ where strftime('%%Y-%%m-%%d',billTime)=='%@'",kBillTableName,day];
    }else if (week!=0) {
        sql=[NSString stringWithFormat:@"select * from %@ where strftime('%%Y-%%W',billTime)=='%@'",kBillTableName,week];
    }else {
        sql=[NSString stringWithFormat:@"select * from %@ where strftime('%%Y-%%m',billTime)=='%@'",kBillTableName,month];
    }
    rs=[self.databade executeQuery:sql];
    Bill *abill;
    while ([rs next]) {
        abill=[[Bill alloc]init];
        
        abill.billID=[rs intForColumn:@"billID"];
        abill.memberID=[rs intForColumn:@"memberID"];
        abill.spendID=[rs intForColumn:@"spendID"];
        abill.billTime=[rs stringForColumn:@"billTime"];
        abill.moneyAmount=[rs intForColumn:@"moneyAmount"];
        abill.isPayout=[rs boolForColumn:@"isPayout"];
        abill.billImageData=[rs dataForColumn:@"billImageData"];
        abill.billRemarks=[rs stringForColumn:@"billRemarks"];
        
        [array addObject:abill];
    }
    return array;
}

//根据收入支出查询账单，并返回所有bill的金额的总和，用于首页的显示
-(double)billInDay:(NSString *)day InWeek:(NSString *)week InMonth:(NSString *)month IsPayOut:(BOOL)isPayOut{
    NSString *sql;
    if (day!=nil) {
        sql=[NSString stringWithFormat:@"select SUM(moneyAmount) from %@ where strftime('%%Y-%%m-%%d',billTime)=='%@' and isPayOut=?",kBillTableName,day];
    }else if(week!=nil){
        sql=[NSString stringWithFormat:@"select SUM(moneyAmount) from %@ where strftime('%%Y-%%W',billTime)=='%@' and isPayOut=?",kBillTableName,week];
    }else{
        sql=[NSString stringWithFormat:@"select SUM(moneyAmount) from %@ where strftime('%%Y-%%m',billTime)=='%@' and isPayOut=?",kBillTableName,month];
    }
    double num;
    FMResultSet *rs=[self.databade executeQuery:sql,@(isPayOut)];
    while ([rs next]) {
        num=[rs doubleForColumn:@"SUM(moneyAmount)"];
    }
    return num;
}

//返回这个月的所有账单信息，分收入、支出
-(NSMutableArray *)billListInMonth:(NSString *)month IsPayOut:(BOOL)isPayOut{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    NSString *sql=[NSString stringWithFormat:@"select * from %@ where strftime('%%Y-%%m',billTime)=='%@' and isPayOut=?",kBillTableName,month];
    FMResultSet *rs=[self.databade executeQuery:sql,@(isPayOut)];
    Bill *abill;
    while ([rs next]) {
        abill=[[Bill alloc]init];
        
        abill.billID=[rs intForColumn:@"billID"];
        abill.memberID=[rs intForColumn:@"memberID"];
        abill.spendID=[rs intForColumn:@"spendID"];
        abill.billTime=[rs stringForColumn:@"billTime"];
        abill.moneyAmount=[rs intForColumn:@"moneyAmount"];
        abill.isPayout=[rs boolForColumn:@"isPayout"];
        abill.billImageData=[rs dataForColumn:@"billImageData"];
        abill.billRemarks=[rs stringForColumn:@"billRemarks"];
        
        [array addObject:abill];
    }
    return array;
}

/*
 *TODO:对消费类别的操
 */
//消费类别

//spendID integer
//spendName text
//spendfatherID integer
//budgetMoneyValue integer
//isPayOut bool

-(BOOL)addNewSpendType:(spendingType *)aSpengType{//添加
    BOOL isSucced;
    NSString *SQLStr;
    SQLStr = [NSString stringWithFormat:@"insert into %@(spendName,spendfatherID,budgetMoneyValue,isPayOut) values (?,?,?,?)",kSpendTypeName];
    isSucced=[self.databade executeUpdate:SQLStr,aSpengType.spendName,@(aSpengType.fatherType.spendID),aSpengType.budgetMoneyValue,@(aSpengType.isPayout)];
    return isSucced;
}

-(BOOL)deleteSpendType:(spendingType *)aSpengType{//删除
    BOOL isSucced = NO;
    NSString *deleteSQL=[NSString stringWithFormat:@"delete from %@ where spendID='%d'",kSpendTypeName,aSpengType.spendID];
    isSucced=[self.databade executeUpdate:deleteSQL];
    return isSucced;
}

-(BOOL)modifySpendType:(spendingType *)aSpengType{//修改
    NSString *SQLStr=[NSString stringWithFormat:@"update %@ set spendName=? ,spendfatherID=?  ,budgetMoneyValue=? ,isPayOut=? where spendID = ?",kSpendTypeName];
    BOOL isSucced = [self.databade executeUpdate:SQLStr,aSpengType.spendName,@(aSpengType.fatherType.spendID),@(aSpengType.budgetMoneyValue.floatValue),@(aSpengType.isPayout),@(aSpengType.spendID)];
    return isSucced;
}

-(spendingType *)selectTypeByTypeName:(NSString *)typeName{//根据名字查找
    NSString *SQLStr=[NSString stringWithFormat:@"select * from %@ where spendName= '%@'",kSpendTypeName,typeName];
    FMResultSet *rs=[self.databade executeQuery:SQLStr];
    spendingType *aType;
    while ([rs next]) {
        aType=[[spendingType alloc]init];
        aType.spendID=[rs intForColumn:@"spendID"];
        aType.spendName=[rs stringForColumn:@"spendName"];
        int fatherTypeID=[rs intForColumn:@"spendfatherID"];
        spendingType *subType = [[spendingType alloc] init];
        subType.spendID = fatherTypeID;
        aType.fatherType = subType;
        aType.isPayout = [rs boolForColumn:@"isPayout"];
    }
    return aType;
}

//此处已修改spendfatherID改为spendID。请审核。。。。。
-(spendingType *)selectTypeByTypeID:(NSString *)typeID andIsPayout:(BOOL)isPayout{//根据fahterID查找
    NSString *SQLStr=[NSString stringWithFormat:@"select * from %@ where spendID= %@ and isPayout = %@",kSpendTypeName,typeID,@(isPayout)];
    FMResultSet *rs=[self.databade executeQuery:SQLStr];
    spendingType *aType;
    while ([rs next]) {
        aType=[[spendingType alloc]init];
        aType.spendID=[rs intForColumn:@"spendID"];
        aType.spendName=[rs stringForColumn:@"spendName"];
        int fatherTypeID=[rs intForColumn:@"spendfatherID"];
        spendingType *subType = [[spendingType alloc] init];
        subType.spendID = fatherTypeID;
        aType.fatherType = subType;
        aType.isPayout = [rs boolForColumn:@"isPayout"];
    }
    return aType;
}

//找到该大类别下得所有小类别
-(NSMutableArray *)selectTypeListByFatherTypeID:(int)fatherTypeID andIsPayout:(BOOL)isPayout{
    NSString *SQLStr=[NSString stringWithFormat:@"select * from %@ where spendfatherID= '%d' and isPayout = %@",kSpendTypeName,fatherTypeID,@(isPayout)];
    FMResultSet *rs=[self.databade executeQuery:SQLStr];
    spendingType *aType;
    NSMutableArray *typeList = [NSMutableArray array];;
    while ([rs next]) {
        
        aType=[[spendingType alloc]init];
        aType.spendID=[rs intForColumn:@"memberID"];
        aType.spendName=[rs stringForColumn:@"memberName"];
        spendingType *parentType=[[spendingType alloc]init];
        parentType.spendID = [rs intForColumn:@"spendfatherID"];
        aType.fatherType = parentType;
        aType.isPayout = [rs boolForColumn:@"isPayout"];
        [typeList addObject:aType];
        
    }
    return typeList;
}

//根据一个父类别查询所有子类别，所有类别（返回字典类型）
-(NSMutableDictionary *)readSpendTypeList:(spendingType *)aSpendType andIsPayout:(BOOL)isPayout{
    NSString *SQLStr;
    NSMutableDictionary *list=[NSMutableDictionary dictionary];
    
    if (aSpendType != nil) {
        if (aSpendType.fatherType.spendID == 0) {//是父类别
            SQLStr=[NSString stringWithFormat:@"select * from %@ where spendfatherID = '%d' and isPayout = %@ ",kSpendTypeName,aSpendType.spendID,@(aSpendType.isPayout)];//根据父类别的ID查询所有的子类别
        }else{//子类别
            SQLStr=[NSString stringWithFormat:@"select * from %@ where spendfatherID = '%d' and isPayout = %@ ",kSpendTypeName,aSpendType.fatherType.spendID,@(aSpendType.isPayout)];//根据父类别的ID查询所有的子类别
        }
        
        FMResultSet *rs=[self.databade executeQuery:SQLStr];
        
        NSMutableArray *typeList = [NSMutableArray array];
        while ([rs next]) {
            spendingType *aType=[[spendingType alloc]init];
            aType.spendID=[rs intForColumn:@"spendID"];
            aType.spendName=[rs stringForColumn:@"spendName"];
            int fatherTypeID = [rs intForColumn:@"spendfatherID"];
            spendingType *fatherType = [[spendingType alloc] init];
            fatherType.spendID = fatherTypeID;
            fatherType.isPayout = [rs boolForColumn:@"isPayOut"];
            aType.fatherType = fatherType;
            aType.isPayout = [rs boolForColumn:@"isPayOut"];
            aType.budgetMoneyValue = @([rs doubleForColumn:@"budgetMoneyValue"]);
            [typeList addObject:aType];
        }
        [list setObject:typeList forKey:aSpendType.spendName];
        
    }else{
        SQLStr=[NSString stringWithFormat:@"select * from %@ where isPayout = %@",kSpendTypeName,@(isPayout)];
        FMResultSet *rs=[self.databade executeQuery:SQLStr];
        
        NSMutableArray *typeList = [NSMutableArray array];
        NSMutableArray *subTypeList = [NSMutableArray array];
        if (isPayout == YES) {
            while ([rs next]) {
                spendingType *aType=[[spendingType alloc]init];
                aType.spendID=[rs intForColumn:@"spendID"];
                aType.spendName=[rs stringForColumn:@"spendName"];
                aType.isPayout = [rs boolForColumn:@"isPayOut"];
                aType.budgetMoneyValue = @([rs intForColumn:@"budgetMoneyValue"]);
                int fatherTypeID = [rs intForColumn:@"spendfatherID"];
                spendingType *fatherType = [[spendingType alloc] init];
                fatherType.spendID = fatherTypeID;
                aType.fatherType = fatherType;
                if (fatherTypeID == 0) {
                    [typeList addObject:aType];//主类别
                }else{
                    [subTypeList addObject:aType];
                }
            }
            [list setObject:typeList forKey:@"big"];//添加大类别数组
            for (spendingType *type in typeList) {
                
                NSMutableArray *array = [NSMutableArray array];
                
                for (spendingType *subType in subTypeList) {
                    if (subType.fatherType.spendID == type.spendID) {
                        [array addObject:subType];
                    }
                }
                
                [list setObject:array forKey:type.spendName];//分类别将数据存入字典，取得时候根据主类别取出
            }//for end
        }else{
            while ([rs next]) {
                spendingType *aType=[[spendingType alloc]init];
                aType.spendID=[rs intForColumn:@"spendID"];
                aType.spendName=[rs stringForColumn:@"spendName"];
                aType.isPayout = [rs boolForColumn:@"isPayOut"];
                aType.budgetMoneyValue = @([rs intForColumn:@"budgetMoneyValue"]);
                int fatherTypeID = [rs intForColumn:@"spendfatherID"];
                spendingType *fatherType = [[spendingType alloc] init];
                fatherType.spendID = fatherTypeID;
                aType.fatherType = fatherType;
                [typeList addObject:aType];
            }
            [list setObject:typeList forKey:@"big"];//添加大类别数组
        }
        
    }//else end
    
    return list;
}



/*
 *TODO:对成员表的操作
 */
//成员表
-(BOOL)addNewMember:(member *)aMember{
    NSString *SQLStr=[NSString stringWithFormat:@"insert into %@(memberName) values (?)",kMemberName];
    if ([self.databade executeUpdate:SQLStr,aMember.memberName]) {
        NSLog(@"插入成功");
    }
    return YES;
}

-(BOOL)deleteMenber:(member *)aMember{
    NSString *deleteSQL=[NSString stringWithFormat:@"delete from %@ where memberID='%d'",kMemberName,aMember.memberID];
    if ([self.databade executeUpdate:deleteSQL]) {
        NSLog(@"删除成功");
    }
    return YES;
}

-(BOOL)modifyMember:(member *)aMember{
    BOOL isSuceed = NO;
    NSString *SQLStr = [NSString stringWithFormat:@"update %@ set memberName=? where memberID = ?",kSpendTypeName];
    isSuceed = [self.databade executeUpdate:SQLStr,aMember.memberName,@(aMember.memberID)];
    return isSuceed;
}

-(member *)selectMember:(NSString *)memberName{
    NSString *deleteSQL=[NSString stringWithFormat:@"select * from %@ where memberName='%@'",kMemberName,memberName];
    FMResultSet *rs=[self.databade executeQuery:deleteSQL];
    member *aMember;
    while ([rs next]) {
        aMember=[[member alloc]init];
        aMember.memberID=[rs intForColumn:@"memberID"];
        aMember.memberName=[rs stringForColumn:@"memberName"];
    }
    return aMember;
    
}

-(member *)selectMemberID:(int)memberID{
    NSString *deleteSQL=[NSString stringWithFormat:@"select * from %@ where memberID=%d",kMemberName,memberID];
    FMResultSet *rs=[self.databade executeQuery:deleteSQL];
    member *aMember;
    while ([rs next]) {
        aMember=[[member alloc]init];
        aMember.memberID=[rs intForColumn:@"memberID"];
        aMember.memberName=[rs stringForColumn:@"memberName"];
    }
    return aMember;
    
}

-(NSMutableArray *)readAllMemberList{
    NSString *SQLStr=[NSString stringWithFormat:@"select * from %@",kMemberName];
    FMResultSet *rs=[self.databade executeQuery:SQLStr];
    NSMutableArray *list=[NSMutableArray array];
    while ([rs next]) {
        member *aMember=[[member alloc]init];
        aMember.memberID=[rs intForColumn:@"memberID"];
        aMember.memberName=[rs stringForColumn:@"memberName"];
        [list addObject:aMember];
    }
    return list;
}

/*
 *TODO:计算函数
 */
//计算函数
-(float)calculateDifferenceWithType:(spendingType *)mainType{
    NSMutableDictionary *dic = [self billListWithDate:nil toDate:nil inType:nil inMember:nil isPayout:YES];
    NSArray *arr = [dic objectForKey:mainType.spendName];
    float sumMoney = 0.0;
    for (Bill *aBill in arr) {
        sumMoney+=aBill.moneyAmount;
    }
    float difference = 0;
    difference = mainType.budgetMoneyValue.floatValue - sumMoney;
    return difference;
}

//TODO:密码操作
//添加密码
-(BOOL)addPassword:(Password *)aPassword{
    NSString *addPassword = [NSString stringWithFormat:@"insert into %@ (password) values(?)",kPassword];
    [self.databade executeUpdate:addPassword,aPassword.password];
    return YES;
}

//删除密码
-(BOOL)deletePassword{
    NSString *deletePassword = [NSString stringWithFormat:@"delete from %@",kPassword];
    [self.databade executeUpdate:deletePassword];
    return YES;
}

//修改密码
-(BOOL)updatePassword:(Password *)aPassword{
    NSString *updatePassword = [NSString stringWithFormat:@"update %@ set password = ? where passwordID = ?",kPassword];
    [self.databade executeUpdate:updatePassword,aPassword.password,aPassword.PasswordID];
    return YES;
}

//根据number找到一排
-(Password *)searchPassword:(int)number{
    NSString *searchPassword = [NSString stringWithFormat:@"select * from %@ limit 1 offset ?",kPassword];
    FMResultSet *rs = [self.databade executeQuery:searchPassword,@(number)];
    Password *aPassword;
    while ([rs next]) {
        aPassword = [[Password alloc]init];
        aPassword.PasswordID = @([rs intForColumn:@"passwordID"]);
        aPassword.password = [rs stringForColumn:@"password"];
    }
    return aPassword;
}
@end
