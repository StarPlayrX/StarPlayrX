//
//  AP2Volume.m
//  StarPlayrX
//
//  Created by Todd Bruss on 11/1/19
//  Copyright © 2019-2020 StarPlayrX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AP2Volume.h"

@implementation AP2Volume
static AP2Volume *_shared = nil;


//MARK: AP2Volume Singleton shared()
+(AP2Volume *)shared {
    @synchronized([AP2Volume class]) {
        if (!_shared)
            _shared = [[self alloc] init];
        return _shared;
    }
    return nil;
}


//MARK: Set HUD Method
- (void)hud:(BOOL)enabled
{
#if !(TARGET_IPHONE_SIMULATOR)
    //NSString *system = @"System";
    
    NSString *selectorString = [NSString stringWithFormat:@"setSystemVolumeHUDEnabled:forAudioCategory:"];
    
    SEL selector = NSSelectorFromString(selectorString);
    
    if ([[UIApplication sharedApplication] respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIApplication instanceMethodSignatureForSelector:selector]];
        invocation.selector = selector;
        invocation.target = [UIApplication sharedApplication];
        [invocation setArgument:&enabled atIndex:2];
        __unsafe_unretained NSString *category = [NSString stringWithFormat:@"Audio/Video"];
        [invocation setArgument:&category atIndex:3];
        [invocation invoke];
        
    }
#endif
}


//MARK: System
#pragma mark - System

- (id)systemController
{
    
#if !(TARGET_IPHONE_SIMULATOR)
    Class class    = NSClassFromString(@"AVSystemController");
    SEL   selector = NSSelectorFromString(@"sharedAVSystemController");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id controller = [class performSelector:selector];
#pragma clang diagnostic pop
    return controller;
#else
    return nil;
#endif
}


//MARK: Get Volume Helper
- (float)getVolume
{
    float volume = -1.0;
    id andName = 0;
#if !(TARGET_IPHONE_SIMULATOR)
    if ([self getActiveCategoryVolume:&volume andName:&andName] == NO) {
        return -1.0;
    }
#endif
    return volume;
}

//MARK: Get Volume Method
- (BOOL)getActiveCategoryVolume:(float*)volume andName:(id*)andName
{
    
#if !(TARGET_IPHONE_SIMULATOR)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
#pragma clang diagnostic pop
    id  target = [self systemController];
    SEL sel = NSSelectorFromString(@"getActiveCategoryVolume:andName:");
    NSMethodSignature* signature = [target methodSignatureForSelector:sel];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:sel];
    [invocation setArgument:&volume atIndex:2];
    [invocation setArgument:&andName atIndex:3];
    [invocation invoke];
    BOOL success;
    [invocation getReturnValue:&success];
    return success;
#else
    return NO;
#endif
}


//MARK: setVolume Helper
- (void)setVolume:(float)volume
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString* audioCategory = @"Audio/Video";
    if ([self setVolume:volume category:audioCategory] == NO) {
        NSLog(@"maybe it failed failed.");
    }
#endif
}

//MARK: setVolume Method
- (BOOL)setVolume:(float)volume category:(NSString*)category
{
    
#if !(TARGET_IPHONE_SIMULATOR)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id  volumeCategory = [[self systemController] performSelector:NSSelectorFromString(@"volumeCategoryForAudioCategory:") withObject:category];
#pragma clang diagnostic pop
    id  target = [self systemController];
    SEL sel = NSSelectorFromString(@"setVolumeTo:forCategory:");
    NSMethodSignature* signature = [target methodSignatureForSelector:sel];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:sel];
    [invocation setArgument:&volume atIndex:2];
    [invocation setArgument:&volumeCategory atIndex:3];
    [invocation invoke];
    BOOL success;
    [invocation getReturnValue:&success];
    return success;
#else
    return NO;
#endif
}

//MARK: setVolumeBy Helper
- (void)setVolumeBy:(float)volume
{
#if !(TARGET_IPHONE_SIMULATOR)
    if ([self setAP2VolumeBy:volume] == NO) {}
#endif
}


//MARK: setVolumeBy Method
- (BOOL)setAP2VolumeBy:(float)volume
{
    
#if !(TARGET_IPHONE_SIMULATOR)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic pop
    id  target = [self systemController];
    SEL sel = NSSelectorFromString(@"changeActiveCategoryVolumeBy:");
    NSMethodSignature* signature = [target methodSignatureForSelector:sel];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:sel];
    [invocation setArgument:&volume atIndex:2];
    [invocation invoke];
    BOOL success;
    [invocation getReturnValue:&success];
    return success;
#else
    return NO;
#endif
}

@end
