//
//  AliyunUpload.h
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/16.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpYun.h"

@interface AliyunUpload : NSObject

- (void)AliyunUploadWithFileData:(NSData *)data
                        FilePath:(NSString *)filePath
                         SaveKey:(NSString *)savekey
                   completeBlock:(UPCompeleteBlock)completeBlock
                        progress:(UPProgressBlock)httpProgress;

- (void)AliyunMutUploadWithFileData:(NSData *)data
                          FilePath:(NSString *)filePath
                           SaveKey:(NSString *)savekey
                     progressBlock:(UPProgressBlock)progressBlock
                     completeBlock:(UPCompeleteBlock)completeBlock;
@end
