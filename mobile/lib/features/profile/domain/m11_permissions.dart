/// M11 klasteri ishlatadigan RBAC kalitlari (`contracts/permissions.md`).
///
/// Backend `GET /me.permissions` ro'yxatini qaytaradi; ekranlar bandni shu
/// ro'yxatga qarab yashiradi. String literal tarqatish taqiq.
library;

/// `POST /feedback`.
const String kPermFeedbackCreate = 'feedback.create';

/// `GET /support-tickets`, `GET /support-tickets/{id}[/messages]`.
const String kPermSupportRead = 'support.read';

/// `POST /support-tickets`, `POST /support-tickets/{id}/messages`.
const String kPermSupportCreate = 'support.create';
