//
//  SKUtilities.h
//  Hexasphere
//
//  Created by Peter Easdown on 10/02/2016.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <SceneKit/SceneKit.h>

/*! 
 * Provides some utility methods for use throughout the app.
 */
@interface Utilities : NSObject

/*!
 * Returns the signed latitutde (y) and longitude (x) of the given vector3 position from the centre of
 * a sphere with the specified sphereRadius.
 */
+ (CGPoint) geographicalPositionFor:(SCNVector3)vector3 withRadius:(float)sphereRadius;

/*!
 * Returns a hash value for the given geographical position.
 */
+ (NSUInteger) hashValueForGeographicalPosition:(CGPoint)position;

#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongSelf __typeof__(self) strongSelf = weakSelf;

@end
