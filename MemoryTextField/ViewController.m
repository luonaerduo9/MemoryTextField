//
//  ViewController.m
//  MemoryTextField
//
//  Created by ui01 on 15/11/12.
//  Copyright © 2015年 LJ. All rights reserved.
//

#import "ViewController.h"
#import "MemoryTextField.h"

#define StaH [[UIApplication sharedApplication] statusBarFrame].size.height

@interface ViewController ()

@property(nonatomic,strong) MemoryTextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _textField = [[MemoryTextField alloc]initWithFrame:CGRectMake(20, 50+StaH, self.view.frame.size.width*0.6, 50) inViewController:self];
    [self.view addSubview:_textField];
    
}

- (IBAction)saveString:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"save" object:nil userInfo:nil];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_textField resignFirstResponder];
}

@end
