//
//  QiniuUpload.h
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/15.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpYun.h"

@interface QiniuUpload : NSObject

- (void)QiniuUploadWithFileData:(NSData *)data
                       FilePath:(NSString *)filePath
                        SaveKey:(NSString *)savekey
                        success:(HttpSuccessBlock)httpSuccess
                        failure:(HttpFailBlock)httpFail
                       progress:(HttpProgressBlock)httpProgress;
- (void)QiniuMutUploadWithFileData:(NSData *)data
                       FilePath:(NSString *)filePath
                        SaveKey:(NSString *)savekey
                     progressBlock:(UPProgressBlock)progressBlock
                     completeBlock:(UPCompeleteBlock)completeBlock;
@end
