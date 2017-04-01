//
//  objectExtension.c
//  HSDashedLine
//
//  Created by zwb on 17/2/7.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

#include "objectExtension.h"

void _msgSend(struct objc_super *objc_, op selector){
    
    id (* functionImplementation)(struct objc_super *a, op b);
    *(void **)(&functionImplementation)=dlsym(RTLD_DEFAULT, "_TFC14FirstSwiftTest12ASampleClass13aTestFunctionfS0_FT_CSo8NSString");
    
    void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
    
    char *error;
    
    if ((error=dlerror()) != NULL){
        printf("Method not found! \n");
    }else{
        functionImplementation(objc_, selector);
        
        msgSend(objc_, selector);
    }
}
