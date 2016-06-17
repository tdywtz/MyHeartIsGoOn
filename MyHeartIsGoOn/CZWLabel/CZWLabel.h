//
//  LHLabel.h
//  autoService
//
//  Created by bangong on 16/5/9.
//  Copyright © 2016年 车质网. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZWLabel : UILabel

@property (nonatomic,strong) NSMutableAttributedString *attributeString;

//文字四周间距
@property (nonatomic,assign) UIEdgeInsets     textInsets;
/**字距（0无效）*/
@property (nonatomic,assign) CGFloat          characterSpace;

//段落样式
/**行距*/
@property (nonatomic,assign) CGFloat         linesSpacing;
/**段落距离*/
@property(nonatomic,assign) CGFloat         paragraphSpacing;
/** 段落首行距离左边长度*/
@property(nonatomic,assign) CGFloat         firstLineHeadIndent;
/**除去首行段落距离左边长度 */
@property(nonatomic,assign) CGFloat         headIndent;
/**段落宽度*/
@property(nonatomic,assign) CGFloat         tailIndent;
/**段落前空白距离*/
@property(nonatomic,assign) CGFloat         paragraphSpacingBefore;

- (void)addColor:(UIColor *)color range:(NSRange)range;
- (void)insertImage:(UIImage *)image size:(CGSize)size index:(NSInteger)index;
- (void)addImage:(UIImage *)image size:(CGSize)size range:(NSRange)range;

@end
