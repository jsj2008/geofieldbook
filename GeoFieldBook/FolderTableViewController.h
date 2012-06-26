//
//  FolderTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "UISplitViewBarButtonPresenter.h"

@interface FolderTableViewController : CoreDataTableViewController  //Making this inherit the FetchedResultsController from CoreDataTVC

@property (nonatomic,strong) UIManagedDocument *database;   //The database to fetch folders from
@property (nonatomic,strong) UIBarButtonItem *barButtonItem;

@end
