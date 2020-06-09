//
//  Hexasphere.m
//  Hexasphere
//
//  Created by Peter Easdown on 28/06/2016.
//

#import "Hexasphere.h"
#import "HSHexasphere.h"
#import "Utilities.h"
#import "MutableTileTexture.h"
#if !TARGET_OS_OSX
#import "UIImage+PixelData.h"
#endif
#import <GLKit/GLKit.h>
#import "HexNode.h"

@interface Hexasphere()

@property (nonatomic) SCNVector3 *oneMeshVertices;
@property (nonatomic) UInt32 *oneMeshIndices;
@property (nonatomic) SCNVector3 *oneMeshNormals;
@property (nonatomic) TextureCoord *oneMeshTextureCoordinates;
@property (nonatomic, retain) SCNMaterial *oneMeshMaterial;
@property (nonatomic) CGImageRef colorMapImage;
@property (nonatomic, retain) MutableTileTexture *tileTexture;

@end

@implementation Hexasphere {
#if TARGET_OS_OSX
    NSBitmapImageRep* imageRep;
#endif
}

/*!
 * Returns YES if the specified latitude/longitude is considered to be land in the speciied image.  This is signified by
 * a black pixel.
 */
- (BOOL) isLandInImage:(UIImage*)image atLat:(float)lat andLong:(float)lon {
#if TARGET_OS_OSX
    if (imageRep == nil) {
        imageRep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
    }
    
    NSUInteger x = imageRep.pixelsWide * (lon + 180.0) / 360.0;
    NSUInteger y = imageRep.pixelsHigh * (lat + 90.0) / 180.0;

    NSColor* color = [imageRep colorAtX:x y:y];
    
    GLubyte pixelColor = (GLubyte)(color.redComponent * 255.0);
#else
    NSUInteger x = image.size.width * (lon + 180.0) / 360.0;
    NSUInteger y = image.size.height * (lat + 90.0) / 180.0;

    GLubyte pixelColor = [image redColorAtPosition:CGPointMake(x, y)];
#endif

    return (pixelColor == 0);
}

/*!
 * Initialises a Hexaspehere node with the specified radius.  numDivisions is used to define the amount of detail
 * that is shown in the result, and hexSize is the size of each hex where 1.0 has all hexes touching their
 * neighbours.
 */
- (instancetype) initWithRadius:(float)radius numDivisions:(NSUInteger)numDivisions andHexSize:(float)hexSize {
    self = [super init];
    
    if (self != nil) {
#if TARGET_OS_OSX
        imageRep = nil;
#endif

        // create the initial hexasphere using internal structures; this object is the actual port of the original
        // Hexasphere.js code by Rob Scanlon.
        //
        HSHexasphere *internalSphere = [HSHexasphere hexasphereWithRadius:radius numDivisions:numDivisions andHexSize:hexSize];

        // Now create a SceneKit node from the hexasphere, whee all tiles become part of a single node, rather than
        // trying to get SceneKit to render thousands of nodes.
        //
        // First off, iterate through the tiles and determine which are land.
        //
        UIImage *image = [UIImage imageNamed:@"equirectangle_projection.png"];

        for (HSTile *tile in internalSphere.tiles) {
            HSLatLong latLon = [tile getLatLongForRadius:internalSphere.radius];
            
            if ([self isLandInImage:image atLat:latLon.lat andLong:latLon.lon] == YES) {
                tile.isLand = 1;
            } else {
                tile.isLand = 0;
            }
        }

        UInt16 indices[] = {0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 5};
        
        NSMutableArray *oneMeshElements = [NSMutableArray array];
        
        NSUInteger oneMeshVertexCount = ((internalSphere.tiles.count) * 6);
        NSUInteger oneMeshIndiceCount = (12 * 9) + ((internalSphere.tiles.count-12) * 12);
        
        self.oneMeshVertices = malloc(oneMeshVertexCount * sizeof(SCNVector3));
        self.oneMeshNormals = malloc(oneMeshVertexCount * 3 * sizeof(SCNVector3));
        self.oneMeshIndices = malloc(oneMeshIndiceCount * sizeof(UInt32));

        // We colour each tile individually by using a texture and mapping each tile ID to
        // a coordinate that can be derived from the tile ID.
        //
        self.oneMeshTextureCoordinates = malloc(oneMeshVertexCount * sizeof(TextureCoord));
        
        UInt32 vertexIndex = 0;
        NSUInteger indiceIndex = 0;
        NSUInteger normalIndex = 0;

        // For this demo, hexNodes is unnecesary, however it's handy if you are adding this to your own
        // project and you want access to each HexNode (where each represents a virtual tile within the
        // Hexasphere).
        self.hexNodes = [NSMutableArray arrayWithCapacity:internalSphere.tiles.count];
        
#ifdef DEBUG
        NSTimeInterval startBuild = [NSDate timeIntervalSinceReferenceDate];
#endif

        NSUInteger tileCount = 0;
        
        for (HSTile *tile in internalSphere.tiles) {
            // Only add land tiles
            //
            if (tile.isLand == 1) {
                for (int i = 0; i < tile.boundaryLength; i++) {
                    self.oneMeshVertices[vertexIndex+i] = [tile boundaryPointAtIndex:i];
                    
                    self.oneMeshTextureCoordinates[vertexIndex+i] = [MutableTileTexture textureCoordForTileID:tile.tileID normalised:YES];
                    
                    self.oneMeshNormals[normalIndex] =
                    [Hexasphere computeNormalFor:[tile boundaryPointAtIndex:0]
                                         b:[tile boundaryPointAtIndex:1]
                                      andC:[tile boundaryPointAtIndex:2]];
                    normalIndex += 1;
                }
                
                NSUInteger indicesNeeded = (tile.boundaryLength - 2) * 3;
                
                for (int i = 0; i < indicesNeeded; i++) {
                    self.oneMeshIndices[indiceIndex+i] = vertexIndex + indices[i];
                }
                
                [self.hexNodes addObject:[HexNode hexNodeWithTile:tile]];
                
                vertexIndex += tile.boundaryLength;
                
                indiceIndex += indicesNeeded;
                
                tileCount++;
            }
        }
        
        NSLog(@"Whole world tile count: %lu", (unsigned long)internalSphere.tiles.count);
        NSLog(@"Land mass tile count: %lu", (unsigned long)tileCount);
        NSLog(@"vertex count: %u", (unsigned int)vertexIndex);
        NSLog(@"indice count: %lu", (unsigned long)indiceIndex);

        // Now that we have all the data, populate the various SceneKit structures ahead of creating
        // the geometry
        //
        // This is all of the indicies, that map the coordinates of each triangle to vertices
        //
        NSData *indiceData = [NSData dataWithBytes:self.oneMeshIndices length:sizeof(UInt32) * indiceIndex];

        // Create a mesh of triangles using the indices.
        //
        SCNGeometryElement *oneMeshElement =
            [SCNGeometryElement geometryElementWithData:indiceData
                                          primitiveType:SCNGeometryPrimitiveTypeTriangles
                                         primitiveCount:indiceIndex / 3
                                          bytesPerIndex:sizeof(UInt32)];
        [oneMeshElements addObject:oneMeshElement];

        // Create a source specifying the normal of each vertex.
        //
        SCNGeometrySource *oneMeshNormalSource =
            [SCNGeometrySource geometrySourceWithNormals:self.oneMeshNormals count:normalIndex];

        // Create a source of the vertices.
        //
        SCNGeometrySource *oneMeshVerticeSource =
            [SCNGeometrySource geometrySourceWithVertices:self.oneMeshVertices count:vertexIndex];

        // Create a texture map that tells SceneKit where in the material to get colour information for
        // each vertex.
        //
        SCNGeometrySource *textureMappingSource =
        [SCNGeometrySource geometrySourceWithData:[NSData dataWithBytes:self.oneMeshTextureCoordinates
                                                                 length:sizeof(TextureCoord) * vertexIndex]
                                         semantic:SCNGeometrySourceSemanticTexcoord
                                      vectorCount:vertexIndex
                                  floatComponents:YES
                              componentsPerVector:2
                                bytesPerComponent:sizeof(float)
                                       dataOffset:0
                                       dataStride:sizeof(TextureCoord)];

        // Create the geometry, at last.
        //
        SCNGeometry *oneMeshGeom =
            [SCNGeometry geometryWithSources:[NSArray arrayWithObjects:oneMeshVerticeSource, oneMeshNormalSource, textureMappingSource, nil]
                                    elements:oneMeshElements];

        // Now load the default texture (it must be a 1024x1024 PNG)  The size is referenced inside
        // UIImage.textureCoordForTileID:
        //
        self.tileTexture = [MutableTileTexture tileTextureWithImage:[UIImage imageNamed:@"texturemap.png"]];
        self.colorMapImage = [self.tileTexture tileTextureImage];

        self.oneMeshMaterial = [SCNMaterial material];
        self.oneMeshMaterial.diffuse.contents = (__bridge id _Nullable)(self.colorMapImage);

        self.oneMeshMaterial.doubleSided = YES;
        self.oneMeshMaterial.locksAmbientWithDiffuse = YES;

        oneMeshGeom.materials = @[self.oneMeshMaterial];

        SCNNode *node = [SCNNode nodeWithGeometry:oneMeshGeom];
        node.name = @"sphere";
        [self addChildNode:node];
        
        free(self.oneMeshVertices);
        self.oneMeshVertices = nil;
        free(self.oneMeshNormals);
        self.oneMeshNormals = nil;
        free(self.oneMeshIndices);
        self.oneMeshIndices = nil;
        free(self.oneMeshTextureCoordinates);
        self.oneMeshTextureCoordinates = nil;
        
#ifdef DEBUG
        NSTimeInterval endBuild = [NSDate timeIntervalSinceReferenceDate];
        NSLog(@"build time taken: %fl", (endBuild - startBuild));
#endif

        internalSphere = nil;
    }
    
    return self;
}

/*!
 * Is supposed the compute the normal for threee vectors.  Not entirely convinced it works as expected.
 */
+ (SCNVector3) computeNormalFor:(SCNVector3)a b:(SCNVector3)b andC:(SCNVector3)c {
    GLKVector3 ga = SCNVector3ToGLKVector3(a);
    GLKVector3 gb = SCNVector3ToGLKVector3(b);
    GLKVector3 gc = SCNVector3ToGLKVector3(c);
    return SCNVector3FromGLKVector3(GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(gb, ga), GLKVector3Subtract(gc, ga))));
}

/*!
 * Returns a Hexaspehere node with the specified radius.  numDivisions is used to define the amount of detail
 * that is shown in the result, and hexSize is the size of each hex where 1.0 has all hexes touching their
 * neighbours.
 */
+ (Hexasphere*) hexasphereWithRadius:(float)radius numDivisions:(NSUInteger)numDivisions andHexSize:(float)hexScale {
    return [[Hexasphere alloc] initWithRadius:radius numDivisions:numDivisions andHexSize:hexScale];
}

/*!
 * Use this to change the colour of a specific hex tile in the hexasphere.  Be warned, that this should be done within
 * the SceneKit renderer thread.
 */
- (void) updateTile:(TileID)tileID withColor:(UIColor*)color {
    [self.tileTexture setPixelForTileID:tileID toColor:color];
    self.colorMapImage = [self.tileTexture tileTextureImage];
    self.oneMeshMaterial.diffuse.contents = (__bridge id _Nullable)(self.colorMapImage);
}

@end
