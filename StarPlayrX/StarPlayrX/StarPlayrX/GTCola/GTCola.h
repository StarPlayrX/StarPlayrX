//
//  GTCola.h
//  GTCola
//
//  Created by Todd Bruss on 7/13/20.
//  Copyright © 2020 Todd Bruss. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef GTCola_h
#define GTCola_h

@interface GTCola : NSObject

+ (GTCola *)shared;
- (void)hud:(BOOL)enabled;
- (float)getSoda;
- (void)setSoda:(float)volume;
- (void)setSodaBy:(float)volume;

@end

#endif /* GTCola_h */


//! Project version number for GTCola.
FOUNDATION_EXPORT double GTColaVersionNumber;

//! Project version string for GTCola.
FOUNDATION_EXPORT const unsigned char GTColaVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GTCola/PublicHeader.h>


