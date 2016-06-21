
//
//  LHImageStorage.m
//  MyHeartIsGoOn
//
//  Created by bangong on 16/5/30.
//  Copyright © 2016年 auto. All rights reserved.
//

#import "LHImageStorage.h"
#import <CoreText/CoreText.h>
#import "CZWLabel.h"

//CTRun的回调，销毁内存的回调
void TYTextRunDelegateDeallocCallback( void* refCon ){
    //TYDrawRun *textRun = (__bridge TYDrawRun *)refCon;
    //[textRun DrawRunDealloc];
}

//CTRun的回调，获取高度
CGFloat TYTextRunDelegateGetAscentCallback(void *refCon){
    LHImageStorage *imageStorage = (__bridge LHImageStorage *)refCon;
    
    return imageStorage.imageSize.height;
}

CGFloat TYTextRunDelegateGetDescentCallback(void *refCon){
    
    return 0;
}

//CTRun的回调，获取宽度
CGFloat TYTextRunDelegateGetWidthCallback(void *refCon){
    
    LHImageStorage *imageStorage = (__bridge LHImageStorage *)refCon;
    
    return imageStorage.imageSize.width;
}

@implementation LHImageStorage

-(void)drawImageAttributeString:(NSMutableAttributedString *)attributeString{
    NSRange range  = self.range;
    
    [attributeString replaceCharactersInRange:range withString:[self spaceReplaceString]];
    range = NSMakeRange(range.location, 1);
    self.range = range;
   // 为图片设置CTRunDelegate,delegate决定留给显示内容的空间大小
    CTRunDelegateCallbacks runCallbacks;
    runCallbacks.version = kCTRunDelegateVersion1;
    runCallbacks.dealloc = TYTextRunDelegateDeallocCallback;
    runCallbacks.getAscent = TYTextRunDelegateGetAscentCallback;
    runCallbacks.getDescent = TYTextRunDelegateGetDescentCallback;
    runCallbacks.getWidth = TYTextRunDelegateGetWidthCallback;
    
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&runCallbacks, (__bridge void *)(self));
    [attributeString addAttribute:(__bridge_transfer NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
    [attributeString addAttribute:kLHTextRunAttributedName value:self range:range];
    CFRelease(runDelegate);

}

- (NSString *)spaceReplaceString
{
    // 替换字符
    unichar objectReplacementChar           = 0xFFFC;
    NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
    return objectReplacementString;
}


@end
