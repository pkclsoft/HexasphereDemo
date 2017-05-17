//
//  HSTile.m
//  Hexasphere
//
//  Created by Peter Easdown on 28/06/2016.
//

#import "HSTile.h"
#import "HSPoint.h"
#import <GLKit/GLKit.h>

@implementation HSTile {
    
    SCNVector3 _boundary[6];
    GLubyte _boundaryLength;
}

static TileID static_tileId = 0;

+ (void) resetTileID {
    static_tileId = 0;
}

- (id) initWithCentre:(HSPoint*)centrePoint inSphereWithRadius:(float)radius withHexSize:(float)hexSize {
    self = [super init];
    
    if (self != nil) {
        _tileID = static_tileId++;
        _sphereRadius = radius;
        _isLand = 0;
        _neighbors = [NSMutableIndexSet indexSet];

        self.hexSize = MAX(0.01, MIN(1.0, hexSize));
        
        self.centrePoint = centrePoint.point;
        
        NSArray<HSFace*> *faces = [centrePoint orderedFaces];
        _boundaryLength = faces.count;
      
        NSUInteger index = 0;
        for (HSFace *face in faces) {
            _boundary[index++] = [HSPoint segmentFromCentroid:face.centroid toPoint:centrePoint.point withPercent:self.hexSize];
        }
        
        faces = nil;
    }
    
    return self;
}

+ (HSTile*) tileWithCentrePoint:(HSPoint*)centrePoint inSphereWithRadius:(float)radius {
    return [[HSTile alloc] initWithCentre:centrePoint inSphereWithRadius:radius withHexSize:1.0];
}

+ (HSTile*) tileWithCentrePoint:(HSPoint*)centrePoint inSphereWithRadius:(float)radius withHexSize:(float)hexSize  {
    return [[HSTile alloc] initWithCentre:centrePoint inSphereWithRadius:radius withHexSize:hexSize];
}

- (int) pointIndex:(int)input {
    return (input < 0) ? input + 5 : (input > 5) ? input - 5 : input;
}

- (SCNVector3) midpointBetween:(SCNVector3)v1 and:(SCNVector3)v2 {
    return SCNVector3FromGLKVector3(GLKVector3Lerp(SCNVector3ToGLKVector3(v1), SCNVector3ToGLKVector3(v2), 0.5));
}

- (NSUInteger) dataLength {
    const NSUInteger fixedSize = sizeof(SCNVector3) + sizeof(GLubyte) + sizeof(GLubyte) + sizeof(GLubyte) + sizeof(GLubyte);
    
    return fixedSize + (sizeof(SCNVector3) * _boundaryLength) + (sizeof(TileID) * _neighbors.count);
}

- (HSLatLong) getLatLongForRadius:(float)radius {
    return [self getLatLongForRadius:radius andPoint:_centrePoint];
}

- (HSLatLong) getLatLongForRadius:(float)radius andPoint:(SCNVector3)point {
    float phi = acosf(point.y / radius); //lat
    float theta = fmodf((atan2f(point.x, point.z) + M_PI + M_PI / 2.0), (M_PI * 2.0)) - M_PI; // lon
    
    // theta is a hack, since I want to rotate by Math.PI/2 to start.  sorryyyyyyyyyyy
    HSLatLong result = {
        180.0 * phi / M_PI - 90,
        180.0 * theta / M_PI
    };
    
    return result;
}

- (GLubyte) boundaryLength {
    return _boundaryLength;
}

- (SCNVector3) boundaryPointAtIndex:(NSUInteger)boundaryIndex {
    return _boundary[boundaryIndex];
}

- (NSString*) debugDescription {
    return [NSString stringWithFormat:@"HSTile[%lul]", (unsigned long)self.tileID];
}

- (BOOL) isFloat:(float)a equalTo:(float)b {
    return ( fabsf(a - b) < 0.002 );
}

- (BOOL) isAdjacentTo:(HSTile*)otherTile {
    NSUInteger count = 0;

    for (NSUInteger pIndex = 0; pIndex < _boundaryLength; pIndex++) {
        for (NSUInteger opIndex = 0; opIndex < otherTile.boundaryLength; opIndex++) {
            SCNVector3 a = _boundary[pIndex];
            SCNVector3 b = [otherTile boundaryPointAtIndex:opIndex];

            if ([self isFloat:a.x equalTo:b.x] && [self isFloat:a.y equalTo:b.y] && [self isFloat:a.z equalTo:b.z] == YES) {
                count++;
            }
        }
    }

    return (count == 2);

}

@end
