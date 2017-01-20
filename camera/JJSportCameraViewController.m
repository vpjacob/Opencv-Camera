//
//  JJSportCameraViewController.m
//  camera
//
//  Created by 董建新 on 2016/11/16.
//  Copyright © 2016年 董建新. All rights reserved.
/*
 
 双目视觉的三维重构
 必看<<opencv2 计算机视觉编程手册>> */

#import "JJSportCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "ConverseController.h"
#import "SVProgressHUD.h"

#define JJSportCaptureAnimation 0.25
#define SCREENW 375
#define SCREENH 667



@interface JJSportCameraViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *waterImage;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
/**
 预览视图
 */
@property (strong, nonatomic) UIView *preview;
/**
 快门按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *capButton;
/**
 旋转和分享按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *rotateShareButton;

//位置管理者
@property (nonatomic, strong) CMMotionManager *mgr;

/**
 旋转速率
 */
@property (assign, nonatomic) CMRotationRate rotationRate;

/**
 X\Y\Z的数值
 */
@property (nonatomic, assign) CGFloat xPoint;
@property (nonatomic, assign) CGFloat yPoint;
@property (nonatomic, assign) CGFloat zPoint;

/**
 arImageview
 */
@property (nonatomic, strong) UIImageView* arImageView;

/**
 小红点数组
 */
@property (strong, nonatomic) NSMutableArray<UIView* > *viewArray;

/**
 绿点数组
 */
@property (strong, nonatomic) NSMutableArray<UIView *> *greenViews;


/**
 记录小红点的数值
 */
@property (assign, nonatomic) NSInteger ViewCount;

/**
 图片数组
 */
@property (strong, nonatomic) NSMutableArray<UIImage *> *imagesArray;

@end

@implementation JJSportCameraViewController{
    
    // 四大对象
    //  拍摄会话
    AVCaptureSession* _captureSession;
    //输出设备-摄像头
    AVCaptureDeviceInput* _inputDevice;
    //  图像输出
    AVCaptureStillImageOutput* _imageOutput;
    //  取景框
    AVCaptureVideoPreviewLayer* _previewLayer;
    
    //  拍摄完成的图像
    UIImage* _capturePicture;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
#pragma mark - 实例化对象
    
    _viewArray = [NSMutableArray array];
    _greenViews = [NSMutableArray array];
    _imagesArray = [NSMutableArray array];
    
    
    self.preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 537)];
    
    self.preview.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:_preview];
    
    
    //创建运动管理者
    self.mgr = [[CMMotionManager alloc] init];
    
    [self setupCaptureSession];
    
    [self addpoint];
    
    [self test];
    
    self.ViewCount = 24;
    
    
    ///  半透明视图
    UIView *alpatView = [[UIView alloc] init];
    
    alpatView.backgroundColor = [UIColor redColor];
    
    alpatView.alpha = 0.5;
    
    alpatView.center = self.preview.center;
    
    alpatView.bounds = CGRectMake(0, 0, 20, 20);
    
    alpatView.layer.cornerRadius = 10;
    alpatView.layer.masksToBounds = YES;
    
    
    [self.preview addSubview:alpatView];
    
    
}


//  旋转摄像touch
- (IBAction)switchCamera{
    
    [SVProgressHUD show];
    
    ConverseController* converse = [[ConverseController alloc] init];
    
    converse.view.backgroundColor = [UIColor whiteColor];
    
    converse.imageArray = self.imagesArray;
    
    //   当dissmiss后  继续dismiss
    
    __weak typeof(self)weakSelf = self;
    
    converse.restartBlock = ^{
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
    };
    
    [weakSelf presentViewController:converse animated:YES completion:nil];
    
    
    
}




#pragma mark - 红点相关
-(void)test{
    
    __weak typeof(self) weakself = self;
    
    if (weakself.mgr.deviceMotionAvailable) {
        
        [weakself.mgr startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            
            weakself.rotationRate = motion.rotationRate;
            
            
            weakself.yPoint = weakself.rotationRate.y * -7;
            weakself.xPoint = weakself.rotationRate.x * -7;
            weakself.zPoint = weakself.rotationRate.z * -7;
            
            
            ///  进行遍历改变坐标
            [weakself.viewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGRect viewFrame = obj.frame;
                viewFrame.origin.x -= weakself.yPoint;
                viewFrame.origin.y -= weakself.xPoint;
                
                obj.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
                
                //  红点 arimage   preview是中心点
                if (   obj.center.x > weakself.preview.bounds.size.width/2 - 20
                    && obj.center.x < weakself.preview.bounds.size.width/2 + 20
                    && obj.center.y > weakself.preview.bounds.size.height/2 - 20
                    && obj.center.y < weakself.preview.bounds.size.height/2 + 20
                    ) {
                    
                    
                    
                    
                    
                    [obj removeFromSuperview];
                    
                    [weakself.viewArray removeObject:obj];
                    
                    NSLog(@"%zd",weakself.viewArray.count);
                    
                    @synchronized (weakself) {
                        
                        // 如果数量有减少，那么就拍个照
                        weakself.ViewCount - weakself.viewArray.count == 0 ?nil:[weakself countTakePhoto:obj.frame];
                        
                    }
                    
                }
                
            }];
            
            
            
            //  小绿点进行遍历
            [weakself.greenViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGRect viewFrame = obj.frame;
                viewFrame.origin.x -= weakself.yPoint;
                viewFrame.origin.y -= weakself.xPoint;
                
                obj.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
                
                
            }];
            
            
            
            
        }
         ];
    }
    
}


NSInteger ii = 0;

-(void)countTakePhoto:(CGRect)viewRect{
    
    UIView * greenView = [[UIView alloc] init];
    
    greenView.frame = viewRect;
    
    greenView.backgroundColor = [UIColor greenColor];
    
    [self.preview addSubview:greenView];
    [self.greenViews addObject:greenView];
    
    self.ViewCount --;
    
    [self capturePciture];
    
    NSLog(@"paizhao %zd",++ii);
}



#pragma mark - 添加12个红点
-(void)addpoint{
    
    NSInteger maxPoint = 26;
    
          for (NSInteger i = 0; i < maxPoint; i++) {
            
            UIView* redview1 = [[UIView alloc] init];
            redview1.backgroundColor = [UIColor redColor];
            
//            UIView* redview2 = [[UIView alloc] init];
//            redview2.backgroundColor = [UIColor redColor];
//            
//            UIView* redview3 = [[UIView alloc] init];
//            redview3.backgroundColor = [UIColor redColor];
            
//            if (i< maxPoint * 0.5) {
              
                redview1.frame = CGRectMake(SCREENW * 0.2 + self.preview.bounds.size.width * 0.5 * i, self.preview.bounds.size.height * 0.5, 20, 20);
                
//                redview2.frame = CGRectMake(SCREENW * 0.2 + self.preview.bounds.size.width * 0.5 * i, 0, 20, 20);
//                
//                redview3.frame = CGRectMake(SCREENW * 0.2 + self.preview.bounds.size.width * 0.5 * i, self.preview.bounds.size.height, 20, 20);
                
                
                
//            }else{
              
//                redview1.frame = CGRectMake(SCREENW * 0.2 - self.preview.bounds.size.width * 0.5 * (i - maxPoint * 0.5), self.preview.bounds.size.height * 0.5, 20, 20);
              
//                redview2.frame = CGRectMake(SCREENW * 0.2 - self.preview.bounds.size.width * 0.5 * (i - maxPoint * 0.5), 0, 20, 20);
//                
//                redview3.frame = CGRectMake(SCREENW * 0.2 - self.preview.bounds.size.width * 0.5 * (i - maxPoint * 0.5), self.preview.bounds.size.height, 20, 20);
                
                
                
//            }

            
                
                [self.preview addSubview:redview1];
                [self.viewArray addObject:redview1];
                
            
            
//                //  进行优化，上下各减少三分之一的红点
//                if (i % 2 == 0) {
//                    continue;
//                }
//                
//                
//                [self.preview addSubview:redview2];
//                [self.viewArray addObject:redview2];
//                
//                [self.preview addSubview:redview3];
//                [self.viewArray addObject:redview3];
              
            
        }
            
        
    

    
}

//  点击拍照进行转换
- (IBAction)capture {
    
    //  拍照和保存---》重启会话
    [self capturePciture];
    
    
}



/**
 当dismiss后  将数组清空
 */
-(void)dealloc{
    
    
    [self.viewArray removeAllObjects];
    [self.greenViews removeAllObjects];
    
    
    [self.imagesArray removeAllObjects];
    
    
    NSLog(@"%zd",self.viewArray.count);
    NSLog(@"%zd",self.greenViews.count);
    
    [_captureSession stopRunning];
}

- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


//  拍照
-(void)capturePciture{
    
    //  表示图像和摄像头的连接
    AVCaptureConnection* conn = _imageOutput.connections.firstObject;
    
    //  判断conn是不是空
    if (conn == nil) {
        NSLog(@"无法连接到摄像头");
        return;
    }
    
    //  拍摄照片
    [_imageOutput captureStillImageAsynchronouslyFromConnection:conn completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        //  判断是否有图像数据的采集
        if (imageDataSampleBuffer == nil) {
            NSLog(@"没有采集到");
            return ;
        }
        
        //  使用图像数据采样缓冲生成照片的数据
        NSData* data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        //  生成图片
        UIImage* image = [UIImage imageWithData:data];
        
//        //  预览视图的大小
//        CGRect rect = _preview.bounds;
//        
//        //  要裁剪的高度
//        CGFloat offset = (self.view.bounds.size.height - rect.size.height) * 0.5;
//        
//        
//        
//        //  1 开启图像上下文  --opaque不透明的
//        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
//        
//        //2绘制图像
//        [image drawInRect:CGRectInset(rect, 0, -offset)];
//        
//        
//        //  3取得结果图片
//        UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
//        
//        //  关闭上下文
//        UIGraphicsEndPDFContext();
        
        
        #pragma mark - 将图片进行保存
        [self.imagesArray addObject:image];
        
        
        
        
//        //  将第一张图片进行删除
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            [self.imagesArray removeObjectAtIndex:0];
//        });
        
        
        
        /**
         保存图像
         
         @param result 要保存的图片
         @param self self
         @param image:didFinishSavingWithError:contextInfo: 要执行的动作
         @return
         */
//        UIImageWriteToSavedPhotosAlbum(result, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
        
    }];
    
}


#pragma mark - 设置照片结束的回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSString* msg = (error != nil)?@"保存成功":@"保存失败";
    NSLog(@"%@",msg);
    
    //  静止画面
    //    [self stopCapture];
    
}


#pragma mark - 开始拍照
-(void)startCapture{
    [_captureSession startRunning];
}



#pragma mark - 停止拍照

-(void)stopCapture{
    
    [_captureSession stopRunning];
    
    [self startCapture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  设置电池栏的隐藏
- (BOOL)prefersStatusBarHidden{
    return NO;
}



/**
 拍摄会话
 */
-(void)setupCaptureSession{
    
    //  1获取到设备
    AVCaptureDevice* device = [self captureDevice];
    //  2设置具体的设备 - 摄像头，麦克风等
    _inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    
    [device isFocusModeSupported:AVCaptureFocusModeLocked];

    [device isExposureModeSupported:AVCaptureExposureModeLocked];
    
    [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked];
    
    //  2输出图像
    _imageOutput = [AVCaptureStillImageOutput new];
    
    //  3拍摄会话
    _captureSession = [AVCaptureSession new];
    
    //    AVCaptureSessionPreset1280x720
    _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    
    //  4将输出输入添加到拍摄会话
    //  为了避免因为客户手机的设备故障以及其他原因，通常需要判断
    if (![_captureSession canAddInput:_inputDevice]) {
        NSLog(@"无法添加输入设备");
        return;
    }
    if (![_captureSession canAddOutput:_imageOutput]) {
        NSLog(@"无法添加输出设备");
        return;
    }
    
    
    
    [_captureSession addInput:_inputDevice];
    [_captureSession addOutput:_imageOutput];
    
    
    //  5 设置预览层
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    
    //  制定图层的大小。模态展现的在viewdidload中，视图的大小还没有设置
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.size.height -= 130;
    _previewLayer.frame = rect;
    
    //  将preivewLayer添加layer
    [_preview.layer insertSublayer:_previewLayer atIndex:0];
    
    
    //  设置取景框的拉伸效果，在实际开发中，统一使用
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    
    //  开始拍摄
    [self startCapture];
    
}


-(AVCaptureDevice *)captureDevice{
    
    //  获取当前输入设备的镜头位置
    AVCaptureDevicePosition position = _inputDevice.device.position;
    position = (position != AVCaptureDevicePositionBack) ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    //  具体的设备
    NSArray* array = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    
    
    
    //  遍历数组获取后置摄像头
    AVCaptureDevice* device;
    for (AVCaptureDevice* obj in array) {
        if (obj.position == position) {
            
            device = obj;
            break;
        }
    }
    
    return device;
}



@end
