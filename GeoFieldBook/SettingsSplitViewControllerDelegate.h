//
//  SettingsSplitViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SettingsSplitViewController;

@protocol SettingsSplitViewControllerDelegate <NSObject>

- (NSString *)currentFolderTitleForSettingsViewController:(SettingsSplitViewController *)sender;

@end
