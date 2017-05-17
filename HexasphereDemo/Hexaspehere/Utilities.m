//
//  Utilities.m
//  Hexasphere
//
//  Created by Peter Easdown on 10/02/2016.
//

#import "Utilities.h"

@implementation Utilities

// Converts an angle in the world where 0 is north in a clockwise direction to a world
// where 0 is east in an anticlockwise direction.
//
+ (float) angleFromDegrees:(float)deg {
    return fmodf((450.0f - deg), 360.0);
}

/*!
 * Returns the signed latitutde (y) and longitude (x) of the given vector3 position from the centre of
 * a sphere with the specified sphereRadius.
 */
+ (CGPoint) geographicalPositionFor:(SCNVector3)vector3 withRadius:(float)sphereRadius {
    float latitude = -((float)acosf(vector3.y / sphereRadius) - M_PI_2); //theta
    float longitude = M_PI - ((float)atan2f(vector3.z, vector3.x)); //phi
    
    if (longitude > M_PI) {
        longitude = longitude - (2.0 * M_PI);
    }

    return CGPointMake(longitude, latitude);
}

/*!
 * Returns a hash value for the given geographical position.
 */
+ (NSUInteger) hashValueForGeographicalPosition:(CGPoint)position {
    return ((long)(roundf((position.y + (2*M_PI))*100.0)) * 1000000) +
    (long)(roundf((position.x + (2*M_PI))*100.0));
}

@end
