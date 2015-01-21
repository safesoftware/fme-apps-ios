/*============================================================================= 
 
   Name     : FMETopicDescriptionViewController.m
 
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

#import "FMETopicDescriptionViewController.h"

static NSString * kMIMETypeTextHTML = @"text/html";
static NSString * kTextEncodingUTF8 = @"UTF-8";

@interface FMETopicDescriptionViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *topicDescriptionWebView;
- (BOOL)isPlainText:(NSString *)text;
@end

@implementation FMETopicDescriptionViewController
@synthesize topicDescriptionWebView = topicDescriptionWebView_;
@synthesize html = html_;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) 
    {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // We don't want to scale plain text to fit the page since the text will
    // be too small.
    self.topicDescriptionWebView.scalesPageToFit = ![self isPlainText:self.html];
    
    NSData * htmlData = [self.html dataUsingEncoding:NSUTF8StringEncoding];
	[self.topicDescriptionWebView loadData:htmlData MIMEType:kMIMETypeTextHTML 
                          textEncodingName:kTextEncodingUTF8 
                                   baseURL:nil];
}

- (void)viewDidUnload
{
    [self setTopicDescriptionWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)isPlainText:(NSString *)text
{
    // We simply check if the text contains the < character for html tags.
    // If it doesn't exist, the text is a plain text.
    return ([text rangeOfString:@"<"].location == NSNotFound);
}

@end
