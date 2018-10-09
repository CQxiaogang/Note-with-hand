//
//  NoDataView.m
//  随手记-第三组
//
//  Created by apple on 2018/9/27.
//  Copyright © 2018年 小刚. All rights reserved.
//

#import "NoDataView.h"

@implementation NoDataView

-(UIView *)noDataView:(UIView *)currentView{
    UIView *view = [[UIView alloc] initWithFrame:currentView.bounds];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    imageView.center = view.center;
    imageView.image = [UIImage imageNamed:@"noDataImage"];
    [view addSubview:imageView];
    
    
    CGFloat labelX = imageView.frame.origin.x;
    CGFloat labelY = imageView.frame.origin.y + imageView.frame.size.height;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, imageView.frame.size.width, 50)];
    
    label.text = @"暂无数据";
    
    label.textAlignment = NSTextAlignmentCenter;
    
    [view addSubview:label];
    
    return view;
}

@end
