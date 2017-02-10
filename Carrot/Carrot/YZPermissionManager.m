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

typedef NS_ENUM(NSInteger, YZLocationUsageType) {
    YZLocationUsageWhenInUse,
    YZLocationUsageAlways
};

@class  YZLocationAgent;

static YZLocationAgent *locationAgent;
static CLLocationManager *locationManager;

@interface YZLocationAgent: NSObject<CLLocationManagerDelegate>

@property (nonatomic, assign) YZLocationUsageType type;
@property (nonatomic, copy) YZPermissionAgreedHandler agreedHandler;
@property (nonatomic, copy) YZPermissionRejectedHandler rejectHandler;

@end

@implementation YZLocationAgent

- (instancetype)initWithLocationUsage:(YZLocationUsageType)type
                        agreedHandler:(YZPermissionAgreedHandler)agreedHandler
                      rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.type = type;
    self.agreedHandler = agreedHandler;
    self.rejectHandler = rejectedHandler;
    
    return self;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    dispatch_sync(dispatch_get_main_queue(), ^{
        switch (status) {
            case kCLAuthorizationStatusAuthorizedWhenInUse: {
                self.type == YZLocationUsageWhenInUse ? self.agreedHandler() : self.rejectHandler(YZPermissionStatusUnauthorized);
                locationAgent = nil;
                locationManager = nil;
            }
                break;
            case kCLAuthorizationStatusAuthorizedAlways: {
                self.type == YZLocationUsageAlways ? self.agreedHandler() : self.rejectHandler(YZPermissionStatusUnauthorized);
                locationAgent = nil;
                locationManager = nil;
            }
                break;
            case kCLAuthorizationStatusDenied:
                self.rejectHandler(YZPermissionStatusDisabled);
                locationAgent = nil;
                locationManager = nil;
            default:
                break;
        }
    });
}

@end

@interface YZNotificationAgent: NSObject

@property (nonatomic, copy) YZPermissionAgreedHandler agreedHandler;
@property (nonatomic, copy) YZPermissionRejectedHandler rejectHandler;

@end

@implementation YZNotificationAgent

- (instancetype)initWithFinishedRequestingAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                        rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.agreedHandler = agreedHandler;
    self.rejectHandler = rejectedHandler;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestingNotifications) name:UIApplicationWillResignActiveNotification object:nil];
    
    return self;
}

#pragma mark - NotificationCenter method
- (void)requestingNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedRequestingNotifications) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)finishedRequestingNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];

    
}

@end

@implementation YZPermissionManager

#pragma mark - request authorizationStatus
+ (void)checkPermissionWithResource:(YZPermissionResource)resource
                  completionHandler:(YZPermissionCompletionHandler)completionHandler {
    switch (resource) {
        case YZPermissionResourceNotifications:
            [YZPermissionManager notificationsStatusWithCompletionHandler:completionHandler];
            break;
        case YZPermissionResourceLocationWhileInUse:
            completionHandler([YZPermissionManager locationWhileInUseStatus]);
            break;
        case YZPermissionResourceLocationAlways:
            completionHandler([YZPermissionManager locationAlwaysStatus]);
            break;
        case YZPermissionResourceContacts:
            completionHandler([YZPermissionManager contactsStatus]);
            break;
        case YZPermissionResourceEvents:
            completionHandler([YZPermissionManager eventsStatus]);
            break;
        case YZPermissionResourceMicrophone:
            completionHandler([YZPermissionManager microphoneStatus]);
            break;
        case YZPermissionResourceCamera:
            completionHandler([YZPermissionManager cameraStatus]);
            break;
        case YZPermissionResourcePhotos:
            completionHandler([YZPermissionManager photosStatus]);
            break;
        case YZPermissionResourceReminders:
            completionHandler([YZPermissionManager remindersStatus]);
            break;
        case YZPermissionResourceBluetooth:
            completionHandler([YZPermissionManager bluetoothStatus]);
            break;
        case YZPermissionResourceMotion:
            completionHandler([YZPermissionManager motionStatus]);
            break;
    }
}

+ (void)requestPermissionWithResource:(YZPermissionResource)resource
                        agreedHandler:(YZPermissionAgreedHandler)agreedHandler
                      rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    
    switch (resource) {
        case YZPermissionResourceNotifications:
            //            [YZPermissionManager requestNotificationsPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            NSAssert(YES, @"use requestNotificationsPermissionWithSetting");
            break;
        case YZPermissionResourceLocationWhileInUse:
            [YZPermissionManager requestLocationWhileInUsePermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case YZPermissionResourceLocationAlways:
            [YZPermissionManager requestLocationAlwaysPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case YZPermissionResourceContacts:
            [YZPermissionManager requestContactsPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case YZPermissionResourceEvents:
            [YZPermissionManager requestEventsPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case YZPermissionResourceMicrophone:
            [YZPermissionManager requestMicrophonePermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case YZPermissionResourceCamera:
            [YZPermissionManager requestCameraPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case YZPermissionResourcePhotos:
            [YZPermissionManager requestPhotosPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case YZPermissionResourceReminders:
            [YZPermissionManager requestRemindersPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case YZPermissionResourceBluetooth:
            [YZPermissionManager requestBluetoothPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
        case YZPermissionResourceMotion:
            [YZPermissionManager requestMotionPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            break;
    }
}

+ (void)requestNotificationsPermissionWithSetting:(UIUserNotificationSettings *)setting
                                    agreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                  rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    
}

+ (void)requestLocationWhileInUsePermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                         rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            agreedHandler();
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            agreedHandler();
            break;
        case kCLAuthorizationStatusNotDetermined: {
            if ([CLLocationManager locationServicesEnabled]) {
                locationAgent = [[YZLocationAgent alloc] initWithLocationUsage:YZLocationUsageWhenInUse
                                                                 agreedHandler:agreedHandler
                                                               rejectedHandler:rejectedHandler];
                locationManager.delegate = locationAgent;
                [locationManager requestWhenInUseAuthorization];
            } else {
                rejectedHandler(YZPermissionStatusDisabled);
            }
        }
            break;
        default:
            rejectedHandler(YZPermissionStatusUnauthorized);
            break;
    }
}

+ (void)requestLocationAlwaysPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                     rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            agreedHandler();
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            agreedHandler();
            break;
        case kCLAuthorizationStatusNotDetermined: {
            if ([CLLocationManager locationServicesEnabled]) {
                locationAgent = [[YZLocationAgent alloc] initWithLocationUsage:YZLocationUsageAlways
                                                                 agreedHandler:agreedHandler
                                                               rejectedHandler:rejectedHandler];
                locationManager.delegate = locationAgent;
                [locationManager requestAlwaysAuthorization];
            } else {
                rejectedHandler(YZPermissionStatusDisabled);
            }
        }
            break;
        default:
            rejectedHandler(YZPermissionStatusUnauthorized);
            break;
    }
}

+ (void)requestContactsPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                               rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(9.0)) {
        [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts
                                                completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                                        granted ? agreedHandler() : rejectedHandler([YZPermissionManager contactsStatus]);
                                                    });
                                                }];
    } else {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                granted ? agreedHandler() : rejectedHandler([YZPermissionManager contactsStatus]);
            });
        });
    }
}

+ (void)requestEventsPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                             rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [[[EKEventStore alloc] init] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            granted ? agreedHandler() : rejectedHandler([YZPermissionManager eventsStatus]);
        });
    }];
}

+ (void)requestRemindersPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [[[EKEventStore alloc] init] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            granted ? agreedHandler() : rejectedHandler([YZPermissionManager remindersStatus]);
        });
    }];
}

+ (void)requestMicrophonePermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                 rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            granted ? agreedHandler() : rejectedHandler([YZPermissionManager microphoneStatus]);
        });
    }];
}

+ (void)requestCameraPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                             rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            granted ? agreedHandler() : rejectedHandler([YZPermissionManager cameraStatus]);
        });
    }];
}

+ (void)requestPhotosPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                             rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            status == PHAuthorizationStatusAuthorized ? agreedHandler() : rejectedHandler([YZPermissionManager photosStatus]);
        });
    }];
}

+ (void)requestBluetoothPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    
}

+ (void)requestMotionPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                             rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    
}

#pragma mark - check permission
+ (void)notificationsStatusWithCompletionHandler:(YZPermissionCompletionHandler)completionHandler {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(10.0)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusNotDetermined:
                    completionHandler(YZPermissionStatusUnknown);
                    break;
                case UNAuthorizationStatusDenied:
                    completionHandler(YZPermissionStatusUnauthorized);
                    break;
                case UNAuthorizationStatusAuthorized:
                    completionHandler(YZPermissionStatusAuthorized);
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

+ (YZPermissionStatus)locationWhileInUseStatus {
    if ([CLLocationManager locationServicesEnabled]) {
        return YZPermissionStatusDisabled;
    }
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            return YZPermissionStatusAuthorized;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            return YZPermissionStatusUnauthorized;
        case kCLAuthorizationStatusNotDetermined:
            return YZPermissionStatusUnknown;
    }
}

+ (YZPermissionStatus)locationAlwaysStatus {
    if ([CLLocationManager locationServicesEnabled]) {
        return YZPermissionStatusDisabled;
    }
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // TODO: 从低权限到高权限 测试
            return YZPermissionStatusUnknown;
        case kCLAuthorizationStatusAuthorizedAlways:
            return YZPermissionStatusAuthorized;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            return YZPermissionStatusUnauthorized;
        case kCLAuthorizationStatusNotDetermined:
            return YZPermissionStatusUnknown;
    }
}

+ (YZPermissionStatus)contactsStatus {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(9.0)) {
        CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        
        switch (authorizationStatus) {
            case CNAuthorizationStatusDenied:
            case CNAuthorizationStatusRestricted:
                return YZPermissionStatusUnauthorized;
            case CNAuthorizationStatusAuthorized:
                return YZPermissionStatusAuthorized;
            case CNAuthorizationStatusNotDetermined:
                return YZPermissionStatusUnknown;
        }
    } else {
        ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
        switch (authorizationStatus) {
            case kABAuthorizationStatusAuthorized:
                return YZPermissionStatusAuthorized;
            case kABAuthorizationStatusRestricted:
            case kABAuthorizationStatusDenied:
                return YZPermissionStatusUnauthorized;
            case kABAuthorizationStatusNotDetermined:
                return YZPermissionStatusUnknown;
            default:
                break;
        }
    }
}

+ (YZPermissionStatus)eventsStatus {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusNotDetermined:
            return YZPermissionStatusUnknown;
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied:
            return YZPermissionStatusUnauthorized;
        case EKAuthorizationStatusAuthorized:
            return YZPermissionStatusAuthorized;
        default:
            break;
    }
}

+ (YZPermissionStatus)remindersStatus {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusNotDetermined:
            return YZPermissionStatusUnknown;
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied:
            return YZPermissionStatusUnauthorized;
        case EKAuthorizationStatusAuthorized:
            return YZPermissionStatusAuthorized;
        default:
            break;
    }
}

+ (YZPermissionStatus)microphoneStatus {
    AVAudioSessionRecordPermission authorizationStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (authorizationStatus) {
        case AVAudioSessionRecordPermissionDenied:
            return YZPermissionStatusUnauthorized;
        case AVAudioSessionRecordPermissionGranted:
            return YZPermissionStatusAuthorized;
        case AVAudioSessionRecordPermissionUndetermined:
            return YZPermissionStatusUnknown;
    }
}

+ (YZPermissionStatus)cameraStatus {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusAuthorized:
            return YZPermissionStatusAuthorized;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            return YZPermissionStatusUnauthorized;
        case AVAuthorizationStatusNotDetermined:
            return YZPermissionStatusUnknown;
    }
}

+ (YZPermissionStatus)photosStatus {
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    switch (authorizationStatus) {
        case PHAuthorizationStatusAuthorized:
            return YZPermissionStatusAuthorized;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            return YZPermissionStatusUnauthorized;
        case PHAuthorizationStatusNotDetermined:
            return YZPermissionStatusUnknown;
    }
}


+ (YZPermissionStatus)bluetoothStatus {
    return YZPermissionStatusUnknown;
}

+ (YZPermissionStatus)motionStatus {
    return YZPermissionStatusUnknown;
}

@end

#pragma clang diagnostic pop
