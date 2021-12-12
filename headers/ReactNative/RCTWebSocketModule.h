@interface RCTWebSocketModule
#pragma mark superclass RCTEventEmitter

/**
 * When a websocket message is received, this is called.
 *
 * `name = "websocketMessage"`
 * `body = @{@"data" : message, @"type" : type, @"id" : webSocket.reactTag}`
 */
- (void)sendEventWithName:(NSString *)name body:(id)body;
@end