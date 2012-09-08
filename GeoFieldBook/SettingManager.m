//
//  SettingManager.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "SettingManager.h"

#import "GeoDatabaseManager.h"
#import "Folder.h"

@interface SettingManager()

@property (nonatomic,readonly) NSUserDefaults *userDefaults;
@property (nonatomic,readonly) UIManagedDocument *database;

@end

@implementation SettingManager

static SettingManager *settingManager;

+ (void)initialize {
    [super initialize];
    
    //Set up the singleton instance
    if (!settingManager)
        settingManager=[[SettingManager alloc] init];
}

+ (SettingManager *)standardSettingManager {
    return settingManager;
}

- (SettingManager *)init {
    if (self=[super init]) {
        //Register to hear changes from the setting program
        NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self
                               selector:@selector(userPreferencesDidChange:)
													 name:NSUserDefaultsDidChangeNotification
												   object:[NSUserDefaults standardUserDefaults]];
    }
    
    return self;
}

- (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (UIManagedDocument *)database {
    return [GeoDatabaseManager standardDatabaseManager].geoFieldBookDatabase;
}

- (void)userDefaultsSetObject:(id)object forKey:(NSString *)key {
    [self.userDefaults setObject:object forKey:key];
    [self.userDefaults synchronize];
}

- (void)userDefaultsSetBool:(BOOL)flag forKey:(NSString *)key {
    [self.userDefaults setBool:flag forKey:key];
    [self.userDefaults synchronize];
}

#pragma mark - Notification Center

- (void)postNotificationWithName:(NSString *)name andUserInfo:(NSDictionary *)userInfo {
    //Post the notification
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:self userInfo:userInfo];    
}

- (void)postFeedbackNotification {
    //If the feedback system is enabled, proceed
    if (self.feedbackEnabled) {
        //Get the interval and counter
        int feedbackInterval=self.feedbackInterval.intValue;
        int feedbackCounter=self.feedbackCounter.intValue;
        
        if (feedbackCounter>=feedbackInterval) {
            //Post a notification
            [self postNotificationWithName:SettingManagerFeedbackTimeout andUserInfo:[NSDictionary dictionary]];
        }
    }
}

- (void)userPreferencesDidChange:(NSNotification *)notification {
    //Post notifications
    NSDictionary *userInfo=[NSDictionary dictionary];
    [self postNotificationWithName:SettingManagerUserPreferencesDidChange andUserInfo:userInfo];
}

#pragma mark - Color Group

-(NSString *) defaultFormationColorName {
    return [self.userDefaults objectForKey:NSUserDefaultsDefaultFormationColor];
}

- (BOOL)formationColorEnabled {
    return [self.userDefaults boolForKey:NSUserDefaultsFormationColorEnabled];
}

- (void)setFormationColorEnabled:(BOOL)formationColorEnabled {
    [self userDefaultsSetBool:formationColorEnabled forKey:NSUserDefaultsFormationColorEnabled];
}

- (UIColor *)defaultFormationColor {
    return [self.userDefaults objectForKey:NSUserDefaultsDefaultFormationColor];
}

- (void)setDefaultFormationColor:(NSString *)defaultFormationColor {
    [self userDefaultsSetObject:defaultFormationColor forKey:NSUserDefaultsDefaultFormationColor];
}


- (UIColor *)defaultSymbolColor {
    UIColor *defaultSymbolColor=nil;
    NSString *defaultSymbolColorPreference=[self.userDefaults objectForKey:NSUserDefaultsDefaultSymbolColor];
    if ([defaultSymbolColorPreference isEqualToString:@"Red"])
        defaultSymbolColor=[UIColor redColor];
    else if ([defaultSymbolColorPreference isEqualToString:@"Blue"])
        defaultSymbolColor=[UIColor blueColor];
    else if ([defaultSymbolColorPreference isEqualToString:@"Black"])
        defaultSymbolColor=[UIColor blackColor];
    
    return defaultSymbolColor;
}

- (void)setDefaultSymbolColor:(NSString *)defaultSymbolColor {
    [self userDefaultsSetObject:defaultSymbolColor forKey:NSUserDefaultsDefaultSymbolColor];
}

#pragma mark - Gestures Group

- (BOOL)longGestureEnabled {
    return [self.userDefaults boolForKey:NSUserDefaultsLongPressEnabled];
}

- (void)setLongGestureEnabled:(BOOL)longGestureEnabled {
    [self userDefaultsSetBool:longGestureEnabled forKey:NSUserDefaultsLongPressEnabled];
}

- (BOOL)swipeToTurnRecordEnabled {
    return [self.userDefaults boolForKey:NSUserDefaultsSwipeRecordEnabled];
}

- (void)setSwipeToTurnRecordEnabled:(BOOL)swipeToTurnRecordEnabled {
    return [self userDefaultsSetBool:swipeToTurnRecordEnabled forKey:NSUserDefaultsSwipeRecordEnabled];
}

-(NSNumber *)recordSwipeGestureNumberOfFingersRequired {
    return [self.userDefaults objectForKey:NSUserDefaultsSwipeRecord];
}

- (void)setRecordSwipeGestureNumberOfFingersRequired:(NSNumber *)recordSwipeGestureNumberOfFingersRequired {
    [self userDefaultsSetObject:recordSwipeGestureNumberOfFingersRequired forKey:NSUserDefaultsSwipeRecord];
}

#pragma mark - Feedback Group

- (BOOL)feedbackEnabled {
    return [self.userDefaults boolForKey:NSUserDefaultsFeedbackEnabled];
}

- (void)setFeedbackEnabled:(BOOL)feedbackEnabled {
    [self userDefaultsSetBool:feedbackEnabled forKey:NSUserDefaultsFeedbackEnabled];
}

- (NSNumber *)feedbackInterval {
    return [self.userDefaults objectForKey:NSUserDefaultsFeedbackInterval];
}

- (void)setFeedbackInterval:(NSNumber *)feedbackInterval {
    [self userDefaultsSetObject:feedbackInterval forKey:NSUserDefaultsFeedbackInterval];
}

- (NSNumber *)feedbackCounter {
    return [self.userDefaults objectForKey:NSUserDefaultsFeedbackCounter];
}

- (void)setFeedbackCounter:(NSNumber *)feedbackCounter {
    //Set the feedback counter
    [self userDefaultsSetObject:feedbackCounter forKey:NSUserDefaultsFeedbackCounter];
    
    //Feedback notification
    [self postFeedbackNotification];
}

#pragma mark - Dip Strike Symbol Group

- (BOOL)dipNumberEnabled {
    return [self.userDefaults boolForKey:NSUserDefaultsDipNumberEnabled];
}

- (void)setDipNumberEnabled:(BOOL)dipNumberEnabled {
    [self userDefaultsSetBool:dipNumberEnabled forKey:NSUserDefaultsDipNumberEnabled];
}

- (NSString *)defaultContactFormation {
    return [self.userDefaults objectForKey:NSUserDefaultsContactDefaultFormation];
}

- (void)setDefaultContactFormation:(NSString *)defaultContactFormation {
    [self userDefaultsSetObject:defaultContactFormation forKey:NSUserDefaultsContactDefaultFormation];
}

#pragma mark - Group Settings Group

+ (NSString *)generateGroupID {
    //Create a new group id
    NSTimeInterval timeInterval=[[NSDate date] timeIntervalSince1970];
    CFUUIDRef uuidObject=CFUUIDCreate(kCFAllocatorDefault);
    NSString *uniqueIdentifier1=(__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    
    uuidObject=CFUUIDCreate(kCFAllocatorDefault);
    NSString *uniqueIdentifier2=(__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    
    NSString *groupID=[NSString stringWithFormat:@"%@%f%@",uniqueIdentifier1,timeInterval,uniqueIdentifier2];
    
    //Save the id to settings
    [SettingManager standardSettingManager].groupID=groupID;
    
    return groupID;
}

- (NSString *)groupName {
    return [self.userDefaults objectForKey:NSUserDefaultsGroupName];
}

- (void)setGroupName:(NSString *)groupName {
    [self userDefaultsSetObject:groupName forKey:NSUserDefaultsGroupName];
}

- (NSString *)groupID {
    return [self.userDefaults objectForKey:NSUserDefaultsGroupID];
}

- (void)setGroupID:(NSString *)groupID {
    [self userDefaultsSetObject:groupID forKey:NSUserDefaultsGroupID];
}

#pragma mark - Record Settings Group

typedef void (^save_handler_t)(void);

- (void)saveToDatabaseWithCompletionHandler:(save_handler_t)completionHandler {
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success)
            completionHandler();
    }];
}

- (Folder *)folderWithName:(NSString *)folderName {
    //Query for the folder with the given name
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    return results.lastObject;
}

- (BOOL)recordPrefixEnabledForFolderWithName:(NSString *)folderName {
    return [self folderWithName:folderName].prefixEnabled.boolValue;
}

- (void)setPrefixEnabled:(BOOL)enabled forFolderWithName:(NSString *)folderName {
    Folder *folder=[self folderWithName:folderName];
    folder.prefixEnabled=[NSNumber numberWithBool:enabled];
    [self saveToDatabaseWithCompletionHandler:^{}];
}

- (NSString *)prefixForFolderWithName:(NSString *)folderName {
    NSString *prefix=[self folderWithName:folderName].prefixText;
    return prefix ? prefix : folderName;
}

- (void)setPrefix:(NSString *)prefix forFolderWithName:(NSString *)folderName {
    Folder *folder=[self folderWithName:folderName];
    folder.prefixText=prefix;
    [self saveToDatabaseWithCompletionHandler:^{}];
}

- (NSNumber *)prefixCounterForFolderWithName:(NSString *)folderName {
    NSNumber *prefixCounter=[self folderWithName:folderName].prefixCounter;
    return prefixCounter ? prefixCounter : [NSNumber numberWithInt:1];
}

- (void)setPrefixCounter:(NSNumber *)prefixCounter forFolderWithName:(NSString *)folderName {
    Folder *folder=[self folderWithName:folderName];
    folder.prefixCounter=prefixCounter;
    [self saveToDatabaseWithCompletionHandler:^{}];
}

@end
