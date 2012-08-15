//
//  JointSetSymbol.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JointSetSymbol : UIView

@property (nonatomic) float strike;
@property (nonatomic) float dip;
@property (nonatomic, strong) NSString *dipDirection;
@property (nonatomic, strong) UIColor *color;

@end
