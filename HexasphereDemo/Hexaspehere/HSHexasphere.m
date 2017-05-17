//
//  HSHexasphere.m
//  Hexasphere
//
//  Created by Peter Easdown on 28/06/2016.
//

#import "HSHexasphere.h"
#import "HSPoint.h"
#import "HSFace.h"
#import "HSTile.h"
#import "Utilities.h"

@implementation HSHexasphere {
    
    NSMutableArray<HSPoint*> *points;
    
}

- (instancetype)initWithRadius:(float)radius numDivisions:(NSUInteger)numDivisions andHexSize:(float)hexSize {
    self = [super init];
    
    if (self) {
        _radius = radius;
        float tao = 1.61803399;
        
        NSMutableArray *corners = [NSMutableArray arrayWithObjects:
                            [HSPoint pointWithPoint:SCNVector3Make(       1000.0,  tao * 1000.0,          0.0)],
                            [HSPoint pointWithPoint:SCNVector3Make(      -1000.0,  tao * 1000.0,          0.0)],
                            [HSPoint pointWithPoint:SCNVector3Make(       1000.0, -tao * 1000.0,          0.0)],
                            [HSPoint pointWithPoint:SCNVector3Make(      -1000.0, -tao * 1000.0,          0.0)],
                            [HSPoint pointWithPoint:SCNVector3Make(          0.0,        1000.0,  tao * 1000.0)],
                            [HSPoint pointWithPoint:SCNVector3Make(          0.0,       -1000.0,  tao * 1000.0)],
                            [HSPoint pointWithPoint:SCNVector3Make(          0.0,        1000.0, -tao * 1000.0)],
                            [HSPoint pointWithPoint:SCNVector3Make(          0.0,       -1000.0, -tao * 1000.0)],
                            [HSPoint pointWithPoint:SCNVector3Make( tao * 1000.0,           0.0,        1000.0)],
                            [HSPoint pointWithPoint:SCNVector3Make(-tao * 1000.0,           0.0,        1000.0)],
                            [HSPoint pointWithPoint:SCNVector3Make( tao * 1000.0,           0.0,       -1000.0)],
                            [HSPoint pointWithPoint:SCNVector3Make(-tao * 1000.0,           0.0,       -1000.0)],
                            nil];
        
        points = [NSMutableArray arrayWithArray:corners];
        
        NSMutableArray *faces = [NSMutableArray arrayWithObjects:
                          [HSFace faceWithPoint1:corners[0] point2:corners[1] point3:corners[4] andRegister:NO],
                          [HSFace faceWithPoint1:corners[1] point2:corners[9] point3:corners[4] andRegister:NO],
                          [HSFace faceWithPoint1:corners[4] point2:corners[9] point3:corners[5] andRegister:NO],
                          [HSFace faceWithPoint1:corners[5] point2:corners[9] point3:corners[3] andRegister:NO],
                          [HSFace faceWithPoint1:corners[2] point2:corners[3] point3:corners[7] andRegister:NO],
                          [HSFace faceWithPoint1:corners[3] point2:corners[2] point3:corners[5] andRegister:NO],
                          [HSFace faceWithPoint1:corners[7] point2:corners[10] point3:corners[2] andRegister:NO],
                          [HSFace faceWithPoint1:corners[0] point2:corners[8] point3:corners[10] andRegister:NO],
                          [HSFace faceWithPoint1:corners[0] point2:corners[4] point3:corners[8] andRegister:NO],
                          [HSFace faceWithPoint1:corners[8] point2:corners[2] point3:corners[10] andRegister:NO],
                          [HSFace faceWithPoint1:corners[8] point2:corners[4] point3:corners[5] andRegister:NO],
                          [HSFace faceWithPoint1:corners[8] point2:corners[5] point3:corners[2] andRegister:NO],
                          [HSFace faceWithPoint1:corners[1] point2:corners[0] point3:corners[6] andRegister:NO],
                          [HSFace faceWithPoint1:corners[11] point2:corners[1] point3:corners[6] andRegister:NO],
                          [HSFace faceWithPoint1:corners[3] point2:corners[9] point3:corners[11] andRegister:NO],
                          [HSFace faceWithPoint1:corners[6] point2:corners[10] point3:corners[7] andRegister:NO],
                          [HSFace faceWithPoint1:corners[3] point2:corners[11] point3:corners[7] andRegister:NO],
                          [HSFace faceWithPoint1:corners[11] point2:corners[6] point3:corners[7] andRegister:NO],
                          [HSFace faceWithPoint1:corners[6] point2:corners[0] point3:corners[10] andRegister:NO],
                          [HSFace faceWithPoint1:corners[9] point2:corners[1] point3:corners[11] andRegister:NO],
                          nil
                          ];
        
        [corners removeAllObjects];
        corners = nil;
        
        NSMutableArray *newFaces = [NSMutableArray array];
        
        WeakSelf
        
        StrongSelf
        
        for (HSFace *face in faces) {
            NSArray<HSPoint*> *prev = nil;
            
            NSArray<HSPoint*> *bottom = [NSArray arrayWithObject:face.points[0]];
            NSArray<HSPoint*> *left = [face.points[0] subdividePoint:face.points[1] withCount:numDivisions andPointChecker:strongSelf];
            NSArray<HSPoint*> *right = [face.points[0] subdividePoint:face.points[2] withCount:numDivisions andPointChecker:strongSelf];
            
            for (NSUInteger i = 1; i <= numDivisions; i++) {
                prev = bottom;
                bottom = [left[i] subdividePoint:right[i] withCount:i andPointChecker:strongSelf];
                
                for (NSUInteger j = 0; j < i; j++) {
                    [newFaces addObject:[HSFace faceWithPoint1:prev[j] point2:bottom[j] point3:bottom[j+1]]];
                    
                    if (j > 0) {
                        [newFaces addObject:[HSFace faceWithPoint1:prev[j-1] point2:prev[j] point3:bottom[j]]];
                    }
                }
            }
        }
        
        for (HSPoint *point in points) {
            [point projectToRadius:radius];
        }
        
        self.tiles = [NSMutableArray array];
        
        for (HSPoint *p in points){
            [self.tiles addObject:[HSTile tileWithCentrePoint:p inSphereWithRadius:radius withHexSize:hexSize]];
        }
        
        for (HSFace *face in faces) {
            [face deregister];
        }
        
        for (HSFace *face in newFaces) {
            [face deregister];
        }
        
        [newFaces removeAllObjects];
        newFaces = nil;
        
        [points removeAllObjects];
        points = nil;
        
        [faces removeAllObjects];
        faces = nil;
    }
    
    return self;
}


+ (HSHexasphere*) hexasphereWithRadius:(float)radius numDivisions:(NSUInteger)numDivisions andHexSize:(float)hexSize {
    return [[HSHexasphere alloc] initWithRadius:radius numDivisions:numDivisions andHexSize:hexSize];
}

- (void) dealloc {
    [points removeAllObjects];
    points = nil;
    [self.tiles removeAllObjects];
    self.tiles = nil;
}

- (HSPoint*) addPointIfNotPresent:(HSPoint*)point {
    for (HSPoint *thisPoint in points) {
        if ([thisPoint isPointEqual:point] == YES) {
            return thisPoint;
        }
    }
    
    [points addObject:point];
    
    return point;
}

/*!
 * Iterates through all of the tiles, and for those that are marked as being land, compute what other tiles are neighbors.
 */
- (void) determineNeighbors {
    [self.tiles enumerateObjectsUsingBlock:^(HSTile * _Nonnull tileToCheck, NSUInteger idx, BOOL * _Nonnull stop) {
        if (tileToCheck.isLand == 1) {
            [tileToCheck.neighbors removeAllIndexes];

            [self.tiles enumerateObjectsUsingBlock:^(HSTile * _Nonnull potentialNeighbor, NSUInteger idx, BOOL * _Nonnull stop) {
                if ((potentialNeighbor.tileID != tileToCheck.tileID) && (potentialNeighbor.isLand == 1)) {
                    if ([tileToCheck isAdjacentTo:potentialNeighbor] == YES) {
                        [tileToCheck.neighbors addIndex:potentialNeighbor.tileID];
                        [potentialNeighbor.neighbors addIndex:tileToCheck.tileID];
                    }
                }

                if (tileToCheck.neighbors.count == tileToCheck.boundaryLength) {
                    *stop = YES;
                }
            }];
        }

        if (tileToCheck.tileID % 100 == 0) {
            NSLog(@"determineNeighbors tile: %d", (unsigned int)tileToCheck.tileID);
        }
    }];
}

@end
