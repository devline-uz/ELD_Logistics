// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_feedback.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback {
  @override
  final int? appRating;
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final String? id;
  @override
  final DateTime? submittedAt;
  @override
  final String? text;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback._(
      {this.appRating,
      this.driverId,
      this.driverName,
      this.id,
      this.submittedAt,
      this.text})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback &&
        appRating == other.appRating &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        id == other.id &&
        submittedAt == other.submittedAt &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appRating.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, submittedAt.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback')
          ..add('appRating', appRating)
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('id', id)
          ..add('submittedAt', submittedAt)
          ..add('text', text))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback,
            GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback? _$v;

  int? _appRating;
  int? get appRating => _$this._appRating;
  set appRating(int? appRating) => _$this._appRating = appRating;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _submittedAt;
  DateTime? get submittedAt => _$this._submittedAt;
  set submittedAt(DateTime? submittedAt) => _$this._submittedAt = submittedAt;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appRating = $v.appRating;
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _id = $v.id;
      _submittedAt = $v.submittedAt;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback._(
          appRating: appRating,
          driverId: driverId,
          driverName: driverName,
          id: id,
          submittedAt: submittedAt,
          text: text,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
