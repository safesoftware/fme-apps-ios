/*============================================================================= 
 
   Name     : UIAlertView+Block.m
 
   System   : Extension
 
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

#import "UIAlertView+Block.h"
#import <objc/runtime.h>

// This delegate stores a copy of the completion block when it is initialized.
// When the alert view calls the function of this delegate, this delegate will
// execute the completion block.
@interface Delegate : NSObject <UIAlertViewDelegate>

@property (nonatomic, copy)  void(^completion)(UIAlertView * alertView, NSInteger buttonIndex);

@end

@implementation Delegate

@synthesize completion = completion_;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completion)
    {
        self.completion(alertView, buttonIndex);
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    [self alertView:alertView clickedButtonAtIndex:alertView.cancelButtonIndex];
}

@end


@implementation UIAlertView (Block)


- (void)showWithCompletion:(void(^)(UIAlertView * alertView, NSInteger buttonIndex))completion
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        return;   // No need to show the alert view since the user won't be able
                  // to see it anyway.
    }

    Delegate * delegate = [[Delegate alloc] init];
    delegate.completion = completion;
    self.delegate       = delegate;
    
    static const char kDelegateAssociationKey;
    objc_setAssociatedObject(self, &kDelegateAssociationKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self show];
}

@end
