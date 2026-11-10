/// One problem found while validating a domain object.
class ValidationIssue {
  const ValidationIssue(this.field, this.message);

  final String field;
  final String message;

  @override
  String toString() => '$field: $message';
}

/// Thrown when a plan fails validation. Carries every issue found.
class PlanValidationException implements Exception {
  PlanValidationException(List<ValidationIssue> issues)
    : issues = List.unmodifiable(issues);

  final List<ValidationIssue> issues;

  @override
  String toString() => 'PlanValidationException(${issues.join('; ')})';
}
