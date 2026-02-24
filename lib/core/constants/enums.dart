enum UserRole { buyer, seller, tenant, landlord }

extension UserRoleX on UserRole {
  String get titleAr {
    switch (this) {
      case UserRole.buyer:
        return 'مشتري';
      case UserRole.seller:
        return 'بائع';
      case UserRole.tenant:
        return 'مستأجر';
      case UserRole.landlord:
        return 'مؤجر';
    }
  }
}

// const List<String> kVisitTimeSlots = [
//   '10:00',
//   '11:00',
//   '12:00',
//   '14:00',
//   '15:00',
//   '16:00',
// ];
