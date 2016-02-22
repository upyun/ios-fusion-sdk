//
//  UPYUNConfig.h
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/2.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ThirdUpload) {
    kNoneThirdUpload = 1,
    kQiniuUpload = 2,
    kAliyunUPload = 3
};

@interface UPYUNConfig : NSObject
+ (UPYUNConfig *)sharedInstance;
/**
 *	@brief 默认空间名(必填项), 默认为 *****
 */
@property (nonatomic, copy) NSString *DEFAULT_BUCKET;
/**
 *	@brief	默认表单API密钥, 默认为 *******
 */
@property (nonatomic, copy) NSString *DEFAULT_PASSCODE;
/**
 *	@brief	默认当前上传授权的过期时间，单位为“秒” （必填项，较大文件需要较长时间)，默认1800秒
 */
@property (nonatomic, assign) NSInteger DEFAULT_EXPIRES_IN;
/**
 *	@brief 默认超过大小后走分块上传，可在init之后修改mutUploadSize的值来更改
 */
@property (nonatomic, assign) NSInteger DEFAULT_MUTUPLOAD_SIZE;
/**
 *	@brief 失败重传次数, 默认重试两次
 */
@property (nonatomic, assign) NSInteger DEFAULT_RETRY_TIMES;
/**
 *  @brief 单个分块尺寸500kb(不可小于100kb, 不超过5M)
 */
@property (nonatomic, assign) NSInteger SingleBlockSize;
/**
 *  @brief 表单Domain http://v0.api.upyun.com/
 */
@property (nonatomic, copy) NSString *FormAPIDomain;
/**
 *  @brief 分块Domain http://m0.api.upyun.com/
 */
@property (nonatomic, copy) NSString *MutAPIDomain;

@property (nonatomic, assign) ThirdUpload thirdUpload;

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