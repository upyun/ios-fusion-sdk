//
//  QiniuUpload.m
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/15.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import "QiniuUpload.h"
#import "UPHTTPClient.h"
#import "UpSimpleHttpClient.h"
#import "UPMultipartBody.h"
#import "NSString+NSHash.h"
#import <UIKit/UIKit.h>

@interface QiniuUpload()
@property (nonatomic, assign) NSInteger dataLength;
@property (nonatomic, assign) NSInteger blockCount;
@property (nonatomic, copy) NSString *saveKey;
@property (nonatomic, copy) NSString *filePathURL;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) NSMutableArray *lastCtxOfChunkArray;
@property (nonatomic, strong) NSMutableArray *progressArray;
@end

@implementation QiniuUpload

- (void)QiniuUploadWithFileData:(NSData *)data
                      FilePath:(NSString *)filePath
                       SaveKey:(NSString *)savekey
                        success:(UpLoaderSuccessBlock)successBlock
                        failure:(UpLoaderFailureBlock)failureBlock
                       progress:(UpLoaderProgressBlock)progressBlock {
    if ([savekey rangeOfString:@"/"].location == 0) {
        savekey = [savekey substringFromIndex:1];
    }
    
    NSString *key = savekey;
    
    if ([ThirdUpload instance].QiniuUploadPath.length > 0) {
        key = [NSString stringWithFormat:@"%@%@", [ThirdUpload instance].QiniuUploadPath, savekey];
    }
    
    UPMultipartBody *multiBody = [[UPMultipartBody alloc]init];
    [multiBody addDictionary:@{@"token":[ThirdUpload instance].QiniuToken, @"key":key}];
    
    NSString *fileName = [filePath lastPathComponent];
    if (!fileName) {
        fileName = @"fileName";
    }
    [multiBody addFileData:data OrFilePath:filePath fileName:fileName fileType:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[ThirdUpload instance].QiniuUploadUrl]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [multiBody dataFromPart];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", multiBody.boundary] forHTTPHeaderField:@"Content-Type"];
    
    
    
    UPHTTPClient *client = [[UPHTTPClient alloc]init];

    [client uploadRequest:request success:^(NSURLResponse *response, id responseData) {
        if (successBlock) {
            successBlock((NSHTTPURLResponse *)response, responseData);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error, nil, nil);
        }
    } progress:progressBlock];


//    [client uploadRequest:request success:successBlock failure:failureBlock progress:httpProgress];
}


- (void)QiniuMutUploadWithFileData:(NSData *)data
                          FilePath:(NSString *)filePath
                           SaveKey:(NSString *)savekey
                           success:(UpLoaderSuccessBlock)successBlock
                           failure:(UpLoaderFailureBlock)failureBlock
                          progress:(UpLoaderProgressBlock)progressBlock {
    if ([savekey rangeOfString:@"/"].location == 0) {
        savekey = [savekey substringFromIndex:1];
    }
    
    NSString *key = savekey;
    
    if ([ThirdUpload instance].QiniuUploadPath.length > 0) {
        key = [NSString stringWithFormat:@"%@%@", [ThirdUpload instance].QiniuUploadPath, savekey];
    }
    
    _fileData = data;
    _filePathURL = filePath;
    _saveKey = key;
    _lastCtxOfChunkArray = [[NSMutableArray alloc]init];
    _progressArray = [[NSMutableArray alloc]init];
    _dataLength = _fileData.length;
    if (_filePathURL) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:_filePathURL error:nil];
        _dataLength = fileDictionary.fileSize;
    }
    _blockCount = ceil(_dataLength*1.0/[ThirdUpload instance].QiniuBlockSize);
    for (NSInteger i = 0; i < _blockCount; ++i) {
        [_lastCtxOfChunkArray addObject:[NSNull null]];
        [_progressArray addObject:@0];
    }
    for (int i=0; i < _blockCount; i++) {
        [self QiniuCreateBlockIndex:i success:successBlock failure:failureBlock progress:progressBlock];
    }
}

- (void)QiniuCreateBlockIndex:(NSInteger)index success:(UpLoaderSuccessBlock)successBlock
                      failure:(UpLoaderFailureBlock)failureBlock
                     progress:(UpLoaderProgressBlock)progressBlock {
    __weak typeof(self)weakSelf = self;
    //进度回调
    HttpProgressBlock httpProgress = ^(int64_t completedBytesCount, int64_t totalBytesCount) {
        
    };
    NSInteger blockSize = [ThirdUpload instance].QiniuBlockSize;
    NSInteger offset = index * blockSize;
    NSData *data;
    NSInteger blockLength = 0;
    if (_filePathURL) {
        data = [self readChunkWithFilePath:_filePathURL offset:offset];
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:_filePathURL error:nil];
        blockLength = MIN(blockSize, fileDictionary.fileSize - offset);
    } else {
        data = [self readChunkWithFileData:_fileData Offset:offset];
        blockLength = MIN(blockSize, _fileData.length - offset);
    }
    //成功回调
    HttpSuccessBlock httpSuccess = ^(NSURLResponse *response, id responseData) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSString *ctx = json[@"ctx"];
        NSNumber *nextChunkOffset = json[@"offset"];

        CGFloat percent = 1.0 /_blockCount*[ThirdUpload instance].QiniuChunkSize/[ThirdUpload instance].QiniuBlockSize;
        
        if (blockLength < [ThirdUpload instance].QiniuChunkSize) {
            percent = 1.0 /_blockCount;
            [_lastCtxOfChunkArray replaceObjectAtIndex:index withObject:ctx];
            if (![_lastCtxOfChunkArray containsObject:[NSNull null]]) {
                [weakSelf QiniuMakeFileSuccess:successBlock failure:failureBlock progress:progressBlock];
            }
        } else {
            [weakSelf QiniuUploadChunkBlockIndex:index Ctx:ctx NextChunkOffset:nextChunkOffset.longValue BlockLength:blockLength success:successBlock failure:failureBlock progress:progressBlock];
        }
        @synchronized(_progressArray) {
            _progressArray[index] = [NSNumber numberWithFloat:percent];
            float sumPercent = 0;
            for (NSNumber *num in _progressArray) {
                sumPercent += [num floatValue];
            }
            float totalPercent = sumPercent/_progressArray.count;
            if (progressBlock) {
                progressBlock(totalPercent, _dataLength);
            }
        }
    };
    
    //失败回调
    HttpFailBlock httpFail = ^(NSError * error) {
        
        
    };
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%ld", [ThirdUpload instance].QiniuCreateBlockUrl, (long)blockLength]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    [request setValue:[NSString stringWithFormat:@"UpToken %@", [ThirdUpload instance].QiniuToken] forHTTPHeaderField:@"Authorization"];
    
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    UPHTTPClient *client = [[UPHTTPClient alloc]init];
    [client uploadRequest:request success:httpSuccess failure:httpFail progress:httpProgress];
}

- (void)QiniuUploadChunkBlockIndex:(NSInteger)index Ctx:(NSString *)ctx NextChunkOffset:(NSInteger)nextChunkOffset BlockLength:(NSInteger) blockLength success:(UpLoaderSuccessBlock)successBlock
                           failure:(UpLoaderFailureBlock)failureBlock
                          progress:(UpLoaderProgressBlock)progressBlock {
    __weak typeof(self)weakSelf = self;
    //进度回调
    NSLog(@"QiniuUploadChunkBlockIndex ");
    HttpProgressBlock httpProgress = ^(int64_t completedBytesCount, int64_t totalBytesCount) {
        //        CGFloat percent = completedBytesCount/(float)totalBytesCount;
        //        if (_progressBlocker) {
        //            _progressBlocker(percent, totalBytesCount);
        //        }
    };
    //成功回调
    HttpSuccessBlock httpSuccess = ^(NSURLResponse *response, id responseData) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSString *ctx = json[@"ctx"];
        NSNumber *nextChunkOffset = json[@"offset"];
        
        CGFloat percent = 1.0/_blockCount * nextChunkOffset.longValue/blockLength;
        if (nextChunkOffset.longValue == blockLength) {
            [_lastCtxOfChunkArray replaceObjectAtIndex:index withObject:ctx];
            if (![_lastCtxOfChunkArray containsObject:[NSNull null]]) {
                
                [weakSelf QiniuMakeFileSuccess:successBlock failure:failureBlock progress:progressBlock];
            }
        } else {
            [weakSelf QiniuUploadChunkBlockIndex:index Ctx:ctx NextChunkOffset:nextChunkOffset.longValue BlockLength:blockLength success:successBlock failure:failureBlock progress:progressBlock];
        }
        
        @synchronized(_progressArray) {
            _progressArray[index] = [NSNumber numberWithFloat:percent];
            float sumPercent = 0;
            for (NSNumber *num in _progressArray) {
                sumPercent += [num floatValue];
            }
            float totalPercent = sumPercent;
            NSLog(@"totalPercent  %f", totalPercent);
            if (progressBlock) {
                progressBlock(totalPercent, _dataLength);
            }
        }
    };
    
    //失败回调
    HttpFailBlock httpFail = ^(NSError * error) {
        NSLog(@"UploadChunk error %@", error);
        //        if (retryTimes > 0 && error.code/100 == 5) {
        //            [weakSelf formUploadWithFileData:data FilePath:filePath SaveKey:savekey RetryTimes:retryTimes-1];
        //        } else {
        //            if (_failBlocker) {
        //                _failBlocker(error);
        //            }
        //        }
    };
    NSInteger blockSize = [ThirdUpload instance].QiniuBlockSize;
    
    NSInteger offset = index * blockSize + nextChunkOffset;
    NSData *data;

    if (_filePathURL) {
        data = [self readChunkWithFilePath:_filePathURL offset:offset];
    } else {
        data = [self readChunkWithFileData:_fileData Offset:offset];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%ld", [ThirdUpload instance].QiniuUploadChunkUrl, ctx, (long)nextChunkOffset]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    [request setValue:[NSString stringWithFormat:@"UpToken %@", [ThirdUpload instance].QiniuToken] forHTTPHeaderField:@"Authorization"];
    
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    UPHTTPClient *client = [[UPHTTPClient alloc]init];
    [client uploadRequest:request success:httpSuccess failure:httpFail progress:httpProgress];
}

- (void)QiniuMakeFileSuccess:(UpLoaderSuccessBlock)successBlock
                           failure:(UpLoaderFailureBlock)failureBlock
                          progress:(UpLoaderProgressBlock)progressBlock{

    //成功回调
    HttpSuccessBlock httpSuccess = ^(NSURLResponse *response, id responseData) {
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        if (successBlock) {
            NSDictionary *resonseDic = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            NSDictionary *result = @{@"response":response, @"responseData":resonseDic};
            successBlock((NSHTTPURLResponse *)response, result);
        }
    };
    
    //失败回调
    HttpFailBlock httpFail = ^(NSError *error) {
        NSLog(@"Make error %@", error);
        if (failureBlock) {
            failureBlock(error, nil, nil);
        }
    };
    
    NSString *lastCtxStrings = @"";
    for (NSString *lastCtx in _lastCtxOfChunkArray) {
        lastCtxStrings = [NSString stringWithFormat:@"%@,%@", lastCtxStrings, lastCtx];
    }
    if (lastCtxStrings.length > 0) {
        lastCtxStrings = [lastCtxStrings substringFromIndex:1];
    }

    NSData *data = [lastCtxStrings dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%ld/key/%@", [ThirdUpload instance].QiniuMakeFileUrl, (long)_dataLength, [_saveKey URLSafeBase64encode]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    [request setValue:[NSString stringWithFormat:@"UpToken %@", [ThirdUpload instance].QiniuToken] forHTTPHeaderField:@"Authorization"];
    
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    UPHTTPClient *client = [[UPHTTPClient alloc]init];
    [client uploadRequest:request success:httpSuccess failure:httpFail progress:nil];
}


- (NSData *)readChunkWithFileData:(NSData *)fileData Offset:(NSInteger)offset {
    
    NSInteger length = [ThirdUpload instance].QiniuChunkSize;
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
    NSData *subData = [handle readDataOfLength:[ThirdUpload instance].QiniuChunkSize];
    [handle closeFile];
    return [subData copy];
}


- (void)dealloc {
    NSLog(@"qiniu dealloc");
}

@end
