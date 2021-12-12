#import "DSATwitterEmbed.h"

@interface DSATwitterMessageSerializer : NSObject
@property (nonatomic, retain) NSMutableDictionary<NSString *, DSATwitterEmbed *> *embedCache;

- (instancetype)init;
- (void)serializeTwitterMessages:(NSArray *)messages;
- (DSATwitterEmbed *)embedForProxyURL:(NSString *)proxyURL;
@end