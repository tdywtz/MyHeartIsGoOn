//
//  LHDrawView.m
//  MyHeartIsGoOn
//
//  Created by bangong on 16/6/16.
//  Copyright © 2016年 auto. All rights reserved.
//

#import "LHDrawView.h"
#import <CoreText/CoreText.h>

//CTRun的回调，销毁内存的回调
void LHTextRunDelegateDeallocCallback( void* refCon ){
    //TYDrawRun *textRun = (__bridge TYDrawRun *)refCon;
    //[textRun DrawRunDealloc];
}

//CTRun的回调，获取高度
CGFloat LHTextRunDelegateGetAscentCallback(void *refCon){
    LHDrawView *drawView = (__bridge LHDrawView *)refCon;
    
    return drawView.size.height;
}

CGFloat LHTextRunDelegateGetDescentCallback(void *refCon){
    
    return 0;
}

//CTRun的回调，获取宽度
CGFloat LHTextRunDelegateGetWidthCallback(void *refCon){
    
    LHDrawView *drawView = (__bridge LHDrawView *)refCon;
    
    return drawView.size.width;
}

@implementation LHDrawView

-(void)drawViewAttributeString:(NSMutableAttributedString *)attributeString{
    NSRange range  = self.range;
    
    [attributeString replaceCharactersInRange:range withString:[self spaceReplaceString]];
    range = NSMakeRange(range.location, 1);
    self.range = range;
    //为图片设置CTRunDelegate,delegate决定留给显示内容的空间大小
    CTRunDelegateCallbacks runCallbacks;
    runCallbacks.version = kCTRunDelegateVersion1;
    runCallbacks.dealloc = LHTextRunDelegateDeallocCallback;
    runCallbacks.getAscent = LHTextRunDelegateGetAscentCallback;
    runCallbacks.getDescent = LHTextRunDelegateGetDescentCallback;
    runCallbacks.getWidth = LHTextRunDelegateGetWidthCallback;
    
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&runCallbacks, (__bridge void *)(self));
    [attributeString addAttribute:(__bridge_transfer NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
    CFRelease(runDelegate);
    
//    [attributeString enumerateAttributesInRange:NSMakeRange(0, attributeString.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
//        
//        //NSLog(@"%ld,%ld",range.location,range.length);
//    }];
//    
}

- (NSString *)spaceReplaceString
{
    // 替换字符
    unichar objectReplacementChar           = 0xFFFC;
    NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
    return objectReplacementString;
}


@end
