// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest? data;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope
              ._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope',
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
