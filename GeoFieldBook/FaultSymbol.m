//
//  FaultSymbol.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FaultSymbol.h"
#import "Record+DipDirectionValues.h"

@implementation FaultSymbol

@synthesize strike=_strike;
@synthesize dip=_dip;
@synthesize dipDirection=_dipDirection;
@synthesize color=_color;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Setters

- (void)setStrike:(float)strike {
    _strike=strike;
    
    //Redraw
    [self setNeedsDisplay];
}

- (void)setDip:(float)dip {
    _dip=dip;
    
    //Redraw
    [self setNeedsDisplay];
}

- (void)setDipDirection:(NSString *)dipDirection {
    _dipDirection=dipDirection;
    
    //Redraw
    [self setNeedsDisplay];
}

- (UIColor *)color {
    if (!_color)
        self.color=[UIColor blackColor];
    
    return _color;
}

#pragma mark - Getters

- (NSString *)dipDirection {
    if (!_dipDirection.length)
        return @"N";
    
    return _dipDirection;
}

- (float) toRadians:(float) degrees
{
    return degrees * M_PI / 180;
}

- (void) drawStrikeWithContext:(CGContextRef) context point:(CGPoint) point1 andPoint:(CGPoint) point2 withColor:(UIColor *) color
{
    UIGraphicsPushContext(context);
    CGContextMoveToPoint(context, point1.x, point1.y);
    CGContextAddLineToPoint(context, point2.x, point2.y);
    [color setStroke];
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}

- (void) drawDipWithContext:(CGContextRef) context from:(CGPoint) center to:(CGPoint) point withColor:(UIColor *) color
{
    UIGraphicsPushContext(context);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddLineToPoint(context, point.x, point.y);
    [color setStroke];
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

- (void)drawArrowHeadForRadius:(CGFloat)radius andCenter:(CGPoint)center andDipEndPoint:(CGPoint)dipEndPoint inContext:(CGContextRef)context {
    CGPoint arrowA1 = CGPointMake(radius*.35 * sin([self toRadians:(self.strike+70)]) + center.x, -radius*.35 * cos([self toRadians:(self.strike+70)]) +center.y);
    CGPoint arrowA2 = CGPointMake(radius*.35 * sin([self toRadians:(self.strike+110)]) + center.x, -radius*.35 * cos([self toRadians:(self.strike+110)]) +center.y);
    CGPoint arrowB1 = CGPointMake(radius*.35 * sin([self toRadians:(self.strike-70)]) + center.x, -radius*.35 * cos([self toRadians:(self.strike-70)]) +center.y);
    CGPoint arrowB2 = CGPointMake(radius*.35 * sin([self toRadians:(self.strike-110)]) + center.x, -radius*.35 * cos([self toRadians:(self.strike-110)]) +center.y);
    
    CGPoint closer = [self closestPointTo:dipEndPoint among:arrowA1 or:arrowB1];
    
    if(closer.x==arrowA1.x && closer.y==arrowA1.y) {
        CGContextMoveToPoint   (context, dipEndPoint.x, dipEndPoint.y);  // top left
        CGContextAddLineToPoint(context, arrowA1.x, arrowA1.y);  // mid right
        CGContextAddLineToPoint(context, arrowA2.x, arrowA2.y);  // bottom left
        
        [self.color setFill];
        CGContextFillPath(context);
    }else {
        CGContextMoveToPoint   (context, dipEndPoint.x, dipEndPoint.y);  
        CGContextAddLineToPoint(context, arrowB1.x, arrowB1.y);  // mid right
        CGContextAddLineToPoint(context, arrowB2.x, arrowB2.y);  
        
        [self.color setFill];
        CGContextFillPath(context);
    }
}

- (CGPoint) closestPointTo:(CGPoint) givenDipPoint among:(CGPoint) dipPoint1 or:(CGPoint) dipPoint2
{
    float givenDipToDipPoint1 = sqrtf(powf(dipPoint1.x-givenDipPoint.x, 2.0) + powf(dipPoint1.y-givenDipPoint.y, 2.0));
    float givenDipToDipPoint2 = sqrtf(powf(dipPoint2.x-givenDipPoint.x, 2.0) + powf(dipPoint2.y-givenDipPoint.y, 2.0));
    
    return givenDipToDipPoint1 > givenDipToDipPoint2 ? dipPoint2 : dipPoint1;
}

- (void)drawFaultSymbolWithCenter:(CGPoint)center andRadius:(float)radius
{
    //STRIKE
    //information about the view being drawn in   
    float strike=[self toRadians:self.strike];
    CGPoint point1 = CGPointMake(radius * sin(strike) + center.x, -radius * cos(strike) + center.y);
    CGPoint point2 = CGPointMake(-radius * sin(strike) + center.x, radius * cos(strike) + center.y);
    
    //Begin drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    //Draw the strike line
    CGContextSetLineWidth(context,2.0);
    [self drawStrikeWithContext:context point:point1 andPoint:point2 withColor:self.color];
    
    //DIP
    //the dip line is always perpendicular to the strike line
    //we determine which side of the strike line the dip line will appear based on the dip direction...
    //whichever side is closer to this direction is the side on which the dip line is drawn
    //if the dip direction corresponds exactly with the strike line (which it should not, this is likely an error in measurement), the dip line is drawn towards dipPoint1 (see below) (90 degrees clockwise from the strike angle given by the user)
    
    //arrays used to convert between direction and angle
    NSArray *dipDirectionConversions = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:45], [NSNumber numberWithInt:90], [NSNumber numberWithInt:135], [NSNumber numberWithInt:180], [NSNumber numberWithInt:225], [NSNumber numberWithInt:270], [NSNumber numberWithInt:315], nil];
    NSArray *possibleDips = [Record allDipDirectionValues];
    
    //the dip direction of the record being drawn
    NSString *dipdirection = self.dipDirection;
    
    float dipAngle = [[dipDirectionConversions objectAtIndex:[possibleDips indexOfObject:dipdirection]] floatValue];
    dipAngle = [self toRadians:dipAngle];
    
    float strikePlus90 = strike + (M_PI / 2);
    if (strikePlus90 > 2*M_PI)
        strikePlus90 -= 2*M_PI;
    
    CGPoint dipPoint1 = CGPointMake((.55) * radius * sin(strikePlus90) + center.x, -(.55) * radius * cos(strikePlus90) + center.y);
    CGPoint dipPoint2 = CGPointMake(-(.55) * radius * sin(strikePlus90) + center.x, (.55) * radius * cos(strikePlus90) + center.y);
    CGPoint givenDipPoint = CGPointMake(radius * sin(dipAngle) + center.x, -radius * cos(dipAngle) + center.y);
    
    CGPoint dipEndPoint = [self closestPointTo:givenDipPoint among:dipPoint1 or:dipPoint2];
    
    //Draw the dip line
    CGContextSetLineWidth(context, 1.0);
    [self drawDipWithContext:context from:center to:dipEndPoint withColor:self.color];
    
    //draw the arrowhead/triangle
    [self drawArrowHeadForRadius:radius andCenter:center andDipEndPoint:dipEndPoint inContext:context];
    
    //Write the numerical representation of the dip
    if (self.dip >=0){
        CGFloat height = self.bounds.size.height;
        CGFloat width = self.bounds.size.width;
        NSString *dipString = [NSString stringWithFormat:@"%d", (int)self.dip];
        CGFloat dipLocationX = dipEndPoint.x >= center.x ? center.x+width/6 : 0;
        CGFloat dipLocationY = dipEndPoint.y >= center.y ? center.y+height/5 : -height/9;
        CGPoint dipLocation = CGPointMake(dipLocationX, dipLocationY);
        [self.color set];
        [dipString drawAtPoint:dipLocation withFont:[UIFont fontWithName:@"Helvetica-Bold" size:9.0]];
    }
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
    float radius = sqrtf(width*width+height*height)/2;
    
    [self drawFaultSymbolWithCenter:center andRadius:radius];
}

@end
