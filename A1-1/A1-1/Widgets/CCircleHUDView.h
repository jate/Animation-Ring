//
//  CCircleHUDView.h
//  testCircle
//
//  Created by JateXu on 8/12/14.
//  Copyright (c) 2014 SIXIN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCircleHUDView : UIView

/**@name Appearance*/
/**The primary color of the `M13ProgressView`.*/
@property (nonatomic, strong) UIColor *primaryColor;
/**The secondary color of the `M13ProgressView`.*/
@property (nonatomic, strong) UIColor *secondaryColor;


@property (nonatomic, assign) CGFloat progress;



- (id)initWithFrame:(CGRect)frame;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;






@end
