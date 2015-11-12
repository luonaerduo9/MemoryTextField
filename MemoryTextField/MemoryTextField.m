//
//  MemoryTextField.m
//  MemoryTextField
//
//  Created by ui01 on 15/11/12.
//  Copyright © 2015年 LJ. All rights reserved.
//

#import "MemoryTextField.h"
#import "FMDatabase.h"
#import "AutocompletionTableView.h"

@interface MemoryTextField()<UITextFieldDelegate>

@property (nonatomic, strong) AutocompletionTableView *autoCompleter;
@property (nonatomic,strong)UIViewController *vc;

@end

@implementation MemoryTextField

- (AutocompletionTableView *)autoCompleter
{
    if (!_autoCompleter)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        [options setValue:[NSNumber numberWithBool:YES] forKey:ACOCaseSensitive];
        [options setValue:nil forKey:ACOUseSourceFont];
        
        _autoCompleter = [[AutocompletionTableView alloc] initWithTextField:self inViewController:self.vc withOptions:options];
        _autoCompleter.suggestionsDictionary = [self fetchPhones];
    }
    return _autoCompleter;
}

-(instancetype)initWithFrame:(CGRect)frame inViewController:(UIViewController *)viewController{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatPhonesDoc];
        self.vc = viewController;
        self.placeholder = @"please Input!";
        self.delegate = self;
        self.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.clearButtonMode = UITextFieldViewModeAlways;
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.borderStyle = UITextBorderStyleRoundedRect;
        [self addTarget:self.autoCompleter action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deletePhoneNum:) name:@"delete" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(savePhoneNum) name:@"save" object:nil];
    }
    return self;
}

-(void)deletePhoneNum:(NSNotification*)noti{

    NSString *str = [noti.userInfo objectForKey:@"string"];
    [self deletePhone:str];
    _autoCompleter.suggestionsDictionary = [self fetchPhones];
    [self.autoCompleter textFieldValueChanged:self];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.autoCompleter textFieldValueChanged:textField];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.autoCompleter.hidden = YES;
}

-(void)savePhoneNum{
    [self creatPhonesDoc];
    [self insertPhone:self.text];
    _autoCompleter.suggestionsDictionary = [self fetchPhones];
}

-(void)creatPhonesDoc{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    FMDatabase *db= [FMDatabase databaseWithPath:[self getPath]];
    if (![fileManager fileExistsAtPath:[self getPath]]) {
        NSLog(@"还未创建数据库，现在正在创建数据库");
        if ([db open]) {
            [db executeUpdate:@"create table if not exists stringsList (string text)"];
            [db close];
        }else{
            NSLog(@"database open error");
        }
    }
    
}

//1>,插入数据
-(void)insertPhone:(NSString*)str{
    
    if ([str isEqualToString:@""]) {
        return;
    }
    
    NSMutableArray *array = [self fetchPhones];
    for (NSString*string in array) {
        if ([string isEqualToString:str]) {
            return;
        }
    }
    FMDatabase *db = [FMDatabase databaseWithPath:[self getPath]];
    [db open];
    BOOL res = [db executeUpdate:@"INSERT INTO stringsList (string) VALUES (?)", str];
    if (res == NO) {
        NSLog(@"数据插入失败");
    }else{
        NSLog(@"数据插入成功");
    }
    [db close];
    
}
//2>,删除操作
-(void)deletePhone:(NSString*)str{
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getPath]];
    //打开数据库
    BOOL res = [db open];
    //如果失败，退出方法
    if (res == NO) {
        NSLog(@"打开失败");
        return;
    }
    //删除
    res = [db executeUpdate:@"delete from stringsList where string=?",str];
    if (res == NO) {
        NSLog(@"删除失败");
    }else{
        NSLog(@"删除成功");
    }
    [db close];
    
}
//4>,查询操作
-(NSMutableArray*)fetchPhones{
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getPath]];
    BOOL res = [db open];
    if (res == NO) {
        NSLog(@"打开失败");
        return nil;
    }
    FMResultSet* set = [db executeQuery:@"select * from stringsList"];//FMResultSet相当于游标集
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    //遍历Students表
    while ([set next]) {//有下一个的话，就取出它的数据，然后关闭数据库
        //姓名
        NSString* str = [set stringForColumn:@"string"];
        [array addObject:str];
    }
    [db close];
    return array;
    
}

- (NSString*) getPath {
    NSArray* paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) ;
    return [[paths objectAtIndex:0]stringByAppendingPathComponent:@"stringsList.txt"] ;
}

@end
