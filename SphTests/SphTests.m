//
//  SphTests.m
//  SphTests
//
//  Created by 青天揽月1 on 2020/3/5.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AFNetworking.h"
#import "DbManager.h"

#define WAIT do {\
[self expectationForNotification:@"RSBaseTest" object:nil handler:nil];\
[self waitForExpectationsWithTimeout:30 handler:nil];\
} while (0);

#define NOTIFY \
[[NSNotificationCenter defaultCenter]postNotificationName:@"RSBaseTest" object:nil];

@interface SphTests : XCTestCase

@end

@implementation SphTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testDB1 {
    NSDictionary *dict = @{@"_id":@(100),
                           @"quarter":@"2020-Q1",
                           @"volume_of_mobile_data":@"20.53504752"
    };
    NSDictionary *dict1 = @{@"_id":@(101),
                           @"quarter":@"2020-Q2",
                           @"volume_of_mobile_data":@"20.53504752"
    };
    NSArray * tem = @[dict,dict1];
    BOOL result = [[DbManager sharedAdapter] saveData:tem];
    XCTAssertTrue(result, @"插入数据");
}
- (void)testDB2{
    NSArray *tem = [[DbManager sharedAdapter] getLocalData];
    XCTAssertNotNil(tem, @"本地数据出错");
}

-(void)testRequest{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = @"https://data.gov.sg/api/action/datastore_search?resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f";
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        XCTAssertNotNil(responseObject, @"返回出错");
        NOTIFY //继续执行
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
        XCTAssertNil(error, @"请求出错");
        NOTIFY //继续执行
    }];
    WAIT  //暂停
}
@end
