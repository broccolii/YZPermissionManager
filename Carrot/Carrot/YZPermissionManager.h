//
//  PermissionManager.h
//  Carrot
//
//  Created by Broccoli on 2017/2/4.
//  Copyright © 2017年 broccoliii. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PermissionStatus) {
    PermissionStatusUnknown,
    PermissionStatusAuthorized,
    PermissionStatusUnauthorized,
    PermissionStatusDisabled
};

typedef NS_ENUM(NSInteger, PermissionResource) {
    PermissionResourceNotifications,
    PermissionResourceLocationWhileInUse,
    PermissionResourceLocationAlways,
    PermissionResourceContacts,
    PermissionResourceEvents,
    PermissionResourceMicrophone,
    PermissionResourceCamera,
    PermissionResourcePhotos,
    PermissionResourceReminders,
    PermissionResourceBluetooth,
    PermissionResourceMotion
};

@interface YZPermissionManager : NSObject
// check permission
// request permission
+ (void)requestPermissionWithResource:(PermissionResource)resource
                        agreedHandler:(void(^)())agreedHandler
                      rejectedHandler:(void(^)())rejectedHandler;

+ (void)notificationsStatusWithCompletionHandler:(void(^)(PermissionStatus permissionStatus))completionHandler;
+ (PermissionStatus)locationWhileInUseStatus;
+ (PermissionStatus)locationAlwaysStatus;
+ (PermissionStatus)contactsStatus;
+ (PermissionStatus)eventsStatus;
+ (PermissionStatus)microphoneStatus;
+ (PermissionStatus)cameraStatus;
+ (PermissionStatus)photosStatus;
+ (PermissionStatus)remindersStatus;
+ (PermissionStatus)bluetoothStatus;
+ (PermissionStatus)motionStatus;

@end
