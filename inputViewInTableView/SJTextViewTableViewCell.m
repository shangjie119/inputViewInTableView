//
//  SJTextViewTableViewCell.m
//  inputViewInTableView
//
//  Created by sj on 2019/7/1.
//  Copyright © 2019 sj. All rights reserved.
//

#import "SJTextViewTableViewCell.h"

#import "SJInputModel.h"

@interface SJTextViewTableViewCell ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation SJTextViewTableViewCell
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.textContainer.lineFragmentPadding = 0;
    
    self.textView.inputAccessoryView = [UIView new];
    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    redView.backgroundColor = [UIColor redColor];
    self.textView.inputView = redView;
}

- (void)updateCellWithModel:(SJInputModel *)model
{
    self.textView.delegate = model;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
