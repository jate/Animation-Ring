//
//  CCircleHUDView.m
//  testCircle
//
//  Created by JateXu on 8/12/14.
//  Copyright (c) 2014 SIXIN. All rights reserved.
//

#import "CCircleHUDView.h"

@interface CCircleHUDView ()

/**The start progress for the progress animation.*/
@property (nonatomic, assign) CGFloat animationFromValue;
/**The end progress for the progress animation.*/
@property (nonatomic, assign) CGFloat animationToValue;
/**The start time interval for the animaiton.*/
@property (nonatomic, assign) CFTimeInterval animationStartTime;
/**Link to the display to keep animations in sync.*/
@property (nonatomic, strong) CADisplayLink *displayLink;

/**The layer that progress is shown on.*/
@property (nonatomic, strong) CAShapeLayer *progressLayer;

/**The layer that the background shown on.*/
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;

/**The layer that the background shown on.*/
@property (nonatomic, strong) CAShapeLayer *bigCircleLayer;


@end

@implementation CCircleHUDView
@synthesize progress = _progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setup
{
    //Set own background color
    self.backgroundColor = [UIColor clearColor];
    
    //Set default colors
    self.primaryColor = [UIColor whiteColor];
    self.secondaryColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.36];
    
    _bigCircleLayer = [CAShapeLayer layer];
    _bigCircleLayer.strokeColor = self.secondaryColor.CGColor;
    _bigCircleLayer.fillColor = [UIColor clearColor].CGColor;
    _bigCircleLayer.lineWidth = 1.0f;
    [self.layer addSublayer:_bigCircleLayer];
    
    //Set up the background layer
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.strokeColor = self.secondaryColor.CGColor;
    _backgroundLayer.lineWidth = 2.0f;
    [self.layer addSublayer:_backgroundLayer];
    
    //Set up the progress layer
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.strokeColor = self.primaryColor.CGColor;
    _backgroundLayer.lineWidth = 2.0f;
    [self.layer addSublayer:_progressLayer];
}

#pragma mark Actions

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (self.progress == progress) {
        return;
    }
    if (animated == NO) {
        if (_displayLink) {
            //Kill running animations
            [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            _displayLink = nil;
        }
        _progress = progress;
        [self setNeedsDisplay];
    } else {
        _animationStartTime = CACurrentMediaTime();
        _animationFromValue = self.progress;
        _animationToValue = progress;
        if (!_displayLink) {
            //Create and setup the display link
            [self.displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateProgress:)];
            [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        } /*else {
           //Reuse the current display link
           }*/
    }
}

- (void)animateProgress:(CADisplayLink *)displayLink
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat dt = (displayLink.timestamp - _animationStartTime) / .9;
        if (dt >= 1.0) {
            //Order is important! Otherwise concurrency will cause errors, because setProgress: will detect an animation in progress and try to stop it by itself. Once over one, set to actual progress amount. Animation is over.
            [self.displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
            self.displayLink = nil;
            _progress = _animationToValue;
            [self setNeedsDisplay];
            return;
        }
        
        //Set progress
        _progress = _animationFromValue + dt * (_animationToValue - _animationFromValue);
        [self setNeedsDisplay];
    });
}

#pragma mark Layout

- (void)layoutSubviews
{
    //Update frames of layers
    _backgroundLayer.frame = self.bounds;
    _bigCircleLayer.frame = self.bounds;
    _progressLayer.frame = self.bounds;
    
//    [self updateAngles];
    
    //Redraw
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [super drawRect:rect];
    
    [self drawBigCircle];
    
    //Draw the background
    [self drawProgressBackground];
    
    //Draw Progress
    [self drawProgress];
}

- (void)drawBigCircle
{
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    CGFloat r1 = center.x - 10;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:r1 startAngle:- M_PI_2 + 0.2 endAngle:- M_PI_2 - 0.2 clockwise:YES];
    
    path.lineWidth = 1;
    
    _bigCircleLayer.path = path.CGPath;
}

- (void)drawProgressBackground
{
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    CGFloat r2 = center.x - 20;
    CGFloat r1 = r2 - 15;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
//    for (CGFloat angle = - M_PI; angle <= - M_PI_4; angle += 0.05)
    for (CGFloat angle = 0; angle <= 2 * M_PI; angle += 0.05)
    {
        CGFloat sin = sinf(angle);
        CGFloat cos = cosf(angle) * -1;
        
        CGPoint innerCirclePoint = CGPointMake(sin * r1, cos * r1);
        CGPoint outerCirclePoint = CGPointMake(sin * r2, cos * r2);
        
        innerCirclePoint = CGPointMake(innerCirclePoint.x + center.x, innerCirclePoint.y + center.y);
        outerCirclePoint = CGPointMake(outerCirclePoint.x + center.x, outerCirclePoint.y + center.y);
        
        UIBezierPath *aPath = [UIBezierPath bezierPath];
        [aPath moveToPoint:innerCirclePoint];
        
        // Draw the lines.
        [aPath addLineToPoint:outerCirclePoint];
        [aPath closePath];
        
        CGPathAddPath(pathRef, NULL, aPath.CGPath);
    }
    
    //Set the path
    _backgroundLayer.path = pathRef;
    
    CGPathRelease(pathRef);
}

- (void)drawProgress
{
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    CGFloat r2 = center.x - 20;
    CGFloat r1 = r2 - 15;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    
    CGFloat maxAngle = 2 * M_PI * self.progress;
    for (CGFloat angle = 0; angle <= maxAngle; angle += 0.05)
    {
        CGFloat sin = sinf(angle);
        CGFloat cos = cosf(angle) * -1;
        
        CGPoint innerCirclePoint = CGPointMake(sin * r1, cos * r1);
        CGPoint outerCirclePoint = CGPointMake(sin * r2, cos * r2);
        
        innerCirclePoint = CGPointMake(innerCirclePoint.x + center.x, innerCirclePoint.y + center.y);
        outerCirclePoint = CGPointMake(outerCirclePoint.x + center.x, outerCirclePoint.y + center.y);
        
        UIBezierPath *aPath = [UIBezierPath bezierPath];
        [aPath moveToPoint:innerCirclePoint];
        
        // Draw the lines.
        [aPath addLineToPoint:outerCirclePoint];
        [aPath closePath];
        
        CGPathAddPath(pathRef, NULL, aPath.CGPath);
    }
    
    //Set the path
    _progressLayer.path = pathRef;
    
    CGPathRelease(pathRef);
}




@end
