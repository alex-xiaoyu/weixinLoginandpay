//
//  DDecorationView.m
//  UIDynamicDemo
//
//  Created by zgk on 2016/12/26.
//  Copyright © 2016年 BBAE. All rights reserved.
//

#import "DDecorationView.h"

@interface DDecorationView ()
@property (nonatomic, strong) UIView *attachmentPointView;
@property (nonatomic, strong) UIView *attachedView;
@property (nonatomic, readwrite) CGPoint attachmentOffset;

@property (nonatomic, strong) NSMutableArray *attachmentDecorationLayers;
@property (nonatomic, weak) IBOutlet UIImageView *centerPointView;
@property (nonatomic, weak) UIImageView *arrowView;

@end

@implementation DDecorationView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundTile"]];
    }
    return self;
}


- (void)dealloc
{
    [self.attachmentPointView removeObserver:self forKeyPath:@"center"];
    [self.attachedView removeObserver:self forKeyPath:@"center"];
}

- (void)drawMagnitudeVectorWithLength:(CGFloat)distance angle:(CGFloat)angle color:(UIColor *)arrowColor forLimitedTime:(BOOL)temporary {
    if (!self.arrowView) {
        UIImage *arrowImage = [[UIImage imageNamed:@"Arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
        arrowImageView.bounds = CGRectMake(0, 0, arrowImage.size.width, arrowImage.size.height);
        arrowImageView.contentMode = UIViewContentModeRight;
        arrowImageView.clipsToBounds = YES;
        arrowImageView.layer.anchorPoint = CGPointMake(0.0, 0.5);
        
        [self addSubview:arrowImageView];
        [self sendSubviewToBack:arrowImageView];
        self.arrowView = arrowImageView;
    }
    
    self.arrowView.bounds = CGRectMake(0, 0, distance, self.arrowView.bounds.size.height);
    self.arrowView.transform = CGAffineTransformMakeRotation(angle);
    self.arrowView.tintColor = arrowColor;
    self.arrowView.alpha = 1;
    
    if (temporary) {
        [UIView animateWithDuration:1.0 animations:^{
            self.arrowView.alpha = 0;
        }];
    }
}

- (void)trackAndDrawAttachmentFromView:(UIView *)attachmentPointView toView:(UIView *)attachedView withattachmentOffset:(CGPoint)attachmentOffset {
    if (!self.attachmentDecorationLayers) {
        self.attachmentDecorationLayers = [NSMutableArray arrayWithCapacity:4];
        
        for (NSUInteger i = 0; i < 4; i++) {
            UIImage *dashImage = [UIImage imageNamed:[NSString stringWithFormat:@"DashStyle%lu", (i%3)+1]];
            
            CALayer *dashLayer = [CALayer layer];
            dashLayer.contents = (__bridge id)dashImage.CGImage;
            dashLayer.bounds = CGRectMake(0, 0, dashImage.size.width, dashImage.size.height);
            dashLayer.anchorPoint = CGPointMake(0.5, 0);
            
            [self.layer insertSublayer:dashLayer atIndex:0];
            [self.attachmentDecorationLayers addObject:dashLayer];
        }
    }
    
    [self.attachmentPointView removeObserver:self forKeyPath:@"center"];
    [self.attachedView removeObserver:self forKeyPath:@"center"];
    
    self.attachmentPointView = attachmentPointView;
    self.attachedView = attachedView;
    self.attachmentOffset = attachmentOffset;
    
    [self.attachmentPointView addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
    [self.attachedView addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.arrowView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    if (self.centerPointView) {
        self.centerPointView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    
    if (self.attachmentDecorationLayers) {
        const NSUInteger MaxDasheds = self.attachmentDecorationLayers.count;
        
        CGPoint attachmentPointViewCenter = CGPointMake(self.attachmentPointView.bounds.size.width/2, self.attachmentPointView.bounds.size.height/2);
        attachmentPointViewCenter = [self.attachmentPointView convertPoint:attachmentPointViewCenter toView:self];
        CGPoint attachedViewAttachmentPoint = CGPointMake(self.attachedView.bounds.size.width/2+self.attachmentOffset.x, self.attachedView.bounds.size.height/2+self.attachmentOffset.y);
        attachedViewAttachmentPoint = [self.attachedView convertPoint:attachedViewAttachmentPoint toView:self];
        
        CGFloat distance = sqrt(powf(attachedViewAttachmentPoint.x-attachmentPointViewCenter.x, 2.0)+powf(attachedViewAttachmentPoint.y-attachmentPointViewCenter.y, 2.0));
        CGFloat angle = atan2(attachedViewAttachmentPoint.y-attachmentPointViewCenter.y, attachedViewAttachmentPoint.x-attachmentPointViewCenter.x);
        
        NSUInteger requiredDashes = 0;
        CGFloat d = 0.0;
        
        while (requiredDashes < MaxDasheds) {
            CALayer *dashLayer = self.attachmentDecorationLayers[requiredDashes];
            
            if (d+dashLayer.bounds.size.height < distance) {
                d+= dashLayer.bounds.size.height;
                dashLayer.hidden = NO;
                requiredDashes++;
            }
            else
                
                break;
        }
        
        CGFloat dashSpacing = (distance-d)/(requiredDashes+1);
        
        for (; requiredDashes < MaxDasheds; requiredDashes++) {
            [self.attachmentDecorationLayers[requiredDashes] setHidden:YES];
        }
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(attachmentPointViewCenter.x, attachmentPointViewCenter.y);
        transform = CGAffineTransformRotate(transform, angle-M_PI/2);
        
        for (NSUInteger drawnDashes = 0; drawnDashes < requiredDashes; drawnDashes++) {
            CALayer *dashLayer = self.attachmentDecorationLayers[drawnDashes];
            transform = CGAffineTransformTranslate(transform, 0, dashSpacing);
            [dashLayer setAffineTransform:transform];
            transform = CGAffineTransformTranslate(transform, 0, dashLayer.bounds.size.height);
        }
        [CATransaction commit];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.attachmentPointView || object == self.attachedView) {
        [self setNeedsLayout];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
