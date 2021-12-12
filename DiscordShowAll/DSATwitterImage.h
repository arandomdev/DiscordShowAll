@interface DSATwitterImage : NSObject
@property (nonatomic) float height;
@property (nonatomic) float width;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *proxyURL;

- (instancetype)initWithImageData:(NSDictionary *)imageData;
@end