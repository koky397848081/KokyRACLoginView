//
//  KokyTestRAC
//
//  Created by xujing on 17/3/1.
//  Copyright © 2017年 xujing. All rights reserved.
//
/*
ReactiveCocoa:
 函数响应式编程（FRP）框架
 使用RAC解决问题，就不需要考虑调用顺序，直接考虑结果，把每一次操作都写成一系列嵌套的方法中，使代码高聚合，方便管理。
  RACSignal使用步骤：
  1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
  2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
  3.发送信号 - (void)sendNext:(id)value
 
 
  RACSignal底层实现：
  1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
  2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
  2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
  2.1 subscribeNext内部会调用siganl的didSubscribe
  3.siganl的didSubscribe中调用[subscriber sendNext:@1];
  3.1 sendNext底层其实就是执行subscriber的nextBlock
 
 RACSubject:RACSubject:信号提供者，自己可以充当信号，又能发送信号。
 使用场景:通常用来代替代理，有了它，就不必要定义代理了。
 // RACSubject使用步骤
 // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
 // 2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
 // 3.发送信号 sendNext:(id)value
 
 // RACSubject:底层实现和RACSignal不一样。
 // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
 // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
 
 
 // RACReplaySubject使用步骤:
 // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
 // 2.可以先订阅信号，也可以先发送信号。
 // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
 // 2.2 发送信号 sendNext:(id)value
 
 // RACReplaySubject:底层实现和RACSubject不一样。
 // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
 // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
 
 // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
 // 也就是先保存值，在订阅值。
 */
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ReactiveVC.h"

@interface ReactiveVC ()

@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *login;


@end

@implementation ReactiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    [self creatSignal];
//    [self creatSubject];
    
    [self testLoginWithRAC];

}
- (void)testLoginWithRAC{

    //将lalel的text和username的text信号进行绑定
    RAC(self.displayLabel,text)  = [self.userName rac_textSignal];
    
//    [self signalSubscribe]; //信号订阅
    //
    //    [self signalFilter]; ////信号过滤
    //
        [self signalMap]; //信号转化
    
    
    [self signalCombine];//信号合并，控制登录按钮交互状态

}
/*
- (void)creatSignal{

    
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    
        // 2.发送信号
        [subscriber sendNext:@1];
        
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            
            // 执行完Block后，当前信号就不在被订阅了。
            
            NSLog(@"信号被销毁");
        }];
    
    
    }];

    // 3.订阅信号,才会激活信号.
    [siganl subscribeNext:^(id x) {
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@",x);
    }];
  
}
- (void)creatSubject{

    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者%@",x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者%@",x);
    }];
    
    // 3.发送信号
    [subject sendNext:@"1"];

}
 */
//信号订阅
- (void)signalSubscribe{
    [[[self.userName rac_textSignal]filter:^BOOL(NSString* value) {
        //        NSLog(@"value:%@",value);
        if (value.length>5) {
            return NO;
        }
        return YES;
    }]subscribeNext:^(id x) {
        NSLog(@"x=%@",x);
    }];
}

//信号转化
- (void)signalMap{
    @weakify(self);
    
    [[[[self.userName rac_textSignal]map:^id(NSString*  value) {
      
      if (value.length>5) {
          value = @"爱礼";
      }
      return value;
    }]filter:^BOOL(id value) {
      
      return YES;
  }]subscribeNext:^(id x) {
      @strongify(self);
      self.userName.text = x;
      self.displayLabel.text = x;
      
  }];

}
///信号过滤
- (void)signalFilter
{
    [[[self.userName rac_textSignal]filter:^BOOL(NSString* value) {
        //        NSLog(@"value:%@",value);
        if (value.length>5) {
            return NO;
        }
        return YES;
    }]subscribeNext:^(id x) {
        NSLog(@"x=%@",x);
    }];
}

//信号合并
- (void)signalCombine{

    RACSignal *userNameSignal = [self.userName rac_textSignal];
    RACSignal *passwordNameSignal = [self.password rac_textSignal];
    
    RAC(self.login,enabled) = [RACSignal combineLatest:@[userNameSignal,passwordNameSignal] reduce:^id(NSString*useName,NSString*password){
        //返回一个对象
        return @(useName.length>5 &&password.length >5);
    }];
    [[self.login rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        NSLog(@"登陆按钮被点击了");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
