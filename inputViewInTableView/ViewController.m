//
//  ViewController.m
//  inputViewInTableView
//
//  Created by sj on 2019/7/1.
//  Copyright © 2019 sj. All rights reserved.
//

#import "ViewController.h"

#import "SJInputModel.h"

#import "SJTextViewTableViewCell.h"
#import "SJTextFieldTableViewCell.h"

#import "ViewController+showInputView.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (int i = 0; i < 20; i++) {
        SJInputModel *model = [[SJInputModel alloc] init];
        if (i < 10) {
            model.type = TypeTextField;
            model.vc = self;
        } else {
            model.type = TypeTextView;
            model.vc = self;
        }
        [self.dataArray addObject:model];
    }
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"SJTextViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"SJTextViewTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SJTextFieldTableViewCell" bundle:nil] forCellReuseIdentifier:@"SJTextFieldTableViewCell"];
    
//    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self registerAllNotifications];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJInputModel *model = self.dataArray[indexPath.row];
    return model.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJInputModel *model = self.dataArray[indexPath.row];
    if (model.type == TypeTextView) {
        SJTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJTextViewTableViewCell" forIndexPath:indexPath];
        [cell updateCellWithModel:model];
        return cell;
    } else {
        SJTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJTextFieldTableViewCell" forIndexPath:indexPath];
        [cell updateCellWithModel:model];
        return cell;
    }
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

@end
