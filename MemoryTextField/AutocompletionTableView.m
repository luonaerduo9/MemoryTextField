//
//  MemoryTextField.m
//  MemoryTextField
//
//  Created by ui01 on 15/11/12.
//  Copyright © 2015年 LJ. All rights reserved.
//

#import "AutocompletionTableView.h"

@interface AutocompletionTableView () 
@property (nonatomic, strong) NSArray *suggestionOptions; // of selected NSStrings 
@property (nonatomic, strong) UITextField *textField; // will set automatically as user enters text
@property (nonatomic, strong) UIFont *cellLabelFont; // will copy style from assigned textfield
@end

@implementation AutocompletionTableView

@synthesize suggestionsDictionary = _suggestionsDictionary;
@synthesize suggestionOptions = _suggestionOptions;
@synthesize textField = _textField;
@synthesize cellLabelFont = _cellLabelFont;
@synthesize options = _options;

#pragma mark - Initialization
- (UITableView *)initWithTextField:(UITextField *)textField inViewController:(UIViewController *) parentViewController withOptions:(NSDictionary *)options
{
    //set the options first
    self.options = options;
    // frame must align to the textfield 
    CGRect frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y+textField.frame.size.height, textField.frame.size.width, 0);
    
    // save the font info to reuse in cells
    self.cellLabelFont = textField.font;
    
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    
    self.delegate = self;
    self.dataSource = self;
    self.scrollEnabled = YES;
    
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // turn off standard correction
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // to get rid of "extra empty cell" on the bottom
    // when there's only one cell in the table
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textField.frame.size.width, 1)]; 
    v.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:v];
    self.hidden = YES;  
    [parentViewController.view addSubview:self];

    return self;
}

#pragma mark - Logic staff
- (BOOL) substringIsInDictionary:(NSString *)subString
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    NSRange range;
    
    for (NSString *tmpString in self.suggestionsDictionary)
    {
        range = ([[self.options valueForKey:ACOCaseSensitive] isEqualToNumber:[NSNumber numberWithInt:1]]) ? [tmpString rangeOfString:subString] : [tmpString rangeOfString:subString options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) [tmpArray addObject:tmpString];
    }
    if ([tmpArray count]>0)
    {
        self.suggestionOptions = tmpArray;
        return YES;
    }
    return NO;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestionOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    if ([self.options valueForKey:ACOUseSourceFont]) 
    {
        cell.textLabel.font = [self.options valueForKey:ACOUseSourceFont];
    } else 
    {
        cell.textLabel.font = self.cellLabelFont;
    }
    cell.textLabel.adjustsFontSizeToFitWidth = NO;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"delete.jpg"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 5, 20, 20);
    [btn addTarget:self action:@selector(btnClicked: event:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = btn;
    cell.textLabel.text = [self.suggestionOptions objectAtIndex:indexPath.row];

    return cell;
}
- (void)btnClicked:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil)
    {
        [self tableView:self accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 30;
    
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textField setText:[self.suggestionOptions objectAtIndex:indexPath.row]];
    [self hideOptionsView];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{

    NSString *str = self.suggestionOptions[indexPath.row];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"delete" object:nil userInfo:@{@"string":str}];
}

#pragma mark - UITextField delegate
- (void)textFieldValueChanged:(UITextField *)textField
{
    self.textField = textField;
    NSString *curString = textField.text;
    
    if (![curString length])
    {
        [self showOptionsView];
        self.suggestionOptions = self.suggestionsDictionary;
        self.frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y+textField.frame.size.height, textField.frame.size.width, (MIN(self.suggestionOptions.count, 3)+0.5)*30);
        [self reloadData];
        return;
    } else if ([self substringIsInDictionary:curString])
        {
            [self showOptionsView];
            self.frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y+textField.frame.size.height, textField.frame.size.width, (MIN(self.suggestionOptions.count, 3)+0.5)*30);
            [self reloadData];
        } else [self hideOptionsView];
}

#pragma mark - Options view control
- (void)showOptionsView
{
    self.hidden = NO;
}

- (void) hideOptionsView
{
    self.hidden = YES;
}


@end
