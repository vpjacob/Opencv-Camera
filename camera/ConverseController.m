//
//  ConverseController.m
//  camera
//
//  Created by ios on 2017/1/16.
//  Copyright © 2017年 董建新. All rights reserved.
//

#import "ConverseController.h"
#import "Masonry.h"
#import "CVWrapper.h"
#import "SVProgressHUD.h"
#import "UIButton+Addition.h"
#import <mach/mach_time.h>

@interface ConverseController ()<UIScrollViewDelegate>


@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *saveImage;


@end

@implementation ConverseController

- (void)viewDidLoad {
    [super viewDidLoad];

    

}


-(void)viewDidAppear:(BOOL)animated{
    
    
    
    [super viewDidAppear:animated];
    
    
    
    [self stitch];
    
    
}




-(void)stitch{
    
    [SVProgressHUD show];
    
    NSMutableArray* imageM1 = [NSMutableArray array];
    NSMutableArray* imageM2 = [NSMutableArray array];
    NSMutableArray* imageM3 = [NSMutableArray array];
    NSMutableArray* imageM4 = [NSMutableArray array];
    
        
        CGSize newSize = CGSizeMake(960, 1280);
        
    

        
    [self.imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        UIGraphicsBeginImageContext(newSize);
        
        [self.imageArray[idx] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        
        UIImage * scaledImage= UIGraphicsGetImageFromCurrentImageContext();


        
        //  将可变数组分成4份
        switch (idx / 4) {
            case 0:
                [imageM1 addObject:scaledImage];
                break;
            case 1:
                [imageM2 addObject:scaledImage];
                break;
            case 2:
                [imageM3 addObject:scaledImage];
                break;
            case 3:
                [imageM4 addObject:scaledImage];
                break;
            default:
                break;
        }
        
        
        
         UIGraphicsEndImageContext();
        
        
        
    }];

    
    
        //  传入一个图片数组
    NSMutableArray* lastPuzzle = [NSMutableArray array];
    
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        UIImage* stitchedImage1 = [CVWrapper processWithArray:imageM1];
        UIImage* stitchedImage2 = [CVWrapper processWithArray:imageM2];
        UIImage* stitchedImage3 = [CVWrapper processWithArray:imageM3];
        UIImage* stitchedImage4 = [CVWrapper processWithArray:imageM4];
        
        
//        dispatch_barrier_async(dispatch_get_main_queue(), ^{
    
            [lastPuzzle addObject:stitchedImage1];
            [lastPuzzle addObject:stitchedImage2];
            [lastPuzzle addObject:stitchedImage3];
            [lastPuzzle addObject:stitchedImage4];
            
            
//            dispatch_async(dispatch_get_main_queue(), ^{
    
               UIImage* image = [CVWrapper processWithArray:lastPuzzle];
                
//            });
//            
//            
//        });
//        
//        
//    });
    

    
    
    
    
    self.saveImage = image;
            
            //  创建一个imageview
            self.imageView = [[UIImageView alloc] initWithImage:image];
            
            //注意要设置小了 scroll view  但是将contentsize设置大
            UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - 50)];
            
            self.scrollView = scrollView;
            
            [scrollView addSubview:self.imageView];
            
            scrollView.contentSize = CGSizeMake(SCREENW, SCREENH - 50);
            
            scrollView.maximumZoomScale = 4;
            scrollView.minimumZoomScale = 0.4;
            
            scrollView.delegate = self;
            
            scrollView.contentOffset = CGPointMake(0,0);
            
            [self.view addSubview:self.scrollView];
            
            [SVProgressHUD dismissWithCompletion:^{
                
                
                /**
                 按钮相关

                 退出按钮
                 
                 保存按钮
                 */
                
                
                UIView* btnView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH - 50, SCREENW, 50)];
                
                btnView.backgroundColor = [UIColor redColor];
                
                [self.view addSubview:btnView];
                
                UIButton* saveBtn = [UIButton button:@"save" fontSize:15 normalColor:[UIColor whiteColor] selectedColor:[UIColor yellowColor]];
                
                [btnView addSubview:saveBtn];
                
                [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                
                    make.left.equalTo(self.view);
                    
                    make.top.equalTo(self.scrollView.mas_bottom);
                    
                    make.width.mas_equalTo(SCREENW * 0.5);
                    
                    make.height.mas_equalTo(50);
                        
                }];
                    
                [saveBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];
                
                
                
                UIButton* exitBtn = [UIButton button:@"exit" fontSize:15 normalColor:[UIColor whiteColor] selectedColor:[UIColor yellowColor]];
                
                
                [btnView addSubview:exitBtn];
                
                [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.right.equalTo(self.view);
                    
                    make.top.equalTo(self.scrollView.mas_bottom);
                    
                    make.width.mas_equalTo(SCREENW * 0.5);
                    
                    make.height.mas_equalTo(50);
                    
                }];
                
                [exitBtn addTarget:self action:@selector(exitBtnAction) forControlEvents:UIControlEventTouchUpInside];
                
                
                
            }];
            
//        });
    
        
        
//    });
    
    
    
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}


- (void)saveBtnAction {
    
UIImageWriteToSavedPhotosAlbum(self.saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}

-(void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)exitBtnAction{

    self.restartBlock();
    
    [SVProgressHUD dismiss];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}




@end
