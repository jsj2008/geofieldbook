//
//  SettingManager.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SettingManagerNotificationNames.h"

@interface SettingManager : NSObject

+ (SettingManager *)standardSettingManager;

#pragma mark - Color Group

#define NSUserDefaultsFormationColorEnabled @"color_formation_color_enabled"
#define NSUserDefaultsDefaultFormationColor @"color_default_formation_color"
#define NSUserDefaultsDefaultSymbolColor @"color_default_symbol_color"

@property (nonatomic) BOOL formationColorEnabled;
@property (nonatomic,strong) NSString *defaultFormationColor;
@property (nonatomic,strong) UIColor *defaultSymbolColor;

#pragma mark - Gestures Group

#define NSUserDefaultsLongPressEnabled @"gestures_long_press_enabled"
#define NSUserDefaultsSwipeRecordEnabled @"gestures_swipe_record_enabled"
#define NSUserDefaultsSwipeRecord @"gestures_swipe_record"

@property (nonatomic) BOOL longGestureEnabled;
@property (nonatomic) BOOL swipeToTurnRecordEnabled;
@property (nonatomic,strong) NSNumber *recordSwipeGestureNumberOfFingersRequired;

#pragma mark - Feedback Group

#define NSUserDefaultsFeedbackEnabled @"feedback_enabled"
#define NSUserDefaultsFeedbackInterval @"feedback_interval"
#define NSUserDefaultsFeedbackCounter @"feedback_counter"

@property (nonatomic) BOOL feedbackEnabled;
@property (nonatomic,strong) NSNumber *feedbackInterval;
@property (nonatomic,strong) NSNumber *feedbackCounter;

#pragma mark - Dip Strike Symbol Group

#define NSUserDefaultsDipNumberEnabled @"dip_number_enabled"
#define NSUserDefaultsContactDefaultFormation @"contact_default_formation"

@property (nonatomic) BOOL dipNumberEnabled;
@property (nonatomic,strong) NSString *defaultContactFormation;

#pragma mark - Group Settings Group

#define NSUserDefaultsGroupName @"group_name"
#define NSUserDefaultsGroupID @"group_id"

+ (NSString *)generateGroupID;

@property (nonatomic,strong) NSString *groupName;
@property (nonatomic,strong) NSString *groupID;

#pragma mark - Record Settings Group

- (BOOL)recordPrefixEnabledForFolderWithName:(NSString *)folderName;
- (void)setPrefixEnabled:(BOOL)enabled forFolderWithName:(NSString *)folderName;

- (NSString *)prefixForFolderWithName:(NSString *)folderName;
- (void)setPrefix:(NSString *)prefix forFolderWithName:(NSString *)folderName;

- (NSNumber *)prefixCounterForFolderWithName:(NSString *)folderName;
- (void)setPrefixCounter:(NSNumber *)prefixCounter forFolderWithName:(NSString *)folderName;

@end