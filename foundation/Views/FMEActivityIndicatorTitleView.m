/*============================================================================= 
 
   Name     : FMEActivityIndicatorTitleView.m
 
   System   : FME Alerts
 
   Language : Objective-C 
 
   Purpose  : TBD
 
         Copyright (c) 2013 - 2014, Safe Software Inc. All rights reserved. 
 
   Redistribution and use of this sample code in source and binary forms, with  
   or without modification, are permitted provided that the following  
   conditions are met: 
   * Redistributions of source code must retain the above copyright notice,  
     this list of conditions and the following disclaimer. 
   * Redistributions in binary form must reproduce the above copyright notice,  
     this list of conditions and the following disclaimer in the documentation  
     and/or other materials provided with the distribution. 
 
   THIS SAMPLE CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED  
   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR  
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR  
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,  
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,  
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;  
   OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,  
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR  
   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SAMPLE CODE, EVEN IF  
   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
=============================================================================*/

#import "FMEActivityIndicatorTitleView.h"

@interface FMEActivityIndicatorTitleView ()
@property (nonatomic, retain) UILabel * titleLabel;
@property (nonatomic, retain) UIActivityIndicatorView * activityIndicator;
@end

@implementation FMEActivityIndicatorTitleView

@synthesize titleLabel = titleLabel_;
@synthesize activityIndicator = activityIndicator_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                                UIViewAutoresizingFlexibleBottomMargin |
                                UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleRightMargin;
        
        self.activityIndicator 
            = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                                                  UIViewAutoresizingFlexibleBottomMargin |
                                                  UIViewAutoresizingFlexibleLeftMargin |
                                                  UIViewAutoresizingFlexibleRightMargin;
       self.activityIndicator.color = [UIColor blackColor];

        CGFloat indicatorWidth  = self.activityIndicator.frame.size.width;
        CGFloat indicatorHeight = self.activityIndicator.frame.size.height; 
        
        CGFloat spacing = 20.0f;
        
        CGFloat titleWidth  = 100.0f;
        CGFloat titleHeight = indicatorHeight;
        
        CGFloat indicatorX = (frame.size.width - indicatorWidth - spacing - titleWidth) / 2.0;
        CGFloat indicatorY = (frame.size.height - indicatorHeight) / 2.0;
        
        CGFloat titleX = indicatorWidth + spacing;// indicatorX + indicatorWidth + spacing;
        CGFloat titleY = 0.0f; //indicatorY;
        
        self.activityIndicator.frame = CGRectMake(indicatorX, 
                                                  indicatorY, 
                                                  indicatorWidth, 
                                                  indicatorHeight);

        [self.activityIndicator startAnimating];
        [self addSubview:self.activityIndicator];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleX,
                                                                    titleY,
                                                                    titleWidth,
                                                                    titleHeight)];
        
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                                           UIViewAutoresizingFlexibleBottomMargin |
                                           UIViewAutoresizingFlexibleLeftMargin |
                                           UIViewAutoresizingFlexibleRightMargin |
                                           UIViewAutoresizingFlexibleWidth;

                
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor       = [UIColor blackColor];
        self.titleLabel.textAlignment   = NSTextAlignmentLeft;
        self.titleLabel.text            = @"Verifying";
        self.titleLabel.font            = [UIFont boldSystemFontOfSize:17.0f];
        [self.activityIndicator addSubview:self.titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.titleLabel.text = title;
}

@end
