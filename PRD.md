# Product Requirements Document (PRD)

## Overview

This App is a chat style application that allows the user to set a 10 minute timer and then chat with the app. The app will respond to the user in a conversational manner by asking the user maths questions, aimed a school aged children. The app should focus on addition, subtraction, multiplication and division. The app should also be able to provide hints and tips to the user if they are struggling with a question. The app should also be able to provide the user with a score at the end of the 10 minutes, based on the number of questions answered correctly. The app should also be able to provide the user with a summary of their performance at the end of the 10 minutes, including the number of questions answered correctly, the number of questions answered incorrectly, and the time taken to answer each question.

The Each interaction from the app should appear as a chat message bubble, with the app's messages appearing on the left and the user's messages appearing on the right.

## Key features of the app include

- A timer that counts down from a user defined time (1 minutes to 10 minutes)
- A chat interface that looks and feels like iMessage and includes tapbacks.
- Tapbacks for celebration and thumbs down for correct and incorrect answers respectively
- Messages from the bot should appear in grey
- Messages from the user should appear in blue
- A chat interface that allows the user to interact with the app
- The app should ask the user maths questions, aimed at school aged children
- The app should be able to provide hints and tips to the user if they are struggling with a question
- The app should be able to provide the user with a score at the end of the 10 minutes, based on the number of questions answered correctly
- The app should be able to provide the user with a summary of their performance at the end of the time, including the number of questions answered correctly.
- Display a trophy icon in the summary when the user answers all questions correctly
- The App should display a numeric keyboard when the user is asked a maths question
- Each question should be randomly generated
- The app should not go beyond 12x12 for multiplication and division questions
- The app should not go beyond 100 for addition and subtraction questions
- The app should conform to SwiftUI best practices
- The app should be able to run on iOS 14 and above
- The app should be able to written in Swift and SwiftUI
- The message from the app should appear to come from a robot and have an icon of a robot next to it like a contact card
- The app should have a settings pages that allows the user to adjust the timer duration (a slider, with 1 to 10 minutes and 1 minute increments), the difficulty level of the questions.
- The app should have a settings page that allows the user to choose appearance settings such as light mode, dark mode, and system mode.
- The app should launch with a welcome message from the bot, it should ask the user to set a timer and difficulty level and provide cards in the chat interface to do this, these should be tappable and allow the user to select the timer and difficulty level and this should update the settings in the app and be reflected in the settings view

## Steps

This is an iOS app written in Swift. I've add a PRD document with a list of requirements. Lets work on building this out one requirement at a time. After each requirement I should be able to run the application without any build errors or warnings and manually test it works.
