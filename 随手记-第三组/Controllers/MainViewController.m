//
//  MainViewController.m
//  随手记-第三组
//
//  Created by student on 14-5-6.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "MainViewController.h"
#import "Bill.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tfIncome;//金额
@property (weak, nonatomic) IBOutlet UITextField *remarksText;//备注
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;//时间
@property (weak, nonatomic) IBOutlet UILabel *classLabel;//类别

@property (weak, nonatomic) IBOutlet UITableView *TableView;
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UIPickerView *PickerView;
- (IBAction)editButton:(id)sender;
- (IBAction)chooseButton:(id)sender;
- (IBAction)chooseImageBut:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign ,nonatomic) NSInteger rowInProvince;
@property (nonatomic,strong)UIImagePickerController *imagePicker;//创建图片选择器
@property (nonatomic,strong)Bill *aBill;
@property (nonatomic,strong)NSMutableDictionary *typeDic;//从数据库中读出type字典
@property (nonatomic,strong) NSMutableArray *fatherType;

@end

@implementation MainViewController


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
    self.aBill=[[Bill alloc]init];
	// Do any additional setup after loading the view.
    //对第三方控件
    [IQKeyboardManager sharedManager].enableAutoToolbar=NO;
    
    //PickerView操作
    self.subView.hidden=YES;
    self.PickerView.delegate=self;
    self.PickerView.dataSource=self;
    //plist数据读入数据库中
    /*
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ProvincesAndCities" ofType:@"plist"];
    
    self.fatherType=[NSMutableArray arrayWithContentsOfFile:path];
    
    spendingType *aSpendingType = [[spendingType alloc] init];
    for (int i=0; i<self.fatherType.count; i++) {
        NSString *SpendFahterTypeNameStr = [self.fatherType[i] objectForKey:@"fatherType"];
        aSpendingType.spendID=i+1;
        aSpendingType.spendName=SpendFahterTypeNameStr;
        spendingType *parentsType=[[spendingType alloc]init];
        aSpendingType.fatherType=parentsType;
        aSpendingType.isPayout = YES;
        [[DatabaseManager ShareDBManager]addNewSpendType:aSpendingType];
        
        NSMutableArray *childType=[[NSMutableArray alloc]init];
        childType=[self.fatherType[i]objectForKey:@"childType"];
        for (int j=0; j<childType.count; j++) {
            aSpendingType = [[spendingType alloc] init];
            NSString *SpendChildTypeNameStr =[childType[j]objectForKey:@"type"];
            NSNumber *SpendChildTypeIDStr =[childType[j]objectForKey:@"id"];
            aSpendingType.spendID=SpendChildTypeIDStr.intValue;
            aSpendingType.spendName=SpendChildTypeNameStr;
            spendingType *parentsType=[[spendingType alloc]init];
            parentsType.spendID=i+1;
            aSpendingType.fatherType=parentsType;
            aSpendingType.isPayout = YES;
            [[DatabaseManager ShareDBManager] addNewSpendType:aSpendingType];
        }
    }
     */
    
    //tableView操作
    self.TableView.delegate=self;
    self.TableView.dataSource=self;
    
    //dateLabel为当前时间
    NSDate *now=[[NSDate alloc]init];
    NSString *todayDate=[[now description] substringWithRange:NSMakeRange(0, 10)];
    self.dateLabel.text=todayDate;
    
    //photo
    self.imagePicker=[[UIImagePickerController alloc]init];
    
    //自定义键盘
    _keyboardView= [[ZenKeyboard alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    self.keyboardView.textField = self.tfIncome;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self. extendedLayoutIncludesOpaqueBars=NO;
    
    //定义view的外形
    self.imageView.layer.cornerRadius=15;//定义控件的圆角
    self.imageView.layer.borderColor=[UIColor blackColor].CGColor;//定义边框颜色
    self.imageView.layer.borderWidth=0.5;//定义边框大小
    self.imageView.layer.masksToBounds=YES;//定义边界 不越界
    
}

- (void)viewWillAppear:(BOOL)animated {//此方法为 当push时调用
    
    self.typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:YES];
    self.fatherType = [self.typeDic objectForKey:@"big"];
    
    [self.PickerView reloadAllComponents];
}

//点击remarksText键盘消失
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.remarksText resignFirstResponder];
    [_tfIncome resignFirstResponder];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - PickerView 类别默认为支出
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component==0) {
        return self.fatherType.count;
        
    }else{
        spendingType *aType = self.fatherType[self.rowInProvince];
        NSArray *subTypeList = [self.typeDic objectForKey:aType.spendName];
        return subTypeList.count;
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component==0) {
        NSString *fatherTypeStr;
        
        //        fatherTypeStr=[[self.fatherType objectAtIndex:row]objectForKey:@"fatherType"];
        spendingType *aType = [[self.typeDic objectForKey:@"big"] objectAtIndex:row];
        fatherTypeStr = aType.spendName;
        _fatherTypeStr=fatherTypeStr;
        
        return fatherTypeStr;
        
    }else{
        NSString *typeStr;
        //        typeStr==[[[[self.fatherType objectAtIndex:self.rowInProvince] objectForKey:@"childType"] objectAtIndex:row] objectForKey:@"type"];
        NSArray *typeList = [self.typeDic objectForKey:@"big"];
        spendingType *aType = typeList[self.rowInProvince];
        NSArray *subTypeList = [self.typeDic objectForKey:aType.spendName];
        aType = subTypeList[row];
        typeStr =aType.spendName;
        _typeStr=typeStr;
        return typeStr;
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component==0) {
        self.rowInProvince=row;
        [self.PickerView reloadComponent:1];
    }
}

#pragma mark - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }
    if (section==1) {
        return 1;
    }else{
        return 1;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier1 = @"cell1";
    static NSString *CellIdentifier2 = @"cell2";
    static NSString *CellIdentifier3 = @"cell3";
    UITableViewCell *cell;
    if (indexPath.section==0) {//今天的所有支出
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        UILabel *todayTotalLabel=(UILabel *)[cell viewWithTag:1];
        
        NSDate *now=[NSDate date];
        NSString *date;
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        date = [formatter stringFromDate:now];
        
        double totalMoney =[[DatabaseManager ShareDBManager] billInDay:date InWeek:nil InMonth:nil IsPayOut:YES];
        NSLog(@"%.2f",totalMoney);
        todayTotalLabel.text = [NSString stringWithFormat:@"%.2f",totalMoney];
        
    }
    if (indexPath.section==1) {//这周的所有支出，因为将每周的第一天当成星期天，所以在星期天是会置为0.0的
         cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        NSDate *nowDate = [[NSDate alloc] init];
        NSString *weekStr = [self stringWeekForDate:nowDate];
        
        UILabel *weekTotalLabel=(UILabel *)[cell viewWithTag:2];
        float weekMoney = [[DatabaseManager ShareDBManager] billInDay:nil InWeek:weekStr InMonth:nil IsPayOut:YES];
        
        weekTotalLabel.text=[NSString stringWithFormat:@"%.2f",weekMoney];
        
    }
    if (indexPath.section==2) {//这月的所有支出
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPath];
        UILabel *monthTotalLabel=(UILabel *)[cell viewWithTag:3];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *nowDate;
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
        NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;//分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit 可查年、月、周开始结束 “某个时间点”所在的“单元”的起始时间，以及起始时间距离“某个时间点”的时差（单位秒）
        nowDate=[NSDate date];
        comps = [calendar components:unitFlags fromDate:nowDate];
//        NSInteger month = [comps month];
//        NSInteger week = [comps week];
//        NSInteger day = [comps day];
//        NSInteger hour = [comps hour];
//        NSInteger min = [comps minute];
//        NSInteger sec = [comps second];
        NSString *monthStr = [self stringMonthForDate:nowDate];
        monthTotalLabel.text = [NSString stringWithFormat:@"%.2f",[[DatabaseManager ShareDBManager] billInDay:nil InWeek:nil InMonth:monthStr IsPayOut:YES]] ;
    }
    
    return cell;
}

- (IBAction)SaveButton:(UIButton *)sender {
    
    if (self.tfIncome.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"不能保存" message:@"金额为空,请输入金额" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    Bill *aBill = [[Bill alloc] init];
    spendingType *aSpendType=[[spendingType alloc]init];
    
    aBill.moneyAmount=self.tfIncome.text.floatValue;
    aBill.billRemarks=self.remarksText.text;
    aBill.billImageData = UIImageJPEGRepresentation(self.imageView.image, 0.5);
    
    aSpendType = [[DatabaseManager ShareDBManager] selectTypeByTypeName:_typeStr];//查询小类别
    aBill.spendID = aSpendType.spendID;
    aBill.memberID = 0;
    //string转换为date
    NSString *timeStr=self.dateLabel.text;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    //    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    aBill.billTime=timeStr;
    aBill.isPayout=YES;
    
    [[DatabaseManager ShareDBManager] addNewBill:aBill];
    [self.TableView reloadData];
    
}
//TODO:再记一笔按钮，先保存在清空
- (IBAction)comeBackButton:(UIButton *)sender {
    if (self.tfIncome.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"不能保存" message:@"金额为空,请输入金额" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    Bill *aBill = [[Bill alloc] init];
    spendingType *aSpendType=[[spendingType alloc]init];
    
    aBill.moneyAmount=self.tfIncome.text.floatValue;
    aBill.billRemarks=self.remarksText.text;
    aBill.billImageData = UIImageJPEGRepresentation(self.imageView.image, 0.5);
    
    aSpendType = [[DatabaseManager ShareDBManager] selectTypeByTypeName:_typeStr];//查询小类别
    aBill.spendID = aSpendType.spendID;
    aBill.memberID = 0;
    //string转换为date
    NSString *timeStr=self.dateLabel.text;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    //    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    aBill.billTime=timeStr;
    aBill.isPayout=YES;
    
    [[DatabaseManager ShareDBManager] addNewBill:aBill];
    [self.TableView reloadData];
    
    //显示数据清空
    self.tfIncome.text = nil;
    self.remarksText.text=nil;
    self.imageView.image=[UIImage imageNamed:@"camera"];
    NSDate *now=[[NSDate alloc]init];
    NSString *todayDate=[[now description] substringWithRange:NSMakeRange(0, 10)];
    self.dateLabel.text=todayDate;
}

- (IBAction)TimeChooseButton:(UIButton *)sender {
}

//@TODO:类别选择
- (IBAction)ClassChooseButton:(UIButton *)sender {
    self.subView.hidden=NO;

}

- (IBAction)editButton:(id)sender {
    //点击按钮调用方法进行传值
    [self performSegueWithIdentifier:@"Picker2Edit" sender:self.typeDic];
}

- (IBAction)chooseButton:(id)sender {
    self.subView.hidden=YES;
    if (_typeStr == nil) {
        _typeStr = @"";
    }
    int mainT=[self.PickerView selectedRowInComponent:0];
    int subT=[self.PickerView selectedRowInComponent:1];
    spendingType *fatherType = self.fatherType[mainT];
    NSArray *subList = [self.typeDic objectForKey:fatherType.spendName];
    spendingType *subType = subList[subT];
    
    NSString *Str=[NSString stringWithFormat:@"%@>%@",fatherType.spendName,subType.spendName];
    self.classLabel.text=Str;
    
}

#pragma mark - 照相、相册功能实现
- (IBAction)chooseImageBut:(UIButton *)sender {

    UIActionSheet *sheet;
    
    // 判断是否支持相机
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //info是个字典
    self.imageView.image = info[@"UIImagePickerControllerEditedImage"];
    [self dismissViewControllerAnimated:YES completion:nil];//dismiss解除返回上一层
}

#pragma mark - 实现actionSheet delegate事件
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

#pragma mark - 日期操作函数

//date装换为str
- (NSString *)stringMonthForDate:(NSDate *)date{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *dateStr=[dateFormatter stringFromDate:date];
    return dateStr;
}

- (NSString *)stringDayForDate:(NSDate *)date{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr=[dateFormatter stringFromDate:date];
    return dateStr;
}

//给定一个日期，得到它处于一年的那一周
- (NSString *)stringWeekForDate:(NSDate *)date{
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekOfYearCalendarUnit fromDate:date];
    int weekday = [componets weekOfYear];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *dateStr=[dateFormatter stringFromDate:date];
    NSString *str=[NSString stringWithFormat:@"%@-%@",dateStr,@(weekday-1)];
    return str;
}

- (NSString *)getBeginAndEndWithMonth:(NSString *)month andWeek:(NSString *)week{
    
    NSDate *newDate = [NSDate date];
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL ok;
    if (month!=nil)
    {
        ok = [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    }else{
        ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    }
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit 可查年、月、周开始结束 “某个时间点”所在的“单元”的起始时间，以及起始时间距离“某个时间点”的时差（单位秒）
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return nil;
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"MM月dd日"];
    NSString *beginString = [myDateFormatter stringFromDate:beginDate];
    NSString *endString = [myDateFormatter stringFromDate:endDate];
    
    return [NSString stringWithFormat:@"%@-%@",beginString,endString];
}


#pragma mark - 传值
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSObject *nextVC=[segue destinationViewController];
    if ([segue.identifier isEqualToString:@"Picker2Edit"]) {
        [nextVC setValue:sender forKey:@"typeDic"];
    }
}


@end
