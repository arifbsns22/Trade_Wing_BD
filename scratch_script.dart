import 'dart:io';

void main() async {
  final file = File(r'c:\Users\mohos\OneDrive\Desktop\trade_wign_bd\lib\features\users\e-commerce\presentation\widgets\order_details_bottom_sheet.dart');
  var content = await file.readAsString();

  // 1. Add _buildAdminActionsCard to build method
  content = content.replaceFirst(
    '''
                  const SizedBox(height: 8),
                  _buildHeaderCard(),
                  const SizedBox(height: 16),

                  _sectionTitle('Items Ordered', Icons.shopping_bag_outlined),
''',
    '''
                  const SizedBox(height: 8),
                  _buildHeaderCard(),
                  const SizedBox(height: 16),

                  if (isAdmin) ...[
                    _sectionTitle('Admin Actions', Icons.admin_panel_settings_outlined),
                    const SizedBox(height: 10),
                    _buildAdminActionsCard(),
                    const SizedBox(height: 16),
                  ],

                  _sectionTitle('Items Ordered', Icons.shopping_bag_outlined),
'''
  );

  // 2. Remove Order Status dropdown from _sectionTitle
  final orderStatusRegex = RegExp(
    r"_sectionTitle\(\s*'Order Status',\s*Icons\.local_shipping_outlined,\s*trailing: isAdmin[\s\S]*?,\s*\),",
  );
  content = content.replaceFirst(
    orderStatusRegex,
    "_sectionTitle('Order Status', Icons.local_shipping_outlined),"
  );

  // 3. Revert Payment Status row to simple view
  final paymentStatusRegex = RegExp(
    r"Row\(\s*mainAxisAlignment: MainAxisAlignment\.spaceBetween,\s*children: \[\s*Text\(\s*'Payment Status'[\s\S]*?else\s*(Container\([\s\S]*?),\s*\],\s*\),",
  );
  content = content.replaceFirstMapped(paymentStatusRegex, (match) {
    // Keep the 'Payment Status' text on left, and the Container on right
    return '''
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Status',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              \${match.group(1)}
            ],
          ),
''';
  });

  // 4. Add _buildAdminActionsCard method
  final adminActionsCode = '''

  Widget _buildAdminActionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Status',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              DropdownButton<OrderStatus>(
                value: currentOrderStatus,
                isDense: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    _updateOrderStatus(newStatus);
                  }
                },
                items: OrderStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Status',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              DropdownButton<PaymentStatus>(
                value: currentPaymentStatus,
                isDense: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                style: TextStyle(
                  fontSize: 13,
                  color: currentPaymentStatus == PaymentStatus.verified
                      ? AppColors.green
                      : (currentPaymentStatus == PaymentStatus.failed
                          ? Colors.red
                          : Colors.orange),
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    _updatePaymentStatus(newStatus);
                  }
                },
                items: PaymentStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
''';

  content = content.replaceFirst(
    "  Widget _buildTimelineCard() {",
    "\$adminActionsCode\n  Widget _buildTimelineCard() {"
  );

  await file.writeAsString(content);
  print('Done.');
}
