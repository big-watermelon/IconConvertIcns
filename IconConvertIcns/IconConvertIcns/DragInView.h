//
//  DragInView.h
//  IconConvertIcns
//
//  Created by Tenorshare Developer on 2019/1/11.
//  Copyright © 2019 xxxxxx. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void(^DragInViewBlock)(NSString *dragInPath);
@interface DragInView : NSView

@property (nonatomic, assign) BOOL isDragIn;

@property (nonatomic, strong) IBInspectable NSColor *bgColor;

@property (nonatomic, copy) NSString *dragInPath;

@property (nonatomic, copy) DragInViewBlock dragInBlock;


@end
