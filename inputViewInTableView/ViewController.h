//
//  ViewController.h
//  inputViewInTableView
//
//  Created by sj on 2019/7/1.
//  Copyright © 2019 sj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

#pragma mark 键盘用到的属性
@property (nonatomic, assign) BOOL keyboardShowing;
@property (nonatomic, assign) CGSize kbSize;
@property (nonatomic, strong, nullable) UIView *inputView;


@end

