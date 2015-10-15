//
//  UIAppearance+Swift.m
//  Capriccio
//
//  Created by Yuki MIZUNO on 7/2/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

#import "UIAppearance+Swift.h"

@implementation UIView (UIViewAppearance_Swift)
+ (instancetype)appearanceWhenContainedInInstancesOfClasses:(NSArray *)containerClass {
	return [self appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass[0], nil];
}
@end
