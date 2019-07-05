#iOS开发 tableview上可变高度的文本输入框
开发中有很多时候都会遇到tableView上多行输入自适应高度的文本，处理起来就非常麻烦。有的方法改变contentOffset并且设置

```
self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;    
```
当滑动tableView时候注销输入框响应，个人觉得这种体验不是很好，因为当tableView上有多个输入框的时候，我在上面输入完，就想滑到下面接着输入，并不想看到键盘收起再弹出，那么这种方式就不太好了，废话不多说，现在给大家另外一种处理方法。  
先说一下思路：修改tableView的frame和contentOffset来实现文本框不遮挡且高度可自适应变化的效果。
首先，注册几个通知，这里需要注意一下，UITextField和UITextView点击的时候，几个通知方法执行的顺序是不太一样的。所以后面处理的时候要多加注意和判断。

```
/*
 通知方法执行顺序：
 UItextField: UITextFieldTextDidBeginEditingNotification -> UIKeyboardWillShowNotification -> UIKeyboardDidShowNotification
 UITextView : UIKeyboardWillShowNotification -> UITextViewTextDidBeginEditingNotification -> UIKeyboardDidShowNotification
 如果输入文本都不设置inputAccessoryView，文本间切换通知方法执行顺序: inputViewDidEndEditing -> inputViewDidBeginEditing
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
```
设置3个属性，keyboardShowing：标记键盘是否已经显示；kbSize：当前键盘大小（不同输入框键盘可能不一样）；inputView：当前输入框。判断当键盘已经显示且inputView有值的时候，再进行位置的判断与变化。

```
#pragma mark 键盘用到的属性
@property (nonatomic, assign) BOOL keyboardShowing;
@property (nonatomic, assign) CGSize kbSize;
@property (nonatomic, strong, nullable) UIView *inputView;
```
实现通知对应方法

```
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
    [self restorePosition];
}

- (void)keyboardDidHide:(NSNotification*)aNotification {
    NSLog(@"keyboard did hidden");
    self.kbSize = CGSizeZero;
}

```
下面就是最关键的方法了，判断键盘弹起后，输入框是否被遮挡，如果遮挡，计算相对滚动距离,先把tableView的frame重新设置成除键盘的区域，然后设置contentOffset，这个设置frame时候要放在结束动画的block中，否则列表会有显示位移的问题。代码如下：

```
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
    
    CGRect frame = self.tableView.frame;
    frame.size.height = kScreenHeight - self.kbSize.height;
    self.tableView.frame = frame;
    CGFloat shouldOffsetY = move + self.tableView.contentOffset.y;
    [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        [self.tableView setContentOffset:CGPointMake(0, shouldOffsetY) animated:NO];
    } completion:^(BOOL finished) {
        CGRect frame = self.tableView.frame;
        frame.size.height = kScreenHeight - self.kbSize.height;
        self.tableView.frame = frame;
    }];
}
```
当结束输入时，需要把tableView的frame设置回来

```
- (void)restorePosition 
{
    CGRect frame = self.tableView.frame;
    frame.size.height = kScreenHeight;
    self.tableView.frame = frame;
}
```
到这，点击文本输入的时候，键盘出现后，文本输入就不会遮挡了，如果高度不需要动态变化，那么现在可以说大功告成，接下来要实现高度动态变化且不遮挡的输入框。  
我用的方法是根据cell绑定的model里面的cellHeight属性，来改变cell高度实现文本框高度变化。
controller中cell高度用model记录返回

```
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJInputModel *model = self.dataArray[indexPath.row];
    return model.cellHeight;
}
```
cell里面把输入文本的delegate设置为model，在model实现代理执行对应操作。

```
self.inputView.delegate = model;
```
在model里实现代理方法

```
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
```
这里面有个判断，textViewHeight来记录之前输入文本高度，如果高度没变化，则不执行对应操作，如果变化了，才会刷新位置。
刷新的时候不能用reloadData，因为使用后会注销文本的响应，键盘会消失，用以下代码就可以

```
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
```
写到这里，基本上大功告成。
附上[简书链接](https://www.jianshu.com/p/fe765cf773b8)  



