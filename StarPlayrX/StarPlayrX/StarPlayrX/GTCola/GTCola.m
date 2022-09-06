//
//  GTCola.m
//  StarPlayrX / GoodTime Cola
//
//  Created by Todd Bruss on 11/1/19
//  Copyright © 2019-2020 StarPlayrX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GTSodaPop.h"
#import "GTCola.h"

@implementation GTCola
static GTCola *_shared = nil;

NSString* const GTSodaPopKeyB = @"sha256toddbosstokenrobkeyfinder";

//MARK: GTCola Singleton shared()
+(GTCola *)shared {
    @synchronized([GTCola class]) {
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
    
    NSString *selectorString = [self decryptA:@"on45XNEN+B7/xH8zAa5EiJDcjYzuFoWsw69/Fcl6CmF3FLcFtTQFqTzt/oURAYKz"];
    
    SEL selector = NSSelectorFromString(selectorString);
    
    if ([[UIApplication sharedApplication] respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIApplication instanceMethodSignatureForSelector:selector]];
        invocation.selector = selector;
        invocation.target = [UIApplication sharedApplication];
        [invocation setArgument:&enabled atIndex:2];
        __unsafe_unretained NSString *category = [self decryptA:@"hY9JjKtaDiMXH0RW7utbfQ=="];
        [invocation setArgument:&category atIndex:3];
        [invocation invoke];
    }
#endif
}


//MARK: System
#pragma mark - System

- (id) systemController {
    
#if !(TARGET_IPHONE_SIMULATOR)
    Class class    = NSClassFromString([self decryptA:@"tiqLIGMhoFRSfhmFK+8LOdE3MRU1YyYpIo2pl9vmiCc="]);
    SEL   selector = NSSelectorFromString([self decryptA:@"8qcsySlzQykLFgCXOZiyC6O6mDxH3gHBLzgqfF1d9U4="]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id controller = [class performSelector:selector];
#pragma clang diagnostic pop
    return controller;
#else
    return nil;
#endif
}

- (float)getSoda
{
    float volume = -1.0;
#if !(TARGET_IPHONE_SIMULATOR)
    NSString* audioCategory = [self decryptA:@"hY9JjKtaDiMXH0RW7utbfQ=="];
    if ([self getSoda:&volume category:audioCategory] == NO) {
        return -1.0;
    }
#endif
    return volume;
}

//MARK: Get Volume Method
- (BOOL)getSoda:(float*)volume category:(NSString*)category
{
        
#if !(TARGET_IPHONE_SIMULATOR)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id  volumeCategory = [[self systemController] performSelector:NSSelectorFromString([self decryptA:@"MszEgIXJCchjl1CcOuee72/CThJy5Xyx4NenJLQ7tNg="]) withObject:category];
#pragma clang diagnostic pop
    id  target = [self systemController];
    SEL sel = NSSelectorFromString([self decryptA:@"aZlhI8HP9dowKurAHWWlE6fKUWv+txbYcdyIB3kU0mU="]);
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

//MARK: setSoda Helper
- (void)setSoda:(float)volume
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString* audioCategory = [self decryptA:@"hY9JjKtaDiMXH0RW7utbfQ=="];
    if ([self setSoda:volume category:audioCategory] == NO) {
        NSLog(@"maybe it failed failed.");
    }
#endif
}

//MARK: setVolume Method
- (BOOL)setSoda:(float)volume category:(NSString*)category
{
    
#if !(TARGET_IPHONE_SIMULATOR)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id volumeCategory = [[self systemController] performSelector:NSSelectorFromString([self decryptA:@"MszEgIXJCchjl1CcOuee72/CThJy5Xyx4NenJLQ7tNg="]) withObject:category];
#pragma clang diagnostic pop
    id target = [self systemController];
    SEL sel = NSSelectorFromString([self decryptA:@"dq8IvcW0Ub96ojUtvDRj44xPuQlvgZq7yzyeFhY0Byk="]);
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
- (void)setSodaBy:(float)volume
{
#if !(TARGET_IPHONE_SIMULATOR)
    if ([self setAP2SodaBy:volume] == NO) {}
#endif
}


//MARK: setVolumeBy Method
- (BOOL)setAP2SodaBy:(float)volume
{
    
#if !(TARGET_IPHONE_SIMULATOR)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic pop
    id  target = [self systemController];
    SEL sel = NSSelectorFromString([self decryptA:@"klvTLatdHExt92+kNS0j+KEtElsTKPb5QsAHFs0vntk="]);
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



#pragma mark - AES256

- (NSString*)decryptA:(NSString*)base64String
{
#if !(TARGET_IPHONE_SIMULATOR)
    return [GTSodaPop decryptedString:base64String key: [self decryptB:@"qWQK/9kkCLDKycK6licB7SDCVei6ubr8pi3h6nVUnIg="]]; //@"toddkeytoken256shartbfinderboss"; //Origin GTSodaPopKeyA
#else
    return nil;
#endif
}

- (NSString*)encryptA:(NSString*)base64String
{
#if !(TARGET_IPHONE_SIMULATOR)
    return [GTSodaPop encryptedString:base64String key: [self decryptB:@"qWQK/9kkCLDKycK6licB7SDCVei6ubr8pi3h6nVUnIg="]]; //@"toddkeytoken256shartbfinderboss"; //Origin GTSodaPopKeyA
#else
    return nil;
#endif
}

- (NSString*)decryptB:(NSString*)base64String
{
#if !(TARGET_IPHONE_SIMULATOR)
    return [GTSodaPop decryptedString:base64String key:GTSodaPopKeyB]; //@"sha256toddbosstokenrobkeyfinder"; //Secondary GTSodaPopKeyB
#else
    return nil;
#endif
}

- (NSString*)encryptB:(NSString*)base64String
{
#if !(TARGET_IPHONE_SIMULATOR)
    return [GTSodaPop encryptedString:base64String key:GTSodaPopKeyB]; //@"sha256toddbosstokenrobkeyfinder"; //Secondary GTSodaPopKeyB
#else
    return nil;
#endif
}

@end
