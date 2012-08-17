//
//  MapSymbol.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MapSymbol <NSObject>

@property (nonatomic) float strike;
@property (nonatomic) float dip;
@property (nonatomic, strong) NSString *dipDirection;
@property (nonatomic, strong) UIColor *color;

@end
