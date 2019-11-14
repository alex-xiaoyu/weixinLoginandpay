//
//  DDecorationView.h
//  UIDynamicDemo
//
//  Created by zgk on 2016/12/26.
//  Copyright © 2016年 BBAE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDecorationView : UIView

- (void)trackAndDrawAttachmentFromView:(UIView *)attachmentPointView toView:(UIView *)attachedView withattachmentOffset:(CGPoint)attachmentOffset;
- (void)drawMagnitudeVectorWithLength:(CGFloat)distance angle:(CGFloat)angle color:(UIColor *)arrowColor forLimitedTime:(BOOL)temporary;

@end
