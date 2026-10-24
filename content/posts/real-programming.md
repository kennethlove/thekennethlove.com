+++
title = "Real World Programming or The Whole Damn Point is to Solve Problems"
date = 2018-02-19T13:52:43-07:00
draft = false
tags = [
    "programming",
    "csv",
    "helping"
]
categories = [
    "Blog",
    "Programming"
]
summary = "My wife had a problem and I solved it with programming...but didn't write a single line of code."
+++
I want to tell you about some programming I did recently. It might not be what you think of as programming, though. Trust me, though, it is and it just might change how you think of this field.

My wife just started her term as director of her regional spinner's guild (spinning yarn from fibers, not the bike thing). The previous director sent her a list of names, phone numbers, and email addresses for all of the local members. My wife wanted to get them all into her contacts so she could easily email individuals or the group as a whole. You know, basic administration stuff.

I could hear her grumbling at her computer so I went to see what was going on. At this point she was adding people to her contacts one at a time while cross-checking them against another list. It was frustrating and time consuming to say the least. I offered to help and she accepted.

First, I checked to see if there was a way to import a bunch of contacts into Google's contacts web app. There is, sorta. It'll import contacts from other email services or from a CSV. I didn't see any instructions, though, on what the columns should be in the CSV. The email my wife had from the previous instructor had things in three columns: name, phone number, and email. Well, those seem like likely candidates.

You can't export a CSV from just plain text in an email, though. So I opened up Google Sheets, made a new document, copied and pasted the email contents into there, then cleaned things up a bit and named the columns. A quick export as a CSV and it was time to see if my guesses were right. In Google Contacts, an equally quick import said that, yes, I was pretty close. I think Google expects "phone" instead of "phone number" but that's not a big deal. My wife cleaned up the details, made a list of names, and got on with other stuff she wanted to do. We turned a long, annoying job into about 10 or 15 minutes worth of work, counting the time it took to check the names against that other list I mentioned in the beginning.

So how is this programming? I mean, I didn't write a program. I barely typed anything into her computer at all. Surely this is more data entry or secretarial work than it is programming, right?

Well, I have a possibly-unpopular/uncommon definition for programming. Programming isn't all about coding; programming is about applying logic to the behavior of computers. Using the logic I've built up over years of working with computers, I could create a programmatic solution to my wife's problem. To me, that's programming and it's something I use every day.

I think this is a much better approach to the world of programming. If you only see programming as typing code into a text file, you're really limiting the impact and usefulness of programming. Turning one email of names and emails into an actual group of contacts isn't something you're going to want to write a whole program for. You'll have to find libraries for dealing with CSV, Google's contacts, etc. You'll have to get API keys and format a text file just right. By the time you've finished orchestrating your solution, you could have probably just done it by hand. Don't we all use programming to make our computing lives easier?