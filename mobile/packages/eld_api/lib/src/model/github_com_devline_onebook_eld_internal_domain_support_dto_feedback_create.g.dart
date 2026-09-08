// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_feedback_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate {
  @override
  final int? appRating;
  @override
  final String? text;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate._(
      {this.appRating, this.text})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate &&
        appRating == other.appRating &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appRating.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate')
          ..add('appRating', appRating)
          ..add('text', text))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate,
            GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate? _$v;

  int? _appRating;
  int? get appRating => _$this._appRating;
  set appRating(int? appRating) => _$this._appRating = appRating;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _appRating = $v.appRating;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate._(
          appRating: appRating,
          text: text,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
