//
//  Capriccio-Bridging-Header.h
//  Capriccio
//
//  Created by Yuki MIZUNO on 6/2/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

#ifndef Capriccio_Bridging_Header_h
#define Capriccio_Bridging_Header_h

#import <MobileVLCKit/MobileVLCKit.h>

#ifndef __IPHONE_9_0
#import "UIAppearance+Swift.h"
#elif __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
#import "UIAppearance+Swift.h"
#endif

#endif
