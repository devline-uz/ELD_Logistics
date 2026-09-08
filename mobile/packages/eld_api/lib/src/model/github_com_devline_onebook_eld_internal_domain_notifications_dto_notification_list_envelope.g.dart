// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_notifications_dto_notification_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope {
  @override
  final BuiltList<
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope &&
        data == other.data &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope,
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope?
      _$v;

  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification>?
      _data;
  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder?
      _meta;
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder
      get meta => _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _meta = $v.meta?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope
              ._(
            data: _data?.build(),
            meta: _meta?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
        _$failedField = 'meta';
        _meta?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationListEnvelope',
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
