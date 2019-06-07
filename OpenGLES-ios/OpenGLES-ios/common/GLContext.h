//
//  GLContext.h
//  OpenGLES-ios
//
//  Created by 飞拍科技 on 2019/5/29.
//  Copyright © 2019 飞拍科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLDefine.h"

/** 在ios中
 *  1、要使用Opengl es 需要引用头文件
 *  // 提供标准的opengl es接口
 *  #import <OpenGLES/ES2/gl.h>
 *  // IOS平台用于进行上下文管理及窗口管理的头文件
 *  #import <OpenGLES/EAGL.h>
 *  2、要想使用opengl es，则必须创建上下文环境
 */
@interface GLContext : NSObject
@property (strong, nonatomic,readonly) EAGLContext *context;

// 默认opengl es 2.0 和不支持多线程
- (id)initDefaultContextLayer:(CAEAGLLayer*)caLayer;

- (id)initWithApiVersion:(EAGLRenderingAPI)version
             multiThread:(BOOL)yesOrnot
                   layer:(CAEAGLLayer*)calayer;

// 将上下文设置为当前线程的上下文环境
- (void)useAsCurrentContext;
// 释放上下文
- (void)releaseContext;
@end
