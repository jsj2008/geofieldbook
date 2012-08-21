//
//  DataMapSegmentViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "DataMapSegmentViewController.h"

#import "FormationFolderTableViewController.h"
#import "GeoDatabaseManager.h"
#import "ModelGroupNotificationNames.h"

@interface DataMapSegmentViewController()

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) UIPopoverController *formationFolderPopoverController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dataMapSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importExportButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *formationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingButton;

@property (readonly, nonatomic) RecordPageViewController *recordPageViewController;
@property (readonly, nonatomic) RecordViewController *recordViewController;

@property (readonly, nonatomic) RecordMapViewController *mapViewController;

@end

@implementation DataMapSegmentViewController

@synthesize toolbar=_toolbar;
@synthesize formationFolderPopoverController=_formationFolderPopoverController;
@synthesize dataMapSwitch = _dataMapSwitch;
@synthesize importExportButton = _importExportButton;
@synthesize formationButton = _formationButton;
@synthesize settingButton = _settingButton;

@synthesize animationOption=_animationOption;

@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (UIViewController *)detailSideViewController {
    return [self.viewControllers objectAtIndex:0];
}

- (RecordPageViewController *)recordPageViewController {
    if ([self.detailSideViewController isKindOfClass:[RecordPageViewController class]])
        return (RecordPageViewController *)self.detailSideViewController;
    else
        return nil;
}

- (RecordViewController *)recordViewController {
    return self.recordPageViewController.currentRecordViewController;
}

- (RecordMapViewController *)mapViewController {
    id mapVC=[self.viewControllers lastObject];
    if (![mapVC isKindOfClass:[RecordMapViewController class]])
        mapVC=nil;
    
    return mapVC;
}

//Determine the type of animation
- (TransionAnimationOption)animationOption {
    return self.currentViewController==self.viewControllers.lastObject ? TransitionAnimationFlipLeft : TransitionAnimationFlipRight;
}

#pragma mark - Record Page View Controller Data Forward Mechanisms

- (void)setRecordPageViewControllerDelegate:(id <RecordPageViewControllerDelegate>)delegate {
    self.recordPageViewController.delegate=delegate;
}

#pragma mark - Record View Controller Data Forward Mechanisms

- (void)dismissKeyboardInDataSideView {
    if ([self.detailSideViewController isKindOfClass:[RecordViewController class]])
        [(RecordViewController *)self.detailSideViewController resignAllTextFieldsAndAreas];
}

- (void)setRecordViewControllerDelegate:(id <RecordViewControllerDelegate>)delegate {
    //Set the delegate of the record detail vc
    self.recordViewController.delegate=delegate;
}

- (void)updateRecordDetailViewWithRecord:(Record *)record {
    //Set the record of the record detail vc
    [self.recordPageViewController updateRecord:record];
}

- (void)putRecordViewControllerIntoEditingMode {
    //Put the record view controller into edit mode
    [self.recordViewController setEditing:YES animated:YES];
    [self.recordViewController showKeyboard];
}

- (void)resetRecordViewController {
    //Cancel the record view controller's edit mode
    [self.recordViewController cancelEditingMode];
}

#pragma mark - Record Map View Controller Data Forward Mechanisms

- (void)setMapViewDelegate:(id<RecordMapViewControllerDelegate>)mapDelegate {
    //Set the map delegate of the map vc
    self.mapViewController.mapDelegate=mapDelegate;
}

- (void)updateMapWithRecords:(NSArray *)records forceUpdate:(BOOL)willForceUpdate updateRegion:(BOOL)willUpdateRegion {
    //Set the records of the record map view controller if it's in the view controller array
    [self.mapViewController updateRecords:records forceUpdate:willForceUpdate updateRegion:willUpdateRegion];
}

- (void)setMapSelectedRecord:(Record *)selectedRecord {
    self.mapViewController.selectedRecord=selectedRecord;
}

- (void)reloadMapAnnotationViews {
    [self.mapViewController reloadAnnotationViews];
}

#pragma mark - View Controller Manipulation (Pushing, Poping, Swapping)

- (void)swapToViewControllerAtSegmentIndex:(int)segmentIndex {
    [super swapToViewControllerAtSegmentIndex:segmentIndex];
    
    //Allow the delegate (the big controller) to jump in
    [self.delegate dataMapSegmentController:self isSwitchingToViewController:[self.viewControllers objectAtIndex:segmentIndex]];
}

- (void)pushRecordViewController {
    if (!self.recordPageViewController) {
        [self performSegueWithIdentifier:RECORD_PAGE_VIEW_CONTROLLER_IDENTIFIER sender:nil];
        if (!self.topViewController)
            [self swapToViewControllerAtSegmentIndex:0];
    }
}

- (void)pushInitialViewController {    
    [self performSegueWithIdentifier:@"Initial View Controller" sender:nil];
    if (!self.topViewController)
        [self swapToViewControllerAtSegmentIndex:0];
}

#pragma mark - KVO/NSNotification Managers

- (void)modelGroupUserDidSelectRecord:(NSNotification *)notification {
    //Get the selected record
    Record *selectedRecord=[notification.userInfo objectForKey:GeoNotificationKeyModelGroupSelectedRecord];
    
    //Push the detail
    [self pushRecordViewController];
    
    //Update the detail side
    [self updateRecordDetailViewWithRecord:selectedRecord];
    
    //Update the map
    [self setMapSelectedRecord:selectedRecord];    
}

- (void)registerForModelGroupNotifications {
    //Register to receive notifications from the model group
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self 
                           selector:@selector(modelGroupUserDidSelectRecord:) 
                               name:GeoNotificationModelGroupDidSelectRecord 
                             object:nil];
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSMutableArray *viewControllers=self.viewControllers.mutableCopy;
    UIViewController *newViewController=nil;
    int index=0;
    if ([segue.identifier isEqualToString:@"Initial View Controller"]) {
        //Instantiate the initial view controller
        newViewController=[self.storyboard instantiateViewControllerWithIdentifier:INITIAL_DETAIL_VIEW_CONTROLLER_IDENTIFIER];
    }
    
    else if ([segue.identifier isEqualToString:@"Map View Controller"]) {
        //Instantiate the record map view controller
        newViewController=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_MAP_VIEW_CONTROLLER_IDENTIFIER];
        index=1;
    }
    
    else if ([segue.identifier isEqualToString:@"Record Page View Controller"]) {
        //Instantiate the record page view controller
        newViewController=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_PAGE_VIEW_CONTROLLER_IDENTIFIER];
    }
    
    if (viewControllers.count<index+1) {
        [viewControllers addObject:newViewController];
        self.viewControllers=viewControllers.copy;
    }
    else if ([viewControllers objectAtIndex:index])
        [self replaceViewControllerAtSegmentIndex:index withViewController:newViewController];
    else {
        [viewControllers insertObject:newViewController atIndex:index];
        self.viewControllers=viewControllers.copy;
    }    
}

#pragma mark - View Controller Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //Instantiate the intial and map view controllers
    [self performSegueWithIdentifier:@"Initial View Controller" sender:nil];
    [self performSegueWithIdentifier:@"Map View Controller" sender:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Show the initial view
    [self swapToViewControllerAtSegmentIndex:0];
    
    //Subscribe to Model Group
    [self registerForModelGroupNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setDataMapSwitch:nil];
    [self setSettingButton:nil];
    [super viewDidUnload];
    
    //Remove self as observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
