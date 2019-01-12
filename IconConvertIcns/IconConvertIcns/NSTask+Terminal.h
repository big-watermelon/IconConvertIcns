//
//  NSTask+Terminal.h
//  IconConvertIcns
//
//  Created by Tenorshare Developer on 2019/1/11.
//  Copyright © 2019 xxxxxx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTask (Terminal)

/**
 使用终端执行命令

 @param cmd 命令行 多行用;隔开
 @return 运行结果
 */
+ (NSString *)cmd:(NSString *)cmd;

@end
