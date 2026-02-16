import 'package:burger_budget/features/favorite/data/models/favorite_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FavoriteModel', () {
    final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);
    final testDateTimeString = testDateTime.toIso8601String();

    group('fromMap', () {
      test('should create model from complete map', () {
        // Arrange
        final map = {
          'id': 1,
          'main_item_id': 'burger_1',
          'side_item_id': 'side_1',
          'drink_item_id': 'drink_1',
          'created_at': testDateTimeString,
        };

        // Act
        final result = FavoriteModel.fromMap(map);

        // Assert
        expect(result.id, 1);
        expect(result.mainItemId, 'burger_1');
        expect(result.sideItemId, 'side_1');
        expect(result.drinkItemId, 'drink_1');
        expect(result.createdAt, testDateTime);
      });

      test('should create model with null sideItemId', () {
        // Arrange
        final map = {
          'id': 1,
          'main_item_id': 'burger_1',
          'side_item_id': null,
          'drink_item_id': 'drink_1',
          'created_at': testDateTimeString,
        };

        // Act
        final result = FavoriteModel.fromMap(map);

        // Assert
        expect(result.id, 1);
        expect(result.mainItemId, 'burger_1');
        expect(result.sideItemId, null);
        expect(result.drinkItemId, 'drink_1');
        expect(result.createdAt, testDateTime);
      });

      test('should create model with null drinkItemId', () {
        // Arrange
        final map = {
          'id': 1,
          'main_item_id': 'burger_1',
          'side_item_id': 'side_1',
          'drink_item_id': null,
          'created_at': testDateTimeString,
        };

        // Act
        final result = FavoriteModel.fromMap(map);

        // Assert
        expect(result.id, 1);
        expect(result.mainItemId, 'burger_1');
        expect(result.sideItemId, 'side_1');
        expect(result.drinkItemId, null);
        expect(result.createdAt, testDateTime);
      });

      test('should create model with all nullable fields as null', () {
        // Arrange
        final map = {
          'id': 1,
          'main_item_id': 'burger_1',
          'side_item_id': null,
          'drink_item_id': null,
          'created_at': testDateTimeString,
        };

        // Act
        final result = FavoriteModel.fromMap(map);

        // Assert
        expect(result.id, 1);
        expect(result.mainItemId, 'burger_1');
        expect(result.sideItemId, null);
        expect(result.drinkItemId, null);
        expect(result.createdAt, testDateTime);
      });
    });

    group('toMap', () {
      test('should convert model to map with all fields', () {
        // Arrange
        final model = FavoriteModel(
          id: 1,
          mainItemId: 'burger_1',
          sideItemId: 'side_1',
          drinkItemId: 'drink_1',
          createdAt: testDateTime,
        );

        // Act
        final result = model.toMap();

        // Assert
        expect(result['main_item_id'], 'burger_1');
        expect(result['side_item_id'], 'side_1');
        expect(result['drink_item_id'], 'drink_1');
        expect(result['created_at'], testDateTimeString);
        expect(result.containsKey('id'), false); // id should not be in toMap
      });

      test('should convert model to map with null sideItemId', () {
        // Arrange
        final model = FavoriteModel(
          id: 1,
          mainItemId: 'burger_1',
          sideItemId: null,
          drinkItemId: 'drink_1',
          createdAt: testDateTime,
        );

        // Act
        final result = model.toMap();

        // Assert
        expect(result['main_item_id'], 'burger_1');
        expect(result['side_item_id'], null);
        expect(result['drink_item_id'], 'drink_1');
        expect(result['created_at'], testDateTimeString);
      });

      test('should convert model to map with all nullable fields as null', () {
        // Arrange
        final model = FavoriteModel(
          id: 1,
          mainItemId: 'burger_1',
          sideItemId: null,
          drinkItemId: null,
          createdAt: testDateTime,
        );

        // Act
        final result = model.toMap();

        // Assert
        expect(result['main_item_id'], 'burger_1');
        expect(result['side_item_id'], null);
        expect(result['drink_item_id'], null);
        expect(result['created_at'], testDateTimeString);
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        // Arrange
        final entity = FavoriteModel(
          id: 1,
          mainItemId: 'burger_1',
          sideItemId: 'side_1',
          drinkItemId: 'drink_1',
          createdAt: testDateTime,
        );

        // Act
        final result = FavoriteModel.fromEntity(entity);

        // Assert
        expect(result.id, 1);
        expect(result.mainItemId, 'burger_1');
        expect(result.sideItemId, 'side_1');
        expect(result.drinkItemId, 'drink_1');
        expect(result.createdAt, testDateTime);
      });
    });
  });
}
