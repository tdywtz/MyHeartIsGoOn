//
//  LHTextStorage.h
//  MyHeartIsGoOn
//
//  Created by bangong on 16/5/19.
//  Copyright © 2016年 auto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LHTextStorage : NSObject

@property (nonatomic,assign) NSRange range;
@property (nonatomic,assign) NSRange releaseRange;
@property (nonatomic,copy) NSString *rangeOfString;
@property (nonatomic,strong) id data;


+ (BOOL)isFontDownloaded:(NSString *)fontName;
+ (void)setup:(NSString *)fontName;

@end
