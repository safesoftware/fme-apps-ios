/*=============================================================================
 
 Name     : FMEServerREST.h
 
 System   : FMEServer
 
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

#import <Foundation/Foundation.h>
#import "FMEServerAccount.h"

@interface FMEServerREST : NSObject <NSURLSessionDelegate>

typedef enum
{
   OK           = 200,
   BAD_REQUEST  = 400,
   UNAUTHORIZED = 401,
   FORBIDDEN    = 403,
   NOT_FOUND    = 404
} FMERESTHTTPStatusCode;

typedef enum
{
    APPLICATION_JSON,
    APPLICATION_X_WWW_FORM_URLENCODED
} FMEHTTPContentType;

typedef enum
{
   GET,
   POST,
   PUT,
   DELETE
} FMERESTHTTPMethod;

@property (nonatomic, retain) FMEServerAccount * userAccount;

// This function sends a url request to the host with an optional request body.
// The result will be processed by the completionHandler.
- (void)sendRequest:(NSString *)uri
        contentType:(FMEHTTPContentType)contentType
             method:(FMERESTHTTPMethod)httpMethod
        requestBody:(NSData *)data
  completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler;

- (void)retrieveAccount:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler;

+ (BOOL)isOK:(NSURLResponse *)response;

- (void)logIn:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler;

- (void)getTopics:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler;

- (void)getRepositories:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler;
- (void)getRepository:(NSString *)name completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler;
- (void)runWorkspace:(NSString *)workspace repository:(NSString *)repository completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler;

@end
