enum UserRole {
  superAdmin,
  guestCustomer,
  customer,
  brandPromoter,
  salesPartner,
  seniorSalesPartner,
  subDealer,
  dealer,
  seniorDealer,
  masterDealer,
}

extension UserRoleExtension on UserRole {
  String get nameInBengali {
    switch (this) {
      case UserRole.superAdmin:
        return 'সুপার এডমিন';
      case UserRole.guestCustomer:
        return 'অতিথি গ্রাহক';
      case UserRole.customer:
        return 'গ্রাহক';
      case UserRole.brandPromoter:
        return 'ব্র্যান্ড প্রমোটর';
      case UserRole.salesPartner:
        return 'সেলস পার্টনার';
      case UserRole.seniorSalesPartner:
        return 'সিনিয়র সেলস পার্টনার';
      case UserRole.subDealer:
        return 'সাব ডিলার';
      case UserRole.dealer:
        return 'ডিলার';
      case UserRole.seniorDealer:
        return 'সিনিয়র ডিলার';
      case UserRole.masterDealer:
        return 'মাস্টার ডিলার';
    }
  }

  String get value {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.guestCustomer:
        return 'Guest Customer';
      case UserRole.customer:
        return 'Customer';
      case UserRole.brandPromoter:
        return 'Brand Promoter';
      case UserRole.salesPartner:
        return 'Sales Partner';
      case UserRole.seniorSalesPartner:
        return 'Senior Sales Partner';
      case UserRole.subDealer:
        return 'Sub Dealer';
      case UserRole.dealer:
        return 'Dealer';
      case UserRole.seniorDealer:
        return 'Senior Dealer';
      case UserRole.masterDealer:
        return 'Master Dealer';
    }
  }

  static UserRole fromString(String role) {
    switch (role) {
      case 'Super Admin':
        return UserRole.superAdmin;
      case 'Guest Customer':
        return UserRole.guestCustomer;
      case 'Customer':
        return UserRole.customer;
      case 'Brand Promoter':
        return UserRole.brandPromoter;
      case 'Sales Partner':
        return UserRole.salesPartner;
      case 'Senior Sales Partner':
        return UserRole.seniorSalesPartner;
      case 'Sub Dealer':
        return UserRole.subDealer;
      case 'Dealer':
        return UserRole.dealer;
      case 'Senior Dealer':
        return UserRole.seniorDealer;
      case 'Master Dealer':
        return UserRole.masterDealer;
      default:
        return UserRole.customer;
    }
  }
}
