//
//  PlungePickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PlungePickerViewController.h"

@interface PlungePickerViewController ()

@end

@implementation PlungePickerViewController

@synthesize delegate=_delegate;

@synthesize previousSelection=_previousSelection;

#pragma mark - Getters and Setters

- (void)setPreviousSelection:(NSString *)previousSelection {
    if (previousSelection) {
        //Add 0 to the previous selection if it has length < 3
        if (previousSelection.length<2) {
            int length=previousSelection.length;
            for (int i=0;i<2-length;i++)
                previousSelection=[@"0" stringByAppendingString:previousSelection];
        }
        
        _previousSelection=previousSelection;
    }
}

#pragma mark - Picker View State Initialization

- (NSArray *)plungeComponentMatrix {
    //First component
    NSArray *firstComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    //Second component
    NSArray *secondComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    return [NSArray arrayWithObjects:firstComponent,secondComponent, nil];
}

#pragma mark - User Selection Manipulation

- (void)handleUserSelection {
    [super handleUserSelection];
    
    //Format the number
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    NSString *userSelection=[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:self.userSelection]];
    
    //Notify the delegate
    [self.delegate plungePickerViewController:self userDidSelectPlungeValue:userSelection];
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Handle user selection
    [self handleUserSelection];
}

#pragma mark - View Controller Lifecycles

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setup the component matrix
    self.componentMatrix=[self plungeComponentMatrix]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
