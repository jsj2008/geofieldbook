//
//  SelectFormationFolderTVC.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PrototypeFormationFolderTableViewController.h"

#import "SelectFormationFolderTVCDelegate.h"

@interface SelectFormationFolderTVC : PrototypeFormationFolderTableViewController

@property (nonatomic,weak) id <SelectFormationFolderTVCDelegate> delegate;

@end
