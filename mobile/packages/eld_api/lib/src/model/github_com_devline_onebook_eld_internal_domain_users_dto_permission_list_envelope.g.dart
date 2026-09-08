// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_permission_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule>? data;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope,
            GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope',
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
