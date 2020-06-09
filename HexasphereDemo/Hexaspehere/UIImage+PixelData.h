//
//  UIImage+PixelData.h
//  Hexasphere
//
//  Created by Peter Easdown on 29/06/2016.
//

#import "HSTile.h"

@interface UIImage (PixelData)

/*!
 * Returns the red component of the pixel at the specified position within the image.
 */
- (GLubyte) redColorAtPosition:(CGPoint)position;

@end
