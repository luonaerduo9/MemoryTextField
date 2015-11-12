# MemoryTextField
Localdatabase Save,Auto Complete Text Field,  Auto Search,May delete
- (void)viewDidLoad {
    [super viewDidLoad];

    _textField = [[MemoryTextField alloc]initWithFrame:CGRectMake(20, 50+StaH, self.view.frame.size.width*0.6, 50) inViewController:self];
    [self.view addSubview:_textField];
    
}

- (IBAction)saveString:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"save" object:nil userInfo:nil];
}
