//
//  sphProtocol.m
//  Sph
//
//  Created by 青天揽月1 on 2020/3/18.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import "sphProtocol.h"
#import <UIKit/UIKit.h>
#import "DbManager.h"

@interface UrlCacheConfig: NSObject

@property (readwrite, nonatomic, strong) NSMutableDictionary *urlDict;//记录上一次url请求时间
@property (readwrite, nonatomic, assign) NSInteger updateInterval;//相同的url地址请求，相隔大于等于updateInterval才会发出后台更新的网络请求，小于的话不发出请求。
@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *config;//config是全局的，所有的网络请求都用这个config
@property (readwrite, nonatomic, strong) NSOperationQueue *forgeroundNetQueue;
@property (readwrite, nonatomic, strong) NSOperationQueue *backgroundNetQueue;

@end

#define DefaultUpdateInterval 3600
@implementation UrlCacheConfig


- (NSInteger)updateInterval{
    if (_updateInterval == 0) {
        //默认后台更新的时间为3600秒
        _updateInterval = DefaultUpdateInterval;
    }
    return _updateInterval;
}

- (NSURLSessionConfiguration *)config{
    if (!_config) {
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return _config;
}

- (NSMutableDictionary *)urlDict{
    if (!_urlDict) {
        _urlDict = [NSMutableDictionary dictionary];
    }
    return _urlDict;
}

- (NSOperationQueue *)forgeroundNetQueue{
    if (!_forgeroundNetQueue) {
         _forgeroundNetQueue = [[NSOperationQueue alloc] init];
        _forgeroundNetQueue.maxConcurrentOperationCount = 10;
    }
    return _forgeroundNetQueue;
}

- (NSOperationQueue *)backgroundNetQueue{
    if (!_backgroundNetQueue) {
        _backgroundNetQueue = [[NSOperationQueue alloc] init];
        _backgroundNetQueue.maxConcurrentOperationCount = 6;
    }
    return _backgroundNetQueue;
}

+ (instancetype)instance{
    static UrlCacheConfig *urlCacheConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        urlCacheConfig = [[UrlCacheConfig alloc] init];
    });
    return urlCacheConfig;
}

- (void)clearUrlDict{
    [UrlCacheConfig instance].urlDict = nil;
}

@end

static NSString * const URLProtocolAlreadyHandleKey = @"alreadyHandle";
static NSString * const checkUpdateInBgKey = @"checkUpdateInBg";

@interface sphProtocol()

@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSMutableData *data;
@property (readwrite, nonatomic, strong) NSURLResponse *response;

@end

@implementation sphProtocol
+ (void)startListeningNetWorking{
    [NSURLProtocol registerClass:[sphProtocol class]];
}

+ (void)cancelListeningNetWorking{
    [NSURLProtocol unregisterClass:[sphProtocol class]];
}

+ (void)setConfig:(NSURLSessionConfiguration *)config{
    [[UrlCacheConfig instance] setConfig:config];
}

+ (void)setUpdateInterval:(NSInteger)updateInterval{
    [[UrlCacheConfig instance] setUpdateInterval:updateInterval];
}

+ (void)clearUrlDict{
    [[UrlCacheConfig instance] clearUrlDict];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    NSString *urlScheme = [[request URL] scheme];
    if ([urlScheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [urlScheme caseInsensitiveCompare:@"https"] == NSOrderedSame){
        //判断是否标记过使用缓存来处理，或者是否有标记后台更新
        if ([NSURLProtocol propertyForKey:URLProtocolAlreadyHandleKey inRequest:request] || [NSURLProtocol propertyForKey:checkUpdateInBgKey inRequest:request]) {
            NSLog(@"缓存数据");
            return NO;
        }
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    return request;
}

- (void)backgroundCheckUpdate{
    __weak typeof(self) weakSelf = self;
    [[[UrlCacheConfig instance] backgroundNetQueue] addOperationWithBlock:^{
        NSDate *updateDate = [[UrlCacheConfig instance].urlDict objectForKey:weakSelf.request.URL.absoluteString];
        if (updateDate) {
            //判读两次相同的url地址发出请求相隔的时间，如果相隔的时间小于给定的时间，不发出请求。否则发出网络请求
            NSDate *currentDate = [NSDate date];
            NSInteger interval = [currentDate timeIntervalSinceDate:updateDate];
            if (interval < [UrlCacheConfig instance].updateInterval) {
                return;
            }
        }
        NSMutableURLRequest *mutableRequest = [[weakSelf request] mutableCopy];
        [NSURLProtocol setProperty:@YES forKey:checkUpdateInBgKey inRequest:mutableRequest];
        [weakSelf netRequestWithRequest:mutableRequest];

    }];
}

- (void)netRequestWithRequest:(NSURLRequest *)request{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[UrlCacheConfig instance].forgeroundNetQueue];
    NSURLSessionDataTask * sessionTask = [self.session dataTaskWithRequest:request];
    [[UrlCacheConfig instance].urlDict setValue:[NSDate date] forKey:self.request.URL.absoluteString];
    [sessionTask resume];
}


- (void)startLoading{
    NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:[self request]];
    if (urlResponse) {
        //如果缓存存在，则使用缓存。并且开启异步线程去更新缓存
        [self.client URLProtocol:self didReceiveResponse:urlResponse.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:urlResponse.data];
        [self.client URLProtocolDidFinishLoading:self];
        [self backgroundCheckUpdate];
        return;
    }
    NSMutableURLRequest *mutableRequest = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:URLProtocolAlreadyHandleKey inRequest:mutableRequest];
    [self netRequestWithRequest:mutableRequest];
}

- (void)stopLoading{
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (BOOL)isUseCache{
    //如果有缓存则使用缓存，没有缓存则发出请求
    NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:[self request]];
    if (urlResponse) {
        return YES;
    }
    return NO;
}

- (void)appendData:(NSData *)newData{
    if ([self data] == nil) {
        [self setData:[newData mutableCopy]];
    }
    else {
        [[self data] appendData:newData];
    }
}
#pragma mark -NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.client URLProtocol:self didLoadData:data];
    
    [self appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    self.response = response;
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        if (!self.data) {
            NSData *mockData = [[DbManager sharedAdapter] getMockDta:task.originalRequest.URL.absoluteString];
            if (mockData) {
                self.data = [mockData mutableCopy];
                NSURLResponse *resp = [[NSURLResponse alloc]initWithURL:task.originalRequest.URL MIMEType:@"text/json" expectedContentLength:self.data.length textEncodingName:@""];
                self.response = resp;
                [self.client URLProtocol:self didReceiveResponse:resp cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                [self.client URLProtocol:self didLoadData:self.data];
                [self.client URLProtocolDidFinishLoading:self];
                NSCachedURLResponse *cacheUrlResponse = [[NSCachedURLResponse alloc] initWithResponse:resp data:self.data];
                [[NSURLCache sharedURLCache] storeCachedResponse:cacheUrlResponse forRequest:self.request];
                self.data = nil;
                return;
            }else{
                NSLog(@"请配置mock数据");
            }
        }
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
        if (!self.data) {
            return;
        }
        NSCachedURLResponse *cacheUrlResponse = [[NSCachedURLResponse alloc] initWithResponse:task.response data:self.data];
        [[NSURLCache sharedURLCache] storeCachedResponse:cacheUrlResponse forRequest:self.request];
        self.data = nil;
    }
}
@end
