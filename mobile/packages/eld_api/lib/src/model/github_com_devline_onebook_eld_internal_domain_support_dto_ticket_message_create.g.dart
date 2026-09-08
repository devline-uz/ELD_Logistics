// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_message_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate {
  @override
  final BuiltList<String> attachments;
  @override
  final String text;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate._(
      {required this.attachments, required this.text})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate &&
        attachments == other.attachments &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, attachments.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate')
          ..add('attachments', attachments)
          ..add('text', text))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate,
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate? _$v;

  ListBuilder<String>? _attachments;
  ListBuilder<String> get attachments =>
      _$this._attachments ??= ListBuilder<String>();
  set attachments(ListBuilder<String>? attachments) =>
      _$this._attachments = attachments;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _attachments = $v.attachments.toBuilder();
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate
              ._(
            attachments: attachments.build(),
            text: BuiltValueNullFieldError.checkNotNull(
                text,
                r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate',
                'text'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'attachments';
        attachments.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate',
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
