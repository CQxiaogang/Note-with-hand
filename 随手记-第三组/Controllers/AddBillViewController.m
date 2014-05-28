//
//  AddBillViewController.m
//  随手记-第三组
//
//  Created by student on 14-5-15.
//  Copyright (c) 2014年 小刚. All rights reserved.
//

#import "AddBillViewController.h"
#import "DatabaseManager.h"

@interface AddBillViewController ()

//弹出的视图（pickerView和buttons）
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;//pickerView的输出口
- (IBAction)editButton:(UIBarButtonItem *)sender;//编辑按钮
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

@property (weak, nonatomic) IBOutlet UISegmentedControl *isPayoutSegment;//支出和收入选择
- (IBAction)saveBillToDatabase:(UIButton *)sender;

@property (assign ,nonatomic) NSInteger rowInProvince;//全局,picker中得到位置

@property(nonatomic,strong)ZenKeyboard *keyboardView;//键盘

@property(nonatomic,strong)UIDatePicker *TimePicker;//自定义datePicker

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
//    
//    self.memberList = [[NSMutableArray alloc] initWithObjects:@"自己",@"老婆",@"幺儿",@"侄儿",@"爸妈",@"朋友",nil];
//    for (int i=0;i<self.memberList.count;i++) {
//        NSString *nameStr = self.memberList[i];
//        member *aMemer = [[member alloc] init];
//        aMemer.memberName = nameStr;
////        aMemer.memberID=i;
//        [[DatabaseManager ShareDBManager] addNewMember:aMemer];
//    }
//    //收入数组
//    self.budgetClasslist=[[NSMutableArray alloc]initWithObjects:@"工资",@"证劵",@"银行利息",@"意外收获",@"外债",nil];
//    for (int i=0; i<self.budgetClasslist.count; i++) {
//        NSString *budgetClassStr=self.budgetClasslist[i];
//        spendingType *aSpendingType=[[spendingType alloc]init];
//        aSpendingType.spendName=budgetClassStr;
//        aSpendingType.spendID=i+24;
//        [[DatabaseManager ShareDBManager]addNewSpendType:aSpendingType];
//    }
    //
    
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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    //    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];//转换时间格式
    NSDate *date=[dateFormatter dateFromString:timeStr];
    
    aBill.billTime=date;
    aBill.memberID = aMember.memberID;
    aBill.moneyAmount=self.tfIncomeText.text.floatValue;
    aBill.billRemarks=self.remarksTextView.text;
    aBill.isPayout = self.isPayoutSegment.selectedSegmentIndex;
    aBill.spendID = aSpendType.spendID;
    
    [[DatabaseManager ShareDBManager] addNewBill:aBill];
    
}

#pragma mark - datePicker
- (void)dateChoose{
    _date=[self.TimePicker date];  //创建时间格式化实例对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];//设置时间格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
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
        }else{
            return 1;
        }
    }else{
        return 1;
    }
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (_isTypePicker == YES) {
        if (self.isPayoutSegment.selectedSegmentIndex==0) {
                if (component==0) {
                return self.typeList.count;
            }else{
                return [[[self.typeList objectAtIndex:self.rowInProvince] objectForKey:@"childType"] count];
            }
        }else{
            return self.budgetClasslist.count;
        }
        
    }else{
        return self.memberList.count;
    }
    
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (_isTypePicker == YES) {
        if (self.isPayoutSegment.selectedSegmentIndex==0) {
            if (component==0) {
                NSString *fatherTypeStr=[[self.typeList objectAtIndex:row] objectForKey:@"fatherType"];
                _fatherTypeStr=fatherTypeStr;
                return fatherTypeStr;
                //        return [[fatherType objectAtIndex:row]objectForKey:@"fatherType"];
            }else{
                NSString *typeStr=[[[[self.typeList objectAtIndex:self.rowInProvince] objectForKey:@"childType"] objectAtIndex:row] objectForKey:@"type"];
                _typeStr=typeStr;
                return typeStr;
                //        return [[[[fatherType objectAtIndex:self.rowInProvince] objectForKey:@"childType"] objectAtIndex:row] objectForKey:@"type"];
            }
        }else{
            NSString *spendType=self.budgetClasslist[row];
            _spendName=spendType;
            return spendType;
        }
    }else{
        NSString *memberStr = self.memberList[row];
        _memberStr = memberStr;
        return memberStr;
    }
    
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
@end
