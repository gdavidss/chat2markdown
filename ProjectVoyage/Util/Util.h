//
//  Util.h
//  ProjectVoyage
//
//  Created by Gui David on 7/7/22.
//

#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface Util : NSObject

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;
+ (NSString *) formatDateString:(NSDate *)stringDate;
+ (void) roundImage:(UIImageView *)imageView;
+ (NSString *)removeEndSpaceFrom:(NSString *)strToRemove;

@end

NS_ASSUME_NONNULL_END
