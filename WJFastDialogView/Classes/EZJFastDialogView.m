//
//  EZJFastDialogView.m
//  EZJFastDialogView
//
//  Created by Easy233 on 15/12/25.
//  Copyright © 2015年 wallen. All rights reserved.
//

#import "EZJFastDialogView.h"
#import <Accelerate/Accelerate.h>
#define EZJCColor(r, g, b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define JCiOS7OrLater ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)

@interface EZJSingleTon : NSObject
@property (nonatomic,assign) BOOL alertReady;//是否弹窗
@end

@implementation EZJSingleTon

+ (instancetype)shareSingleTon{
    static EZJSingleTon *shareSingleTonInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareSingleTonInstance = [EZJSingleTon new];
    });
    return shareSingleTonInstance;
}

@end

@interface  EZJFastDialogView()
@property (nonatomic, assign)BOOL modal;  //模态 (是否强制点击窗口关闭) true为点击弹窗外关闭，false为点击弹窗关闭
@end


@implementation EZJFastDialogView{
    SetDialogViewBlock setDialogViewBlock;
    MissCompetionBlock missCompetionBlock;
    UIView *customView;
    UIView *dialogView;
    UIButton *coverView;
    UIImageView *screenShotView;
    
}

- (instancetype)init{
    customView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self=[super initWithFrame:customView.bounds];
    if (self){}
    return self;
}


- (void)show{
    if (![EZJSingleTon shareSingleTon].alertReady) {
        [self addSubview:customView];
        //[self addScreenShot];
        [self addCoverView];
        [self addDialogView];
        [self showDialog];
        [EZJSingleTon shareSingleTon].alertReady=true;
        
        
    }
}

- (void)setdialogViewWithWidth:(CGFloat )width dialogViewHeight:(CGFloat)height{
    [dialogView setFrame:CGRectMake(0, 0, width, height)];
    dialogView.center=coverView.center;
    
}

- (void)onDisplayDialogView:(SetDialogViewBlock)block{
    if (block) {
        [self show];
        setDialogViewBlock=block;
        setDialogViewBlock(dialogView);
        
    }
}

- (void)close:(MissCompetionBlock)completion{
    if (completion) {
        missCompetionBlock=completion;
    }
    [self dismissWithCompletion:^{
        if (missCompetionBlock) {
            missCompetionBlock();
        }
        
    }];
}


- (void)onClose:(MissCompetionBlock)block{
    if (block) {
        missCompetionBlock=block;
    }
}



- (void)onTouchBGClose:(MissCompetionBlock)block{
    if (block) {
        missCompetionBlock=block;
        self.modal=true;
    }
}


//弹窗view出来的时候动画
- (void)showDialog{
    CGFloat duration = 0.3;
    CGFloat delay=0;
    
    for (UIButton *btn in customView.subviews) {
        btn.userInteractionEnabled = false;
    }
    screenShotView.alpha = 0;
    coverView.alpha = 0;
    customView.alpha = 0;
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        screenShotView.alpha = 1;
        coverView.alpha = 1;
        customView.alpha = 1.0;
    } completion:^(BOOL finished) {
        for (UIButton *btn in customView.subviews) {
            btn.userInteractionEnabled = YES;
        }
        
    }];
    
    customView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [UIView animateWithDuration:duration * 0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        customView.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration * 0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            customView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration * 0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                customView.transform = CGAffineTransformMakeScale(1, 1);
            } completion:nil];
        }];
    }];
}

//加mark 遮罩
- (void)addCoverView{
    coverView = [[UIButton alloc] initWithFrame:[UIScreen mainScreen].bounds];
    coverView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
    coverView.userInteractionEnabled=true;
    [coverView addTarget:self action:@selector(coverViewClick) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:coverView];
}

- (void)addDialogView{
    dialogView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 450)];
    dialogView.center=coverView.center;
    //dialogView.backgroundColor = [UIColor redColor];
    //coverView.userInteractionEnabled=true;
    [coverView addSubview:dialogView];
}

- (void)coverViewClick{
    if (self.modal) {
        [self dismissWithCompletion:^{
            missCompetionBlock();
            self.modal=false;
        }];
    }
}

//view消失

- (void)dismissWithCompletion:(MissCompetionBlock)completion{
    [self hideDialogWithCompletion:^{
        if (completion) {
            completion();
            NSNotification *notification =[NSNotification notificationWithName:@"userdata_event" object:nil userInfo:@{@"name":@"click"}];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }];
    
}

//view消失的动画

- (void)hideDialogWithCompletion:(MissCompetionBlock)completion{
    [EZJSingleTon shareSingleTon].alertReady=false;
    
    CGFloat duration = 0.2;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        //coverView.alpha = 0;
        //screenShotView.alpha = 0;
        //customView.alpha = 0;
    } completion:^(BOOL finished) {
        
        
        if (completion) {
            completion();
            [self removeFromSuperview];
        }
    }];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        customView.transform = CGAffineTransformMakeScale(0.4, 0.4);
    } completion:^(BOOL finished) {
        customView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

//添加背景模糊效果
- (void)addScreenShot{
    UIWindow *screenWindow = [UIApplication sharedApplication].windows.firstObject;
    UIGraphicsBeginImageContext(screenWindow.frame.size);
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *originalImage = nil;
    if (JCiOS7OrLater) {
        originalImage = viewImage;
    } else {
        originalImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewImage.CGImage, CGRectMake(0, 20, 320, 460))];
    }
    
    CGFloat blurRadius = 4;
    UIColor *tintColor = [UIColor clearColor];
    CGFloat saturationDeltaFactor = 1;
    UIImage *maskImage = nil;
    
    CGRect imageRect = { CGPointZero, originalImage.size };
    UIImage *effectImage = originalImage;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -originalImage.size.height);
        CGContextDrawImage(effectInContext, imageRect, originalImage.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data	 = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width	= CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data	 = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width	= CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1;
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,					0,					0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -originalImage.size.height);
    
    CGContextDrawImage(outputContext, imageRect, originalImage.CGImage);
    
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    screenShotView = [[UIImageView alloc] initWithImage:outputImage];
    
    [customView addSubview:screenShotView];
    
}
@end
