//
//  RecordSettingsTVC.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordSettingsTVC.h"

#import "SettingManager.h"

@interface RecordSettingsTVC ()

@property (nonatomic,readonly) SettingManager *settingManager;

@property (weak, nonatomic) IBOutlet UILabel *currentFolderLabel;
@property (weak, nonatomic) IBOutlet UITextField *currentCounterText;
@property (weak, nonatomic) IBOutlet UISwitch *prefixEnabledSwitch;
@property (weak, nonatomic) IBOutlet UITextField *prefixText;

@property (weak, nonatomic) IBOutlet UILabel *currentFolderL;
@property (weak, nonatomic) IBOutlet UILabel *currentCounterL;
@property (weak, nonatomic) IBOutlet UILabel *automaticPrefixL;
@property (weak, nonatomic) IBOutlet UILabel *prefixL;

@end

@implementation RecordSettingsTVC

@synthesize currentFolderLabel = _currentFolderLabel;
@synthesize currentCounterText = _currentCounterText;
@synthesize prefixEnabledSwitch = _prefixEnabledSwitch;
@synthesize prefixText = _prefixText;
@synthesize currentFolderL = _currentFolderL;
@synthesize currentCounterL = _currentCounterL;
@synthesize automaticPrefixL = _automaticPrefixL;
@synthesize prefixL = _prefixL;

@synthesize currentFolder=_currentFolder;

#pragma mark - Getters and Setters

- (SettingManager *)settingManager {
    return [SettingManager standardSettingManager];
}

- (void)setCurrentFolder:(NSString *)currentFolder {
    _currentFolder=currentFolder;
    
    //Setup the UI
    [self setupInterface];
}

- (void)setupInterface {
    //Enable/Disable
    BOOL enabled=self.currentFolder!=nil;
    self.currentFolderLabel.enabled=enabled;
    self.currentCounterText.enabled=enabled;
    self.prefixEnabledSwitch.enabled=enabled;
    self.prefixEnabledSwitch.userInteractionEnabled=enabled;
    self.prefixText.enabled=enabled;
    self.currentFolderL.enabled=enabled;
    self.currentCounterL.enabled=enabled;
    self.automaticPrefixL.enabled=enabled;
    self.prefixL.enabled=enabled;
    
    //If there is a current folder, fill in the appropriate info
    if (self.currentFolder) {
        //Fill info
        self.currentFolderLabel.text=self.currentFolder;
        self.currentCounterText.text=[NSString stringWithFormat:@"%@",[self.settingManager prefixCounterForFolderWithName:self.currentFolder]];
        self.currentCounterText.placeholder=self.currentCounterText.text;
        self.prefixText.text=[NSString stringWithFormat:@"%@",[self.settingManager prefixForFolderWithName:self.currentFolder]];
        self.prefixEnabledSwitch.on=[self.settingManager recordPrefixEnabledForFolderWithName:self.currentFolder];
    }
    
    //Else reset info
    else {
        self.currentFolderLabel.text=@"(Not in any folder)";
        self.currentCounterText.text=@"";
        self.currentCounterText.placeholder=@"0";
        self.prefixText.text=@"";
        self.prefixText.placeholder=@"N/A";
    }
}

#pragma mark - Target-Action Handlers

- (IBAction)prefixCounterChanged:(UITextField *)sender {
    //Validate the new prefix counter
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    NSString *newCounter=sender.text;
    
    //If the new prefix counter is not a positive integer, set it to its previous value
    NSNumber *counter=[numberFormatter numberFromString:newCounter];
    if (!counter)
        sender.text=[NSString stringWithFormat:@"%@",[self.settingManager prefixCounterForFolderWithName:self.currentFolder]];
    
    //Else update prefix counter and the place holder
    else {
        NSLog(@"value: %d",counter.intValue);
        counter=[NSNumber numberWithInt:counter.intValue];
        [self.settingManager setPrefixCounter:counter forFolderWithName:self.currentFolder];
        sender.text=[NSString stringWithFormat:@"%@",counter];
        sender.placeholder=sender.text;
    }
}

- (IBAction)prefixChanged:(UITextField *)sender {
    //Update the prefix
    [self.settingManager setPrefix:sender.text forFolderWithName:self.currentFolder];
}

- (IBAction)automaticPrefixSwitched:(UISwitch *)sender {
    //Update prefix enabled
    [self.settingManager setPrefixEnabled:sender.isOn forFolderWithName:self.currentFolder];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Setup the UI
    [self setupInterface];
}

- (void)viewDidUnload {
    [self setCurrentFolderLabel:nil];
    [self setCurrentCounterText:nil];
    [self setPrefixEnabledSwitch:nil];
    [self setPrefixText:nil];
    [self setCurrentFolderL:nil];
    [self setCurrentCounterL:nil];
    [self setAutomaticPrefixL:nil];
    [self setPrefixL:nil];
    [self setPrefixText:nil];
    [super viewDidUnload];
}
@end
