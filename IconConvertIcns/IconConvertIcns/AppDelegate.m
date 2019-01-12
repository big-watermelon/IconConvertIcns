//
//  AppDelegate.m
//  IconConvertIcns
//
//  Created by Tenorshare Developer on 2019/1/11.
//  Copyright © 2019 xxxxxx. All rights reserved.
//

#import "AppDelegate.h"
#import "DragInView.h"
#import "NSTask+Terminal.h"


static NSString *const kTmpDirectory = @"tmpIcns";//临时目录名
static NSString *const kTmpDirectorySuffix = @".iconset";//临时目录名后缀

static NSString *const kIcnsName = @"Icon.icns";//最终的icns名字

static NSString *const kHintTitleNormal = @"将图片拖入框中,点击convert,生成icns";
static NSString *const kHintTitleError  = @"不支持该类型图片或文件";
#define kHintTitleNormalColor [NSColor blackColor]
#define kHintTitleErrorColor [NSColor redColor]


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *hintTitle;

@property (weak) IBOutlet DragInView *dragInView;

@property (weak) IBOutlet NSButton *convertButton;
@property (weak) IBOutlet NSButton *openPathButton;
@property (weak) IBOutlet NSImageView *dragInImageView;

@property (nonatomic, copy) NSString *photoName;
@property (nonatomic, copy) NSString *tmpDirectory;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.hintTitle.stringValue = kHintTitleNormal;
    
    __weak typeof(self) weakSelf = self;
    self.dragInView.dragInBlock = ^(NSString *dragInPath) {
        dragInPath = [dragInPath stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
        if (![dragInPath.lastPathComponent.lowercaseString isEqualToString:@"png"]) {
            NSString *tmpPath = [dragInPath.stringByDeletingPathExtension stringByAppendingString:@".png"];
            //将图片转换成png格式
            [NSTask cmd:[NSString stringWithFormat:@"sips -s format png %@ --out %@", dragInPath, tmpPath]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
                weakSelf.dragInView.dragInPath = tmpPath;
            }else{
                weakSelf.convertButton.enabled = NO;
                weakSelf.openPathButton.enabled = NO;
                weakSelf.dragInImageView.image = nil;
                weakSelf.hintTitle.stringValue = kHintTitleError;
                weakSelf.hintTitle.textColor = kHintTitleErrorColor;
                return;
            }
        }
        weakSelf.dragInImageView.image = [[NSImage alloc] initWithContentsOfFile:weakSelf.dragInView.dragInPath];
        weakSelf.convertButton.enabled = YES;
        weakSelf.openPathButton.enabled = NO;
        weakSelf.hintTitle.stringValue = kHintTitleNormal;
        weakSelf.hintTitle.textColor = kHintTitleNormalColor;
    };

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)convert:(id)sender
{
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES).firstObject;
    self.photoName = self.dragInView.dragInPath.lastPathComponent;
    self.tmpDirectory = [directory stringByAppendingFormat:@"/%@%@", kTmpDirectory, kTmpDirectorySuffix];
    NSUInteger tag = 2;
    //若有重复，则增加新的文件夹
    while ([[NSFileManager defaultManager] fileExistsAtPath:self.tmpDirectory]) {
        self.tmpDirectory = [directory stringByAppendingFormat:@"/%@%ld%@", kTmpDirectory, tag++, kTmpDirectorySuffix];
        NSLog(@"tag == %ld", tag);
    }
    //2.在桌面新建临时文件夹
    NSString *command2 = [NSString stringWithFormat:@"mkdir %@;", self.tmpDirectory];
    //3.将图片转化成10张不同分辨率放入临时文件夹
    NSString *command3 = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@",
                          [self getPhotoCommandWithResolution:16 is2x:NO],
                          [self getPhotoCommandWithResolution:32 is2x:YES],
                          [self getPhotoCommandWithResolution:32 is2x:NO],
                          [self getPhotoCommandWithResolution:64 is2x:YES],
                          [self getPhotoCommandWithResolution:128 is2x:NO],
                          [self getPhotoCommandWithResolution:256 is2x:YES],
                          [self getPhotoCommandWithResolution:256 is2x:NO],
                          [self getPhotoCommandWithResolution:512 is2x:YES],
                          [self getPhotoCommandWithResolution:512 is2x:NO],
                          [self getPhotoCommandWithResolution:1024 is2x:YES]];
    //4.将10张图片转成icns
    NSString *command5 = [NSString stringWithFormat:@"iconutil -c icns %@ -o %@/%@;", self.tmpDirectory, self.tmpDirectory, kIcnsName];
    NSString *commandAll = [NSString stringWithFormat:@"%@ %@ %@",  command2, command3,  command5];
    [NSTask cmd: commandAll];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", self.tmpDirectory, kIcnsName]]) {
        self.openPathButton.enabled = YES;
    }
}

- (NSString *)getPhotoCommandWithResolution:(NSUInteger)resolution is2x:(BOOL)is2x
{/*
  @"sips -z 16 16     pic.png --out tmp.iconset/icon_16x16.png",
  @"sips -z 32 32     pic.png --out tmp.iconset/icon_16x16@2x.png"
  */
    NSString *sizeString = @"";
    if (is2x) {
        sizeString = [NSString stringWithFormat:@"%ldx%ld@2x", resolution/2, resolution/2];
    }else{
        sizeString = [NSString stringWithFormat:@"%ldx%ld", resolution, resolution];
    }
    return [NSString stringWithFormat:@"sips -z %ld %ld %@ --out %@/icon_%@.png;",resolution, resolution, self.dragInView.dragInPath, self.tmpDirectory, sizeString];
}

- (IBAction)openPath:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:self.tmpDirectory];
}



@end
