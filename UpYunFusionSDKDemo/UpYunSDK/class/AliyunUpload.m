//
//  AliyunUpload.m
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/16.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import "AliyunUpload.h"
#import <UIKit/UIKit.h>
#import "OSSService.h"

@interface AliyunUpload () {
    OSSClient * client;
}

@property (nonatomic, assign) NSInteger fileLength;
@property (nonatomic, copy) NSString * filePath;
@property (nonatomic, copy) NSData * fileData;
@property (nonatomic, copy) NSString * uploadId;
@property (nonatomic, strong) NSMutableArray * partInfos;
@property (nonatomic, copy) NSString * uploadToBucket;
@property (nonatomic, copy) NSString * uploadObjectkey;
@property (nonatomic, strong) NSMutableArray *progressArray;

@end

@implementation AliyunUpload

- (instancetype)init {
    if (self == [super init]) {
        [self initOSSClient];
    }
    return self;
}

- (void)AliyunUploadWithFileData:(NSData *)data
                        FilePath:(NSString *)filePath
                         SaveKey:(NSString *)savekey
                         success:(UpLoaderSuccessBlock)successBlock
                         failure:(UpLoaderFailureBlock)failureBlock
                        progress:(UpLoaderProgressBlock)progressBlock; {
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    // required fields
    put.bucketName = [ThirdUpload instance].AliyunBucket;
    
    //在上传文件时，如果把ObjectKey写为"folder/subfolder/file"，即是模拟了把文件上传到folder/subfolder/下的file文件。注意，路径默认是"根目录"，不需要以'/'开头
    if ([savekey rangeOfString:@"/"].location == 0) {
        savekey = [savekey substringFromIndex:1];
    }
    
    NSString *key = savekey;
    
    if ([ThirdUpload instance].AliyunUploadPath.length > 0) {
        key = [NSString stringWithFormat:@"%@%@", [ThirdUpload instance].AliyunUploadPath, savekey];
    }
    
    put.objectKey = key;
    
    if (data) {
        put.uploadingData = data;
    } else {
        put.uploadingFileURL = [NSURL fileURLWithPath:filePath];
    }
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
//        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (progressBlock) {
                progressBlock(1.0*totalByteSent/totalBytesExpectedToSend, totalByteSent);
            }
        });
    };
    // 可选参数
//    put.contentType = @"";
//    put.contentMd5 = @"";
//    put.contentEncoding = @"";
//    put.contentDisposition = @"";
//    // 设置回调参数
//    put.callbackParam = @{@"callbackUrl": @"<your server callback address>",
//                          @"callbackBody": @"<your callback body>"};
//    // 设置自定义变量
//    put.callbackVar = @{@"<var1>": @"<value1>",
//                        @"<var2>": @"<value2>"};
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        NSLog(@"objectKey: %@", put.objectKey);
        NSString *string = @"";
        if (!task.error) {
            string = @"upload object success!";
            NSLog(@"upload object success!");
        } else {
            NSLog(@"upload object failed, error: %@", task.error);
        }
        OSSPutObjectResult * result = task.result;
        NSHTTPURLResponse * response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.oss-cn-hangzhou.aliyuncs.com/", [ThirdUpload instance].AliyunBucket]] statusCode:result.httpResponseCode HTTPVersion:@"1.1" headerFields:result.httpResponseHeaderFields];
        
        NSDictionary *dic = @{@"response":response, @"responseData":string};
        dispatch_async(dispatch_get_main_queue(), ^(){
            
            if (!task.error) {
                if (successBlock) {
                    successBlock(response, dic);
                }
            } else {
                if (failureBlock) {
                    failureBlock(task.error, response, dic);
                }
            }
        });
        return nil;
    }];
}

- (void)AliyunMutUploadWithFileData:(NSData *)data
                           FilePath:(NSString *)filePath
                            SaveKey:(NSString *)savekey
                            success:(UpLoaderSuccessBlock)successBlock
                            failure:(UpLoaderFailureBlock)failureBlock
                           progress:(UpLoaderProgressBlock)progressBlock; {
    
    if ([savekey rangeOfString:@"/"].location == 0) {
        savekey = [savekey substringFromIndex:1];
    }
    
    NSString *key = savekey;
    
    if ([ThirdUpload instance].AliyunUploadPath.length > 0) {
        key = [NSString stringWithFormat:@"%@%@", [ThirdUpload instance].AliyunUploadPath, savekey];
    }
    
    _uploadToBucket = [ThirdUpload instance].AliyunBucket;
    _uploadObjectkey = key;
    _partInfos = [[NSMutableArray alloc]init];
    _progressArray = [[NSMutableArray alloc]init];
    _fileData = data;
    _filePath = filePath;
    
    _fileLength = data.length;
    if (filePath) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        _fileLength = fileDictionary.fileSize;
    }
    NSInteger blockCount = ceil(_fileLength*1.0/[ThirdUpload instance].QiniuBlockSize);
    
    for (int i = 0; i < blockCount; i++) {
        [_partInfos addObject:[NSNull null]];
        [_progressArray addObject:@0];
    }
    
    OSSInitMultipartUploadRequest * init = [OSSInitMultipartUploadRequest new];
    init.bucketName = _uploadToBucket;
    init.objectKey = _uploadObjectkey;
    init.contentType = @"application/octet-stream";
//    init.objectMeta = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value1", @"x-oss-meta-name1", nil];
    
    OSSTask * initTask = [client multipartUploadInit:init];
    
    __weak typeof(self)weakSelf = self;
    [initTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            OSSInitMultipartUploadResult *result = initTask.result;
            _uploadId = result.uploadId;
            NSLog(@"init multipart upload success: %@", result.uploadId);
            for (int i = 1; i <= blockCount; i++) {
                [weakSelf uploadBlock:i success:successBlock failure:failureBlock progress:progressBlock];
            }
        } else {
            NSLog(@"multipart upload failed, error: %@", initTask.error);
        }
        return nil;
    }];
 
}

- (void)uploadBlock:(int32_t)index success:(UpLoaderSuccessBlock)successBlock
            failure:(UpLoaderFailureBlock)failureBlock
           progress:(UpLoaderProgressBlock)progressBlock{
    
    
    NSData *data;
    if (_filePath) {
        data = [self readChunkWithFilePath:_filePath offset:[ThirdUpload instance].AlinyunBlockSize * (index - 1)];
    } else {
        data = [self readChunkWithFileData:_fileData Offset:[ThirdUpload instance].AlinyunBlockSize * (index - 1)];
    }
    
    OSSUploadPartRequest * uploadPart = [OSSUploadPartRequest new];
    uploadPart.bucketName = _uploadToBucket;
    uploadPart.objectkey = _uploadObjectkey;
    uploadPart.uploadId = _uploadId;
    uploadPart.partNumber = index; // part number start from 1
    uploadPart.uploadPartData = data;
    
    __weak typeof(self)weakSelf = self;
    uploadPart.uploadPartProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            CGFloat percent = 1.0*totalByteSent/totalBytesExpectedToSend;
            @synchronized(_progressArray) {
                _progressArray[index-1] = [NSNumber numberWithFloat:percent];
                float sumPercent = 0;
                for (NSNumber *num in _progressArray) {
                    sumPercent += [num floatValue];
                }
                float totalPercent = sumPercent/_progressArray.count;
                if (progressBlock) {
                    progressBlock(totalPercent, _fileLength*totalPercent);
                }
            }
        });
    };
    OSSTask * uploadPartTask = [client uploadPart:uploadPart];
    [uploadPartTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            OSSUploadPartResult * result = uploadPartTask.result;
            uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:uploadPart.uploadPartFileURL.absoluteString error:nil] fileSize];
            
            [_partInfos replaceObjectAtIndex:(index - 1) withObject:[OSSPartInfo partInfoWithPartNum:index eTag:result.eTag size:fileSize]];
            
            if (![_partInfos containsObject:[NSNull null]]) {
                [weakSelf makeFileSuccess:successBlock failure:failureBlock progress:progressBlock];
            }
            
        } else {
            NSLog(@"upload part error: %@", uploadPartTask.error);
        }
        return nil;
    }];
}

- (void)makeFileSuccess:(UpLoaderSuccessBlock)successBlock
                      failure:(UpLoaderFailureBlock)failureBlock
                     progress:(UpLoaderProgressBlock)progressBlock {
    OSSCompleteMultipartUploadRequest * complete = [OSSCompleteMultipartUploadRequest new];
    complete.bucketName = _uploadToBucket;
    complete.objectKey = _uploadObjectkey;
    complete.uploadId = _uploadId;
    complete.partInfos = _partInfos;
    
    OSSTask *completeTask = [client completeMultipartUpload:complete];
    
    [completeTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"multipart upload success!");
        } else {
            NSLog(@"multipart upload failed, error: %@", completeTask.error);
        }
        
        OSSCompleteMultipartUploadResult * result = task.result;
        NSHTTPURLResponse * response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.oss-cn-hangzhou.aliyuncs.com/", [ThirdUpload instance].AliyunBucket]] statusCode:result.httpResponseCode HTTPVersion:@"1.1" headerFields:result.httpResponseHeaderFields];
        
        NSDictionary *dic = @{@"response":response, @"responseData":@"multipart upload success!"};
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (!task.error) {
                if (successBlock) {
                    successBlock(response, dic);
                }
            } else {
                if (failureBlock) {
                    failureBlock(task.error, response, dic);
                }
            }
        });
        return nil;
    }];
}

- (void)initOSSClient {
    
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:[ThirdUpload instance].AliyunAccessKey secretKey:[ThirdUpload instance].AliyunSecretKey];
    
    // 自实现签名，可以用本地签名也可以远程加签
//    id<OSSCredentialProvider> credential1 = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
//        NSString *signature = [OSSUtil calBase64Sha1WithData:contentToSign withSecret:@"<your secret key>"];
//        if (signature != nil) {
//            *error = nil;
//        } else {
//            // construct error object
//            *error = [NSError errorWithDomain:@"<your error domain>" code:OSSClientErrorCodeSignFailed userInfo:nil];
//            return nil;
//        }
//        return [NSString stringWithFormat:@"OSS %@:%@", @"<your access key>", signature];
//    }];
    
    // Federation鉴权，建议通过访问远程业务服务器获取签名
    // 假设访问业务服务器的获取token服务时，返回的数据格式如下：
    // {"accessKeyId":"STS.iA645eTOXEqP3cg3VeHf",
    // "accessKeySecret":"rV3VQrpFQ4BsyHSAvi5NVLpPIVffDJv4LojUBZCf",
    // "expiration":"2015-11-03T09:52:59Z[;",
    // "federatedUser":"335450541522398178:alice-001",
    // "requestId":"C0E01B94-332E-4582-87F9-B857C807EE52",
    // "securityToken":"CAES7QIIARKAAZPlqaN9ILiQZPS+JDkS/GSZN45RLx4YS/p3OgaUC+oJl3XSlbJ7StKpQp1Q3KtZVCeAKAYY6HYSFOa6rU0bltFXAPyW+jvlijGKLezJs0AcIvP5a4ki6yHWovkbPYNnFSOhOmCGMmXKIkhrRSHMGYJRj8AIUvICAbDhzryeNHvUGhhTVFMuaUE2NDVlVE9YRXFQM2NnM1ZlSGYiEjMzNTQ1MDU0MTUyMjM5ODE3OCoJYWxpY2UtMDAxMOG/g7v6KToGUnNhTUQ1QloKATEaVQoFQWxsb3cSHwoMQWN0aW9uRXF1YWxzEgZBY3Rpb24aBwoFb3NzOioSKwoOUmVzb3VyY2VFcXVhbHMSCFJlc291cmNlGg8KDWFjczpvc3M6KjoqOipKEDEwNzI2MDc4NDc4NjM4ODhSAFoPQXNzdW1lZFJvbGVVc2VyYABqEjMzNTQ1MDU0MTUyMjM5ODE3OHIHeHljLTAwMQ=="}
//    id<OSSCredentialProvider> credential2 = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * {
//        NSURL * url = [NSURL URLWithString:@"http://localhost:8080/distribute-token.json"];
//        NSURLRequest * request = [NSURLRequest requestWithURL:url];
//        OSSTaskCompletionSource * tcs = [OSSTaskCompletionSource taskCompletionSource];
//        NSURLSession * session = [NSURLSession sharedSession];
//        NSURLSessionTask * sessionTask = [session dataTaskWithRequest:request
//                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                                        if (error) {
//                                                            [tcs setError:error];
//                                                            return;
//                                                        }
//                                                        [tcs setResult:data];
//                                                    }];
//        [sessionTask resume];
//        [tcs.task waitUntilFinished];
//        if (tcs.task.error) {
//            NSLog(@"get token error: %@", tcs.task.error);
//            return nil;
//        } else {
//            NSDictionary * object = [NSJSONSerialization JSONObjectWithData:tcs.task.result
//                                                                    options:kNilOptions
//                                                                      error:nil];
//            OSSFederationToken * token = [OSSFederationToken new];
//            token.tAccessKey = [object objectForKey:@"accessKeyId"];
//            token.tSecretKey = [object objectForKey:@"accessKeySecret"];
//            token.tToken = [object objectForKey:@"securityToken"];
//            token.expirationTimeInGMTFormat = [object objectForKey:@"expiration"];
//            NSLog(@"get token: %@", token);
//            return token;
//        }
//    }];
    
    
    OSSClientConfiguration *conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 30;
    conf.timeoutIntervalForResource = 24 * 60 * 60;

    client = [[OSSClient alloc] initWithEndpoint:[ThirdUpload instance].AliyunEndPoint credentialProvider:credential clientConfiguration:conf];
}

- (NSData *)readChunkWithFileData:(NSData *)fileData Offset:(NSInteger)offset {
    
    NSInteger length = [ThirdUpload instance].AlinyunBlockSize;
    NSInteger startLocation = offset;
    if (startLocation+length > fileData.length) {
        length = fileData.length-startLocation;
    }
    NSData *subData = [fileData subdataWithRange:NSMakeRange(startLocation, length)];
    return subData;
}

- (NSData *)readChunkWithFilePath:(NSString *)filePath offset:(NSInteger)offset {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSInteger startLocation = offset;
    [handle seekToFileOffset:startLocation];
    NSData *subData = [handle readDataOfLength:[ThirdUpload instance].AlinyunBlockSize];
    [handle closeFile];
    return [subData copy];
}

@end
