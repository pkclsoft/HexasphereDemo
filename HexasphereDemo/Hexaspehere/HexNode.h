//
//  HexNode.h
//  Hexasphere
//
//  Created by Peter Easdown on 14/07/2016.
//

#import <SceneKit/SceneKit.h>
#import "HSTile.h"

/*!
 * Servies as a model of a single hex tile in the hexasphere.
 */
@interface HexNode : NSObject

@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) SCNVector3 position;
@property (nonatomic, assign) TileID tileID;
@property (nonatomic, readonly) NSUInteger sides;
@property (nonatomic, retain) NSIndexSet *neighbors;

/*!
 * Creates a hex node representing the specified tile.
 */
+ (HexNode*) hexNodeWithTile:(HSTile*)tile;

/*!
 * Returns YES if this hex node has the same laitude and longitude.
 */
- (BOOL) matchesLatitude:(float)latitude andLongitude:(float)longitude;

/*!
 * Returns the boundary point for the hex node at the specified index.
 */
- (SCNVector3) boundaryPointAtIndex:(NSUInteger)boundaryIndex;

/*!
 * Returns YES if this hex node is adjacent to the specified node.
 */
- (BOOL) isAdjacentTo:(HexNode*)otherNode;

@end
