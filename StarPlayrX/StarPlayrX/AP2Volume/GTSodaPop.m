#import "GTSodaPop.h"
#import <CommonCrypto/CommonCryptor.h>

@interface GTSodaPop ()
@property (nonatomic, readonly) NSCache* cache;
@end

@implementation GTSodaPop


#pragma mark - Public Class Method

+ (NSString*)encryptedBase64StringForString:(NSString*)string key:(NSString*)key
{
    if (string.length == 0 || key.length == 0) {
        return nil;
    }
    
    NSString* cacheKey = [NSString stringWithFormat:@"enc-%@-%@", key, string];
    NSString* cached   = [[[self sharedInstance] cache] objectForKey:cacheKey];
    if (cached) {
        return cached;
    }
    else {
        NSData*   plainData             = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSData*   encryptedData         = [[self sharedInstance] encryptedDataForData:plainData key:key];
        NSString* encryptedBase64String = [self base64StringForData:encryptedData];
        [[[self sharedInstance] cache] setObject:encryptedBase64String forKey:cacheKey];
        return encryptedBase64String;
    }
}

+ (NSString*)decryptedStringForBase64String:(NSString*)base64String key:(NSString*)key
{
    if (base64String.length == 0 || key.length == 0) {
        return nil;
    }
    
    NSString* cacheKey = [NSString stringWithFormat:@"dec-%@-%@", key, base64String];
    NSString* cached   = [[[self sharedInstance] cache] objectForKey:cacheKey];
    if (cached) {
        return cached;
    }
    else {
        NSData*   encryptedData   = [self dataForBase64String:base64String];
        NSData*   decryptedData   = [[self sharedInstance] decryptedDataForData:encryptedData key:key];
        NSString* decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        [[[self sharedInstance] cache] setObject:decryptedString forKey:cacheKey];
        return decryptedString;
    }
}

#pragma mark - Private Class Method

+ (NSString*)base64StringForData:(NSData*)data
{
    NSString* base64String;
    #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    // less than iOS 7.0
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        base64String = [data base64Encoding];
        #pragma clang diagnostic pop
    }
    // greater or equal iOS 7.0
    else if (NSFoundationVersionNumber_iOS_7_0 <= NSFoundationVersionNumber) {
        base64String = [data base64EncodedStringWithOptions:0];
    }
    #elif TARGET_OS_MAC
    // greater or equal OSX 10.9
    if (NSFoundationVersionNumber10_9 <= NSFoundationVersionNumber) {
        base64String = [data base64EncodedStringWithOptions:0];
    }
    #endif
    return base64String;
}

+ (NSData*)dataForBase64String:(NSString*)base64String
{
    NSData* data = nil;
    #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    // less than iOS 7.0
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        data = [[NSData alloc] initWithBase64Encoding:base64String];
        #pragma clang diagnostic pop
    }
    // greater or equal iOS 7.0
    else if (NSFoundationVersionNumber_iOS_7_0 <= NSFoundationVersionNumber) {
        data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    }
    #elif TARGET_OS_MAC
    // greater or equal OSX 10.9
    if (NSFoundationVersionNumber10_9 <= NSFoundationVersionNumber) {
        data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    }
    #endif
    return data;
}

#pragma mark - Singleton Pattern

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initSharedInstance
{
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initSharedInstance];
    });
    return sharedInstance;
}

#pragma mark - Encryption

- (NSData*)encryptedDataForData:(NSData*)data key:(NSString*)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void*  buffer     = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,
                                          data.bytes, data.length,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    else {
        free(buffer);
        return nil;
    }
}

#pragma mark - Decryption

- (NSData*)decryptedDataForData:(NSData*)data key:(NSString*)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void*  buffer     = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,
                                          data.bytes, data.length,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    else {
        free(buffer);
        return nil;
    }
}

@end
