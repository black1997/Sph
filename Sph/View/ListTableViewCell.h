//
//  ListTableViewCell.h
//  Sph
//
//  Created by 青天揽月1 on 2020/3/5.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ListTableViewCell : UITableViewCell
- (void)updateData:(NSDictionary *)info lastYearData:(NSDictionary *)lastInfo;
@end

NS_ASSUME_NONNULL_END
