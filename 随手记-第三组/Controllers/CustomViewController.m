//
//  CustomViewController.m
//  随手记-第三组
//
//  Created by student on 14-6-9.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "CustomViewController.h"
#import "Password.h"
#import "DatabaseManager.h"
#import "ChessView.h"
#import "recreationViewController.h"

@interface CustomViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) Password *aPassword;
@property(nonatomic, strong) NSString *judgmentString;//判断
@property(nonatomic, strong) NSArray *cellArray;

@end

@implementation CustomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(NSArray *)cellArray{
    if (!_cellArray) {
        _cellArray = [[NSArray alloc] init];
    }
    return _cellArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _cellArray = @[@"关于我们",@"娱乐"];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = _cellArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"toAbout" sender:self];
    }else{
        [self performSegueWithIdentifier:@"toRecreation" sender:self];
    }
}
@end
