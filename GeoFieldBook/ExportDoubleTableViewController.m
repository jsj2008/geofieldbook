//
//  ExportDoubleTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ExportDoubleTableViewController.h"

#import "ExportFolderTableViewController.h"
#import "ExportRecordTableViewController.h"

#import "ExportFormationFolderTableViewController.h"
#import "ExportFormationTableViewController.h"

#import "IEEngine.h"

@interface ExportDoubleTableViewController()

@property (nonatomic,strong) IEEngine *exportEngine;

@end

@implementation ExportDoubleTableViewController

@synthesize exportEngine=_exportEngine;

#pragma mark - Getters

- (IEEngine *)exportEngine {
    if (!_exportEngine)
        _exportEngine=[[IEEngine alloc] init];
    
    return _exportEngine;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.masterTableViewController isKindOfClass:[ExportFolderTableViewController class]]) {
        ExportFolderTableViewController *exportRecordTVC = (ExportFolderTableViewController *)self.masterTableViewController;
        [(ExportRecordTableViewController *)self.detailTableViewController setDelegate:exportRecordTVC];
    }
    else if ([self.masterTableViewController isKindOfClass:[ExportFormationFolderTableViewController class]]) {
        ExportFormationFolderTableViewController *exportFormationsTVC = (ExportFormationFolderTableViewController *)self.masterTableViewController;
        [(ExportFormationTableViewController *)self.detailTableViewController setDelegate:exportFormationsTVC];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Target-Action Handlers

- (IBAction)exportPressed:(UIBarButtonItem *)sender {
    //Export the records
    NSArray *exportedItems;
    
    if ([self.masterTableViewController isKindOfClass:[ExportFolderTableViewController class]]) {
        exportedItems = [(ExportFolderTableViewController *)self.masterTableViewController selectedRecords];
    }
    else if ([self.masterTableViewController isKindOfClass:[ExportFormationFolderTableViewController class]]) {
        exportedItems = [(ExportFormationFolderTableViewController *)self.masterTableViewController selectedFormations];
    }
    
    [self.exportEngine createCSVFilesFromRecords:exportedItems];
}

@end
