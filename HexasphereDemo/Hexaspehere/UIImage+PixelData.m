//
//  UIImage+PixelData.m
//  Hexasphere
//
//  Created by Peter Easdown on 29/06/2016.
//

#import "UIImage+PixelData.h"

@implementation UIImage (PixelData)

- (GLubyte) redColorAtPosition:(CGPoint)position {
    
    CGRect sourceRect = CGRectMake(position.x, position.y, 1.f, 1.f);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, sourceRect);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *buffer = malloc(4);
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef context = CGBitmapContextCreate(buffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0.f, 0.f, 1.f, 1.f), imageRef);
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    GLubyte r = buffer[0];

    free(buffer);
    
    return r;
}

+ (UIImage*) setPixelForTileIDs:(NSIndexSet*)tileIDs inImage:(UIImage*)image toColor:(UIColor*)color {
    CGImageRef imageRef = [image CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bitmapByteCount = bytesPerRow * height;
    
    unsigned char *rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextSetAllowsAntialiasing(context, false);
    CGContextSetShouldAntialias(context, false);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorRef cgColor = [color CGColor];
    const CGFloat *components = CGColorGetComponents(cgColor);
    float r = components[0];
    float g = components[1];
    float b = components[2];
    float a = components[3]; // not needed
    
    r = r * 255.0;
    g = g * 255.0;
    b = b * 255.0;
    a = 255.0;
    
    [tileIDs enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TextureCoord coord = [UIImage textureCoordForTileID:(TileID)idx normalised:NO];
        
        int byteIndex = (width*coord.y+coord.x)*4; //the index of pixel(x,y) in the 1d array pixels
        
        rawData[byteIndex] = r;
        rawData[byteIndex + 1] = g;
        rawData[byteIndex + 2] = b;
        rawData[byteIndex + 3] = a;
    }];
    
    
    CGImageRef imgref = CGBitmapContextCreateImage(context);
    UIImage *result = [UIImage imageWithCGImage:imgref];
    
    CGImageRelease(imgref);
    CGContextRelease(context);
    free(rawData);
    
    return result;
}

+ (TextureCoord) textureCoordForTileID:(TileID)tileID normalised:(BOOL)normalised {
    TextureCoord result;
    
    result.x = (float)((tileID % 256) * 4);
    result.y = (float)((tileID / 256) * 4);
    
    if (normalised == YES) {
        result.x += 0.5;
        result.x /= 1024.0;
        result.y += 0.5;
        result.y /= 1024.0;
    }
    
    return result;
}

+ (UIImage*) setPixelForTileID:(TileID)tileID inImage:(UIImage*)image toColor:(UIColor*)color {
    return [UIImage setPixelForTileIDs:[NSIndexSet indexSetWithIndex:tileID] inImage:image toColor:color];
}


@end
