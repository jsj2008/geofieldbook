//
//  FormationTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationTableViewController.h"

#import "FormationViewController.h"

#import "Formation.h"
#import "Formation+Creation.h"
#import "Formation+Modification.h"
#import "Formation+DictionaryKeys.h"

#import "ModelGroupNotificationNames.h"

#import "SelectFormationFolderTVC.h"

#import "TextInputFilter.h"

@interface FormationTableViewController() <FormationViewControllerDelegate,NSFetchedResultsControllerDelegate,UIActionSheetDelegate,SelectFormationFolderTVCDelegate>

@property (nonatomic) BOOL formationsWereReordered;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *moveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectAllButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectNone;

@property (strong, nonatomic) NSArray *selectedFormations;

@end

@implementation FormationTableViewController

@synthesize addButton = _addButton;
@synthesize deleteButton = _deleteButton;
@synthesize moveButton = _moveButton;
@synthesize editButton = _editButton;
@synthesize selectAllButton = _selectAllButton;
@synthesize selectNone = _selectNone;

@synthesize formationsWereReordered=_formationsWereReordered;

@synthesize selectedFormations=_selectedFormations;

#pragma mark - Getters and Setters

- (NSArray *)toBeDeletedFormations {
    if (!_selectedFormations)
        _selectedFormations=[NSArray array];
    
    return _selectedFormations;
}

- (void)setSelectedFormations:(NSArray *)selectedFormations {
    _selectedFormations=selectedFormations;
    
    //Update the title of the delete button
    int numFormations=self.toBeDeletedFormations.count;
    self.deleteButton.title=numFormations ? [NSString stringWithFormat:@"Delete (%d)",numFormations] : @"Delete";
    
    //Enable the delete button if appropriate
    self.deleteButton.enabled=numFormations>0;
    
    //Update the title of the move button
    self.moveButton.title=numFormations ? [NSString stringWithFormat:@"Move (%d)",numFormations] : @"Move";
    
    //Enable the move button if appropriate
    self.moveButton.enabled=numFormations>0;
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If seguing to a formation view controller
    if ([segue.identifier isEqualToString:@"Formation Manipulation"]) {
        //Set the delegate of the destination controller as self
        [segue.destinationViewController setDelegate:self];
        
        //If the sender is a UITableViewCell, set the formation of the destination controller as well
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell=sender;
            Formation *selectedFormation=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            [segue.destinationViewController setFormation:selectedFormation];
        }
    }
    
    else if ([segue.identifier isEqualToString:@"Move Formations"]) {
        UINavigationController *navigationController=(UINavigationController *)segue.destinationViewController;
        [(SelectFormationFolderTVC *)navigationController.topViewController setDelegate:self];      
    }
}

#pragma mark - Alert Generators

- (void)putUpAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

- (void)putUpDuplicateNameAlertWithName:(NSString *)duplicateName {
    NSString *message=[NSString stringWithFormat:@"A formation with the name '%@' already exists in this folder!",duplicateName];
    [self putUpAlertWithTitle:@"Name Duplicate" andMessage:message];
}

#pragma mark - Notification Manipulators

- (void)postNotificationWithName:(NSString *)name andUserInfo:(NSDictionary *)userInfo {
    //Post the notification
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:self userInfo:userInfo];    
}

#pragma mark - Formation Manipulation

typedef void (^database_save_t)(void);

- (void)saveChangesToDatabaseWithCompletionHandler:(database_save_t)completionHandler {
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success) {
            //Call completion handler
            completionHandler();
        } else {
            //handle errors
            [self putUpDatabaseErrorAlertWithMessage:@"Failed to save changes to database. Please try to submit them again."];
        }
    }];
}

- (BOOL)createNewFormationWithInfo:(NSDictionary *)formationInfo {
    //Get the formation name
    NSString *formationName=[formationInfo objectForKey:GeoFormationName];
    formationName=[TextInputFilter filterDatabaseInputText:formationName];
        
    //Add the sort number to the formation info dictionary
    NSMutableDictionary *newFormationInfo=formationInfo.mutableCopy;
    [newFormationInfo setObject:[NSNumber numberWithInt:self.fetchedResultsController.fetchedObjects.count+1] forKey:GeoFormationSortNumber];
    
    //create a new formation, if that returns nil (folder not found), put up an alert
    if (![Formation formationForInfo:newFormationInfo.copy inFormationFolderWithName:self.formationFolder.folderName inManagedObjectContext:self.database.managedObjectContext]) {
        [self putUpDuplicateNameAlertWithName:formationName];
        return NO;
    }
    
    //Save changes to database
    [self saveChangesToDatabaseWithCompletionHandler:^(void){
        //Broadcast changes
        [self postNotificationWithName:GeoNotificationModelGroupFormationDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
    }];
    
    return YES;
}

- (BOOL)modifyFormation:(Formation *)formation withNewInfo:(NSDictionary *)formationInfo {
    //Filter formation name
    NSString *formationName=[formationInfo objectForKey:GeoFormationName];
    formationName=[TextInputFilter filterDatabaseInputText:formationName];
    
    //Update the formation, if that returns NO (i.e. the update failed because of name duplication), put up an alert
    if (![formation updateFormationWithFormationInfo:formationInfo]) {
        [self putUpDuplicateNameAlertWithName:formationName];
        return NO;
    }
    
    //Save changes to database
    [self saveChangesToDatabaseWithCompletionHandler:^(void){
        //Broadcast changes
        [self postNotificationWithName:GeoNotificationModelGroupFormationDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
    }];
    
    return YES;
}

- (void)deleteFormations:(NSArray *)formations {
    //Delete the folder
    for (Formation *formation in formations)
        [self.database.managedObjectContext deleteObject:formation];
    
    //Save changes to database
    [self saveChangesToDatabaseWithCompletionHandler:^(void){
        //Broadcast changes
        [self postNotificationWithName:GeoNotificationModelGroupFormationDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
    }];
}

#pragma mark - Target-Action Handlers

- (void)toggleSelectButtons {
    //Setup the select buttons
    NSMutableArray *toolbarItems=self.toolbarItems.mutableCopy;
    if (self.tableView.editing) {
        [toolbarItems insertObject:self.selectAllButton atIndex:1];
        [toolbarItems insertObject:self.selectNone atIndex:toolbarItems.count-1];
    }
    else {
        [toolbarItems removeObject:self.selectAllButton];
        [toolbarItems removeObject:self.selectNone];
    }
    
    self.toolbarItems=toolbarItems.copy;
}

- (void)setupButtonsForEditingMode:(BOOL)editing {
    //Change the style of the action button
    self.editButton.style=editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    
    //Show/Hide add/delete/move buttons
    NSMutableArray *toolbarItems=[self.toolbarItems mutableCopy];
    if (editing) {
        //Hide the add button
        [toolbarItems removeObject:self.addButton];
        
        //Show the delete button
        if (![toolbarItems containsObject:self.deleteButton])
            [toolbarItems insertObject:self.deleteButton atIndex:1];
        
        //Show the move button
        if (![toolbarItems containsObject:self.moveButton])
            [toolbarItems insertObject:self.moveButton atIndex:1];
    }
    else {
        //Hide the delete and move buttons
        [toolbarItems removeObject:self.deleteButton];
        [toolbarItems removeObject:self.moveButton];
        
        //Show the add button
        if (![toolbarItems containsObject:self.addButton])
            [toolbarItems insertObject:self.addButton atIndex:1];
    }
    self.toolbarItems=[toolbarItems copy];
    
    //Reset the title of the delete button and disable it
    self.deleteButton.title=@"Delete";
    self.deleteButton.enabled=NO;
    
    //Set up select buttons
    [self toggleSelectButtons];
}

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Set the table view to editting mode
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    //Set up the buttons
    [self setupButtonsForEditingMode:self.tableView.editing];
    
    //Reset the array of to be deleted records
    self.selectedFormations=nil;
}

- (IBAction)deletePressed:(UIBarButtonItem *)sender {
    int numOfDeletedFormations=self.toBeDeletedFormations.count;
    NSString *message=numOfDeletedFormations > 1 ? [NSString stringWithFormat:@"Are you sure you want to delete %d formations?",numOfDeletedFormations] : @"Are you sure you want to delete this formation?";
    NSString *destructiveButtonTitle=numOfDeletedFormations > 1 ? @"Delete Formations" : @"Delete Formation";
    
    //Put up an alert
    UIActionSheet *deleteActionSheet=[[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    [deleteActionSheet showInView:self.view];
}

- (IBAction)selectAll:(UIBarButtonItem *)sender {
    //Select all the csv files
    self.selectedFormations=self.fetchedResultsController.fetchedObjects;
    
    //Select all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)selectNone:(UIBarButtonItem *)sender {
    //Empty the selected csv files
    self.selectedFormations=[NSArray array];
    
    //Deselect all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
}

#pragma mark - Formation View Controller Delegate methods

- (void)formationViewController:(FormationViewController *)sender 
      didObtainNewFormationInfo:(NSDictionary *)formationInfo
{
    //Create a new formation with the specified name and if that returns YES (success), dismiss the modal
    if ([self createNewFormationWithInfo:formationInfo]) {
        //Dismiss the modal
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)formationViewController:(FormationViewController *)sender 
        didAskToModifyFormation:(Formation *)formation 
             andObtainedNewInfo:(NSDictionary *)formationInfo
{
    //Modify the formation with the specified original name and if that returns YES (success), dismiss the modal
    if ([self modifyFormation:formation withNewInfo:formationInfo]) {
        //Dismiss the modal
        [self dismissModalViewControllerAnimated:YES];        
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //Segue to the MoDalNewFolderViewController
    [self performSegueWithIdentifier:@"Formation Manipulation" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, increment the count for delete
    if (self.tableView.editing) {
        //Add the selected formation to the delete list
        Formation *formation=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *selectedFormations=self.toBeDeletedFormations.mutableCopy;
        [selectedFormations addObject:formation];
        self.selectedFormations=selectedFormations.copy;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, decrement the count for delete
    if (self.tableView.editing) {
        //Remove the selected formation from the delete list
        Formation *formation=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *selectedFormations=self.toBeDeletedFormations.mutableCopy;
        [selectedFormations removeObject:formation];
        self.selectedFormations=selectedFormations.copy;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Table View DataSource

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}

- (void)updateFormationOrder:(NSArray *)formations {
    for (int i=0;i<formations.count;i++) {
        Formation *formation=[formations objectAtIndex:i];
        formation.formationSortNumber=[NSNumber numberWithInt:i];
    }
    
    [self saveChangesToDatabaseWithCompletionHandler:^{}];
}

- (void)tableView:(UITableView *)tableView 
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
      toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    
    //Update the sort number of the formations
    NSMutableArray *formations=[self.fetchedResultsController.fetchedObjects mutableCopy];
    Formation *objectToMove=[formations objectAtIndex:sourceIndexPath.row];
    [formations removeObjectAtIndex:sourceIndexPath.row];
    [formations insertObject:objectToMove atIndex:destinationIndexPath.row];
    [self updateFormationOrder:formations];
}


#pragma mark - View Controller Lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];

    //Setup buttons
    [self setupButtonsForEditingMode:self.tableView.editing];
        
    //Update order
    [self updateFormationOrder:self.fetchedResultsController.fetchedObjects];
}

#pragma mark - UIActionSheetDelegate protocol methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the action sheet is the delete formation action sheet and user clicks "Delete Formations" or "Delete Formation", delete the formation(s)
    NSSet *deleteButtonTitles=[NSSet setWithObjects:@"Delete Formations",@"Delete Formation", nil];
    NSString *clickedButtonTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
    if (self.tableView.editing && [deleteButtonTitles containsObject:clickedButtonTitle]) {
        //Delete the selected formations
        [self deleteFormations:self.toBeDeletedFormations];
                
        //End editing mode
        if (self.tableView.editing)
            [self editPressed:self.editButton];
    }
}

#pragma mark - SelectFormationFolderTVCDelegate Protocol Methods

- (void)formationFolderSelectTVC:(SelectFormationFolderTVC *)sender userDidSelectFormationFolder:(Formation_Folder *)formationFolder {
    //Move the selected folders to the destination folder
    for (Formation *formation in self.selectedFormations) {
        //Change the folder of the formation
        formation.formationFolder=formationFolder;        
        
        //Remove all records from the formation
        [formation removeBeddings:formation.beddings];
        [formation removeFaults:formation.faults];
        [formation removeJoinSets:formation.joinSets];
        [formation removeLowerContacts:formation.lowerContacts];
        [formation removeUpperContacts:formation.upperContacts];
    }
    
    //Post a notification
    [self postNotificationWithName:GeoNotificationModelGroupFormationDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
    
    //Press edit to end editing mode
    [self editPressed:self.editButton];
    
    //Dismiss the modal
    [self dismissModalViewControllerAnimated:YES];
}

@end
