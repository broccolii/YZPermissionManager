//
//  ViewController.m
//  Carrot
//
//  Created by Broccoli on 2017/2/4.
//  Copyright © 2017年 broccoliii. All rights reserved.
//

#import "MainViewController.h"
#import "YZPermissionManager.h"
#import "PermissionViewController.h"

NSString *YZPermissionResourceNameMapping[] = {
    [YZPermissionResourceNotifications] = @"Notifcations",
    [YZPermissionResourceLocationWhileInUse] = @"LocationWhileInUse",
    [YZPermissionResourceLocationAlways] = @"LocationAlways",
    [YZPermissionResourceContacts] = @"Contacts",
    [YZPermissionResourceEvents] = @"Events",
    [YZPermissionResourceMicrophone] = @"Microphone",
    [YZPermissionResourceCamera] = @"Camera",
    [YZPermissionResourcePhotos] = @"Photos",
    [YZPermissionResourceReminders] = @"Reminders",
    [YZPermissionResourceBluetooth] = @"Bluetooth",
    [YZPermissionResourceMotion] = @"Motion"
};

@interface YZPermissionCellItem : NSObject

@property (nonatomic, assign) YZPermissionResource resource;
@property (nonatomic, strong) NSString *resourceDesc;

@end

@implementation YZPermissionCellItem

+ (instancetype)itemWithResource:(YZPermissionResource)resource {
    YZPermissionCellItem *item = [[YZPermissionCellItem alloc] init];
    if (!item) {
        return nil;
    }
    item.resource = resource;
    item.resourceDesc = YZPermissionResourceNameMapping[resource];
    return item;
}

@end



@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSArray<YZPermissionCellItem *> *dataSource;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YZPermissionCell"];
    
    cell.textLabel.text = self.dataSource[indexPath.row].resourceDesc;
    
    return cell;
}

#pragma mark - UITableViewDelelgate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PermissionViewController *permissionViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([PermissionViewController class])];
    permissionViewController.permissionResource = self.dataSource[indexPath.row].resource;
    [self.navigationController pushViewController:permissionViewController animated:YES];
}

#pragma mark - getter
- (NSArray<YZPermissionCellItem *> *)dataSource {
    if (!_dataSource) {
        NSMutableArray *items = [NSMutableArray array];
        
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourceNotifications]];
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourceLocationWhileInUse]];
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourceLocationAlways]];
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourceContacts]];
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourceEvents]];
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourceMicrophone]];
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourceCamera]];
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourcePhotos]];
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourceReminders]];
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourceBluetooth]];
        [items addObject:[YZPermissionCellItem itemWithResource:YZPermissionResourceMotion]];
        
        _dataSource = items;
    }
    return _dataSource;
}

@end
