/// The administration's check of a license or of a point's license appendix, as the owner reads
/// it. [status] is the API's `unverified | verified | rejected` (the generated enums' `json`):
/// anything else, or nothing yet, reads as waiting.
String verificationStatusLabel(String? status) => switch (status) {
      'verified' => 'Подтверждено',
      'rejected' => 'Отклонено',
      _ => 'Ожидает проверки',
    };
