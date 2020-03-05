//
//  ListTableViewCell.m
//  Sph
//
//  Created by 青天揽月1 on 2020/3/5.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import "ListTableViewCell.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
@interface ListTableViewCell()
@property (nonatomic,strong) UILabel *labTitle;
@property (nonatomic,strong) UILabel *labValue;
@property (nonatomic,strong) UIButton  *img;
@end

@implementation ListTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeUIs];
    }
    return self;
}
#pragma mark -prvate
- (void)makeUIs {
    [self.contentView addSubview:self.labTitle];
    [self.contentView addSubview:self.labValue];
    [self.contentView addSubview:self.img];
    __weak typeof(self) weakself = self;
    [self.labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.contentView).with.offset(25);
        make.top.mas_equalTo(weakself.contentView).with.offset(15);
    }];
    [self.labValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.labTitle);
        make.top.mas_equalTo(weakself.labTitle.mas_bottom).with.offset(5);
    }];
    [self.img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.contentView).with.offset(-20);
        make.centerY.mas_equalTo(weakself.contentView);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
}


#pragma mark - setter
-(UILabel *)labTitle {
    if (!_labTitle) {
        _labTitle = [[UILabel alloc]init];
        _labTitle.textColor = [UIColor blackColor];
        _labTitle.font = [UIFont systemFontOfSize:16];
    }
    return _labTitle;
}
-(UILabel *)labValue {
    if (!_labValue) {
        _labValue = [[UILabel alloc]init];
        _labValue.textColor = [UIColor grayColor];
        _labValue.font = [UIFont systemFontOfSize:13];
    }
    return _labValue;
}

- (UIButton *)img {
    if (!_img) {
        _img = [[UIButton alloc]init];
        [_img setImage:[UIImage imageNamed:@"icon-img"] forState:UIControlStateNormal];
        _img.hidden = YES;
        [_img addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _img;
}

- (void)updateData:(NSDictionary *)info lastYearData:(NSDictionary *)lastInfo {
    if (info) {
        self.labTitle.text = info[@"quarter"];
        self.labValue.text = info[@"volume_of_mobile_data"];
    }
    if (lastInfo) {
        float lastData = [lastInfo[@"volume_of_mobile_data"] floatValue];
        float data = [info[@"volume_of_mobile_data"] floatValue];
        if (data < lastData) {
            self.img.hidden = NO;
        }else{
            self.img.hidden = YES;
        }
    }
}

- (void)btnAction:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"这个季度数据下降";
    [hud hideAnimated:YES afterDelay:1.5];
}
@end
