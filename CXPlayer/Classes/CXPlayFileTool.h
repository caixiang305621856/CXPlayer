//
//  CXPlayFileTool.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/24.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXPlayFileTool : NSObject

+ (NSString *)cachePathWithURL: (NSURL *)url;
+ (NSString *)tmpPathWithURL: (NSURL *)url;

+ (BOOL)isCacheFileExists: (NSURL *)url;
+ (BOOL)isTmpFileExists: (NSURL *)url;

+ (NSString *)contentTypeWithURL: (NSURL *)url;

+ (long long)cacheFileSizeWithURL: (NSURL *)url;
+ (long long)tmpFileSizeWithURL: (NSURL *)url;

+ (void)removeTmpFileWithURL: (NSURL *)url;

+ (void)moveTmpPathToCachePath: (NSURL *)url;

@end
