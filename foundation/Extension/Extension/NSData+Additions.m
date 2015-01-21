/*============================================================================= 
 
   Name     : NSData+Additions.m
 
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


#import "NSData+Additions.h"

void forceLoadNSDataWithCategoryMBBase64(void)
{
    // Do nothing
}

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string {
  if (string == nil)
    [NSException raise:NSInvalidArgumentException format:nil];
  if ([string length] == 0)
    return [NSData data];
  
  static char *decodingTable = NULL;
  if (decodingTable == NULL) {
    decodingTable = malloc(256);
    if (decodingTable == NULL)
      return nil;
    memset(decodingTable, CHAR_MAX, 256);
    NSUInteger i;
    for (i = 0; i < 64; i++)
      decodingTable[(short)encodingTable[i]] = i;
  }
  
  const char *characters = [string cStringUsingEncoding:NSUTF8StringEncoding];
  if (characters == NULL)     //  Not an ASCII string!
    return nil;
  char *bytes = malloc((([string length] + 3) / 4) * 3);
  if (bytes == NULL)
    return nil;
  NSUInteger length = 0;
  
  NSUInteger i = 0;
  while (YES)
  {
    char buffer[4];
    short bufferLength;
    for (bufferLength = 0; bufferLength < 4; i++)
    {
      if (characters[i] == '\0')
        break;
      if (isspace(characters[i]) || characters[i] == '=')
        continue;
      buffer[bufferLength] = decodingTable[(short)characters[i]];
      if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
      {
        free(bytes);
        return nil;
      }
    }
    
    if (bufferLength == 0)
      break;
    if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
    {
      free(bytes);
      return nil;
    }
    
    //  Decode the characters in the buffer to bytes.
    bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
    if (bufferLength > 2)
      bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
    if (bufferLength > 3)
      bytes[length++] = (buffer[2] << 6) | buffer[3];
  }
  
  realloc(bytes, length);
  return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64Encoding {
  if ([self length] == 0)
    return @"";
  
  char *characters = malloc((([self length] + 2) / 3) * 4);
  if (characters == NULL)
    return nil;
  NSUInteger length = 0;
  
  NSUInteger i = 0;
  while (i < [self length])
  {
    char buffer[3] = {0,0,0};
    short bufferLength = 0;
    while (bufferLength < 3 && i < [self length])
      buffer[bufferLength++] = ((char *)[self bytes])[i++];
    
    //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
    characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
    characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
    if (bufferLength > 1)
      characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
    else characters[length++] = '=';
    if (bufferLength > 2)
      characters[length++] = encodingTable[buffer[2] & 0x3F];
    else characters[length++] = '=';  
  }
  
  return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSUTF8StringEncoding freeWhenDone:YES];
}

@end
