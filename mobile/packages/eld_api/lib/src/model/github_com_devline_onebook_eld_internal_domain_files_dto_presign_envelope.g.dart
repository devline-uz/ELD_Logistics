// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_files_dto_presign_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse? data;

  factory _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope,
            GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope',
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
