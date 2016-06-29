//
//  LHLabel.h
//  autoService
//
//  Created by bangong on 16/5/9.
//  Copyright © 2016年 车质网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHImageStorage.h"
#import "LHLinkStorage.h"
#import "LHDrawView.h"

@interface LHLabel : UIView

@property (nonatomic,copy)   NSString                  *text;
@property (nonatomic,strong) NSAttributedString        *attributedText;

@property (nonatomic,strong) UIColor                   *textColor;
@property (nonatomic,strong) UIFont                    *font;

//自动布局设置最大宽度
@property (nonatomic,assign) CGFloat          preferredMaxLayoutWidth;
//文字四周间距
@property (nonatomic,assign) UIEdgeInsets     textInsets;
/**字距（0无效）*/
@property (nonatomic,assign) CGFloat          characterSpace;
/**下划线样式*/
@property (nonatomic,assign) NSUnderlineStyle UnderlineStyle;

@property (nonatomic,assign) NSInteger        numberOfLines;

//段落样式
/**换行模式*/
@property (nonatomic,assign)    NSLineBreakMode lineBreakMode;
/**行距*/
@property (nonatomic,assign)    CGFloat         lineSpacing;
/**段落距离*/
@property (nonatomic,assign)    CGFloat         paragraphSpacing;
/**对其方式*/
@property (nonatomic,assign)    NSTextAlignment alignment;
/** 段落首行距离左边长度*/
@property (nonatomic,assign)    CGFloat         firstLineHeadIndent;
/**除去首行段落距离左边长度 */
@property (nonatomic,assign)    CGFloat         headIndent;
/**段落宽度*/
@property (nonatomic,assign)    CGFloat         tailIndent;
/**段落前空白距离*/
@property (nonatomic,assign)    CGFloat         paragraphSpacingBefore;

@property (nonatomic,copy)      void(^click)(LHTextStorage * storage);

//
-(instancetype)initWithClickBlock:(void(^)(LHTextStorage * storage))block;

#pragma mark - 

- (void)addLinkData:(id)data range:(NSRange)range;
- (void)addLinkData:(id)data rangeOfString:(NSString *)string;

- (void)addImage:(UIImage *)image data:(id)data size:(CGSize)size range:(NSRange)range;
- (void)addImage:(UIImage *)image data:(id)data size:(CGSize)size rangeOfString:(NSString *)string;

- (void)addView:(UIView *)view size:(CGSize)size rangeOfString:(NSString *)string;

@end
