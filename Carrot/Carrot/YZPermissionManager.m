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

@class  YZLocationAgent;

static YZLocationAgent *locationAgent;
static CLLocationManager *locationManager;

@interface YZLocationAgent: NSObject<CLLocationManagerDelegate>

@property (nonatomic, copy) YZPermissionAgreedHandler agreedHandler;
@property (nonatomic, copy) YZPermissionRejectedHandler rejectHandler;

@end

@implementation YZLocationAgent

- (instancetype)initWithAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                      rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.agreedHandler = agreedHandler;
    self.rejectHandler = rejectedHandler;
    
    return self;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (status) {
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            case kCLAuthorizationStatusAuthorizedAlways: {
                self.agreedHandler();
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


static NSString * const kRequestNotificationPermission = @"com.YZPermission.kRequestNotificationPermission";
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
    
    // TODO:
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kRequestNotificationPermission];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        self.agreedHandler();
    } else {
        self.rejectHandler(YZPermissionStatusUnknown);
    }
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
    }
}

+ (void)requestPermissionWithResource:(YZPermissionResource)resource
                        agreedHandler:(YZPermissionAgreedHandler)agreedHandler
                      rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    
    switch (resource) {
        case YZPermissionResourceNotifications:
            //            [YZPermissionManager requestNotificationsPermissionAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
            NSAssert(NO, @"use requestNotificationsPermissionWithSetting");
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
    }
}

static YZNotificationAgent *notificationAgent = nil;
+ (void)requestNotificationsPermissionWithSetting:(UIUserNotificationSettings *)setting
                                    agreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                  rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [YZPermissionManager notificationsStatusWithCompletionHandler:^(YZPermissionStatus status) {
        switch (status) {
            case YZPermissionStatusAuthorized: {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(10.0)) {
                    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        if (granted) {
                            agreedHandler();
                        } else {
                            rejectedHandler(YZPermissionStatusUnauthorized);
                        }
                    }];
                } else {
                    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
                    agreedHandler();
                }
            }
                break;
            case YZPermissionStatusUnknown:{
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(10.0)) {
                    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        if (granted) {
                            agreedHandler();
                        } else {
                            rejectedHandler(YZPermissionStatusUnauthorized);
                        }
                    }];
                } else {
                    notificationAgent = [[YZNotificationAgent alloc] initWithFinishedRequestingAgreedHandler:agreedHandler rejectedHandler:rejectedHandler];
                    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
                }
            }
                break;
            default:
                break;
        }
    }];
}

+ (void)requestLocationWhileInUsePermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                         rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    
    locationAgent = [[YZLocationAgent alloc] initWithAgreedHandler:agreedHandler
                                                   rejectedHandler:rejectedHandler];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = locationAgent;
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            agreedHandler();
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [locationManager requestWhenInUseAuthorization];
            break;
        case kCLAuthorizationStatusNotDetermined:
            [locationManager requestWhenInUseAuthorization];
            break;
        default:
            rejectedHandler(YZPermissionStatusUnauthorized);
            break;
    }
}

+ (void)requestLocationAlwaysPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                     rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    
    locationAgent = [[YZLocationAgent alloc] initWithAgreedHandler:agreedHandler
                                                   rejectedHandler:rejectedHandler];
    locationManager.delegate = locationAgent;
    locationManager = [[CLLocationManager alloc] init];
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [locationManager requestAlwaysAuthorization];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            agreedHandler();
            break;
        case kCLAuthorizationStatusNotDetermined:
            [locationManager requestAlwaysAuthorization];
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
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        granted ? agreedHandler() : rejectedHandler([YZPermissionManager contactsStatus]);
                                                    });
                                                }];
    } else {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                granted ? agreedHandler() : rejectedHandler([YZPermissionManager contactsStatus]);
            });
        });
    }
}

+ (void)requestEventsPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                             rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [[[EKEventStore alloc] init] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            granted ? agreedHandler() : rejectedHandler([YZPermissionManager eventsStatus]);
        });
    }];
}

+ (void)requestRemindersPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [[[EKEventStore alloc] init] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            granted ? agreedHandler() : rejectedHandler([YZPermissionManager remindersStatus]);
        });
    }];
}

+ (void)requestMicrophonePermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                                 rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            granted ? agreedHandler() : rejectedHandler([YZPermissionManager microphoneStatus]);
        });
    }];
}

+ (void)requestCameraPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                             rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            granted ? agreedHandler() : rejectedHandler([YZPermissionManager cameraStatus]);
        });
    }];
}

+ (void)requestPhotosPermissionAgreedHandler:(YZPermissionAgreedHandler)agreedHandler
                             rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            status == PHAuthorizationStatusAuthorized ? agreedHandler() : rejectedHandler([YZPermissionManager photosStatus]);
        });
    }];
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
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            completionHandler(YZPermissionStatusAuthorized);
        } else {
            completionHandler(YZPermissionStatusUnknown);
        }
    }
}

+ (YZPermissionStatus)locationWhileInUseStatus {
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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(8.0)) {
        ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
        switch (authorizationStatus) {
            case ALAuthorizationStatusNotDetermined:
                return YZPermissionStatusUnknown;
                break;
            case ALAuthorizationStatusRestricted:
            case ALAuthorizationStatusDenied:
                return YZPermissionStatusUnauthorized;
                break;
            case ALAuthorizationStatusAuthorized:
                return YZPermissionStatusAuthorized;
                break;
        }
    } else {
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
}

// TODO:
+ (YZPermissionStatus)bluetoothStatus {
    return YZPermissionStatusUnknown;
}

+ (YZPermissionStatus)motionStatus {
    return YZPermissionStatusUnknown;
}

@end

#pragma clang diagnostic pop
