//
//  ThirdUpload.m
//  UpYunFusionSDKDemo
//
//  Created by lingang on 2017/11/28.
//  Copyright © 2017年 upyun. All rights reserved.
//

#import "ThirdUpload.h"

@implementation ThirdUpload
+ (ThirdUpload *)instance
{
    static dispatch_once_t once;
    static ThirdUpload *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[ThirdUpload alloc] init];
        
        sharedInstance.thirdUploadMethod = kNoneThirdUpload;
        
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
