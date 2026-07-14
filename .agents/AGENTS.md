# Trade Wing BD Workspace Customizations & Rules

## Business Club Membership Progression Sequence

Maintain the following sequential order, Bangla translations, and icons for Business Club membership ranks:

| Rank | English Role Key | Bangla Display Label | Material Icon |
|------|------------------|----------------------|---------------|
| 1    | `customer` | কাস্টমার | `Icons.person_outline` |
| 2    | `active customer` | সক্রিয় কাস্টমার | `Icons.shopping_bag_outlined` |
| 3    | `brand promoter` | ব্র্যান্ড প্রমোটার | `Icons.campaign_outlined` |
| 4    | `sales partner` | সেলস পার্টনার | `Icons.handshake_outlined` |
| 5    | `senior sales partner` | সিনিয়র সেলস পার্টনার | `Icons.business_center_outlined` |
| 6    | `sub dealer` | সাব ডিলার | `Icons.storefront_outlined` |
| 7    | `dealer` | ডিলার | `Icons.store_outlined` |
| 8    | `senior dealer` | সিনিয়র ডিলার | `Icons.domain_outlined` |
| 9    | `master dealer` | মাস্টার ডিলার | `Icons.workspace_premium_outlined` |
| 10   | `regional distributor` | রিজিওনাল ডিস্ট্রিবিউটর | `Icons.local_shipping_outlined` |

### Rules for Promotions & Role Mapping:
* **Active Status Logic:** When evaluating a user's promotion status, ranks are strictly progressive from Rank 1 (`customer`) up to Rank 10 (`regional distributor`).
* **Admin Bypass:** Admins and Super Admins bypass the sequence and automatically unlock all levels (Active Index = 9).
* **Case-Insensitive Match:** When checking roles from Firestore, trim and normalize to lowercase before matching.

## Snackbar Style & Position

All snackbars shown via `Get.snackbar` must follow the designated design pattern and appear at the bottom:

```dart
Get.snackbar(
  title,
  message,
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2), // AppColors.primaryColor
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
```
