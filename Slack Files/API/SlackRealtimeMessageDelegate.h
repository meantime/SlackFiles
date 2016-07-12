//
//  SlackRealtimeMessageDelegate.h
//  Slack Files
//
//  Created by Chris DeSalvo on 7/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class SlackAPI;

@protocol SlackRealtimeMessageDelegate <NSObject>

@optional

//  Called once after the websocket connection is made
- (void)slackAPIDidMakeRealtimeConnection:(SlackAPI *)api;                                                              //  hello

- (void)slackAPI:(SlackAPI *)api didReceiveMessage:(NSDictionary *)messageData;                                         //  message

//  Channel actions
- (void)slackAPI:(SlackAPI *)api didMarkPublicChannelWithId:(NSString *)channelId readAtTimestamp:(NSDate *)timestamp;  //  channel_marked
- (void)slackAPI:(SlackAPI *)api didCreatePublicChannel:(NSDictionary *)channelData;                                    //  channel_created
- (void)slackAPI:(SlackAPI *)api didJoinPublicChannel:(NSDictionary *)channelData;                                      //  channel_joined
- (void)slackAPI:(SlackAPI *)api didLeavePublicChannel:(NSDictionary *)channelData;                                     //  channel_left
- (void)slackAPI:(SlackAPI *)api didDeletePublicChannel:(NSDictionary *)channelData;                                    //  channel_deleted
- (void)slackAPI:(SlackAPI *)api didRenamePublicChannel:(NSDictionary *)channelData;                                    //  channel_rename
- (void)slackAPI:(SlackAPI *)api didArchivePublicChannel:(NSDictionary *)channelData;                                   //  channel_archive
- (void)slackAPI:(SlackAPI *)api didUnarchivePublicChannel:(NSDictionary *)channelData;                                 //  channel_unarchive
- (void)slackAPI:(SlackAPI *)api didChangePublicChannelHistory:(NSDictionary *)channelData;                             //  channel_history_changed

//  Do-Not-Disturb actions
- (void)slackAPI:(SlackAPI *)api didUpdateDoNotDisturbSettings:(NSDictionary *)dndData;                                 //  dnd_updated
- (void)slackAPI:(SlackAPI *)api userWithId:(NSString *)userId didUpdateDoNotDisturbSettings:(NSDictionary *)dndData;   //  dnd_updated_user

//  Direct Message actions
- (void)slackAPI:(SlackAPI *)api didCreateDirectMessageChannel:(NSDictionary *)dmData;                                  //  im_created
- (void)slackAPI:(SlackAPI *)api didOpenDirectMessageChannel:(NSDictionary *)dmData;                                    //  im_open
- (void)slackAPI:(SlackAPI *)api didCloseDirectMessageChannel:(NSDictionary *)dmData;                                   //  im_close
- (void)slackAPI:(SlackAPI *)api didMarkDirectMessageWithId:(NSString *)channelId readAtTimestamp:(NSDate *)timestamp;  //  im_marked
- (void)slackAPI:(SlackAPI *)api didChangeDirectMessageHistory:(NSDictionary *)dmData;                                  //  im_history_changed

//  Private Channel actions
- (void)slackAPI:(SlackAPI *)api didJoinPrivateChannel:(NSDictionary *)channelData;                                     //  group_joined
- (void)slackAPI:(SlackAPI *)api didLeavePrivateChannel:(NSDictionary *)channelData;                                    //  group_left
- (void)slackAPI:(SlackAPI *)api didCreatePrivateChannel:(NSDictionary *)channelData;                                   //  group_open
- (void)slackAPI:(SlackAPI *)api didDeletePrivateChannel:(NSDictionary *)channelData;                                   //  group_close
- (void)slackAPI:(SlackAPI *)api didArchivePrivateChannel:(NSDictionary *)channelData;                                  //  group_archive
- (void)slackAPI:(SlackAPI *)api didUnarchivePrivateChannel:(NSDictionary *)channelData;                                //  group_unarchive
- (void)slackAPI:(SlackAPI *)api didRenamePrivateChannel:(NSDictionary *)channelData;                                   //  group_rename
- (void)slackAPI:(SlackAPI *)api didMarkPrivateChannelWithId:(NSString *)channelId readAtTimestamp:(NSDate *)timestamp; //  group_marked
- (void)slackAPI:(SlackAPI *)api didChangePrivateChannelHistory:(NSDictionary *)channelData;                            //  group_history_changed

//  File actions
- (void)slackAPI:(SlackAPI *)api didCreateFileWithId:(NSString *)fileId;                                                //  file_created
- (void)slackAPI:(SlackAPI *)api didShareFileWithId:(NSString *)fileId;                                                 //  file_shared
- (void)slackAPI:(SlackAPI *)api didUnshareFileWithId:(NSString *)fileId;                                               //  file_unshared
- (void)slackAPI:(SlackAPI *)api didMakeFileWithIdPublic:(NSString *)fileId;                                            //  file_public
- (void)slackAPI:(SlackAPI *)api didMakeFileWithIdPrivate:(NSString *)fileId;                                           //  file_private
- (void)slackAPI:(SlackAPI *)api didChangeFileWithId:(NSString *)fileId;                                                //  file_change
- (void)slackAPI:(SlackAPI *)api didDeleteFileWithId:(NSString *)fileId;                                                //  file_deleted
- (void)slackAPI:(SlackAPI *)api didAddComment:(NSDictionary *)commentData toFileWithId:(NSString *)fileId;             //  file_comment_added
- (void)slackAPI:(SlackAPI *)api didEditComment:(NSDictionary *)commentData forFileWithId:(NSString *)fileId;           //  file_comment_edited
- (void)slackAPI:(SlackAPI *)api didDeleteComment:(NSDictionary *)commentData fromFileWithId:(NSString *)fileId;        //  file_comment_deleted

//  Pinning, Starring, and Reaction actions
- (void)slackAPI:(SlackAPI *)api didPinItem:(NSDictionary *)pinData;                                                    //  pin_added
- (void)slackAPI:(SlackAPI *)api didUnpinItem:(NSDictionary *)pinData;                                                  //  pin_removed
- (void)slackAPI:(SlackAPI *)api didStarItem:(NSDictionary *)starData;                                                  //  star_added
- (void)slackAPI:(SlackAPI *)api didUnstarItem:(NSDictionary *)starData;                                                //  star_removed
- (void)slackAPI:(SlackAPI *)api didAddReaction:(NSDictionary *)reactionData;                                           //  reaction_added
- (void)slackAPI:(SlackAPI *)api didRemoveReaction:(NSDictionary *)reactionData;                                        //  reaction_removed

//  Presence actions
- (void)slackAPI:(SlackAPI *)api userWithId:(NSString *)userId didChangePresenceTo:(NSString *)presence;                //  presence_change
- (void)slackAPI:(SlackAPI *)api userWithId:(NSString *)userId didManuallyChangePresenceTo:(NSString *)presence;        //  manual_presence_change

//  Team actions
- (void)slackAPI:(SlackAPI *)api didChangeTeamPlanTo:(NSString *)planName;                                              //  team_plan_change
- (void)slackAPI:(SlackAPI *)api didChangeTeamPreference:(NSString *)prefName toValue:(NSString *)value;                //  team_pref_change
- (void)slackAPI:(SlackAPI *)api didRenameTeamTo:(NSString *)newName;                                                   //  team_rename
- (void)slackAPI:(SlackAPI *)api didChangeTeamDomain:(NSString *)domainData;                                            //  team_domain_change
- (void)slackAPI:(SlackAPI *)api didChangeTeamEmailDomain:(NSString *)domainData;                                       //  email_domain_changed
- (void)slackAPI:(SlackAPI *)api didChangeTeamProfileFields:(NSString *)fieldData;                                      //  team_profile_change
- (void)slackAPI:(SlackAPI *)api didDeleteTeamProfileFields:(NSString *)fieldData;                                      //  team_profile_delete
- (void)slackAPI:(SlackAPI *)api didReorderTeamProfileFields:(NSString *)fieldData;                                     //  team_profile_reorder

//  Multi-party Direct Message actions
- (void)slackAPI:(SlackAPI *)api didOpenMultipartyDirectMessageChannel:(NSString *)mpdmData;                            //  mpim_open
- (void)slackAPI:(SlackAPI *)api didJoinMultipartyDirectMessageChannel:(NSString *)mpdmData;                            //  mpim_join
- (void)slackAPI:(SlackAPI *)api didCloseMultipartyDirectMessageChannel:(NSString *)mpdmData;                           //  mpim_close

//  User-group actions
- (void)slackAPI:(SlackAPI *)api didCreateUserGroup:(NSString *)groupData;                                              //  subteam_created
- (void)slackAPI:(SlackAPI *)api didUpdateUserGroup:(NSString *)groupData;                                              //  subteam_updated
- (void)slackAPI:(SlackAPI *)api didAddSelfToUserGroup:(NSString *)groupData;                                           //  subteam_self_added
- (void)slackAPI:(SlackAPI *)api didRemoveSelfFromUserGroup:(NSString *)groupData;                                      //  subteam_self_removed

//  Misc actions
- (void)slackAPI:(SlackAPI *)api didChangePreference:(NSString *)prefName toValue:(NSString *)value;                    //  pref_change
- (void)slackAPI:(SlackAPI *)api didUpdateUser:(NSDictionary *)userData;                                                //  user_change
- (void)slackAPI:(SlackAPI *)api didUpdateEmoji:(NSDictionary *)emojiData;                                              //  emoji_changed
- (void)slackAPI:(SlackAPI *)api didAddOrUpdateSlashCommand:(NSDictionary *)commandData;                                //  commands_changed
- (void)slackAPI:(SlackAPI *)api didAddBotIntegration:(NSString *)botData;                                              //  bot_added
- (void)slackAPI:(SlackAPI *)api didChangeBotIntegration:(NSString *)botData;                                           //  bot_changed
- (void)slackAPIDidChangeSignedInAccounts:(SlackAPI *)api;                                                              //  accounts_changed
- (void)slackAPIDidBeginTeamMigration:(SlackAPI *)api;                                                                  //  team_migration_started
- (void)slackAPI:(SlackAPI *)api userWithIdIsTyping:(NSString *)userId;                                                 //  user_typing

- (void)slackAPI:(SlackAPI *)api didReceiveUnknownMessageOfType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
