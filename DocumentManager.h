//
//  DocumentManager.h
//  Bypass3
//
//  Created by Liangjun Jiang on 5/24/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentManager : NSObject

+ (BOOL)isFileExistedAtDocument:(NSString *)fileName;

+ (void)copyFileFromBundleToDocument:(NSString*)fileName;

+ (NSString *)filePathInDocument:(NSString*)fileName;

+ (void)removeFileInDocument:(NSString *)fileName;
+ (NSMutableArray *)fileListInDocument;
@end
