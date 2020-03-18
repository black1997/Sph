//
//  DbManager.h
//  Sph
//
//  Created by 青天揽月1 on 2020/3/5.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface DbManager : NSObject
/*单利模式*/
+ (DbManager *)sharedAdapter;

@property (nonatomic,assign)BOOL useMockData;

/*保存数据*/
- (BOOL)saveData:(NSArray*)data;

- (NSArray *)getLocalData;

- (NSDictionary *)getMockDataForNSDictionary;
/*
 * 实际开发使用配置文件、在配置文件中添加接口地址和对应mock数据
 */
- (NSData *)getMockDta:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
