//
//  SettingsSplitViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "SettingsSplitViewController.h"

#import "MainSettingsTableViewController.h"
#import "IASKAppSettingsViewController.h"
#import "GroupSettingsTableViewController.h"

#import "SettingManagerNotificationNames.h"

@interface SettingsSplitViewController() <MainSettingsTableViewControllerDelegate,IASKSettingsDelegate>

@property (nonatomic,readonly) MainSettingsTableViewController *leftSideSettingViewController;
@property (nonatomic,readonly) IASKAppSettingsViewController *rightSideSettingViewController;

@end

@implementation SettingsSplitViewController 

#pragma mark - Getters and Setters

- (MainSettingsTableViewController *)leftSideSettingViewController {
    UINavigationController *masterNav=(UINavigationController *)self.masterViewController;
    return (MainSettingsTableViewController *)masterNav.topViewController;
}

- (UINavigationController *)rightSideNav {
    UINavigationController *detailNav=(UINavigationController *)self.detailViewController;
    return detailNav;
}

- (IASKAppSettingsViewController *)rightSideSettingViewController {
    return (IASKAppSettingsViewController *)self.rightSideNav.topViewController;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set the customSplitViewController properties of the master and detail
    if ([self.masterViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *masterNav=(UINavigationController *)self.masterViewController;
        if ([masterNav.topViewController conformsToProtocol:@protocol(CustomSplitViewControllerChildren)]) {
            UIViewController<CustomSplitViewControllerChildren> *masterViewController=(UIViewController<CustomSplitViewControllerChildren> *)masterNav.topViewController;
            masterViewController.customSplitViewController=self;
        }
    }
    
    if ([self.detailViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *detailNav=(UINavigationController *)self.detailViewController;
        if ([detailNav.topViewController conformsToProtocol:@protocol(CustomSplitViewControllerChildren)]) {
            UIViewController<CustomSplitViewControllerChildren> *detailViewController=(UIViewController<CustomSplitViewControllerChildren> *)detailNav.topViewController;
            detailViewController.customSplitViewController=self;
        }
    }
    
    //Set the title of the right side view controller
    self.rightSideSettingViewController.navigationItem.title=@"Color";
    
    //Set the delegate of the settings tvc
    self.leftSideSettingViewController.delegate=self;
}

#pragma mark - MainSettingsTableViewControllerDelegate methods

- (void)mainSettingsTVC:(MainSettingsTableViewController *)sender userDidSelectSettingPaneWithTitle:(NSString *)paneTitle {
    
    NSLog(@"PaneTitle: %@", paneTitle);
    
    //If the current rhs table is the group settings table, pop
    if ([self.rightSideSettingViewController isKindOfClass:[GroupSettingsTableViewController class]])
        [self.rightSideNav popToRootViewControllerAnimated:YES];
    
    //Pop the left side's navigation controller all the way to root
    UINavigationController *detailNav=(UINavigationController *)self.detailViewController;
    [detailNav popToRootViewControllerAnimated:NO];
    
    //Set the .plist file to be loaded of the left side settings tvc to the pane title
    self.rightSideSettingViewController.file=paneTitle;
    
    //Set the title
    self.rightSideSettingViewController.navigationItem.title=paneTitle;
}

- (void)userDidSelectGroupSettingsInMainSettingsTVC:(MainSettingsTableViewController *)sender {
    //Segue to the group settings table view
    if (![self.rightSideSettingViewController isKindOfClass:[GroupSettingsTableViewController class]])
        [self.rightSideSettingViewController performSegueWithIdentifier:@"Group Settings" sender:nil];
}

- (void)userDidPressCancel:(MainSettingsTableViewController *)sender {
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - iASKSettingsDelegate Protocol Methods

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender {
    //Broadcast
    [[NSNotificationCenter defaultCenter] postNotificationName:SettingManagerUserPreferencesDidChange object:self];
}

@end
