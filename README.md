# About SnapchatMemoriesDownloader
A simple application to download your memories from your Snapchat MyData.

This tool was created after discovering that in order to download the actual images/videos two steps are needed;
1. Do a POST with the "downloadlink" (app.snapchat.com/dmd/memories?something) to get the actual downloadlink (something.amazonaws.com/someMoreThings)
2. Download the media using that actual download link.

Next to that I wanted the files to have the original timestamp as creation date. 
Oh and of course to not do this whole stupid process manually :man_facepalming:️

# FAQ
### 1. How do I get MyData?
In order to get the raw JSON file "memories_history.json" you need to request MyData at Snapchat: https://support.snapchat.com/a/download-my-data

### 2. Why Dart?
Because about 99% of my current development work is Flutter, so Dart was the most recent familiar language and also covered the requirements I had.

### 3. How do I run this?
1. Install Dart: https://dart.dev/tutorials/server/get-started#2-install-dart 
2. Clone the project
3. `cd` into the project dir
4. Run `pub get` (info: https://dart.dev/tutorials/server/get-started#5-get-the-apps-dependencies)
5. Make sure your "memories_history.json" is placed in the folder named "input/", or change the path/name in code at `_inputFile`.
6. Run the app with `dart bin/main.dart` (info: https://dart.dev/tutorials/server/get-started#6-run-the-app)
7. Grab a beer and wait :beer:
8. Enjoy all the memories
9. Grab more beer :beers:
10. Delete your Snapchat account: https://support.snapchat.com/en-US/a/delete-my-account1 

### 4. Why not use dart2native?
Didn't have any extra time yet :man_shrugging: