//
//  GLView.m
//  study
//
//  Created by 飞拍科技 on 2018/7/26.
//  Copyright © 2018年 飞拍科技. All rights reserved.
//

#import "GLView.h"
#import "GLContext.h"
#import <OpenGLES/ES2/gl.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const lineShaderString = SHADER_STRING
(
 attribute vec4 position;
 void main()
 {
     gl_Position = position;
 }
 );
NSString *const lineFragString = SHADER_STRING
(
 void main()
 {
     gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
 }
 );

NSString *const vertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 texcoord;
 varying vec2 v_texcoord;
 
 void main()
 {
     gl_Position = position;
     v_texcoord = texcoord.xy;
 }
 );

NSString *const rgbFragmentShaderString = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 uniform sampler2D inputImageTexture1;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture1, v_texcoord)+texture2D(inputImageTexture2, v_texcoord);
 }
 );

static float lineData1[8] = {
    -1.0f,  // x0
    -1.0f,  // y0

    1.0f,  // x3
    1.0f,  // y3
    
    -1.0f,  // x0
    1.0f,  // y0
    
    1.0f,  // x3
    -1.0f,  // y3
};

static float verData1[8] = {
    -1.0f,  // x0
    -1.0f,  // y0
    
    1.0f,  // ..
    -1.0f,
    
    -1.0f,
    1.0f,
    
    1.0f,  // x3
    1.0f,  // y3
};

static float uvData[8] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f,
};

@interface GLView()
{
    GLuint _framebufferForShut;
    GLuint _textures[2];
    GLuint _position;
    GLuint _texture;
    GLuint _sampler2D;
    GLint _renderWidth,_renderHeight;
    
    GLContext *_context;
    
    GLuint texturexId1;
    GLuint texturexId2;
}
@end
@implementation GLView
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        // 1、创建Opengl es上下文环境;此必须要重写View的layerClass方法，让其返回[CAEAGLLayer class];
        [self setEAGLContext];
        
        // 2、创建frame buffer 和render buffer
        [self setupFrameAndRenderBuffer];
        
        // 3、加载着色器并生成最终程序
        [self loadShaders];
//        [self setVBOBuffers];
    }
    return self;
}

// 设置上下文的环境
- (void)setEAGLContext
{
    _context = [[GLContext alloc] initDefaultContextLayer:(CAEAGLLayer *)self.layer];
    [_context useAsCurrentContext];
}

/** 遇到问题:checkFramebuffer返回36054错误
 *  解决方案：发现是renderbufferStorage所使用的EAGLContext和setCurrentContext的EAGLContext不一致导致；二者保持一直即可
 */
- (void)setupFrameAndRenderBuffer
{
    // 如果有 则先删除
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    // 创建frameBuffer
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // 如果有 则先删除
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    // 创建渲染buffer
    glGenRenderbuffers(1, &_renderBuffer);    //第一个参数 创建buffer的数量 第二个参数 创建的bufferId(为0表示创建失败)
    // 绑定刚刚创建的buffer为GL_RENDERBUFFER类型。
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer); // 第一个参数，buffer的类型，要与前面创建的buffer类型对应。第二个参数，前面创建的buffer id
    // 将render buffer和frame buffer关联在一起，第二个参数和前面创建的buffer类型一一对应(color buffer,depth buffer,stencil buffer)，分别对应GL_COLOR_ATTACHMENT0,GL_DEPTH_ATTACHMENT,GL_STENCIL_ATTACHMENT
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    // 为render buffer 开辟存储空间 重要;EAGLContext必须设置正确，否则下面会出现36054错误
    [_context.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
    
    NSError *error;
    if (![GLUtils checkFramebuffer:&error]) {
        NSLog(@"出错==>%@",error);
    }
}

- (void)loadShaders
{
    if (!self.program) {
        self.program = [[GLProgram alloc] initWithVertexShaderType:vertexShaderString fragShader:rgbFragmentShaderString];
        // 渲染管线中的可编程程序要调用一下glUseProgram()后面的glDrawxxx()指令执行后这个程序才会有效
//        [self.program use];
    }
    if (!self.lineprogram) {
        self.lineprogram = [[GLProgram alloc] initWithVertexShaderType:lineShaderString fragShader:lineFragString];
        // 渲染管线中的可编程程序要调用一下glUseProgram()后面的glDrawxxx()指令执行后这个程序才会有效
//        [self.lineprogram use];
    }
}

- (void)offscreenRender
{
//    GLenum error = GL_NO_ERROR;
//
//    glClearColor(1, 0, 0, 1);   //red clear color, this can be seen
//    glClear(GL_COLOR_BUFFER_BIT);
//
//
//    glViewport(self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2, self.frame.size.height/2);
////    _position = [self.sanjiaoxProgram attributeIndexOfName:@"position"];
////    _color = [self.sanjiaoxProgram attributeIndexOfName:@"color"];
//
//    glVertexAttribPointer(_position, 3, GL_FLOAT, GL_FALSE, 0, verData1);
//    glVertexAttribPointer(_color, 4, GL_FLOAT, GL_FALSE, 0, uvData);
//    glEnableVertexAttribArray(_position);
//    glEnableVertexAttribArray(_color);
//    glDrawArrays(GL_TRIANGLE_STRIP, 1, 3);
//
//    error = glGetError();
//    if (error != GL_NO_ERROR) {
//        NSLog(@"error happend, error is %d, line %d",error,__LINE__);
//    }
//
//    glFinish();
//    error = glGetError();
//    if (error != GL_NO_ERROR) {
//        NSLog(@"error happend, error is %d, line %d",error,__LINE__);
//    }
//
//    [self imaFromFrameBufferContext];
}

- (UIImage*)imaFromFrameBufferContext
{
    GLenum error = GL_NO_ERROR;
    int WIDTH_IN_PIXEL = self.frame.size.width;
    int HEIGHT_IN_PIXEL = self.frame.size.height;
    
    NSInteger x = 0, y = 0;
    NSInteger dataLength = WIDTH_IN_PIXEL * HEIGHT_IN_PIXEL * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, WIDTH_IN_PIXEL, HEIGHT_IN_PIXEL, GL_RGBA, GL_UNSIGNED_BYTE, data);
    NSData *pixelsRead = [NSData dataWithBytes:data length:dataLength];
    
    error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"error happend, error is %d, line %d",error,__LINE__);
    }
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(WIDTH_IN_PIXEL, HEIGHT_IN_PIXEL, 8, 32, WIDTH_IN_PIXEL * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    
    UIGraphicsBeginImageContext(CGSizeMake(WIDTH_IN_PIXEL, HEIGHT_IN_PIXEL));
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, WIDTH_IN_PIXEL, HEIGHT_IN_PIXEL), iref);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData *d = UIImageJPEGRepresentation(image, 1);
    NSString *documentDirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    static NSInteger imageNO = 1;
    imageNO++;
    NSString *savingPath = [documentDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg",imageNO]];
    BOOL succ = [d writeToFile:savingPath atomically:NO];   //is succeeded
    
    UIGraphicsEndImageContext();
    
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return nil;
}

/** 一次渲染两张照片到指定区域中
 *  1、遇到问题：Texture1纹理对应图片无法显示
 *  解决方案，因为Texture0默认激活的，Texture1要手动激活，同时还需要调用glBindTexture()函数和正确用glUniform1i()函数
 *  设置GLSL纹理的，这里为1解决问题
 */
- (void)renderTextureWithPath:(NSString*)path1 path2:(NSString*)path2
{
    glClearColor(0, 1, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, _renderWidth, _renderHeight);

    int w1,h1;
    int w2,h2;
    void *image1 = [CGImageUtils rgbaImageDataForPath:path1 width:&w1 height:&h1];
    NSLog(@"图片的宽和高 w1 %d h1 %d",w1,h1);
    void *image2 = [CGImageUtils rgbaImageDataForPath:path2 width:&w2 height:&h2];
    NSLog(@"图片的宽和高 w2 %d h2 %d",w1,h1);

    [self.program use];
    GLuint position = [self.program attribLocationForName:@"position"];
    GLuint texcoord = [self.program attribLocationForName:@"texcoord"];
    GLuint s_texture1 = [self.program uniformLocationForName:@"inputImageTexture1"];
    GLuint s_texture2 = [self.program uniformLocationForName:@"inputImageTexture2"];

    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 0, verData1);
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(texcoord, 2, GL_FLOAT, GL_FALSE, 0, uvData);
    glEnableVertexAttribArray(texcoord);
    
    GLint active,textureSize;
    glGetIntegerv(GL_ACTIVE_TEXTURE, &active);
    NSLog(@"该设备支持的最大纹理单元数目 %d",active);
    // 超过此大小则必须先压缩再传给opengl es，否则opengl es无法渲染
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &textureSize);
    NSLog(@"该设备支持的纹理最大的长或宽 %d",textureSize);
    
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1,&texturexId2);
    glBindTexture(GL_TEXTURE_2D, texturexId2);
    // 此方法必须有，第二个参数要与前面激活的纹理单元数对应，前面是GL_TEXTURE1，这里就是1
    glUniform1i(s_texture2, 1);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // S方向上的贴图模式
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // T方向上的贴图模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)w2, (int)h2, 0, GL_RGBA, GL_UNSIGNED_BYTE, image2);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    
    /** 纹理的工作原理
     *  纹理单元用来将app中图片像素数据传递给OpenGL ES,对应片段着色器中的uniform sampler2D变量。它是一个全局对象，每台设备都会创建数个独立的纹理单元，要使用
     *  一个纹理单元之前必须先激活它才能使用，激活之后还需要绑定，则才可以使用多个纹理对象;
     *  如果应用中只有一个激活的纹理，则不需要调用glBindTexture()函数也可以，但是如果要使用多个纹理，则必须要调用glBindTexture()进行区分，否则会造成数据被覆盖
     */
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1,&texturexId1);
    NSLog(@"texturexId %d",texturexId1);
    glBindTexture(GL_TEXTURE_2D, texturexId1);
    // 此方法必须有，第二个参数要与前面激活的纹理单元数对应，前面是GL_TEXTURE0，这里就是0
    glUniform1i(s_texture1, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // S方向上的贴图模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // T方向上的贴图模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    // 1字节对齐，效率比较低，默认是4；必须在glTexImage2D前面设置
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    // 因为image1像素数据本身就是由RGBA构成的，所以这里format只能是GL_RGBA，如果传其它值则会造成数据不对称而出错
    // 比如进行视频渲染是，分别传递YUV三个分量的像素给Opengl es，则那个时候format取值就必须为GL_LUMINANCE或者GL_ALPHA等只有一个字节的
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w1, h1, 0, GL_RGBA, GL_UNSIGNED_BYTE, image1);    // border参数为1 渲染不出来
    
    // 释放图片像素数据
    if (image1) {
        free(image1);
    }
    if (image2) {
        free(image2);
    }
    
    // 确定要绘制的几何图形，该指令执行后才opengl es指令才开始真正的执行；处于渲染管线的第一阶段，每次glDrawArrays()的调用
    // 代表前面所有的指令是一次完整的渲染
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // 即光栅化阶段，它与opengl es的渲染是独立的，不相干的。当它会将前面所有的渲染结果呈现到屏幕上;
    [_context.context presentRenderbuffer:GL_RENDERBUFFER];
}

/** 多次调用glDrawArrays()
 *  1、遇到问题：第二次调用的glDrawArrays()覆盖了前面调用的结果
 *  解决方案，是因为每次glDrawArrays()都对应着自己的着色器程序，而opengl es又是个全局的状态机，glUseProgram()函数会覆盖
 *  前面的着色器程序，所以导致了着色器程序对应出错，所以第二次绘制时glUseProgram()函数应该在第一次glDrawArrays()之后
 */
- (void)renderTextureAndlinesWithPath:(NSString*)path
{
    glClearColor(0, 1, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, _renderWidth, _renderHeight);
    
    int w1,h1;
    void *image1 = [CGImageUtils rgbaImageDataForPath:path width:&w1 height:&h1];
    NSLog(@"图片的宽和高 w1 %d h1 %d",w1,h1);
    
    [self.program use];
    GLuint position = [self.program attribLocationForName:@"position"];
    GLuint texcoord = [self.program attribLocationForName:@"texcoord"];
    GLuint s_texture1 = [self.program uniformLocationForName:@"inputImageTexture1"];
    
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 0, verData1);
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(texcoord, 2, GL_FLOAT, GL_FALSE, 0, uvData);
    glEnableVertexAttribArray(texcoord);
    
    GLint active,textureSize;
    glGetIntegerv(GL_ACTIVE_TEXTURE, &active);
    NSLog(@"该设备支持的最大纹理单元数目 %d",active);
    // 超过此大小则必须先压缩再传给opengl es，否则opengl es无法渲染
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &textureSize);
    NSLog(@"该设备支持的纹理最大的长或宽 %d",textureSize);
    
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1,&texturexId2);
    glBindTexture(GL_TEXTURE_2D, texturexId2);
    // 此方法必须有，第二个参数要与前面激活的纹理单元数对应，前面是GL_TEXTURE1，这里就是1
    glUniform1i(s_texture1, 1);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // S方向上的贴图模式
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // T方向上的贴图模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)w1, (int)h1, 0, GL_RGBA, GL_UNSIGNED_BYTE, image1);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    // 释放图片像素数据
    if (image1) {
        free(image1);
    }
    
    // 确定要绘制的几何图形，该指令执行后才opengl es指令才开始真正的执行；处于渲染管线的第一阶段，每次glDrawArrays()的调用
    // 代表前面所有的指令是一次完整的渲染
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self.lineprogram use];
    GLuint linePosition = [self.lineprogram attribLocationForName:@"position"];
    glVertexAttribPointer(linePosition, 2, GL_FLOAT, GL_FALSE, 0, lineData1);
    glEnableVertexAttribArray(linePosition);
    
    glLineWidth(5.0);
    glDrawArrays(GL_LINES, 0, 4);
    
    // 即光栅化阶段，它与opengl es的渲染是独立的，不相干的。当它会将前面所有的渲染结果呈现到屏幕上;
    // 前面调用了两次glDrawArrays();所以它会将前面两次渲染的结果呈现到屏幕上
    [_context.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)destroy
{
    if (texturexId1) {
        glDeleteTextures(1, &texturexId1);
    }
    if (texturexId2) {
        glDeleteTextures(1, &texturexId2);
    }
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (self.program) {
        [self.program destroy];
    }
    if (_context) {
        [_context releaseContext];
        _context = nil;
    }
}

- (void)dealloc
{
    [self destroy];
}
@end
