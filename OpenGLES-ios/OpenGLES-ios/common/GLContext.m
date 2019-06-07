//
//  GLContext.m
//  OpenGLES-ios
//
//  Created by 飞拍科技 on 2019/5/29.
//  Copyright © 2019 飞拍科技. All rights reserved.
//

#import "GLContext.h"

@implementation GLContext

- (id)initDefaultContextLayer:(CAEAGLLayer*)caLayer
{
    return [self initWithApiVersion:kEAGLRenderingAPIOpenGLES2 multiThread:NO layer:caLayer];
}

- (id)initWithApiVersion:(EAGLRenderingAPI)version multiThread:(BOOL)yesOrnot layer:(CAEAGLLayer*)calayer
{
    if (self = [super init]) {
        
        calayer.opaque = NO; //CALayer默认是透明的，透明的对性能负荷大，故将其关闭
        // 表示屏幕的scale，默认为1；会影响后面renderbufferStorage创建的renderbuffer的长宽值；
        // 它的长宽值等于=layer所在视图的逻辑长宽*contentsScale
        // 最好这样设置，否则后面按照纹理的实际像素渲染，会造成图片被放大。
        calayer.contentsScale = [UIScreen mainScreen].scale;
        calayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                      // 由应用层来进行内存管理
                                      @(NO),kEAGLDrawablePropertyRetainedBacking,
                                      kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,
                                      nil];

        
        // 创建指定OpenGL ES的版本的上下文，一般选择2.0的版本
        _context = [[EAGLContext alloc] initWithAPI:version];
        // 当为yes的时候，所有关于Opengl渲染，指令真正执行都在另外的线程中。NO，则关于渲染，指令真正执行在当前调用的线程
        // 对于多核设备有大的性能提升
        _context.multiThreaded = yesOrnot;
    }
    
    return self;
}

- (void)useAsCurrentContext
{
    if (!_context) {
        return;
    }
    [EAGLContext setCurrentContext:_context];
}

- (void)releaseContext
{
    
}
@end
