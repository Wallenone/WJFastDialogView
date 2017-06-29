//
//  EZJFastDialogView.h
//  EZJFastDialogView
//
//  Created by Easy233 on 15/12/25.
//  Copyright © 2015年 wallen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^SetDialogViewBlock)(UIView *);
typedef void(^MissCompetionBlock)(void);

@interface EZJFastDialogView : UIView


- (instancetype)init;

- (void)onDisplayDialogView:(SetDialogViewBlock)block;   //显示弹窗

- (void)onTouchBGClose:(MissCompetionBlock)block;   //关闭弹窗

- (void)close:(MissCompetionBlock)completion;

- (void)onClose:(MissCompetionBlock)block;

- (void)setdialogViewWithWidth:(CGFloat )width dialogViewHeight:(CGFloat)height;

@end
