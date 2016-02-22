//
//  NSData+MD5Digest.m
//  NSData+MD5Digest
//
//  Created by Francis Chong on 12年6月5日.
//

#import "NSData+MD5Digest.h"
#import <CommonCrypto/CommonDigest.h>
#import <zlib.h>

@implementation NSData (MD5)

+(NSData *)MD5Digest:(NSData *)input {
    unsigned char result[CC_MD5_DIGEST_LENGTH];

    CC_MD5(input.bytes, (uint32_t)input.length, result);
    return [[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

-(NSData *)MD5Digest {
    return [NSData MD5Digest:self];
}

+(NSString *)MD5HexDigest:(NSData *)input {
    unsigned char result[CC_MD5_DIGEST_LENGTH];

    CC_MD5(input.bytes, (uint32_t)input.length, result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

-(NSString *)MD5HexDigest {
    return [NSData MD5HexDigest:self];
}

//- (UInt32) DataCRC32 {
//    uLong crc = crc32(0L, Z_NULL, 0);
//    crc = crc32(crc, [self bytes], (uInt)self.length);
//    return (UInt32)crc;
//}

@end
