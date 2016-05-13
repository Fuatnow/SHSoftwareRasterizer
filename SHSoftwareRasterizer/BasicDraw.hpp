//
//  BasicDraw.h
//  SHSoftwareRasterizer
//
//  Created by 7heaven on 16/5/13.
//  Copyright © 2016年 7heaven. All rights reserved.
//

#ifndef BasicDraw_h
#define BasicDraw_h

#include <stdio.h>
#include "BasicGeometry.h"
#include "IDevice.h"

namespace sh{

    class BasicDraw{
    public:
        static void drawLine(IDevice &device, SHPoint p0, SHPoint p1, SHColor color);
    };
    
}

#endif /* BasicDraw_h */