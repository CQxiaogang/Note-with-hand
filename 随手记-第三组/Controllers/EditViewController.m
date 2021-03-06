//
//  EditViewController.m
//  随手记-第三组
//
//  Created by student on 14-5-9.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "EditViewController.h"
#import "spendingType.h"
#import "DatabaseManager.h"

@interface EditViewController ()
{
    BOOL _isPayout;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UITableView *TableView;
@property (strong,nonatomic) NSMutableArray *textFiledList;
@property (nonatomic,strong)NSMutableArray *fatherType;
@property(nonatomic,strong)NSIndexPath *currentIndexPath;
@property(nonatomic,strong)NSIndexPath *_indexPath;
@end

@implementation EditViewController

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
    self.TableView.delegate=self;
    self.TableView.dataSource=self;
    self.textFiledList =[NSMutableArray array];
    
    //根据父类别ID查询父类别
    self.fatherType=[self.typeDic objectForKey:@"big"];
    
    _isPayout = YES;

}
//TODO:- tableView的实现
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fatherType.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITextField *fatherTypeLabel=(UITextField *)[cell viewWithTag:2];
    
    spendingType *aType=self.fatherType[indexPath.row];
    fatherTypeLabel.text=aType.spendName;
    
    //改变tag的值
    fatherTypeLabel.tag = indexPath.row+1;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self._indexPath=indexPath;
        spendingType *aType=self.fatherType[indexPath.row];
        NSString *str=[NSString stringWithFormat:@"确定删除%@",aType.spendName];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"确定删除" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alert.tag=1001;
        alert.delegate = self;
        [alert show];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

- (IBAction)editButton:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"编辑"]) {
        
        UIActionSheet *sheet;
        sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加",@"修改" ,nil];
       
        [sheet showInView:self.view];
        
    }else if ([sender.title isEqualToString:@"保存"]){
        self.editButton.title = @"编辑";
        
        //根据textFiled的tag为aType.spendName改变值
        for (int i = 0; i<self.fatherType.count; i++) {
            spendingType *aType = self.fatherType[i];
            UITextField *textFiled = (UITextField *)[self.TableView viewWithTag:i+1];//获取每个cell的textFiled根据tag来获取，i+1就是动态改变每个textFiled的tag值，这样就可以修改、添加。
            aType.spendName = textFiled.text;
            
            [[DatabaseManager ShareDBManager] modifySpendType:aType];
            textFiled.enabled = NO;
        }
    }
}

#pragma mark - ActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {//添加
        
        //弹出含有输入textfiled的提示框
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加类别" message:@"" delegate:self cancelButtonTitle:@"添加" otherButtonTitles:@"取消", nil];
        //设置textfiled的风格,
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        //提示框输入框所用键盘风格
        [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
        
        [[alert textFieldAtIndex:0] becomeFirstResponder];
        alert.tag=1000;
        alert.delegate = self;
        [alert show];
        
    }
    if (buttonIndex==1) {//修改
        
        self.editButton.title = @"保存";
        for (int i=0; i<self.fatherType.count; i++) {
            UITextField *textFiled = (UITextField *)[self.TableView viewWithTag:i+1];
            textFiled.enabled = YES;
        }
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1000) {
        //得到提示框
        if (buttonIndex==0) {
            NSString *textStr=[alertView textFieldAtIndex:0].text;
            
            spendingType *aType = [[spendingType alloc] init];
            aType.spendName = textStr;
            spendingType *fatherType = [[spendingType alloc] init];
            fatherType.spendID = 0;
            aType.fatherType = fatherType;
            aType.isPayout = _isPayout;
            [self.fatherType addObject:aType];
            [[DatabaseManager ShareDBManager] addNewSpendType:aType];
            
            [self.TableView reloadData];
            [alertView textFieldAtIndex:0].text = nil;
            
        }
        
    }//tag判断end
    else if (alertView.tag==1001)
    {
        if (buttonIndex==0) {
            
            spendingType *aType=self.fatherType[self._indexPath.row];
            NSMutableArray *array = [[DatabaseManager ShareDBManager]selectTypeListByFatherTypeID:aType.spendID andIsPayout:YES];
            NSLog(@"该大类别下的子类别个数为:%i",array.count);
            if (array.count!=0) {
                
                UIAlertView *errorAlert=[[UIAlertView alloc]initWithTitle:@"无法删除" message:@"请先清空二级类别" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                errorAlert.tag = 1002;
                [errorAlert show];
                
            }else{//弹出提示框
                
                [[DatabaseManager ShareDBManager] deleteSpendType:aType];//从数据库中删除这个类别
                [self.fatherType removeObjectAtIndex:self._indexPath.row];
                [self.TableView deleteRowsAtIndexPaths:@[self._indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            [self.TableView reloadData];
            
        }
    }//tag判断end
}

#pragma mark - 传值
//传值只能穿对象，不能传简单数据类型如：int....
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = [self.TableView indexPathForCell:sender];//根据tableView的cell(sender)来找到你所点击的行。
    spendingType *aType = self.fatherType[indexPath.row];
    NSArray *array = [self.typeDic objectForKey:aType.spendName];
    
    NSObject *nextVC=[segue destinationViewController];//destinationViewController找你到你要传值的controller
    NSNumber *fatherID = @(aType.spendID);
    if ([segue.identifier isEqualToString:@"Fa2Child"]) {
        [nextVC setValue:array forKey:@"childArray"];
        [nextVC setValue:fatherID forKey:@"fatherID"];
    }
}


@end
