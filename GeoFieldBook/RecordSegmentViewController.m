//
//  RecordSegmentViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordSegmentViewController.h"

@interface RecordSegmentViewController ()

@end

@implementation RecordSegmentViewController

@synthesize database=_database;
@synthesize folder=_folder;
@synthesize delegate=_delegate;
@synthesize chosenRecord=_chosenRecord;

- (void)setDatabase:(UIManagedDocument *)database {
    _database=database;
    
    //Transfer the data to the content record tvcs
    [self transferDataToContentRecordTVCs];
}

- (void)setFolder:(Folder *)folder {
    _folder=folder;
    
    //Transfer the data to the content record tvcs
    [self transferDataToContentRecordTVCs];
}

- (void)setDelegate:(id<RecordTableViewControllerDelegate>)delegate {
    _delegate=delegate;
    
    //Transfer the data to the content record tvcs
    [self transferDataToContentRecordTVCs];
}

- (void)setChosenRecord:(Record *)chosenRecord {
    _chosenRecord=chosenRecord;
    
    //Transfer the data to the content record tvcs
    [self transferDataToContentRecordTVCs];
}

- (TransionAnimationOption)animationOption {
    return TransionAnimationNone;
}

- (void)transferDataToContentRecordTVCs {
    for (RecordTableViewController *recordTVC in self.viewControllers) {
        recordTVC.database=self.database;
        recordTVC.folder=self.folder;
        recordTVC.delegate=self.delegate;
        if (self.chosenRecord)
            recordTVC.chosenRecord=self.chosenRecord;
    }
}

#pragma mark - View Controller Manipulation (Pushing, Poping, Swapping)

- (void)swapToViewControllerAtSegmentIndex:(int)segmentIndex {
    [super swapToViewControllerAtSegmentIndex:segmentIndex];
    
    //Transfer the toolbar items in the swapped-to vc to the current vc
    NSMutableArray *toolbarItems=[NSMutableArray array];
    for (UIBarButtonItem *item in self.topViewController.toolbarItems)
        [toolbarItems addObject:item];
    self.toolbarItems=toolbarItems.copy;
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"By Name"]) {
        RecordByNameTVC *recordByNameTVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Records By Name"];
        [self pushViewController:recordByNameTVC];
    } 
    
    else if ([segue.identifier isEqualToString:@"By Date"]) {
        RecordByNameTVC *recordByDateTVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Records By Date"];
        [self pushViewController:recordByDateTVC];
    }
    
    else if ([segue.identifier isEqualToString:@"By Type"]) {
        RecordByNameTVC *recordByTypeTVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Records By Type"];
        [self pushViewController:recordByTypeTVC];
    }
}

#pragma mark - Target-Action Handlers

- (IBAction)recordOrderChanged:(UISegmentedControl *)sender {
    int segmentIndex=sender.selectedSegmentIndex;
    [self segmentController:sender indexDidChangeTo:segmentIndex];
}


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Perform all custom sgues
    [self performSegueWithIdentifier:@"By Name" sender:nil];
    [self performSegueWithIdentifier:@"By Date" sender:nil];
    [self performSegueWithIdentifier:@"By Type" sender:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Transfer the data to the content record tvcs
    [self transferDataToContentRecordTVCs];
    
    //Swap to show records by date
    [self swapToViewControllerAtSegmentIndex:1];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
