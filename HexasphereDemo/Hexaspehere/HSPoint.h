//
//  HSPoint.h
//  Hexasphere
//
//  Created by Peter Easdown on 28/06/2016.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@class HSFace;
@protocol PointChecker;

@interface HSPoint : NSObject

@property (nonatomic, assign) NSUInteger pointId;
@property (nonatomic) SCNVector3 point;
@property (nonatomic, readonly) float x;
@property (nonatomic, readonly) float y;
@property (nonatomic, readonly) float z;
@property (nonatomic, retain) NSMutableArray<HSFace*> *faces;

+ (HSPoint*) pointWithPoint:(SCNVector3)point;
- (NSArray<HSFace*>*) orderedFaces;

- (NSArray<HSPoint*>*) subdividePoint:(HSPoint*)point withCount:(NSUInteger)count andPointChecker:(id<PointChecker>)checker;

+ (SCNVector3) segmentFromCentroid:(SCNVector3)centroid toPoint:(SCNVector3)point withPercent:(float)percent;
- (void) deregisterFace:(HSFace*)face;
- (void) registerFace:(HSFace*)face;
- (BOOL) isPointEqual:(HSPoint*)otherPoint;
- (HSPoint*) projectToRadius:(float)radius;
- (HSPoint*) projectToRadius:(float)radius withPercentage:(float)percent;
- (SCNVector3) surfaceTangent;
+ (SCNVector3) surfaceTangentForPoint:(SCNVector3)point;

@end

@protocol PointChecker

- (HSPoint*) addPointIfNotPresent:(HSPoint*)point;

@end
