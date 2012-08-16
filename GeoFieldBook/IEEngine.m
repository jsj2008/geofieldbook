//
//  IEEngine.m
//  GeoFieldBook
//
//  Created by excel 2012 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "IEEngine.h"

#import "TransientRecord.h"
#import "TransientFault.h"
#import "TransientBedding.h"
#import "TransientContact.h"
#import "TransientJointSet.h"
#import "TransientOther.h"
#import "TransientFormation.h"
#import "TransientImage.h"
#import "TransientFormation_Folder.h"
#import "TransientProject.h"

#import "ValidationMessageBoard.h"
#import "IEEngineNotificationNames.h"

#import "TextInputFilter.h"
#import "IEFormatter.h"
#import "ColorManager.h"

#import "Folder.h"
#import "Formation_Folder.h"
#import "Question.h"
#import "Answer.h"
#import "Answer+DateFormatter.h"

#import "SettingManager.h"

@interface IEEngine()

@property (nonatomic, strong) NSArray *selectedFilePaths;
@property (nonatomic, strong) NSMutableArray *records;
@property (nonatomic, strong) NSMutableArray *formations;
@property (nonatomic, strong) NSDictionary *foldersByFolderNames;
@property (nonatomic, strong) NSArray *formationFolders;

@property (nonatomic, strong) ValidationMessageBoard *validationMessageBoard;

@end

@implementation IEEngine

@synthesize handler=_handler;
@synthesize selectedFilePaths=_selectedFilePaths;
@synthesize records=_records;
@synthesize formations=_formations;
@synthesize foldersByFolderNames=_foldersByFolderNames;
@synthesize formationFolders=_formationFolders;

@synthesize validationMessageBoard=_validationMessageBoard;

//enum for columnHeadings
typedef enum columnHeadings{Name, Type, Longitude, Latitude, Date, Time, Strike, Dip, dipDirection, Observations, FormationField, LowerFormation, UpperFormation, Trend, Plunge, imageName}columnHeadings;

#pragma mark - Getters

- (SettingManager *)settingManager {
    return [SettingManager standardSettingManager];
}

-(NSMutableArray *) projects {
    if(!_records) 
        _records = [[NSMutableArray alloc] init];
    
    return _records;
}

-(NSMutableArray *) formations {
    if(!_formations) 
        _formations = [[NSMutableArray alloc] init];
    
    return _formations;
}

- (NSArray *)formationFolders {
    if (!_formationFolders)
        _formationFolders=[NSArray array];
    
    return _formationFolders;
}

- (ValidationMessageBoard *)validationMessageBoard {
    if (!_validationMessageBoard)
        _validationMessageBoard=[[ValidationMessageBoard alloc] init];
    
    return _validationMessageBoard;
}

- (NSMutableArray *)records {
    if (!_records)
        _records=[NSMutableArray array];
    return _records;
}

#pragma mark - Notification Management Mechanisms

- (void)postNotificationWithName:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo {
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:notificationName object:self userInfo:userInfo];
}

#pragma mark - Data Managers

- (NSDate *)dateFromDateToken:(NSString *)dateToken andTimeToken:(NSString *)timeToken {
    //Get date and time components and create a NSDate from them
    NSArray *dateComponents = [dateToken componentsSeparatedByString:@"/"];
    NSArray *timeComponents = [timeToken componentsSeparatedByString:@":"];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    //Set the date components
    comps.year=[[NSString stringWithFormat:@"20%@",[dateComponents objectAtIndex:2]] intValue];
    comps.month=[[dateComponents objectAtIndex:0] intValue];
    comps.day=[[dateComponents objectAtIndex:1] intValue];
    
    //Set the time components
    comps.hour=[[timeComponents objectAtIndex:0] intValue];
    comps.minute=[[timeComponents objectAtIndex:1] intValue];
    comps.second=[[timeComponents objectAtIndex:2] intValue];
    
    //Create a NSDate obj from the date and time components
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian dateFromComponents:comps];
}

- (NSData *)imageInDocumentDirectoryForName:(NSString *)imageFileName {
    NSData *imageData=nil;
    
    //to set the image, first get the image from the images directory
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentsDirectory = [urlArray.lastObject path];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:imageFileName];
    
    //Get the image data if the file exists
    if([fileManager fileExistsAtPath:imageFilePath])
        imageData=[NSData dataWithContentsOfFile:imageFilePath];
    
    return imageData;
}

#pragma mark - Record Importing

- (TransientRecord *)recordForTokenArray:(NSArray *)tokenArray withFolderName:(NSString *)folderName andFormationFolderName:(NSString *)formationFolderName {
    //Initialize the transient record
    NSString *typeToken=[tokenArray objectAtIndex:1];
    TransientRecord *transientRecord=[TransientRecord recordWithType:typeToken];
    NSString *errorMessage=nil;
    
    //Populate the common fields for all the records and save the errors messages if there's any
    //Populate the name
    transientRecord.name = [tokenArray objectAtIndex:Name];
    
    //Set the strike value with validations
    if ((errorMessage=[transientRecord setStrikeWithValidations:[tokenArray objectAtIndex:Strike]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the dip value with validations
    if ((errorMessage=[transientRecord setDipWithValidations:[tokenArray objectAtIndex:Dip]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];

    //Set the dip direction value with validations
    if ((errorMessage=[transientRecord setDipDirectionWithValidations:[tokenArray objectAtIndex:dipDirection]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the field observation value with validations
    if ((errorMessage=[transientRecord setFieldObservationWithValidations:[tokenArray objectAtIndex:Observations]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the latitude value with validations
    if ((errorMessage=[transientRecord setLatitudeWithValidations:[tokenArray objectAtIndex:Latitude]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the longitude value with validations
    if ((errorMessage=[transientRecord setLongitudeWithValidations:[tokenArray objectAtIndex:Longitude]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Populate the date field
    NSString *dateToken = [[tokenArray objectAtIndex:Date] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *timeToken = [[tokenArray objectAtIndex:Time] stringByReplacingOccurrencesOfString:@" " withString:@""];
    transientRecord.date = [self dateFromDateToken:dateToken andTimeToken:timeToken];
    
    //Set the image of the record using the given image file name in the csv file
    NSData *imageData=[self imageInDocumentDirectoryForName:[tokenArray objectAtIndex:imageName]];
    if (imageData) {
        TransientImage *image=[[TransientImage alloc] init];
        image.imageData=imageData;
        transientRecord.image=image;
    }
    
    //Set the folder
    transientRecord.folder=[self.foldersByFolderNames objectForKey:folderName];
    
    //Get the formation folder
    TransientFormation_Folder *formationFolder=[[TransientFormation_Folder alloc] init];
    formationFolder.folderName=formationFolderName;
    
    //identify the record type and populate record specific fields
    if([typeToken isEqualToString:@"Contact"]) {
        TransientContact *contact=(TransientContact *)transientRecord;
        NSString *lowerFormationName=[TextInputFilter filterDatabaseInputText:[tokenArray objectAtIndex:LowerFormation]];
        NSString *upperFormationName=[TextInputFilter filterDatabaseInputText:[tokenArray objectAtIndex:UpperFormation]];
        
        //Set lower formation
        if (lowerFormationName.length) {
            TransientFormation *lowerFormation=[[TransientFormation alloc] init];
            lowerFormation.formationName=lowerFormationName;
            lowerFormation.formationFolder=formationFolder;
            contact.lowerFormation=lowerFormation;
        }
        
        //Set upper formation
        if (upperFormationName.length) {
            TransientFormation *upperFormation=[[TransientFormation alloc] init];
            upperFormation.formationName=upperFormationName;
            upperFormation.formationFolder=formationFolder;
            contact.upperFormation=upperFormation;
        }
    } else if ([typeToken isEqualToString:@"Bedding"]) {
        TransientBedding *bedding=(TransientBedding *)transientRecord;
        NSString *formationName=[tokenArray objectAtIndex:FormationField];
        
        //Setup the formation
        if (formationName.length) {
            TransientFormation *formation=[[TransientFormation alloc] init];
            formation.formationName=formationName;
            formation.formationFolder=formationFolder;
            bedding.formation=formation;
        }
    } else if([typeToken isEqualToString:@"Joint Set"]) {
        TransientJointSet *jointSet=(TransientJointSet *)transientRecord;
        NSString *formationName=[tokenArray objectAtIndex:FormationField];
        
        //Setup the formation
        if (formationName.length) {
            TransientFormation *formation=[[TransientFormation alloc] init];
            formation.formationName=formationName;
            formation.formationFolder=formationFolder;
            jointSet.formation=formation;
        }
    } else if([typeToken isEqualToString:@"Fault"]) {        
        //Set the plunge and trend (need to populate name in case validaiton error occurs)
        TransientFault *transientFault=(TransientFault *)transientRecord;
        transientFault.name = [tokenArray objectAtIndex:Name];
        if ((errorMessage=[transientFault setPlungeWithValidations:[tokenArray objectAtIndex:Plunge]]))
            [self.validationMessageBoard addErrorWithMessage:errorMessage];
        if ((errorMessage=[transientFault setTrendWithValidations:[tokenArray objectAtIndex:Trend]]))
            [self.validationMessageBoard addErrorWithMessage:errorMessage];
        
        //Set formation
        NSString *formationName=[tokenArray objectAtIndex:FormationField];
        if (formationName.length) {
            TransientFormation *formation=[[TransientFormation alloc] init];
            formation.formationName=formationName;
            formation.formationFolder=formationFolder;
            transientFault.formation=formation;
        }
    } else if([typeToken isEqualToString:@"Other"]) {
        //Nothing to populate
    }
        
    return transientRecord;
}

- (NSArray *)constructRecordsFromCSVFileWithPath:(NSString *)path {
    NSMutableArray *transientRecords=[NSMutableArray array];;
    
    //Get all the token arrays (each of them corresponding to a line in the csv file)
    NSMutableArray *tokenArrays = [self tokenArraysFromFile:path].mutableCopy;
    
    //if it has file header(new format), ignore those. Otherwise, just ignore the column headings.
    //Obtain the formation folder name
    NSString *formationFolder=DEFAULT_FORMATION_FOLDER_NAME;
    BOOL containsFormationFolderHeader=NO;
    if([[[tokenArrays objectAtIndex:0] objectAtIndex:0] isEqualToString:METADATA_HEADER]) {
        //Get the formation folder name if there is one
        for (int i=0;i<7;i++) {
            if ([[[tokenArrays objectAtIndex:i] objectAtIndex:0] isEqualToString:FORMATION_FOLDER_HEADER]) {
                formationFolder=[[tokenArrays objectAtIndex:i] objectAtIndex:1];
                containsFormationFolderHeader=YES;
                break;
            }
        }
        
        //Remove the first 7 lines if there is a formation folder header and 6 lines otherwise 
        //(metadata header, group name, group id, folder name, line separator btw metadata and record section, formation folder header, and the record section header)
        int numRemovedLines=containsFormationFolderHeader ? 7 : 6;
        NSMutableIndexSet *indexes=[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numRemovedLines)];
        [tokenArrays removeObjectsAtIndexes:indexes]; 
    }else {
        //Remove the first token array which contains the column headings
        [tokenArrays removeObjectAtIndex:0];
    }
    
    //Now create transient records from the rest
    for(NSArray *tokenArray in tokenArrays) {
        
        //If the current token array does not have enough tokens, add an error message to the message board
        if(tokenArray.count!=NUMBER_OF_COLUMNS_PER_RECORD_LINE) {
            [self.validationMessageBoard addErrorWithMessage:@"Invalid CSV File Format. Please ensure that your csv file has the required format."];
            NSLog(@"Corrupted: %@",tokenArray);
        }
        
        //Else, process the token array and contruct a corresponding transient record
        else {
            //Create a transient record from the token array
            NSString *folderName=[[path.lastPathComponent componentsSeparatedByString:@"."] objectAtIndex:0];
            TransientRecord *record=[self recordForTokenArray:tokenArray withFolderName:folderName andFormationFolderName:formationFolder];
            
            //add the record to the array of records
            [transientRecords addObject:record];
        }
    }
    
    return transientRecords.copy;
}

- (NSDictionary *)createFoldersFromCSVFiles:(NSArray *)files {
    NSMutableDictionary *foldersByFolderNames=[NSMutableDictionary dictionaryWithCapacity:files.count];
    for (NSString *csvFile in files) {
        //Create a folder with the folder name specified in the csv file
        NSString *folderName=[[csvFile componentsSeparatedByString:@"."] objectAtIndex:0];
        TransientProject *folder=[[TransientProject alloc] init];
        folder.folderName=folderName;
        
        //Add it the dictionary as value with its name as key
        [foldersByFolderNames setObject:folder forKey:folderName];
    }
    
    return foldersByFolderNames.copy;
}

/*
 Column Headings:
 "Name, Type, Longitude, Latitude, Date, Time, Strike, Dip, Dip Direction, Observations, Formation, Lower Formation, Upper Formation, Trend, Plunge, Image file name \n"
 */
-(void)createRecordsFromCSVFiles:(NSArray *)files
{   
    //Post a notification
    [self postNotificationWithName:GeoNotificationIEEngineRecordImportingDidStart withUserInfo:[NSDictionary dictionary]];
    
    //get paths to the selected files
    self.selectedFilePaths = [self getSelectedFilePaths:files];
    
    //Create the folders
    self.foldersByFolderNames=[self createFoldersFromCSVFiles:files];
    
    //Iterate through each csv files and create transient records from each of them
    for (NSString *path in self.selectedFilePaths) {
        //Construct the records
        NSArray *records=[self constructRecordsFromCSVFileWithPath:path];
        
        //Add them to self.records
        [self.records addObjectsFromArray:records];
    }
    
   
    //now call the handler and pass it the array of records created ... 
    //If there is any error message, pass nil to the handler as well as the error log
    if (self.validationMessageBoard.errorCount) {
        [self.handler processTransientRecords:nil 
                                   andFolders:nil
                     withValidationMessageLog:self.validationMessageBoard.allMessages];
        
        //Reset the validation message board
        [self.validationMessageBoard clearBoard];
    }
    else {
        [self.handler processTransientRecords:self.records 
                                   andFolders:self.foldersByFolderNames.allValues 
                     withValidationMessageLog:self.validationMessageBoard.warningMessages];

    }
}

#pragma mark - Reading of Formation files

-(void) constructFormationsWithColorsfromCSVFilePath:(NSString *) path withFolderName:(NSString *) fileName;
{
    
    NSMutableArray *tokenArrays = [self tokenArraysFromFile:path].mutableCopy; // A 2D array with rows as each line, and tokens en each line as the columns in each row    
    
    TransientFormation_Folder *newTransientFormationFolder;
    NSMutableArray *formationFolders = self.formationFolders.mutableCopy;
    
    if([tokenArrays count]) {
        NSString *newFormationFolderName = fileName;//get the object as the first row and column.
        newFormationFolderName = [TextInputFilter filterDatabaseInputText:newFormationFolderName];
        newTransientFormationFolder = [[TransientFormation_Folder alloc] init];
        newTransientFormationFolder.folderName = [TextInputFilter filterDatabaseInputText:newFormationFolderName];
        //save the object in the array of folders to be added to the database
        [formationFolders addObject:newTransientFormationFolder];
    }
    [tokenArrays removeObjectAtIndex:0];//get rid of the column headings
    if(![tokenArrays count]) return; //if no data, return
    
    int sortNumber = 1;
    for (int line = 0; line<tokenArrays.count; line++) {
        NSMutableArray *tokenArray = [tokenArrays objectAtIndex:line];
        NSString *formationName = [TextInputFilter filterDatabaseInputText:[tokenArray objectAtIndex:0]];
        
        //if formation name is not empty, then create the transient object
        if (formationName.length) {
            TransientFormation *newFormation = [[TransientFormation alloc] init];
            newFormation.formationFolder = newTransientFormationFolder;
            newFormation.formationName = formationName;
            newFormation.formationSortNumber=[NSNumber numberWithInt:sortNumber++];
            newFormation.color = [tokenArray objectAtIndex:1];
            [self.formations addObject:newFormation];
        }       
    }
    self.formationFolders = formationFolders.copy;
}

/* The format of this file would be two columns of data in a file for each formation folder. The first column is the formation type and the second would be the color associated with that formation type. If the color column is empty, the color would be default when the annotations are drawn.
 For example:
 
 Formations  Color  -> Column headings
 Formation1  Red
 Formation2  Blue
 ...         ...
 */
- (void)createFormationsWithColorFromCSVFiles:(NSArray *)files 
{
    //Post a notification
    [self postNotificationWithName:GeoNotificationIEEngineFormationImportingDidStart withUserInfo:[NSDictionary dictionary]];
    
    self.selectedFilePaths = [self getSelectedFilePaths:files];    
    
    //read each of those files line by line and create the formation objects and add it to self.formations array.
    for(NSString *path in self.selectedFilePaths) {
        //Construct formations from the file path
        NSString *folderName = [[[[path componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] objectAtIndex:0];
        [self constructFormationsWithColorsfromCSVFilePath:path withFolderName:folderName];
    }

   
    //call the handler
    //If there is any error message, pass nil to the handler as well as the error log
    if (self.validationMessageBoard.errorCount) {
        [self.handler processTransientFormations:nil 
                             andFormationFolders:nil
                        withValidationMessageLog:self.validationMessageBoard.allMessages];
    } else {
        [self.handler processTransientFormations:self.formations.copy 
                             andFormationFolders:self.formationFolders 
                        withValidationMessageLog:self.validationMessageBoard.warningMessages];  
    }
}

#pragma mark - CSV File Parsing

-(NSArray *)tokenArraysFromFile:(NSString *)filePath
{
    //if file does not exist, add the error message to the validation message board
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath]) {
        NSString *errorMessage=[NSString stringWithFormat:@"CSV File with name %@ cannot be found!",filePath.lastPathComponent];
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
        return nil;
    }
    
    //Array of token arrays read from the file
    NSMutableArray *tokenArrays = [NSMutableArray array];
    
    //read the contents of the file
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    //get all lines in the file
    NSArray *allLines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    //fix the case where newline characters (record separators) appear in the data field themselves
    allLines = [self fixNewLineCharactersInData:allLines];
    
    //Skip blank lines and parse the rest
    for(NSString *line in allLines) {
        if (line.length)
            [tokenArrays addObject:[self tokenArrayForLine:line]];
    }
    
    return tokenArrays.copy;
}

-(NSArray *)getSelectedFilePaths:(NSArray *)fileNames;
{   
    //Get the document directory path
    NSMutableArray *paths = [NSMutableArray array];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentDirPath = [urlArray.lastObject path];
    
    //Get the csv file paths from the document directory
    for (NSString *fileName in fileNames)
        [paths addObject:[documentDirPath stringByAppendingPathComponent:fileName]];
    
    return paths.copy;
}

- (NSArray *)tokenArrayForLine:(NSString *)line
{
    //Get tokens from each line
    NSMutableArray *tokenArray = [line componentsSeparatedByString:@","].mutableCopy;
    tokenArray = [self separateRecordsOrFieldsByCountingQuotations:tokenArray byAppending:@","];
        
    //Filter each token (get rid of extra quotation marks or any auxiliary, csv-added symbols)
    NSArray *filteredTokenArray=[self filterTokenArray:tokenArray.copy];
    
    return filteredTokenArray;
}
-(NSMutableArray *) fixNewLineCharactersInData:(NSArray *)records {
    return [self separateRecordsOrFieldsByCountingQuotations:records byAppending:@"\n"];
}

-(NSMutableArray *) separateRecordsOrFieldsByCountingQuotations:(NSArray *) array byAppending:(NSString *) separator {
    NSString *merged=@"";
    NSString *current=@"";
    BOOL repeat=NO;
    NSMutableArray *copy = [array mutableCopy];
    do {
        repeat = NO;
        int length = copy.count;
        for(int i = 0; i<length; i++) {
            current = [copy objectAtIndex:i];
            int quotes = [[current componentsSeparatedByString:@"\""] count]-1; //number of quotes
            if(quotes%2) { // if odd, merge with the next string value
                merged = [current stringByAppendingFormat:@"%@%@",separator,[copy objectAtIndex:i+1]];
                [copy replaceObjectAtIndex:i withObject:merged];
                [copy removeObjectAtIndex:i+1];
                repeat = YES;
                length = copy.count;
                break;
            }
        }
    } while (repeat);
        
    return copy;
}

- (NSArray *)filterTokenArray:(NSArray *)tokenArray {
    NSMutableArray *mutableTokenArray=tokenArray.mutableCopy;
    for (int i=0;i<tokenArray.count;i++) {
        NSString *token=[tokenArray objectAtIndex:i];
        [mutableTokenArray replaceObjectAtIndex:i withObject:[TextInputFilter stringFromCSVCompliantString:token]];
    }        
    
    return mutableTokenArray.copy;
}


#pragma mark - Creation of CSV files

-(void) createCSVFilesFromRecords:(NSArray *)records
{
    //Use a set so that we won't get any folder duplicates
    NSMutableSet *folders = [NSMutableSet set];
    
    //get the names of the folders from the array of records so you could create them
    for(Record *record in records)
        [folders addObject:record.folder];
        
    //Get the document directory path
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentDirPath = [urlArray.lastObject path];
    
    //create an dictionary of filehandlers. Key - folder name, Value - FileHandler for that folder
    NSMutableDictionary *fileHandlers = [NSMutableDictionary dictionary];
    NSMutableDictionary *mediaDirectories = [NSMutableDictionary dictionary];
    
    //for each project name, create a project folder in the documents directory with the same name. if the folder already exists, empty it. also create a media folder with the same name inside the directory
    for(Folder *folder in folders.allObjects) {
        //first create the paths
        NSString *folderName=folder.folderName;
        NSString *formationFolderName=folder.formationFolder ? folder.formationFolder.folderName : @"";
        NSString *dataDirectory = [documentDirPath stringByAppendingPathComponent:folderName];
        NSString *mediaDirectory = [dataDirectory stringByAppendingPathComponent:@"media"];
        [mediaDirectories setObject:mediaDirectory forKey:folderName]; 
        NSString *csvFileName=[NSString stringWithFormat:@"%@.record.csv",folderName];
        NSString *dataFile = [dataDirectory stringByAppendingPathComponent:csvFileName];
        
        //then create the directories...
        //create the data directory if not there already
        if (![fileManager fileExistsAtPath:dataDirectory])
            [fileManager createDirectoryAtPath:dataDirectory withIntermediateDirectories:NO attributes:nil error:NULL]; 
        else {
            //If the folder already, delete it and recreate it
            [fileManager removeItemAtPath:dataDirectory error:NULL];
            [fileManager createDirectoryAtPath:dataDirectory withIntermediateDirectories:NO attributes:nil error:NULL];             
        }
        
        //Create the media directory
        [fileManager createDirectoryAtPath:mediaDirectory withIntermediateDirectories:NO attributes:nil error:NULL];
        
        //create the file if it does not exist
        if(![fileManager fileExistsAtPath:dataFile])
            [fileManager createFileAtPath: dataFile contents:nil attributes:nil];
        NSFileHandle *handler = [NSFileHandle fileHandleForWritingAtPath:dataFile];
        [fileHandlers setObject:handler forKey:folderName];
        
        //clear all contents of the file
        [handler truncateFileAtOffset:0]; 
        
        //write the group information - a.k.a the metadata
        //metadata format:
        //Header - Line 0
        //Group Name - Line 1
        //Group ID (Unique ID) - Line 2
        //Folder Name - Line 3
        //Separator btw metadata section and record section - Line 4
        NSString *header = [NSString stringWithFormat:@"%@,  \n",METADATA_HEADER];
        NSString *groupName = [NSString stringWithFormat:@"Group Name, %@ \n",self.settingManager.groupName]; //get it from the settings manager
        NSString *groupID = [NSString stringWithFormat:@"Group ID, %@ \n",self.settingManager.groupID];; //get it from the manager
        NSString *folderNameLine=[NSString stringWithFormat:@"Folder Name, %@ \n",folderName];
        NSString *formationFolderNameLine=[NSString stringWithFormat:@"%@, %@ \n",FORMATION_FOLDER_HEADER,formationFolderName];
        NSString *separatorLine=@", \n";
        
        //write the header data
        [handler writeData:[header dataUsingEncoding:NSUTF8StringEncoding]];
        [handler writeData:[groupName dataUsingEncoding:NSUTF8StringEncoding]];
        [handler writeData:[groupID dataUsingEncoding:NSUTF8StringEncoding]];
        [handler writeData:[folderNameLine dataUsingEncoding:NSUTF8StringEncoding]];
        [handler writeData:[formationFolderNameLine dataUsingEncoding:NSUTF8StringEncoding]];
        [handler writeData:[separatorLine dataUsingEncoding:NSUTF8StringEncoding]];
        
        //Record section
        //write the column headings to the csv
        NSString *titles = [NSString stringWithFormat:@"Name, Type, Longitude, Latitude, Date,Time, Strike, Dip, Dip Direction, Observations, Formation, Lower Formation, Upper Formation, Trend, Plunge, Image file name \n"];
        [handler writeData:[titles dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //now call the method that writes onto the array of records into their respective csv files
    [self writeRecords:records withFileHandlers:fileHandlers.copy andSaveImagesInPath:mediaDirectories.copy];
    
    //Post a notification when done
    [self postNotificationWithName:GeoNotificationIEEngineExportingDidEnd withUserInfo:[NSDictionary dictionary]];
}

- (void)writeRecord:(Record *)record withFileHandler:(NSFileHandle *)fileHandler mediaDirectoryPath:(NSString *)mediaDirPath {  
    //now get all the common fields
    NSString *name = [TextInputFilter csvCompliantStringFromString:record.name];
    NSString *observation = [TextInputFilter csvCompliantStringFromString:record.fieldObservations];
    NSString *longitude = [TextInputFilter csvCompliantStringFromString:record.longitude];
    NSString *latitude = [TextInputFilter csvCompliantStringFromString:record.latitude];
    NSString *dip = [TextInputFilter csvCompliantStringFromString:[NSString stringWithFormat:@"%@", record.dip]];
    NSString *dipDir = [TextInputFilter csvCompliantStringFromString:record.dipDirection];
    NSString *strike = [TextInputFilter csvCompliantStringFromString:[NSString stringWithFormat:@"%@", record.strike]];
        
    //get the date and time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];        
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init]; 
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    
    NSString *date = [TextInputFilter csvCompliantStringFromString:[dateFormatter stringFromDate:record.date]];
    NSString *time = [TextInputFilter csvCompliantStringFromString:[timeFormatter stringFromDate:record.date]];
    NSString *type = [TextInputFilter csvCompliantStringFromString:[record.class description]];
        
    //now get the type, and type-specific fields   
    NSString *formation=@"";
    NSString *lowerFormation=@"";
    NSString *upperFormation=@"";
    NSString *plunge=@"";
    NSString *trend=@"";
    if([record isKindOfClass:[Bedding class]] || [record isKindOfClass:[JointSet class]] || [record isKindOfClass:[Fault class]]) {
        formation=[(id)record formationName];
    } else if([record isKindOfClass:[Contact class]]) {
        lowerFormation=[(Contact *)record lowerFormationName];
        upperFormation=[(Contact *)record upperFormationName];
    } else if([record isKindOfClass:[Fault class]]) {
        Fault *fault=(Fault *)record;
        plunge = [NSString stringWithFormat:@"%@", fault.plunge];
        trend = [NSString stringWithFormat:@"%@", fault.trend];
    } else if([record isKindOfClass:[Other class]]) {
        //nothing to populate
    }       
    
    //Filter the type-specific fields
    formation=[TextInputFilter csvCompliantStringFromString:formation];
    lowerFormation=[TextInputFilter csvCompliantStringFromString:lowerFormation];
    upperFormation=[TextInputFilter csvCompliantStringFromString:upperFormation];
    plunge=[TextInputFilter csvCompliantStringFromString:plunge];
    trend=[TextInputFilter csvCompliantStringFromString:trend];
    
    //save the image file  
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *imageFileName=@"";
    if(record.image) {                  
       imageFileName = [NSString stringWithFormat:@"%@_%@.jpeg", record.folder.folderName, record.name];
        NSString *imageFilePath = [mediaDirPath stringByAppendingPathComponent:imageFileName];
        if(![fileManager fileExistsAtPath:imageFilePath]){
            [fileManager createFileAtPath:imageFilePath contents:nil attributes:nil];
            
            NSFileHandle *mediaFileHandler = [NSFileHandle fileHandleForWritingAtPath:imageFilePath];
            NSData *image=UIImageJPEGRepresentation([[UIImage alloc] initWithData:record.image.imageData], 1.0);
            [mediaFileHandler writeData:image];
            [mediaFileHandler closeFile];
        }
    }
    
    //finally write the string tokens to the csv file
    NSString *recordData=@"";
    recordData = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                  name,type,longitude,latitude,date,time,strike,dip,dipDir,observation,formation,lowerFormation,upperFormation,trend,plunge,imageFileName];
    [fileHandler writeData:[recordData dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)writeRecords:(NSArray *)records withFileHandlers:(NSDictionary *)fileHandlers andSaveImagesInPath:(NSDictionary *) mediaDirectories 
{        
    //Get the data from each record
    for(Record *record in records) {
        //Write each record out
        NSString *folderName=record.folder.folderName;
        NSFileHandle *fileHandler=[fileHandlers objectForKey:folderName];
        [self writeRecord:record withFileHandler:fileHandler mediaDirectoryPath:[mediaDirectories objectForKey:folderName]];
    }
    
    //close all the filehandlers
    for(NSFileHandle *handler in [fileHandlers allValues])
        [handler closeFile];
}

#pragma mark - Creation of CSV for formations

-(void) createCSVFilesFromFormationsWithColors:(NSArray *) formations 
{
    NSMutableDictionary *formationsByFolders = [NSMutableDictionary dictionary];
    for(Formation *formation in formations) {
        //check if the foldername key is already present, if so add the new formation to the value for the key (array of formations), otherwise create a new array and add it to the dictionary.
        if([formationsByFolders.allKeys containsObject:formation.formationFolder.folderName]) {
            //new formation to add
            NSArray *newFormation = [NSArray arrayWithObjects:[ TextInputFilter csvCompliantStringFromString:formation.formationName], [TextInputFilter csvCompliantStringFromString:formation.color], nil];
            
            //get the existing value
            NSMutableArray *formationArray =[formationsByFolders objectForKey:formation.formationFolder.folderName];
            [formationsByFolders removeObjectForKey:formation.formationFolder.folderName];
            [formationArray addObject:newFormation];
            [formationsByFolders setObject:formationArray forKey:formation.formationFolder.folderName];
        } else {
            NSArray *newFormation = [NSArray arrayWithObjects: [TextInputFilter csvCompliantStringFromString:formation.formationName], [TextInputFilter csvCompliantStringFromString:formation.color], nil];
            NSMutableArray *formationArray = [NSMutableArray arrayWithObject:newFormation];
            [formationsByFolders setObject:formationArray forKey:formation.formationFolder.folderName];
        }
    }
    
    [self writeFormationFilesWithColor:formationsByFolders];
    
    //Post a notification when done so that the spinner stops
    [self postNotificationWithName:GeoNotificationIEEngineExportingDidEnd withUserInfo:[NSDictionary dictionary]];
}

- (NSArray *)transposedFormationArrayFromDictionary:(NSDictionary *)formationsByFoldersDictionary {
    //Process the formation by folder dictionary into a two dimensional array; each of the element array contains
    //the formation folder name and all its formations' names
    NSMutableArray *twoDimensionalArray=[NSMutableArray array];
    NSArray *allKeys=formationsByFoldersDictionary.allKeys;
    allKeys=[allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *folderName in allKeys) {
        NSMutableArray *entry=[NSMutableArray arrayWithObject:folderName];
        [entry addObjectsFromArray:(NSArray *)[formationsByFoldersDictionary objectForKey:folderName]];
        [twoDimensionalArray addObject:entry.copy];
    }
    
    NSArray *transposedArray=[IEFormatter transposeTwoDimensionalArray:twoDimensionalArray.copy];
    
    return transposedArray;
}

-(void)writeFormationFilesWithColor:(NSDictionary *)formationsSeparatedByFolders {
    //get the path to documents directory
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlsArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentsDirectory = [[urlsArray objectAtIndex:0] path];
    
    for(NSString *folder in formationsSeparatedByFolders.allKeys ) {
        //first create the file, if a file by that name already exists, overwrite.
        NSString *destinationPath = [NSString stringWithFormat:@"%@/%@.formation.csv", documentsDirectory, folder];
        [[NSFileManager defaultManager] createFileAtPath:destinationPath contents:nil attributes:nil];
        NSFileHandle *handler = [NSFileHandle fileHandleForWritingAtPath:destinationPath];
        
        //now write the contents - first write the column headings, then the contents
        NSString *header = [NSString stringWithFormat:@"Formation,Color\n"];
        [handler writeData:[header dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSArray *formationsArray = [formationsSeparatedByFolders objectForKey:folder];
        NSString *line;
        for(NSArray *formations in formationsArray) 
        {
            if(formations.count==2) {
                line = [NSString stringWithFormat:@"%@,%@\n", [formations objectAtIndex:0], [formations objectAtIndex:1]];
                [handler writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        [handler closeFile];
    }
}

#pragma mark - Student Response Exporting

- (NSString *)feedbackFilePath {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSString *feedbackFilePath=[documentDirURL.path stringByAppendingPathComponent:FEEDBACK_FILENAME];
    
    return feedbackFilePath;
}

- (void)createCSVFilesFromStudentResponses:(NSArray *)responses {
    //Create token matrix from responses
    NSMutableArray *tokenMatrix=[NSMutableArray array];
    for (Answer *response in responses)
        [tokenMatrix addObject:[self tokenArrayFromResponse:response]];
    
    //Write the token matrix to file
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *feedbackFilePath=self.feedbackFilePath;
    
    //Create the file and add the the token array to the matrix if the file doesn't exist yet
    BOOL fileNewlyCreated=NO;
    if (![fileManager fileExistsAtPath:feedbackFilePath]) {
        fileNewlyCreated=YES;
        
        //Create the file
        [fileManager createFileAtPath:feedbackFilePath contents:nil attributes:nil];
                
        //write the group information - a.k.a the metadata
        //metadata format:
        //Header - Line 0
        //Group Name - Line 1
        //Group ID (Unique ID) - Line 2
        //Separator btw metadata section and response section - Line 3
        NSArray *metadataHeader = [NSArray arrayWithObjects:METADATA_HEADER,@"", nil];
        NSArray *groupName = [NSArray arrayWithObjects:@"Group Name",self.settingManager.groupName, nil]; //get it from the settings manager
        NSArray *groupID = [NSArray arrayWithObjects:@"Group ID",self.settingManager.groupID, nil]; //get it from the manager
        NSArray *numFeedback = [NSArray arrayWithObjects:@"# Feedbacks", @"3",nil];
        NSArray *separatorLine=[NSArray arrayWithObjects:@"",@"", nil];;
        
        //Add the header token array
        NSArray *headerTokenArray=[NSArray arrayWithObjects:@"Question",@"Response",@"Date",@"Time",@"Latitude",@"Longitude",@"Number of Records", nil];
        
        //write the header data
        NSArray *insertedHeaders=[NSArray arrayWithObjects:metadataHeader,groupName,groupID,numFeedback,separatorLine,headerTokenArray, nil];
        NSIndexSet *indexes=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 6)];
        [tokenMatrix insertObjects:insertedHeaders atIndexes:indexes];
    }
    
    NSFileHandle *handler = [NSFileHandle fileHandleForWritingAtPath:feedbackFilePath];
    
    //Append the response data to the file (without overwriting it)
    [handler seekToEndOfFile];
    
    //Write a blank line if the file is not newly created
    if (!fileNewlyCreated)
        [handler writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    for (NSArray *tokenArray in tokenMatrix) {
        NSString *line=[tokenArray componentsJoinedByString:@", "];
        line=[line stringByAppendingString:@"\n"];
        [handler writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [handler closeFile];
}

- (NSArray *)tokenArrayFromResponse:(Answer *)response {
    //Create a token array from the given response
    NSMutableArray *tokenArray=[NSMutableArray array];
    [tokenArray addObject:response.question.prompt];
    [tokenArray addObject:response.content];
    [tokenArray addObject:response.day];
    [tokenArray addObject:response.time];
    [tokenArray addObject:[NSString stringWithFormat:@"%@",response.latitude]];
    [tokenArray addObject:[NSString stringWithFormat:@"%@",response.longitude]];
    [tokenArray addObject:[NSString stringWithFormat:@"%@",response.numberOfRecords]];
    
    return tokenArray.copy;
}

#pragma mark - Update Mechanisms

- (void)updateFeedbackFileWithInfo:(NSDictionary *)feedbackInfo {
    //Open the feedback csv file
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *feedbackFilePath=self.feedbackFilePath;
    
    //Modify the file's metadata if it exists
    if ([fileManager fileExistsAtPath:feedbackFilePath]) {
        //read the contents of the file
        NSString *content = [NSString stringWithContentsOfFile:feedbackFilePath encoding:NSUTF8StringEncoding error:NULL];
        
        //get all lines in the file
        NSMutableArray *allLines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].mutableCopy;
        
        //delete the old metadata (First 3 lines)
        NSIndexSet *indexes=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)];
        [allLines removeObjectsAtIndexes:indexes];
                
        //metadata format:
        //Header - Line 0
        //Group Name - Line 1
        //Group ID (Unique ID) - Line 2
        //Number of feedbacks per feedback record (aka. feedback collection)
        NSString *metadataHeader = [NSString stringWithFormat:@"%@,  ",METADATA_HEADER];
        NSString *groupName = [NSString stringWithFormat:@"Group Name, %@ ",self.settingManager.groupName]; //get it from the settings manager
        NSString *groupID = [NSString stringWithFormat:@"Group ID, %@ ",self.settingManager.groupID]; //get it from the manager
        NSString *numFeedback = [NSString stringWithFormat:@"# Feedbacks, 3"];
                
        //add the new metadata
        [allLines insertObjects:[NSArray arrayWithObjects:metadataHeader,groupName,groupID,numFeedback, nil] atIndexes:indexes];
                
        //Rewrite the file
        NSFileHandle *fileHandler=[NSFileHandle fileHandleForUpdatingAtPath:feedbackFilePath];
        [fileHandler truncateFileAtOffset:0];
        for (NSString *line in allLines) {
            NSString *writtenLine=[line stringByAppendingString:@"\n"];
            [fileHandler writeData:[writtenLine dataUsingEncoding:NSUTF8StringEncoding]];
        }
            
        //Close the file
        [fileHandler closeFile];
    }
}

@end