//
//  KokyTestRAC
//
//  Created by xujing on 17/3/1.
//  Copyright © 2017年 xujing. All rights reserved.
//

#import "ALLoginViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#define MAX_PHONE_LEGNTH    11
#define MIN_PSW_LENGTH      6    //密码最小长度
#define MAX_PSW_LENGTH      16   //密码最大长度


@implementation ALLoginViewModel

- (ALLoginViewModel *)init
{
    self = [super init];
    if (self) {
        [self signalAction];
        [self bindSignalAction];
        [self nicknameCheckSignalAction];
    }
    return self;
}

- (void)signalAction
{
    RACSignal *loginNameSignal =
    [[RACObserve(self, loginName)
      map:^id(NSString *text) {
          return text;
      }]
     distinctUntilChanged];
    
    @weakify(self)
    [loginNameSignal subscribeNext:^(id x) {
        @strongify(self)
        NSString *string = (NSString *)x;
        if (string.length > MAX_PHONE_LEGNTH) {
            self.loginName = [string substringToIndex:MAX_PHONE_LEGNTH];
        }
        [self checkLoginButtonStatus];
        self.loginNameErrorMsg = @"";
    }];
    
    RACSignal *pwdSignal =
    [[RACObserve(self, password)
      map:^id(NSString *text) {
          return text;
      }]
     distinctUntilChanged];
    
    [pwdSignal subscribeNext:^(id x) {
        @strongify(self)
        NSString *string = (NSString *)[x stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (string.length > MAX_PSW_LENGTH) {
            self.password = [string substringToIndex:MAX_PSW_LENGTH];
        }
        [self checkLoginButtonStatus];
        self.pwdErrorMsg = @"";
    }];
}

- (void)bindSignalAction
{
    RACSignal *bindLoginNameSignal =
    [[RACObserve(self, bindMobile)
      map:^id(NSString *text) {
          return text;
      }]
     distinctUntilChanged];
    
    @weakify(self)
    [bindLoginNameSignal subscribeNext:^(id x) {
        @strongify(self)
        NSString *string = (NSString *)x;
        if (string.length > MAX_PHONE_LEGNTH) {
            self.bindMobile = [string substringToIndex:MAX_PHONE_LEGNTH];
        }
        [self checkBindButtonStatus];
    }];
    
    RACSignal *bindPwdSignal =
    [[RACObserve(self, bindPwd)
      map:^id(NSString *text) {
          return text;
      }]
     distinctUntilChanged];
    
    [bindPwdSignal subscribeNext:^(id x) {
        @strongify(self)
        NSString *string = (NSString *)[x stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (string.length > MAX_PSW_LENGTH) {
            self.bindPwd = [string substringToIndex:MAX_PSW_LENGTH];
        }
        [self checkBindButtonStatus];
    }];
}

- (void)nicknameCheckSignalAction
{
    RACSignal *nicknameSignal =
    [[RACObserve(self, bindNickname)
      map:^id(NSString *text) {
          return text;
      }]
     distinctUntilChanged];
    
    @weakify(self)
    [nicknameSignal subscribeNext:^(id x) {
        @strongify(self)
        [self checkNicknameButtonStatus];
    }];
}

- (void)checkLoginButtonStatus
{
    if (self.password.length >= MIN_PSW_LENGTH && self.password.length <= MAX_PSW_LENGTH && self.loginName.length != 0) {
        self.loginButtonStatus = YES;
    }else{
        self.loginButtonStatus = NO;
    }
}

- (void)checkBindButtonStatus
{
    if (self.bindPwd.length >= MIN_PSW_LENGTH && self.bindPwd.length <= MAX_PSW_LENGTH && self.bindMobile.length != 0) {
        self.bindButtonStatus = YES;
    }else{
        self.bindButtonStatus = NO;
    }
}

- (void)checkNicknameButtonStatus
{
    if (self.bindNickname.length != 0) {
        self.bindButtonStatus = YES;
    }else{
        self.bindButtonStatus = NO;
    }
}

- (void)loginActionComplete:(ALViewModelComplete)complete
{
    BOOL flag = NO;
    BOOL loginNameCheckFlag = [self checkTel:self.loginName];
    BOOL passwordCheckFlag = [self checkPassword:self.password];
    if (!loginNameCheckFlag) {
        NSLog(@"格式错误");
        return;
    }else{
        self.loginNameErrorMsg = @"";
    }
    
    if (!passwordCheckFlag) {
        NSLog(@"6~16个字符以内，支持字母、数字及特殊符号");
        return;
    }else{
        self.pwdErrorMsg = @"";
    }
    
    if (loginNameCheckFlag && passwordCheckFlag) {
        flag = YES;
    }
    
    if (flag) {
        //登录接口请求代码写这里
       complete(@"登录结果");
    }else{
        complete(nil);
    }
}

- (BOOL)checkTel:(NSString *)str{
    NSString *regex = @"^1[34578]\\d{9}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

- (BOOL)checkPassword:(NSString *) password
{
    //6-16  0
    NSString *pattern = @"^[A-Za-z0-9_]{6,16}$"; //只含有数字、字母、下划线，下划线位置不限
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

@end
