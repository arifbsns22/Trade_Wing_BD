enum UserRole {
  superAdmin,
  guestCustomer,
  customer,
  activeCustomer,
  brandPromoter,
  salesPartner,
  seniorSalesPartner,
  subDealer,
  dealer,
  seniorDealer,
  masterDealer,
  regionalDistributor,
}

extension UserRoleExtension on UserRole {
  String get nameInBengali {
    switch (this) {
      case UserRole.superAdmin:
        return 'সুপার এডমিন';
      case UserRole.guestCustomer:
        return 'অতিথি গ্রাহক';
      case UserRole.customer:
        return 'কাস্টমার';
      case UserRole.activeCustomer:
        return 'সক্রিয় কাস্টমার';
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
      case UserRole.regionalDistributor:
        return 'রিজিওনাল ডিস্ট্রিবিউটর';
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
      case UserRole.activeCustomer:
        return 'Active Customer';
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
      case UserRole.regionalDistributor:
        return 'Regional Distributor';
    }
  }

  static UserRole fromString(String role) {
    final normalized = role.trim().toLowerCase();
    switch (normalized) {
      case 'super admin':
        return UserRole.superAdmin;
      case 'guest customer':
        return UserRole.guestCustomer;
      case 'customer':
        return UserRole.customer;
      case 'active customer':
        return UserRole.activeCustomer;
      case 'brand promoter':
        return UserRole.brandPromoter;
      case 'sales partner':
        return UserRole.salesPartner;
      case 'senior sales partner':
        return UserRole.seniorSalesPartner;
      case 'sub dealer':
        return UserRole.subDealer;
      case 'dealer':
        return UserRole.dealer;
      case 'senior dealer':
        return UserRole.seniorDealer;
      case 'master dealer':
        return UserRole.masterDealer;
      case 'regional distributor':
        return UserRole.regionalDistributor;
      default:
        return UserRole.customer;
    }
  }
}
