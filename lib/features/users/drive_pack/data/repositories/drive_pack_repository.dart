import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/operator_model.dart';
import '../../domain/models/drive_package_model.dart';
import '../../domain/models/recharge_model.dart';

class DrivePackRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _operatorsCollection = 'operators';
  static const String _packagesCollection = 'drive_packages';
  static const String _rechargesCollection = 'mobile_recharges';

  // --- Operators Setup ---

  /// Stream of all operators
  Stream<List<OperatorModel>> streamOperators() {
    return _firestore
        .collection(_operatorsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OperatorModel.fromFirestore(doc))
            .toList());
  }

  /// Get list of operators
  Future<List<OperatorModel>> getOperators() async {
    final snapshot = await _firestore
        .collection(_operatorsCollection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => OperatorModel.fromFirestore(doc)).toList();
  }

  /// Add operator
  Future<void> addOperator(OperatorModel operator) async {
    await _firestore
        .collection(_operatorsCollection)
        .add(operator.toFirestore());
  }

  /// Delete operator
  Future<void> deleteOperator(String id) async {
    await _firestore.collection(_operatorsCollection).doc(id).delete();
  }

  // --- Drive Packages (Offers) ---

  /// Stream of all packages
  Stream<List<DrivePackageModel>> streamAllOffers() {
    return _firestore
        .collection(_packagesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DrivePackageModel.fromFirestore(doc))
            .toList());
  }

  /// Fetch all packages
  Future<List<DrivePackageModel>> getAllOffers() async {
    final snapshot = await _firestore
        .collection(_packagesCollection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => DrivePackageModel.fromFirestore(doc))
        .toList();
  }

  /// Fetch packages filtered by operatorId
  Stream<List<DrivePackageModel>> streamOffersByOperator(String operatorId) {
    return _firestore
        .collection(_packagesCollection)
        .where('operatorId', isEqualTo: operatorId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DrivePackageModel.fromFirestore(doc))
            .toList());
  }

  /// Add a package
  Future<void> addOffer(DrivePackageModel offer) async {
    await _firestore.collection(_packagesCollection).add(offer.toFirestore());
  }

  /// Update a package
  Future<void> updateOffer(DrivePackageModel offer) async {
    await _firestore
        .collection(_packagesCollection)
        .doc(offer.id)
        .update(offer.toFirestore());
  }

  /// Delete a package
  Future<void> deleteOffer(String id) async {
    await _firestore.collection(_packagesCollection).doc(id).delete();
  }

  // --- Mobile Recharges ---

  /// Create a mobile recharge record (financial ledger)
  Future<void> createRecharge(RechargeModel recharge) async {
    await _firestore
        .collection(_rechargesCollection)
        .doc(recharge.transactionId)
        .set(recharge.toFirestore());
  }

  /// Get user's recharge history
  Stream<List<RechargeModel>> streamUserRechargeHistory(String userMobile) {
    return _firestore
        .collection(_rechargesCollection)
        .where('userMobile', isEqualTo: userMobile)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RechargeModel.fromFirestore(doc))
            .toList());
  }
}
