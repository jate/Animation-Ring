//
//  CTransform3DPerspective.h
//  A1-1
//
//  Created by JateXu on 8/13/14.
//  Copyright (c) 2014 JateXu. All rights reserved.
//

#ifndef A1_1_CTransform3DPerspective_h
#define A1_1_CTransform3DPerspective_h

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ);

CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ);


#endif
