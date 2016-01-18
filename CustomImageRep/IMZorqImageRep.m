//
//  ZorqImageRep.m
//  SVGParserTest
//
//  Created by Freddie Tilley on 18-01-16.
//  Copyright © 2016 Impending. All rights reserved.
//

#import "IMZorqImageRep.h"

#define kZorqHeaderSize 12
#define kZorqMagicHeaderNo 0x51524F5A
#define kZorqBytesPerPixel 4
#define kZorqBitsPerComponent 8

#define kZorqMaxPixelsWidth 10000
#define kZorqMaxPixelsHeight 10000

@interface IMZorqImageRep ()

@property (assign) CGImageRef backingImage;

@end

@implementation IMZorqImageRep

+ (NSArray<NSString *> *)imageUnfilteredTypes {
    static dispatch_once_t pred;
    static NSArray *types = nil;

    dispatch_once(&pred, ^{
        types = @[@"public.zorq-image"];
    });

    return types;
}

+ (NSArray<NSString *> *)imageUnfilteredFileTypes {
    static dispatch_once_t pred;
    static NSArray *fileTypes = nil;

    dispatch_once(&pred, ^{
        fileTypes = @[@"zorq"];
    });

    return fileTypes;
}

- (void)dealloc {
    CGImageRelease(_backingImage);
}

+ (BOOL)canInitWithData:(NSData *)data
{
    uint32_t zorqType;
    BOOL validData = NO;

    if (data != nil && data.length >= kZorqHeaderSize) {
        [data getBytes: &zorqType range: NSMakeRange(0,4)];

        if (zorqType == kZorqMagicHeaderNo) {
            validData = YES;
        }
    }

    return validData;
}

+ (nullable instancetype)imageRepWithData:(NSData*)data {
    if ([[self class] canInitWithData: data]) {
        return [[[self class] alloc] initWithData: data];
    } else {
        return nil;
    }
}

- (nullable instancetype)initWithData:(NSData *)data
{
    self = [self init];

    if (self != nil)
    {
        uint32_t width;
        uint32_t height;

        [data getBytes: &width range:NSMakeRange(4,4)];
        [data getBytes: &height range:NSMakeRange(8,4)];

        if ((width > 0 && width <= kZorqMaxPixelsWidth) &&
            (height > 0 && height <= kZorqMaxPixelsHeight))
        {
            self.alpha = YES;
            self.pixelsHigh = height;
            self.pixelsWide = width;
            self.bitsPerSample = 8;
            self.size = NSMakeSize(self.pixelsWide, self.pixelsHigh);

            size_t imageBytes = self.pixelsWide * self.pixelsHigh * kZorqBytesPerPixel;
            void *imageData = malloc(imageBytes);

            if (imageData != NULL)
            {
                memset(imageData, 0, imageBytes);
                NSRange dataRange = NSMakeRange(kZorqHeaderSize, data.length - kZorqHeaderSize);

                if (dataRange.length > imageBytes) {
                    dataRange.length = imageBytes;
                }

                [data getBytes: imageData range: dataRange];

                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

                if (colorSpace != NULL)
                {
                    uint32_t bytesPerRow = width * kZorqBytesPerPixel;

                    CGContextRef context = CGBitmapContextCreate(imageData, width,
                            height, self.bitsPerSample,
                            bytesPerRow, colorSpace,
                            kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

                    if (context != NULL) {
                        _backingImage = CGBitmapContextCreateImage(context);
                        CGContextRelease(context);
                    }

                    CGColorSpaceRelease(colorSpace);
                }

                free(imageData);
            }
        }
    }

    if (_backingImage == NULL) {
        NSLog(@"Unable to create Zorq image");
        return nil;
    } else {
        return self;
    }
}

- (BOOL)drawInRect:(NSRect)rect
{
    CGContextDrawImage([[NSGraphicsContext currentContext] graphicsPort],
                       NSRectToCGRect(rect), _backingImage);

    return YES;
}

- (BOOL)draw {
    NSRect drawRect = NSMakeRect(0.0f, 0.0f, self.size.width, self.size.height);
    return [self drawInRect: drawRect];
}

@end
