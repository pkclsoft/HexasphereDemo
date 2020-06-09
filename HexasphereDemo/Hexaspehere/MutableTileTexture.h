//
//  MutableTileTexture.h
//  LetItShine
//
//  Created by Peter Easdown on 24/10/18.
//

#import <Foundation/Foundation.h>
#import "HSTile.h"

NS_ASSUME_NONNULL_BEGIN

@interface MutableTileTexture : NSObject

typedef struct {
    float x;
    float y;
} TextureCoord;

+ (MutableTileTexture*) tileTextureWithImage:(UIImage*)initialImage;

- (CGImageRef) tileTextureImage;

- (void) setPixelForTileID:(TileID)tileID toColor:(UIColor*)color;
- (void) setPixelForTileIDs:(NSIndexSet*)tileIDs toColor:(UIColor*)color;

+ (TextureCoord) textureCoordForTileID:(TileID)tileID normalised:(BOOL)normalised;

@end

NS_ASSUME_NONNULL_END
