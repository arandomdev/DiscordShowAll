#import "DSATwitterEmbed.h"
#import "DSATwitterImage.h"

@implementation DSATwitterEmbed
- (instancetype)initWithEmbeds:(NSArray *)embeds url:(NSString *)url {
	self = [super init];

	if (self) {
		self.images = [NSMutableArray new];

		for (NSDictionary *embed in embeds) {
			NSString *embedURL = [embed objectForKey:@"url"];
			if (
				[embedURL isEqual:url]
				&& [embed objectForKey:@"image"]  // Check if it has an image
			) {
				[self.images addObject:[[DSATwitterImage alloc] initWithImageData:embed[@"image"]]];
			}
		}

		self.firstImageProxyURL = [self.images firstObject].proxyURL;
	}

	return self;
}
@end