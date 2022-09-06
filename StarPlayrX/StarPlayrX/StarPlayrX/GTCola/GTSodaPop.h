#import <Foundation/Foundation.h>

@interface GTSodaPop : NSObject

+ (NSString*)encryptedString:(NSString*)string key:(NSString*)key;
+ (NSString*)decryptedString:(NSString*)base64String key:(NSString*)key;

@end
