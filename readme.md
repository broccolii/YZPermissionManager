



# YZPermissionManager
<p align="center">
    <img src="https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat" alt="Platform: iOS 8+" />
    <a href="https://cocoapods.org/pods/PermissionScope"><img src="https://cocoapod-badges.herokuapp.com/v/PermissionScope/badge.png" alt="Cocoapods compatible" /></a>
    <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="License: MIT" />
</p>

YZPermissionManager can help you to get access to the simple and easy to use.


Supported permissions: **Notifications**, **Location (WhileInUse, Always)**, **Camera**, **Photos**, **Microphone**, **Contacts**, **Reminders**, **Calendar**.

## Requirements

iOS 8.0+

## Example

Check the current status of the authority:

```
[YZPermissionManager checkPermissionWithResource:self.permissionResource
                                   completionHandler:^(YZPermissionStatus status) {
                   // do some thing                    
                    }];
```


Request the system permission you need

```
[YZPermissionManager requestPermissionWithResource:self.permissionResource agreedHandler:^{
        // Continue to execute your code
    } rejectedHandler:^(YZPermissionStatus status) {
        [self showRejectAlertController];
    }];
```

When the user rejects your permission application, You can use the code, go to the system settings page

```
NSURL *systemSettingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:systemSettingsURL]) {
            [[UIApplication sharedApplication] openURL:systemSettingsURL];
        }
```
## Installation

Just drag `YZPermissionManager.h / YZPermissionManager.m` to your iOS Project. 

# Contact
[broccoliii](broccoliii@163.com)

## License

YZPermissionManager is available under the MIT license. See the LICENSE file for more info.


