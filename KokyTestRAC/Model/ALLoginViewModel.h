//
//  KokyTestRAC
//
//  Created by xujing on 17/3/1.
//  Copyright © 2017年 xujing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ALViewModelComplete)(id result);

@interface ALLoginViewModel : NSObject

@property (nonatomic, strong) NSString *loginName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL      loginButtonStatus;
@property (nonatomic, strong) NSString *loginNameErrorMsg;
@property (nonatomic, strong) NSString *pwdErrorMsg;
@property (nonatomic, strong) NSString *bindMobile;
@property (nonatomic, strong) NSString *bindPwd;
@property (nonatomic, strong) NSString *bindNickname;
@property (nonatomic, assign) BOOL      bindButtonStatus;

- (void)loginActionComplete:(ALViewModelComplete)complete;

@end
