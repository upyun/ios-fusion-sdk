//
//  AliyunUpload.h
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/16.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThirdUpload.h"
#import "UpYunUploader.h"

@interface AliyunUpload : NSObject

- (void)AliyunUploadWithFileData:(NSData *)data
                        FilePath:(NSString *)filePath
                         SaveKey:(NSString *)savekey
                         success:(UpLoaderSuccessBlock)successBlock
                         failure:(UpLoaderFailureBlock)failureBlock
                        progress:(UpLoaderProgressBlock)progressBlock;

- (void)AliyunMutUploadWithFileData:(NSData *)data
                          FilePath:(NSString *)filePath
                           SaveKey:(NSString *)savekey
                            success:(UpLoaderSuccessBlock)successBlock
                            failure:(UpLoaderFailureBlock)failureBlock
                           progress:(UpLoaderProgressBlock)progressBlock;
@end
