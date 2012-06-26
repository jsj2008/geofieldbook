//
//  RecordViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record+Creation.h"
#import "Record+DictionaryKeys.h"
#import "UISplitViewBarButtonPresenter.h"

@class RecordViewController;

@protocol RecordViewControllerDelegate <NSObject>

- (void)recordViewController:(RecordViewController *)sender 
         userDidModifyRecord:(Record *)record 
           withNewRecordInfo:(NSDictionary *)recordInfo;

@optional

- (void)userDidNavigateAwayFrom:(RecordViewController *)sender 
           whileModifyingRecord:(Record *)record 
              withNewRecordInfo:(NSDictionary *)recordInfo;

- (UIManagedDocument *)databaseForFormationPicker;

@end

@interface RecordViewController : UIViewController <UISplitViewBarButtonPresenter>

@property (nonatomic,strong) Record *record;
@property (nonatomic,weak) id <RecordViewControllerDelegate> delegate;

- (NSDictionary *)dictionaryFromForm;
- (BOOL) inEdittingMode;

@end
