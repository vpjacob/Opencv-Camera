//
//  ViewController.m
//  camera
//
//  Created by 董建新 on 2016/11/16.
//  Copyright © 2016年 董建新. All rights reserved.
//

#import "ViewController.h"
#import "JJSportCameraViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    
    
    
    [super viewDidLoad];
    
}


- (IBAction)click {
    
    JJSportCameraViewController* vc = [JJSportCameraViewController new];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}




@end
