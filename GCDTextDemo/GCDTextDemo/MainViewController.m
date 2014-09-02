//
//  MainViewController.m
//  GCDTextDemo
//
//  Created by jiawei on 14-9-1.
//  Copyright (c) 2014年 eliteworkltd. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

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


    //GCD多线程方式
    [self GCDwaysOne];
    [self GCDwaysTwo];
    [self GCDwaysThree];
    
    //NSOperation、NSOperationQueue多线程方式
    [self OperationOne];
    
    //NSThread创建线程
    [self ThreadOne];
}

#pragma mark - 系统方法的GCD
//系统方法的GCD
/*
 dispatch_async开启一个异步请求
 第一个参数是指定一个gcd队列，第二个参数是分配一个处理事物的程序块到该队列
 dispatch_get_global_queue指定为全局队列
 第一个参数是分配事物处理程序的块队列优先级。
 #define DISPATCH_QUEUE_PRIORITY_HIGH     2
 #define DISPATCH_QUEUE_PRIORITY_DEFAULT  0
 #define DISPATCH_QUEUE_PRIORITY_LOW     (-2)
 */
- (void)GCDwaysOne{
    //后台执行
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //something
    });
    
    //主线程执行
    dispatch_async(dispatch_get_main_queue(), ^{
        //something
    });
    
    //一次性执行
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //something
    });
    
    //延迟1秒执行
    double delayOne = 1.0;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delayOne * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        
    });
}

#pragma mark - 自定义dispatch_queue_t
- (void)GCDwaysTwo{
    //自定义的dispatch_queue_t
    dispatch_queue_t url_queue = dispatch_queue_create("something", NULL);
    dispatch_async(url_queue, ^{
        //something
    });
    //非arc下需要释放
    //dispatch_release(url_queue);
}

#pragma mark - 后台多线程并发
/*
 异步和并发的不同点：
 异步只是提供了一种多线程处理的概念，
 并发是更像是异步的一种大规模实现
 */
- (void)GCDwaysThree{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //并行执行的线程一
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //并行执行的线程二
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        //汇总结果
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 NSOperationQueue 是建立一个线程管理器，建立过程：
 建立NSOperationQueue对象→建立NSOperation对象→将NSOperation对象加入到队列中→release掉NSOperation对象(非ARC下)
 NSOperation对象通过NSInvocationOperation类建立，是NSOperation的子类
 
 NSOperationQueue通过setMaxConcurrentOperationCount方法设定队列中线程的个数
 */
- (void)OperationOne{
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doSomething:) object:@"传的参数是个字符串"];
    [queue addOperation:operation];
//    [operation release];
}

#pragma mark - 运行在另外一个线程的“方法”
- (void)doSomething:(NSString *)string{
    NSLog(@"%@",string);
}
/*
 NSThread方式进行多线程操作时，多个线程时必须上锁NSLock，在一个线程完成操作后解锁[theLock unlock];
 通过NSCondition的signal方法，发送信号的方式，在这个线程中唤醒另外一个线程的等待
 */
- (void)ThreadOne{
    [NSThread detachNewThreadSelector:@selector(doSomething2:) toTarget:self withObject:@"这里传的是参数"];
    
}

- (void)ThreadTwo{
    NSThread *myThread = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething2:) object:@"参数"];
    [myThread start];
}

- (void)doSomething2:(NSString *)string{
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
}

#pragma mark - 所有自己创建的线程都不能对UI进行操作
- (void)updateUI{
    //更新UI操作
}

@end
