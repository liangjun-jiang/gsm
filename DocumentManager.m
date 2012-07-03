//
//  DocumentManager.m
//  Bypass3
//
//  Created by Liangjun Jiang on 5/24/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import "DocumentManager.h"

@implementation DocumentManager
+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}


+ (BOOL)isFileExistedAtDocument:(NSString *)fileName
{
    NSString *documentsDirectory = [self documentsDirectory];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    return [fileManager fileExistsAtPath:path];
}

+ (NSString *)filePathInDocument:(NSString*)fileName{
    NSString *documentsDirectory = [self documentsDirectory];
//    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+ (void)copyFileFromBundleToDocument:(NSString*)fileName{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![self isFileExistedAtDocument:fileName]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath:[self filePathInDocument:fileName] error:&error];
    }
}

+ (void)removeFileInDocument:(NSString *)fileName{
    NSString *filePath = [self filePathInDocument:fileName];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager removeItemAtPath: filePath error: &error] == NO)
    {
        // Directory removal failed.
        NSLog(@"Remove failed!");
    }
}

+ (NSMutableArray *)fileListInDocument
{
    NSError *error;
    NSMutableArray *fileList = [NSMutableArray array];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsDirectory] error:&error];
    
    // We only need txt file
    for (NSString *fileName in files){
        if ([fileName rangeOfString:@".plist"].location!=NSNotFound) {
            [fileList addObject:fileName];
        }
    }
    return fileList;
}

@end
