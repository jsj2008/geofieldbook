//
//  GroupSettingsTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GroupSettingsTableViewController.h"

#import "SettingManager.h"

@interface GroupSettingsTableViewController()

@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *groupIDLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *createGroupCell;

@end

@implementation GroupSettingsTableViewController 

@synthesize groupNameTextField=_groupNameTextField;
@synthesize groupIDLabel = _groupIDLabel;
@synthesize createGroupCell = _createGroupCell;

#pragma mark - Target-Action Handlers

- (IBAction)groupNameDidChange:(UITextField *)sender {
    //Save the group name to the settings
    SettingManager *manager=[SettingManager standardSettingManager];
    if (sender.text.length) {
        manager.groupName=sender.text;
        sender.placeholder=sender.text;
    }
    else
        sender.text=manager.groupName;
}

- (void)createNewGroup {
    //create a group id
    NSString *groupID=[SettingManager generateGroupID];
    
    //Set the label
    self.groupIDLabel.text=groupID;
}

#pragma mark - UITableViewDelegate Protocol Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the selected cell has title "Create New Group", create a new student group and deselect it
    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"Create New Group"]) {
        [self createNewGroup];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Populate the group id label
    SettingManager *manager=[SettingManager standardSettingManager];
    self.groupIDLabel.text=manager.groupID;
    
    //Populate the group name
    self.groupNameTextField.text=manager.groupName;
    self.groupNameTextField.placeholder=self.groupNameTextField.text;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setGroupNameTextField:nil];
    [self setGroupIDLabel:nil];
    [self setCreateGroupCell:nil];
    [super viewDidUnload];
}

@end
