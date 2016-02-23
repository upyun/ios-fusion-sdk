# UPYUN iOS Fusion SDK
[![Build Status](https://travis-ci.org/upyun/ios-fusion-sdk.svg)](https://travis-ci.org/upyun/ios-fusion-sdk)
[![Latest Stable Version](https://img.shields.io/cocoapods/v/UPYUNFusion.svg)](https://github.com/upyun/ios-fusion-sdk/releases)
![Platform](http://img.shields.io/cocoapods/p/UPYUNFusion.svg)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](License.md)


#####UPYUN iOS Fusion SDK, 提供融合云存储功能, 在上传 UPYUN 服务器失败后会自动备份到第三方存储, 集成:
- [又拍云存储 表单 API接口](http://docs.upyun.com/api/form_api/) 
- [又拍云存储 分块上传接口](http://docs.upyun.com/api/multipart_upload/)
- [七牛云上传功能](http://developer.qiniu.com/docs/v6/api/reference/up/) 
- [阿里云上传功能](https://help.aliyun.com/document_detail/oss/sdk/ios-sdk/upload-object.html?spm=5176.docoss/sdk/ios-sdk/multipart-upload.6.294.vD6pEA)


## 运行环境

  iOS 7.0 及以上版本, ARC 模式, 采用 NSURLSession 做网络库 
>注: 因为 iOS 9 的 ATS , 如果碰到 SSL 错误, 请将上传 URL 设置为信任, 可以参考 [stackoverflow](http://stackoverflow.com/questions/32755674/ios9-getting-error-an-ssl-error-has-occurred-and-a-secure-connection-to-the-ser) 和 [iOS 9 AdaptationTips](https://github.com/ChenYilong/iOS9AdaptationTips#1-demo1_ios9%E7%BD%91%E7%BB%9C%E9%80%82%E9%85%8D_ats%E6%94%B9%E7%94%A8%E6%9B%B4%E5%AE%89%E5%85%A8%E7%9A%84https).



## 使用说明：
1.直接下载, 引入 `UPYUNSDK` 文件夹, 然后 CocoaPods  
        ```pod 'AliyunOSSiOS', '~> 2.2.0'``` , 之后 `#import "UpYun.h"` 即可使用
        
2.使用 CocoaPods ,  ```pod 'UPYUNFusion', '~> 1.0.1'``` , 之后 `#import "UpYun.h"` 即可使用
>注: 该项目依赖 AliyunOSSiOS


## 参数设置
在 `UPYUNConfig.m` 中可以对 SDK 的一些参数进行配置, 也可以通过 ``` [UPYUNConfig sharedInstance].DEFAULT_BUCKET ``` 来进行修改

* `DEFAULT_BUCKET` : 默认空间名（必填项）, 
* `DEFAULT_PASSCODE` : 默认表单 API 功能密钥 , 用户从服务端获取 `signature` 则无须填写
* `DEFAULT_EXPIRES_IN` : 默认当前上传授权的过期时间，单位为“秒” （必填项，较大文件需要较长时间)
* `DEFAULT_RETRY_TIMES` : 失败之后重传次数, 默认 2 次
* `SingleBlockSize` : 单个分块大小, 默认 500 KB
* `thirdUpload` :  在上传 `UPYUN` 失败之后, 选择七牛还是阿里云进行容灾上传; `kQiniuUpload` 使用七牛, `kAliyunUPload`  使用阿里云 

* `QiniuToken` : 七牛的上传 `token` , 详细参考[七牛安全机制](http://developer.qiniu.com/docs/v6/api/reference/security/) 
 
* `AliyunBucket` : 阿里云的 `Bucket`
* `AliyunAccessKey` : 阿里云的 `AccessKey`
* `AliyunSecretKey` : 阿里云的 `SecretKey`


**注1: 如果使用融合云存储功能，阿里和七牛的配置必选其一**

**注2: 如果需要在上传的过程中不断变动一些参数值, 建议初始化 `UpYun` 之后, 通过 `UpYun` 的属性来修改**


## 上传接口

> 详细示例请见 UpYunFusionSDKDemo 的 `Viewcontroller` 和 `UpYunFusionSDKDemoTests` 。

### 文件上传

````
UpYun *uy = [[UpYun alloc] init];
uy.successBlocker = ^(NSURLResponse *response, id responseData) {
  //TODO
};
uy.failBlocker = ^(NSError * error) {
  //TODO
};
uy.progressBlocker = ^(CGFloat percent,long long requestDidSendBytes) {
  //TODO
};

[uy.params setObject:@"value" forKey:@"key"];
uy.uploadMethod = UPFormUpload;

[uy uploadFile:'file' saveKey:'saveKey'];
````


### 参数说明：

#### 1、`file` 需要上传的文件
* 可传入类型：
 * `NSData`: 文件数据
 * `NSString`: 本地文件路径
 * `UIImage`: 传入的图片 (*当以此类型传入图片时，都会转成PNG数据，需要其他格式请先转成 `NSData` 传入 或者 传入文件路径 `NSString`*)

#### 2、`saveKey` 要保存到又拍云存储的具体地址
* 可传入类型：
 * `NSString`: 要保存到又拍云存储的具体地址
* 由开发者自己生成 saveKey :
  * 比如 `/dir/sample.jpg`表示以`sample.jpg` 为文件名保存到 `/dir` 目录下；
  * 若保存路径为 `/sample.jpg` , 则表示保存到根目录下；
  * **注意 `saveKey` 的路径必须是以`/`开始的**


#### 3、`successBlocker` 上传成功回调
* 回调中的参数：
  * `response`: 成功后服务器返回的信息响应
  * `responseData`: 成功后服务器返回的数据 `body` (JSON)格式

#### 4、`failBlocker` 上传失败回调
* 回调中的参数：
  * `error`: 失败后返回的错误信息

#### 5、`progressBlocker` 上传进度回调
* 回调中的参数：
  * `percent`: 上传进度的百分比
  * `requestDidSendBytes`: 已经发送的数据量
 
#### 6、`signatureBlocker` 用户获取 signature 回调
* 回调中的参数：
  * `policy`: 经过处理的 policy 字符串, 用户可以直接上传到用户服务端与 `密钥` 拼接, 
* 返回的参数：
  * `sinature`: 用户服务端使用上传的 `policy` 生成的 sinature , 或者用户自己生成 `sinature`
 
#### 7、`params` [可选参数](http://docs.upyun.com/api/form_api/#api_1)

#### 8、`uploadMethod` 上传方法选择
* 默认根据文件大小选择表单还是分块上传, 可以通过 `uy.uploadMethod = UPFormUpload` 来选择表单上传, `uy.uploadMethod = UPMUtUPload` 来选择分块上传.



### 错误代码
* `-1997`: 参数 `filepath` , 找不到文件
* `-1998`: 参数 `file` 以 `UIImage` 、 `NSData` 类型传入时, `saveKey` 带有 `{filename}` 
* `-1999`: 参数 `file `以 `UIImage` 、 `NSData`、 `NSString` 外的类型传入
* 其他错误代码详见 [表单API错误代码表](http://docs.upyun.com/api/errno/)
