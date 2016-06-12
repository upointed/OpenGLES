//
//  AGLKView.m
//  
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>


@implementation AGLKView

@synthesize delegate;
@synthesize context;
@synthesize drawableDepthFormat;

/////////////////////////////////////////////////////////////////
// This method returns the CALayer subclass to be used by  
// CoreAnimation with this view
/*
    每个UIView都有一个相关联的Core Animation层；
    Cocoa Touch会调用该方法决定生成一个什么样的层；
    CAEAGLLayer会与一个OGE帧缓存共享它的像素仓库；
 */
+ (Class)layerClass
{
   return [CAEAGLLayer class];
}

/////////////////////////////////////////////////////////////////
// This method is designated initializer for the class

//kEAGLDrawablePropertyRetainedBacking == NO 不使用保留背景告诉Core Animation层任何部分需要在屏幕上显示的时候都需要绘制整个层的内容；
//kEAGLColorFormatRGBA8 使用8位来保存每个像素每个颜色的值；
//AGLKView需要配置一个帧缓存和一个颜色渲染缓存；
//这段代码告诉Core Animation不要试图保留任何以前绘制的图像留作以后重用；
- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)aContext
{
   if ((self = [super initWithFrame:frame]))
   {
      CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
      eaglLayer.drawableProperties = 
         [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithBool:NO], 
             kEAGLDrawablePropertyRetainedBacking, 
             kEAGLColorFormatRGBA8, 
             kEAGLDrawablePropertyColorFormat, 
             nil];
      
      self.context = aContext;
   }
   return self;
}

/////////////////////////////////////////////////////////////////
// This method is called automatically to initialize each Cocoa
// Touch object as the object is unarchived from an 
// Interface Builder .xib or .storyboard file.
//串行化(Serialization)是计算机科学中的一个概念，它是指将对象存储到介质（如文件、内存缓冲区等）中或是以二进制方式通过网络传输，在iOS中也叫做归档。
//该方法是Cocoa Touch用于初始化对象的标准方法之一，Cocoa Touch会自动调用该方法，这是反归档先前归档入一个文件的对象过程的一部分；本例中AGLKView从storyboard文件中加载过程就是反归档；
- (id)initWithCoder:(NSCoder*)coder
{    
   if ((self = [super initWithCoder:coder]))
   {
      CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
      
      eaglLayer.drawableProperties = 
         [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithBool:NO], 
             kEAGLDrawablePropertyRetainedBacking, 
             kEAGLColorFormatRGBA8, 
             kEAGLDrawablePropertyColorFormat, 
             nil];          
   }
   return self;
}
//修改视图的上下文会导致先前创建的所有缓存全部失效，需要配置新的缓存；
//glFramebufferRenderbuffer()用来配置当前绑定的帧缓存以便在colorRenderBuffer中保存渲染的像素颜色；


/////////////////////////////////////////////////////////////////
// This method sets the receiver's OpenGL ES Context. If the 
// receiver already has a different Context, this method deletes
// OpenGL ES Frame Buffer resources in the old Context and the 
// recreates them in the new Context.
- (void)setContext:(EAGLContext *)aContext
{
   if(context != aContext)
   {  // Delete any buffers previously created in old Context
      [EAGLContext setCurrentContext:context];
      
      if (0 != defaultFrameBuffer)
      {
         glDeleteFramebuffers(1, &defaultFrameBuffer); // Step 7
         defaultFrameBuffer = 0;
      }
      
      if (0 != colorRenderBuffer)
      {
         glDeleteRenderbuffers(1, &colorRenderBuffer); // Step 7
         colorRenderBuffer = 0;
      }
      
      if (0 != depthRenderBuffer)
      {
         glDeleteRenderbuffers(1, &depthRenderBuffer); // Step 7
         depthRenderBuffer = 0;
      }
      
      context = aContext;
   
      if(nil != context)
      {  // Configure the new Context with required buffers
         context = aContext;
         [EAGLContext setCurrentContext:context];
                   
         glGenFramebuffers(1, &defaultFrameBuffer);    // Step 1
         glBindFramebuffer(                            // Step 2
            GL_FRAMEBUFFER,             
            defaultFrameBuffer);

         glGenRenderbuffers(1, &colorRenderBuffer);    // Step 1
         glBindRenderbuffer(                           // Step 2
            GL_RENDERBUFFER, 
            colorRenderBuffer);
         
         // Attach color render buffer to bound Frame Buffer
         glFramebufferRenderbuffer(
            GL_FRAMEBUFFER, 
            GL_COLOR_ATTACHMENT0, 
            GL_RENDERBUFFER, 
            colorRenderBuffer);

         // Create any additional render buffers based on the
         // drawable size of defaultFrameBuffer
         [self layoutSubviews];
      }
   }
}


/////////////////////////////////////////////////////////////////
// This method returns the receiver's OpenGL ES Context
- (EAGLContext *)context
{
   return context;
}


/////////////////////////////////////////////////////////////////
// Calling this method tells the receiver to redraw the contents 
// of its associated OpenGL ES Frame Buffer. This method 
// configures OpenGL ES and then calls -drawRect:
- (void)display
{
   [EAGLContext setCurrentContext:self.context];
   glViewport(0, 0, (GLint)self.drawableWidth, (GLint)self.drawableHeight);

   [self drawRect:[self bounds]];
   
   [self.context presentRenderbuffer:GL_RENDERBUFFER];
}


/////////////////////////////////////////////////////////////////
// This method is called automatically whenever the receiver
// needs to redraw the contents of its associated OpenGL ES
// Frame Buffer. This method should not be called directly. Call
// -display instead which configures OpenGL ES before calling
// -drawRect:
- (void)drawRect:(CGRect)rect
{
   if(delegate)
   {
      [self.delegate glkView:self drawInRect:[self bounds]];
   }
}


/////////////////////////////////////////////////////////////////
// This method is called automatically whenever a UIView is
// resized including just after the view is added to a UIWindow.

//任何在接收到重新调整大小的消息时，Cocoa Touch都会调用下面的layoutSubviews；上下文的"renderbufferStorage:fromDrawable"方法会调整视力的缓存尺寸以匹配层的新尺寸；

- (void)layoutSubviews
{
   CAEAGLLayer 	*eaglLayer = (CAEAGLLayer *)self.layer;
   
   // Make sure our context is current
   [EAGLContext setCurrentContext:self.context];

   // Initialize the current Frame Buffer’s pixel color buffer 
   // so that it shares the corresponding Core Animation Layer’s
   // pixel color storage.
   [self.context renderbufferStorage:GL_RENDERBUFFER 
      fromDrawable:eaglLayer];
      
   
   if (0 != depthRenderBuffer)
   {
      glDeleteRenderbuffers(1, &depthRenderBuffer); // Step 7
      depthRenderBuffer = 0;
   }
   
   GLint currentDrawableWidth = (GLint)self.drawableWidth;
   GLint currentDrawableHeight = (GLint)self.drawableHeight;
   
   if(self.drawableDepthFormat != 
      AGLKViewDrawableDepthFormatNone &&
      0 < currentDrawableWidth &&
      0 < currentDrawableHeight)
   {
      glGenRenderbuffers(1, &depthRenderBuffer); // Step 1
      glBindRenderbuffer(GL_RENDERBUFFER,        // Step 2
         depthRenderBuffer);
      glRenderbufferStorage(GL_RENDERBUFFER,     // Step 3 
         GL_DEPTH_COMPONENT16, 
         currentDrawableWidth, 
         currentDrawableHeight);
      glFramebufferRenderbuffer(GL_FRAMEBUFFER,  // Step 4 
         GL_DEPTH_ATTACHMENT, 
         GL_RENDERBUFFER, 
         depthRenderBuffer);
   }
   
   // Check for any errors configuring the render buffer   
   GLenum status = glCheckFramebufferStatus(
      GL_FRAMEBUFFER) ;
     
   if(status != GL_FRAMEBUFFER_COMPLETE) {
       NSLog(@"failed to make complete frame buffer object %x", status);
   }

   // Make the Color Render Buffer the current buffer for display
   glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
}


/*下面通过OpenGLES的glGetRenderbufferParameteriv()方法获取和返回当前上下文的帧缓存的像素颜色渲染缓存尺寸*/

/////////////////////////////////////////////////////////////////
// This method returns the width in pixels of current context's
// Pixel Color Render Buffer
- (NSInteger)drawableWidth;
{
   GLint          backingWidth;

   glGetRenderbufferParameteriv(
      GL_RENDERBUFFER, 
      GL_RENDERBUFFER_WIDTH, 
      &backingWidth);
      
   return (NSInteger)backingWidth;
}


/////////////////////////////////////////////////////////////////
// This method returns the height in pixels of current context's
// Pixel Color Render Buffer
- (NSInteger)drawableHeight;
{
   GLint          backingHeight;

   glGetRenderbufferParameteriv(
      GL_RENDERBUFFER, 
      GL_RENDERBUFFER_HEIGHT, 
      &backingHeight);
      
   return (NSInteger)backingHeight;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically when the reference count 
// for a Cocoa Touch object reaches zero.

- (void)dealloc
{
   // Make sure the receiver's OpenGL ES Context is not current
   if ([EAGLContext currentContext] == context)
   {
      [EAGLContext setCurrentContext:nil];
   }

   // Deletes the receiver's OpenGL ES Context
   context = nil;
}

@end
