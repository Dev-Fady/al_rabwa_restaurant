import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_line.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';

/// Serializable DTO for persisting the customer's cart state to Hive.
class CartModel {
  const CartModel({
    required this.orderType,
    required this.lines,
  });

  final String orderType;
  final List<CartLineModel> lines;

  factory CartModel.fromEntity(Cart cart) {
    return CartModel(
      orderType: cart.orderType,
      lines: [
        for (final line in cart.lines) CartLineModel.fromEntity(line),
      ],
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? const [];
    return CartModel(
      orderType: json['order_type'] as String? ?? Cart.defaultOrderType,
      lines: [
        for (final raw in rawLines)
          if (raw is Map<String, dynamic>)
            CartLineModel.fromJson(raw)
          else if (raw is Map)
            CartLineModel.fromJson(Map<String, dynamic>.from(raw)),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
        'order_type': orderType,
        'lines': [for (final line in lines) line.toJson()],
      };

  Cart toEntity() {
    return Cart(
      orderType: orderType,
      lines: [for (final line in lines) line.toEntity()],
    );
  }
}

class CartLineModel {
  const CartLineModel({
    required this.item,
    required this.quantity,
    required this.notes,
    required this.weight,
    this.option,
    this.addons = const [],
  });

  final CartMenuItemModel item;
  final int quantity;
  final String notes;
  final double weight;
  final CartOptionModel? option;
  final List<CartAddonModel> addons;

  factory CartLineModel.fromEntity(CartLine line) {
    return CartLineModel(
      item: CartMenuItemModel.fromEntity(line.item),
      quantity: line.quantity,
      notes: line.notes,
      weight: line.weight,
      option:
          line.option == null ? null : CartOptionModel.fromEntity(line.option!),
      addons: [
        for (final addon in line.addons) CartAddonModel.fromEntity(addon),
      ],
    );
  }

  factory CartLineModel.fromJson(Map<String, dynamic> json) {
    final rawAddons = json['addons'] as List<dynamic>? ?? const [];
    final rawOption = json['option'];

    return CartLineModel(
      item: CartMenuItemModel.fromJson(
        Map<String, dynamic>.from(json['item'] as Map? ?? {}),
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      notes: json['notes'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      option: rawOption is Map
          ? CartOptionModel.fromJson(Map<String, dynamic>.from(rawOption))
          : null,
      addons: [
        for (final raw in rawAddons)
          if (raw is Map)
            CartAddonModel.fromJson(Map<String, dynamic>.from(raw)),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'quantity': quantity,
        'notes': notes,
        'weight': weight,
        'option': option?.toJson(),
        'addons': [for (final addon in addons) addon.toJson()],
      };

  CartLine toEntity() {
    return CartLine(
      item: item.toEntity(),
      quantity: quantity,
      notes: notes,
      weight: weight,
      option: option?.toEntity(),
      addons: [for (final addon in addons) addon.toEntity()],
    );
  }
}

class CartMenuItemModel {
  const CartMenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.compareAtPrice,
    required this.image,
    required this.video,
    required this.hasLargePhoto,
    required this.soldByWeight,
    required this.weightRange,
    required this.options,
    required this.addons,
  });

  final int? id;
  final int? categoryId;
  final String name;
  final String description;
  final double price;
  final double? compareAtPrice;
  final String image;
  final String video;
  final bool hasLargePhoto;
  final bool soldByWeight;
  final CartWeightRangeModel? weightRange;
  final List<CartOptionModel> options;
  final List<CartAddonModel> addons;

  factory CartMenuItemModel.fromEntity(MenuItem item) {
    return CartMenuItemModel(
      id: item.id,
      categoryId: item.categoryId,
      name: item.name,
      description: item.description,
      price: item.price,
      compareAtPrice: item.compareAtPrice,
      image: item.image,
      video: item.video,
      hasLargePhoto: item.hasLargePhoto,
      soldByWeight: item.soldByWeight,
      weightRange: item.weightRange == null
          ? null
          : CartWeightRangeModel.fromEntity(item.weightRange!),
      options: [
        for (final opt in item.options) CartOptionModel.fromEntity(opt),
      ],
      addons: [
        for (final addon in item.addons) CartAddonModel.fromEntity(addon),
      ],
    );
  }

  factory CartMenuItemModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? const [];
    final rawAddons = json['addons'] as List<dynamic>? ?? const [];
    final rawRange = json['weight_range'];

    return CartMenuItemModel(
      id: (json['id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: (json['compare_at_price'] as num?)?.toDouble(),
      image: json['image'] as String? ?? '',
      video: json['video'] as String? ?? '',
      hasLargePhoto: json['has_large_photo'] as bool? ?? false,
      soldByWeight: json['sold_by_weight'] as bool? ?? false,
      weightRange: rawRange is Map
          ? CartWeightRangeModel.fromJson(Map<String, dynamic>.from(rawRange))
          : null,
      options: [
        for (final raw in rawOptions)
          if (raw is Map)
            CartOptionModel.fromJson(Map<String, dynamic>.from(raw)),
      ],
      addons: [
        for (final raw in rawAddons)
          if (raw is Map)
            CartAddonModel.fromJson(Map<String, dynamic>.from(raw)),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'compare_at_price': compareAtPrice,
        'image': image,
        'video': video,
        'has_large_photo': hasLargePhoto,
        'sold_by_weight': soldByWeight,
        'weight_range': weightRange?.toJson(),
        'options': [for (final opt in options) opt.toJson()],
        'addons': [for (final addon in addons) addon.toJson()],
      };

  MenuItem toEntity() {
    return MenuItem(
      id: id,
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
      compareAtPrice: compareAtPrice,
      image: image,
      video: video,
      hasLargePhoto: hasLargePhoto,
      soldByWeight: soldByWeight,
      weightRange: weightRange?.toEntity(),
      options: [for (final opt in options) opt.toEntity()],
      addons: [for (final addon in addons) addon.toEntity()],
    );
  }
}

class CartOptionModel {
  const CartOptionModel({
    required this.id,
    required this.name,
    required this.price,
  });

  final int? id;
  final String name;
  final double price;

  factory CartOptionModel.fromEntity(MenuItemOption option) {
    return CartOptionModel(
      id: option.id,
      name: option.name,
      price: option.price,
    );
  }

  factory CartOptionModel.fromJson(Map<String, dynamic> json) {
    return CartOptionModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };

  MenuItemOption toEntity() => MenuItemOption(id: id, name: name, price: price);
}

class CartAddonModel {
  const CartAddonModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  final int? id;
  final String name;
  final double price;
  final String image;

  factory CartAddonModel.fromEntity(MenuItemAddon addon) {
    return CartAddonModel(
      id: addon.id,
      name: addon.name,
      price: addon.price,
      image: addon.image,
    );
  }

  factory CartAddonModel.fromJson(Map<String, dynamic> json) {
    return CartAddonModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
      };

  MenuItemAddon toEntity() =>
      MenuItemAddon(id: id, name: name, price: price, image: image);
}

class CartWeightRangeModel {
  const CartWeightRangeModel({
    required this.min,
    required this.max,
    required this.step,
  });

  final double min;
  final double max;
  final double step;

  factory CartWeightRangeModel.fromEntity(MenuItemWeight range) {
    return CartWeightRangeModel(
      min: range.min,
      max: range.max,
      step: range.step,
    );
  }

  factory CartWeightRangeModel.fromJson(Map<String, dynamic> json) {
    return CartWeightRangeModel(
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 0.0,
      step: (json['step'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        'step': step,
      };

  MenuItemWeight toEntity() => MenuItemWeight(min: min, max: max, step: step);
}

