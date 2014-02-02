//
//  DrawRectView.h
//  ObjectMarkingMacOS
//
//  Created by Jai Dhorajia on 18/01/14.
//  Copyright (c) 2014 Softweb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol drawRectDelegate
- (void)rectDrawn:(CGRect)rect;
@end

@interface DrawRectView : UIView
{
    UIBezierPath *path;
    UIImage *incrementalImage;
    CGPoint startPt;
    CGPoint currPt;
    CGRect finalRect;
}

@property (nonatomic,retain) UIBezierPath *path;
@property (nonatomic,retain) UIImage *incrementalImage;
@property (nonatomic) CGPoint startPt;
@property (nonatomic) CGPoint currPt;
@property (assign) id <drawRectDelegate> delegate;

@end
