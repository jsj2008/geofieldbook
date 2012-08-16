//
//  RecordSegmentViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "SegmentViewController.h"

#import "RecordByNameTVC.h"
#import "RecordByDateTVC.h"
#import "RecordByTypeTVC.h"

@interface RecordSegmentViewController : SegmentViewController

#pragma mark - Data for content record tvcs

@property (nonatomic,strong) Folder *folder;
@property (nonatomic,strong) UIManagedDocument *database;
@property (nonatomic,weak) id <RecordTableViewControllerDelegate> delegate;
@property (nonatomic,strong) Record *chosenRecord;

@end
