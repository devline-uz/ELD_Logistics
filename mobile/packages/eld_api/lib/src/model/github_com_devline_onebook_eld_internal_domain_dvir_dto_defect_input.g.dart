// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput {
  @override
  final String defectTypeId;
  @override
  final String? note;
  @override
  final BuiltList<String>? photoKeys;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput._(
      {required this.defectTypeId, this.note, this.photoKeys})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput &&
        defectTypeId == other.defectTypeId &&
        note == other.note &&
        photoKeys == other.photoKeys;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, defectTypeId.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, photoKeys.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput')
          ..add('defectTypeId', defectTypeId)
          ..add('note', note)
          ..add('photoKeys', photoKeys))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput? _$v;

  String? _defectTypeId;
  String? get defectTypeId => _$this._defectTypeId;
  set defectTypeId(String? defectTypeId) => _$this._defectTypeId = defectTypeId;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<String>? _photoKeys;
  ListBuilder<String> get photoKeys =>
      _$this._photoKeys ??= ListBuilder<String>();
  set photoKeys(ListBuilder<String>? photoKeys) =>
      _$this._photoKeys = photoKeys;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _defectTypeId = $v.defectTypeId;
      _note = $v.note;
      _photoKeys = $v.photoKeys?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput _build() {
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput._(
            defectTypeId: BuiltValueNullFieldError.checkNotNull(
                defectTypeId,
                r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput',
                'defectTypeId'),
            note: note,
            photoKeys: _photoKeys?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'photoKeys';
        _photoKeys?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput',
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
