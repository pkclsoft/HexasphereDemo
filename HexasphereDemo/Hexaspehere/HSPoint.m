//
//  HSPoint.m
//  Hexasphere
//
//  Created by Peter Easdown on 28/06/2016.
//

#import "HSPoint.h"
#import "HSFace.h"

@implementation HSPoint {
    long cachedComparisonValue;
}

static NSUInteger static_pointId = 0;

- (id) initWithPoint:(SCNVector3)point {
    self = [super init];
    
    if (self != nil) {
        _pointId = static_pointId++;

        self.point = point;
        self.faces = [NSMutableArray array];
    }
    
    return self;
}

+ (HSPoint*) pointWithPoint:(SCNVector3)point {
    return [[HSPoint alloc] initWithPoint:point];
}

- (void) dealloc {
    [self.faces removeAllObjects];
    self.faces = nil;
}

- (float) x {
    return _point.x;
}

- (float) y {
    return _point.y;
}

- (float) z {
    return _point.z;
}

- (void) setPoint:(SCNVector3)point {
    _point = point;

    [self updateCachedComparisonValue];
}

- (void) updateCachedComparisonValue {
    cachedComparisonValue = ((long)(roundf(self.x*100.0)) * 1000000000) +
    ((long)(roundf(self.y*100.0)) * 1000000) +
    (long)(roundf(self.z*100.0));
}

- (NSArray<HSPoint*>*) subdividePoint:(HSPoint*)point withCount:(NSUInteger)count andPointChecker:(id<PointChecker>)checker {
    NSMutableArray<HSPoint*> *segments = [NSMutableArray arrayWithCapacity:count];
    
    [segments addObject:self];
    
    for (NSUInteger i = 1; i < count; i++) {
        float iOverCount = (float)i / (float)count;
        HSPoint *np = [HSPoint pointWithPoint:SCNVector3Make(_point.x * (1-iOverCount) + point.x * iOverCount,
                                                             _point.y * (1-iOverCount) + point.y * iOverCount,
                                                             _point.z * (1-iOverCount) + point.z * iOverCount)];

        np = [checker addPointIfNotPresent:np];
        [segments addObject:np];
    }
    
    [segments addObject:point];
    
    NSArray *result = [NSArray arrayWithArray:segments];
    [segments removeAllObjects];
    
    return result;
}

+ (SCNVector3) segmentFromCentroid:(SCNVector3)centroid toPoint:(SCNVector3)point withPercent:(float)percent {
    percent = MAX(0.01, MIN(1.0, percent));

    SCNVector3 vector = SCNVector3Make(point.x * (1.0-percent) + centroid.x * percent,
                                       point.y * (1.0-percent) + centroid.y * percent,
                                       point.z * (1.0-percent) + centroid.z * percent);

    return vector;
}

- (HSPoint*) projectToRadius:(float)radius {
    return [self projectToRadius:radius withPercentage:1.0];
}

- (HSPoint*) projectToRadius:(float)radius withPercentage:(float)percent {
    percent = MAX(0.0, MIN(1.0, percent));
    
    float mag = sqrtf(powf(_point.x, 2.0) + powf(_point.y, 2.0) + powf(_point.z, 2.0));
    float ratio = radius / mag;
    
    _point.x = _point.x * ratio * percent;
    _point.y = _point.y * ratio * percent;
    _point.z = _point.z * ratio * percent;

    [self updateCachedComparisonValue];
    
    return self;
}

- (SCNVector3) surfaceTangent {
    return [HSPoint surfaceTangentForPoint:_point];
}

+ (SCNVector3) surfaceTangentForPoint:(SCNVector3)point {
    float r = sqrtf(powf(point.x, 2.0) + powf(point.y, 2.0) + powf(point.z, 2.0));
    float theta = acosf(point.z/r);
    float phi = atan2f(point.y, point.x);
    
    //then add pi/2 to theta or phi
    
    return SCNVector3Make(sinf(theta) * cosf(phi), sinf(theta) * sinf(phi), cosf(theta));
}

- (void) deregisterFace:(HSFace*)face {
    [self.faces removeObject:face];
}

- (void) registerFace:(HSFace*)face {
    [self.faces addObject:face];
}

- (BOOL) isPointEqual:(HSPoint*)otherPoint {
    return [self comparisonValue] == [otherPoint comparisonValue];
}

- (NSArray<HSFace*>*) orderedFaces {
    NSMutableArray<HSFace*> *mutableResult = [NSMutableArray arrayWithCapacity:self.faces.count];
    NSMutableArray<HSFace*> *workingArray = [NSMutableArray arrayWithArray:self.faces];
    
    NSUInteger i = 0;
    
    while (i < self.faces.count) {
        if (i == 0) {
            [mutableResult addObject:[workingArray objectAtIndex:i]];
            [workingArray removeObjectAtIndex:i];
        } else {
            BOOL hit = NO;
            NSUInteger j = 0;
            
            while ((j < workingArray.count) && (hit == NO)) {
                if ([workingArray[j] isAdjacentTo:mutableResult[i-1]] == YES) {
                    hit = YES;
                    [mutableResult addObject:workingArray[j]];
                    [workingArray removeObjectAtIndex:j];
                }
                
                j++;
            }

            if (hit == NO) {
                NSLog(@"no adjacent faces");
            }
        }
        
        i++;
    }
    
    NSArray *result = [NSArray arrayWithArray:mutableResult];
    [mutableResult removeAllObjects];
    [workingArray removeAllObjects];
    
    return result;
}

- (HSFace*) commonFace:(HSPoint*)other notThisFace:(HSFace*)notThisFace {
    for (HSFace* thisFace in self.faces) {
        for (HSFace* otherFace in other.faces) {
            if ((thisFace.faceId == otherFace.faceId) && (thisFace.faceId != notThisFace.faceId)) {
                return thisFace;
            }
        }
    }
    
    return nil;
}

- (long) comparisonValue {
    return cachedComparisonValue;
}

- (NSString*) debugDescription {
    return [NSString stringWithFormat:@"HSPoint at %@", self.description];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%2.2f, %2.2f, %2.2f", roundf(_point.x * 100.0) / 100.0, roundf(_point.y * 100.0) / 100.0, roundf(_point.z * 100.0) / 100.0];
}

@end
