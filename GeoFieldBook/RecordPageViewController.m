//
//  RecordPageViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordPageViewController.h"

@interface RecordPageViewController()

@end

@implementation RecordPageViewController

@synthesize flipViewController=_flipViewController;
@synthesize delegate=_delegate;

@synthesize record=_record;

#pragma mark - Getters and Setters

- (void)updateRecord:(Record *)record {
    if (record!=self.record) {
        //Update record
        self.record=record;
        
        //Set the record of the currently active record vc
        self.currentRecordViewController.record=record;
    }
}

- (RecordViewController *)currentRecordViewController {
    return (RecordViewController *)self.flipViewController.viewController;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    	
	// Configure the page view controller and add it as a child view controller.
	self.flipViewController = [[MPFlipViewController alloc] initWithOrientation:[self flipViewController:nil orientationForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation]];
	self.flipViewController.delegate = self;
	self.flipViewController.dataSource = self;
	
	// Set the page view controller's bounds
	self.flipViewController.view.frame = self.view.bounds;
	[self addChildViewController:self.flipViewController];
	[self.view addSubview:self.flipViewController.view];
	[self.flipViewController didMoveToParentViewController:self];
	
    //Create the initial record vc
    RecordViewController *recordVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Record Detail View Controller"];
	[self.flipViewController setViewController:recordVC direction:MPFlipViewControllerDirectionForward animated:NO completion:^(BOOL success){
        if (success && self.record)
            recordVC.record=self.record;
    }];
	
	// Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
	self.view.gestureRecognizers = self.flipViewController.gestureRecognizers;
}

#pragma mark - MPFlipViewControllerDelegate protocol

- (void)flipViewController:(MPFlipViewController *)flipViewController didFinishAnimating:(BOOL)finished previousViewController:(UIViewController *)previousViewController transitionCompleted:(BOOL)completed
{
	//Update the current record
    RecordViewController *recordVC=(RecordViewController *)flipViewController.viewController;
    self.record=recordVC.record;
    
    //Notify delegate
    [self.delegate recordPage:self isTurningToRecordViewController:recordVC];
}

- (MPFlipViewControllerOrientation)flipViewController:(MPFlipViewController *)flipViewController orientationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return MPFlipViewControllerOrientationHorizontal;
}

#pragma mark - MPFlipViewControllerDataSource protocol

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	//Get the previous record
    Record *record=[self.delegate recordPage:self recordBeforeRecord:self.record];
    RecordViewController *recordVC=nil;
    
    if (record) {
        //Create a new record vc
        recordVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Record Detail View Controller"];
        recordVC.record=record;
    }
    
    return recordVC;
}

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	//Get the next record
    Record *record=[self.delegate recordPage:self recordAfterRecord:self.record];
    RecordViewController *recordVC=nil;
    
    if (record) {
        //Create a new record vc
        recordVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Record Detail View Controller"];
        recordVC.record=record;
    }
    
    return recordVC;
}

@end
