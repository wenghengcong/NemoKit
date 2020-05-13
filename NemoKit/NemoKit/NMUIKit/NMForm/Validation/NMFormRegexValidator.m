//
//  NMFormRegexValidator.m
//  NMForm (  )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NMFormRegexValidator.h"

@implementation NMFormRegexValidator

-(instancetype)initWithMsg:(NSString*)msg andRegexString:(NSString*)regex {
    self = [super init];
    if (self) {
        self.msg = msg;
        self.regex = regex;
    }
    
    return self;
}

-(NMFormValidationStatus *)isValid: (NMFormRowDescriptor *)row {
    if (row != nil && row.value != nil) {
        // we only validate if there is a value
        // assumption: required validation is already triggered
        // if this field is optional, we only validate if there is a value
        id value = row.value;
        if ([value isKindOfClass:[NSNumber class]]){
            value = [value stringValue];
        }
        if ([value isKindOfClass:[NSString class]] && [value length] > 0) {
            BOOL isValid = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.regex] evaluateWithObject:[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            return [NMFormValidationStatus formValidationStatusWithMsg:self.msg status:isValid rowDescriptor:row];
        }
    }
    return nil;
};

+(NMFormRegexValidator *)formRegexValidatorWithMsg:(NSString *)msg regex:(NSString *)regex {
    return [[NMFormRegexValidator alloc] initWithMsg:msg andRegexString:regex];
}

@end
