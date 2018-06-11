//
//  DlibWrapper.h
//  HigeMaster
//
//  Created by 藤井陽介 on 2018/06/11.
//  Copyright © 2018 touyou. All rights reserved.
//

/// Reference: https://github.com/zweigraf/face-landmarking-ios

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface DlibWrapper : NSObject

- (instancetype)init;
- (NSArray<NSArray<NSValue *> *> *)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects;
- (NSArray<NSValue *> *)doWorkOnPixelBuffer:(CVImageBufferRef)pixelBuffer;
- (void)prepare;

@end
