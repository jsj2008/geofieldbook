//
//  FolderTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FolderTableViewController.h"
#import "ModalFolderViewController.h"
#import "RecordTableViewController.h"
#import "TextInputFilter.h"
#import "GeoDatabaseManager.h"

#import "Folder.h"
#import "Record.h"
#import "Folder+Creation.h"
#import "Folder+Modification.h"
#import "Folder+DictionaryKeys.h"

#import "CheckBox.h"

#import "GeoFilter.h"
#import "CustomFolderCell.h"

#import "ModelGroupNotificationNames.h"

@interface FolderTableViewController() <ModalFolderDelegate,UIAlertViewDelegate,RecordTableViewControllerDelegate,CustomFolderCellDelegate>

@property (nonatomic, strong) GeoFilter *recordFilter;

#pragma mark - Temporary "to-be-deleted" data

@property (nonatomic,strong) NSArray *toBeDeletedFolders;

#pragma mark - Popover Controllers

@property (nonatomic,weak) UIPopoverController *formationPopoverController;
@property (nonatomic,strong) UIPopoverController *folderInfoPopoverController;

#pragma mark - Buttons

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@end

@implementation FolderTableViewController 

@synthesize recordFilter=_recordFilter;
@synthesize willFilterByFolder=_willFilterByFolder;
@synthesize editButton = _editButton;
@synthesize deleteButton = _deleteButton;

@synthesize toBeDeletedFolders=_toBeDeletedFolders;

@synthesize database=_database;

@synthesize formationPopoverController=_formationPopoverController;
@synthesize folderInfoPopoverController=_folderInfoPopoverController;

#pragma mark - Getters and Setters

- (void)setDatabase:(UIManagedDocument *)database {
    if (_database!=database) {
        _database=database;
        
        //Make sure the document is open and set up the fetched result controller
        [self normalizeDatabase];        
    }
}

- (GeoFilter *)recordFilter {
    if (!_recordFilter)
        _recordFilter=[[GeoFilter alloc] init];
    
    return _recordFilter;
}

- (NSArray *)toBeDeletedFolders {
    if (!_toBeDeletedFolders)
        _toBeDeletedFolders=[NSArray array];
    
    return _toBeDeletedFolders;
}

- (NSArray *)selectedFolders {
    return [self.recordFilter selectedFolderNames];
}

- (void)setWillFilterByFolder:(BOOL)willFilterByFolder {
    _willFilterByFolder=willFilterByFolder;
    
    //Reload the table view
    [self.tableView reloadData];
}

#pragma mark - Notification Center

- (void)postNotificationWithName:(NSString *)name andUserInfo:(NSDictionary *)userInfo {
    //Post the notification
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:self userInfo:userInfo];    
}

#pragma mark - Controller State Initialization

//Set up the FetchedResultsController to fetch folder entities from the database
- (void)setupFetchedResultsController {
    //Setup its request
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Folder"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    
    //Create the fetchedResultsController
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                      managedObjectContext:self.database.managedObjectContext 
                                                                        sectionNameKeyPath:nil 
                                                                                 cacheName:nil];
}

- (void)normalizeDatabase {
    //If the managed document is closed, open it
    if (self.database.documentState==UIDocumentStateClosed) {
        [self.database openWithCompletionHandler:^(BOOL success){
            //Set up the fetched result controller
            [self setupFetchedResultsController];
        }];
    }
    
    //Else if the managed document is open, just use it
    else if (self.database.documentState==UIDocumentStateNormal) {
        //Set up the fetched result controller
        [self setupFetchedResultsController];
    }
}

#pragma mark - Alert Generators

//Put up an alert about some database failure with specified message
- (void)putUpDatabaseErrorAlertWithMessage:(NSString *)message {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Database Error" 
                                                  message:message 
                                                 delegate:nil 
                                        cancelButtonTitle:@"Dismiss" 
                                        otherButtonTitles: nil];
    [alert show];
}

- (void)putUpDuplicateNameAlertWithName:(NSString *)duplicateName {
    UIAlertView *duplicationAlert=[[UIAlertView alloc] initWithTitle:@"Name Duplicate" message:[NSString stringWithFormat:@"A folder with the name '%@' already exists!",duplicateName] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [duplicationAlert show];
}

#pragma mark - RecordTableViewControllerDelegate methods

- (void)recordTableViewController:(RecordTableViewController *)sender 
                needsUpdateFolder:(Folder *)folder 
           setFormationFolderName:(NSString *)formationFolder
{
    //Update the folder
    [folder setFormationFolderWithName:formationFolder];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the alert view is the delete folder alert and user clicks "Continue", delete the folder
    if ([alertView.title isEqualToString:@"Delete Folder"]) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Continue"]) {
            //Delete the selected folders
            [self deleteFolders:self.toBeDeletedFolders];
        }
    }
}

#pragma mark - Folder Creation/Editing/Deletion

- (void)saveChangesToDatabase {
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //handle errors
            [self putUpDatabaseErrorAlertWithMessage:@"Failed to save changes to database. Please try to submit them again."];
        }
    }];
}

- (BOOL)createNewFolderWithInfo:(NSDictionary *)folderInfo {
    //Create a folder entity with the specified name (after filtering), put up an alert if that returns nil (name duplicate) and return NO
    if (![Folder folderWithInfo:folderInfo inManagedObjectContext:self.database.managedObjectContext]) {
        [self putUpDuplicateNameAlertWithName:[folderInfo objectForKey:FOLDER_NAME]];
        return NO;
    }
        
    //Else, save
    else 
        [self saveChangesToDatabase];
    
    //Update the record filter (add the name of the newly created folder)
    [self.recordFilter userDidSelectFolderWithName:[folderInfo objectForKey:FOLDER_NAME]];
    
    //Reload
    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)modifyFolder:(Folder *)folder withNewInfo:(NSDictionary *)folderInfo {
    NSString *originalName=folder.folderName;
    
    //Update its name, if that returns NO (i.e. the update failed because of name duplication), put up an alert and return NO
    if (![folder updateWithNewInfo:folderInfo]) {
        [self putUpDuplicateNameAlertWithName:[folderInfo objectForKey:FOLDER_NAME]];
        return NO;
    }
    
    //Else, save
    else
        [self saveChangesToDatabase];
    
    //Update the filter
    [self.recordFilter changeFolderName:originalName toFolderName:[folderInfo objectForKey:FOLDER_NAME]];
    
    //Reload
    [self.tableView reloadData];
    
    return YES;
}

- (void)deleteFolders:(NSArray *)folders {
    for (Folder *folder in folders) {
        //Update the record filter
        [self.recordFilter userDidDeselectFolderWithName:folder.folderName];
    
        //Delete the folder
        [self.database.managedObjectContext deleteObject:folder];
    }
    
    //Save
    [self saveChangesToDatabase];
    
    //End editing mode
    [self.tableView setEditing:NO animated:NO];
    
    //Reload
    [self.tableView reloadData];
    
    //Send out a notification to indicate that the folder database has changed
    [self postNotificationWithName:GeoNotificationModelGroupFolderDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
}

#pragma mark - View lifecycle

- (void)showDeleteButton {
    //Hide the delete button
    self.deleteButton.title=@"Delete";
    self.deleteButton.style=UIBarButtonItemStyleBordered;
    self.deleteButton.enabled=YES;
}

- (void)hideDeleteButton {
    //Hide the delete button
    self.deleteButton.title=@"";
    self.deleteButton.style=UIBarButtonItemStylePlain;
    self.deleteButton.enabled=NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set up the database using the GeoDatabaseManager fetch method=====>the block will get called only the first time the database gets created
    //success is YES if the database saving process succeeded or NO otherwise
    self.database=[[GeoDatabaseManager standardDatabaseManager] fetchDatabaseFromDisk:self completion:^(BOOL success){
        //May be show up an alert if not success?
        if (!success) {
            //Put up an alert
            [self putUpDatabaseErrorAlertWithMessage:@"Failed to access the database. Please make sure the database is not corrupted."];
        } 
    }];
    
    //Hide delete button
    [self hideDeleteButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Save any change to database
    [self saveChangesToDatabase];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Support all orientations
    return YES;
}

#pragma mark - Target-Action Handlers

- (void)reloadCheckboxesInVisibleCells {
    for (CustomFolderCell *cell in self.tableView.visibleCells) {
        if (self.tableView.editing)
            [cell hideCheckBoxAnimated:YES];
        else {
            //Show/Hide the checkboxes
            if (self.willFilterByFolder)
                [cell showCheckBoxAnimated:YES];
            else
                [cell hideCheckBoxAnimated:YES];
        }
    }
}

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Set the table view to editting mode
    [self.tableView setEditing:!self.tableView.editing animated:YES];

    //Change the style of the button to edit or done
    sender.style=self.tableView.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    sender.title=self.tableView.editing ? @"Done" : @"Edit";    
    
    //Reload the checkboxes
    [self reloadCheckboxesInVisibleCells];
    
    //Show the delete button if in editing mode
    if (self.tableView.editing)
        [self showDeleteButton];
    else
        [self hideDeleteButton];
}

- (IBAction)deletePressed:(UIBarButtonItem *)sender {
    int numOfDeletedFolders=self.toBeDeletedFolders.count;
    NSString *folderCounter=numOfDeletedFolders > 1 ? @"folders" : @"folder";
    NSString *message=[NSString stringWithFormat:@"You are about to delete %d entire %@ of records. Do you want to continue?",numOfDeletedFolders,folderCounter];
    
    //Put up an alert
    UIAlertView *deleteAlert=[[UIAlertView alloc] initWithTitle:@"Delete Folder" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [deleteAlert show];
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Seguing to ModalNewFolderViewController
    if ([segue.identifier isEqualToString:@"Add/Edit Folder"]) {
        //Set the delegate of the destination controller
        [segue.destinationViewController setDelegate:self];
        
        //Set the folder of the destination controller if the table view is in editting mode
        if (self.tableView.editing) {
            UITableViewCell *cell=(UITableViewCell *)sender;
            Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            [segue.destinationViewController setFolder:folder];
            [self editPressed:self.editButton];
        }            
    }
    
    //Seguing to the RecordTableViewController
    else if ([segue.identifier isEqualToString:@"Show Records"]) {
        //Common setup
        [segue.destinationViewController setDatabase:self.database];
        [segue.destinationViewController setDelegate:self];
        
        //Get the cell that activates the segue and set up the destination controller if the sender is a table cell
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell=(UITableViewCell *)sender;
            Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            [segue.destinationViewController setTitle:folder.folderName];
            [segue.destinationViewController setFolder:folder];
        }
        
        //If the sender is a record
        else if ([sender isKindOfClass:[Record class]]) {
            Record *record=(Record *)sender;
            Folder *folder=record.folder;
            [segue.destinationViewController setTitle:folder.folderName];
            [segue.destinationViewController setFolder:folder];
            [segue.destinationViewController setChosenRecord:record];
        }
    }
}

#pragma mark - ModalFolderDelegate methods

- (void)modalFolderViewController:(ModalFolderViewController *)sender 
            obtainedNewFolderInfo:(NSDictionary *)folderInfo
{
    //Create the folder with the specified name, and if that returns YES (no name duplication) dismiss the modal
    if ([self createNewFolderWithInfo:folderInfo]) {
        //Dismiss modal
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)modalFolderViewController:(ModalFolderViewController *)sender 
             didAskToModifyFolder:(Folder *)folder
       obtainedModifiedFolderInfo:(NSDictionary *)folderInfo
{
    //Modify the folder's name and that returns YES, dismiss the modal
    if ([self modifyFolder:folder withNewInfo:folderInfo]) {
        //Dismiss modal
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Folder Cell";
    
    CustomFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomFolderCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.folder=folder;
    cell.editingAccessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    CheckBox *checkbox=(CheckBox *)cell.checkBox;
    checkbox.image=[self.recordFilter.selectedFolderNames containsObject:folder.folderName] ? checkbox.checked : checkbox.unchecked;
    
    //Set self to the delegate of the cell
    cell.delegate=self;
    
    //Add gesture recognizer for long press
    UILongPressGestureRecognizer *longPressRecognizer=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnTableCell:)];
    [cell addGestureRecognizer:longPressRecognizer];
    
    //Show/Hide the checkboxes
    if (self.willFilterByFolder && !self.tableView.editing)
        [cell showCheckBoxAnimated:YES];
    else
        [cell hideCheckBoxAnimated:YES];
    
    return cell;
}

- (void)longPressOnTableCell:(UILongPressGestureRecognizer *)longPress {
    //Show a popover
    //UITableViewCell *cell=(UITableViewCell *)longPress.view;
    //Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    //cell.textLabel.text=folder.folderDescription;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //If the table view is currently in editting mode, segue to the MoDalNewFolderViewController and set its 
    if (self.tableView.editing) {
        [self performSegueWithIdentifier:@"Add/Edit Folder" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, increment the count for delete
    if (self.tableView.editing) {
        //Add the selected folder to the delete list
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *toBeDeletedFolders=[self.toBeDeletedFolders mutableCopy];
        [toBeDeletedFolders addObject:folder];
        self.toBeDeletedFolders=[toBeDeletedFolders copy];
        
        //Update the title of the delete button
        self.deleteButton.title=[NSString stringWithFormat:@"Delete (%d)",[self.toBeDeletedFolders count]];
    }
    
    //If the table view is not in editing mode, segue to show the records
    else
        [self performSegueWithIdentifier:@"Show Records" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, decrement the count for delete
    if (self.tableView.editing) {
        //Remove the selected folder from the delete list
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *toBeDeletedFolders=[self.toBeDeletedFolders mutableCopy];
        [toBeDeletedFolders removeObject:folder];
        self.toBeDeletedFolders=[toBeDeletedFolders copy];
        
        //Update the title of the delete button
        self.deleteButton.title=[NSString stringWithFormat:@"Delete (%d)",[self.toBeDeletedFolders count]];
    }
}

#pragma mark - CustomFolderCellDelegate methods

- (void)folderCell:(CustomFolderCell *)sender userDidSelectDidCheckBoxForRecord:(Folder *)folder {
    [self.recordFilter userDidSelectFolderWithName:folder.folderName];
    
    //Post a notification to indicate that the folder database has changed
    [self postNotificationWithName:GeoNotificationModelGroupFolderDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
}

- (void)folderCell:(CustomFolderCell *)sender userDidDeselectDidCheckBoxForRecord:(Folder *)folder {
    [self.recordFilter userDidDeselectFolderWithName:folder.folderName];
    
    //Post a notification to indicate that the folder database has changed
    [self postNotificationWithName:GeoNotificationModelGroupFolderDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
}

- (void)viewDidUnload {
    [self setDeleteButton:nil];
    [super viewDidUnload];
}
@end