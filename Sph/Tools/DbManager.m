//
//  DbManager.m
//  Sph
//
//  Created by 青天揽月1 on 2020/3/5.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import "DbManager.h"

@interface DbManager(){
    FMDatabase *_db;
}
@property (nonatomic,strong) NSString *filePath;
@end

@implementation DbManager
static DbManager *_DbManager;
static dispatch_once_t onceToken;
+ (DbManager *)sharedAdapter {
    dispatch_once(&onceToken, ^{
        _DbManager = [[DbManager alloc]init];
        [_DbManager openDB];
    });
    return _DbManager;
}

- (void)openDB {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.filePath = [[path lastObject] stringByAppendingPathComponent:@"Sph.sqlite"];
    //创建数据库
   _db = [FMDatabase databaseWithPath:self.filePath];
    //打开数据库
    if ([_db open]) {
        NSLog(@"打开数据库成功");
        NSString *sql =  @"create table if not exists 'sph' ('_id' INTEGER PRIMARY KEY NOT NULL ,'quarter' VARCHAR(255),'volume_of_mobile_data' VARCHAR(255))";
        BOOL res = [_db executeUpdate:sql];
        if(res){
            NSLog(@"创建表格成功");
        }else{
            NSLog(@"创建表格失败");
            [_db close];
        }
    }else{
        NSLog(@"打开数据库失败");
         [_db close];
    }
}

-(BOOL)saveData:(NSArray *)data {
    if (![_db open]) {
        NSLog(@"数据库打开失败!");
        return NO;
    }
    [_db beginTransaction];
    BOOL isRollBack= NO;
    @try {
        [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FMResultSet *resultSet = [_db executeQuery:[NSString stringWithFormat:@"SELECT * FROM sph WHERE _id = %@;", obj[@"_id"]]];
            if (![resultSet next]) {
                BOOL res = [_db executeUpdate:@"INSERT INTO sph(_id,quarter,volume_of_mobile_data)VALUES(?,?,?)",obj[@"_id"],obj[@"quarter"],obj[@"volume_of_mobile_data"]];
                if (!res) {
                    NSLog(@"db事务插入失败");
                }else{
                    NSLog(@"db事务插入成功");
                }
            }else{
                NSLog(@"数据已存在");
            }
        }];
    } @catch (NSException *exception) {
        isRollBack = YES;
        [_db rollback];
    } @finally {
        if (!isRollBack) {
            [_db commit];
        }
    }
    [_db close];
    return !isRollBack;
}


- (NSArray *)getLocalData{
    [_db open];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM sph"];
    while ([res next]) {
        int _id = [res intForColumn:@"_id"];
        NSString *quarter = [res stringForColumn:@"quarter"];
        NSString *volume_of_mobile_data = [res stringForColumn:@"volume_of_mobile_data"];
        if (_id) {
            _id = 0;
        }
        if (!quarter || ![quarter isKindOfClass:[NSString class]]) {
            quarter = @"";
        }
        if (!volume_of_mobile_data || ![volume_of_mobile_data isKindOfClass:[NSString class]]) {
                   volume_of_mobile_data = @"";
               }
        NSDictionary *dict = @{@"_id":@(_id),
                               @"quarter":quarter,
                               @"volume_of_mobile_data":volume_of_mobile_data
        };
        [dataArray addObject:dict];
    }
    [_db close];
    return [[NSArray alloc]initWithArray:dataArray];
}
@end
