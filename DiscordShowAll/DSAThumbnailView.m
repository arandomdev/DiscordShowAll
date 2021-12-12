#import "DSAThumbnailView.h"
#import "DSATwitterImage.h"
#import "DSATwitterEmbed.h"

#include "HBLog.h"
#import <BFRImageViewController/BFRImageViewController.h>
#import <PINRemoteImage/Classes/include/PINRemoteImage.h>


@implementation DSAThumbnailView
- (instancetype)initWithEmbed:(DSATwitterEmbed *)embed context:(NSDictionary *)context constrainedSize:(CGSize)size {
	self = [super initWithFrame:CGRectZero];
	if (self) {
		[self setupWithEmbed:embed constrainedSize:size];

		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		[self addGestureRecognizer:tapRecognizer];
	}
	return self;
}

- (void)setupWithEmbed:(DSATwitterEmbed *)embed constrainedSize:(CGSize)size {
	// calculate the frame and create the image views
	self.imageViews = [NSMutableArray arrayWithCapacity:embed.images.count];
	self.images = [NSMutableArray arrayWithCapacity:embed.images.count];
	for (int i = 0; i < embed.images.count; i++) {
		[self.images addObject:[NSNull null]];
	}

	__block CGFloat frameWidth = size.width;
	__block CGFloat frameHeight = 0;

	[embed.images enumerateObjectsUsingBlock:^(DSATwitterImage *image, NSUInteger idx, BOOL *stop) {
		// calculate the scaled height
		CGFloat height = frameWidth / image.width * image.height;

		// Create the view and add it
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frameHeight, frameWidth, height)];
		imageView.contentMode = UIViewContentModeScaleAspectFit;

		[self.imageViews addObject:imageView];
		[self addSubview:imageView];

		// set the image of the image view
		[[PINRemoteImageManager sharedImageManager] downloadImageWithURL:[NSURL URLWithString:image.url]
			options:PINRemoteImageManagerDownloadOptionsNone
			completion:^(PINRemoteImageManagerResult * _Nonnull result) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (result.error || !result.image) {
						HBLogDebug(@"Unable to get image for url: %@", image.url);
						return;
					}

					imageView.image = result.image;
					self.images[idx] = result.image;
				});
			}
		];

		frameHeight += height + 5; // also add a separator
	}];

	self.frame = CGRectMake(0, 0, frameWidth, frameHeight-5);
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateEnded) {
		CGPoint touchLoc = [sender locationInView:self];

		[self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
			if (CGRectContainsPoint(imageView.frame, touchLoc)) {
				BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:self.images];
				imageVC.startingIndex = idx;
				imageVC.maxScale = 10;
				
				[[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:imageVC animated:YES completion:nil];

				*stop = YES;
			}
		}];
	}
}
@end