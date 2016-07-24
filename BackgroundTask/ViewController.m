//
//  ViewController.m
//  BackgroundTask
//
//  Created by Shingo Hiraya on 7/24/16.
//  Copyright © 2016 Shingo Hiraya. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) NSInteger count;

// A unique token that identifies a request to run in the background.
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareNotifications];
}

#pragma mark - private

- (void)countTwenty
{
    self.count = 0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(update)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)update
{
    self.count++;
    
    if (self.count > 20) {
        [self.timer invalidate];
        
        // タスクが完了したら、トークンを引数として endBackgroundTask: メソッドを実行し、その旨をシステムに伝える
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        
        return;
    }
    
    // 残り時間
    NSLog(@"[%@] backgroundTimeRemaining:%@", @(self.count), @([UIApplication sharedApplication].backgroundTimeRemaining));
}

- (void)prepareNotifications
{
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(willResignActive:)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didBecomeActive:)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
}

- (void)willResignActive:(NSNotification *)notification
{
    NSLog(@"willResignActive");
    
    UIApplication *application = notification.object;
    
    // 追加の実行時間を要求する
    // self.backgroundTaskIdentifier: 当該タスクに対応する一意的なトークン
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        // 時間切れハンドラ
        // タスクを終了するために必要なコードを追加できる
        // 長時間を要する処理は実行できない
        // 時間切れハンドラが呼び出された時点で、すでにアプリケーションの時間切れが迫っているから
        // このため、状態情報の最小限のクリーンアップを実行してタスクを終了する
        
        // クリーンアップ処理を実行
        // ...
        
        // トークンを引数として endBackgroundTask: メソッドを実行し、その旨をシステムに伝える
        [application endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
    
    // 実行に時間のかかるタスクを実行する
    [self countTwenty];
}

- (void)didBecomeActive:(NSNotification *)notification
{
    NSLog(@"didBecomeActive");
    
    UIApplication *application = notification.object;
    [application endBackgroundTask:self.backgroundTaskIdentifier];
}

@end
