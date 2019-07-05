//
//  SJTextFieldTableViewCell.h
//  inputViewInTableView
//
//  Created by sj on 2019/7/1.
//  Copyright © 2019 sj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJInputModel;

NS_ASSUME_NONNULL_BEGIN

@interface SJTextFieldTableViewCell : UITableViewCell

- (void)updateCellWithModel:(SJInputModel *)model;

@end

NS_ASSUME_NONNULL_END
