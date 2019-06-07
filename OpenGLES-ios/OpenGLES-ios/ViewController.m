//
//  ViewController.m
//  OpenGLES-ios
//
//  Created by 飞拍科技 on 2019/5/28.
//  Copyright © 2019 飞拍科技. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h"
#import "CGImageUtils.h"

@interface ViewController ()
{
    GLView *_glView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _glView = [[GLView alloc] initWithFrame:CGRectMake(50, 100, 200, 200)];
    _glView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_glView];
    
//    // 测试PNG转换成JPG
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, 200, 200)];
//    imageView.image = [UIImage imageNamed:@"4.JPG"];
//    [self.view addSubview:imageView];
//
//    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
//    path = [path stringByAppendingPathComponent:@"1.JPG"];
//    NSLog(@"path %@",path);
//
//    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"JPG"];
//    [CGImageUtils pngToJPGWithPath:path2 tojpgPath:path];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(testRender) withObject:nil afterDelay:1.0f];
}

- (void)testRender
{
    // 同时加载两张照片
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"png"];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"JPG"];
//    [_glView renderTextureWithPath:path1 path2:path2];
    
    // 同时渲染一张图片和画一条直线
    [_glView renderTextureAndlinesWithPath:path1];
//    [self performSelector:@selector(testReleaseMemeory) withObject:nil afterDelay:1.0f];
}

- (void)testReleaseMemeory
{
    if (_glView) {
        [_glView removeFromSuperview];
        _glView = nil;
    }
}
@end
