//
//  AppDelegate.h
//  HelloOpenGL
//
//  Created by zhanghaiwei on 13-8-7.
//  Copyright (c) 2013年 zhanghaiwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{

OpenGLView* _glView;

}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet OpenGLView *glView;

@end
