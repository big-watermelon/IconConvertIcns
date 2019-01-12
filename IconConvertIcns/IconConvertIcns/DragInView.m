//
//  DragInView.m
//  IconConvertIcns
//
//  Created by Tenorshare Developer on 2019/1/11.
//  Copyright © 2019 xxxxxx. All rights reserved.
//

#import "DragInView.h"
#import "NSTask+Terminal.h"
@implementation DragInView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupDefault];
    }
    return self;
}

- (void)setupDefault
{
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];  
}

#pragma mark - Drap
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pb = [sender draggingPasteboard];
    NSArray *types = [pb types];
    if ([types containsObject:NSFilenamesPboardType]) {
        NSArray *pathArr = [pb propertyListForType:NSFilenamesPboardType];
        if (pathArr.firstObject) {
            NSString *path = pathArr.firstObject;
            self.isDragIn = YES;
            self.dragInPath = path;
        }
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    if (_isDragIn) {
        return NSDragOperationCopy;
    }else{
        return NSDragOperationNone;
    }
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    if (self.isDragIn) {
        return YES;
    }else{
        return NO;
    }
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    if (self.dragInBlock && self.isDragIn) {
        self.dragInBlock(self.dragInPath);
    }
    self.isDragIn = NO;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    self.isDragIn = NO;
}

- (void)setBgColor:(NSColor *)bgColor
{
    _bgColor = bgColor;
    self.wantsLayer = YES;
    self.layer.backgroundColor = bgColor.CGColor;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
