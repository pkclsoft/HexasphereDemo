//
//  HSFace.h
//  Hexasphere
//
//  Created by Peter Easdown on 28/06/2016.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@class HSPoint;

@interface HSFace : NSObject

@property (nonatomic, assign) NSUInteger faceId;
@property (nonatomic, readonly) SCNVector3 centroid;
@property (nonatomic, retain) NSArray<HSPoint*> *points;

+ (HSFace*) faceWithPoint1:(HSPoint*)point1 point2:(HSPoint*)point2 point3:(HSPoint*)point3;
+ (HSFace*) faceWithPoint1:(HSPoint*)point1 point2:(HSPoint*)point2 point3:(HSPoint*)point3 andRegister:(BOOL)registering;

- (BOOL) isAdjacentTo:(HSFace*)face;

- (void) deregister;

@end
