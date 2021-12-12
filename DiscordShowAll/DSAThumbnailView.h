#import "DSATwitterEmbed.h"

@interface DSAThumbnailView : UIView
@property (nonatomic, retain) NSMutableArray<UIImageView *> *imageViews;
@property (nonatomic, retain) NSMutableArray *images;

- (instancetype)initWithEmbed:(DSATwitterEmbed *)embed context:(NSDictionary *)context constrainedSize:(CGSize)size;
@end