//
//  CustomShowViewController.m
//  随手记-第三组
//
//  Created by student on 14-6-17.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "CustomShowViewController.h"

@interface CustomShowViewController ()


@end

@implementation CustomShowViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
     
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(126, 200, 68, 21)];
        nameLabel.text = @"关于我们";
        UILabel *nameLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(90, 240, 89, 21)];
        nameLabel1.text = @"指导老师:";
        UILabel *nameLabel11 = [[UILabel alloc]initWithFrame:CGRectMake(172, 240, 89, 21)];
        nameLabel11.text = @"廖";
        
        UILabel *nameLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(90, 280, 89, 21)];
        nameLabel2.text = @"组长:";
        UILabel *nameLabel21 = [[UILabel alloc]initWithFrame:CGRectMake(172, 280, 89, 21)];
        nameLabel21.text = @"蒋龙";
        
        UILabel *nameLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(90, 320, 89, 21)];
        nameLabel3.text = @"小组成员:";
        UILabel *nameLabel31 = [[UILabel alloc]initWithFrame:CGRectMake(172, 320, 200, 21)];
        nameLabel31.text = @"向江英,杨玲,王孝刚";
        
        
        [self.view addSubview:nameLabel];
        [self.view addSubview:nameLabel1];
        [self.view addSubview:nameLabel11];
        [self.view addSubview:nameLabel2];
        [self.view addSubview:nameLabel21];
        [self.view addSubview:nameLabel3];
        [self.view addSubview:nameLabel31];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
