//
//  AGLKViewController.m
//  
//

#import "AGLKViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation AGLKViewController

/////////////////////////////////////////////////////////////////
// This constant defines the default number of frame per second
// rate to redraw the receiver's view when the receiver is not
// paused.  
static const NSInteger kAGLKDefaultFramesPerSecond = 30;

/*
 使用一个CADisplayLink对象来调度和执行与控制器相关联的视力的周期性的重绘；
 CADisplayLink本质上是一个用于显示更新的同步计时器，它能够被设置用来在每个显示
 更新或者其他更新时发送一个消息；
 显示更新频率通常是由嵌入设备硬件决定的，它代表一个帧缓存的内容每秒最多能够被在
 屏幕上通过的像素显示出来的次数；
 */

/////////////////////////////////////////////////////////////////
// This method is the designated initializer.
// The receiver's Core Animation displayLink instance is created
// and configured to prompt redraw of the receiver's view
// at the default number of frames per second rate.
- (id)initWithNibName:(NSString *)nibNameOrNil 
   bundle:(NSBundle *)nibBundleOrNil;
{
    if(nil != (self = [super initWithNibName:nibNameOrNil 
       bundle:nibBundleOrNil]))
    {
      displayLink = 
         [CADisplayLink displayLinkWithTarget:self 
            selector:@selector(drawView:)];

      self.preferredFramesPerSecond = 
         kAGLKDefaultFramesPerSecond;

      [displayLink addToRunLoop:[NSRunLoop currentRunLoop] 
         forMode:NSDefaultRunLoopMode];
         
      self.paused = NO;
    }
    
    return self;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically to initialize each Cocoa
// Touch object as the object is unarchived from an 
// Interface Builder .xib or .storyboard file.
// The receiver's Core Animation displayLink instance is created
// and configured to prompt redraw of the receiver's view
// at the default number of frames per second rate.
- (id)initWithCoder:(NSCoder*)coder
{    
   if (nil != (self = [super initWithCoder:coder]))
   {
      displayLink = 
         [CADisplayLink displayLinkWithTarget:self 
            selector:@selector(drawView:)];

      self.preferredFramesPerSecond = 
         kAGLKDefaultFramesPerSecond;

      [displayLink addToRunLoop:[NSRunLoop currentRunLoop] 
         forMode:NSDefaultRunLoopMode];
         
      self.paused = NO;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// This method is called when the view controller's view is 
// loaded and performs initialization before the view is asked 
// to draw.
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // Verify the type of view created automatically by the
   // Interface Builder storyboard
   AGLKView *view = (AGLKView *)self.view;
   NSAssert([view isKindOfClass:[AGLKView class]],
      @"View controller's view is not a AGLKView");
   
   view.opaque = YES;
   view.delegate = self;
}

   
/////////////////////////////////////////////////////////////////
// This method is called when the receiver's view appears and
// unpauses the receiver. 
- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   self.paused = NO;
}


/////////////////////////////////////////////////////////////////
// This method is called when the receiver's view disappears and
// pauses the receiver. 
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
   self.paused = YES;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically and allows all standard 
// device orientations. 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   if ([[UIDevice currentDevice] userInterfaceIdiom] == 
      UIUserInterfaceIdiomPhone) 
   {
       return (interfaceOrientation != 
          UIInterfaceOrientationPortraitUpsideDown);
   } 
   else 
   {
       return YES;
   }
}


/////////////////////////////////////////////////////////////////
// This method is called at the receiver's framesPerSecond rate
// when the receiver is not paused and instructs the receiver's 
// view to redraw.
- (void)drawView:(id)sender
{
   [(AGLKView *)self.view display];
}


/////////////////////////////////////////////////////////////////
// Returns the receiver's framesPerSecond property value.  
- (NSInteger)framesPerSecond;
{
   return 60 / displayLink.frameInterval;
}


/////////////////////////////////////////////////////////////////
// This method returns the desired frames per second rate at for
// redrawing the receiver's view.
- (NSInteger)preferredFramesPerSecond;
{
   return preferredFramesPerSecond;
}


/////////////////////////////////////////////////////////////////
// This method sets the desired frames per second rate at for
// redrawing the receiver's view.
- (void)setPreferredFramesPerSecond:(NSInteger)aValue
{
   preferredFramesPerSecond = aValue;
   
   displayLink.frameInterval = MAX(1, (60 / aValue));
}


/////////////////////////////////////////////////////////////////
// This method returns YES if the receiver is paused and NO 
// otherwise. The receiver does not automatically prompt redraw
// of the receiver's view when paused.
- (BOOL)isPaused
{
   return displayLink.paused;
}


/////////////////////////////////////////////////////////////////
// This method sets whether the receiver is paused. The receiver 
// automatically prompts redraw of the receiver's view 
// unless paused.
- (void)setPaused:(BOOL)aValue
{
   displayLink.paused = aValue;
}


/////////////////////////////////////////////////////////////////
// This required AGLKViewDelegate method does nothing. Subclasses
// of this class may override this method to draw on behalf of
// the receiver's view.
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect;
{
}

@end
