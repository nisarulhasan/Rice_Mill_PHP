<?php
declare(strict_types=1);

function validate_required(string $label, mixed $value): ?string { return trim((string)$value) === '' ? "$label is required." : null; }
function validate_email(string $label, mixed $value): ?string { if ($value===''||$value===null) return null; return filter_var((string)$value, FILTER_VALIDATE_EMAIL) ? null : "$label must be a valid email."; }
function validate_numeric(string $label, mixed $value, float $min = 0): ?string { if (!is_numeric($value)) return "$label must be numeric."; return (float)$value < $min ? "$label must be >= $min." : null; }
function validate_date(string $label, mixed $value): ?string { if ($value===''||$value===null) return null; return strtotime((string)$value) ? null : "$label must be a valid date."; }
function clean_input(array $input): array { $clean=[]; foreach($input as $k=>$v){ $clean[$k]=is_string($v)?trim(strip_tags($v)):$v; } return $clean; }
function validate_password_strength(string $password): ?string { if (strlen($password) < 8) return 'Password must be at least 8 characters.'; if (!preg_match('/[A-Z]/', $password)) return 'Password must contain uppercase letter.'; if (!preg_match('/[a-z]/', $password)) return 'Password must contain lowercase letter.'; if (!preg_match('/\d/', $password)) return 'Password must contain number.'; return null; }
