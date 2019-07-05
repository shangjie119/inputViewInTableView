//
//  SJTextFieldTableViewCell.m
//  inputViewInTableView
//
//  Created by sj on 2019/7/1.
//  Copyright © 2019 sj. All rights reserved.
//

#import "SJTextFieldTableViewCell.h"

#import "SJInputModel.h"

@interface SJTextFieldTableViewCell ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation SJTextFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.textField.delegate = self;
    self.textField.inputAccessoryView = [UIView new];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing:YES];
    return YES;
}

- (void)updateCellWithModel:(SJInputModel *)model
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
