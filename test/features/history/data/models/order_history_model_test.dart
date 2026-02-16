import 'package:burger_budget/features/history/data/models/order_history_model.dart';
import 'package:burger_budget/features/history/domain/entities/order_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderHistoryModel', () {
    final testDateTime = DateTime(2024, 1, 15, 12, 30);
    final testMap = {
      'id': 1,
      'main_item_id': 'burger_001',
      'side_item_id': 'fries_001',
      'drink_item_id': 'coke_001',
      'total_price': 15000,
      'created_at': testDateTime.toIso8601String(),
    };

    test('fromMap should correctly convert map to model with all fields', () {
      final model = OrderHistoryModel.fromMap(testMap);

      expect(model.id, 1);
      expect(model.mainItemId, 'burger_001');
      expect(model.sideItemId, 'fries_001');
      expect(model.drinkItemId, 'coke_001');
      expect(model.totalPrice, 15000);
      expect(model.createdAt, testDateTime);
    });

    test('fromMap should handle nullable fields correctly', () {
      final mapWithNulls = {
        'id': 2,
        'main_item_id': 'burger_002',
        'side_item_id': null,
        'drink_item_id': null,
        'total_price': 8000,
        'created_at': testDateTime.toIso8601String(),
      };

      final model = OrderHistoryModel.fromMap(mapWithNulls);

      expect(model.id, 2);
      expect(model.mainItemId, 'burger_002');
      expect(model.sideItemId, isNull);
      expect(model.drinkItemId, isNull);
      expect(model.totalPrice, 8000);
      expect(model.createdAt, testDateTime);
    });

    test('toMap should correctly convert model to map', () {
      final model = OrderHistoryModel(
        id: 1,
        mainItemId: 'burger_001',
        sideItemId: 'fries_001',
        drinkItemId: 'coke_001',
        totalPrice: 15000,
        createdAt: testDateTime,
      );

      final map = model.toMap();

      expect(map['main_item_id'], 'burger_001');
      expect(map['side_item_id'], 'fries_001');
      expect(map['drink_item_id'], 'coke_001');
      expect(map['total_price'], 15000);
      expect(map['created_at'], testDateTime.toIso8601String());
      expect(map.containsKey('id'), false);
    });

    test('fromEntity should correctly convert entity to model', () {
      final entity = OrderHistory(
        id: 3,
        mainItemId: 'burger_003',
        sideItemId: 'onion_rings',
        drinkItemId: 'sprite',
        totalPrice: 18000,
        createdAt: testDateTime,
      );

      final model = OrderHistoryModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.mainItemId, entity.mainItemId);
      expect(model.sideItemId, entity.sideItemId);
      expect(model.drinkItemId, entity.drinkItemId);
      expect(model.totalPrice, entity.totalPrice);
      expect(model.createdAt, entity.createdAt);
    });

    test('model should extend OrderHistory entity', () {
      final model = OrderHistoryModel(
        id: 1,
        mainItemId: 'burger_001',
        totalPrice: 10000,
        createdAt: testDateTime,
      );

      expect(model, isA<OrderHistory>());
    });
  });
}
