//
//  GLKContext.m
//  
//

#import "AGLKContext.h"

@implementation AGLKContext

/////////////////////////////////////////////////////////////////
// This method sets the clear (background) RGBA color.
// The clear color is undefined until this method is called.
- (void)setClearColor:(GLKVector4)clearColorRGBA
{
   clearColor = clearColorRGBA;
    
   NSAssert(self == [[self class] currentContext],
      @"Receiving context required to be current context");
      
   glClearColor(
      clearColorRGBA.r, 
      clearColorRGBA.g, 
      clearColorRGBA.b, 
      clearColorRGBA.a);
}


/////////////////////////////////////////////////////////////////
// Returns the clear (background) color set via -setClearColor:.
// If no clear color has been set via -setClearColor:, the 
// return clear color is undefined.
- (GLKVector4)clearColor
{
   return clearColor;
}


//clear方法告诉OGE去设置每个在上下文帧缓存中的元素值，颜色为glClearColor()的值；

/////////////////////////////////////////////////////////////////
// This method instructs OpenGL ES to set all data in the
// current Context's Render Buffer(s) identified by mask to
// colors (values) specified via -setClearColor: and/or
// OpenGL ES functions for each Render Buffer type.
- (void)clear:(GLbitfield)mask
{
   NSAssert(self == [[self class] currentContext],
      @"Receiving context required to be current context");
      
   glClear(mask);
}


/////////////////////////////////////////////////////////////////
// 
- (void)enable:(GLenum)capability;
{
   NSAssert(self == [[self class] currentContext],
      @"Receiving context required to be current context");
   
   glEnable(capability);
}


/////////////////////////////////////////////////////////////////
// 
- (void)disable:(GLenum)capability;
{
   NSAssert(self == [[self class] currentContext],
      @"Receiving context required to be current context");
      
   glDisable(capability);
}


/////////////////////////////////////////////////////////////////
// 
- (void)setBlendSourceFunction:(GLenum)sfactor 
   destinationFunction:(GLenum)dfactor;
{
   glBlendFunc(sfactor, dfactor);
}
  
@end
