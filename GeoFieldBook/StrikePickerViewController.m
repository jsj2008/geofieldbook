//
//  StrikePickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "StrikePickerViewController.h"

@interface StrikePickerViewController() <UIPickerViewDelegate>

@end

@implementation StrikePickerViewController

@synthesize delegate=_delegate;

@synthesize previousSelection=_previousSelection;

#pragma mark - Getters and Setters

- (void)setPreviousSelection:(NSString *)previousSelection {
    if (previousSelection) {
        //Add 0 to the previous selection if it has length < 3
        if (previousSelection.length<3) {
            int length=previousSelection.length;
            for (int i=0;i<3-length;i++)
                previousSelection=[@"0" stringByAppendingString:previousSelection];
        }
        
        _previousSelection=previousSelection;
    }
}

#pragma mark - Picker View State Initialization

- (NSArray *)strikeComponentMatrix {
    //First component
    NSArray *firstComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3", nil];
    
    //Second component
    NSArray *secondComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    //Third component
    NSArray *thirdComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    return [NSArray arrayWithObjects:firstComponent,secondComponent,thirdComponent, nil];
}

#pragma mark - User Selection Manipulation

- (void)handleUserSelection {
    //Handle selection
    [super handleUserSelection];
    
    //Format the number
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    NSString *userSelection=[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:self.userSelection]];
    
    //Notify the delegate of user's selection
    [self.delegate strikePickerViewController:self userDidSelectStrikeValue:userSelection];
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Handle user selection
    [self handleUserSelection];
}

#pragma mark - View Controller Lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Setup the component matrix
    self.componentMatrix=[self strikeComponentMatrix];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end