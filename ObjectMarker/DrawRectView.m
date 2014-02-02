//
//  DrawRectView.m
//  ObjectMarkingMacOS
//
//  Created by Jai Dhorajia on 18/01/14.
//  Copyright (c) 2014 Softweb. All rights reserved.
//

#import "DrawRectView.h"

// Variable factors ** change according to need and liking
#define LINE_WIDTH 2.0
#define LINE_COLOR [UIColor redColor]
#define BACKGROUND_COLOR [UIColor clearColor]
#define MIN_RECT_WIDTH 20
#define MAX_RECT_HEIGHT 20

@implementation DrawRectView
@synthesize path;
@synthesize startPt;
@synthesize currPt;
@synthesize incrementalImage;
@synthesize delegate = _delegate;

- (id)initWithCoder:(NSCoder *)aDecoder 
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO]; 
        [self setBackgroundColor:BACKGROUND_COLOR];
        self.path = [UIBezierPath bezierPath];
        [self.path setLineWidth:LINE_WIDTH];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:BACKGROUND_COLOR];
        self.path = [UIBezierPath bezierPath];
        [self.path setLineWidth:LINE_WIDTH];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //Square or Rectangle
    [self.path moveToPoint:startPt];
    [self.path addLineToPoint:CGPointMake(currPt.x, startPt.y)];
    [self.path addLineToPoint:currPt];
    [self.path addLineToPoint:CGPointMake(startPt.x, currPt.y)];
    [self.path closePath];
    
    if (startPt.x<currPt.x && startPt.y<currPt.y)
        finalRect = CGRectMake(startPt.x, startPt.y, currPt.x-startPt.x, currPt.y-startPt.y);
    else if (startPt.x>currPt.x && startPt.y<currPt.y)
        finalRect = CGRectMake(currPt.x, startPt.y, startPt.x-currPt.x, currPt.y-startPt.y);
    else if (startPt.x>currPt.x && startPt.y>currPt.y)
        finalRect = CGRectMake(currPt.x, currPt.y, startPt.x-currPt.x, startPt.y-currPt.y);
    else if (startPt.x<currPt.x && startPt.y>currPt.y)
        finalRect = CGRectMake(startPt.x, currPt.y, currPt.x-startPt.x, startPt.y-currPt.y);
    else if (startPt.x<currPt.x && startPt.y==currPt.y)
        finalRect = CGRectMake(startPt.x, startPt.y, currPt.x-startPt.x, 0);
    else if (startPt.x>currPt.x && startPt.y==currPt.y)
        finalRect = CGRectMake(currPt.x, currPt.y, startPt.x-currPt.x, 0);
    else if (startPt.x==currPt.x && startPt.y>currPt.y)
        finalRect = CGRectMake(currPt.x, currPt.y, 0, startPt.y-currPt.y);
    else if (startPt.x==currPt.x && startPt.y<currPt.y)
        finalRect = CGRectMake(startPt.x, startPt.y, 0, currPt.y-startPt.y);
    else
        finalRect = CGRectMake(startPt.x, startPt.y, 0, 0);
    
    [LINE_COLOR setStroke];
    [self.path stroke];
    [self.path removeAllPoints];
}
///////////////////////////////////////////////////////////////////////////////
///////          Touches Methods
///////////////////////////////////////////////////////////////////////////////
# pragma mark Touches Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    startPt = [touch locationInView:self];
    currPt = [touch locationInView:self];
    [self setNeedsDisplay];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    currPt = [touch locationInView:self];
    
    if (currPt.x >= self.bounds.size.width)         currPt.x = self.bounds.size.width-1;
    if (currPt.x <= 0)                              currPt.x = 0;
    if (currPt.y >= self.bounds.size.height)        currPt.y = self.bounds.size.height-1;
    if (currPt.y <= 0)                              currPt.y = 0;
    
    [self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (finalRect.size.width>MIN_RECT_WIDTH && finalRect.size.height>MAX_RECT_HEIGHT) {
        [self.delegate rectDrawn:finalRect];
    }
    [self setNeedsDisplay];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

@end
