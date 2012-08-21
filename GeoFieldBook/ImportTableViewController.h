//
//  ImportTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/10/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "IEEngine.h"
#import "ConflictHandler.h"

#import "ImportTableViewControllerDelegate.h"

@interface ImportTableViewController : UITableViewController

#pragma mark - Models

@property (nonatomic,strong) NSArray *csvFileNames;
@property (nonatomic,strong) NSArray *selectedCSVFiles;
@property (nonatomic,strong) NSString *csvFileExtension;

#pragma mark - Processors

@property (nonatomic,strong) IEEngine *engine;
@property (nonatomic,strong) ConflictHandler *conflictHandler;

#pragma mark - Buttons

@property (strong, nonatomic) IBOutlet UIBarButtonItem *importButton;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *addButton;

#define SECTION_FOOTER_HEIGHT 30
#define SizeInPopover CGRectMake(0,0,400,500).size

#pragma mark - Target-Action Handlers

- (IBAction)importPressed:(UIBarButtonItem *)sender;

#pragma mark - UI Updaters

- (void)putImportButtonBack;

#pragma mark - Import Helpers

typedef void (^import_block_t)(NSArray *selectedCSVFiles);
- (void)importWithBlock:(import_block_t)importBlock;

#pragma mark - Other Helpers

- (void)postNotificationWithName:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo;

- (void)synchronizeWithFileSystem;

@end
