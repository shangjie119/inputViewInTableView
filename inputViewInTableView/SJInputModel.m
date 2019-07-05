//
//  SJInputModel.m
//  inputViewInTableView
//
//  Created by sj on 2019/7/1.
//  Copyright © 2019 sj. All rights reserved.
//

#import "SJInputModel.h"

@interface SJInputModel ()

@property (nonatomic, assign) CGFloat tempTextViewHeight;

@end

@implementation SJInputModel

- (CGFloat)cellHeight
{
    return [self viewHeight];
}

- (CGFloat)viewHeight
{
    if (self.type == TypeTextField) {
        return 100;
    } else {
        if ([self textViewHeight] < 20) {
            return 105;
        } else {
            return [self textViewHeight] + 85;
        }        
    }
}

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
- (CGFloat)textViewHeight
{
    CGFloat textViewHeight;
    UIFont *font = [UIFont systemFontOfSize:16];
    CGFloat maxWidth = kScreenWidth - 30;
    CGSize size = CGSizeMake(maxWidth, CGFLOAT_MAX);
    NSDictionary *attributes = @{NSFontAttributeName:font};
    textViewHeight = [self.contentStr boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin) attributes:attributes context:nil].size.height;
    textViewHeight = ceilf(textViewHeight);
    return textViewHeight;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.contentStr = textView.text;

    CGFloat textViewHeight;
    if ([self textViewHeight] < 20) {
        textViewHeight = 20;
    } else {
        textViewHeight = [self textViewHeight];
    }
    if (textViewHeight != self.tempTextViewHeight) {
        self.tempTextViewHeight = textViewHeight;
        if ([self.vc respondsToSelector:@selector(reloadTableViewWithoutAnimation)]) {
            [self.vc performSelector:@selector(reloadTableViewWithoutAnimation) withObject:nil];
        }
    }
}

@end
