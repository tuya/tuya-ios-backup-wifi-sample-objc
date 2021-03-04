//
//  StandbyWifiVC.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <TuyaSmartDeviceCoreKit/TuyaSmartDevice.h>
NS_ASSUME_NONNULL_BEGIN

@interface StandbyWifiVC : UIViewController
@property(nonatomic, strong)TuyaSmartDevice *device;
@property (nonatomic,assign) BOOL isSelect;
@property (nonatomic,copy) void(^selectBlock)(TuyaSmartBackupWifiModel *model);
@end

NS_ASSUME_NONNULL_END
