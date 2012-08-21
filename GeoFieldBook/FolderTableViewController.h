//
//  FolderTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PrototypeFolderTableViewController.h"

#import "ModelGroupNotificationNames.h"

@interface FolderTableViewController : PrototypeFolderTableViewController 

@property (nonatomic,strong) NSArray *selectedFolders;

@property (nonatomic) BOOL willFilterByFolder;

@end
