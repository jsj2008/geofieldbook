//
//  GroupSettingsTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GroupSettingsTableViewController.h"

#import "SettingManager.h"

#import "IEEngine.h"

@interface GroupSettingsTableViewController()

@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *groupIDLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *createGroupCell;

@end

@implementation GroupSettingsTableViewController 

@synthesize groupNameTextField=_groupNameTextField;
@synthesize groupIDLabel = _groupIDLabel;
@synthesize createGroupCell = _createGroupCell;

- (SettingManager *)settingManager {
     return [SettingManager standardSettingManager];
}

- (void)updateMetadataOfFeedbackCSVFile {
    //Update
    IEEngine *engine=[[IEEngine alloc] init];
    NSDictionary *metadata=[NSDictionary dictionaryWithObjectsAndKeys:self.settingManager.groupName,IEEngineFeedbackGroupName,
                            self.settingManager.groupID,IEEngineFeedbackGroupID, nil];
    [engine updateFeedbackFileWithInfo:metadata];
}

#pragma mark - Target-Action Handlers

- (IBAction)groupNameDidChange:(UITextField *)sender {
    //Save the group name to the settings
    if (sender.text.length) {
        self.settingManager.groupName=sender.text;
        sender.placeholder=sender.text;
        
        //Update metadata of feedback csv file
        [self updateMetadataOfFeedbackCSVFile];
    }
    else
        sender.text=self.settingManager.groupName;
}

- (void)createNewGroup {
    //create a group id
    NSString *groupID=[SettingManager generateGroupID];
    
    //Set the label
    self.groupIDLabel.text=groupID;
    
    //Update metadata of feedback csv file
    [self updateMetadataOfFeedbackCSVFile];
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
