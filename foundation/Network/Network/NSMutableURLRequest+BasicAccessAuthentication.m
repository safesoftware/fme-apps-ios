/*============================================================================= 
 
   Name     : NSMutableURLRequest+BasicAccessAuthentication.m
 
   System   : Network
 
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

#import "NSMutableURLRequest+BasicAccessAuthentication.h"

// com.safe.foundation.Extension
#import "NSData+Additions.h"

void forceLoadNSMutableURLRequestWithCategoryBasicAccessAuthentication(void)
{
    // Do nothing
}

@implementation NSMutableURLRequest (BasicAccessAuthentication)

+ (id)requestInBasicAccessAuthenticationWithUrl:(NSURL *)url
                                       username:(NSString *)username
                                       password:(NSString *)password
{
    // Build a url request
    NSMutableURLRequest * urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:url];    
    [urlRequest setBasicAccessAuthenticationWithUsername:username password:password];
    return urlRequest;
}

- (void)setBasicAccessAuthenticationWithUsername:(NSString *)username
                                        password:(NSString *)password
{
    forceLoadNSDataWithCategoryMBBase64();
    
    NSString * rawLoginInfo = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData * authorizationData = [rawLoginInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSString * authorizationValue = [NSString stringWithFormat:@"Basic %@", [authorizationData base64Encoding]];
    [self setValue:authorizationValue forHTTPHeaderField:@"Authorization"];    
}

@end
