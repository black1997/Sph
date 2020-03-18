//
//  MockDataManager.h
//  Sph
//
//  Created by 青天揽月1 on 2020/3/18.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MockDataManager : NSObject
/*单利模式*/
+ (MockDataManager *)sharedAdapter;
@property (nonatomic,strong)NSMutableArray *mockData;
- (void)start;
@end

NS_ASSUME_NONNULL_END
