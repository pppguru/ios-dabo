//
//  AddMoreOccasionsVC.m
//  Gifter
//
//  Created by Vivudh Pandey on 12/15/15.
//
//

#import "AddMoreOccasionsVC.h"
#import "UIPickerView+Blocks.h"
#import "KTUtility.h"
#import "AppDelegate.h"
#import "JSON.h"

@interface AddMoreOccasionsVC () <UITextFieldDelegate>
{
    UIDatePicker *datePicker;
    UIPickerView *pickerView;
    
    IBOutlet UITextField *occasionTypeTF;
    IBOutlet UITextField *occasionDateTF;
    
    UITextField *selectedTexField;
    
    IBOutlet UIButton *saveBtn;
    
    AppDelegate *delegate;
    
    NSMutableArray *occasionArr;
    
    NSDictionary *isEditDic;
}
@end

@implementation AddMoreOccasionsVC
@synthesize isEdit,occDateStr,occTypeStr;

- (void)viewDidLoad
{
    if(self.isEdit)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit Occasion", @"");
        occasionTypeTF.text = self.occTypeStr;
        occasionDateTF.text = self.occDateStr;
        
        isEditDic= [NSDictionary dictionaryWithObjectsAndKeys:occasionTypeTF.text,@"name",occasionDateTF.text,@"date", nil];
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"Add Occasion", @"");
    }

    [KTUtility setButtonUI:saveBtn];
    
    UIColor *borderColor = [UIColor colorWithRed:232.0/255.0 green:0 blue:31.0/255.0 alpha:0.8];
    
    [[occasionTypeTF layer] setBorderColor:borderColor.CGColor];
    [[occasionDateTF layer] setBorderColor:borderColor.CGColor];
    
    [[occasionTypeTF layer] setBorderWidth:1.0f];
    [[occasionDateTF layer] setBorderWidth:1.0f];
    
    [[occasionTypeTF layer] setCornerRadius:3.5f];
    [[occasionDateTF layer] setCornerRadius:3.5f];
   
    [super viewDidLoad];
}

- (IBAction)save:(id)sender
{
    if (occasionDateTF.text.length == 0 || occasionTypeTF.text.length == 0) {
        
        [[[UIAlertView alloc]
          initWithTitle:@""
          message:@"Please fill in all the details to add the person."
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil] show];

        return;
    }
    
    delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSString *occasionStr = [delegate.occasionJsonStr copy];
    if (occasionStr!=nil) {
        NSError *jsonError;
        NSData *objectData = [occasionStr dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:objectData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&jsonError];
        occasionArr = [[NSMutableArray alloc] initWithArray:jsonArr];
    }
    else
    {
        occasionArr = [[NSMutableArray alloc] init];
    }
    
    if(self.isEdit)
    {
        [occasionArr removeObject:isEditDic];
    }
   
    NSDictionary *ocsDic= [NSDictionary dictionaryWithObjectsAndKeys:occasionTypeTF.text,@"name",occasionDateTF.text,@"date", nil];
    [occasionArr addObject:ocsDic];
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    
    NSString *jsonString = [jsonWriter stringWithObject:occasionArr];
    
    delegate.occasionJsonStr = [jsonString copy];
   
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openOccasionType:(id)sender
{
    [[self.view viewWithTag:1001] removeFromSuperview];
    [[self.view viewWithTag:1002] removeFromSuperview];
    pickerView = [self makeAPicker:0];
    
    selectedTexField = occasionTypeTF;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 240)];
    
    view.tag = 1001;
    
    [self addToolbar:view];
    
    [view addSubview:pickerView];
    
    [self.view addSubview:view];
    
    NSMutableArray *items = nil;
    
    items = [[NSMutableArray alloc] initWithArray:[@[
                                                     @"Birthday",
                                                     @"anniversary",
                                                     @"valentines day",
                                                     @"graduation",
                                                     @"wedding",
                                                     @"bridal shower",
                                                     @"engagement",
                                                     @"special occasion",
                                                     @"In Dabo mood"
                                                     ] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    [pickerView setTitles:@[ items ]];
    
    if (occasionTypeTF.text.length == 0) {
        occasionTypeTF.text = [items objectAtIndex:0];
    }
    
    [pickerView
     handleSelectionWithBlock:^void(UIPickerView *pickerView, NSInteger row,
                                    NSInteger component) {
         occasionTypeTF.text = [items objectAtIndex:row];
     }];
}

- (IBAction)openOccasionDate:(id)sender
{
    selectedTexField = occasionDateTF;
    [[self.view viewWithTag:1001] removeFromSuperview];
    [[self.view viewWithTag:1002] removeFromSuperview];
    [self datePicker:0];
    
    UIView *view = [[UIView alloc]
                    initWithFrame:CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 240)];
    
    view.tag = 1002;
    
    [self addToolbar:view];
    
    [view addSubview:datePicker];
    
    [self.view addSubview:view];
}

#pragma mark - Picker

-(void)datePicker :(NSUInteger)row{
    
    datePicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 160)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.hidden = NO;
    datePicker.backgroundColor=[UIColor whiteColor];
    datePicker.date = [NSDate date];
    
    [datePicker addTarget:self
                   action:@selector(ChangeValue:)
         forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"M-d-yyyy"]; // from here u can change format..
    occasionDateTF.text=[df stringFromDate:datePicker.date];
}

- (void)ChangeValue:(id)sender
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"M-d-yyyy"];
    
    occasionDateTF.text = [NSString stringWithFormat:@"%@",
                           [df stringFromDate:datePicker.date]];
}

- (UIPickerView *)makeAPicker:(NSUInteger)row
{
    UIPickerView *myPickerView = [[UIPickerView alloc]
                                  initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 160)];
    myPickerView.backgroundColor = [UIColor whiteColor];
    myPickerView.showsSelectionIndicator = YES;
    myPickerView.tag = row;
    
    return myPickerView;
}

- (void)addToolbar:(UIView *)view
{
    UIToolbar *doneToolbar = [[UIToolbar alloc]
                              initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *selectBtn =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(selectBtn:)];
    
    
    [selectBtn setTitleTextAttributes:@{
                                        NSFontAttributeName : SKIA_REGULAR(16),
                                        NSForegroundColorAttributeName : GT_RED
                                        } forState:UIControlStateNormal];
    
    [selectBtn setTintColor:GT_RED];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear")
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(cancelButton:)];
    
    [cancelButton setTitleTextAttributes:@{
                                           NSFontAttributeName : SKIA_REGULAR(16),
                                           NSForegroundColorAttributeName : GT_RED
                                           } forState:UIControlStateNormal];
    
    [cancelButton setTintColor:GT_RED];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    doneToolbar.items = @[cancelButton, flexibleSpace, selectBtn ];
    
    [doneToolbar sizeToFit];
    
    [view addSubview:doneToolbar];
}

- (void)cancelButton:(id)sender
{
    selectedTexField.text = @"";
    
    [[self.view viewWithTag:1001] removeFromSuperview];
    [[self.view viewWithTag:1002] removeFromSuperview];
}

- (void)selectBtn:(id)sender
{
    [[self.view viewWithTag:1001] removeFromSuperview];
    [[self.view viewWithTag:1002] removeFromSuperview];
}


@end
