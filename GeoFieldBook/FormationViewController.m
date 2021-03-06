//
//  FormationViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationViewController.h"

#import "ColorPickerViewController.h"
#import "ColorPickerViewControllerDelegate.h"
#import "NPColorPickerView.h"

#import "SettingManager.h"
#import "ColorManager.h"

@interface FormationViewController() <UITextFieldDelegate,ColorPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *colorPatch;

@property (nonatomic,strong) NSString *formationName;
@property (nonatomic,strong) NSString *formationColor;

@property (nonatomic,readonly) ColorManager *colorManager;

@end

@implementation FormationViewController

@synthesize nameTextField = _nameTextField;
@synthesize colorPatch = _colorPatch;

@synthesize delegate=_delegate;

@synthesize formation=_formation;

@synthesize formationName=_formationName;
@synthesize formationColor=_formationColor;

- (void)dismissKeyboard:(UITapGestureRecognizer *)tapGesture {
    //dismiss the keyboard
    [self.nameTextField resignFirstResponder];
}

#pragma mark - Getters and Setters

- (ColorManager *)colorManager {
    return [ColorManager standardColorManager];
}

- (NSString *)formationColor {
    if (!_formationColor)
        _formationColor=[SettingManager standardSettingManager].defaultFormationColor;
        
    return _formationColor;
}

- (void)setFormationColor:(NSString *)formationColor {
    if (![_formationColor isEqualToString:formationColor]) {
        _formationColor=formationColor;
        
        //Update the color patch
        self.colorPatch.backgroundColor=[[ColorManager standardColorManager] colorWithName:formationColor];
    }
}

- (void)setFormation:(Formation *)formation {
    _formation=formation;
    
    //Update the name
    self.formationName=self.formation.formationName;
    
    //Update the color
    self.formationColor=formation.color;
}

#pragma mark - Data Collectors

- (NSDictionary *)formationInfoFromForm {
    //Create a dictionary with all the information user provided        
    NSDictionary *formationInfo=[NSDictionary dictionaryWithObjectsAndKeys:self.formationName,GeoFormationName,self.formationColor,GeoFormationColor, nil];
    return formationInfo;
}

#pragma mark - Target-Action Handlers

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    //If the formation name text field is blank, focus on it instead of returning
    if (![self.nameTextField.text length])
        [self.nameTextField becomeFirstResponder];
    
    //Else pass the new formation info dictionary back to the delegate
    else {
        //Save the formation name
        self.formationName=self.nameTextField.text;
        
        //Process new info
        NSDictionary *formationInfo=[self formationInfoFromForm];
        //If the formation has not been set before, send the delegate the new info
        if (!self.formation)
            [self.delegate formationViewController:self 
                         didObtainNewFormationInfo:formationInfo];
        
        //Else send both the formation and the info
        else 
            [self.delegate formationViewController:self 
                           didAskToModifyFormation:self.formation 
                                andObtainedNewInfo:formationInfo];
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //If the text field is the name text field
    if (textField==self.nameTextField) {
        //Click "Done" for user
        [self donePressed:nil];
    }
    
    return YES;
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Color picker
    if ([segue.identifier isEqualToString:@"Color Picker"]) {
        
        //Dismiss the keyboard
        [self dismissKeyboard:nil];
        
        //Set the color picker vc's delegate to self
        ColorPickerViewController *colorPickerVC=(ColorPickerViewController *)segue.destinationViewController;
        colorPickerVC.delegate=self;
    }
}

#pragma mark - View Controller Lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Add double tap gesture recognizer for dismissing the keyboard
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //Set the delegate of the name text field to be self
    self.nameTextField.delegate=self;
    self.nameTextField.returnKeyType=UIReturnKeyDone;
    self.nameTextField.enablesReturnKeyAutomatically=YES;
    
    //Set the name text field to be the first responder
    [self.nameTextField becomeFirstResponder];
    
    //If the formation name is not nil, set the text of the name text field
    if (self.formationName)
        self.nameTextField.text=self.formationName;
    
    //Setup the color patch button
    self.colorPatch.layer.borderColor=[UIColor blackColor].CGColor;
    self.colorPatch.layer.cornerRadius=8.0f;
    self.colorPatch.layer.borderWidth=1.0f;
    
    //Give the color patch the formation color
    self.colorPatch.backgroundColor=[self.colorManager colorWithName:self.formationColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setNameTextField:nil];
    [self setColorPatch:nil];
    [super viewDidUnload];
}

#pragma mark - ColorPickerViewControllerDelegate Protocol methods

- (void)colorPicker:(ColorPickerViewController *)colorPicker userDidSelectColor:(NSString *)color {
    //Save the selected color
    self.formationColor=color;
}

@end
