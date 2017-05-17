//
//  HSTile.h
//  Hexasphere
//
//  Created by Peter Easdown on 28/06/2016.
//

#import <Foundation/Foundation.h>
#import "HSPoint.h"
#import "HSFace.h"

@interface HSTile : NSObject

typedef struct {
    float lat;
    float lon;
} HSLatLong;

typedef NSUInteger TileID;

@property (nonatomic, assign) TileID tileID;
@property (nonatomic, assign) float sphereRadius;
@property (nonatomic, assign) float hexSize;
@property (nonatomic, assign) SCNVector3 centrePoint;
@property (nonatomic, assign) GLubyte isLand;
@property (nonatomic, retain) NSMutableIndexSet *neighbors;

+ (void) resetTileID;

+ (HSTile*) tileWithCentrePoint:(HSPoint*)centrePoint inSphereWithRadius:(float)radius;
+ (HSTile*) tileWithCentrePoint:(HSPoint*)centrePoint inSphereWithRadius:(float)radius withHexSize:(float)hexSize;

- (HSLatLong) getLatLongForRadius:(float)radius;

- (GLubyte) boundaryLength;
- (SCNVector3) boundaryPointAtIndex:(NSUInteger)boundaryIndex;

- (BOOL) isAdjacentTo:(HSTile*)otherTile;

@end
