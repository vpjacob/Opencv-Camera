//
//  UIButton+Addition.m
//  camera
//
//  Created by ios on 2017/1/16.
//  Copyright © 2017年 董建新. All rights reserved.
//

#import "UIButton+Addition.h"

@implementation UIButton (Addition)

+ (instancetype)button:(NSString *)title fontSize:(CGFloat)fontSize normalColor:(UIColor *)normalColor selectedColor:(UIColor *)selectedColor {
    
    UIButton *button = [[self alloc] init];
    
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button setTitleColor:selectedColor forState:UIControlStateSelected];
    
    button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    
    [button sizeToFit];
    
    return button;
}

@end
