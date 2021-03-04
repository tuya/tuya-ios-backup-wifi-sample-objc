//
//  StandbyWifiVC.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "StandbyWifiVC.h"
#import "UIAlertController+Wifi.h"
#import <YYModel/YYModel.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface StandbyWifiVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<TuyaSmartBackupWifiModel *> *dataList;
@property (nonatomic, assign)NSInteger maxNum;

@end

@implementation StandbyWifiVC

// MARK: - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Standby Wifi",@"");
    [self loadData];
    self.tableView.hidden = NO;
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"add",@"") style:UIBarButtonItemStylePlain target:self action:@selector(addWifi)];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save",@"") style:UIBarButtonItemStylePlain target:self action:@selector(updateBackupWifiList)];
    self.navigationItem.rightBarButtonItems = @[addItem,saveItem];
}

// MARK: - Get a list of alternate networks
- (void)loadData{
    __weak __typeof__(self) weak_self = self;
    [self.device getBackupWifiListWithSuccess:^(NSDictionary *dict) {
        NSDictionary *dataDic = [dict objectForKey:@"data"];
        NSArray<TuyaSmartBackupWifiModel *> *list = [NSArray yy_modelArrayWithClass:TuyaSmartBackupWifiModel.class json:[dataDic objectForKey:@"backupList"]];
        weak_self.maxNum = [dataDic[@"maxNum"] intValue];
        weak_self.dataList = [list mutableCopy];
        [weak_self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"Standby Wifi:%@",error);
    }];
}

// MARK: - Setting up an alternate network list
-(void)updateBackupWifiList{
    __weak __typeof__(self) weak_self = self;
    [SVProgressHUD showWithStatus:@"update backup wifi"];
    [self.device setBackupWifiList:self.dataList success:^(NSDictionary *dict) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"update success"];
        [weak_self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

-(void)addWifi{
    if (self.maxNum <= self.dataList.count) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"The number of backup wifi has reached the upper limit", @"")];
        return;
    }
    __weak __typeof__(self) weakSelf = self;
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add wifi",@"") sureBtnTitle:NSLocalizedString(@"add",@"") sureBlock:^(NSString * _Nonnull ssid, NSString * _Nonnull password) {
        //Determine whether the ssid is empty
        if (ssid == nil || ssid.length == 0) {
            NSLog(@"ssid is empty");
            [SVProgressHUD showErrorWithStatus:@"ssid is empty"];
            return;
        }
        
        //Use “hashValue” to determine whether the added wifi is already in the backup wifi
        NSString *hashValue = [TuyaSmartBackupWifiModel getBase64HashValueWithLocalKey:self.device.deviceModel.localKey ssid:ssid psw:password];
        BOOL isStandbyNet = NO;
        for (TuyaSmartBackupWifiModel* wifiModel in weakSelf.dataList) {
            if ([hashValue isEqualToString:wifiModel.hashValue] ||
                ([ssid isEqualToString:wifiModel.ssid]&&[password isEqualToString:wifiModel.password])){
                isStandbyNet = YES;
                break;
            }
        }
        if (isStandbyNet) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Whether the added wifi is already in the backup wifi",@"")];
            return;
        }
        
        TuyaSmartBackupWifiModel *model = [TuyaSmartBackupWifiModel new];
        model.ssid = ssid;
        model.password = password;
        [self.dataList addObject:model];
        [self.tableView reloadData];
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

// MARK: - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataList[indexPath.row].ssid;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isSelect) {
        [self.navigationController popViewControllerAnimated:YES];
        self.selectBlock(self.dataList[indexPath.row]);
    }
}


// MARK: - TableView edit
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteItem:indexPath];
    }
}

-(void)deleteItem:(NSIndexPath *)indexPath{
    [self.dataList removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


// MARK: - Getter
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 0;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor grayColor];
        [_tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"cell"];
        [self.view addSubview:_tableView];
        _tableView.frame = self.view.bounds;
    }
    return _tableView;
}

@end
