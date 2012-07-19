//
//  FormationImportTVC.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/11/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationImportTVC.h"

@interface FormationImportTVC() <UIAlertViewDelegate,UIActionSheetDelegate,CSVTableViewControllerDelegate>

@property (nonatomic,strong) UIBarButtonItem *spinner;

@end

@implementation FormationImportTVC

@synthesize spinner=_spinner;

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Get the list of csv files from the document directories
    NSMutableArray *csvFileNames=[NSMutableArray array];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *urls=[fileManager contentsOfDirectoryAtPath:[documentDirURL path] error:NULL];
    for (NSURL *url in urls) {
        //If the file name has extension .formation.csv, add it to the array of csv files
        NSString *fileName=[url lastPathComponent];
        if ([fileName hasSuffix:@".formation.csv"]) {
            [csvFileNames addObject:fileName];
        }
    }
    self.csvFileNames=csvFileNames;
    
    //Register to hear notifications from the conflict handler
    [self registerForNotificationsForConflictHandler];
}

#pragma mark - UIAlertViewDelegate protocol methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Folder Name Conflict
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Replace"]) {
        ConflictHandler *conflictHandler=self.conflictHandler;
        dispatch_queue_t conflict_handler_queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(conflict_handler_queue, ^{
            //Handle the conflict
            [conflictHandler userDidChooseToHandleFormationFolderNameConflictWith:ConflictHandleReplace];
            
            //If there is any unprocessed formations, continue
            if (conflictHandler.transientFormations.count)
                [conflictHandler processTransientFormations:conflictHandler.transientFormations 
                                        andFormationFolders:conflictHandler.transientFormationFolders 
                                   withValidationMessageLog:nil];
        });
    }
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Keep Both"]) {
        ConflictHandler *conflictHandler=self.conflictHandler;
        dispatch_queue_t conflict_handler_queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(conflict_handler_queue, ^{
            //Handle the conflict
            [conflictHandler userDidChooseToHandleFormationFolderNameConflictWith:ConflictHandleKeepBoth];
            
            //If there is any unprocessed records, continue
            if (conflictHandler.transientFormations.count)
                [conflictHandler processTransientFormations:conflictHandler.transientFormations 
                                        andFormationFolders:conflictHandler.transientFormationFolders 
                                   withValidationMessageLog:nil];
        });
    }
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        [self.conflictHandler userDidChooseToHandleFolderNameConflictWith:ConflictHandleCancel];
    }
}

#pragma mark - Handle Notifications

- (void)putImportButtonBack {
    dispatch_async(dispatch_get_main_queue(), ^{
        //Hide the spinner and put the import button
        NSMutableArray *toolbarItems=self.toolbarItems.mutableCopy;
        int index=[toolbarItems indexOfObject:self.spinner];
        [toolbarItems removeObjectAtIndex:index];
        [toolbarItems insertObject:self.importButton atIndex:index];
        self.toolbarItems=toolbarItems.copy;
        self.spinner=nil;
    });
}

- (void)importingWasCanceled:(NSNotification *)notification {
    //Put the import button back
    [self putImportButtonBack];
}

- (void)importingDidEnd:(NSNotification *)notification {
    //Put the import button back again
    [self putImportButtonBack];
}

- (void)registerForNotificationsForConflictHandler {
    //Register to hear notifications from conflict handler
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self 
                           selector:@selector(handleFolderNameConflict:) 
                               name:GeoNotificationConflictHandlerFormationFolderNameConflictOccurs 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(handleValidationErrors:) 
                               name:GeoNotificationConflictHandlerValidationErrorsOccur 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(importingDidEnd:) 
                               name:GeoNotificationConflictHandlerImportingDidEnd 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(importingWasCanceled:) 
                               name:GeoNotificationConflictHandlerImportingWasCanceled
                             object:nil];
}

- (void)handleFolderNameConflict:(NSNotification *)notification {
    //Put up an alert in the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *duplicateFormationFolderName=self.conflictHandler.duplicateFormationFolderName;
        NSString *alertTitle=[NSString stringWithFormat:@"Formation Folder With Name \"%@\" already exists!",duplicateFormationFolderName];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:alertTitle 
                                                      message:nil 
                                                     delegate:self 
                                            cancelButtonTitle:@"Cancel" 
                                            otherButtonTitles:@"Replace",@"Keep Both", nil];
        [alert show];
    });
}

- (void)handleValidationErrors:(NSNotification *)notification {
    //Put up an alert in the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo=notification.userInfo;
        NSArray *errorMessages=[userInfo objectForKey:GeoNotificationConflictHandlerValidationLogKey];
        NSString *alertTitle=@"Importing Failed!";
        NSString *message=[errorMessages componentsJoinedByString:@"\n"];;
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:alertTitle 
                                                      message:message 
                                                     delegate:self 
                                            cancelButtonTitle:@"Dismiss" 
                                            otherButtonTitles:nil];
        [alert show];
        
        //Put the import button back again
        [self putImportButtonBack];
    });
}

#pragma mark - UITableViewDataSource protocol methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Formation CSV Files";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Formation Import Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSString *fileName=[self.csvFileNames objectAtIndex:indexPath.row];
    NSString *fileNameWithoutExtension=[[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
    cell.textLabel.text=fileNameWithoutExtension;
    
    return cell;
}

#pragma mark - Target Action Handlers

- (IBAction)importPressed:(UIBarButtonItem *)sender {
    [super importPressed:sender];
    
    __weak FormationImportTVC *weakSelf=self;
    
    //Start importing in another thread
    dispatch_queue_t import_queue_t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(import_queue_t, ^{
        NSArray *selectedCSVFiles=weakSelf.selectedCSVFiles;
        
        //Put up a spinner for the import button
        __block UIActivityIndicatorView *spinner=nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            spinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            UIBarButtonItem *spinnerBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:spinner];
            [spinner startAnimating];
            
            //Save the spinner
            weakSelf.spinner=spinnerBarButtonItem;
            
            //Hide the import button and put the spinner there
            NSMutableArray *toolbarItems=weakSelf.toolbarItems.mutableCopy;
            
            int index=[toolbarItems indexOfObject:weakSelf.importButton];
            [toolbarItems removeObject:weakSelf.importButton];
            [toolbarItems insertObject:spinnerBarButtonItem atIndex:index];
            weakSelf.toolbarItems=toolbarItems.copy;
            
            //Unset selected records
            [weakSelf selectNone:nil];
        });
        
        //Pass the selected csv files to the engine
        weakSelf.engine.handler=weakSelf.conflictHandler;
        [weakSelf.engine createFormationsFromCSVFiles:selectedCSVFiles];
    });
    dispatch_release(import_queue_t);
}

- (IBAction)selectAll:(UIBarButtonItem *)sender {
    //Select all the csv files
    self.selectedCSVFiles=self.csvFileNames;
    
    //Select all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)selectNone:(UIBarButtonItem *)sender {
    //Empty the selected csv files
    self.selectedCSVFiles=[NSArray array];
    
    //Deselect all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
}

- (IBAction)deletePressed:(UIBarButtonItem *)sender {
    //Put up an actionsheet
    int numOfDeletedCSVFiles=self.selectedCSVFiles.count;
    NSString *message=numOfDeletedCSVFiles > 1 ? [NSString stringWithFormat:@"Are you sure you want to delete %d csv files?",numOfDeletedCSVFiles] : @"Are you sure you want to delete this csv file?";
    NSString *destructiveButtonTitle=numOfDeletedCSVFiles > 1 ? @"Delete Files" : @"Delete File";
    
    //Put up an alert
    UIActionSheet *deleteActionSheet=[[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    [deleteActionSheet showInView:self.view];
}

- (void)deleteFilesWithNames:(NSArray *)fileNames {
    //Get document dir's url
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    
    //Delete files with given names
    NSMutableArray *csvFileNames=self.csvFileNames.mutableCopy;
    for (NSString *fileName in fileNames) {
        //Delete the file
        NSURL *fileURL=[documentDirURL URLByAppendingPathComponent:fileName];
        [fileManager removeItemAtURL:fileURL error:NULL];
        
        //Remove the file name from the list of csv files
        [csvFileNames removeObject:fileName];
    }
    
    self.csvFileNames=csvFileNames;
}

#pragma mark - UIActionSheetDelegate protocol methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the action sheet is the delete file action sheet and user clicks "Delete Files" or "Delete File", delete the file(s)
    NSSet *deleteButtonTitles=[NSSet setWithObjects:@"Delete Files",@"Delete File", nil];
    NSString *clickedButtonTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
    if (self.tableView.editing && [deleteButtonTitles containsObject:clickedButtonTitle]) {
        //Delete selected files from the document directory
        [self deleteFilesWithNames:self.selectedCSVFiles];
        self.selectedCSVFiles=[NSArray array];
    }
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Add File"]) {
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setBlacklistedExtensions:[NSArray arrayWithObjects:@".record.csv",@".formation.csv",nil]];
    }
}

#pragma mark - CSVTableViewControllerDelegate protocol methods

- (void)csvTableViewController:(CSVTableViewController *)sender userDidChooseFilesWithNames:(NSArray *)fileNames {
    //Rename the files to have .formation.csv extension
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSMutableArray *csvFileNames=self.csvFileNames.mutableCopy;
    for (NSString *fileName in fileNames) {
        NSMutableArray *nameComponents=[fileName componentsSeparatedByString:@"."].mutableCopy;
        [nameComponents removeLastObject];
        NSString *localizedName=[nameComponents componentsJoinedByString:@"."];
        NSString *newName=[localizedName stringByAppendingString:@".formation.csv"];
        
        [fileManager moveItemAtURL:[documentDirURL URLByAppendingPathComponent:fileName] toURL:[documentDirURL URLByAppendingPathComponent:newName] error:NULL];
        [csvFileNames addObject:newName];
    }
    
    //Set the csv file names
    self.csvFileNames=csvFileNames.copy;
    
    //Pop navigation stack to self
    [self.navigationController popToViewController:self animated:YES];
}


@end
