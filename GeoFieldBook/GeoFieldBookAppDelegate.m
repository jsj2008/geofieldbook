//
//  GeoFieldBookAppDelegate.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoFieldBookAppDelegate.h"

#import "GeoDatabaseManager.h"
#import "SettingManager.h"

#import "Question+Types.h"

@interface GeoFieldBookAppDelegate()
    
@property (nonatomic,readonly) SettingManager *settingManager;

void uncaughtExceptionHandler(NSException *exception);

@end

@implementation GeoFieldBookAppDelegate

@synthesize window = _window;

- (SettingManager *)settingManager {
    return [SettingManager standardSettingManager];
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (void)registerDefaultsForPListFile:(NSString *)plistFileName {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:plistFileName]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if (key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

- (void)setDefaultGroupInfo {
    if (!self.settingManager.groupID)
        [SettingManager generateGroupID];
    
    if (!self.settingManager.groupName.length)
        self.settingManager.groupName=@"GeoFieldBook";
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Custom Exception Handler
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    //Initialize the settings
    [self registerDefaultsForPListFile:@"Map Symbols.plist"];
    [self registerDefaultsForPListFile:@"Feedback.plist"];
    [self registerDefaultsForPListFile:@"Record Settings.plist"];
    
    [self setDefaultGroupInfo];
    
    // Override point for customization after application launch.
    return YES;
}

@end
