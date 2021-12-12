#import "DSATwitterImage.h"

@interface DSATwitterEmbed : NSObject
@property (nonatomic, retain) NSString *firstImageProxyURL;
@property (nonatomic, retain) NSMutableArray<DSATwitterImage *> *images;

- (instancetype)initWithEmbeds:(NSArray *)embeds url:(NSString *)url;
@end