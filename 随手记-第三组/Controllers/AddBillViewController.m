//
//  AddBillViewController.m
//  随手记-第三组
//
//  Created by student on 14-5-15.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "AddBillViewController.h"
#import "DatabaseManager.h"

#define kDicOfTypeKey @"big"

#define kMainShowIdentifier @"main2add"
#define kCharShowIdentifier @"char2Edit"
#define kDayShowIdentifier @"dayShow2Edit"
#define kWeekShowIdentifier @"weekShow2Edit"
#define kMonthShowIdentifier @"monthShow2Edit"
#define kBillShowIdentifier @"billShow2Modify"


@interface AddBillViewController ()

//弹出的视图（pickerView和buttons）
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;//pickerView的输出口
- (IBAction)chooseButton:(UIBarButtonItem *)sender;//选择确认按钮

- (IBAction)calssText:(UITextField *)sender;
- (IBAction)memberText:(UITextField *)sender;
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UITextField *classText;
@property (weak, nonatomic) IBOutlet UITextField *memberText;
- (IBAction)classButton:(UIButton *)sender;//类别选择按钮，点击弹出pickerView
- (IBAction)memberButton:(id)sender;//成员选择按钮，点击弹出pickerView

//下层视图的控件
@property (weak, nonatomic) IBOutlet UITextField *tfIncomeText;
@property (weak, nonatomic) IBOutlet UITextView *remarksTextView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *isPayoutSegment;//支出b和收入选择
- (IBAction)isPayoutSegmentButton:(UISegmentedControl *)sender;

- (IBAction)saveBillToDatabase:(UIButton *)sender;
- (IBAction)editBillButton:(id)sender;//修改bill
@property (weak, nonatomic) IBOutlet UIButton *editBill;
@property (weak, nonatomic) IBOutlet UIButton *comeBackBill;
@property (weak, nonatomic) IBOutlet UIButton *saveBill;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (assign ,nonatomic) NSInteger rowInProvince;//全局,picker中得到位置

@property(nonatomic,strong)ZenKeyboard *keyboardView;//键盘

@property(nonatomic,strong)UIDatePicker *TimePicker;//自定义datePicker

- (IBAction)edit:(id)sender;//编辑按钮



@property (nonatomic,strong) NSMutableArray *fatherTypeList;

@property (nonatomic,strong)NSMutableDictionary *typeDic;//从数据库中读出type字典
@property (nonatomic,strong) NSMutableArray *typeList;//存放type

@property (nonatomic,strong) NSMutableArray *memberList;//存放成员

@property (nonatomic,strong) NSMutableDictionary *incomeDic;//收入
@property (nonatomic,strong) NSMutableArray *incomeList;//收入
@end

@implementation AddBillViewController

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
//    textview对象.layer.borderColor = UIColor.grayColor.CGColor;
//    textview对象.layer.borderWidth = 5;
    self.remarksTextView.layer.borderColor = [UIColor blackColor].CGColor;
    self.remarksTextView.layer.borderWidth = 5;
    self.remarksTextView.delegate = self;
    
    _isTypePicker = YES;
    
    //PickerView操作
    self.subView.hidden=YES;
    self.pickerView.delegate=self;
    self.pickerView.dataSource=self;
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"ProvincesAndCities" ofType:@"plist"];
//    self.typeList=[NSMutableArray arrayWithContentsOfFile:path];
    
//    self.memberList = [[NSMutableArray alloc] initWithObjects:@"自己",@"老婆",@"幺儿",@"侄儿",@"爸妈",@"朋友",nil];
//    for (int i=0;i<self.memberList.count;i++) {
//        NSString *nameStr = self.memberList[i];
//        member *aMemer = [[member alloc] init];
//        aMemer.memberName = nameStr;
////        aMemer.memberID=i;
//        [[DatabaseManager ShareDBManager] addNewMember:aMemer];
//    }
    //收入数组
//    self.incomeList=[[NSMutableArray alloc]initWithObjects:@"工资",@"证劵",@"银行利息",@"意外收获",@"外债",nil];
//    for (int i=0; i<self.incomeList.count; i++) {
//        NSString *budgetClassStr=self.incomeList[i];
//        spendingType *aSpendingType=[[spendingType alloc]init];
//        aSpendingType.spendName=budgetClassStr;
//        aSpendingType.spendID=i+24;
//        aSpendingType.isPayout=NO;
//        [[DatabaseManager ShareDBManager]addNewSpendType:aSpendingType];
//    }
    
    //自定义键盘
    _keyboardView= [[ZenKeyboard alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
//    [self.tfIncomeText setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];
    
    self.keyboardView.textField = self.tfIncomeText;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self. extendedLayoutIncludesOpaqueBars=NO;
//    [self.tfIncomeText becomeFirstResponder];//某个输入框变为第一响应者，准备接受输入
    // Do any additional setup after loading the view.
    
//    RBCustomDatePickerView *datePickerView = [[RBCustomDatePickerView alloc] initWithFrame:CGRectMake(0, -30, 320, 200)];
//    
//    [self.dateSubView addSubview:datePickerView];
//    self.dateSubView.hidden=YES;
//    NSString *dateStr=[datePickerView selectDate];
//    _dateLabel.text = dateStr;
    
    //datePicker自定义
    self.TimePicker=[[UIDatePicker alloc]init];
    self.dateText.inputView=self.TimePicker;//修改inputView，没有修改inputView时系统会弹出自定义键盘
    [self dateChoose];//第一次进入显示时间
    [self.TimePicker addTarget:self action:@selector(dateChoose) forControlEvents:UIControlEventValueChanged];//发送一条消息 pickerDate的值发生改变，textFild的也紧随发生改变
    
    self.memberList = [[DatabaseManager ShareDBManager] readAllMemberList];
    
    //支出数据
    self.typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:YES];
    self.typeList = self.typeDic[kDicOfTypeKey];
    
    //收入数据
    self.incomeDic = [[DatabaseManager ShareDBManager]readSpendTypeList:nil andIsPayout:NO];
    self.incomeList = self.incomeDic[kDicOfTypeKey];
    
    _isTypePicker = YES;//判断是支出还是收入，好多picker的重用
    
    //判断，添加bill时不调用此函数，修改bill时调用此函数。
    if (!self.aBill.moneyAmount == 0) {
        [self editAbill];
    }
    if ([self.identifierStr isEqualToString:kMainShowIdentifier]) {
        self.editBill.hidden = YES;
    }
    if ([self.identifierStr isEqualToString:kCharShowIdentifier]) {
        self.saveBill.hidden = YES;
        self.comeBackBill.hidden =YES;
    }
    if ([self.identifierStr isEqualToString:kDayShowIdentifier]) {
        self.saveBill.hidden = YES;
        self.comeBackBill.hidden =YES;
    }
    if ([self.identifierStr isEqualToString:kWeekShowIdentifier]) {
        self.saveBill.hidden = YES;
        self.comeBackBill.hidden =YES;
    }
    if ([self.identifierStr isEqualToString:kMonthShowIdentifier]) {
        self.saveBill.hidden = YES;
        self.comeBackBill.hidden =YES;
    }
    if ([self.identifierStr isEqualToString:kBillShowIdentifier]) {
        self.saveBill.hidden = YES;
        self.comeBackBill.hidden =YES;
    }
//    if (1 == self.isPayoutSegment.selectedSegmentIndex ) {
//        self.classText.text = @"工资";
//    }
}

//- (void)viewWillAppear:(BOOL)animated {//此方法为 当push时调用
//    
//    [self.pickerView reloadAllComponents];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//选择收入支出按钮值改变时响应函数
- (IBAction)isPayoutSegmentButton:(UISegmentedControl *)sender {
    
    BOOL isPayout;
    if (self.isPayoutSegment.selectedSegmentIndex == 0) {
        isPayout = YES;
    }else{
        isPayout = NO;
    }
    if (1 == self.isPayoutSegment.selectedSegmentIndex ) {
        self.classText.text = @"工资";
        self.typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:isPayout];
        self.typeList = self.typeDic[kDicOfTypeKey];
    }
    if (0 == self.isPayoutSegment.selectedSegmentIndex) {
        self.classText.text = @"食品酒水>早午晚餐";
        self.typeDic = [[DatabaseManager ShareDBManager] readSpendTypeList:nil andIsPayout:isPayout];
        self.typeList = self.typeDic[kDicOfTypeKey];
    }
    
    [self.pickerView reloadAllComponents];
}

//保存bill按钮
- (IBAction)saveBillToDatabase:(UIButton *)sender {
    UIAlertView *alertView;
    if (self.classText.text.length == 0) {
         alertView = [[UIAlertView alloc] initWithTitle:@"警告！" message:@"你还没有填写类别" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alertView show];
    }
    if (self.tfIncomeText.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"不能保存" message:@"金额为空,请输入金额" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    
    Bill *aBill = [[Bill alloc] init];
    spendingType *aSpendType=[[spendingType alloc]init];
    member *aMember = [[member alloc] init];
    aSpendType = [[DatabaseManager ShareDBManager] selectTypeByTypeName:_typeStr];
    aMember=[[DatabaseManager ShareDBManager] selectMember:self.memberText.text];
    //string转换为date
    NSString *timeStr=self.dateText.text;
    
    aBill.billTime=[timeStr substringToIndex:10];
    aBill.memberID = aMember.memberID;
    aBill.moneyAmount=self.tfIncomeText.text.floatValue;
    aBill.billRemarks=self.remarksTextView.text;
    BOOL isPayout;
    if (self.isPayoutSegment.selectedSegmentIndex == 0) {
        isPayout = YES;
    }else{
        isPayout = NO;
    }
    aBill.isPayout = isPayout;
    aBill.spendID = aSpendType.spendID;
    aBill.billImageData = UIImageJPEGRepresentation(self.imageView.image, 0.5);
    
    [[DatabaseManager ShareDBManager] addNewBill:aBill];
    
}

//TODO:修改账单属性
- (IBAction)editBillButton:(id)sender {
    Bill *aBill = [[Bill alloc]init];
    aBill.billID = self.aBill.billID;
    aBill.billImageData = UIImageJPEGRepresentation(self.imageView.image, 0.7);
    aBill.moneyAmount = self.tfIncomeText.text.intValue;
    aBill.billTime = self.dateText.text;
    aBill.billRemarks = self.remarksTextView.text;
    
    member *aMember =  [[DatabaseManager ShareDBManager]selectMember:self.memberText.text];
    aBill.memberID = aMember.memberID;
    
    NSArray *TypeList = [self.classText.text componentsSeparatedByString:@">"];
    NSString *TypeStr = TypeList[1];
    spendingType *aType =  [[DatabaseManager ShareDBManager]selectTypeByTypeName:TypeStr];
    aBill.spendID = aType.spendID;
    
    [[DatabaseManager ShareDBManager]modifyBill:aBill];
}
// 在记一笔
- (IBAction)comeBackButton:(id)sender {
    //判断金额是否为空
    if (self.tfIncomeText.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"不能保存" message:@"金额为空,请输入金额" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    Bill *aBill = [[Bill alloc]init];
    spendingType *aType = [[spendingType alloc]init];
    aBill.moneyAmount=self.tfIncomeText.text.floatValue;
    aBill.billRemarks=self.remarksTextView.text;
    aBill.billImageData = UIImageJPEGRepresentation(self.imageView.image, 0.5);
    
    aType = [[DatabaseManager ShareDBManager] selectTypeByTypeName:_typeStr];//查询小类别
    aBill.spendID = aType.spendID;
    
    member *aMember = [[member alloc] init];
    aMember=[[DatabaseManager ShareDBManager] selectMember:self.memberText.text];
    aBill.memberID = aMember.memberID;
    //string转换为date
    NSString *timeStr=self.dateText.text;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    //    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    aBill.billTime=timeStr;
    aBill.isPayout=YES;
    
    [[DatabaseManager ShareDBManager] addNewBill:aBill];
    
    //数据清空
    self.tfIncomeText.text = nil;
    self.remarksTextView.text=nil;
    self.imageView.image=[UIImage imageNamed:@"camera"];
    NSDate *now=[[NSDate alloc]init];
    NSString *todayDate=[[now description] substringWithRange:NSMakeRange(0, 10)];
    self.dateText.text=todayDate;

}

#pragma mark - datePicker
- (void)dateChoose{
    _date=[self.TimePicker date];  //创建时间格式化实例对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];//设置时间格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dates=[dateFormatter stringFromDate:_date];
    self.dateText.text=dates;
    
//    self.datePickerSubView.hidden=YES;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"时间提示" message:dateAndTime delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alert show];
}
- (IBAction)chooseButton:(UIBarButtonItem *)sender {
    self.subView.hidden=YES;
    if (_isTypePicker == YES) {
        if (self.isPayoutSegment.selectedSegmentIndex==0) {
            NSString *Str=[NSString stringWithFormat:@"%@>%@",_fatherTypeStr,_typeStr];
            self.classText.text=Str;
        }else{
            self.classText.text=_spendName;
        }
    }else{
        self.memberText.text = [NSString stringWithFormat:@"%@",_memberStr];
    }
}


//修改第一响应者
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view resignFirstResponder];
    [self.remarksTextView resignFirstResponder];
    [_tfIncomeText resignFirstResponder];
    [self.dateText resignFirstResponder];
}

#pragma mark - PickerView
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (_isTypePicker == YES) {
        
        if (self.isPayoutSegment.selectedSegmentIndex==0) {
            return 2;
        }else{//end 收入pickerView中显示多少列
            return 1;
        }//end 支出pickerView中显示多少列
    }else{
        return 1;
    }//end---member
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (_isTypePicker == YES) {
        if (self.isPayoutSegment.selectedSegmentIndex==0) {
            if (component==0) {
                return self.typeList.count;
            }else{
                spendingType *aType = self.typeList[self.rowInProvince];
                NSArray *subTypeList = [self.typeDic objectForKey:aType.spendName];
                return subTypeList.count;
            }//end 收入pickerView中每个component的个数
        }else{
            
            return self.incomeList.count;
         
        }//end pickerView中每个component的个数
        
    }else{
        return self.memberList.count;
    }//end---member
    
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *typeStr;
    NSString *fatherTypeStr;
    if (_isTypePicker == YES) {
        if (self.isPayoutSegment.selectedSegmentIndex==0) {
            if (component==0) {
                NSArray *array = [self.typeDic objectForKey:@"big"];
                spendingType *aType = array[row];
                fatherTypeStr = aType.spendName;
                _fatherTypeStr=fatherTypeStr;
                
                return fatherTypeStr;
                
            }else{
                NSArray *typeList = [self.typeDic objectForKey:@"big"];
                spendingType *aType = typeList[self.rowInProvince];
                NSArray *subTypeList = [self.typeDic objectForKey:aType.spendName];
                aType = subTypeList[row];
                typeStr =aType.spendName;
                _typeStr=typeStr;
                
                return typeStr;
            }//end 收入pickerView的component值显示
        }else{
            spendingType *spendType=self.incomeList[row];
            _spendName=spendType.spendName;
            return _spendName;
        }//end 支出pickerView的component值显示
    }else{
        member *aMember= self.memberList[row];
        _memberStr = aMember.memberName;
        return _memberStr;
    }//end---member
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.rowInProvince=row;
    if (_isTypePicker == YES) {
        if (self.isPayoutSegment.selectedSegmentIndex==0) {
            if (component==0) {
                [self.pickerView reloadComponent:1];
            }
        }
    }

}


#pragma mark - ZenKeyboardViewDelegate

- (void)didNumericKeyPressed:(UIButton *)button {
    _tfIncomeText.text = [NSString stringWithFormat:@"%@%@", _tfIncomeText.text, button.titleLabel.text];
}

- (void)didBackspaceKeyPressed {
    NSInteger length = _tfIncomeText.text.length;
    if (length == 0) {
//        _tfIncomeText.text = @"";
        
        return;
    }
    
    NSString *substring = [_tfIncomeText.text substringWithRange:NSMakeRange(0, length - 1)];
    _tfIncomeText.text = substring;
}

#pragma mark - UITextViewDelegete

-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.remarksTextView.text = nil;
}

- (IBAction)classButton:(UIButton *)sender {
    _isTypePicker = YES;
    [self.pickerView reloadAllComponents];
    self.subView.hidden=NO;
}

- (IBAction)memberButton:(id)sender {
    _isTypePicker = NO;
    [self.pickerView reloadAllComponents];
    self.subView.hidden=NO;
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

#pragma mark - 修改bill
-(void)editAbill;
{
    //TODO:传来的数据，显示数据
    self.imageView.image = [UIImage imageWithData:self.aBill.billImageData];
    self.tfIncomeText.text = [NSString stringWithFormat:@"%.2f",self.aBill.moneyAmount];
    self.dateText.text = self.aBill.billTime;
    self.remarksTextView.text = self.aBill.billRemarks;
    
    spendingType *aSpendType =  [[DatabaseManager ShareDBManager]selectTypeByTypeID:[NSString stringWithFormat:@"%d",self.aType.fatherType.spendID] andIsPayout:YES];
    self.classText.text = [NSString stringWithFormat:@"%@>%@",aSpendType.spendName,self.aType.spendName];
    
    self.memberText.text = self.aMember.memberName;
}

@end
