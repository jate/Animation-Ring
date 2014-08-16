//
//  CViewController.m
//  A1-1
//
//  Created by JateXu on 8/13/14.
//  Copyright (c) 2014 JateXu. All rights reserved.
//

#import "CViewController.h"

#import "CCircleHUDView.h"

#import "CTransform3DPerspective.h"

#import "MJRefresh.h"


@interface CViewController () <UIGestureRecognizerDelegate>
{
    CGFloat bottomOriginY;
    
    // for control bottom table view frame change.
    CGFloat tabOriginYMin;
    CGFloat tabOriginYMax;
    
    CGFloat stepsCenterYDelta;
}
@property (weak, nonatomic) IBOutlet UIView *circleView;

@property (weak, nonatomic) IBOutlet UIView *stepsView;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;


@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *bottomTableView;

// refresh
@property (strong, nonatomic) MJRefreshHeaderView *tableHeader;

//
@property (strong, nonatomic) CCircleHUDView *hudV;

// Initial Animation
@property (nonatomic, assign) CGFloat initialAnimationFromValue;
@property (nonatomic, assign) CGFloat initialAnimationToValue;
@property (nonatomic, assign) CFTimeInterval initialAnimationStartTime;
@property (nonatomic, assign) CFTimeInterval initialAnimationFactor;
@property (nonatomic, strong) CADisplayLink *displayLink;



@end

@implementation CViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
	
    self.circleView.alpha = 0.0;
    self.stepsView.alpha = 0.0;
    self.bottomView.alpha = 0.0;
//    self.bottomTableView.canCancelContentTouches = YES;
//    self.bottomTableView.delaysContentTouches = YES;
    
    CCircleHUDView *hubView = [[CCircleHUDView alloc] initWithFrame:self.circleView.bounds];
    self.hudV = hubView;
    [self.circleView addSubview:self.hudV];
    
    [self.hudV setProgress:0.3 animated:NO];
    
    
    // add table view refresh view here.
    [self addHeader];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //???
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    // init value
    CGRect bounds = self.view.bounds;
    tabOriginYMin = bounds.size.height / 3 - 10;
    tabOriginYMax = bounds.size.height / 3 * 2 - 30;
    
    stepsCenterYDelta = 65;
    CGFloat yDelta = (tabOriginYMin) / 2;
    stepsCenterYDelta = self.stepsView.center.y - yDelta + 12;
    
    // Setup Anchor Point for circle HUD View.
    [self setView:self.circleView AnchorPoint:CGPointMake(0.5, 0.0)];
    [self setView:self.stepsView AnchorPoint:CGPointMake(0.5, 0.0)];
    
    [self performSelector:@selector(startInitialAnimation) withObject:nil afterDelay:0.2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setView:(UIView *)view AnchorPoint:(CGPoint)anchor
{
    CGRect oldFrame = view.frame;
    view.layer.anchorPoint = anchor;
    view.frame = oldFrame;
}

#pragma mark - Initial Animation
- (void)startInitialAnimation
{
    self.circleView.alpha = 0.0;
    self.stepsView.alpha = 0.0;
    
    self.initialAnimationStartTime = CACurrentMediaTime();
    self.initialAnimationFromValue = 1;
    self.initialAnimationToValue = 0;
    if (!_displayLink)
    {
        //Create and setup the display link
        [self.displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationFun:)];
        [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    }
}

- (void)animationFun:(CADisplayLink *)displayLink
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat dt = (displayLink.timestamp - _initialAnimationStartTime) / 0.5;
        
        if (dt >= 1.0) {
            //Order is important! Otherwise concurrency will cause errors, because setProgress: will detect an animation in progress and try to stop it by itself. Once over one, set to actual progress amount. Animation is over.
            [self.displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
            self.displayLink = nil;
            
            self.initialAnimationFactor = self.initialAnimationToValue;
            [self changeInitialAnimationToCircleView];
            [self changeInitialAnimationToBottomView];
            
            [self initialAnimationOnCompeleted];
            return;
        }
        
        self.initialAnimationFactor = _initialAnimationFromValue + dt * (_initialAnimationToValue - _initialAnimationFromValue);
        [self changeInitialAnimationToCircleView];
        [self changeInitialAnimationToBottomView];
    });
}

- (void)changeInitialAnimationToCircleView
{
    CGFloat factor = self.initialAnimationFactor;
    
    CGFloat angleX = ANGLE_TO_RADIAN(20 * factor);
    CATransform3D transformX = CATransform3DMakeRotation(angleX, 1.0, 0.0, 0.0);
    
    CGFloat yf = factor;
    CGFloat angleY = ANGLE_TO_RADIAN(60 * yf);
    CATransform3D transformY = CATransform3DMakeRotation(angleY, 0.0, 1.0, 0.0);
    
    CGFloat angleZ = ANGLE_TO_RADIAN(10 * factor);
    CATransform3D transformZ = CATransform3DMakeRotation(angleZ, 0.0, 0.0, 1.0);
    
    CATransform3D translateY = CATransform3DMakeTranslation(-5 * factor, 30 * factor, 10 * factor);
    
    CATransform3D transform = CATransform3DConcat(transformX, transformY);
    transform = CATransform3DConcat(transform, transformZ);
    transform = CATransform3DConcat(transform, translateY);
    
    transform = CATransform3DPerspect(transform, CGPointMake(0, 0), 500);
    
    self.circleView.layer.transform = transform;
    
    self.circleView.alpha = 1 - factor;
    self.stepsView.alpha = 1 - factor;
}

- (void)changeInitialAnimationToBottomView
{
    CGFloat factor = self.initialAnimationFactor;
    CGRect bounds = self.view.bounds;
    
    if (factor >= 0.95)
    {
        CGRect frame = self.bottomView.frame;
        frame.origin.y = bounds.size.height;
        self.bottomView.frame = frame;
        
        self.bottomView.hidden = NO;
        self.bottomView.alpha = 1;
        return ;
    }
    
    CGFloat height = tabOriginYMin * factor;
    
    CGRect frame = self.bottomView.frame;
    frame.origin.y = tabOriginYMax + height;
    frame.size.height = bounds.size.height - frame.origin.y;
    self.bottomView.frame = frame;
}

- (void)initialAnimationOnCompeleted
{
//    self.bottomTableView.scrollEnabled = true;
}

#pragma mark - Circle HUD View Animation
- (void)changeCircleViewWithFactor:(float)factor
{
//    NSLog(@"%f", factor);
    
    // rotate the circle view.
    CGFloat angle = ANGLE_TO_RADIAN(85 * factor);
    
    CATransform3D transform = CATransform3DMakeRotation(angle, 1.0, 0.0, 0.0);
    
    transform = CATransform3DPerspect(transform, CGPointMake(0, 0), 500);
    
    self.circleView.layer.transform = transform;
    
    self.circleView.alpha = 1 - factor;
    
    [self changeStepsViewWithFactor:factor];
}

- (void)changeStepsViewWithFactor:(float)factor
{
    //    NSLog(@"%f", factor);
    
    // rotate the circle view.
    CGFloat angle = ANGLE_TO_RADIAN(10 * factor);
    
    CATransform3D transform = CATransform3DMakeRotation(angle, 1.0, 0.0, 0.0);
    CATransform3D translate = CATransform3DMakeTranslation(0.0, -stepsCenterYDelta * factor, 60 * factor);
    transform = CATransform3DConcat(transform, translate);
    transform = CATransform3DPerspect(transform, CGPointMake(0, 0), 500);
    
    self.stepsView.layer.transform = transform;
    
    for (UILabel *label in self.labels) {
        label.alpha = 1 - factor;
    }
    
    self.stepLabel.alpha = factor;
//    self.circleView.alpha = 1 - factor;
}

#pragma mark - Refresh
- (void)addHeader
{
    //    __unsafe_unretained CHomeViewController *vc = self;
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.bottomTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
//        NSLog(@"%@----开始进入刷新状态", refreshView.class);
        
        [self performSelector:@selector(doneWithView:) withObject:self.tableHeader afterDelay:0.5];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
//        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    self.tableHeader = header;
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    [self.bottomTableView reloadData];
    
    [refreshView endRefreshing];
}

#pragma mark - Gesture
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"%s - state:%d", __PRETTY_FUNCTION__, gestureRecognizer.state);
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
//        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
//        NSLog(@"=========>> x = %f, y = %f", translation.x, translation.y);
        
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view];
        NSLog(@"velocity.y = %f", velocity.y);
        
        if (velocity.y < 0)
        {   // up
            
            if (bottomOriginY == tabOriginYMin)
            {
                return YES;
            }
            else
            {
                return NO; // disable table view gesture.
            }
        }
        else
        {   // down
            
            if (bottomOriginY == tabOriginYMax)
            {
                return YES;
            }
            else
            {
                return NO; // disable table view gesture.
            }
        }
    }
    
    return YES;
}

- (IBAction)panGesture:(UIPanGestureRecognizer *)gest
{
    NSLog(@"%s - state:%d", __PRETTY_FUNCTION__, gest.state);
    
    CGRect bounds = self.view.bounds;
    
    switch (gest.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            bottomOriginY = self.bottomView.frame.origin.y;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [gest translationInView:self.view];
            
            CGFloat tempY = bottomOriginY + translation.y;
            
            if (tempY >= tabOriginYMin && tempY <= tabOriginYMax)
            {
                bottomOriginY = tempY;
                
                CGRect frame = self.bottomView.frame;
                frame.origin.y = bottomOriginY;
                frame.size.height = bounds.size.height - bottomOriginY;
                self.bottomView.frame = frame;
                
                float factor = (bottomOriginY - tabOriginYMin ) / (tabOriginYMax - tabOriginYMin);
                
                [self changeCircleViewWithFactor:1 - factor];
            }
            
            // Must call this to make it soomthly.
            [gest setTranslation:CGPointZero inView:self.view];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGPoint velocity = [gest velocityInView:self.view];
            if (velocity.y < 0)
            {
                bottomOriginY = tabOriginYMin;
            }
            else
            {
                bottomOriginY = tabOriginYMax;
            }
            
            [UIView animateWithDuration:0.25
                             animations:^{
                                 CGRect frame = self.bottomView.frame;
                                 frame.origin.y = bottomOriginY;
                                 frame.size.height = bounds.size.height - bottomOriginY;
                                 self.bottomView.frame = frame;
                             }
                             completion:^(BOOL finished) {
                             }];
            
            float factor = (bottomOriginY - tabOriginYMin ) / (tabOriginYMax - tabOriginYMin);
            [self changeCircleViewWithFactor:1 - factor];
        }
            break;
        default:
            break;
    }
}


@end
