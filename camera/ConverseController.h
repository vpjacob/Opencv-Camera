//
//  ConverseController.h
//  camera
//
//  Created by ios on 2017/1/16.
//  Copyright © 2017年 董建新. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConverseController : UIViewController

@property (strong, nonatomic) NSArray* imageArray;

//  重启相机的block
@property (copy, nonatomic)void(^restartBlock)();

@end
