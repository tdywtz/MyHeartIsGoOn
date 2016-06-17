//
//  LHDrawView.h
//  MyHeartIsGoOn
//
//  Created by bangong on 16/6/16.
//  Copyright © 2016年 auto. All rights reserved.
//

#import "LHTextStorage.h"

@interface LHDrawView : LHTextStorage

@property (nonatomic,strong) UIView *view;
@property (nonatomic,assign) CGSize size;

-(void)drawViewAttributeString:(NSMutableAttributedString *)attributeString;

@end
