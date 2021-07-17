//
//  FSZoomViewController.m
//  FS
//
//  Created by L on 2021/7/5.
//  Copyright © 2021 mac. All rights reserved.
//

#import "FSZoomViewController.h"
#import <WebKit/WebKit.h>
//#import "FSZoomTokenModel.h"
//#import "FSZoomDetailModel.h"
//#import <MobileRTC/MobileRTC.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPSessionManager.h>


#define Client_ID @"0jT1EMK8QqayE6fRrugX4Q"
#define Client_Secret @"zRDdUMM90pjIi63Hr9NZEW8so8fm7Nxi"

@interface FSZoomViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSString *code;

@property (nonatomic, strong) NSString *access_token;

//@property (nonatomic, strong) FSZoomTokenModel *tokenModel;

//@property (nonatomic, strong) FSZoomDetailModel *detailModel;


@end

@implementation FSZoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
    // https://zoom.us/oauth/authorize?client_id=ufsOEtWJTJ2HCqqEncErtg&response_type=code&redirect_uri=http%3A%2F%2Fnew-project.whgxwl.com%3A6060%2Froom.php
    // https://zoom.us/j/6858021495?pwd=WGxPTW1ab1M3WldleXlTczM5ZjlzZz09
    
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://zoom.us/oauth/authorize?client_id=0jT1EMK8QqayE6fRrugX4Q&response_type=code&redirect_uri=http://new-project.whgxwl.com:6060/room.php"]]];


    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"菜单" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
}

- (void)rightButtonClick {

    if (self.access_token != nil) {
//        [self getPersonalZak];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"authorization_code" forKey:@"grant_type"];
    [params setValue:self.code forKey:@"code"];
    [params setValue:@"http://new-project.whgxwl.com:6060/room.php" forKey:@"redirect_uri"];
    
    NSString *base64 = [self base64];
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", base64];

    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    [manager POST:@"https://zoom.us/oauth/token" parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.access_token = responseObject[@"access_token"];
        
        NSLog(@"");
        [self createMeeting];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    

    
    
}

//// 获取个人信息
//- (void)getPersonalInfo {
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//
//    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", self.access_token];
//
//    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
//
//
//    [manager GET:@"https://api.zoom.us/v2/users/me" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSLog(@"%@", responseObject);
//
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];
//}
//
//// 获取个人信息
//- (void)getPersonalZak {
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//
//    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", self.access_token];
//
//    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
//
//
//    [manager GET:@"https://api.zoom.us/v2/users/me/zak" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSLog(@"%@", responseObject);
//        [self getPassword:responseObject[@"token"]];
//
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];
//}
//
// 创建会议
- (void)createMeeting {
    
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
        [params setValue:@"测试会议" forKey:@"topic"];
        [params setValue:@"2" forKey:@"type"];
        [params setValue:@"2021-07-9T18:00:00" forKey:@"start_time"];
        [params setValue:@(10) forKey:@"duration"];
    //    [params setValue:@"1234567" forKey:@"schedule_for"];
        [params setValue:@"Asia/Shanghai" forKey:@"timezone"];
    
        [params setValue:@"1234567" forKey:@"password"];
    
    
        NSString *authorization = [NSString stringWithFormat:@"Bearer %@", self.access_token];
    
        [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
        NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"https://api.zoom.us/v2/users/me/meetings" parameters:params error:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSLog(@"-----responseObject===%@+++++",responseObject);
            if (!error) {

    //            self.detailModel = [FSZoomDetailModel mj_objectWithKeyValues: responseObject];
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    // 请求成功数据处理
    
                } else {
    
                }
    
            } else {
                NSLog(@"请求失败error=%@", error);
            }
        }];
    
        [task resume];
    
}


//
//// 获取个人密码
//- (void)getPassword:(NSString *)zak {
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//
//    [params setValue:@"测试会议" forKey:@"topic"];
//    [params setValue:@"2" forKey:@"type"];
//    [params setValue:@"2021-07-6T18:00:00" forKey:@"start_time"];
//    [params setValue:@(10) forKey:@"duration"];
////    [params setValue:@"1234567" forKey:@"schedule_for"];
//    [params setValue:@"Asia/Shanghai" forKey:@"timezone"];
//
//    [params setValue:@"1234567" forKey:@"password"];
//
//
//    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", self.access_token];
//
//    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//
//    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"https://api.zoom.us/v2/users/me/meetings" parameters:params error:nil];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
//
//    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"-----responseObject===%@+++++",responseObject);
//        if (!error) {
//
////            self.detailModel = [FSZoomDetailModel mj_objectWithKeyValues: responseObject];
//            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                // 请求成功数据处理
//
//            } else {
//
//            }
////
////            MobileRTCMeetingService *meetingService = [[MobileRTC sharedRTC] getMeetingService];
//////
////            MobileRTCMeetingJoinParam *joinMeetingParameters = [[MobileRTCMeetingJoinParam alloc]init];
////            joinMeetingParameters.meetingNumber = self.detailModel.zoomId;
////            joinMeetingParameters.password = self.detailModel.password;
////            joinMeetingParameters.zak = zak;
//////
////            [meetingService joinMeetingWithJoinParam:joinMeetingParameters];
////
//
//        } else {
//            NSLog(@"请求失败error=%@", error);
//        }
//    }];
//
//    [task resume];
//}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"=======%@", navigationAction.request.URL);
    NSString *query = navigationAction.request.URL.query;
    
    if ([query hasPrefix:@"code"]) {
        NSArray *array = [navigationAction.request.URL.query componentsSeparatedByString:@"="];
        if (array.count == 2) {
            self.code = array[1];
        }
    }
    
    if (navigationAction.navigationType == WKNavigationTypeFormSubmitted) {
        if (navigationAction.request.URL != nil) {
            NSLog(@"=======%@", navigationAction.request.URL);
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}


//MARK:- Lazy
- (WKWebView *)webView {
    if (_webView == nil) {
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _webView.navigationDelegate = self;
    }
    return _webView;
}


- (NSString *)base64 {
    NSString *str = [NSString stringWithFormat:@"%@:%@",Client_ID, Client_Secret];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Str = [data base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
    return base64Str;
//    NSString *base64DecodeStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


@end
