//
//  CustomFolderCell.h
//  GeoFieldBook
//
//  Created by excel 2011 on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Folder.h"

@class CustomFolderCell;

@protocol CustomFolderCellDelegate

- (void)folderCell:(CustomFolderCell *)sender folder:(Folder *)folder visibilityChanged:(BOOL)visible;

@end

@interface CustomFolderCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *title;
@property (nonatomic,weak) IBOutlet UILabel *subtitle;
@property (nonatomic,strong) IBOutlet UIImageView *visibility;
@property (nonatomic,strong) Folder *folder;

@property (nonatomic,weak) id <CustomFolderCellDelegate> delegate;

- (void)setVisible:(BOOL)visible animated:(BOOL)animated;

- (void)hideVisibilityIconAnimated:(BOOL)animated;
- (void)showVisibilityIconAnimated:(BOOL)animated;

#define VISIBILITY_ANIMATION_DURATION 0.5

@end
