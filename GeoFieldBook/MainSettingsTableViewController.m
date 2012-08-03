//
//  MainSettingsTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MainSettingsTableViewController.h"

@interface MainSettingsTableViewController ()

@end

@implementation MainSettingsTableViewController

@synthesize customSplitViewController=_customSplitViewController;

@synthesize delegate=_delegate;

#pragma mark - View Controller Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Select the first row
    NSIndexPath *selectedIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewRowAnimationNone];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Target - Action Handlers

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    //Notify delegate
    [self.delegate userDidPressCancel:self];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedRowTitle=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    //If user selected any but "Group Settings", notify delegate
    if (![selectedRowTitle isEqualToString:@"Group Settings"])
        [self.delegate mainSettingsTVC:self userDidSelectSettingPaneWithTitle:selectedRowTitle];
    
    //Else segue the right handside table
    else
        [self.delegate userDidSelectGroupSettingsInMainSettingsTVC:self];
}

@end
