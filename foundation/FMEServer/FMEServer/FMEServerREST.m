/*=============================================================================
 
 Name     : FMEServerNotificationManager.m
 
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

#import "FMEServerREST.h"
#import "NSMutableURLRequest+BasicAccessAuthentication.h"
#import <Security/Security.h>

// Request Headers
static NSString * const kRESTAcceptKey                 = @"Accept";
static NSString * const kRESTAcceptValue               = @"application/json";
static NSString * const kHTTPHeaderContentType         = @"Content-Type";
static NSString * const kContentTypeJson               = @"application/json";
static NSString * const kContentTypeXWwwFormUrlencdoed = @"application/x-www-form-urlencoded";

static NSString * const kHTTPMethodGET        = @"GET";
static NSString * const kHTTPMethodPOST       = @"POST";
static NSString * const kHTTPMethodPUT        = @"PUT";
static NSString * const kHTTPMethodDELETE     = @"DELETE";

// FME Server REST
static NSString * const kFMEREST     = @"/fmerest/v2";

// Topics
static NSString * const kTopics       = @"/notifications/topics";
static NSString * const kMessageMap   = @"/message/map";
static NSString * const kMessageRaw   = @"/message/raw";

// Security
static NSString * const kSecurityAccounts = @"/security/accounts";

// Repositories
static NSString * const kRepositories = @"/fmerest/repositories";
static NSString * const kRun          = @"run";
static NSString * const kDotJSON      = @".json";

static NSString * const kAccept       = @"accept";
static NSString * const kJSON         = @"json";

static NSString * const kDetail       = @"detail";
static NSString * const kDetailLow    = @"low";       // default
static NSString * const kDetailHigh   = @"high";

static NSString * const kAcceptJSONLowDetail = @"accept=json&detail=low";

@interface FMEServerREST ()

// This function returns a url string by appending uri to self.userAccount.host.
- (NSString *)urlFromUri:(NSString *)uri;

// This function returns a url request to the url. The content type is set to JSON.
- (NSMutableURLRequest *)requestFromUrl:(NSString *)url;

@end

@implementation FMEServerREST

@synthesize userAccount = userAccount_;

- (void)logIn:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler
{
   // We are faking a log in here. Getting the topics successfully is the
   // same as logging in successfully.
   [self getTopics:completionHandler];
}

- (void)getTopics:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler
{
   NSString * uri = [NSString stringWithFormat:@"%@%@?%@", kFMEREST, kTopics, kAcceptJSONLowDetail];
   [self sendRequest:uri contentType:APPLICATION_JSON method:GET requestBody:nil completionHandler:completionHandler];
}

-(void)getRepositories:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler
{
   NSString * uri = [NSString stringWithFormat:@"%@%@", kRepositories, kDotJSON];
   [self sendRequest:uri contentType:APPLICATION_JSON method:GET requestBody:nil completionHandler:completionHandler];
}

- (void)getRepository:(NSString *)name completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler
{
   NSString * uri = [NSString stringWithFormat:@"%@/%@%@", kRepositories, name, kDotJSON];
   [self sendRequest:uri contentType:APPLICATION_JSON method:GET requestBody:nil completionHandler:completionHandler];
}

- (void)runWorkspace:(NSString *)workspace repository:(NSString *)repository completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler
{
   NSString * uri = [NSString stringWithFormat:@"%@/%@/%@/%@%@", kRepositories, repository, workspace, kRun, kDotJSON];
   [self sendRequest:uri contentType:APPLICATION_JSON method:GET requestBody:nil completionHandler:completionHandler];
}

+ (BOOL)isOK:(NSURLResponse *)response
{
   if ([response isKindOfClass:[NSHTTPURLResponse class]])
   {
      NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
      if (httpResponse.statusCode / 100 == 2)
      {
         return YES;
      }
   }
       
   return NO;
}

- (void)sendRequest:(NSString *)uri
        contentType:(FMEHTTPContentType)contentType
             method:(FMERESTHTTPMethod)httpMethod
        requestBody:(NSData *)data
  completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler
{
   NSString * url = [self urlFromUri:uri];
   NSMutableURLRequest * request = [self requestFromUrl:url];
   
    switch (contentType)
    {
    case APPLICATION_JSON:
        [request setValue:kContentTypeJson forHTTPHeaderField:kHTTPHeaderContentType];
        [request setValue:kRESTAcceptValue forHTTPHeaderField:kRESTAcceptKey];
        break;
    case APPLICATION_X_WWW_FORM_URLENCODED:
        [request setValue:kContentTypeXWwwFormUrlencdoed forHTTPHeaderField:kHTTPHeaderContentType];
        break;
    default:
        break;
    }
    //[urlRequest setValue:kRESTContentTypeValue forHTTPHeaderField:kRESTContentTypeKey];
    //[urlRequest setValue:kRESTAcceptValue      forHTTPHeaderField:kRESTAcceptKey];
    

   switch (httpMethod)
   {
   case POST:   [request setHTTPMethod:kHTTPMethodPOST];   break;
   case PUT:    [request setHTTPMethod:kHTTPMethodPUT];    break;
   case DELETE: [request setHTTPMethod:kHTTPMethodDELETE]; break;
   case GET:
   default:     [request setHTTPMethod:kHTTPMethodGET];    break;
   }
   
   if (data)
   {
      [request setHTTPBody:data];
//       [request setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];

   }
   
   NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
   
//    NSString *userPasswordString = [NSString stringWithFormat:@"%@:%@", self.userAccount.username, self.userAccount.password];
//    NSData * userPasswordData = [userPasswordString dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *base64EncodedCredential = [userPasswordData base64EncodedStringWithOptions:0];
//    NSString *authString = [NSString stringWithFormat:@"Basic %@", base64EncodedCredential];
//    
//    configuration.HTTPAdditionalHeaders = @{@"Accept": @"application/json",
//                                            @"Accept-Language": @"en",
//                                            @"Authorization": authString};
    
   NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
   [[session dataTaskWithRequest:request completionHandler:completionHandler] resume];
}


- (NSString *)urlFromUri:(NSString *)uri
{
   NSMutableString * url = [NSMutableString stringWithFormat:@"%@/%@", self.userAccount.host, uri];
   [url replaceOccurrencesOfString:@"\\" withString:@"/" options:0 range:NSMakeRange(0, url.length)];
   [url replaceOccurrencesOfString:@"/{2,}" withString:@"/" options:NSRegularExpressionSearch range:NSMakeRange(0, url.length)];
   return url;
}

- (NSMutableURLRequest *)requestFromUrl:(NSString *)urlString
{
   NSString * escapedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   NSURL * url = [NSURL URLWithString:escapedUrlString];
   
   // Make a url request
   forceLoadNSMutableURLRequestWithCategoryBasicAccessAuthentication();
   NSMutableURLRequest * urlRequest //= [NSMutableURLRequest requestWithURL:url];
   = [NSMutableURLRequest requestInBasicAccessAuthenticationWithUrl:url
                                                           username:self.userAccount.username
                                                           password:self.userAccount.password];
   urlRequest.timeoutInterval = 60;   // seconds
   return urlRequest;
}

// ------------------------------------------------------------------------------
- (void)retrieveAccount:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler
{
   NSString * uri = [NSString stringWithFormat:@"%@%@/%@?%@", kFMEREST, kSecurityAccounts, self.userAccount.username, kAcceptJSONLowDetail];
   [self sendRequest:uri contentType:APPLICATION_JSON method:GET requestBody:nil completionHandler:completionHandler];
}

#pragma mark - NSRULSessionDelegate implementation

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
//{
//    NSLog(@"Authentication Method: %@", challenge.protectionSpace.authenticationMethod);
//    NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:self.userAccount.username
//                                                               password:self.userAccount.password
//                                                            persistence:NSURLCredentialPersistenceNone];
//    
//    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
//
//}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    NSLog(@"Authentication Method: %@", challenge.protectionSpace.authenticationMethod);
    NSURLCredential * credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    
//    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
//    {
//        SecTrustResultType result;
//        OSStatus trustEvalStatus = SecTrustEvaluate(challenge.protectionSpace.serverTrust, &result);
//        if (trustEvalStatus == errSecSuccess)
//        {
//            if (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)
//            {
//                // evaluation OK
//                //[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//                NSURLCredential * credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
//            }
//            else
//            {
//                // evaluation failed
//                // ask user to add certificate to keychain
//                NSLog(@"Evaluation Failed.");
//            }
//        }
//        else
//        {
//            // evaluation failed - cancel authentication
//            NSLog(@"Evaluation Failed.");
////            [[challenge sender] cancelAuthenticationChallenge:challenge];
//            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
//        }
//    }
//    else if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodDefault)
//    {
//        NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:self.userAccount.username
//                                                                  password:self.userAccount.password
//                                                               persistence:NSURLCredentialPersistenceForSession];
//
//        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
//    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
}

@end
