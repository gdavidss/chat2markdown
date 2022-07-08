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
    
    //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];

    NSString *convertedString = [dateFormatter stringFromDate:date]; //here convert date in NSString
    NSLog(@"Converted String : %@", convertedString);
    
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

@end
