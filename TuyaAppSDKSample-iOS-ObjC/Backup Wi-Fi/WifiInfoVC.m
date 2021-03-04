//
//  WifiInfoVC.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "WifiInfoVC.h"
#import <TuyaSmartDeviceCoreKit/TuyaSmartDevice.h>
#import "UIAlertController+Wifi.h"
#import "StandbyWifiVC.h"
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface WifiInfoVC ()

@property(nonatomic, strong)TuyaSmartDevice *device;
@property (nonatomic, strong) UILabel *tipLb;
@property (nonatomic, strong) UIButton *switchNewWifiButton;
@property (nonatomic, strong) UIButton *switchStandbyWifiButton;
@property (nonatomic, strong) UIButton *setStandbyWifiButton;
@end

@implementation WifiInfoVC

// MARK: - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"WIFI info", @"");
    //Determine whether the device supports alternate network settings
    if ([self.device.deviceModel devAttributeIsSupport:12]) {
        self.switchNewWifiButton.hidden = NO;
        self.switchStandbyWifiButton.hidden = NO;
        self.setStandbyWifiButton.hidden = NO;
        [self getCurrentWifiInfo];
    }else{
        self.tipLb.text = NSLocalizedString(@"Alternate network Settings are not supported on the current device",@"");
    }
}

// MARK: - Get current network info

//    data = {
//         devId = 6c2850c9d7c7a84c3cfhx3;
//         hash = "HMa4711Q8FMlHLSJO1xp3/Hg8nint9zvE5xK/43vboE=";
//         network = 0;
//         signal = 99;
//         ssid = "7F-S-10-11-DevOS";
//         tId = F70DE4B1E3CA424D;
//         version = 1;
//     };
//     reqType= wifiInfo;

-(void)getCurrentWifiInfo{
    [self.device getCurrentWifiInfoWithSuccess:^(NSDictionary *dict) {
        NSDictionary *data = dict[@"data"];
        if (data) {
            //network: 0 means wireless and 1 means wired
            int network = [data[@"network"] intValue];
            NSString *s = [NSString stringWithFormat:@"wifi ssid:%@\nsignal:%@ \n%@",data[@"ssid"],data[@"signal"],network?@"wireless":@"wired"];
            self.tipLb.text = s;
            if (network) {
                self.switchNewWifiButton.hidden = YES;
                self.switchStandbyWifiButton.hidden = YES;
                self.setStandbyWifiButton.hidden = YES;
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

// MARK: - Switch the current network to a new network
- (void)switchNewWifi{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"switch Wifi",@"") sureBtnTitle:NSLocalizedString(@"switch",@"") sureBlock:^(NSString * _Nonnull ssid, NSString * _Nonnull password) {
        if (ssid == nil || ssid.length == 0) {
            NSLog(@"ssid is empty");
            return;
        }
        [SVProgressHUD showWithStatus:NSLocalizedString(@"switching",@"")];
        [self.device switchToBackupWifiWithSSID:ssid password:password success:^(NSDictionary *dict) {
            [SVProgressHUD dismiss];
            [self getCurrentWifiInfo];
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            [self handleError:error];
        }];
    }];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

-(void)handleError:(NSError *)error{
    if(error.code ==  TUYA_TIMEOUT_ERROR){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Network switchover failed and no connection back to the original network",@"")];
        return;
    }
    
    if([error.userInfo[@"NSLocalizedFailureReason"] intValue] ==  2){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed to switch the network, but the original network was connected",@"")];
        return;
    }
}

// MARK: - Switch the current network to a saved alternate network
- (void)switchStandbyWifi{
    StandbyWifiVC *vc = [StandbyWifiVC new];
    vc.device = self.device;
    vc.isSelect = YES;
    vc.selectBlock = ^(TuyaSmartBackupWifiModel * _Nonnull model) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"switching",@"")];
        [self.device switchToBackupWifiWithHash:model.hashValue success:^(NSDictionary *dict) {
            [SVProgressHUD dismiss];
            [self getCurrentWifiInfo];
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            [self handleError:error];
        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

// MARK: - Set up standby network
-(void)setStandbyWifi{
    StandbyWifiVC *vc = [StandbyWifiVC new];
    vc.device = self.device;
    [self.navigationController pushViewController:vc animated:YES];
}




// MARK: - Getter
-(TuyaSmartDevice *)device{
    if (!_device) {
        _device = [[TuyaSmartDevice alloc]initWithDeviceId:self.devId];
    }
    return _device;
}


// MARK: - UI
-(UILabel *)tipLb{
    if (!_tipLb) {
        _tipLb = [UILabel new];
        _tipLb.textColor = [UIColor blackColor];
        _tipLb.numberOfLines = 0;
        
        [self.view addSubview:_tipLb];
        [_tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_offset(-20);
            make.top.mas_equalTo(150);
        }];
        [_tipLb setContentHuggingPriority:UILayoutPriorityRequired
                                        forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _tipLb;
}

-(UIButton *)setStandbyWifiButton{
    if (!_setStandbyWifiButton) {
        _setStandbyWifiButton = [UIButton new];
        [_setStandbyWifiButton setTitle:NSLocalizedString(@"set Standby Wifi",@"") forState:0];
        _setStandbyWifiButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_setStandbyWifiButton setTitleColor:[UIColor blueColor] forState:0];
        [_setStandbyWifiButton addTarget:self action:@selector(setStandbyWifi) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_setStandbyWifiButton];
        [_setStandbyWifiButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(150);
            make.bottom.mas_equalTo(-200);
        }];
    }
    return _setStandbyWifiButton;
}


-(UIButton *)switchNewWifiButton{
    if (!_switchNewWifiButton) {
        _switchNewWifiButton = [UIButton new];
        [_switchNewWifiButton setTitle:NSLocalizedString(@"swich to New Wifi",@"") forState:0];
        [_switchNewWifiButton setTitleColor:[UIColor blueColor] forState:0];
        _switchNewWifiButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_switchNewWifiButton addTarget:self action:@selector(switchNewWifi) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_switchNewWifiButton];
        [_switchNewWifiButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(150);
            make.left.mas_equalTo(30);
            make.top.mas_equalTo(self.setStandbyWifiButton.mas_bottom).offset(20);
        }];
    }
    return _switchNewWifiButton;
}

-(UIButton *)switchStandbyWifiButton{
    if (!_switchStandbyWifiButton) {
        _switchStandbyWifiButton = [UIButton new];
        [_switchStandbyWifiButton setTitle:NSLocalizedString(@"Switch to Standby Wifi",@"") forState:0];
        [_switchStandbyWifiButton setTitleColor:[UIColor blueColor] forState:0];
        _switchStandbyWifiButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_switchStandbyWifiButton addTarget:self action:@selector(switchStandbyWifi) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_switchStandbyWifiButton];
        [_switchStandbyWifiButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(150);
            make.right.mas_equalTo(-30);
            make.top.mas_equalTo(self.setStandbyWifiButton.mas_bottom).offset(20);
        }];
    }
    return _switchStandbyWifiButton;
}


@end
