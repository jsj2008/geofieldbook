//
//  RecordViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "FlippablePage.h"

#import "Record.h"
#import "Record+Creation.h"
#import "Record+State.h"
#import "Record+DictionaryKeys.h"
#import "Record+Modification.h"
#import "Record+Validation.h"
#import "Record+NameEncoding.h"

#import "Formation.h"

#import "Bedding.h"
#import "Contact.h"
#import "JointSet.h"
#import "JointSet+Description.h"
#import "Fault.h"
#import "Other.h"

#import "Image.h"
#import "Record+DateAndTimeFormatter.h"

#import "RecordViewControllerDelegate.h"

@interface RecordViewController : UIViewController <FlippablePage>

@property (nonatomic,strong) Record *record;
@property (nonatomic,weak) id <RecordViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (NSDictionary *)dictionaryFromForm;
- (BOOL) isInEdittingMode;
- (void)cancelEditingMode;

- (void)showKeyboard;
- (void)resignAllTextFieldsAndAreas;

- (void)showImage;

#define RECORD_DEFAULT_GPS_STABLILIZING_INTERVAL_LENGTH 12

@end
