//
//  HexNode.m
//  Hexasphere
//
//  Created by Peter Easdown on 14/07/2016.
//

#import "HexNode.h"
#import "Utilities.h"
#import "Hexasphere.h"

@implementation HexNode {
    
    NSUInteger internal_hashValue;
    SCNVector3 _boundary[6];
    GLubyte _boundaryLength;
}

- (id) initWithTile:(HSTile*)tile {
    self = [super init];
    
    if (self != nil) {
        HSLatLong latLon = [tile getLatLongForRadius:tile.sphereRadius];
        _latitude = GLKMathDegreesToRadians(latLon.lat);
        _longitude = GLKMathDegreesToRadians(latLon.lon);
        _position = tile.centrePoint;
        _tileID = tile.tileID;
        _neighbors = [[NSIndexSet alloc] initWithIndexSet:tile.neighbors];
        
        internal_hashValue = [Utilities hashValueForGeographicalPosition:CGPointMake(_longitude, _latitude)];
        
        _boundaryLength = tile.boundaryLength;
        
        for (NSUInteger index = 0; index < _boundaryLength; index++) {
            _boundary[index] = [tile boundaryPointAtIndex:index];
        }
    }
    
    return self;
}

+ (HexNode*) hexNodeWithTile:(HSTile*)tile {
    return [[HexNode alloc] initWithTile:tile];
}

- (NSString*) debugDescription {
    return [NSString stringWithFormat:@"hhexNode %d at: latitude %-3.2f, longitude %-3.2f, sides: %lu", (unsigned int)self.tileID, GLKMathRadiansToDegrees(_latitude), GLKMathRadiansToDegrees(_longitude), (unsigned long)_boundaryLength];

}

- (NSUInteger) sides {
    return _boundaryLength;
}

#define EQUALITY_FACTOR (0.0139626 / 1.5)

- (BOOL) matchesLatitude:(float)latitude andLongitude:(float)longitude {
    return (fabsf((-latitude) - _latitude) < EQUALITY_FACTOR) && (fabsf(longitude - _longitude) < EQUALITY_FACTOR);
}

- (float) latitude {
    return -_latitude;
}

- (NSUInteger) hash {
    return internal_hashValue;
}

- (GLubyte) boundaryLength {
    return _boundaryLength;
}

- (SCNVector3) boundaryPointAtIndex:(NSUInteger)boundaryIndex {
    return _boundary[boundaryIndex];
}

- (BOOL) isAdjacentTo:(HexNode*)otherNode {
    return [self.neighbors containsIndex:otherNode.tileID];
}

@end
