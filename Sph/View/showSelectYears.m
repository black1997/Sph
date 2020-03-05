//
//  showSelectYears.m
//  Sph
//
//  Created by 青天揽月1 on 2020/3/5.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import "showSelectYears.h"
#define  SCR_W      [UIScreen mainScreen].bounds.size.width
#define  SCR_H      [UIScreen mainScreen].bounds.size.height

typedef void(^selectYearBlock)(NSString *);

@interface showSelectYears()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UIView *customview;
@property (nonatomic, strong)UIView *aplview;
@property (nonatomic, strong)UITableView *tableview;
@property (nonatomic, copy)selectYearBlock black;
@property (nonatomic,strong)NSArray *dataSource;
@end
@implementation showSelectYears

+ (void)showSelectYears:(NSArray *)years selctBlock:(nonnull void (^)(NSString * _Nonnull))selctBlock{
    showSelectYears *year = [[showSelectYears alloc]initWithYears:years];
    year.black = selctBlock;
    [year show];
    [[UIApplication sharedApplication].keyWindow addSubview:year];
}

- (instancetype)initWithYears:(NSArray *)years{
    self = [super initWithFrame:CGRectMake(0, 0, SCR_W, SCR_H )];
    if (self) {
        self.dataSource = [[NSArray alloc]initWithArray:years];
        [self addSubview:self.aplview];
        [self addSubview:self.customview];
        self.aplview.userInteractionEnabled = YES;
        self.customview.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        [self.aplview addGestureRecognizer:tap];
        [self.customview addSubview:self.tableview];
    }
    return self;
}

#pragma mark - setter
- (UIView *)aplview {
    if (!_aplview) {
        _aplview = [[UIView alloc]initWithFrame:self.frame];
        _aplview.backgroundColor = [UIColor blackColor];
        _aplview.alpha = 0.0f;
    }
    return _aplview;
}
- (UIView *)customview {
    if (!_customview) {
        _customview = [[UIView alloc]init];
        _customview.frame = CGRectMake(0, 0, SCR_W-80, SCR_H-200);
        _customview.center = CGPointMake(SCR_W/2, SCR_H/2);
    }
    return _customview;
}
- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.customview.frame), CGRectGetHeight(self.customview.frame)) style:UITableViewStylePlain];
        _tableview.backgroundColor = [UIColor whiteColor];
        _tableview.dataSource = self;
        _tableview.delegate = self;
        _tableview.rowHeight = 50;
        _tableview.tableFooterView = [UIView new];
    }
    return _tableview;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row < self.dataSource.count) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@年",self.dataSource[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.dataSource.count) {
        if (self.black) {
            self.black(self.dataSource[indexPath.row]);
        }
    }
    [self closeView];
}

#pragma mark - actoin
- (void)tapAction{
    [self closeView];
}
- (void)show{
    _customview.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    _customview.alpha = 0;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.customview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        weakSelf.customview.alpha = 1.0;
        weakSelf.aplview.alpha = 0.57;
    } completion:nil];
}

- (void)closeView{
    __weak typeof(self) weakSelf = self;
     [UIView animateWithDuration:0.3f animations:^{
         weakSelf.customview.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
         weakSelf.customview.alpha = 0;
         weakSelf.aplview.alpha = 0.0;
     } completion:^(BOOL finished) {
        [weakSelf.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [weakSelf removeFromSuperview];
     }];
}

@end
