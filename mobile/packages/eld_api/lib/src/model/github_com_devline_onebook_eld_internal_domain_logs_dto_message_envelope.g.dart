// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_message_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse? data;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope? _$v;

  GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder? _data;
  GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder();
  set data(
          GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoMessageEnvelope',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
