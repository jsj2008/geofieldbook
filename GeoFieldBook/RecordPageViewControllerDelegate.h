//
//  RecordPageViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Record;
@class RecordPageViewController;
@class RecordViewController;

@protocol RecordPageViewControllerDelegate <NSObject>

- (Record *)recordPage:(RecordPageViewController *)sender recordBeforeRecord:(Record *)nextRecord;
- (Record *)recordPage:(RecordPageViewController *)sender recordAfterRecord:(Record *)previousRecord;
- (void)recordPage:(RecordPageViewController *)sender isTurningToRecordViewController:(RecordViewController *)recordViewController;

@end
