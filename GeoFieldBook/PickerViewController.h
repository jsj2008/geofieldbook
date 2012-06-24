//
//  PickerViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic,strong) NSArray *componentMatrix;   //The matrix of components; i.e. array of columns, which are arrays of rows of components

- (NSString *)userSelection;

@end