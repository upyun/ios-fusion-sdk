//
//  QiniuUpload.h
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/15.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThirdUpload.h"
#import "UpYunUploader.h"


@interface QiniuUpload : NSObject

- (void)QiniuUploadWithFileData:(NSData *)data
                       FilePath:(NSString *)filePath
                        SaveKey:(NSString *)savekey
                        success:(UpLoaderSuccessBlock)successBlock
                        failure:(UpLoaderFailureBlock)failureBlock
                       progress:(UpLoaderProgressBlock)progressBlock;
- (void)QiniuMutUploadWithFileData:(NSData *)data
                       FilePath:(NSString *)filePath
                        SaveKey:(NSString *)savekey
                           success:(UpLoaderSuccessBlock)successBlock
                           failure:(UpLoaderFailureBlock)failureBlock
                          progress:(UpLoaderProgressBlock)progressBlock;
@end
