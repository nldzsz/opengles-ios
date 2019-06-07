//
//  GLView.h
//  study
//
//  Created by 飞拍科技 on 2018/7/26.
//  Copyright © 2018年 飞拍科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLContext.h"
#import "GLProgram.h"
#import "GLUtils.h"
#import "CGImageUtils.h"

@interface GLView : UIView
{
    // 表示一块帧缓冲区的地址
    GLuint _frameBuffer;
    // 表示一块渲染缓冲区的地址
    GLuint _renderBuffer;
}
@property (strong, nonatomic)GLProgram *program;
@property (strong, nonatomic)GLProgram *lineprogram;

- (void)offscreenRender;

// 一次渲染多张图片；同时渲染两张张图片，效果是混合这两张图片
- (void)renderTextureWithPath:(NSString*)path path2:(NSString*)path2;

// 多次渲染，即多次调用glDrawArrays();第一次渲染一张图片，同时再渲染两条直线
- (void)renderTextureAndlinesWithPath:(NSString*)path;

- (void)destroy;
- (UIImage*)imaFromFrameBufferContext;
@end
