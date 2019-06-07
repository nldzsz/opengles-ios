//
//  CGImageUtils.m
//  OpenGLES-ios
//
//  Created by 飞拍科技 on 2019/6/1.
//  Copyright © 2019 飞拍科技. All rights reserved.
//

#import "CGImageUtils.h"

@implementation CGImageUtils
+ (void)createBitmapContext:(CGContextRef*)returnContext withImageRef:(CGImageRef)cgImageRef decodetoRGBAData:(void**)rgbaData decode:(BOOL)yesOrnot
{
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // 表明所使用的是RGB颜色空间，比如还有其它颜色空间CMYK,Gray等
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImageRef) & kCGBitmapAlphaInfoMask;
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipLast;
    int componentsPerPiexel =  hasAlpha ? 4 : 4;
    /** 1、kCGImageAlphaPremultipliedLast和kCGImageAlphaLast的区别
     *  前者表示最终像素RGB的值是原始RGB乘以alpha之后的值，而后者则存储的就是原始的值。一般做GPU渲染时，选择前者，效率高，因为CPU到GPU转换中少一次乘法运算；举例如下：
     *  像素RGBA(200,100,100,0.8)，如果是前者，那么最终生成的imageData中这个像素的存储值为(160,80,80,0.8);而后者依然是(200,100,100,0.8);
     *  2、kCGBitmapByteOrder32Big表示每个像素是按照32位大端序存储的
     *  为了让渲染不会出错，比如CPU数据传给GPU渲染时不会出错，这里都要用32位大端序来存储数据
     *  如下：表示创建一个RGBA像素格式的图像数据块，并且图像数据块中每个像素按照大端序来存储，这里的图片文件有可能是JPG等不带alpha通道的，那么将默认填充为1
     */
    void *imageData = NULL;
    if (yesOrnot) {
        imageData = malloc(width * height * componentsPerPiexel);
    }
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * componentsPerPiexel, colorSpace, bitmapInfo);
    
    CGContextClearRect(context, rect);
    // 相当于软解码，将解码后的数据RGBA像素数据放入了imageData中(如果配置了的话)
    CGContextDrawImage(context, rect, cgImageRef);
    
    // 释放内存
    CGColorSpaceRelease(colorSpace);
    
    //  返回给外部
    *returnContext = context;
    if (yesOrnot) {
        *rgbaData = imageData;
    }
}

+ (void*)rgbaImageDataForPath:(NSString*)name width:(int*)orgwidth height:(int*)orgheight
{
    // 这一步根据文件对象生成CGImageRef对象，并没有将图片的内存加载近内存
    CGImageRef cgImageRef = [UIImage imageNamed:name].CGImage;
    
    *orgwidth = (GLuint)CGImageGetWidth(cgImageRef);
    *orgheight = (GLuint)CGImageGetHeight(cgImageRef);
    
    // 创建上下文
    void *imageData = NULL;
    CGContextRef context;
    [CGImageUtils createBitmapContext:&context withImageRef:cgImageRef decodetoRGBAData:&imageData decode:YES];
    
    // 释放图片对象
    CGImageRelease(cgImageRef);
    // 释放上下文
    CGContextRelease(context);
    
    return imageData;
}


+ (void)pngToJPGWithPath:(NSString*)pngPath tojpgPath:(NSString*)jpgPath
{
    CGImageRef cgImageRef = [UIImage imageNamed:pngPath].CGImage;
    
    CGContextRef context;
    [CGImageUtils createBitmapContext:&context withImageRef:cgImageRef decodetoRGBAData:NULL decode:NO];
    
    // 重新编码成JPG
    CGImageRef cgRef = CGBitmapContextCreateImage(context);
    UIImage* image = [UIImage imageWithCGImage: cgRef];
    // 第二个参数表示压缩比例，范围0-1 1.0代表不压缩
    NSData*imageData1 = UIImageJPEGRepresentation(image, 1.0);
    [imageData1 writeToFile:jpgPath atomically:YES];   //is succeeded
    
    // 释放内存
    CGContextRelease(context);
}
@end
