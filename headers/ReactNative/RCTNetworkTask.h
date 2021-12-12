@interface RCTNetworkTask : NSObject
@property (nonatomic, readonly) NSURLRequest *request;
- (BOOL)validateRequestToken:(id)requestToken;
@end