//
//  AP2Volume.h
//  StarPlayrX
//
//  Created by Todd Bruss on 11/1/19
//  Copyright © 2019-2020 StarPlayrX. All rights reserved.
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
