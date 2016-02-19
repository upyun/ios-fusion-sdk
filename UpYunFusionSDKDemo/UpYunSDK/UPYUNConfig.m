//
//  UPYUNConfig.m
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/2.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import "UPYUNConfig.h"

@implementation UPYUNConfig
+ (UPYUNConfig *)sharedInstance
{
    static dispatch_once_t once;
    static UPYUNConfig *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[UPYUNConfig alloc] init];
        sharedInstance.DEFAULT_BUCKET = @"";
        sharedInstance.DEFAULT_PASSCODE = @"";
        sharedInstance.DEFAULT_EXPIRES_IN = 1800;
        sharedInstance.DEFAULT_MUTUPLOAD_SIZE = 4*1024*1024;
        sharedInstance.DEFAULT_RETRY_TIMES = 2;
        sharedInstance.SingleBlockSize = 500*1024;
        sharedInstance.FormAPIDomain = @"https://v0.api.upyun.com/";
        sharedInstance.MutAPIDomain = @"https://m0.api.upyun.com/";
        
        sharedInstance.thirdUpload = kNoneThirdUpload;
        
        sharedInstance.QiniuBlockSize = 4*1024*1024;
        sharedInstance.QiniuChunkSize = 512*1024;
        sharedInstance.QinMaxConcurrentCount = 3;
        
        sharedInstance.QiniuUploadUrl = @"https://upload.qiniu.com/";
        sharedInstance.QiniuCreateBlockUrl = @"https://up-z0.qiniu.com/mkblk/";
        sharedInstance.QiniuUploadChunkUrl = @"https://up-z0.qiniu.com/bput/";
        sharedInstance.QiniuMakeFileUrl = @"https://up-z0.qiniu.com/mkfile/";
        sharedInstance.QiniuToken = @"";
        
        
        sharedInstance.AlinyunBlockSize = 4*1024*1024;
        sharedInstance.AliyunBucket = @"";
        sharedInstance.AliyunAccessKey = @"";
        sharedInstance.AliyunSecretKey = @"";
        sharedInstance.AliyunEndPoint = @"https://oss-cn-hangzhou.aliyuncs.com";
    });
    return sharedInstance;
}
@end
