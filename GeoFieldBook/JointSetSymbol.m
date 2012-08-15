//
//  JointSetSymbol.m
//  GeoFieldBook
//
//  Created by excel 2011 on 8/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "JointSetSymbol.h"
#import "Record+DipDirectionValues.h"

@implementation JointSetSymbol

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
    return degrees * PI / 180;
}


#pragma mark - drawing of symbols
-(void) drawJointSetSymbolWithcenter:(CGPoint) center andRadius:(float)radius {
    
     //first draw the line with proper strike orientation
    float strike = [self toRadians:self.strike];
    CGPoint point1 = CGPointMake(radius * sin(strike) + center.x, -radius * cos(strike) + center.y);
    CGPoint point2 = CGPointMake(-radius * sin(strike) + center.x, radius * cos(strike) + center.y);
    
    //Draw the strike (longer) line
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 4.0);
    
    [self drawStrikeLineWithContext:context fromPoint:point1 toPoint:point2 withColor:self.color];
    
   
    //now draw the dip line 
    //the dip line (a thick one, to resemble a rectangle) is always perpendicular to the strike line. the proper side to show the line is determined based on the dip direction. the side closer to the direction is the side on which the dip line is drawn. if for some reason, the dip direction corresponds exactly to the strike line, there's a likely error in measurement and hence the dip line is drawn towards dipPoint1 - 90 degrees clockwise from the strike angle given by the user.
    
    //arrays used to convert between direction and angle
    NSArray *dipDirectionConversions = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:45], [NSNumber numberWithInt:90], [NSNumber numberWithInt:135], [NSNumber numberWithInt:180], [NSNumber numberWithInt:225], [NSNumber numberWithInt:270], [NSNumber numberWithInt:315], nil];
    NSArray *possibleDips = [Record allDipDirectionValues];

    //the dip direction of the record being drawn
    NSString *dipdirection = self.dipDirection;
    
    
    float dipAngle = [[dipDirectionConversions objectAtIndex:[possibleDips indexOfObject:dipdirection]] floatValue];
    dipAngle = [self toRadians:dipAngle];
    
    float strikePlus90 = strike + (PI / 2);
    if (strikePlus90 > 2*PI)
        strikePlus90 -= 2*PI;
    
    CGPoint dipPoint1 = CGPointMake((.7) * radius * sin(strikePlus90) + center.x, -(.7) * radius * cos(strikePlus90) + center.y);
    CGPoint dipPoint2 = CGPointMake(-(.7) * radius * sin(strikePlus90) + center.x, (.7) * radius * cos(strikePlus90) + center.y);
    CGPoint givenDipPoint = CGPointMake(radius * sin(dipAngle) + center.x, -radius * cos(dipAngle) + center.y);
    
    CGPoint dipEndPoint = [self closestPointTo:givenDipPoint among:dipPoint1 or:dipPoint2];
    
    //Draw the dip line
    CGContextSetLineWidth(context, 1.0);
    [self drawDipWithContext:context from:center to:dipEndPoint withColor:self.color];
    
    //draw the arrowhead/triangle
    NSLog(@"Strike: %f", self.strike);
    CGPoint arrowA1 = CGPointMake(radius*.35 * sin([self toRadians:(self.strike+70)]) + center.x, -radius*.35 * cos([self toRadians:(self.strike+70)]) +center.y);
    CGPoint arrowA2 = CGPointMake(radius*.35 * sin([self toRadians:(self.strike+110)]) + center.x, -radius*.35 * cos([self toRadians:(self.strike+110)]) +center.y);
    CGPoint arrowB1 = CGPointMake(radius*.35 * sin([self toRadians:(self.strike-70)]) + center.x, -radius*.35 * cos([self toRadians:(self.strike-70)]) +center.y);
    CGPoint arrowB2 = CGPointMake(radius*.35 * sin([self toRadians:(self.strike-110)]) + center.x, -radius*.35 * cos([self toRadians:(self.strike-110)]) +center.y);
    
    CGPoint closer = [self closestPointTo:dipEndPoint among:arrowA1 or:arrowB1];
    
    if(closer.x==arrowA1.x && closer.y==arrowA1.y) {
        NSLog(@"A");
        CGContextMoveToPoint   (context, dipEndPoint.x, dipEndPoint.y);  // top left
        CGContextAddLineToPoint(context, arrowA1.x, arrowA1.y);  // mid right
        CGContextAddLineToPoint(context, arrowA2.x, arrowA2.y);  // bottom left
        
        [self.color setFill];
        CGContextFillPath(context);
    }else {
        NSLog(@"B");
        CGContextMoveToPoint   (context, dipEndPoint.x, dipEndPoint.y);  
        CGContextAddLineToPoint(context, arrowB1.x, arrowB1.y);  // mid right
        CGContextAddLineToPoint(context, arrowB2.x, arrowB2.y);  
       
        [self.color setFill];
        CGContextFillPath(context);
    }
       
    //Write the numerical representation of the dip
    //only if the switch is on in settings and there is a dip
    if (self.dip >=0) {
        CGFloat height = self.bounds.size.height;
        CGFloat width = self.bounds.size.width;
        NSString *dipString = [NSString stringWithFormat:@"%d", (int)self.dip];
        CGFloat dipLocationX = dipEndPoint.x >= center.x ? center.x+width/3 : width/3;
        CGFloat dipLocationY = dipEndPoint.y >= center.y ? center.y+height/8 : -height/8;
        CGPoint dipLocation = CGPointMake(dipLocationX, dipLocationY);
        [self.color set];
        [dipString drawAtPoint:dipLocation withFont:[UIFont fontWithName:@"Helvetica-Bold" size:9.0]];
    }
}


-(void)drawStrikeLineWithContext:(CGContextRef)context fromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 withColor:(UIColor *)color {
    CGContextMoveToPoint(context, point1.x, point1.y);
    CGContextAddLineToPoint(context, point2.x, point2.y);
    [color setStroke];
    CGContextStrokePath(context);
}

- (void) drawDipWithContext:(CGContextRef) context from:(CGPoint) center to:(CGPoint) point withColor:(UIColor *) color
{
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddLineToPoint(context, point.x, point.y);
    [color setStroke];
    CGContextStrokePath(context);
}

- (CGPoint) closestPointTo:(CGPoint) givenDipPoint among:(CGPoint) dipPoint1 or:(CGPoint) dipPoint2
{
    float givenDipToDipPoint1 = sqrtf(powf(dipPoint1.x-givenDipPoint.x, 2.0) + powf(dipPoint1.y-givenDipPoint.y, 2.0));
    float givenDipToDipPoint2 = sqrtf(powf(dipPoint2.x-givenDipPoint.x, 2.0) + powf(dipPoint2.y-givenDipPoint.y, 2.0));
    
    return givenDipToDipPoint1 > givenDipToDipPoint2 ? dipPoint2 : dipPoint1;
}

- (void) drawDotWithCenter:(CGPoint)center andRect:(CGRect)rect
{
    CGFloat width=self.bounds.size.width;
    CGFloat height=self.bounds.size.height;
    CGFloat sideLength = width < height ? width : height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetLineWidth(context, 3.0);
    CGContextBeginPath(context);
    
    CGContextAddArc(context, center.x, center.y, 2*sideLength/7, 2*PI, 0, 1);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextFillPath(context);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
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
    
    if (self.strike && self.dipDirection && self.dip) {
        [self drawJointSetSymbolWithcenter:center andRadius:radius];
    }
    else {
        [self drawDotWithCenter:center andRect:rect];
    }
}


@end
