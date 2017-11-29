//
//  ThirdUpload.h
//  UpYunFusionSDKDemo
//
//  Created by lingang on 2017/11/28.
//  Copyright © 2017年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpYunUploader.h"


@interface ThirdUpload : NSObject
+ (ThirdUpload *)instance;

@property (nonatomic, assign) ThirdUploadMethod thirdUploadMethod;

/// 上传到七牛的 路径
@property (nonatomic, copy) NSString *QiniuUploadPath;

/// 上传到阿里的 路径
@property (nonatomic, copy) NSString *AliyunUploadPath;

// 以下为Qiniu 上传的配置, 若只使用UPYUN 上传可不配置
/** Qiniu 分块大小, 文档只给出了4MB的选择*/
@property (nonatomic, assign) NSInteger QiniuBlockSize;
/** Qiniu 分片大小, 默认 500kb*/
@property (nonatomic, assign) NSInteger QiniuChunkSize;
/** Qiniu 并发请求数量, 默认 3*/
@property (nonatomic, assign) NSInteger QinMaxConcurrentCount;

/** Qiniu 上传的url https://upload.qiniu.com/ */
@property (nonatomic, copy) NSString *QiniuUploadUrl;
/** Qiniu 创建块的url https://up-z0.qiniu.com/mkblk/ */
@property (nonatomic, copy) NSString *QiniuCreateBlockUrl;
/** Qiniu 上传片的url https://up-z0.qiniu.com/bput/ */
@property (nonatomic, copy) NSString *QiniuUploadChunkUrl;
/** Qiniu 合并文件的url https://up-z0.qiniu.com/mkfile/ */
@property (nonatomic, copy) NSString *QiniuMakeFileUrl;
/** Qiniu 上传凭证*/
@property (nonatomic, copy) NSString *QiniuToken;

// 以下为Aliyun 上传的配置, 若只使用UPYUN 上传可不配置
// 分块上传 特别注意： 对于移动端来说，如果不是比较大的文件，不建议使用这种方式上传，因为断点续传是通过分片上传实现的，上传单个文件需要进行多次网络请求，效率不高
/**Aliyun 分块大小, 不能小于100KB*/
@property (nonatomic, assign) NSInteger AlinyunBlockSize;

/**Aliyun 空间*/
@property (nonatomic, copy) NSString *AliyunBucket;
/**Aliyun AccessKey*/
@property (nonatomic, copy) NSString *AliyunAccessKey;
/**Aliyun SecretKey*/
@property (nonatomic, copy) NSString *AliyunSecretKey;
/**Aliyun 上传节点*/
@property (nonatomic, copy) NSString *AliyunEndPoint;

@end
