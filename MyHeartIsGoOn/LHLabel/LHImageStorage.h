//
//  LHImageStorage.h
//  MyHeartIsGoOn
//
//  Created by bangong on 16/5/30.
//  Copyright © 2016年 auto. All rights reserved.
//

#import "LHTextStorage.h"

@interface LHImageStorage : LHTextStorage

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) CGSize imageSize;


-(void)drawImageAttributeString:(NSMutableAttributedString *)attributeString;

@end
