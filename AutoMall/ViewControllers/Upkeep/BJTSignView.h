//
//  BJTSignView.h
//  BJTResearch
//
//  Created by ljy on 2018/5/4.
//  Copyright © 2018年 ljy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BJTSignView : UIView
/**
 * 获取签名图片
 */
- (UIImage *)getSignatureImage;
/**
 * 清除签名
 */
- (void)clearSignature;
@end
