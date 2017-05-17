//
//  UIImage+PixelData.h
//  Hexasphere
//
//  Created by Peter Easdown on 29/06/2016.
//

#import <UIKit/UIKit.h>
#import "HSTile.h"

@interface UIImage (PixelData)

typedef struct {
    float x;
    float y;
} TextureCoord;

/*!
 * Returns the red component of the pixel at the specified position within the image.
 */
- (GLubyte) redColorAtPosition:(CGPoint)position;

/*!
 * Changes the colour of the pixel represented by the specified tileID to the provided colour.
 */
+ (UIImage*) setPixelForTileID:(TileID)tileID inImage:(UIImage*)image toColor:(UIColor*)color;

/*!
 * Changes the colour of the pixel represented by the specified tileIDs to the provided colour.
 */
+ (UIImage*) setPixelForTileIDs:(NSIndexSet*)tileIDs inImage:(UIImage*)image toColor:(UIColor*)color;

/*!
 * Returns a texture coordinate for the specified tileID, optionally normalised.
 */
+ (TextureCoord) textureCoordForTileID:(TileID)tileID normalised:(BOOL)normalised;

@end
