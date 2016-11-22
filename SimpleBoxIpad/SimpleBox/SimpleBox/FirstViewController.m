//
//  FirstViewController.m
//  SimpleBox
//
//  Created by fnst1 on 15/12/11.
//  Copyright © 2015年 FUJISTU. All rights reserved.
//

#import "FirstViewController.h"
#import "SimpleBoxPageControl.h"
#import "SimpleBoxHandler.h"
#import "Reachability.h"
#import "SimpleBoxACSeatViewController.h"
#import "SecondViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define BOXIP                     @"192.168.2.15"
#define BOXPORT                   1234
#define SCROLLIEWHEIGHT         314
#define PAGECONTROLHEIGHT       40
#define PAGECONTROLYLENGTH      360
#define CONNECTIONMAXNUM        5
@interface FirstViewController ()<UIScrollViewDelegate,SimpleBoxPageControlDelegate,CBCentralManagerDelegate,SimpleBoxHanderDelegate>
@property (strong, nonatomic) Reachability *wifiReach;
@property (strong, nonatomic) SimpleBoxPageControl *pageControl;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) SimpleBoxHandler *handler;
@property (assign, nonatomic) NSInteger connectionMaxNum;
@property (assign, nonatomic) BOOL isConnectToBox;
@property (assign, nonatomic) BOOL wifiConnected;
@property (assign, nonatomic) BOOL bluetoothConnected;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *myView;
@property (strong, nonatomic) IBOutlet UILabel *connectToBox;
@property (strong, nonatomic) IBOutlet UIImageView *wifl;
@property (strong, nonatomic) IBOutlet UIImageView *bluetooth;
@property (strong, nonatomic) IBOutlet UIButton *parameterButton;

- (IBAction)onClick:(UIButton*)sender;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"width---%f height---%f",[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    
    self.handler = [SimpleBoxHandler sharedInstance];
    _handler.delegate = self;
    
    self.connectionMaxNum = 0;
    self.isConnectToBox = NO;
    self.wifiConnected = NO;
    self.bluetoothConnected = NO;
    [self createScrollView];
    [self createPageControl];
    [self checkWifiConnect];
    
    [_connectToBox setFont:[UIFont systemFontOfSize:16]];
    [_connectToBox setTextColor:[UIColor whiteColor]];
    [self updateConnectToBoxLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.pageControl.currentPage = offset.x/screenSize.width;
}

#pragma mark -- CBCentralManagerDelegate

- (void)centralManagerDidUpdate567State:(CBCentralManager *)central
{
    switch (central.state) {
        case 4:
            [self showAlertView:@"蓝牙连接状态" message:@"请打开你得蓝牙"];
        case 5:
            [_bluetooth setImage:[UIImage imageNamed:@"bluetooth"]];
            break;
            
    }
}

#pragma  mark -- SimpleBoxHanderDelegate
- (void)connectBoxResult:(BOOL)connected
{
    _connectionMaxNum++;
    if (!connected) {
        if (_connectionMaxNum < CONNECTIONMAXNUM) {
            [_handler connectBox:BOXIP withPort:BOXPORT];
        }else{
            self.isConnectToBox = NO;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self showAlertView:@"连接盒子失败" message:@"连接盒子失败请检查您的网络状况"];
            });
        }
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.isConnectToBox = YES;
        });
    }
    
    
    
}

#pragma mark    privateFunction

- (IBAction)onClick:(UIButton*)sender {
    NSLog(@"asdf");
    switch (sender.tag) {
        case 1:
            [self showOtherApp];
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            NSLog(@"44444");
            [self showSimpleBoxACSeatViewController];
            break;
        case 5:
            break;
        case 6:
            break;
        case 7:
            break;
        case 8:
            break;
    }
}

- (void)showSimpleBoxACSeatViewController
{
    SecondViewController *sec = [[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil];
    [self presentViewController:sec animated:YES completion:nil];
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    SimpleBoxACSeatViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"simpleBoxACSeatViewController"];
//    [self presentViewController:viewController animated:YES completion:^{
//        NSLog(@"load SimpleBoxACSeatViewController successs");
//    }];
}

- (void)updateScrollView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [_scrollView scrollRectToVisible:CGRectMake(screenSize.width*_pageControl.currentPage, 0, screenSize.width, SCROLLIEWHEIGHT) animated:YES];
}

- (void)createScrollView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.scrollView.contentSize = CGSizeMake(screenSize.width*3, SCROLLIEWHEIGHT);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
}

- (void)createPageControl
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.pageControl = [[SimpleBoxPageControl alloc] initWithFrame:CGRectMake(0, PAGECONTROLYLENGTH, screenSize.width, PAGECONTROLHEIGHT)];
    _pageControl.numberOfPages = 3;
    _pageControl.controlSize = 18;
    _pageControl.currentColor = [UIColor redColor];
    _pageControl.controlSpacing = 27.5;
    _pageControl.otherColour = [UIColor greenColor];
    _pageControl.delegate = self;
    _pageControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_pageControl];
}


- (void)checkNetworkStatus:(NetworkStatus)status
{
    if (status == NotReachable) {
        [self showAlertView:@"wifi未连接" message:@"请连接wifi"];
        self.wifl.image = [UIImage imageNamed:@"wifi未连接.png"];
        self.isConnectToBox = NO;
        self.wifiConnected = NO;
        [self updateConnectToBoxLabel];
    }else if(status == ReachableViaWiFi){
        self.wifl.image = [UIImage imageNamed:@"wifi.png"];
        self.wifiConnected = YES;
        [self updateConnectToBoxLabel];
        if (!_isConnectToBox) {
            [_handler connectBox:BOXIP withPort:BOXPORT];
        }
    }
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability* curReach = [notification object];
    NetworkStatus status = [curReach currentReachabilityStatus];
    [self checkNetworkStatus:status];
}


- (void)checkWifiConnect
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self checkNetworkStatus:_wifiReach.currentReachabilityStatus];
    [_wifiReach startNotifier];
}

- (void)showAlertView:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)showOtherApp
{
    NSURL *url = [NSURL URLWithString:@"myApps://"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        NSLog(@"can open %@",url);
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)updateConnectToBoxLabel
{
    if (!_wifiConnected && !_bluetoothConnected) {
        self.connectToBox.text = @"未连接";
    }else if(!_bluetoothConnected){
        self.connectToBox.text = @"蓝牙未连接";
    }else if(!_wifiConnected){
        self.connectToBox.text = @"wifi未连接";
    }else{
        self.connectToBox.text = @"已连接";
    }
}
@end
