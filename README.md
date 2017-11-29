# UPYUN iOS Fusion SDK
[![Build Status](https://travis-ci.org/upyun/ios-fusion-sdk.svg)](https://travis-ci.org/upyun/ios-fusion-sdk)
[![Latest Stable Version](https://img.shields.io/cocoapods/v/UPYUNFusion.svg)](https://github.com/upyun/ios-fusion-sdk/releases)
![Platform](http://img.shields.io/cocoapods/p/UPYUNFusion.svg)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](License.md)


#####UPYUN iOS Fusion SDK, 提供融合云存储功能, 与 UPYUN 服务器连接不稳定时自动备份到第三方存储, 集成:
- [又拍云存储 表单 API接口](http://docs.upyun.com/api/form_api/) 
- [又拍云存储 分块上传接口](http://docs.upyun.com/api/rest_api/#_3)
- [七牛云上传功能](http://developer.qiniu.com/docs/v6/api/reference/up/) 
- [阿里云上传功能](https://help.aliyun.com/document_detail/oss/sdk/ios-sdk/upload-object.html?spm=5176.docoss/sdk/ios-sdk/multipart-upload.6.294.vD6pEA)


## 运行环境

  iOS 7.0 及以上版本, ARC 模式, 采用 NSURLSession 做网络库 
>注: 因为 iOS 9 的 ATS , 如果碰到 SSL 错误, 请将上传 URL 设置为信任, 可以参考 [stackoverflow](http://stackoverflow.com/questions/32755674/ios9-getting-error-an-ssl-error-has-occurred-and-a-secure-connection-to-the-ser) 和 [iOS 9 AdaptationTips](https://github.com/ChenYilong/iOS9AdaptationTips#1-demo1_ios9%E7%BD%91%E7%BB%9C%E9%80%82%E9%85%8D_ats%E6%94%B9%E7%94%A8%E6%9B%B4%E5%AE%89%E5%85%A8%E7%9A%84https).



## 使用说明：
1.直接下载, 引入 `UPYUNSDK` 文件夹, 然后 `#import "UpYun.h"` `#import "ThirdUpload.h"` 即可使用
        


## 参数设置


在 `ThirdUpload` 中可以对 SDK 的一些参数进行配置

* `thirdUploadMethod` :  在上传 `UPYUN` 失败之后, 选择七牛还是阿里云进行容灾上传; `kQiniuUpload` 使用七牛, `kAliyunUPload`  使用阿里云 

* `QiniuUploadPath` 所有容灾七牛上传的路径. 不设置时默认为根目录
* `QiniuToken` : 七牛的上传 `token` , 详细参考[七牛安全机制](http://developer.qiniu.com/docs/v6/api/reference/security/) 
 
* `AliyunUploadPath` 所有容灾阿里云上传的路径. 不设置时默认为根目录
* `AliyunBucket` : 阿里云的 `Bucket`
* `AliyunAccessKey` : 阿里云的 `AccessKey`
* `AliyunSecretKey` : 阿里云的 `SecretKey`


**注1: 如果使用融合云存储功能，阿里和七牛的配置必选其一**

**注2: 如果需要在上传的过程中不断变动一些参数值, 建议初始化 `UpYun` 之后, 通过 `UpYun` 的属性来修改**


## 上传接口

> 详细示例请见 UpYunFusionSDKDemo 的 `Viewcontroller2` 中的演示方法

````
	[self testFormUploader1];    //本地签名的表单上传
	[self testFormUploader2];   //服务器端签名的表单上传（模拟）
 	[self testBlockUpLoader1];  //断点续传
	......

````

### 表单上传

````
	UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
	[up uploadWithBucketName:#bucketName#
                    operator:#operator#
                    password:#password#
                    fileData:#fileData#
                    fileName:#fileName#
                     saveKey:#saveKey#
                     thirdSuccess:thirdSuccessBlock
                     failure:failureBlock
                    progress:progressBlock];
````
### 断点/分开 上传

````
	UpYunBlockUpLoader *up = [[UpYunBlockUpLoader alloc] init];
	[up uploadWithBucketName:#bucketName#
                    operator:#operator#
                    password:#password#
                    filePath:#filePath#
                    savePath:#savePath#
                     thirdSuccess:thirdSuccessBlock
                     failure:failureBlock
                    progress:progressBlock];
````


### 参数说明：



#### 1、`saveKey` 要保存到又拍云存储的具体地址
* 可传入类型：
 * `NSString`: 要保存到又拍云存储的具体地址
* 由开发者自己生成 saveKey :
  * 比如 `/dir/sample.jpg`表示以`sample.jpg` 为文件名保存到 `/dir` 目录下；
  * 若保存路径为 `/sample.jpg` , 则表示保存到根目录下；
  * **注意 `saveKey` 的路径必须是以`/`开始的**


#### 2、`successBlocker` 上传成功回调
* 回调中的参数：
  * `response`: 成功后服务器返回的信息响应
  * `responseData`: 成功后服务器返回的数据 `body` (JSON)格式

#### 3、`failBlocker` 上传失败回调
* 回调中的参数：
  * `error`: 失败后返回的错误信息

#### 4、`progressBlocker` 上传进度回调
* 回调中的参数：
  * `percent`: 上传进度的百分比
  * `requestDidSendBytes`: 已经发送的数据量
 
 
#### 5、`params` [可选参数](http://docs.upyun.com/api/form_api/#api_1)




### 错误代码

* 错误代码详见 [表单API错误代码表](http://docs.upyun.com/api/errno/)
