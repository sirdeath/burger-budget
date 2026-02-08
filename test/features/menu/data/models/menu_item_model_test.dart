import 'package:burger_budget/features/menu/data/models/menu_item_model.dart';
import 'package:burger_budget/features/menu/domain/entities/menu_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuItemModel', () {
    const testMap = {
      'id': 'mcd_001',
      'franchise': 'mcd',
      'name': '빅맥',
      'type': 'burger',
      'price': 5500,
      'calories': 583,
      'imageUrl': null,
      'tags': 'popular,signature',
    };

    group('fromMap', () {
      test('should create model from valid map', () {
        final model = MenuItemModel.fromMap(testMap);

        expect(model.id, 'mcd_001');
        expect(model.franchise, 'mcd');
        expect(model.name, '빅맥');
        expect(model.type, MenuType.burger);
        expect(model.price, 5500);
        expect(model.calories, 583);
        expect(model.imageUrl, isNull);
        expect(model.tags, ['popular', 'signature']);
      });

      test('should handle empty tags string', () {
        final map = Map<String, dynamic>.from(testMap)..['tags'] = '';
        final model = MenuItemModel.fromMap(map);

        expect(model.tags, isEmpty);
      });

      test('should handle null tags', () {
        final map = Map<String, dynamic>.from(testMap)..['tags'] = null;
        final model = MenuItemModel.fromMap(map);

        expect(model.tags, isEmpty);
      });

      test('should parse set type correctly', () {
        final map = Map<String, dynamic>.from(testMap)..['type'] = 'set';
        final model = MenuItemModel.fromMap(map);

        expect(model.type, MenuType.set_);
      });

      test('should parse all menu types', () {
        for (final entry in {
          'burger': MenuType.burger,
          'side': MenuType.side,
          'drink': MenuType.drink,
          'set': MenuType.set_,
        }.entries) {
          final map = Map<String, dynamic>.from(testMap)
            ..['type'] = entry.key;
          final model = MenuItemModel.fromMap(map);
          expect(model.type, entry.value);
        }
      });

      test('should throw on unknown menu type', () {
        final map = Map<String, dynamic>.from(testMap)
          ..['type'] = 'unknown';

        expect(() => MenuItemModel.fromMap(map), throwsArgumentError);
      });
    });

    group('toMap', () {
      test('should convert model to map', () {
        const model = MenuItemModel(
          id: 'mcd_001',
          franchise: 'mcd',
          name: '빅맥',
          type: MenuType.burger,
          price: 5500,
          calories: 583,
          tags: ['popular', 'signature'],
        );

        final map = model.toMap();

        expect(map['id'], 'mcd_001');
        expect(map['franchise'], 'mcd');
        expect(map['name'], '빅맥');
        expect(map['type'], 'burger');
        expect(map['price'], 5500);
        expect(map['calories'], 583);
        expect(map['tags'], 'popular,signature');
      });

      test('should convert set_ type to "set"', () {
        const model = MenuItemModel(
          id: 'mcd_set_001',
          franchise: 'mcd',
          name: '빅맥세트',
          type: MenuType.set_,
          price: 7500,
        );

        expect(model.toMap()['type'], 'set');
      });

      test('should handle empty tags', () {
        const model = MenuItemModel(
          id: 'mcd_001',
          franchise: 'mcd',
          name: '빅맥',
          type: MenuType.burger,
          price: 5500,
        );

        expect(model.toMap()['tags'], '');
      });
    });

    group('roundtrip', () {
      test('fromMap -> toMap should preserve data', () {
        final model = MenuItemModel.fromMap(testMap);
        final map = model.toMap();

        expect(map['id'], testMap['id']);
        expect(map['franchise'], testMap['franchise']);
        expect(map['name'], testMap['name']);
        expect(map['type'], testMap['type']);
        expect(map['price'], testMap['price']);
        expect(map['calories'], testMap['calories']);
        expect(map['tags'], testMap['tags']);
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        const entity = MenuItem(
          id: 'bk_001',
          franchise: 'bk',
          name: '와퍼',
          type: MenuType.burger,
          price: 6900,
          calories: 660,
          tags: ['signature'],
        );

        final model = MenuItemModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.franchise, entity.franchise);
        expect(model.name, entity.name);
        expect(model.type, entity.type);
        expect(model.price, entity.price);
        expect(model.calories, entity.calories);
        expect(model.tags, entity.tags);
      });
    });
  });
}
