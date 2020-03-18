//
//  MockDataManager.m
//  Sph
//
//  Created by 青天揽月1 on 2020/3/18.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import "MockDataManager.h"
#import "DbManager.h"

@implementation MockDataManager
static MockDataManager *_mockManager;
static dispatch_once_t onceToken;
+ (MockDataManager *)sharedAdapter {
    dispatch_once(&onceToken, ^{
        _mockManager = [[MockDataManager alloc]init];
    });
    return _mockManager;
}
- (NSMutableArray *)mockData {
    if (!_mockData) {
        _mockData = [NSMutableArray new];
    }
    return _mockData;
}

- (void)start {
    NSString * path = @"https://data.gov.sg/api/action/datastore_search?resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f";
    NSString *mockDataName = @"MockData";
    if (mockDataName.length) {
        NSDictionary * dict = @{path:mockDataName};
        if (dict) {
            [self.mockData addObject:dict];
        }
    }
}
@end
