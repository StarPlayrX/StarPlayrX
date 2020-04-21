//
//  AP2Volume.h
//  StarPlayrX
//
//  Created by Todd Bruss on 11/1/19
//  Copyright © 2019-2020 StarPlayrX. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef AP2Volume_h
#define AP2Volume_h

@interface AP2Volume : NSObject

+ (AP2Volume *)shared;
- (void)hud:(BOOL)enabled;
- (float)getVolume;
- (void)setVolume:(float)volume;
- (void)setVolumeBy:(float)volume;

@end

#endif /* AP2Volume_h */
