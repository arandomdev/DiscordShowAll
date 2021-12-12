#import "DSATwitterImage.h"

@implementation DSATwitterImage
- (instancetype)initWithImageData:(NSDictionary *)imageData {
	self = [super init];
	if (self) {
		self.height = [[imageData objectForKey:@"height"] floatValue];
		self.width = [[imageData objectForKey:@"width"] floatValue];
		self.url = [imageData objectForKey:@"url"];
		self.proxyURL = [imageData objectForKey:@"proxy_url"];
	}
	return self;
}
@end