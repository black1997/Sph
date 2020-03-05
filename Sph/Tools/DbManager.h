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

/*保存数据*/
- (BOOL)saveData:(NSArray*)data;

- (NSArray *)getLocalData;
@end

NS_ASSUME_NONNULL_END
