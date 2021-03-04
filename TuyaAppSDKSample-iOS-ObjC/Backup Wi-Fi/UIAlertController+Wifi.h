//
//  UIAlertController+Wifi.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (Wifi)
+(instancetype)alertControllerWithTitle:(NSString*)title
                           sureBtnTitle:(NSString*)sureBtnTitle
                              sureBlock:(void(^)(NSString* ssid, NSString* password))sureBlock;
@end

NS_ASSUME_NONNULL_END
