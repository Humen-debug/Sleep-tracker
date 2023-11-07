String? required(value) {
  if (value == null || (value is String && value.isEmpty)) {
    return 'It is a required field.';
  }
  return null;
}

String? email(String? v) {
  final re = RegExp(
      r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (v == null || v.isEmpty || !re.hasMatch(v)) {
    return 'This is written in a wrong format';
  }
  return null;
}

String? same(String? v, String? v2) {
  if (v != v2) {
    return '$v and $v2 should be the same';
  }
  return null;
}

String? length(String? v, [int length = 8]) {
  return !(v != null && v.length >= length) ? 'This input should have at least 8 characters' : null;
}

String? number(String? v) {
  final re = RegExp(r'^-?\d+\.?\d*$');
  if (v == null || v.isEmpty || !re.hasMatch(v)) {
    return 'This input should be a number';
  }
  return null;
}
