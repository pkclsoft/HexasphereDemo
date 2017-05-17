//
//  HSHexasphere.h
//  Hexasphere
//
//  Created by Peter Easdown on 28/06/2016.
//

#import <Foundation/Foundation.h>
#import "HSPoint.h"
#import "HSFace.h"
#import "HSTile.h"

@interface HSHexasphere : NSObject <PointChecker>

@property (nonatomic, assign) float radius;
@property (nonatomic) NSMutableArray<HSTile*> *tiles;

+ (HSHexasphere*) hexasphereWithRadius:(float)radius numDivisions:(NSUInteger)numDivisions andHexSize:(float)hexSize;

/*!
 * Iterates through all of the tiles, and for those that are marked as being land, compute what other tiles are neighbors.
 */
- (void) determineNeighbors;

@end
