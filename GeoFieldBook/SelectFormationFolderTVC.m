//
//  SelectFormationFolderTVC.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "SelectFormationFolderTVC.h"

@interface SelectFormationFolderTVC()

@end

@implementation SelectFormationFolderTVC

@synthesize delegate=_delegate;

#pragma mark - Target-Action Handlers

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate protocol methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Call the delegate
    Formation_Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate formationFolderSelectTVC:self userDidSelectFormationFolder:folder];
}

#pragma mark - View Controller Lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
