/*============================================================================= 
 
   Name     : UIActionSheet+Block.m
 
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

#import "UIActionSheet+Block.h"
#import <objc/runtime.h>

static const void * kAssociationKeyDelegate = &kAssociationKeyDelegate;

// This delegate stores a copy of the completion block when it is initialized.
// When the alert view calls the function of this delegate, this delegate will
// execute the completion block.
@interface ActionSheetDelegate : NSObject <UIActionSheetDelegate>

@property (nonatomic, copy) UIActionSheetCompletionBlock completion;

@end

@implementation ActionSheetDelegate

@synthesize completion = completion_;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completion)
    {
        self.completion(actionSheet, buttonIndex);
    }
}

@end


@implementation UIActionSheet (Block)

+ (UIActionSheet *)showInView:(UIView *)view
                   completion:(UIActionSheetCompletionBlock)completion
                        title:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
            
{
    ActionSheetDelegate * delegate = [[ActionSheetDelegate alloc] init];
    delegate.completion = completion;
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                              delegate:delegate
                                                     cancelButtonTitle:cancelButtonTitle
                                                destructiveButtonTitle:destructiveButtonTitle
                                                     otherButtonTitles:nil];
    
    objc_setAssociatedObject(actionSheet, kAssociationKeyDelegate, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [actionSheet showInView:view];
    
    return actionSheet;
}

@end
