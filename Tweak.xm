#include "DiscordShowAll/DSAThumbnailView.h"
#include "DiscordShowAll/DSATwitterEmbed.h"
#include "HBLog.h"
#import <mutex>

#import "headers/ReactNative/RCTWebSocketModule.h"
#import "headers/ReactNative/RCTNetworkTask.h"

#import "DiscordShowAll/DSATwitterMessageSerializer.h"


DSATwitterMessageSerializer *serializer;


#pragma mark Message Caching
%hook RCTNetworkTask
- (void)URLRequest:(id)networkRequestToken didCompleteWithError:(NSError *)networkError {
	if (![self validateRequestToken:networkRequestToken]) {
		%orig;
		return;
	}

	// Messages request format
	// https://discord.com/api/v9/channels/000000000000000000/messages?limit=25
	NSString *url = self.request.URL.absoluteString;
	bool isMessagesRequest = [url containsString:@"https://discord.com/api/v9/channels/"]
							 && [url containsString:@"messages"]
							 && ![url hasSuffix:@"ack"];  // Ignore acknowledgements

	if (isMessagesRequest) {
		NSData *messageData;
		{
			std::lock_guard<std::mutex> lock(MSHookIvar<std::mutex>(self, "_mutex"));
			messageData = [MSHookIvar<NSMutableData *>(self, "_data") copy];
		}

		if (![messageData length]) {
			%orig;
			return;
		}

		// Create the array of messages
		NSError *jsonError = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:messageData options:kNilOptions error:&jsonError];
		if (!jsonObject) {
			HBLogError(@"Unable to read JSON data: URL:%@ error:%@", url, jsonError);
			%orig;
			return;
		}

		if (![jsonObject isKindOfClass:[NSArray class]]) {
			HBLogError(@"Unexpected object type from JSON data: URL:%@", url);
			%orig;
			return;
		}

		[serializer serializeTwitterMessages:jsonObject];
		HBLogDebug(@"Add to cache from request.", nil);
	}

	return %orig;
}
%end

%hook RCTWebSocketModule
- (void)sendEventWithName:(NSString *)name body:(NSDictionary *)body {
	if (
		[name isEqual:@"websocketMessage"]
		&& [[body objectForKey:@"type"] isEqual:@"text"]
		&& [body objectForKey:@"data"]
	) {
		NSError *jsonError = nil;
		NSData *jsonData = [body[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
		id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
		if (!jsonObject) {
			HBLogError(@"Unable to read JSON data: error:%@", jsonError);
			%orig;
			return;
		}

		if (![jsonObject isKindOfClass:[NSDictionary class]]) {
			HBLogError(@"Unexpected object type from JSON data:", nil);
			%orig;
			return;
		}

		// Verify that its a message, and serialize it
		// Message format is roughly,
		// {
		//		"t":"MESSAGE_CREATE",
		//		"d":{
		//		    "id":"882730643425988609",
		//		    "embeds":[
		//		    ],
		//			...
		//		}
		// }
		if ([[jsonObject objectForKey:@"t"] isEqual:@"MESSAGE_CREATE"]) {
			// wrap in array
			NSDictionary *message = [jsonObject objectForKey:@"d"];
			if (message) {
				[serializer serializeTwitterMessages:@[message]];
				HBLogDebug(@"Add message from websocket", nil);
			}
		}
	}

	%orig;
}
%end

#pragma mark view modification
%hook DCDThumbnailView
- (CGRect)convertRect:(CGRect)rect toView:(UIView *)view {
	HBLogDebug(@"%@", NSStringFromCGRect(rect));
	return %orig;
}
- (id)initWithThumbnail:(NSDictionary *)thumbnail constrainedSize:(CGSize)size context:(NSDictionary *)context animated:(BOOL)animated {
	DSATwitterEmbed *embed = [serializer embedForProxyURL:thumbnail[@"proxyURL"]];
	if (embed) {
		return (id)[[DSAThumbnailView alloc] initWithEmbed:embed context:context constrainedSize:size];
	}

	return %orig;
}
%end

%ctor {
	HBLogDebug(@"Hook!", nil);
	serializer = [[DSATwitterMessageSerializer alloc] init];
}