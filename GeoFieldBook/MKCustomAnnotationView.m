//
//  MKCustomAnnotationView.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MKCustomAnnotationView.h"

#import "SettingManager.h"
#import "ColorManager.h"

#import "Formation.h"

#import "Bedding.h"
#import "Contact.h"
#import "JointSet.h"
#import "Fault.h"
#import "Other.h"

#import "Contact+Formation.h"

@implementation MKCustomAnnotationView

- (id)initWithAnnotation:(MKGeoRecordAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithAnnotation:self.annotation reuseIdentifier:reuseIdentifier]) {
        //Draw the symbol
        [self drawSymbolForAnnotation:self.annotation];
    }
    
    return self;
}

- (void)setAnnotation:(MKGeoRecordAnnotation *)annotation {
    [super setAnnotation:annotation];
    
    //Draw the symbol
    [self drawSymbolForAnnotation:self.annotation];
}

#pragma mark - Helpers

- (void)reloadAnnotationView {
    //Draw the symbol
    [self drawSymbolForAnnotation:self.annotation];
}

- (void)setupSymbol:(UIView<MapSymbol> *)symbol forAnnotation:(MKGeoRecordAnnotation *)annotation {
    //Get the record
    Record *record=annotation.record;
    SettingManager *settingManager=[SettingManager standardSettingManager];
    
    //Set dip, strike, dip direciton values
    symbol.strike=record.strike ? record.strike.floatValue : 0.0;
    symbol.dipDirection=record.dipDirection ? record.dipDirection : nil;
    
    //determine whether or not to show the dip number with the dip strike symbol
    //DONT SHOW IF NO DIP VALUE (different from dip of 0)
    if (settingManager.dipNumberEnabled && record.dip)
        symbol.dip=record.dip.floatValue;
    else
        symbol.dip=-1.0;
    
    //Setup the color of the dip strike symbol if specified by user preference
    UIColor *color=settingManager.defaultSymbolColor;
    if (settingManager.formationColorEnabled && [(id)record formation]) {
        if (![record isKindOfClass:[Other class]]) {
            Formation *formation=[(id)record formation];
            color=[[ColorManager standardColorManager] colorWithName:formation.color];
        }
    }
    
    symbol.color=color;
    
    //Add the strike symbol view
    symbol.backgroundColor=[UIColor clearColor];
    UIGraphicsBeginImageContext(symbol.bounds.size);
    [symbol.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    self.image=image;
}

#pragma mark - Drawing Mechanisms

- (void)drawSymbolForAnnotation:(MKGeoRecordAnnotation *)annotation {
    Record *record=[(MKGeoRecordAnnotation *)annotation record];
    if (record.strike && record.dip && record.dipDirection.length) {
        if ([record isKindOfClass:[Bedding class]] || [record isKindOfClass:[Contact class]])
            [self drawDipStrikeSymbolForAnnotation:annotation];
        else if ([record isKindOfClass:[Fault class]])
            [self drawFaultSymbolForAnnotation:annotation];
        else if ([record isKindOfClass:[JointSet class]])
            [self drawJointSetSymbolForAnnotation:annotation];
    }
    else if ([record isKindOfClass:[Other class]])
        [self drawOtherSymbolForAnnotation:annotation];
    else
        [self drawDotSymbolForAnnotation:annotation];
}

- (void)drawDipStrikeSymbolForAnnotation:(MKGeoRecordAnnotation *)annotation {
    if (annotation.record) {
        //Create the dip strike symbol
        DipStrikeSymbol *symbol=[[DipStrikeSymbol alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];        
        
        //Setup the symbol
        [self setupSymbol:symbol forAnnotation:annotation];
    }
}

- (void)drawJointSetSymbolForAnnotation:(MKGeoRecordAnnotation *)annotation {
    if (annotation.record) {
        //Create the joint set symbol
        JointSetSymbol *symbol=[[JointSetSymbol alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        //Setup the symbol
        [self setupSymbol:symbol forAnnotation:annotation];
    }
}

- (void)drawFaultSymbolForAnnotation:(MKGeoRecordAnnotation *)annotation {
    if (annotation.record) {
        //Cterea the fault symbol
        FaultSymbol *symbol=[[FaultSymbol alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        //Setup the symbol
        [self setupSymbol:symbol forAnnotation:annotation];
    }
}

- (void)drawOtherSymbolForAnnotation:(MKGeoRecordAnnotation *)annotation {
    if (annotation.record) {
        //Setup the other symbol
        SettingManager *settingManager=[SettingManager standardSettingManager];
        OtherSymbol *symbol=[[OtherSymbol alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        //Setup the color of the symbol to default
        symbol.color=settingManager.defaultSymbolColor;
        
        //Add the strike symbol view
        symbol.backgroundColor=[UIColor clearColor];
        UIGraphicsBeginImageContext(symbol.bounds.size);
        [symbol.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();    
        self.image=image;
    }
}

- (void)drawDotSymbolForAnnotation:(MKGeoRecordAnnotation *)annotation {
    if (annotation.record) {
        //Create the dot symbol
        DotSymbol *symbol=[[DotSymbol alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        //Setup the symbol
        [self setupSymbol:symbol forAnnotation:annotation];
    }
}

@end
