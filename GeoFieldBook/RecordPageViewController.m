//
//  RecordPageViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordPageViewController.h"

@interface RecordPageViewController()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *fieldbookBackground;

@end

@implementation RecordPageViewController
@synthesize contentView = _contentView;
@synthesize fieldbookBackground = _fieldbookBackground;

@synthesize flipViewController=_flipViewController;
@synthesize delegate=_delegate;

@synthesize record=_record;

#pragma mark - Helpers

- (void)reloadPagePosition {
    [self setFieldBookBackgroundForRecord:self.record];
}

- (NSString *)fieldbookImageNameForPercentage:(double)percentage {
    if (!percentage)
        return @"fieldbook_first_page";
    else if (percentage<=0.5 && percentage>0)
        return @"fieldbook_first_few";
    else if (percentage>0.5 && percentage<1)
        return @"fieldbook_last_few";
    else if (percentage==1)
        return @"fieldbook_last_page";
    
    return @"fieldbook_cover";
}

- (void)setFieldBookBackgroundForRecord:(Record *)record {
    //Setup the new fieldbook background
    NSString *imageName=[self fieldbookImageNameForPercentage:[self.delegate recordPage:self recordPercentage:record]];
    self.fieldbookBackground.image=[UIImage imageNamed:imageName];
}

- (void)updateRecord:(Record *)record {
    if (record!=self.record || (self.record && !self.currentRecordViewController)) {    
        //Current percentage
        double currentPercentage=[self.delegate recordPage:self recordPercentage:self.record];
        
        //Update record
        self.record=record;
        
        //Current percentage
        double percentage=[self.delegate recordPage:self recordPercentage:self.record];
        
        //Set new background
        [self setFieldBookBackgroundForRecord:self.record];
        
        //Flip Direction (Forward if new record or record is after current one)
         MPFlipViewControllerDirection direction=(currentPercentage<percentage || record.recordState==RecordStateNew) ? MPFlipViewControllerDirectionForward : MPFlipViewControllerDirectionReverse;
        
        //Create the new record vc
        RecordViewController *recordVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Record Detail View Controller"];
        recordVC.record=self.record;
        
        //Notify delegate
        [self.delegate recordPage:self isTurningToRecordViewController:recordVC];
        
        //Flip
        [self.flipViewController setViewController:recordVC direction:direction animated:YES completion:^(BOOL success){}];
    }
}

#pragma mark - Getters and Setters

- (RecordViewController *)currentRecordViewController {
    RecordViewController *recordVC=nil;
    
    if ([self.flipViewController.viewController isKindOfClass:[RecordViewController class]])
        recordVC=(RecordViewController *)self.flipViewController.viewController;
        
    return recordVC;
}

#pragma mark - View Controller Lifecycle

- (void)initializeFlipViewController {
    if (!self.flipViewController) {
        // Configure the page view controller and add it as a child view controller.
        self.flipViewController = [[MPFlipViewController alloc] initWithOrientation:[self flipViewController:nil orientationForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation]];
        self.flipViewController.delegate = self;
        self.flipViewController.dataSource = self;
        
        // Set the page view controller's bounds
        self.flipViewController.view.frame = self.contentView.bounds;
        [self addChildViewController:self.flipViewController];
        [self.contentView addSubview:self.flipViewController.view];
        [self.flipViewController didMoveToParentViewController:self];
        
        //Create the initial record vc
        InitialDetailViewController *fieldbookCover=[self.storyboard instantiateViewControllerWithIdentifier:@"Initial Detail View Controller"];
        
        //First animation
        __weak RecordPageViewController *weakSelf=self;
        [self.flipViewController setViewController:fieldbookCover direction:MPFlipViewControllerDirectionReverse animated:NO completion:^(BOOL success){
            if (self.record)
                [weakSelf updateRecord:self.record];
        }];
        
        // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
        self.view.gestureRecognizers = self.flipViewController.gestureRecognizers;
    }
}

- (void)closeWithCompletionHandler:(animation_completion_t)completionHandler {    
    //Create the initial record vc
    InitialDetailViewController *fieldbookCover=[self.storyboard instantiateViewControllerWithIdentifier:@"Initial Detail View Controller"];
    
    //Close animation
    [self.flipViewController setViewController:fieldbookCover direction:MPFlipViewControllerDirectionReverse animated:YES completion:^(BOOL success){
        completionHandler();
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    	
    //Initialize flip vc
	[self initializeFlipViewController];
}

#pragma mark - MPFlipViewControllerDelegate protocol

- (void)flipViewController:(MPFlipViewController *)flipViewController didFinishAnimating:(BOOL)finished previousViewController:(UIViewController *)previousViewController transitionCompleted:(BOOL)completed
{
	//Update the current record
    RecordViewController *recordVC=(RecordViewController *)flipViewController.viewController;
    self.record=recordVC.record;
    
    //Setup the new fieldbook background
    [self setFieldBookBackgroundForRecord:self.record];
    
    //Notify delegate
    [self.delegate recordPage:self isTurningToRecordViewController:recordVC];
}

- (MPFlipViewControllerOrientation)flipViewController:(MPFlipViewController *)flipViewController orientationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return MPFlipViewControllerOrientationHorizontal;
}

#pragma mark - MPFlipViewControllerDataSource protocol

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	//Get the previous record
    Record *record=[self.delegate recordPage:self recordBeforeRecord:self.record];
    RecordViewController *recordVC=nil;
    
    //Setup the new fieldbook background
    [self setFieldBookBackgroundForRecord:record];
    
    //Setup the new record vc
    if (record) {
        //Create a new record vc
        recordVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Record Detail View Controller"];
        recordVC.record=record;
    }
    
    return recordVC;
}

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	//Get the next record
    Record *record=[self.delegate recordPage:self recordAfterRecord:self.record];
    RecordViewController *recordVC=nil;
    
    //Setup the new fieldbook background
    [self setFieldBookBackgroundForRecord:record];
    
    //Create a new record vc
    if (record) {
        //Create a new record vc
        recordVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Record Detail View Controller"];
        recordVC.record=record;
    }
    
    return recordVC;
}

- (void)viewDidUnload {
    [self setFieldbookBackground:nil];
    [super viewDidUnload];
}
@end
