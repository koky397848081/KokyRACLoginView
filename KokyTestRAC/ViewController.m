//
//  ViewController.m
//  KokyTestRAC
//
//  Created by xujing on 17/3/1.
//  Copyright © 2017年 xujing. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ALLoginViewModel.h"

@interface ViewController ()
{
    ALLoginViewModel *_loginViewModel;

    __weak IBOutlet UITextField *_loginNameTF;

    __weak IBOutlet UITextField *_pwdTF;
    
    __weak IBOutlet UIButton *_loginButton;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loginViewModel = [[ALLoginViewModel alloc] init];
    [self bindViewModel];

}

- (void)bindViewModel{
    
    RAC(_loginViewModel, loginName) = _loginNameTF.rac_textSignal;
    RAC(_loginViewModel, password) = _pwdTF.rac_textSignal;
    RAC(_loginNameTF, text) = RACObserve(_loginViewModel, loginName);
    RAC(_pwdTF, text) = RACObserve(_loginViewModel, password);
    RAC(_loginButton, enabled) = RACObserve(_loginViewModel, loginButtonStatus);
}

- (IBAction)clickLoginButton:(UIButton *)sender {
    [self.view endEditing:YES];
    [_loginViewModel loginActionComplete:^(id result) {
        sender.enabled = YES;
        if (result) {
            NSLog(@"登录");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
