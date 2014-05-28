//
//  EditChildViewController.m
//  随手记-第三组
//
//  Created by student on 14-5-9.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "EditChildViewController.h"
#import "DatabaseManager.h"

@interface EditChildViewController ()
@property (weak, nonatomic) IBOutlet UITableView *TableView;
- (IBAction)editButton:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property(nonatomic,strong)NSIndexPath *currentIndexPath;
@property(nonatomic,strong)NSIndexPath *_indexPath;

@end

@implementation EditChildViewController

//-(NSMutableArray *)childArray{
//    if (!_childArray) {
//        _childArray=[[NSMutableArray alloc]init];
//    }
//    return _childArray;
//}


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
    self.TableView.delegate=self;
    self.TableView.dataSource=self;
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"ProvincesAndCities" ofType:@"plist"];
//    self.fatherType=[NSMutableArray arrayWithContentsOfFile:path];
//    int count=self.fatherType.count;
//    for (int i=0; i<count; i++) {
//        self.array=[self.childArray[i]objectForKey:@"childType"];
//    }
//    spendingType *aType = self.childArray[0];
//    
//    spendingType *type = [[spendingType alloc] init];
//    type.fatherType = aType.fatherType;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//寻找tableview中得cell的值
-(NSIndexPath *)indexPathForView:(UIView *)view{
    UIView *parentView=[view superview];
    while (![parentView isKindOfClass:[UITableViewCell class]] && parentView!=nil) {
        parentView=parentView.superview;
    }
    return [self.TableView indexPathForCell:(UITableViewCell *)parentView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.childArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITextField *TypeLabel=(UITextField *)[cell viewWithTag:2];
    
    TypeLabel.enabled=NO;//不可编辑
    
    spendingType *aType=self.childArray[indexPath.row];
    TypeLabel.text=aType.spendName;
    
    //改变tag的值
    TypeLabel.tag = indexPath.row+1;//indexPath.row+1==0+1

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    //    spendingType *aType=self.fatherType[indexPath.row];
    //    NSString *str=[NSString stringWithFormat:@"确定删除%@",aType.spendName];
    //    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"确定删除" message:str delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //    alert.tag=1000;
    //    [alert show];
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        self._indexPath=indexPath;
        spendingType *aType=self.childArray[indexPath.row];
        NSString *str=[NSString stringWithFormat:@"确定删除%@",aType.spendName];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"确定删除" message:str delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag=1000;
        [alert show];
        //        spendingType *aType=self.fatherType[indexPath.row];
        //得到数组,用于判断大类别中是否有小类别。如果有小类别就不能删除
        NSArray *array = [[DatabaseManager ShareDBManager]selectTypeListByFatherTypeID:aType.spendID andIsPayout:YES];
        if (array.count==0) {
            
            [[DatabaseManager ShareDBManager] deleteSpendType:aType];//从数据库中删除这个类别
            
        }else{//弹出提示框
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"无法删除" message:@"请先清空二级类别" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
        for (int i = 0; i<self.childArray.count; i++) {
            spendingType *aType = self.childArray[i];
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
        [alert show];

    }
    if (buttonIndex==1) {//修改
        self.editButton.title=@"保存";//改变editButton的title
        for (int i=0; i<self.childArray.count; i++) {
            UITextField *textFiled = (UITextField *)[self.TableView viewWithTag:i+1];
            textFiled.enabled = YES;
        }
    }
}
#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        NSString *textStr=[alertView textFieldAtIndex:0].text;
        spendingType *aFatherType = [[spendingType alloc]init];//父类别
        spendingType *type = [[spendingType alloc] init];
        if (self.childArray.count==0) {
            //构造一个fatherType
            aFatherType.spendID = self.fatherID.intValue;
            aFatherType.isPayout = YES;
            
            type.fatherType = aFatherType;
            
        }else{
            aFatherType = self.childArray.firstObject;//为了得到fatherType
            type.fatherType = aFatherType.fatherType;
        }
        
        type.spendName = textStr;
        type.isPayout=YES;
        
        [self.childArray addObject:type];
        [[DatabaseManager ShareDBManager] addNewSpendType:type];
    
        [self.TableView reloadData];
    }
}
@end
