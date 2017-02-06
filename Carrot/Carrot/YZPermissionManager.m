//
//  PermissionManager.m
//  Carrot
//
//  Created by Broccoli on 2017/2/4.
//  Copyright © 2017年 broccoliii. All rights reserved.
//

#import "YZPermissionManager.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <EventKit/EventKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version) ([[[UIDevice currentDevice] systemVersion] compare:[NSString stringWithFormat:@"%f", version] options:NSNumericSearch] != NSOrderedAscending)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation YZPermissionManager

#pragma mark - request authorizationStatus
+ (void)requestPermissionWithResource:(PermissionResource)resource
                        agreedHandler:(void(^)())agreedHandler
                      rejectedHandler:(void(^)())rejectedHandler {
    
    switch (resource) {
        case PermissionResourceNotifications:
            [YZPermissionManager requestNotificationsPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case PermissionResourceLocationWhileInUse:
            [YZPermissionManager requestLocationWhileInUsePermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case PermissionResourceLocationAlways:
            [YZPermissionManager requestLocationAlwaysPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case PermissionResourceContacts:
            [YZPermissionManager requestContactsPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case PermissionResourceEvents:
            [YZPermissionManager requestEventsPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case PermissionResourceMicrophone:
            [YZPermissionManager requestMicrophonePermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case PermissionResourceCamera:
            [YZPermissionManager requestCameraPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case PermissionResourcePhotos:
            [YZPermissionManager requestPhotosPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case PermissionResourceReminders:
            [YZPermissionManager requestRemindersPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case PermissionResourceBluetooth:
            [YZPermissionManager requestBluetoothPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case PermissionResourceMotion:
            [YZPermissionManager requestMotionPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
    }
}

+ (void)requestNotificationsPermissionAgreedHandler:(void(^)())agreedHandler
                                    rejectedHandler:(void(^)())rejectedHandler {
    
}

+ (void)requestLocationWhileInUsePermissionAgreedHandler:(void(^)())agreedHandler
                                         rejectedHandler:(void(^)())rejectedHandler {
    
}

+ (void)requestLocationAlwaysPermissionAgreedHandler:(void(^)())agreedHandler
                                     rejectedHandler:(void(^)())rejectedHandler {
    
}

+ (void)requestContactsPermissionAgreedHandler:(void(^)())agreedHandler
                               rejectedHandler:(void(^)())rejectedHandler {
    
}

+ (void)requestEventsPermissionAgreedHandler:(void(^)())agreedHandler
                             rejectedHandler:(void(^)())rejectedHandler {
    
}

+ (void)requestMicrophonePermissionAgreedHandler:(void(^)())agreedHandler
                             rejectedHandler:(void(^)())rejectedHandler {
    
}

+ (void)requestCameraPermissionAgreedHandler:(void(^)())agreedHandler
                             rejectedHandler:(void(^)())rejectedHandler {
    
}

+ (void)requestPhotosPermissionAgreedHandler:(void(^)())agreedHandler
                             rejectedHandler:(void(^)())rejectedHandler {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(8.0)) {
       [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
           
       }];
    } else {
       
    }
}

+ (void)requestRemindersPermissionAgreedHandler:(void(^)())agreedHandler
                                rejectedHandler:(void(^)())rejectedHandler {
    
}

+ (void)requestBluetoothPermissionAgreedHandler:(void(^)())agreedHandler
                                rejectedHandler:(void(^)())rejectedHandler {
    
}

+ (void)requestMotionPermissionAgreedHandler:(void(^)())agreedHandler
                             rejectedHandler:(void(^)())rejectedHandler {
    
}

#pragma mark - get status
+ (void)notificationsStatusWithCompletionHandler:(void(^)(PermissionStatus permissionStatus))completionHandler {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(10.0)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusNotDetermined:
                    completionHandler(PermissionStatusUnknown);
                    break;
                case UNAuthorizationStatusDenied:
                    completionHandler(PermissionStatusUnauthorized);
                    break;
                case UNAuthorizationStatusAuthorized:
                    completionHandler(PermissionStatusAuthorized);
                    break;
            }
        }];
    } else {
        UIUserNotificationSettings *currentUserNotificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (currentUserNotificationSettings.types == UIUserNotificationTypeNone) {
            // TODO:
        }
    }
}

+ (PermissionStatus)locationWhileInUseStatus {
    if ([CLLocationManager locationServicesEnabled]) {
        return PermissionStatusDisabled;
    }
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            return PermissionStatusAuthorized;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            return PermissionStatusUnauthorized;
        case kCLAuthorizationStatusNotDetermined:
            return PermissionStatusUnknown;
    }
}

+ (PermissionStatus)locationAlwaysStatus {
    if ([CLLocationManager locationServicesEnabled]) {
        return PermissionStatusDisabled;
    }
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // TODO: 从低权限到高权限 测试
            return PermissionStatusUnknown;
        case kCLAuthorizationStatusAuthorizedAlways:
            return PermissionStatusAuthorized;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            return PermissionStatusUnauthorized;
        case kCLAuthorizationStatusNotDetermined:
            return PermissionStatusUnknown;
    }
}

+ (PermissionStatus)contactsStatus {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(9.0)) {
        CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        
        switch (authorizationStatus) {
            case CNAuthorizationStatusDenied:
            case CNAuthorizationStatusRestricted:
                return PermissionStatusUnauthorized;
            case CNAuthorizationStatusAuthorized:
                return PermissionStatusAuthorized;
            case CNAuthorizationStatusNotDetermined:
                return PermissionStatusUnknown;
        }
    } else {
        ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
        switch (authorizationStatus) {
            case kABAuthorizationStatusAuthorized:
                return PermissionStatusAuthorized;
            case kABAuthorizationStatusRestricted:
            case kABAuthorizationStatusDenied:
                return PermissionStatusUnauthorized;
            case kABAuthorizationStatusNotDetermined:
                return PermissionStatusUnknown;
            default:
                break;
        }
    }
}

+ (PermissionStatus)eventsStatus {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusNotDetermined:
            return PermissionStatusUnknown;
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied:
            return PermissionStatusUnauthorized;
        case EKAuthorizationStatusAuthorized:
            return PermissionStatusAuthorized;
        default:
            break;
    }
}

+ (PermissionStatus)remindersStatus {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusNotDetermined:
            return PermissionStatusUnknown;
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied:
            return PermissionStatusUnauthorized;
        case EKAuthorizationStatusAuthorized:
            return PermissionStatusAuthorized;
        default:
            break;
    }
}

+ (PermissionStatus)microphoneStatus {
    AVAudioSessionRecordPermission authorizationStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (authorizationStatus) {
        case AVAudioSessionRecordPermissionDenied:
            return PermissionStatusUnauthorized;
        case AVAudioSessionRecordPermissionGranted:
            return PermissionStatusAuthorized;
        case AVAudioSessionRecordPermissionUndetermined:
            return PermissionStatusUnknown;
    }
}

//@property (nonatomic, assign) PermissionStatus motionStatus;

+ (PermissionStatus)cameraStatus {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusAuthorized:
            return PermissionStatusAuthorized;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            return PermissionStatusUnauthorized;
        case AVAuthorizationStatusNotDetermined:
            return PermissionStatusUnknown;
    }
}

+ (PermissionStatus)photosStatus {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(8.0)) {
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        switch (authorizationStatus) {
            case PHAuthorizationStatusAuthorized:
                return PermissionStatusAuthorized;
            case PHAuthorizationStatusDenied:
            case PHAuthorizationStatusRestricted:
                return PermissionStatusUnauthorized;
            case PHAuthorizationStatusNotDetermined:
                return PermissionStatusUnknown;
        }
    } else {
        ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
        switch (authorizationStatus) {
            case ALAuthorizationStatusAuthorized:
                return PermissionStatusAuthorized;
            case ALAuthorizationStatusDenied:
            case ALAuthorizationStatusRestricted:
                return PermissionStatusUnauthorized;
            case ALAuthorizationStatusNotDetermined:
                return PermissionStatusUnknown;
        }
    }
}


+ (PermissionStatus)bluetoothStatus {
    return PermissionStatusUnknown;
}

+ (PermissionStatus)motionStatus {
    return PermissionStatusUnknown;
}

@end

#pragma clang diagnostic pop
