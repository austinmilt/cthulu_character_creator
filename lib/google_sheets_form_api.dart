import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/env.dart';
import 'package:cthulu_character_creator/form_data.dart';
import 'package:gsheets/gsheets.dart';

/// Your spreadsheet id
///
/// It can be found in the link to your spreadsheet -
/// link looks like so https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit#gid=0
/// [YOUR_SPREADSHEET_ID] in the path is the id your need
/// TODO move this to a path parameter or some other option that isnt a compile-time constant
const _spreadsheetId = '1n_mDhUgQwAIZAWijNLUpqCQ72hbr5IMNXaMXqWEZo8U';

class GoogleSheetsFormApi implements Api {
  GoogleSheetsFormApi.withDefaults() : _googleSheetsClient = GSheets(Env.gcpServiceAccountKey);

  final GSheets _googleSheetsClient;

  @override
  Future<void> submitForm(FormData submission) async {
    final Spreadsheet spreadsheet = await _googleSheetsClient.spreadsheet(_spreadsheetId);
    // TODO spreadsheet by game ID (game+campaign)
    final Worksheet worksheet = await _getOrCreateWorksheet(spreadsheet, "coc-dragoncon-stakes");
    final _WorksheetLogger logger = _WorksheetLogger(spreadsheet);

    // initialize the column headers if they havent been already
    List<String> columnOrder = (await worksheet.cells.row(1)).map((e) => e.value).toList();
    if (columnOrder.isEmpty) {
      // TODO probably a better way to make sure the sheet hasnt been initialized, e.g.
      //  this could break things if the first row got deleted but subsequent rows still
      //  had data
      columnOrder = _worksheetSchema.map((c) => c.name).toList();
      await worksheet.values.insertRow(1, columnOrder);
    }

    final int emailColumnIndex = await worksheet.values.columnIndexOf('email');
    if (emailColumnIndex == -1) {
      logger.log("Couldn't find the main email column, so could not write values", submission.email);
      return;
    }

    final Map<String, String> row =
        Map.fromEntries(_worksheetSchema.map((s) => MapEntry(s.name, s.serializer(submission))));
    final int submissionRowIndex = await worksheet.values.rowIndexOf(submission.email, inColumn: emailColumnIndex);
    if (submissionRowIndex == -1) {
      await worksheet.values.map.appendRow(row, appendMissing: true);
    } else {
      await worksheet.values.map.insertRow(submissionRowIndex, row, overwrite: true, appendMissing: true);
    }
  }

  Future<Worksheet> _getOrCreateWorksheet(Spreadsheet spreadsheet, String worksheetTitle) async {
    return spreadsheet.worksheetByTitle(worksheetTitle) ??
        await spreadsheet.addWorksheet(worksheetTitle, rows: 50, columns: _worksheetSchema.length);
  }
}

final List<_ColumnSchema> _worksheetSchema = [
  (name: 'email', serializer: (d) => d.email),
  (name: 'name', serializer: (d) => d.name),
  (name: 'occupation', serializer: (d) => d.occupation),
  (name: 'appearance', serializer: (d) => d.appearance),
  (
    name: 'skills',
    serializer: (d) {
      d.skills.sort((s1, s2) => s1.name.compareTo(s2.name));
      return d.skills.map((s) => "${s.name} (${s.basePercentage + s.percentageModifier}%)").join((', '));
    }
  ),
  (name: 'traits', serializer: (d) => d.traits ?? ""),
  (name: 'ideology', serializer: (d) => d.ideology ?? ""),
  (name: 'injuries', serializer: (d) => d.injuries ?? ""),
  (name: 'relationships', serializer: (d) => d.relationships ?? ""),
  (name: 'phobias', serializer: (d) => d.phobias ?? ""),
  (name: 'treasures', serializer: (d) => d.treasures ?? ""),
  (name: 'details', serializer: (d) => d.details ?? ""),
  (name: 'items', serializer: (d) => d.items ?? ""),
  (name: 'timestamp', serializer: (d) => DateTime.now().toIso8601String()),
];

// TODO deserializer
typedef _ColumnSchema = ({String name, String Function(FormData) serializer});

class _WorksheetLogger {
  _WorksheetLogger(this._spreadsheet);

  final Spreadsheet _spreadsheet;
  Worksheet? _worksheet;

  Future<void> log(String message, String? email) async {
    final String timestamp = DateTime.now().toIso8601String();
    final Worksheet worksheet = await _getOrCreateWorksheet();
    final Map<String, String> row = {
      'timestamp': timestamp,
      'email': email ?? "",
      'message': message,
    };
    print("$row");
    await worksheet.values.map.appendRow(row, appendMissing: true);
  }

  Future<Worksheet> _getOrCreateWorksheet() async {
    final Worksheet result;
    // lazy init the error worksheet in case no errors are logged
    if (_worksheet == null) {
      result = _spreadsheet.worksheetByTitle("log") ?? await _spreadsheet.addWorksheet("log", rows: 1000, columns: 3);

      // get the column order to write the row in, or initialize the column
      // order if it hasnt already been done
      List<String> columnOrder = (await result.cells.row(1)).map((e) => e.value).toList();
      if (columnOrder.isEmpty) {
        // TODO probably a better way to make sure the sheet hasnt been initialized, e.g.
        //  this could break things if the first row got deleted but subsequent rows still
        //  had data
        columnOrder = ['timestamp', 'email', 'message'];
        result.values.insertRow(1, columnOrder);
      }
    } else {
      result = _worksheet!;
    }
    return result;
  }
}
