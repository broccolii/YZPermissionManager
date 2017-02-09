
//
//  PermissionViewController.m
//  Carrot
//
//  Created by Broccoli on 09/02/2017.
//  Copyright © 2017 broccoliii. All rights reserved.
//

#import "PermissionViewController.h"

@interface PermissionViewController ()

@property (strong, nonatomic) IBOutlet UILabel *permissionStatusLabel;

@end

NSString *YZPermissionStatusNameMapping[] = {
    [YZPermissionStatusUnknown] = @"Permission Status Unknown",
    [YZPermissionStatusAuthorized] = @"Permission Status Authorized",
    [YZPermissionStatusUnauthorized] = @"Permission Status Unauthorized",
    [YZPermissionStatusDisabled] = @"Permission Status Disabled"
};

@implementation PermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkPermissionStatus];
}

#pragma mark - Action
- (IBAction)getPermissionButtonClicked:(id)sender {
    [YZPermissionManager requestPermissionWithResource:self.permissionResource agreedHandler:^{
        self.permissionStatusLabel.text = YZPermissionStatusNameMapping[YZPermissionStatusAuthorized];
    } rejectedHandler:^(YZPermissionStatus status) {
        [self showAlertController];
    }];
}

#pragma mark - private method
- (void)checkPermissionStatus {
    [YZPermissionManager checkPermissionWithResource:self.permissionResource
                                   completionHandler:^(YZPermissionStatus status) {
                                       self.permissionStatusLabel.text = YZPermissionStatusNameMapping[status];
                                   }];
}

- (void)showAlertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"get permission" message:@"I need to use some application permissions" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *systemSettingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:systemSettingsURL]) {
            [[UIApplication sharedApplication] openURL:systemSettingsURL];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:confirm];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
