//
//  IEEngine.h
//  GeoFieldBook
//
//  Created by excel 2012 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConflictHandler.h"
#import "SettingManager.h"

@interface IEEngine : NSObject

@property (nonatomic, strong) ConflictHandler *handler;

#pragma mark - Import

- (void)createRecordsFromCSVFiles:(NSArray *)files; //passes the array of records to the ConflictaHandler
- (void)createFormationsFromCSVFiles:(NSArray *)files; //passes the array of formations to the ConflictHandler
- (void)createFormationsWithColorFromCSVFiles:(NSArray *)files; //this reads the new version of formation files with colors.

#pragma mark - Export

- (void)createCSVFilesFromRecords:(NSArray *)records;
- (void)createCSVFilesFromFormations:(NSArray *)formations;
- (void)createCSVFilesFromFormationsWithColors:(NSArray *)formations; //format for version 2
- (void)createCSVFilesFromStudentResponses:(NSArray *)responses;

#define NUMBER_OF_COLUMNS_PER_RECORD_LINE 16

#define METADATA_HEADER @">>>>>> Metadata <<<<<<<"
#define IMPORT_MATRIX_FOLDER_NAME @"ExportMatrix.FolderName"
#define EXPORT_MATRIX_FOLDER_NAME @"ExportMatrix.FolderName"

@end
