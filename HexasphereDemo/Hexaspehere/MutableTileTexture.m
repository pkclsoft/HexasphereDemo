//
//  MutableTileTexture.m
//  LetItShine
//
//  Created by Peter Easdown on 24/10/18.
//

#import "MutableTileTexture.h"

@implementation MutableTileTexture {
    
    NSUInteger width;
    NSUInteger height;
    unsigned char *rawData;
    CGContextRef context;
    
}

- (id) initWithImage:(UIImage*)initialImage {
    self = [super init];
    
    if (self != nil) {
#if TARGET_OS_OSX
        CGImageRef imageRef = [initialImage CGImageForProposedRect:nil context:nil hints:nil];
#else
        CGImageRef imageRef = [initialImage CGImage];
#endif
        
        width = CGImageGetWidth(imageRef);
        height = CGImageGetHeight(imageRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        NSUInteger bitmapByteCount = bytesPerRow * height;
        
        rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));
        
        context = CGBitmapContextCreate(rawData, width, height,
                                        bitsPerComponent, bytesPerRow, colorSpace,
                                        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextSetAllowsAntialiasing(context, false);
        CGContextSetShouldAntialias(context, false);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    }
    
    return self;
}

+ (MutableTileTexture*) tileTextureWithImage:(UIImage*)initialImage {
    return [[MutableTileTexture alloc] initWithImage:initialImage];
}

- (void) dealloc {
    CGContextRelease(context);
    free(rawData);
}

- (CGImageRef) tileTextureImage {
    return CGBitmapContextCreateImage(context);
}

- (void) setPixelForTileIDs:(NSIndexSet*)tileIDs toColor:(UIColor*)color {
    CGColorRef cgColor = [color CGColor];
    const CGFloat *components = CGColorGetComponents(cgColor);
    float r = components[0];
    float g = components[1];
    float b = components[2];
    float a = 255.0; //components[3]; // not needed
    
    r = r * 255.0;
    g = g * 255.0;
    b = b * 255.0;
    //a = 255.0;
    
    [tileIDs enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TextureCoord coord = [MutableTileTexture textureCoordForTileID:(TileID)idx normalised:NO];
        
        int byteIndex = (self->width*coord.y+coord.x)*4; //the index of pixel(x,y) in the 1d array pixels
        
        self->rawData[byteIndex] = r;
        self->rawData[byteIndex + 1] = g;
        self->rawData[byteIndex + 2] = b;
        self->rawData[byteIndex + 3] = a;
    }];
}

+ (TextureCoord) textureCoordForTileID:(TileID)tileID normalised:(BOOL)normalised {
    TextureCoord result;
    
    TileID hexasphereLocalTileID = tileID;
    
    result.x = (float)((hexasphereLocalTileID % 256) * 4);
    result.y = (float)((hexasphereLocalTileID / 256) * 4);
    
    if (normalised == YES) {
        result.x += 0.5;
        result.x /= 1024.0;
        result.y += 0.5;
        result.y /= 1024.0;
    }
    
    return result;
}

- (void)    setPixelForTileID:(TileID)tileID toColor:(UIColor*)color {
    [self setPixelForTileIDs:[NSIndexSet indexSetWithIndex:tileID] toColor:color];
}

@end
