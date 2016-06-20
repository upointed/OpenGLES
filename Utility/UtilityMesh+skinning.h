//
//  UtilityMesh+skinning.h
//
//

#import "UtilityMesh.h"

/////////////////////////////////////////////////////////////////
// Type used to store vertex skinning attributes
typedef struct
{   
   GLKVector4 jointIndices; // encoded float for Shading Language
   GLKVector4 jointWeights; // weight factor for each joint index
} 
UtilityMeshJointInfluence;//关节索引和权重


@interface UtilityMesh (skinning)

- (void)setJointInfluence:
      (UtilityMeshJointInfluence)aJointInfluence
   atIndex:(GLsizei)vertexIndex;

- (void)prepareToDrawWithJointInfluence;

@end
