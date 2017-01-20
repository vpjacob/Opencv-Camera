//
//  UIButton+Addition.h
//  camera
//
//  Created by ios on 2017/1/16.
//  Copyright © 2017年 董建新. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Addition)
/// 创建文本按钮
///
/// @param title         文本
/// @param fontSize      字体大小
/// @param normalColor   默认颜色
/// @param selectedColor 选中颜色
///
/// @return UIButton
+ (instancetype)button:(NSString *)title fontSize:(CGFloat)fontSize normalColor:(UIColor *)normalColor selectedColor:(UIColor *)selectedColor;

@end
