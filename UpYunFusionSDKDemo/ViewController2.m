//
//  ViewController2.m
//  upyundemo
//
//  Created by andy yao on 12-6-14.
//  Copyright (c) 2012年 upyun.com. All rights reserved.
//

#import "ViewController2.h"
#import "ThirdUpload.h"
#import "UpYunFormUploader.h" //图片，小文件，短视频
#import "UpYunBlockUpLoader.h" //分块上传，适合大文件上传
#import "UpYunFileDealManger.h" // 文件处理任务


@interface ViewController2 ()
@property (strong, nonatomic) UIButton *uploadBtn;
@end

@implementation ViewController2
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [ThirdUpload instance].thirdUploadMethod = kAliyunUPload;
    
    /// 七牛的 token
    [ThirdUpload instance].QiniuToken = @"#token#";
    /// 七牛上传的路径.    方式为   dir/XXX/XXX/ 可不设置, 默认为根目录
//    [ThirdUpload instance].QiniuUploadPath = @"img/qiniu/";
    
    /// 阿里云上传的路径.    方式为   dir/XXX/XXX/ 可不设置, 默认为根目录
//    [ThirdUpload instance].AliyunUploadPath = @"img/aliyun/";
    /// 阿里云的上传空间名
    [ThirdUpload instance].AliyunBucket = @"#bucket#";
    
    /// 阿里云的上传 AK, 注意: 如果通过服务的获取, 请参考阿里云官方文档, 修改 AliyunUpload initOSSClient 方法
    [ThirdUpload instance].AliyunAccessKey = @"#AK#";
    /// 阿里云的上传 SK
    [ThirdUpload instance].AliyunSecretKey = @"#SK#";
    
    
    self.uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 200, 44)];
    self.uploadBtn.backgroundColor = [UIColor lightGrayColor];
    [self.uploadBtn setTitle:@"upload"
               forState:UIControlStateNormal];
    [self.uploadBtn addTarget:self
                  action:@selector(uploadBtntap:)
        forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.uploadBtn];
}

- (void)uploadBtntap:(id)sender {
    /*注意: 相关的文件处理只会上传到 UPYUN 成功时进行处理, 如果是上传到 阿里云 或 七牛, 不做任何处理*/
    
    [self testFormUploader1];             //本地签名的表单上传
//    [self testFormUploader2];             //服务器端签名的表单上传（模拟）
//    [self testBlockUpLoader1];            //断点续传
//    [self testBlockUpLoader2];            //断点续传 后异步处理
    
    
//    [self testFormUploaderAndAsyncTask];  //表单上传加异步多媒体处理－－视频截图
//    [self testFormUploaderAndSyncTask];   //表单上传加同步图片处理－－图片水印
//    [self testFileDeal];                  // 文件异步处理请求
    
}

- (void)testFileDeal {
    UpYunFileDealManger *up = [[UpYunFileDealManger alloc] init];
    
    
    NSMutableArray *tasks = [NSMutableArray array];
    
    NSDictionary *taksOne =@{@"type": @"thumbnail", @"avopts": @"/o/true/n/1/ss/00:00:05",
                             @"notify_url": @"http://124.160.114.202:18989/echo",
                                                       @"save_as": @"ios_sdk_new_video_1.jpg"};
    NSDictionary *taksTwo =@{@"type": @"thumbnail", @"avopts": @"/o/true/n/1/ss/00:00:11",
                             @"notify_url": @"http://124.160.114.202:18989/echo",
                             @"save_as": @"ios_sdk_new_video_2.jpg"};
    
    [tasks addObject:taksOne];
    
    [tasks addObject:taksTwo];
    
    [up dealTaskWithBucketName:@"test86400" operator:@"operator123" password:@"password123" notify_url:@"http://124.160.114.202:18989/echo" source:@"/123.mp4" tasks:tasks success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
        
        NSLog(@"response--%@", response);
        NSLog(@"上传成功 responseBody：%@", responseBody);
        
    } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
         NSLog(@"失败---");
        NSLog(@"上传失败 error：%@", error);
        NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
        NSLog(@"上传失败 message：%@", responseBody);
    }];
}


//本地签名的表单上传。
- (void)testFormUploader1 {
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"image.jpg"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
    
    NSString *bucketName = @"test86400";
    [up uploadWithBucketName:bucketName
                    operator:@"operator123"
                    password:@"password123"
                    fileData:fileData
                    fileName:nil
                     saveKey:@"ios_sdk_new/img.jpg"
             otherParameters:nil
                     thirdSuccess:^(ThirdUploadMethod thirdUpload, NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         switch (thirdUpload) {
                             case kNoneThirdUpload:
                                 NSLog(@"上传成功 responseBody：%@", responseBody);
                                 NSLog(@"file url：https://%@.b0.upaiyun.com/%@", bucketName, [responseBody objectForKey:@"url"]);
                                 break;
                             case kQiniuUpload:
                                 NSLog(@"容灾七牛云成功");
                                 
                                 break;
                             case kAliyunUPload:
                                 NSLog(@"容灾阿里云成功");
                                 break;
                         }
                         //主线程刷新ui
                     }
                     failure:^(NSError *error,
                               NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         NSLog(@"上传失败 error：%@", error);
                         NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
                         NSLog(@"上传失败 message：%@", responseBody);
                         //主线程刷新ui
                         dispatch_async(dispatch_get_main_queue(), ^(){
                             NSString *message = [responseBody objectForKey:@"message"];
                             if (!message) {
                                 message = [NSString stringWithFormat:@"%@", error.localizedDescription];
                             }
                             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"上传失败!"
                                                                                            message:message
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                                     style:UIAlertActionStyleDefault
                                                                                   handler:nil];
                             [alert addAction:defaultAction];
                             [self presentViewController:alert animated:YES completion:nil];
                         });
                     }
     
                    progress:^(int64_t completedBytesCount,
                               int64_t totalBytesCount) {
                        NSString *progress = [NSString stringWithFormat:@"%lld / %lld", completedBytesCount, totalBytesCount];
                        NSString *progress_rate = [NSString stringWithFormat:@"upload %.1f %%", 100 * (float)completedBytesCount / totalBytesCount];
                        NSLog(@"upload progress: %@", progress);
                       
                        //主线程刷新ui
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [self.uploadBtn setTitle:progress_rate forState:UIControlStateNormal];
                        });
                    }];

}

//服务器端签名的表单上传（模拟）
- (void)testFormUploader2 {
    //从 app 服务器获取的上传策略 policy
    NSString *policy = @"eyJleHBpcmF0aW9uIjoxNDg5Mzc4NjExLCJyZXR1cm4tdXJsIjoiaHR0cGJpbi5vcmdcL3Bvc3QiLCJidWNrZXQiOiJmb3JtdGVzdCIsInNhdmUta2V5IjoiXC91cGxvYWRzXC97eWVhcn17bW9ufXtkYXl9XC97cmFuZG9tMzJ9ey5zdWZmaXh9In0=";
    
    //从 app 服务器获取的上传策略签名 signature
    NSString *signature = @"BIC22iXgu5fBUXgoMGGpdWNpsak=";
    
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"picture.jpg"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
    
    NSString *operatorName = @"one";
    [up uploadWithOperator:operatorName
                    policy:policy
                 signature:signature
                  fileData:fileData
                  fileName:nil
                   thirdSuccess:^(ThirdUploadMethod thirdUpload, NSHTTPURLResponse *response,
                             NSDictionary *responseBody) {
                       switch (thirdUpload) {
                           case kNoneThirdUpload:
                               NSLog(@"上传成功 responseBody：%@", responseBody);
                               
                               break;
                           case kQiniuUpload:
                               NSLog(@"容灾七牛云成功");
                               
                               break;
                           case kAliyunUPload:
                               NSLog(@"容灾阿里云成功");
                               break;
                       }
                   }
     
                   failure:^(NSError *error,
                             NSHTTPURLResponse *response,
                             NSDictionary *responseBody) {
                       NSLog(@"上传失败 error：%@", error);
                       NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
                       NSLog(@"上传失败 message：%@", responseBody);
                       //主线程刷新ui
                   }
     
                  progress:^(int64_t completedBytesCount,
                             int64_t totalBytesCount) {
                      NSLog(@"upload progress: %lld / %lld", completedBytesCount, totalBytesCount);
                      //主线程刷新ui
                  }];
}

//分块上传


- (void)testBlockUpLoader1{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"test2.png"];
    
    UpYunBlockUpLoader *up = [[UpYunBlockUpLoader alloc] init];
    NSString *bucketName = @"test86400";
    NSString *savePath = @"ios_upload_task_img_test2.png";
    
    [up uploadWithBucketName:bucketName
                    operator:@"operator123"
                    password:@"password123"
                    filePath:filePath
                    savePath:savePath
                     thirdSuccess:^(ThirdUploadMethod thirdUpload, NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         switch (thirdUpload) {
                             case kNoneThirdUpload:
                                 NSLog(@"上传成功 responseBody：%@", responseBody);
                                 break;
                             case kQiniuUpload:
                                 NSLog(@"容灾七牛云成功");
                                 
                                 break;
                             case kAliyunUPload:
                                 NSLog(@"容灾阿里云成功");
                                 break;
                         }

                     }
                     failure:^(NSError *error,
                               NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         NSLog(@"上传失败 error：%@", error);
                         NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
                         NSLog(@"上传失败 message：%@", responseBody);
                         //主线程刷新ui
                     }
                    progress:^(int64_t completedBytesCount,
                               int64_t totalBytesCount) {
                        NSString *progress = [NSString stringWithFormat:@"%lld / %lld", completedBytesCount, totalBytesCount];
                        NSString *progress_rate = [NSString stringWithFormat:@"upload %.1f %%", 100 * (float)completedBytesCount / totalBytesCount];
                        NSLog(@"upload progress: %@", progress);
                        
                        //主线程刷新ui
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [self.uploadBtn setTitle:progress_rate forState:UIControlStateNormal];
                        });
                    }];
}

/// 上传之后进行文件处理操作
- (void)testBlockUpLoader2{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"video.mp4"];
    
    
    NSMutableArray *tasks = [NSMutableArray array];
    /// task 的相关参数, 见
    NSDictionary *taksOne =@{@"type": @"thumbnail", @"avopts": @"/o/true/n/1/ss/00:00:02",
                             @"save_as": @"ios_sdk_new_video_3.jpg"};
    NSDictionary *taksTwo =@{@"type": @"thumbnail", @"avopts": @"/o/true/n/1/ss/00:00:03",
                             @"save_as": @"ios_sdk_new_video_4.jpg"};
    
    [tasks addObject:taksOne];
    
    [tasks addObject:taksTwo];
    
    NSString *notif_url = @"http://124.160.114.202:18989/echo";
    
    
    UpYunBlockUpLoader *up = [[UpYunBlockUpLoader alloc] init];
    NSString *bucketName = @"test86400";
    NSString *savePath = @"ios_upload_task_video.mp4";
    
    [up uploadWithBucketName:bucketName
                    operator:@"operator123"
                    password:@"password123"
                    filePath:filePath
                    savePath:savePath
                  notify_url:notif_url
                       tasks:tasks
                     thirdSuccess:^(ThirdUploadMethod thirdUpload, NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         switch (thirdUpload) {
                             case kNoneThirdUpload:
                                 NSLog(@"上传成功 responseBody：%@", responseBody);
                                 break;
                             case kQiniuUpload:
                                 NSLog(@"容灾七牛云成功");
                                 
                                 break;
                             case kAliyunUPload:
                                 NSLog(@"容灾阿里云成功");
                                 break;
                         }
                         
                     }
                     failure:^(NSError *error,
                               NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         
                         
                         NSLog(@"上传失败 error：%@", error);
                         NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
                         NSLog(@"上传失败 message：%@", responseBody);
                         //主线程刷新ui
                         
                     }
                    progress:^(int64_t completedBytesCount,
                               int64_t totalBytesCount) {
                        NSString *progress = [NSString stringWithFormat:@"%lld / %lld", completedBytesCount, totalBytesCount];
                        NSString *progress_rate = [NSString stringWithFormat:@"upload %.1f %%", 100 * (float)completedBytesCount / totalBytesCount];
                        NSLog(@"upload progress: %@", progress);
                        
                        //主线程刷新ui
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [self.uploadBtn setTitle:progress_rate forState:UIControlStateNormal];
                        });
                    }];
}

//表单上传加异步视频处理－－视频截图
- (void)testFormUploaderAndAsyncTask {
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"video.mp4"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
    
    //异步视频截图处理。更详细参数参考：云处理文档－音视频处理－视频截图 http://docs.upyun.com/cloud/av/#_16
    NSDictionary *asycTask = @{@"name": @"naga",@"type": @"thumbnail",
                               @"save_as": @"ios_sdk_new/test2/video.jpg",
                               @"avopts": @"/o/true/n/1/",
                               @"notify_url": @"http://124.160.114.202:18989/echo"};
    NSArray *apps = @[asycTask];
    
    NSString *bucketName = @"test86400";
    [up uploadWithBucketName:bucketName
                    operator:@"operator123"
                    password:@"password123"
                    fileData:fileData
                    fileName:nil
                     saveKey:@"ios_sdk_new/test2/video.mp4"
             otherParameters:@{@"apps": apps}
                     thirdSuccess:^(ThirdUploadMethod thirdUpload, NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         NSLog(@"上传成功 responseBody：%@", responseBody);
                         NSLog(@"file url：https://%@.b0.upaiyun.com/%@", bucketName, [responseBody objectForKey:@"url"]);
                         //主线程刷新ui
                     }
                     failure:^(NSError *error,
                               NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         NSLog(@"上传失败 error：%@", error);
                         NSLog(@"上传失败 responseBody：%@", responseBody);
                         NSLog(@"上传失败 message：%@", [responseBody objectForKey:@"message"]);
                         //主线程刷新ui
                         dispatch_async(dispatch_get_main_queue(), ^(){
                             NSString *message = [responseBody objectForKey:@"message"];
                             if (!message) {
                                 message = [NSString stringWithFormat:@"%@", error.localizedDescription];
                             }
                             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"上传失败!"
                                                                                            message:message
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                                     style:UIAlertActionStyleDefault
                                                                                   handler:nil];
                             [alert addAction:defaultAction];
                             [self presentViewController:alert animated:YES completion:nil];
                         });
                     }
     
                    progress:^(int64_t completedBytesCount,
                               int64_t totalBytesCount) {
                        NSString *progress = [NSString stringWithFormat:@"%lld / %lld", completedBytesCount, totalBytesCount];
                        NSString *progress_rate = [NSString stringWithFormat:@"upload %.1f %%", 100 * (float)completedBytesCount / totalBytesCount];
                        NSLog(@"upload progress: %@", progress);
                        
                        //主线程刷新ui
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [self.uploadBtn setTitle:progress_rate forState:UIControlStateNormal];
                        });
                    }];
}

//表单上传加同步图片处理－－图片水印
- (void)testFormUploaderAndSyncTask {
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"picture.jpg"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
    
    NSString *bucketName = @"test86400";
    
    //同步图片水印处理。更详细参数参考：云处理文档－图片处理－上传预处理 http://docs.upyun.com/cloud/image/#function

    NSString *watermark = @"这是水印";
    //需要转换为 base64 编码
    NSData *encodeData = [watermark dataUsingEncoding:NSUTF8StringEncoding];
    NSString *watermark_base64 = [encodeData base64EncodedStringWithOptions:0];
    
    [up uploadWithBucketName:bucketName
                    operator:@"operator123"
                    password:@"password123"
                    fileData:fileData
                    fileName:nil
                     saveKey:@"ios_sdk_new/test2/picture.jpg"
             otherParameters:@{@"x-gmkerl-thumb": [NSString stringWithFormat:@"/watermark/text/%@/color/FFFFFF/align/south", watermark_base64]}
                     thirdSuccess:^(ThirdUploadMethod thirdUpload, NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         NSLog(@"上传成功 responseBody：%@", responseBody);
                         NSLog(@"file url：https://%@.b0.upaiyun.com/%@", bucketName, [responseBody objectForKey:@"url"]);
                         //主线程刷新ui
                     }
                     failure:^(NSError *error,
                               NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         NSLog(@"上传失败 error：%@", error);
                         NSLog(@"上传失败 responseBody：%@", responseBody);
                         NSLog(@"上传失败 message：%@", [responseBody objectForKey:@"message"]);
                         //主线程刷新ui
                         dispatch_async(dispatch_get_main_queue(), ^(){
                             NSString *message = [responseBody objectForKey:@"message"];
                             if (!message) {
                                 message = [NSString stringWithFormat:@"%@", error.localizedDescription];
                             }
                             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"上传失败!"
                                                                                            message:message
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                                     style:UIAlertActionStyleDefault
                                                                                   handler:nil];
                             [alert addAction:defaultAction];
                             [self presentViewController:alert animated:YES completion:nil];
                         });
                     }
     
                    progress:^(int64_t completedBytesCount,
                               int64_t totalBytesCount) {
                        NSString *progress = [NSString stringWithFormat:@"%lld / %lld", completedBytesCount, totalBytesCount];
                        NSString *progress_rate = [NSString stringWithFormat:@"upload %.1f %%", 100 * (float)completedBytesCount / totalBytesCount];
                        NSLog(@"upload progress: %@", progress);
                        
                        //主线程刷新ui
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [self.uploadBtn setTitle:progress_rate forState:UIControlStateNormal];
                        });
                    }];
}

@end
