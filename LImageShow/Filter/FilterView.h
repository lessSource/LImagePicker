//
//  FilterView.h
//  LImageShow
//
//  Created by L j on 2020/8/9.
//  Copyright © 2020 L. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterView : UIView

// 图片初始化
- (instancetype)initWithFrame:(CGRect)frame contentImage:(UIImage *)contentImage;

// 移出定时器
- (void)removeDisplayLink;

// 设置滤镜动画
- (void)setupsetupShaderProgram:(NSString *)name;


// 保存图片
- (UIImage *)saveImage;

@end

NS_ASSUME_NONNULL_END
