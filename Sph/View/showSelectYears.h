//
//  showSelectYears.h
//  Sph
//
//  Created by 青天揽月1 on 2020/3/5.
//  Copyright © 2020 wenjuu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface showSelectYears : UIView
- (void)closeView;
- (instancetype)initWithYears:(NSArray *)years;

+ (void)showSelectYears:(NSArray *)years selctBlock:(void (^)(NSString * selectYear))selctBlock;
@end

NS_ASSUME_NONNULL_END
