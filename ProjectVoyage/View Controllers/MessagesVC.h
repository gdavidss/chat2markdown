//
//  ChatController.h
//  Whatsapp
//
//  Created by Rafael Castro on 6/16/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chat.h"
@class Message;

//
// This class control chat exchange message itself
// It creates the bubble UI
//

@protocol EditProtocol
    - (void)editMessage:(Message *)message;
@end

@interface MessagesVC: UIViewController
@property (strong, nonatomic) Chat *chat;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
