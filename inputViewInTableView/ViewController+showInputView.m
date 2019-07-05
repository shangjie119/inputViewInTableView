//
//  ViewController+showInputView.m
//  inputViewInTableView
//
//  Created by sj on 2019/7/1.
//  Copyright © 2019 sj. All rights reserved.
//

#import "ViewController+showInputView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation ViewController (showInputView)

/*
 通知方法执行顺序：
 UItextField: UITextFieldTextDidBeginEditingNotification -> UIKeyboardWillShowNotification -> UIKeyboardDidShowNotification
 UITextView : UIKeyboardWillShowNotification -> UITextViewTextDidBeginEditingNotification -> UIKeyboardDidShowNotification
 如果输入文本都不设置inputAccessoryView，文本间切换通知方法执行顺序: inputViewDidEndEditing -> inputViewDidBeginEditing。
 如果都设置inputAccessoryView，1.切换至UITextField方法执行顺序: inputViewDidEndEditing -> UITextFieldTextDidBeginEditingNotification -> UIKeyboardWillShowNotification -> UIKeyboardDidShowNotification
    2.切换至UITextView方法执行顺序: inputViewDidEndEditing -> UIKeyboardWillShowNotification -> UITextViewTextDidBeginEditingNotification -> UIKeyboardDidShowNotification
 所以当键盘高度有变化时，要设置inputAccessoryView，否则得到键盘大小将是上一个输入框对应键盘大小。
 */

- (void)registerAllNotifications {
    //  Registering for keyboard notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    //  Registering for UITextField notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputViewDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
    //  Registering for UITextView notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];

}

- (void)unregisterAllNotifications {
    //  Unregistering for keyboard notification.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
}


- (void)inputViewDidBeginEditing:(NSNotification*)notification
{
    NSLog(@"input begin edit");
    // Getting object
    self.inputView = notification.object;

    if (self.keyboardShowing == YES &&
        self.inputView)
    {
        [self optimizedAdjustPosition];
    }
}

- (void)inputViewDidEndEditing:(NSNotification*)notification
{
    NSLog(@"input end edit");
    // Setting object to nil
    self.inputView = nil;
}

#pragma mark - UIKeyboad Notification methods
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSLog(@"keyboard will show");
    self.keyboardShowing = YES;

    // Getting UIKeyboardSize.
    CGRect kbFrame = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    //Calculating actual keyboard displayed size, keyboard frame may be different when hardware keyboard is attached
    CGRect intersectRect = CGRectIntersection(kbFrame, screenSize);
    if (CGRectIsNull(intersectRect)) {
        self.kbSize = CGSizeMake(screenSize.size.width, 0);
    } else {
        self.kbSize = intersectRect.size;
    }
}

- (void)keyboardDidShow:(NSNotification*)aNotification {
    NSLog(@"keyboard did show");
    if (self.keyboardShowing == YES && self.inputView)
    {
        [self optimizedAdjustPosition];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSLog(@"keyboard will hidden");
    self.keyboardShowing = NO;
    // 之所以不写在didHide方法里 是因为显示的动画效果不好
    [self restorePosition];
}

- (void)keyboardDidHide:(NSNotification*)aNotification {
    NSLog(@"keyboard did hidden");
    self.kbSize = CGSizeZero;
}

- (void)optimizedAdjustPosition {
    CGFloat duration = 0.25;
    // 相对于文本框，多上滑的距离
    CGFloat keyboardDistanceFromInputView = 15;
    CGFloat keyboardHeight = self.kbSize.height + keyboardDistanceFromInputView;
    CGRect inputViewRectInWindow = [self.inputView.superview convertRect:self.inputView.frame toView:[UIApplication sharedApplication].keyWindow];
    
    CGFloat inputViewMaxY = CGRectGetMaxY(inputViewRectInWindow);
    CGFloat keyboardMinY = kScreenHeight - keyboardHeight;
    CGFloat move = inputViewMaxY - keyboardMinY;
    
    if (move <= 0) return;
    
    CGFloat shouldOffsetY = move + self.tableView.contentOffset.y;
    [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        [self.tableView setContentOffset:CGPointMake(0, shouldOffsetY) animated:NO];
    } completion:^(BOOL finished) {
        CGRect frame = self.tableView.frame;
        frame.size.height = kScreenHeight - self.kbSize.height;
        self.tableView.frame = frame;        
    }];
}

- (void)restorePosition
{
    CGRect frame = self.tableView.frame;
    frame.size.height = kScreenHeight;
    self.tableView.frame = frame;
}

- (void)reloadTableViewWithoutAnimation
{
    //textView 动态高度变化刷新
    [UIView performWithoutAnimation:^{
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
    
    // 需要在tableView刷新完成后执行滚动操作，否则列表会弹动而且滚动的位置会不准确
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self optimizedAdjustPosition];
    });
    
}


@end
