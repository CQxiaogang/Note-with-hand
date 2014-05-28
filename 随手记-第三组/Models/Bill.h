//
//  Bill.h
//  随手记-第三组
//
//  Created by student on 14-5-5.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bill : NSObject

@property(nonatomic,assign) int billID;//账单ID
@property(nonatomic,assign) int spendID;//类别ID
@property(nonatomic,assign) int memberID;//成员ID
@property(nonatomic,strong) NSData *billImageData;//图片
@property(nonatomic,assign) float moneyAmount;//金额
@property(nonatomic,copy) NSDate *billTime;//时间
@property(nonatomic,copy) NSString *billRemarks;//备注
@property(nonatomic,assign) BOOL isPayout;//默认是支出

@end
