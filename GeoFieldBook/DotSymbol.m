//
//  DotSymbol.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "DotSymbol.h"

@implementation DotSymbol

@synthesize strike=_strike;
@synthesize dip=_dip;
@synthesize dipDirection=_dipDirection;
@synthesize color=_color;

- (void) drawDotWithCenter:(CGPoint)center andRect:(CGRect)rect
{
    CGFloat width=self.bounds.size.width;
    CGFloat height=self.bounds.size.height;
    CGFloat sideLength = width < height ? width : height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetLineWidth(context, 3.0);
    CGContextBeginPath(context);
    
    CGContextAddArc(context, center.x, center.y, 2*sideLength/7, 2*M_PI, 0, 1);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextFillPath(context);
}

- (void)drawRect:(CGRect)rect 
{
    //CONVERT TO RADIANS
    [super drawRect:rect];
    
    //information about the view being drawn in   
    CGPoint center;
    CGFloat width=self.bounds.size.width;
    CGFloat height=self.bounds.size.height;
    center.x=self.bounds.origin.x+width/2;
    center.y=self.bounds.origin.y+height/2;
    
    [self drawDotWithCenter:center andRect:rect];
}

@end
