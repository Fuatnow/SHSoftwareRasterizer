//
//  SHCanvas.m
//  SHSoftwareRasterizer
//
//  Created by 7heaven on 16/5/12.
//  Copyright © 2016年 7heaven. All rights reserved.
//

#import "SHSoftwareCanvas.h"

#define INSTINCT_SIZE CGSizeMake(20, 20)

@implementation SHSoftwareCanvas{
    CGImageRef _imageBackend;
    unsigned char *_rawData;
    CGSize _backendSize;
    unsigned long _rawDataSize;
    unsigned long _canvasPixelSize;
    
    SHColor _backgroundColor;
    
    SHSoftwareDevice *_nativePtr;
}

- (instancetype) initWithBackgroundColor:(SHColor) color{
    if(self = [super init]){
        _backgroundColor = color;
        [self initProcess];
    }
    
    return self;
}

- (instancetype) init{
    if(self = [super init]){
        [self initProcess];
    }
    
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)coder{
    if(self = [super initWithCoder:coder]){
        [self initProcess];
    }
    
    return self;
}

- (void) initProcess{
    _nativePtr = new SHSoftwareDevice(self);
    
    [self initImageBackend];
}

- (void) initImageBackend{
    
    CGSize size = self.bounds.size.width == 0 ? INSTINCT_SIZE : self.bounds.size;
    
    _canvasPixelSize = size.width * size.height;
    _rawDataSize = _canvasPixelSize * 3;
    
    _rawData = (unsigned char*) malloc(size.height * size.width * 3);
    for(int i = 0; i < _canvasPixelSize; i++){
        _rawData[i * 3] = _backgroundColor.r;
        _rawData[i * 3 + 1] = _backgroundColor.g;
        _rawData[i * 3 + 2] = _backgroundColor.b;
    }
    
    _imageBackend = [self createCGImageWithSize:size];
    self.image = [[NSImage alloc] initWithCGImage:_imageBackend size:size];
}



- (void) drawLineFrom:(SHPoint) p0 to:(SHPoint) p1 color:(SHColor) color{
    float x0 = p0.x;
    float y0 = p0.y;
    float x1 = p1.x;
    float y1 = p1.y;
    int dx = fabsf(x1-x0), sx = x0<x1 ? 1 : -1;
    int dy = fabsf(y1-y0), sy = y0<y1 ? 1 : -1;
    int err = (dx>dy ? dx : -dy)/2, e2;
    
    for(;;){
        [self setPixel:(SHPoint){static_cast<int>(x0), static_cast<int>(y0)} color:color];
        if (x0==x1 && y0==y1) break;
        e2 = err;
        if (e2 >-dx) { err -= dy; x0 += sx; }
        if (e2 < dy) { err += dx; y0 += sy; }
    }
    
}

- (void) setPixel:(SHPoint) position color:(SHColor) color{
    
    int positionOffset = (self.bounds.size.width * position.y + position.x) * 3;
    
    if(positionOffset < 0 || positionOffset > _rawDataSize) return;
    
    _rawData[positionOffset] = color.r;
    _rawData[positionOffset + 1] = color.g;
    _rawData[positionOffset + 2] = color.b;
}

- (void) setPixels:(SHPoint [])positions color:(SHColor)color{
    size_t length = sizeof(positions) / sizeof(positions[0]);
    
    NSLog(@"length:%zu", length);
    
    for(int i = 0; i < length; i++){
        [self setPixel:positions[i] color:color];
    }
}

- (void) flushWithColor:(SHColor) color{
    for(int i = 0; i < _canvasPixelSize; i++){
        _rawData[i * 3] = color.r;
        _rawData[i * 3 + 1] = color.g;
        _rawData[i * 3 + 2] = color.b;
    }
}

- (void) update{
    _imageBackend = [self createCGImageWithSize:self.bounds.size];
    self.image = [[NSImage alloc] initWithCGImage:_imageBackend size:self.bounds.size];
}

- (void) setFrame:(NSRect)frame{
    [super setFrame:frame];
    
    [self initImageBackend];
}

- (CGImageRef) createCGImageWithSize:(CGSize) size{
    
    _backendSize = size;
    
    if(&_backgroundColor == nil){
        _backgroundColor = (SHColor){0xFF, 0xFF, 0xFF, 0xFF};
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                              _rawData,
                                                              _rawDataSize,
                                                              NULL);
    
    CGImageRef image = CGImageCreate(size.width,
                                      size.height,
                                      8,
                                      24,
                                      3 * size.width,
                                      colorSpace,
                                      kCGBitmapByteOrderDefault,
                                      provider,
                                      NULL,
                                      NO,
                                      kCGRenderingIntentDefault);
    
    CFRelease(colorSpace);
    CFRelease(provider);
    
    return image;
}

- (IDevice *) getNativePtr{
    return _nativePtr;
}

- (void) dealloc{
    self.image = nil;
    CFRelease(_imageBackend);
    free(_rawData);
    delete _nativePtr;
}

@end

SHSoftwareDevice::SHSoftwareDevice(SHSoftwareCanvas *canvas){
    this->_canvas = canvas;
}

void SHSoftwareDevice::update(){
    [this->_canvas update];
}

void SHSoftwareDevice::setPixel(SHPoint position, SHColor color){
    [this->_canvas setPixel:position color:color];
}

void SHSoftwareDevice::setPixels(SHPoint *position, SHColor color){
    [this->_canvas setPixels:position color:color];
}

void SHSoftwareDevice::flush(SHColor color){
    [this->_canvas flushWithColor:color];
}
