//
//  Util.m
//  ProjectVoyage
//
//  Created by Gui David on 7/7/22.
//

#import "Util.h"

@implementation Util

+ (NSString *) formatDateString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"MM/dd/yy"];

    NSString *convertedString = [dateFormatter stringFromDate:date];
    
    return convertedString;
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

+ (void) roundImage:(UIImageView *)imageView {
    imageView.layer.cornerRadius= imageView.frame.size.height / 2;
    imageView.layer.masksToBounds = YES;
}

+ (NSString *)removeEndSpaceFrom:(NSString *)strToRemove {
    NSUInteger location = 0;
    unichar charBuffer[[strToRemove length]];
    [strToRemove getCharacters:charBuffer];
    int i = 0;
    for(i = (int)[strToRemove length]; i >0; i--) {
        NSCharacterSet* charSet = [NSCharacterSet whitespaceCharacterSet];
        if(![charSet characterIsMember:charBuffer[i - 1]]) {
            break;
        }
    }
    return [strToRemove substringWithRange:NSMakeRange(location, i  - location)];
}

@end
