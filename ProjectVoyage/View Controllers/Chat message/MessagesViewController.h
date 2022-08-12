//
//  MessagesViewController.m
//
//  Created by Gui David

#import <UIKit/UIKit.h>
#import "Chat.h"
@class Message;

@protocol ContainerProtocol
- (void)editMessage:(Message *)message;
- (void)deleteMessage:(Message *)message;
- (void)changeSender:(Message *)message;
@end

@interface MessagesViewController: UIViewController
@property (nonatomic, strong) Chat *chat;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableOrderedSet *messagesInChat;
@property (nonatomic, strong) NSMutableOrderedSet *cachedMessages;

@end
