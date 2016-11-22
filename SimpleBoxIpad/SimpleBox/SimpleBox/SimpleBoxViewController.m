//
//  SimpleBoxViewController.m
//  SimpleBox
//
//  Created by fnst001 on 12/3/15.
//  Copyright (c) 2015 FUJISTU. All rights reserved.
//

#import "SimpleBoxViewController.h"
#import "SimpleBoxPageControl.h"
#import "SimpleBoxHandler.h"
#import "Reachability.h"
#import "SimpleBoxACSeatViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define SCROLLIEWHEIGHT           512
#define PAGECONTROLHEIGHT         40
#define PAGECONTROLYLENGTH        678
#define CONNECTIONMAXNUM          5
#define WIFIALERT                 100
#define BLUETOOTHALERT            101

@interface SimpleBoxViewController ()<UIScrollViewDelegate,SimpleBoxPageControlDelegate,CBPeripheralManagerDelegate,SimpleBoxHanderDelegate,UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) Reachability *wifiReach;
@property (strong, nonatomic) SimpleBoxPageControl *pageControl;
@property (strong, nonatomic) SimpleBoxHandler *handler;
@property (strong, nonatomic) CBPeripheralManager *manager;
@property (assign, nonatomic) NSInteger connectionMaxNum;
@property (assign, nonatomic) BOOL isConnectToBox;
@property (assign, nonatomic) BOOL wifiConnected;
@property (assign, nonatomic) BOOL bluetoothConnected;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *myView;
@property (strong, nonatomic) IBOutlet UILabel *connectToBox;
@property (strong, nonatomic) IBOutlet UIImageView *wifl;
@property (strong, nonatomic) IBOutlet UIImageView *bluetooth;
@property (strong, nonatomic) IBOutlet UIButton *parameterButton;

- (IBAction)onClick:(UIButton*)sender;
@end

@implementation SimpleBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverseStatus:) name:@"ReverseStatusNotification" object:nil];

    self.handler = [SimpleBoxHandler sharedInstance];
    _handler.delegate = self;
    self.connectionMaxNum = 0;
    self.isConnectToBox = YES;
    self.wifiConnected = YES;
    self.bluetoothConnected = NO;
    [self createScrollView];
    [self createPageControl];
    [self checkWifiConnect];
    self.manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
   if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
   {
       [_connectToBox setFont:[UIFont systemFontOfSize:16]];
   }
    else
    {
        [_connectToBox setFont:[UIFont systemFontOfSize:26]];
    }
    
    [_connectToBox setTextColor:[UIColor whiteColor]];
    [self updateConnectToBoxLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.pageControl.currentPage = offset.x/screenSize.width;
}

#pragma mark CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
        {
            self.bluetoothConnected = YES;
            [self.bluetooth setImage:[UIImage imageNamed:@"bluetooth.png"]];
            [self updateConnectToBoxLabel];
        }
            break;
            
        default:
        {
            self.bluetoothConnected = NO;
            [self.bluetooth setImage:[UIImage imageNamed:@"bluetooth未连接.png"]];
            [self updateConnectToBoxLabel];
        [self showAlertView:@"蓝牙未打开" message:@"请打开你的蓝牙" tag:BLUETOOTHALERT cancelTitle:@"取消" otherButtonTitles:@"设置"];
        }
            break;
    }
}

#pragma  mark -- SimpleBoxHanderDelegate
- (void)connectBoxResult:(BOOL)connected
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _connectionMaxNum++;
        if (!connected) {
            if (_connectionMaxNum < CONNECTIONMAXNUM) {
                 self.isConnectToBox = NO;
                [_handler connectBox:BOXIP withPort:BOXPORT];
            }else{
                self.isConnectToBox = NO;
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isConnectToBox = YES;
            });
        }
    });
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == WIFIALERT) {
        if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }else if(alertView.tag == BLUETOOTHALERT){
        if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:@"prefs:root=General&path=BlueTooth"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

#pragma mark    privateFunction

- (IBAction)onClick:(UIButton*)sender {
//    [self connectBoxResult:_wifiConnected];
    switch (sender.tag) {
        case 1:
            [self openMusic];
            break;
        case 2:
            [self openFMRadio];
            break;
        case 3:
            [self openAmap];
            break;
        case 4:
        {
            if (!_wifiConnected) {
                [self showAlertView:@"wifi未连接" message:@"请检查你的wifi连接状况" tag:WIFIALERT cancelTitle:@"取消" otherButtonTitles:@"设置"];
                return;
            }
            
            if (!_isConnectToBox) {
                [self showAlertView:@"通信异常" message:@"请检查你的网络和盒子的状况" tag:102 cancelTitle:@"OK" otherButtonTitles:nil];
                return;
            }
            [self showSimpleBoxACSeatViewController];
        }
            break;
        case 5:
            [self openTelPhone];
            break;
        case 6:
        {
            if (!_wifiConnected) {
                [self showAlertView:@"wifi未连接" message:@"请检查你的wifi连接状况" tag:WIFIALERT cancelTitle:@"取消" otherButtonTitles:@"设置"];
                return;
            }
            
            if (!_isConnectToBox) {
                [self showAlertView:@"通信异常" message:@"请检查你的网络和盒子的状况" tag:103 cancelTitle:@"OK" otherButtonTitles:nil];
                return;
            }
            [self openCarHousekeeper];
        }
           
            break;
        case 7:
            [self openWifi];
            break;
        case 8:
            if (!_wifiConnected) {
                [self showAlertView:@"wifi未连接" message:@"请检查你的wifi连接状况" tag:WIFIALERT cancelTitle:@"取消" otherButtonTitles:@"设置"];
                return;
            }
            
            if (!_isConnectToBox) {
                [self showAlertView:@"通信异常" message:@"请检查你的网络和盒子的状况" tag:103 cancelTitle:@"OK" otherButtonTitles:nil];
                return;
            }
            [self openBackCarApplication];
            break;
    }
}

- (void)showSimpleBoxACSeatViewController
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        SimpleBoxACSeatViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"iphoneView2"];
        [self presentViewController:viewController animated:YES completion:^{
            NSLog(@"load SimpleBoxACSeatViewController successs");
        }];
    }
    else
    {
        SimpleBoxACSeatViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"simpleBoxACSeatViewController"];
        [self presentViewController:viewController animated:YES completion:^{
            NSLog(@"load SimpleBoxACSeatViewController successs");
        }];
    }

}

- (void)updateScrollView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [_scrollView scrollRectToVisible:CGRectMake(screenSize.width*_pageControl.currentPage, 0, screenSize.width, SCROLLIEWHEIGHT) animated:YES];
}

- (void)createScrollView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.scrollView.contentSize = CGSizeMake(screenSize.width*3, 150);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(screenSize.width*3, SCROLLIEWHEIGHT);
    }
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;

}

- (void)createPageControl
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.pageControl = [[SimpleBoxPageControl alloc] initWithFrame:CGRectMake(0, 378, screenSize.width, 40)];
        _pageControl.controlSize = 18;
    }
    else
    {
        self.pageControl = [[SimpleBoxPageControl alloc] initWithFrame:CGRectMake(0, PAGECONTROLYLENGTH, screenSize.width, PAGECONTROLHEIGHT)];
        _pageControl.controlSize = 26;
    }
    _pageControl.numberOfPages = 3;
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
        [self showAlertView:@"wifi未连接" message:@"请检查你得wifi连接状况" tag:WIFIALERT cancelTitle:@"取消" otherButtonTitles:@"设置"];
        self.wifl.image = [UIImage imageNamed:@"wifi未连接.png"];
        _handler.isConnected = NO;
        _isConnectToBox = NO;
        self.wifiConnected = NO;
        [self updateConnectToBoxLabel];
    }else if(status == ReachableViaWiFi){
        self.wifl.image = [UIImage imageNamed:@"wifi.png"];
        self.wifiConnected = YES;
        [self updateConnectToBoxLabel];
        if (!_handler.isConnected) {
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


- (void)showAlertView:(NSString *)title message:(NSString *)message tag:(long)alertTag cancelTitle:(NSString *)cancel otherButtonTitles:(NSString *)otherButton
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancel
                                              otherButtonTitles:otherButton,nil];
    alertView.tag = alertTag;
    [alertView show];
}


- (void)openWifi
{
    NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)openAmap
{
    NSURL *url = [NSURL URLWithString:@"iosamap://"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }

}
- (void)openCarHousekeeper
{
    NSString *urlStr = [NSString stringWithFormat:@"szly.simpleBOX://?wifiStatus=%d&bluetoothStatus=%d",(int)self.wifiConnected ,(int)self.bluetoothConnected];
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }

}

- (void)openMusic
{
    NSURL *url = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        url  = [NSURL URLWithString:@"com.kuwo.kwmusic.kwmusicForKwsing://"];
    }else{
        url = [NSURL URLWithString:@"sinaweibosso.2972927130://"];
        
    }   
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)openFMRadio
{
    NSURL *url = [NSURL URLWithString:@"iting://"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }

}
- (void)openTelPhone
{
   
    NSURL *url = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        url  = [NSURL URLWithString:@"wetalkpro://"];
    }else{
        url = [NSURL URLWithString:@"wetalkpro://"];
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)openWiFiviewer
{
//    NSURL *url = [NSURL URLWithString:@""];
//    if ([[UIApplication sharedApplication] canOpenURL:url]) {
//        [[UIApplication sharedApplication] openURL:url];
//    }
    BOOL rsq = [self.handler sendReverseStatusNotificationRsp];
    if (!rsq) {
        NSLog(@"发送响应失败");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_alertView == nil) {
            self.alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"倒车应用正在开发中..."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
            [_alertView show];
        }else{
            [_alertView show];
        }
    });
}

- (void)openBackCarApplication
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"倒车应用正在开发中..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
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

- (void)reverseStatus:(NSNotification *)notify
{
//    ReverseStatusNotification *acParameter = [notify object];
//    if ([acParameter hasNReverseStatus]) {
//        [self openWiFiviewer];
//    }
}
@end


