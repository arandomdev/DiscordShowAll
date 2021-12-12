#import "DSATwitterMessageSerializer.h"
#include "DSATwitterEmbed.h"

@implementation DSATwitterMessageSerializer
- (instancetype)init {
	self = [super init];
	if (self) {
		self.embedCache = [NSMutableDictionary new];
	}
	return self;
}

- (void)serializeTwitterMessages:(NSArray *)messages {
	NSMutableSet<NSString *> *urlsSerialized = [NSMutableSet new];

	for (NSDictionary *message in messages) {
		NSArray *embeds = [message objectForKey:@"embeds"];
		if (embeds.count == 0) {
			continue;
		}

		for (NSDictionary *embed in embeds) {
			NSString *embedURL = [embed objectForKey:@"url"];
			if (
				[embedURL containsString:@"twitter.com"]
				&& ![urlsSerialized containsObject:embedURL]
				&& [embed objectForKey:@"image"]
			) {
				DSATwitterEmbed *twitterEmbed = [[DSATwitterEmbed alloc] initWithEmbeds:embeds url:embedURL];
				if (twitterEmbed.firstImageProxyURL) {
					[self.embedCache setObject:twitterEmbed forKey:twitterEmbed.firstImageProxyURL];
				}

				[urlsSerialized addObject:embedURL];
			}
		}
	}
}

- (DSATwitterEmbed *)embedForProxyURL:(NSString *)proxyURL {
	return [self.embedCache objectForKey:proxyURL];
}
@end