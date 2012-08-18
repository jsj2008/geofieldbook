//
//  CustomRecordCell.h
//  GeoFieldBook
//
//  Created by excel 2011 on 6/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Record.h"
#import "Record+DateAndTimeFormatter.h"

@class CustomRecordCell;

@protocol CustomRecordCellDelegate

- (void)recordCell:(CustomRecordCell *)sender record:(Record *)record visibilityChanged:(BOOL)visible;

@end

@interface CustomRecordCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *date;
@property (nonatomic, weak) IBOutlet UILabel *time;
@property (nonatomic, weak) IBOutlet UIImageView *recordImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UILabel *type;
@property (nonatomic, weak) IBOutlet UIImageView *visibility;

@property (nonatomic) BOOL visible;

@property (nonatomic,strong) Record *record;
@property (nonatomic, weak) id <CustomRecordCellDelegate> delegate;

- (void)setVisible:(BOOL)visible animated:(BOOL)animated;

- (void)showVisibilityIconAnimated:(BOOL)animated;
- (void)hideVisibilityIconAnimated:(BOOL)animated;

#define VISIBILITY_ANIMATION_DURATION 0.5

@end
