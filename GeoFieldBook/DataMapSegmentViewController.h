//
//  DataMapSegmentViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "SegmentViewController.h"

#import "RecordMapViewController.h"
#import "InitialDetailViewController.h"
#import "RecordPageViewController.h"

#import "DataMapSegmentControllerDelegate.h"

@interface DataMapSegmentViewController : SegmentViewController

#define INITIAL_DETAIL_VIEW_CONTROLLER_IDENTIFIER @"Initial Detail View Controller"
#define RECORD_PAGE_VIEW_CONTROLLER_IDENTIFIER @"Record Page View Controller"
#define RECORD_MAP_VIEW_CONTROLLER_IDENTIFIER @"Record Map View Controller"

typedef void (^push_completion_handler_t)(void);

#pragma mark - Record Page Data Forward Mechanisms

- (void)setRecordPageViewControllerDelegate:(id <RecordPageViewControllerDelegate>)delegate;
- (void)updateRecordDetailViewWithRecord:(Record *)record;
- (void)reloadRecordPagePosition;

#pragma mark - Record View Controller Data Forward Mechanisms

- (void)putRecordViewControllerIntoEditingMode;
- (void)resetRecordViewController;
- (void)setRecordViewControllerDelegate:(id <RecordViewControllerDelegate>)delegate;

#pragma mark - Map View Controller Data Forward Mechanisms

- (void)setMapViewDelegate:(id <RecordMapViewControllerDelegate>)mapDelegate;
- (void)updateMapWithRecords:(NSArray *)records forceUpdate:(BOOL)willForceUpdate updateRegion:(BOOL)willUpdateRegion;
- (void)setMapSelectedRecord:(Record *)selectedRecord;
- (void)reloadMapAnnotationViews;

#pragma mark - Helpers

- (void)pushInitialViewController;
- (void)pushRecordViewController;

- (void)dismissKeyboardInDataSideView;

@property (nonatomic,readonly) UIViewController *detailSideViewController;

@property (nonatomic,weak) id <DataMapSegmentControllerDelegate> delegate;

@end
