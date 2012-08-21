//
//  RecordPageViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "InitialDetailViewController.h"
#import "RecordViewController.h"
#import "MPFlipViewController.h"

#import "RecordPageViewControllerDelegate.h"

@interface RecordPageViewController : UIViewController<MPFlipViewControllerDelegate, MPFlipViewControllerDataSource>

@property (strong, nonatomic) MPFlipViewController *flipViewController;
@property (strong, nonatomic) Record *record;
@property (readonly, nonatomic) RecordViewController *currentRecordViewController;

@property (weak, nonatomic) id <RecordPageViewControllerDelegate> delegate;

- (void)updateRecord:(Record *)record;

@end
