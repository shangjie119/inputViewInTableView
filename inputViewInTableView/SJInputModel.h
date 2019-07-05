//
//  SJInputModel.h
//  inputViewInTableView
//
//  Created by sj on 2019/7/1.
//  Copyright © 2019 sj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, Type)
{
    TypeTextField,
    TypeTextView,
};

NS_ASSUME_NONNULL_BEGIN

@interface SJInputModel : NSObject<UITextViewDelegate>

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) Type type;

@property (nonatomic, copy) NSString *contentStr;

@property (nonatomic, weak) UIViewController *vc;

@end

NS_ASSUME_NONNULL_END
