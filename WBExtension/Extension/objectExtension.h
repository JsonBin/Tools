//
//  objectExtension.h
//  HSDashedLine
//
//  Created by zwb on 17/2/8.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

#ifndef objectExtension_h
#define objectExtension_h

#include <stdio.h>
#include <dlfcn.h>
#include <objc/message.h>

typedef struct objc_selector *op;

void _msgSend(struct objc_super *objc_, op selector);

#endif /* objectExtension_h */
