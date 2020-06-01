import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// This is the place your memories_history.json file is located
final _inputFile = File('../input/memories_history.json');

/// This is the folder you want the memories to end up in
const _outputPath = '../output';

/// This processes and downloads the memories in chunks of [_partSize]
// A lower number gives results earlier
const _partSize = 50;

void main(List<String> _) async {
  print('==[STARTING PieterAelse Snapchat Memories Downloader]==');
  final startTimeStamp = DateTime.now();
  print('(timestamp: $startTimeStamp)');
  final dio = Dio();

  print('Reading memories file...');
  final allMemories = await _readJsonInputFile();
  final totalLength = allMemories.length;
  print('Found $totalLength memories!');
  print('(timestamp: ${DateTime.now()})');

  for (var start = 0; start < allMemories.length; start += _partSize) {
    final memoriesPart = allMemories.skip(start).take(_partSize).toList();

    final startNr = start + 1;
    print('Converting memories $startNr - ${start + memoriesPart.length} to downloadable memories...');
    final memoriesToDownload = await _convertMemoriesWithDio(dio, memoriesPart, startNr, totalLength);

    print('Downloading memories $startNr - ${start + memoriesPart.length}...');
    await _downloadMemoriesWithDio(dio, memoriesToDownload, startNr, totalLength);
  }

  dio.close();
  print('\n==[FINISHED PieterAelse Snapchat Memories Downloader]==');
  final endTimeStamp = DateTime.now();
  print('(downloading all memories took: ${endTimeStamp.difference(startTimeStamp)})');
}

Future<List<MemoryDownload>> _readJsonInputFile() async {
  final inputString = await _inputFile.readAsString();
  final inputJson = jsonDecode(inputString) as Map<String, Object>;
  final savedMedia = inputJson['Saved Media'] as List;

  final memories = <MemoryDownload>[];
  savedMedia.forEach((objecto) {
    memories.add(
      MemoryDownload(
        timeStamp: DateTime.parse((objecto['Date'] as String).replaceFirst(' UTC', '')),
        link: Uri.parse(objecto['Download Link'] as String),
      ),
    );
  });

  return memories;
}

Future<List<Memory>> _convertMemoriesWithDio(
  Dio dio,
  List<MemoryDownload> memories,
  int startNr,
  int totalCount,
) async {
  final downloadMemories = <Memory>[];
  var count = 0;
  await Future.forEach(memories, (MemoryDownload memory) async {
    print('${startNr + count}/$totalCount');

    final response = await dio.postUri(memory.link);
    if (response.statusCode == 200) {
      final uri = Uri.parse(response.data);
      downloadMemories.add(Memory(
        name: uri.pathSegments.last,
        timeStamp: memory.timeStamp,
        downloadLink: uri,
      ));
    } else {
      print('!! ERROR !! Failed converting memory $memory');
    }
    count++;
  });

  return downloadMemories;
}

Future<void> _downloadMemoriesWithDio(
  Dio dio,
  List<Memory> memories,
  int startNr,
  int totalCount,
) async {
  var count = 0;
  await Future.forEach(memories, (Memory memory) async {
    print('${startNr + count}/$totalCount : ${memory.name}');
    final result = await _downloadMemoryWithDio(dio, memory);
    if (result == DownloadResult.skippedAlreadyExisted) {
      print('SKIPPED because already downloaded');
    }
    count++;
  });
}

Future<DownloadResult> _downloadMemoryWithDio(Dio dio, Memory memory) async {
  final filePath = '$_outputPath/${memory.name}';
  final file = File(filePath);

  if (!file.existsSync()) {
    final response = await dio.downloadUri(memory.downloadLink, filePath);
    if (response.statusCode != 200) {
      print('!! ERROR !! FAILED DOWNLOADING MEMORY $memory');
      return DownloadResult.failed;
    }

    await file.setLastModified(memory.timeStamp);
    await file.setLastAccessed(memory.timeStamp);
    return DownloadResult.success;
  } else {
    return DownloadResult.skippedAlreadyExisted;
  }
}

class MemoryDownload {
  const MemoryDownload({@required this.timeStamp, @required this.link})
      : assert(timeStamp != null),
        assert(link != null);

  final DateTime timeStamp;
  final Uri link;

  @override
  String toString() => '$timeStamp : $link';
}

class Memory {
  const Memory({@required this.name, @required this.timeStamp, @required this.downloadLink})
      : assert(name != null),
        assert(timeStamp != null),
        assert(downloadLink != null);

  final String name;
  final DateTime timeStamp;
  final Uri downloadLink;

  @override
  String toString() => '$name : $timeStamp';
}

enum DownloadResult { success, failed, skippedAlreadyExisted }
