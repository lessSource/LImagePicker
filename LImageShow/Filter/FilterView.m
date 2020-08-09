//
//  FilterView.m
//  LImageShow
//
//  Created by L j on 2020/8/9.
//  Copyright © 2020 L. All rights reserved.
//

#import "FilterView.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord;  // (U, V)
    
} SenceVertex;

@interface FilterView()

@property (nonatomic, assign) SenceVertex *vertices;

@property (nonatomic, strong) EAGLContext *context;
// 屏幕刷新屏幕
@property (nonatomic, strong) CADisplayLink *displayLink;
// 开始的时间戳
@property (nonatomic, assign) NSTimeInterval startTimeInterval;
// 着色器程序
@property (nonatomic, assign) GLuint program;
// 顶点缓存
@property (nonatomic, assign) GLuint vertexBuffer;
// 纹理 ID
@property (nonatomic, assign) GLuint textureID;

@property (nonatomic, strong) UIImage *contentImage;

@end

@implementation FilterView

- (instancetype)initWithFrame:(CGRect)frame contentImage:(UIImage *)contentImage {
    if (self = [super initWithFrame:frame]) {
        self.contentImage = contentImage;
        [self initView];
    }
    return self;
    
}

// 释放
- (void)dealloc {
    // 上下文释放
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    // 顶点缓存区释放
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    
    // 顶点数组释放
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
    NSLog(@"++++++++ 释放%@", self);
}

- (void)removeDisplayLink {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)initView {
    [self filterInit];
    [self startFilerAnimation];
}

- (void)filterInit {
    // 初始化上下文并设置为当前上下文
    self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
    
    // 开辟顶点数组内存空间
    self.vertices = malloc(sizeof(SenceVertex) * 4);
    
    // 初始化顶点(0、1、2、3)的顶点坐标以及纹理坐标
    self.vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}};
    self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}};
    self.vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}};
    self.vertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}};
    
    // 创建图层(CAEAGLLayer)
    CAEAGLLayer *layer = [[CAEAGLLayer alloc]init];
    // 设置图层frame
    layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    // 设置图层的scale
    layer.contentsScale = [[UIScreen mainScreen] scale];
    // 给View添加layer
    [self.layer addSublayer:layer];
    
    // 绑定渲染缓存区
    [self bindRenderLayer:layer];
    
    // 将图片转换成纹理图片
    GLuint textureID = [self createTextureWithImage:self.contentImage];
    // 设置纹理ID
    self.textureID = textureID;  // 将纹理 ID 保存，方便后面切换滤镜的时候重用
    
    // 设置视口
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    // 设置顶点缓存区
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    // 设置默认着色器
    [self setupNormalShaderProgram]; // 一开始选用默认的着色器
    
    // 将顶点缓存保存，退出时才释放
    self.vertexBuffer = vertexBuffer;
}

// 绑定渲染缓存区和帧缓存区
- (void)bindRenderLayer:(CALayer <EAGLDrawable> *)layer {
    
    // 渲染缓存区，帧缓存区对象
    GLuint renderBuffer;
    GLuint frameBuffer;
    
    // 获取帧渲染缓存区名称,绑定渲染缓存区以及将渲染缓存区与layer建立连接
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    // 获取帧缓存区名称,绑定帧缓存区以及将渲染缓存区附着到帧缓存区上
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
}


// 从图片加载纹理
- (GLuint)createTextureWithImage:(UIImage *)image {
    // 将UIImage 转换为 CGImageRef
    CGImageRef cgImageRef = [image CGImage];
    // 判断图片是否获取成功
    if (!cgImageRef) {
        NSLog(@"Failed to load image");
        exit(1);
    }
    
    // 读取图片的大小，宽和高
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    // 获取图片的rect
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // 获取图片的颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 获取图片字节数 宽*高*4 (RGBA)
    void *imageData = malloc(width * height * 4);
    
    // 创建上下文
    /*
     参数1：data,指向要渲染的绘制图像的内存地址
     参数2：width,bitmap的宽度，单位为像素
     参数3：height,bitmap的高度，单位为像素
     参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     参数5：bytesPerRow,bitmap的没一行的内存所占的比特数
     参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
     */
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // 将图片翻转过来(图片默认是倒置的)
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    
    // 对图片进行重新绘制， 得到一张新的解压缩后的位图
    CGContextDrawImage(context, rect, cgImageRef);
    
    // 设置图片纹理属性
    // 获取纹理ID
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    //6.载入纹理2D数据
    /*
     参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
     参数2：加载的层次，一般设置为0
     参数3：纹理的颜色值GL_RGBA
     参数4：宽
     参数5：高
     参数6：border，边界宽度
     参数7：format
     参数8：type
     参数9：纹理数据
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    // 设置纹理属性
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    //8.绑定纹理
    /*
     参数1：纹理维度
     参数2：纹理ID,因为只有一个纹理，给0就可以了。
     */
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // 释放context、imageData
    CGContextRelease(context);
    free(imageData);
    
    // 返回纹理ID
    return textureID;
}

// 开始一个滤镜动画
- (void)startFilerAnimation {
    // 判断displayLink 是否为空
    // CADisplayLink 定时器
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    
    // 设置displayLink 的方法
    self.startTimeInterval = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    
    // 将displayLink 添加到runloop运行循环
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)timeAction {
    //DisplayLink 的当前时间撮
    if (self.startTimeInterval == 0) {
        self.startTimeInterval = self.displayLink.timestamp;
    }
    // 使用program
    glUseProgram(self.program);
    // 绑定buffer
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    
    // 传入时间
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time = glGetUniformLocation(self.program, "Time");
    glUniform1f(time, currentTime);
    
    // 清除画布
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    
    // 重绘
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    // 渲染到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
}


#pragma mark - Shader
// 设置着色器
- (void)setupsetupShaderProgram:(NSString *)name {
    [self setupShaderProgramWithName:name];
    // 重新开始滤镜动画
    [self startFilerAnimation];
}

// 默认着色器程序
- (void)setupNormalShaderProgram {
    [self setupShaderProgramWithName:@"Normal"];
}

// 初始化着色器程序
- (void)setupShaderProgramWithName:(NSString *)name {
    // 获取着色器program
    GLuint program = [self programWithShaderName:name];
    
    // use program
    glUseProgram(program);
    
    // 获取Position、Texture、TextureCoords 的索引位置
    GLuint positionSlot = glGetAttribLocation(program, "Position");
    GLuint textureSlot = glGetUniformLocation(program, "Texture");
    GLuint textureCoordsSlot = glGetAttribLocation(program, "TextureCoords");
    
    // 激活纹理，绑定纹理ID
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    
    // 纹理sample
    glUniform1i(textureSlot, 0);
    
    // 打开positionSlot 属性并且传递数据到positionSlot中(顶点坐标)
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    // 打开textureCoordsSlot属性并传递数据到textureCoordsSlot(纹理坐标)
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    // 保存program, 界面销毁则释放
    self.program = program;
}


#pragma mark - shader compile and link
// link Program
- (GLuint)programWithShaderName:(NSString *)shaderName {
    // 编译顶点着色器/片元着色器
    GLuint vertexShader = [self compileShaderWithName:shaderName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:shaderName type:GL_FRAGMENT_SHADER];
    
    // 将顶点/片元附着到program
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // linkProgram
    glLinkProgram(program);
    
    // 检查是否link成功
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(program, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSAssert(false, @"program连接失败：%@", messageString);
        exit(1);
    }
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    
    // 返回program
    return program;
}


//编译shader代码
- (GLuint)compileShaderWithName:(NSString *)name type:(GLenum)shaderType {
    // 获取shader路径
        
    NSString *shaderPath = [[NSBundle bundleForClass:[FilterView class]] pathForResource:name ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSAssert(false, @"读取shader失败");
        exit(1);
    }
    
    // 创建shader->根据shaderType
    GLuint shader = glCreateShader(shaderType);
    
    // 获取shader source
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 编译shader
    glCompileShader(shader);
    
    // 查看编译是否成功
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shader, sizeof(message), 0, &message[0]);
        NSString *messageSrring = [NSString stringWithUTF8String:message];
        NSAssert(false, @"shader编译失败：%@", messageSrring);
        exit(1);
    }
    
    // 返回shader
    return shader;
    
}

// 获取渲染缓存区的宽
- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}

//获取渲染缓存区的高
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}


@end


