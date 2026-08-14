# Coding Conventions

## Code Generation (DTOs & Models)

**Mandatory** (see `CLAUDE.md` § 4b): every `*.dto.dart` uses
`build_runner` + `json_serializable`. Hand-written `fromJson` is forbidden
for wire-format models.

### DTO template

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.dto.g.dart';

/// `{id, email, full_name, is_active}` from `GET /api/v1/users`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class UserDto {
  final int id;
  final String email;
  final String fullName;
  @JsonKey(defaultValue: false)
  final bool isActive;

  const UserDto({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isActive,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
}
```

### Rules

* `fieldRename: FieldRename.snake` — backend snake_case ↔ Dart camelCase.
* `@JsonKey(name: ...)` only for non-idiomatic keys;
  `@JsonKey(defaultValue: ...)` preserves pre-existing defaults.
* `createToJson: false` for response DTOs. Request bodies use plain maps or
  dedicated request DTOs.
* Generics: `@JsonSerializable(genericArgumentFactories: true)`, e.g.
  `ApiResponse<T>`, `PaginatedData<T>`.
* Regenerate after editing: `melos run build`. Generated `*.g.dart` files
  are committed.
* Non-serialized value objects (`.entity.dart`) may stay hand-written.

## File Taxonomy

Dot-suffix roles enforced by `tool/check_taxonomy.dart` (see `CLAUDE.md` § 1).
One top-level class per file. Generated files are skipped by the checker.

## Networking

Single HTTP architecture through `packages/core` `ApiClient` (see
`docs/core/networking.md`). No second HTTP stack.
