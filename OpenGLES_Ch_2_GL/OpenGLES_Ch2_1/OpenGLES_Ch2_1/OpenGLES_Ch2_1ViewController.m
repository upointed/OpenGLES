//
//  OpenGLES_Ch2_1ViewController.m
//  OpenGLES_Ch2_1
//

#import "OpenGLES_Ch2_1ViewController.h"

@implementation OpenGLES_Ch2_1ViewController

@synthesize baseEffect;

//先介绍几个概念：
//渲染：用3D数据生成一个2D图像的过程就叫做渲染；
//像素：计算机显示矩形的颜色点叫做像素；
//缓存：是指图形处理器能够控制和管理的连续RAM（原来就是内存）；
//帧缓存：内存中接收2D结果数据的缓冲区；
//上下文：是用于配置OpenGL ES的特定的软件平台的数据结构信息；


/////////////////////////////////////////////////////////////////
// This data type is used to store information for each vertex
typedef struct {
    //用来保存一个坐标，它是一个起始于坐标系原点的矢量，X,Y,Z
    GLKVector3  positionCoords;
}
SceneVertex;

/////////////////////////////////////////////////////////////////
// Define vertex data for a triangle to use in example
//
//用来定义三角形
/*
 *************
 **** ********
 ****  *******
 ****   ******
 ****    *****
 ****     ****
 *************
 *************
*/
static const SceneVertex vertices[] =
{
    {{-0.5f, -0.5f, 0.0}}, // lower left corner
    {{ 0.5f, -0.5f, 0.0}}, // lower right corner
    {{-0.5f,  0.5f, 0.0}}  // upper left corner
};


/////////////////////////////////////////////////////////////////
// Called when the view controller's view is loaded
// Perform initialization before the view is asked to draw
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // Verify the type of view created automatically by the
   // Interface Builder storyboard
   GLKView *view = (GLKView *)self.view;
   NSAssert([view isKindOfClass:[GLKView class]],
      @"View controller's view is not a GLKView");
    
    //OpenGL ES的上下文不仅会保存它的状态，还会控制GPU去执行渲染运算
    //EAGLContext会封装一个特定于某个平台的上下文，一个应用可以使用多个上下文
    
   // Create an OpenGL ES 2.0 context and provide it to the
   // view
   view.context = [[EAGLContext alloc] 
      initWithAPI:kEAGLRenderingAPIOpenGLES2];
   
   // Make the new context current
   [EAGLContext setCurrentContext:view.context];
   
   // Create a base effect that provides standard OpenGL ES 2.0
   // Shading Language programs and set constants to be used for 
   // all subsequent rendering
    //GLKBaseEffect类提供了不依赖OGE版本的渲染方法，它会在需要的时候自动构建一个GPU程序
    //该实例使用恒定不变的白色来渲染像素
    
   self.baseEffect = [[GLKBaseEffect alloc] init];
   self.baseEffect.useConstantColor = GL_TRUE;
   self.baseEffect.constantColor = GLKVector4Make(
      1.0f, // Red
      1.0f, // Green
      1.0f, // Blue
      1.0f);// Alpha
   
   // Set the background color stored in the current context
    //设置当前OGE上下文为不透明黑色，该黑色由RGBA颜色元素值组成，用于在上下文帧缓存被清除时对每个像素进行初始化
   glClearColor(0.0f, 0.0f, 0.0f, 1.0f); // background color
   
    //用于定义三角形的数据必须要发送到GPU来进行渲染
    //创建三角形数据数组缓存的前三个步骤，对应以下步骤：
    //1.为缓存生成一个唯一的标志符；
    //2.为运算绑定缓存；
    //3.复制数据到缓存；
    
    
   // Generate, bind, and initialize contents of a buffer to be 
   // stored in GPU memory
   glGenBuffers(1,                // STEP 1
      &vertexBufferID);
    NSLog(@"vertexBufferID = %p",vertexBufferID);
    //该结果是一个指针，指向所生成标志符的内存保存位置；
    //缓存标志符在文档中叫做 "names"
   glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
      vertexBufferID);
    //保存不同类型的标志符到OGE的不同位置，同一时刻只能绑定一个缓存，即使它们是相同类型的；
    //2.0只支持绑定两种类型，GL_ARRAY_BUFFER GL_ELEMENT_ARRAY_BUFFER；
   glBufferData(                  // STEP 3
      GL_ARRAY_BUFFER,  // Initialize buffer contents
      sizeof(vertices), // Number of bytes to copy
      vertices,         // Address of bytes to copy
      GL_STATIC_DRAW);  // Hint: cache in GPU memory
    //第四个参数提示缓存在未来运算中可能会被怎样使用
    //GL_STATIC_DRAW 提示缓存内容适合复制到内存中，而很少对其进行修改；
    //GL_DYNAMIC_DRAW 缓存数据会频繁改变，提示OGE上下文用不同方式处理
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)

//每当一个GLKView需要重绘时，保存在视图中的上下文都会成为当前上下文；如需要，它还会保存一个来自Core Animation层的帧缓存，并调用下面的方法；
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
   [self.baseEffect prepareToDraw];
   
   // Clear Frame Buffer (erase previous drawing)
   glClear(GL_COLOR_BUFFER_BIT);
    //它的值是前面glClearColor()设置的；
   
   // Enable use of positions from bound vertex buffer
    //此处接上面使用缓存的前三步；
    //4.启动；
    //5.设置指针；
    //6.绘图；
   glEnableVertexAttribArray(      // STEP 4
      GLKVertexAttribPosition);
      
   glVertexAttribPointer(          // STEP 5
      GLKVertexAttribPosition, 
      3,                   // three components per vertex
      GL_FLOAT,            // data is floating point
      GL_FALSE,            // no fixed point scaling
      sizeof(SceneVertex), // no gaps in data
      NULL);               // NULL tells GPU to start at 
                           // beginning of bound buffer
                                   
   // Draw triangles using the first three vertices in the 
   // currently bound vertex buffer
    //以下函数调用完成，此时所需要显示的场景已经完全显示或者GPU处理完成后会完全显示；
    //CPU运算和GPU运算是异步的，这个例子的所有代码都是运行在CPU上的，需要进一步处理时会向GPU发送命令；
    //GPU可能也会处理Core Animation层的命令，所以GPU总执行次数不一定；
   glDrawArrays(GL_TRIANGLES,      // STEP 6
      0,  // Start with first vertex in currently bound buffer
      3); // Use three vertices from currently bound buffer
}

//一秒钟30次
- (void)update{
    static int count = 0;
    NSLog(@"%d",count++);
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view has been unloaded
// Perform clean-up that is possible when you know the view 
// controller's view won't be asked to draw again soon.
- (void)viewDidUnload
{
   [super viewDidUnload];
   
   // Make the view's context current
   GLKView *view = (GLKView *)self.view;
   [EAGLContext setCurrentContext:view.context];
    
   // Delete buffers that aren't needed when view is unloaded
   if (0 != vertexBufferID)
   {
      glDeleteBuffers (1,          // STEP 7 
                       &vertexBufferID);  
      vertexBufferID = 0;
   }
   
   // Stop using the context created in -viewDidLoad
   ((GLKView *)self.view).context = nil;
   [EAGLContext setCurrentContext:nil];
}

@end
