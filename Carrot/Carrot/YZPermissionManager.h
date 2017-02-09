//
//  PermissionManager.h
//  Carrot
//
//  Created by Broccoli on 2017/2/4.
//  Copyright © 2017年 broccoliii. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YZPermissionStatus) {
    YZPermissionStatusUnknown,
    YZPermissionStatusAuthorized,
    YZPermissionStatusUnauthorized,
    YZPermissionStatusDisabled
};

typedef NS_ENUM(NSInteger, YZPermissionResource) {
    YZPermissionResourceNotifications,
    YZPermissionResourceLocationWhileInUse,
    YZPermissionResourceLocationAlways,
    YZPermissionResourceContacts,
    YZPermissionResourceEvents,
    YZPermissionResourceMicrophone,
    YZPermissionResourceCamera,
    YZPermissionResourcePhotos,
    YZPermissionResourceReminders,
    YZPermissionResourceBluetooth,
    YZPermissionResourceMotion
};

typedef void(^YZPermissionAgreedHandler)();
typedef void(^YZPermissionRejectedHandler)(YZPermissionStatus status);
typedef void(^YZPermissionCompletionHandler)(YZPermissionStatus status);

@interface YZPermissionManager : NSObject

/**
 check permission

 @param resource permission type
 @param completionHandler return permission status
 */
+ (void)checkPermissionWithResource:(YZPermissionResource)resource
                  completionHandler:(YZPermissionCompletionHandler)completionHandler;

/**
 request permission

 @param resource permission type
 @param agreedHandler the action after the success of the permission
 @param rejectedHandler the action after the permissions failed
 */
+ (void)requestPermissionWithResource:(YZPermissionResource)resource
                        agreedHandler:(YZPermissionAgreedHandler)agreedHandler
                      rejectedHandler:(YZPermissionRejectedHandler)rejectedHandler;

@end
