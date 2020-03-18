//
//  ViewController.m
//  Sph
//
//  Created by 青天揽月1 on 2020/3/5.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "ListTableViewCell.h"
#import "showSelectYears.h"
#import "MBProgressHUD.h"
#import "DbManager.h"
#import "sphProtocol.h"

static NSString *cellid = @"cellId";

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableview;
@property (nonatomic,strong)NSArray *allData;
@property (nonatomic,strong)NSMutableArray *yearArray;
@property (nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"年份" style:UIBarButtonItemStylePlain target:self action:@selector(choseYear)];
    self.title = @"Sph";
    [self getTheWebData];
    [self.view addSubview:self.tableview];
    
}

#pragma mark - private
- (void)choseYear {
    __weak typeof(self) weakSelf = self;
    [showSelectYears showSelectYears:self.yearArray selctBlock:^(NSString * _Nonnull selectYear) {
        [weakSelf makeSelectData:selectYear];
    }];
}
- (void)makeData:(NSArray*)array{
    self.allData = [[NSArray alloc]initWithArray:array];
    if (self.dataSource.count) {
        [self.dataSource removeAllObjects];
    }
    __weak typeof(self) weakSelf = self;
    __block NSString *lastYear = @"";
    [array enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *quarter = obj[@"quarter"];
        NSArray *tem = [quarter componentsSeparatedByString:@"-"];
        NSString *year = tem.firstObject;
        if ([year isKindOfClass:[NSString class]] && year.length >0 && ![weakSelf.yearArray containsObject:year]) {
            [weakSelf.yearArray addObject:year];
        }
        if (0 == idx) {
            [weakSelf.dataSource addObject:obj];
            lastYear = year;
        }else{
            if ([lastYear isEqualToString:year]) {
                [weakSelf.dataSource addObject:obj];
            }
        }
    }];
    if (self.dataSource.count) {
        [self.tableview reloadData];
    }
}
- (void)makeSelectData:(NSString *)yearObject {
    if (self.dataSource.count) {
        [self.dataSource removeAllObjects];
    }
    __weak typeof(self) weakSelf = self;
    [self.allData enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *quarter = obj[@"quarter"];
        NSArray *tem = [quarter componentsSeparatedByString:@"-"];
        NSString *year = tem.firstObject;
        if ([yearObject isEqualToString:year]) {
            [weakSelf.dataSource addObject:obj];
        }
    }];
    if (self.dataSource.count) {
        [self.tableview reloadData];
    }
}

#pragma mark - getdata
- (void)getTheWebData {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //指定其protocolClasses
    configuration.protocolClasses = @[[sphProtocol class]];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:configuration];
    NSString *url = @"https://data.gov.sg/api/action/datastore_search?resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f";
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [hud hideAnimated:YES];
        NSDictionary *result = (NSDictionary *)responseObject;
        NSArray * tem = result[@"result"][@"records"];
         if (tem.count) {
             [[DbManager sharedAdapter]saveData:tem];
             [weakSelf makeData:tem];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        NSArray * tem = [[DbManager sharedAdapter]getLocalData];
        if (tem.count) {
            [self makeData:tem];
        }
    }];
}

#pragma mark - setter
-(NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
-(NSMutableArray *)yearArray{
    if (!_yearArray) {
        _yearArray = [NSMutableArray new];
    }
    return _yearArray;
}
- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableview.dataSource = self;
        _tableview.delegate = self;
        _tableview.tableFooterView = [UIView new];
        _tableview.rowHeight = 70;
    }
    return _tableview;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[ListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row < self.dataSource.count) {
        NSDictionary *lastInfo;
        if (indexPath.row>0) {
            lastInfo = self.dataSource[indexPath.row -1];
        }
        [cell updateData:self.dataSource[indexPath.row] lastYearData:lastInfo];
    }
    return cell;
}
@end
