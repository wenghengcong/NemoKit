//
//  NMFormOptionsObject.m
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

#import "NMFormOptionsObject.h"

@implementation NMFormOptionsObject

+(NMFormOptionsObject *)formOptionsObjectWithValue:(id)value displayText:(NSString *)displayText
{
    return [[NMFormOptionsObject alloc] initWithValue:value displayText:displayText];
}

-(instancetype)initWithValue:(id)value displayText:(NSString *)displayText
{
    self = [super init];
    if (self){
        _formValue = value;
        _formDisplaytext = displayText;
    }
    return self;
}

+(NMFormOptionsObject *)formOptionsOptionForValue:(id)value fromOptions:(NSArray *)options
{
    for (NMFormOptionsObject * option in options) {
        if ([option.formValue isEqual:value]){
            return option;
        }
    }
    return nil;
}

+(NMFormOptionsObject *)formOptionsOptionForDisplayText:(NSString *)displayText fromOptions:(NSArray *)options
{
    for (NMFormOptionsObject * option in options) {
        if ([option.formDisplayText isEqualToString:displayText]){
            return option;
        }
    }
    return nil;
}

-(BOOL)isEqual:(id)object
{
    if (![[self class] isEqual:[object class]]){
        return NO;
    }
    return [self.formValue isEqual:((NMFormOptionsObject *)object).formValue];
}

#pragma mark - NMFormOptionObject

-(NSString *)formDisplayText
{
    return _formDisplaytext;
}

-(id)formValue
{
    return _formValue;
}

#pragma mark - NSCoding
-(void)encodeWithCoder:(NSCoder *)encoder
{
    
    [encoder encodeObject:self.formValue
                   forKey:@"formValue"];
    [encoder encodeObject:self.formDisplayText
                   forKey:@"formDisplayText"];
}

-(instancetype)initWithCoder:(NSCoder *)decoder
{
    if ((self=[super init])) {
        
        [self setValue:[decoder decodeObjectForKey:@"formValue"]
                forKey:@"formValue"];
        [self setValue:[decoder decodeObjectForKey:@"formDisplayText"]
                forKey:@"formDisplaytext"];
        
    }
    
    return self;
    
}

-(NSUInteger)hash
{
    return [[self formValue ] hash];
}

@end