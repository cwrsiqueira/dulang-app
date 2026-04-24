// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DatetimeStruct extends BaseStruct {
  DatetimeStruct({
    DateTime? datetime,
  }) : _datetime = datetime;

  // "datetime" field.
  DateTime? _datetime;
  DateTime? get datetime => _datetime;
  set datetime(DateTime? val) => _datetime = val;

  bool hasDatetime() => _datetime != null;

  static DatetimeStruct fromMap(Map<String, dynamic> data) => DatetimeStruct(
        datetime: data['datetime'] as DateTime?,
      );

  static DatetimeStruct? maybeFromMap(dynamic data) =>
      data is Map ? DatetimeStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'datetime': _datetime,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'datetime': serializeParam(
          _datetime,
          ParamType.DateTime,
        ),
      }.withoutNulls;

  static DatetimeStruct fromSerializableMap(Map<String, dynamic> data) =>
      DatetimeStruct(
        datetime: deserializeParam(
          data['datetime'],
          ParamType.DateTime,
          false,
        ),
      );

  @override
  String toString() => 'DatetimeStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DatetimeStruct && datetime == other.datetime;
  }

  @override
  int get hashCode => const ListEquality().hash([datetime]);
}

DatetimeStruct createDatetimeStruct({
  DateTime? datetime,
}) =>
    DatetimeStruct(
      datetime: datetime,
    );
