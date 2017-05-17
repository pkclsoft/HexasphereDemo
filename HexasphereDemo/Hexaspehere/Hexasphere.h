//
//  Hexasphere.h
//  Hexasphere
//
//  Created by Peter Easdown on 28/06/2016.
//

#import <SceneKit/SceneKit.h>
#import "HexNode.h"

@interface Hexasphere : SCNNode

/*!
 * Returns a Hexaspehere node with the specified radius.  numDivisions is used to define the amount of detail
 * that is shown in the result, and hexSize is the size of each hex where 1.0 has all hexes touching their
 * neighbours.
 */
+ (Hexasphere*) hexasphereWithRadius:(float)radius numDivisions:(NSUInteger)numDivisions andHexSize:(float)hexSize;

/*!
 * Is supposed the compute the normal for threee vectors.  Not entirely convinced it works as expected.
 */
+ (SCNVector3) computeNormalFor:(SCNVector3)a b:(SCNVector3)b andC:(SCNVector3)c;

@property (nonatomic, retain) NSMutableArray<HexNode*> *hexNodes;

/*!
 * Use this to change the colour of a specific hex tile in the hexasphere.  Be warned, that this should be done within
 * the SceneKit renderer thread.
 */
- (void) updateTile:(TileID)tileID withColor:(UIColor*)color;

@end
