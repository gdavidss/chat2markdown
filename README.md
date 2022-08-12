
# chat2markdown

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description

chat2markdown is an experimental chat app that allows you and your friends to modify all messages in the chat… all for the sake of a good markdown file.

philosophical assumptions:
- data shouldn’t exist in silos
- chats are collective artifacts
- having all the knobs of a system is good sometimes

### App Evaluation
- **Category:** Messaging, note-taking
- **Mobile:** Mobile is fundamental here because it is the most direct from of sending messages.
- **Story:** Users will be able to transcribe their conversations that contains voice messages and export them forever.
- **Market:** Messaging
- **Habit:** The app might assist and integrate the personal habit of sending meaningful voice messages to people, while being able to regularly retrieve information from these messages. 
- **Scope:** On the most basic level, the user should be able to upload a voice message directly from WhatsApp and have it displayed in screen as a message bubble to copy and paste in raw text. Users can also import written messages from WhatsApp if it helps complementing a dialogue. They can also edit any of the text of all parties in the dialogue as they wish. In cybernetic terms, they have requisite variety over all existing symbols in the dialogue.


## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User should be able to upload a voice message directly from WhatsApp.
* Transcribed message should be displayed in screen as a message bubble.
* The user can delete a message bubble, or edit it any way they want (as for correcting syntaxical errors, for example).
*  Users can import **written** messages from WhatsApp.
*   Users edit any of the text of all parties in the dialogue as they wish.
*    In cybernetic terms, users should have requisite variety over all existing symbols in the dialogue.

**Optional Nice-to-have Stories**

* Support for more than one language
    * Automatic language recognition
* Include audio in generated log, uploading it automatically to database and linking it using Markdown famous syntax "[[]()]()" to direct playing it.
* The user can play the voice message directly from its transcribed message bubble.
* Copy the WhatsApp interface perfectly and pitch it as a possible feature for WhatsApp (:DDDD)

### 2. Screen Archetypes

* Login/Sign up 
   * User can log in
   * User can sign up
* Chat list
   * User can see a list of previous created chat
   * User can create a new chat
   * User can delete any chat
   * User can export any chat to Markdown
* Chat
   * User can see message bubbles
   * User can edit any message bubbles
   * User can export chat to Markdown
* Edit message bubble
    * User can edit message bubble
* Settings
    * User can delete account
    * User can change password

### 3. Navigation

**Flow Navigation** (Screen to Screen)

* Login/Signup screen
    * Chat list
* Chat list 
    * Settings
    * Chat
* Edit message
   * Chat (after done editing the message)



## Wireframes
[Figma template](https://www.figma.com/file/mvjrm3VC09pIPwdkurNP2c/Untitled?node-id=4%3A152)

![](https://i.imgur.com/ExRtL06.png)
![](https://i.imgur.com/zRpov42.png)

## Schema 
### Models

#### User

  | Property       | Type     | Description                                 |
| -------------- | -------- | ------------------------------------------- |
| objectId       | String   | unique id for the user (default field)      |
| emailVerified       | Bool   | Whether or not email is verified                   |
| name       | String   | User's name 
| username       | String   | User's username to log in                   |
| password       | String   | Users hashed/encrypted password             |
| email          | String   | User's email address      |
| createdAt      | DateTime | Date for when user created their account  |


#### Chat
  | Property       | Type     | Description                                 |
| -------------- | -------- | ------------------------------------------- |
| objectId       | String   | unique id for the chat     |
| createdAt | Date | Date for when chat was created |
| updatedAt | Date | Date for when chat was updated |
| ACL       | ACL   | Access control list (Public Read + Write by default)            |
| recipients      | NSArray<PFUser *>   | Person who "received" the messages                   |
| chatDescription       | String   | Description of subject of the chat           |
| messages | Relation | List of all messages  in the chat |
| current_sender | Number | Current sender in the chat |


#### Message

  | Property       | Type     | Description                                 |
| -------------- | -------- | ------------------------------------------- |
| objectId       | String   | unique id for the message     |
| text       | String   | The content of the message           |
| sender       | PFUser *  | A pointer to the user who sent the message           |
| audio | File (nullable) | Audio file if the message was transcribed |
| CreatedAt | DateTime | Date for when message was created |


### Networking
- Chat list
    - (Create/POST) Create a new chat
    - (Delete) Delete a new chat
- Chat screen
    - (Create/POST) Create a new message
    - (Delete) Delete a message
    - (Read/GET) Get messages in the chat
- Message
    - (Create/Post) Create a new transcription
    - (Update/Put) Edit message
