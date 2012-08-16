//
//  SettingsSplitViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomSplitViewController.h"

#import "SettingsSplitViewControllerDelegate.h"

@interface SettingsSplitViewController : CustomSplitViewController

@property (nonatomic,weak) id <SettingsSplitViewControllerDelegate> delegate;

@end
