//
//  HSFace.m
//  Hexasphere
//
//  Created by Peter Easdown on 28/06/2016.
//

#import "HSFace.h"
#import "HSPoint.h"

@implementation HSFace

static NSUInteger static_faceId = 0;

- (id) initWithPoint1:(HSPoint*)point1 point2:(HSPoint*)point2 point3:(HSPoint*)point3 andRegister:(BOOL)registering {
    self = [super init];
    
    if (self != nil) {
        _faceId = static_faceId++;
        
        self.points = [NSArray arrayWithObjects:point1, point2, point3, nil];
        
        if (registering == YES) {
            [point1 registerFace:self];
            [point2 registerFace:self];
            [point3 registerFace:self];
        }
    }
    
    return self;
}

+ (HSFace*) faceWithPoint1:(HSPoint*)point1 point2:(HSPoint*)point2 point3:(HSPoint*)point3 {
    return [[HSFace alloc] initWithPoint1:point1 point2:point2 point3:point3 andRegister:YES];
}

+ (HSFace*) faceWithPoint1:(HSPoint*)point1 point2:(HSPoint*)point2 point3:(HSPoint*)point3 andRegister:(BOOL)registering {
    return [[HSFace alloc] initWithPoint1:point1 point2:point2 point3:point3 andRegister:registering];
}

- (void) deregister {
    for (HSPoint *point in self.points) {
        [point deregisterFace:self];
    }
    
    self.points = nil;
}

- (void) dealloc {
    for (HSPoint *point in self.points) {
        [point deregisterFace:self];
    }
    
    self.points = nil;
}

- (NSArray<HSPoint*>*) otherPointsFor:(HSPoint*)point1 {
    NSMutableArray<HSPoint*> *others = [NSMutableArray array];
    
    for (HSPoint *point in self.points) {
        if ([point isPointEqual:point1] == NO) {
            [others addObject:point];
        }
    }
    
    return [NSArray arrayWithArray:others];
}

- (HSPoint*) thirdPointFromPoint1:(HSPoint*)point1 andPoint2:(HSPoint*)point2 {
    for (HSPoint *point in self.points) {
        if (([point isPointEqual:point1] == NO) && ([point isPointEqual:point2] == NO)) {
            return point;
        }
    }
    
    return nil;
}

- (BOOL) isAdjacentTo:(HSFace*)face {
    // adjacent if 2 of the points are the same
    
    NSUInteger count = 0;
    
    for (HSPoint *point in self.points) {
        for (HSPoint* otherPoint in face.points) {
            if ([point isPointEqual:otherPoint] == YES) {
                count++;
            }
        }
    }
    
    return (count == 2);
}

- (SCNVector3) centroid {
    return
    SCNVector3Make
    ((self.points[0].x + self.points[1].x + self.points[2].x)/3.0,
     (self.points[0].y + self.points[1].y + self.points[2].y)/3.0,
     (self.points[0].z + self.points[1].z + self.points[2].z)/3.0);
}

@end
