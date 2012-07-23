//
//  MKCustomAnnotationView.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MKCustomAnnotationView.h"

#import "SettingManager.h"

@implementation MKCustomAnnotationView

- (void)reloadAnnotationView {
    [self drawAnnotationViewForAnnotation:self.annotation];
}

- (void)drawDipStrikeSymbolWithAnnotation:(MKGeoRecordAnnotation *)annotation {
    if (annotation.record) {
        //Setup the dip strike symbol
        DipStrikeSymbol *symbol=[[DipStrikeSymbol alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        Record *record=annotation.record;
        symbol.strike=record.strike.floatValue;
        symbol.dip=record.dip.floatValue;
        symbol.dipDirection=record.dipDirection;
        symbol.backgroundColor=[UIColor clearColor];
        
        //Setup the color of the dip strike symbol if specified by user preference
        UIColor *color=nil;
        SettingManager *settingManager=[SettingManager standardSettingManager];
        if (settingManager.formationColorEnabled) {
            if ([record isKindOfClass:[Bedding class]]) {
                Formation *formation=[(Bedding *)record formation];
                color=[UIColor colorWithRed:formation.redColorComponent.floatValue 
                                      green:formation.greenColorComponent.floatValue 
                                       blue:formation.blueColorComponent.floatValue 
                                      alpha:1.0];
            }
            else if ([record isKindOfClass:[Contact class]]) {
                Formation *upperFormation=[(Contact *)record upperFormation];
                color=[UIColor colorWithRed:upperFormation.redColorComponent.floatValue 
                                      green:upperFormation.greenColorComponent.floatValue 
                                       blue:upperFormation.blueColorComponent.floatValue 
                                      alpha:1.0];
            }
        }
        
        //Else just set the color to the default symbol color
        else {
            color=settingManager.defaultSymbolColor;
        }
        
        symbol.color=color;
        
        //Add the strike symbol view
        UIGraphicsBeginImageContext(symbol.bounds.size);
        [symbol.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();    
        self.image=image;
    }
}

- (void)drawAnnotationViewForAnnotation:(MKGeoRecordAnnotation *)annotation {
    //If the annotation's record does not have a strike and dip value or its strike and dip value are 0, set the image only
    Record *record=annotation.record;
    if (!record.strike || !record.dip || !record.strike.intValue || !record.dip.intValue)
        self.image=[UIImage imageNamed:@"green_pin.png"];
    
    //Else draw the dip strike symbol
    else
        [self drawDipStrikeSymbolWithAnnotation:annotation];
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithAnnotation:self.annotation reuseIdentifier:reuseIdentifier])
        [self drawAnnotationViewForAnnotation:annotation];
    
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    
    [self drawAnnotationViewForAnnotation:annotation];
}

@end
