Original App Design Project - README Template
===

# Project Voyage

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description

Are you the kind of person who sends 10-minute voice messages to your friends investigating the nature of things or making jokes that could totally be in a stand-up comedy show?

If so, this app is for you.
 
Project Voyage is an app based on Automated Speech Recognition (ASR). It transcribes voice messages to text, allowing the user to produce, and manipulate it as they wish, a written dialogue between two people. The user can then export the dialogue in Markdown so they can copy and paste it in their favorite notetaking app.

### App Evaluation
- **Category:** Self-cognition
- **Mobile:** Yes, sir. Mobile is fundamental here because it is the most direct from of sending voice messages. PCs have the disadvantage of having to download the voice message. Plus, most transcription apps on app store are too purpose broad.
- **Story:** Users will be able to transcribe their conversations that contains voice messages and export them forever.
- **Market:** Self-improvement
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
   * User can record a voice message
   * User can import a voice message from the files
   * User can see message bubbles
   * User can edit any message bubbles
   * User can export chat to Markdown
   * (Stretch) User can play the voice message
* Edit message bubble
    * User can edit message bubble
* Settings
    * User can delete account
    * User can change password



### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Chat list
* 
* [fill out your third tab]

**Flow Navigation** (Screen to Screen)

* Login/Signup screen
    * Chat list
* Chat list 
    * Settings
    * Chat
* Edit message
   * Chat (after done editing the message)



## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="YOUR_WIREFRAME_IMAGE_URL" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
