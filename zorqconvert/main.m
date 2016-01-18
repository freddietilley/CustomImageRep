//
//  main.m
//  zorqconvert
//
//  Created by Freddie Tilley on 18-01-16.
//  Copyright © 2016 Impending. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kZorqHeaderSize 12
#define kZorqMagicHeaderNo 0x51524F5A
#define kZorqBytesPerPixel 4
#define kZorqBitsPerComponent 8

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc == 3) {
            NSString *sourcePath = [[NSString stringWithUTF8String: argv[1]] stringByExpandingTildeInPath];
            NSString *destPath = [[NSString stringWithUTF8String: argv[2]] stringByExpandingTildeInPath];
            NSImage *sourceImage = nil;

            if (![[destPath pathExtension] isEqualToString: @"zorq"]) {
                destPath = [destPath stringByAppendingPathExtension:@"zorq"];
            }

            if (![[NSFileManager defaultManager] fileExistsAtPath: sourcePath])
            {
                NSLog(@"Error: Source image does not exist!");
                exit(0);
            }

            if ([[NSFileManager defaultManager] fileExistsAtPath: destPath])
            {
                NSLog(@"Error: Destination image already exists at path!");
                exit(0);
            }
            
            sourceImage = [[NSImage alloc] initWithContentsOfFile: sourcePath];

            if (sourceImage == nil) {
                NSLog(@"Error: Invalid source image!");
                exit(0);
            } else {
				uint32_t magicNo = kZorqMagicHeaderNo;
				uint32_t width = sourceImage.size.width;
				uint32_t height = sourceImage.size.height;
				size_t imageBytes = width * height * kZorqBytesPerPixel;
				void *imageData = malloc(imageBytes);

				if (imageData != NULL)
				{
					CGRect imageRect = CGRectMake(0.0f, 0.0f, sourceImage.size.width, sourceImage.size.height);

					NSGraphicsContext *context = [NSGraphicsContext currentContext];
					CGImageRef imageRef = [sourceImage CGImageForProposedRect: &imageRect
																	  context: context
																		hints: nil];
					if (imageRef != NULL)
					{
						CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

						if (colorSpace != NULL)
						{
							uint32_t bytesPerRow = width * kZorqBytesPerPixel;
							uint32_t bitsPerComponent = 8;

							CGContextRef context = CGBitmapContextCreate(imageData, width,
									height, bitsPerComponent, bytesPerRow, colorSpace,
									kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

							if (context != NULL)
							{
								NSMutableData *zorqData = [NSMutableData dataWithCapacity: (kZorqHeaderSize + imageBytes)];
								CGContextDrawImage(context, imageRect, imageRef);
								CGContextRelease(context);

								[zorqData appendBytes: &magicNo length: sizeof(uint32_t)];
								[zorqData appendBytes: &width length: sizeof(uint32_t)];
								[zorqData appendBytes: &height length: sizeof(uint32_t)];

								[zorqData appendBytes: imageData length: imageBytes];

								if (![[NSFileManager defaultManager] createFileAtPath: destPath
																			 contents: zorqData
																		   attributes: nil])
								{
                                    NSLog(@"Error: Unable to open output file for writing!");
                                    exit(0);
								}
							} else {
								NSLog(@"Error: Unable create create bitmap context");
								exit(0);
							}

							CGColorSpaceRelease(colorSpace);
						} else {
							NSLog(@"Error: Unable to create colorspace");
							exit(0);
						}
					} else {
						NSLog(@"Error: Unable to get source image pixel data");
						exit(0);
					}

					free(imageData);
				} else {
					NSLog(@"Error: Unable to allocate memory for pixel data (out of memory?)");
					exit(0);
				}
            }

            NSLog(@"convert source: %@ to zorq dest: %@", sourcePath, destPath);
        } else {
			NSString *commandName = [[NSString stringWithUTF8String: argv[0]] lastPathComponent];
			NSLog(@"Usage: %@ source_image dest_image", commandName);
            exit(0);
		}
    }
    return 0;
}
