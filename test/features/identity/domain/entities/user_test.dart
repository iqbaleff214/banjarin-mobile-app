import 'package:banjarin/features/identity/domain/entities/user.dart';
import 'package:banjarin/features/identity/domain/entities/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tCreatedAt = DateTime(2024, 1, 1);

  User makeUser({UserRole role = UserRole.user, DateTime? emailVerifiedAt}) {
    return User(
      id: '1',
      name: 'Ahmad',
      email: 'ahmad@test.com',
      role: role,
      isActive: true,
      emailVerifiedAt: emailVerifiedAt,
      createdAt: tCreatedAt,
    );
  }

  group('User.isAdmin', () {
    test('returns true when role is admin', () {
      final user = makeUser(role: UserRole.admin);
      expect(user.isAdmin, isTrue);
    });

    test('returns false when role is user', () {
      final user = makeUser(role: UserRole.user);
      expect(user.isAdmin, isFalse);
    });
  });

  group('User.emailVerified', () {
    test('returns true when emailVerifiedAt is not null', () {
      final user = makeUser(emailVerifiedAt: DateTime(2024, 1, 2));
      expect(user.emailVerified, isTrue);
    });

    test('returns false when emailVerifiedAt is null', () {
      final user = makeUser();
      expect(user.emailVerified, isFalse);
    });
  });

  group('User.copyWith', () {
    test('returns copy with updated name', () {
      final user = makeUser();
      final updated = user.copyWith(name: 'Budi');
      expect(updated.name, 'Budi');
      expect(updated.email, user.email);
    });
  });

  group('User equality', () {
    test('two users with same props are equal', () {
      final a = makeUser();
      final b = makeUser();
      expect(a, equals(b));
    });

    test('users with different id are not equal', () {
      final a = User(
        id: '1',
        name: 'A',
        email: 'a@test.com',
        role: UserRole.user,
        isActive: true,
        createdAt: tCreatedAt,
      );
      final b = a.copyWith(id: '2' as String?);
      expect(a, isNot(equals(b)));
    });
  });

  group('UserRole.fromString', () {
    test('parses admin', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
    });

    test('parses user', () {
      expect(UserRole.fromString('user'), UserRole.user);
    });

    test('defaults to user for unknown value', () {
      expect(UserRole.fromString('unknown'), UserRole.user);
    });
  });
}
