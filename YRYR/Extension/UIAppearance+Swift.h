//
//  UIAppearance+Swift.h
//  YRYR
//
//  Created by Yuki MIZUNO on 7/2/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIViewAppearance_Swift)
+ (instancetype)appearanceWhenContainedInInstancesOfClasses:(NSArray *)containerClass;
@end