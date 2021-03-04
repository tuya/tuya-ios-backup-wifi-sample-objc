//
//  UIAlertController+Wifi.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "UIAlertController+Wifi.h"

@implementation UIAlertController (Wifi)
+(instancetype)alertControllerWithTitle:(NSString*)title
                           sureBtnTitle:(NSString*)sureBtnTitle
                              sureBlock:(void(^)(NSString* ssid, NSString* password))sureBlock{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"ssid";
    }];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"password",@"");
    }];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:sureBtnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *ssid = alertVC.textFields[0].text;
        NSString *password = alertVC.textFields[1].text;
        if (sureBlock) {
            sureBlock(ssid, password);
        }
      
    }];
    [alertVC addAction:action];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"") style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:cancelAction];
    
    return alertVC;
}
@end
