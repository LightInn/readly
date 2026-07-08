// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PantryItemsTable extends PantryItems
    with TableInfo<$PantryItemsTable, PantryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PantryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalPer100gMeta = const VerificationMeta(
    'kcalPer100g',
  );
  @override
  late final GeneratedColumn<double> kcalPer100g = GeneratedColumn<double>(
    'kcal_per100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinsPer100gMeta = const VerificationMeta(
    'proteinsPer100g',
  );
  @override
  late final GeneratedColumn<double> proteinsPer100g = GeneratedColumn<double>(
    'proteins_per100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsPer100gMeta = const VerificationMeta(
    'carbsPer100g',
  );
  @override
  late final GeneratedColumn<double> carbsPer100g = GeneratedColumn<double>(
    'carbs_per100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugarsPer100gMeta = const VerificationMeta(
    'sugarsPer100g',
  );
  @override
  late final GeneratedColumn<double> sugarsPer100g = GeneratedColumn<double>(
    'sugars_per100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatsPer100gMeta = const VerificationMeta(
    'fatsPer100g',
  );
  @override
  late final GeneratedColumn<double> fatsPer100g = GeneratedColumn<double>(
    'fats_per100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packageQuantityMeta = const VerificationMeta(
    'packageQuantity',
  );
  @override
  late final GeneratedColumn<String> packageQuantity = GeneratedColumn<String>(
    'package_quantity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitCountMeta = const VerificationMeta(
    'unitCount',
  );
  @override
  late final GeneratedColumn<int> unitCount = GeneratedColumn<int>(
    'unit_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _perishableMeta = const VerificationMeta(
    'perishable',
  );
  @override
  late final GeneratedColumn<bool> perishable = GeneratedColumn<bool>(
    'perishable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("perishable" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _amountLeftMeta = const VerificationMeta(
    'amountLeft',
  );
  @override
  late final GeneratedColumn<double> amountLeft = GeneratedColumn<double>(
    'amount_left',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    barcode,
    name,
    brand,
    imageUrl,
    kcalPer100g,
    proteinsPer100g,
    carbsPer100g,
    sugarsPer100g,
    fatsPer100g,
    packageQuantity,
    unitCount,
    perishable,
    amountLeft,
    addedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pantry_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PantryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('kcal_per100g')) {
      context.handle(
        _kcalPer100gMeta,
        kcalPer100g.isAcceptableOrUnknown(
          data['kcal_per100g']!,
          _kcalPer100gMeta,
        ),
      );
    }
    if (data.containsKey('proteins_per100g')) {
      context.handle(
        _proteinsPer100gMeta,
        proteinsPer100g.isAcceptableOrUnknown(
          data['proteins_per100g']!,
          _proteinsPer100gMeta,
        ),
      );
    }
    if (data.containsKey('carbs_per100g')) {
      context.handle(
        _carbsPer100gMeta,
        carbsPer100g.isAcceptableOrUnknown(
          data['carbs_per100g']!,
          _carbsPer100gMeta,
        ),
      );
    }
    if (data.containsKey('sugars_per100g')) {
      context.handle(
        _sugarsPer100gMeta,
        sugarsPer100g.isAcceptableOrUnknown(
          data['sugars_per100g']!,
          _sugarsPer100gMeta,
        ),
      );
    }
    if (data.containsKey('fats_per100g')) {
      context.handle(
        _fatsPer100gMeta,
        fatsPer100g.isAcceptableOrUnknown(
          data['fats_per100g']!,
          _fatsPer100gMeta,
        ),
      );
    }
    if (data.containsKey('package_quantity')) {
      context.handle(
        _packageQuantityMeta,
        packageQuantity.isAcceptableOrUnknown(
          data['package_quantity']!,
          _packageQuantityMeta,
        ),
      );
    }
    if (data.containsKey('unit_count')) {
      context.handle(
        _unitCountMeta,
        unitCount.isAcceptableOrUnknown(data['unit_count']!, _unitCountMeta),
      );
    }
    if (data.containsKey('perishable')) {
      context.handle(
        _perishableMeta,
        perishable.isAcceptableOrUnknown(data['perishable']!, _perishableMeta),
      );
    }
    if (data.containsKey('amount_left')) {
      context.handle(
        _amountLeftMeta,
        amountLeft.isAcceptableOrUnknown(data['amount_left']!, _amountLeftMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PantryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PantryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      kcalPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_per100g'],
      ),
      proteinsPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}proteins_per100g'],
      ),
      carbsPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_per100g'],
      ),
      sugarsPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugars_per100g'],
      ),
      fatsPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fats_per100g'],
      ),
      packageQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_quantity'],
      ),
      unitCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_count'],
      ),
      perishable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}perishable'],
      )!,
      amountLeft: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_left'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PantryItemsTable createAlias(String alias) {
    return $PantryItemsTable(attachedDatabase, alias);
  }
}

class PantryItem extends DataClass implements Insertable<PantryItem> {
  final int id;
  final String? barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final double? kcalPer100g;
  final double? proteinsPer100g;
  final double? carbsPer100g;
  final double? sugarsPer100g;
  final double? fatsPer100g;

  /// Human readable package size, e.g. "500 g".
  final String? packageQuantity;

  /// For foods counted in units (eggs, yogurts…): units per full package.
  /// Null means the item is tracked as a percentage of the package.
  final int? unitCount;

  /// Perishable foods should be eaten first.
  final bool perishable;

  /// Estimated fraction left in the package, 0.0 to 1.0.
  final double amountLeft;
  final DateTime addedAt;
  final DateTime updatedAt;
  const PantryItem({
    required this.id,
    this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.kcalPer100g,
    this.proteinsPer100g,
    this.carbsPer100g,
    this.sugarsPer100g,
    this.fatsPer100g,
    this.packageQuantity,
    this.unitCount,
    required this.perishable,
    required this.amountLeft,
    required this.addedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || kcalPer100g != null) {
      map['kcal_per100g'] = Variable<double>(kcalPer100g);
    }
    if (!nullToAbsent || proteinsPer100g != null) {
      map['proteins_per100g'] = Variable<double>(proteinsPer100g);
    }
    if (!nullToAbsent || carbsPer100g != null) {
      map['carbs_per100g'] = Variable<double>(carbsPer100g);
    }
    if (!nullToAbsent || sugarsPer100g != null) {
      map['sugars_per100g'] = Variable<double>(sugarsPer100g);
    }
    if (!nullToAbsent || fatsPer100g != null) {
      map['fats_per100g'] = Variable<double>(fatsPer100g);
    }
    if (!nullToAbsent || packageQuantity != null) {
      map['package_quantity'] = Variable<String>(packageQuantity);
    }
    if (!nullToAbsent || unitCount != null) {
      map['unit_count'] = Variable<int>(unitCount);
    }
    map['perishable'] = Variable<bool>(perishable);
    map['amount_left'] = Variable<double>(amountLeft);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PantryItemsCompanion toCompanion(bool nullToAbsent) {
    return PantryItemsCompanion(
      id: Value(id),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      kcalPer100g: kcalPer100g == null && nullToAbsent
          ? const Value.absent()
          : Value(kcalPer100g),
      proteinsPer100g: proteinsPer100g == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinsPer100g),
      carbsPer100g: carbsPer100g == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsPer100g),
      sugarsPer100g: sugarsPer100g == null && nullToAbsent
          ? const Value.absent()
          : Value(sugarsPer100g),
      fatsPer100g: fatsPer100g == null && nullToAbsent
          ? const Value.absent()
          : Value(fatsPer100g),
      packageQuantity: packageQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(packageQuantity),
      unitCount: unitCount == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCount),
      perishable: Value(perishable),
      amountLeft: Value(amountLeft),
      addedAt: Value(addedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PantryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PantryItem(
      id: serializer.fromJson<int>(json['id']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      kcalPer100g: serializer.fromJson<double?>(json['kcalPer100g']),
      proteinsPer100g: serializer.fromJson<double?>(json['proteinsPer100g']),
      carbsPer100g: serializer.fromJson<double?>(json['carbsPer100g']),
      sugarsPer100g: serializer.fromJson<double?>(json['sugarsPer100g']),
      fatsPer100g: serializer.fromJson<double?>(json['fatsPer100g']),
      packageQuantity: serializer.fromJson<String?>(json['packageQuantity']),
      unitCount: serializer.fromJson<int?>(json['unitCount']),
      perishable: serializer.fromJson<bool>(json['perishable']),
      amountLeft: serializer.fromJson<double>(json['amountLeft']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barcode': serializer.toJson<String?>(barcode),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'kcalPer100g': serializer.toJson<double?>(kcalPer100g),
      'proteinsPer100g': serializer.toJson<double?>(proteinsPer100g),
      'carbsPer100g': serializer.toJson<double?>(carbsPer100g),
      'sugarsPer100g': serializer.toJson<double?>(sugarsPer100g),
      'fatsPer100g': serializer.toJson<double?>(fatsPer100g),
      'packageQuantity': serializer.toJson<String?>(packageQuantity),
      'unitCount': serializer.toJson<int?>(unitCount),
      'perishable': serializer.toJson<bool>(perishable),
      'amountLeft': serializer.toJson<double>(amountLeft),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PantryItem copyWith({
    int? id,
    Value<String?> barcode = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<double?> kcalPer100g = const Value.absent(),
    Value<double?> proteinsPer100g = const Value.absent(),
    Value<double?> carbsPer100g = const Value.absent(),
    Value<double?> sugarsPer100g = const Value.absent(),
    Value<double?> fatsPer100g = const Value.absent(),
    Value<String?> packageQuantity = const Value.absent(),
    Value<int?> unitCount = const Value.absent(),
    bool? perishable,
    double? amountLeft,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) => PantryItem(
    id: id ?? this.id,
    barcode: barcode.present ? barcode.value : this.barcode,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    kcalPer100g: kcalPer100g.present ? kcalPer100g.value : this.kcalPer100g,
    proteinsPer100g: proteinsPer100g.present
        ? proteinsPer100g.value
        : this.proteinsPer100g,
    carbsPer100g: carbsPer100g.present ? carbsPer100g.value : this.carbsPer100g,
    sugarsPer100g: sugarsPer100g.present
        ? sugarsPer100g.value
        : this.sugarsPer100g,
    fatsPer100g: fatsPer100g.present ? fatsPer100g.value : this.fatsPer100g,
    packageQuantity: packageQuantity.present
        ? packageQuantity.value
        : this.packageQuantity,
    unitCount: unitCount.present ? unitCount.value : this.unitCount,
    perishable: perishable ?? this.perishable,
    amountLeft: amountLeft ?? this.amountLeft,
    addedAt: addedAt ?? this.addedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PantryItem copyWithCompanion(PantryItemsCompanion data) {
    return PantryItem(
      id: data.id.present ? data.id.value : this.id,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      kcalPer100g: data.kcalPer100g.present
          ? data.kcalPer100g.value
          : this.kcalPer100g,
      proteinsPer100g: data.proteinsPer100g.present
          ? data.proteinsPer100g.value
          : this.proteinsPer100g,
      carbsPer100g: data.carbsPer100g.present
          ? data.carbsPer100g.value
          : this.carbsPer100g,
      sugarsPer100g: data.sugarsPer100g.present
          ? data.sugarsPer100g.value
          : this.sugarsPer100g,
      fatsPer100g: data.fatsPer100g.present
          ? data.fatsPer100g.value
          : this.fatsPer100g,
      packageQuantity: data.packageQuantity.present
          ? data.packageQuantity.value
          : this.packageQuantity,
      unitCount: data.unitCount.present ? data.unitCount.value : this.unitCount,
      perishable: data.perishable.present
          ? data.perishable.value
          : this.perishable,
      amountLeft: data.amountLeft.present
          ? data.amountLeft.value
          : this.amountLeft,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PantryItem(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinsPer100g: $proteinsPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('sugarsPer100g: $sugarsPer100g, ')
          ..write('fatsPer100g: $fatsPer100g, ')
          ..write('packageQuantity: $packageQuantity, ')
          ..write('unitCount: $unitCount, ')
          ..write('perishable: $perishable, ')
          ..write('amountLeft: $amountLeft, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    barcode,
    name,
    brand,
    imageUrl,
    kcalPer100g,
    proteinsPer100g,
    carbsPer100g,
    sugarsPer100g,
    fatsPer100g,
    packageQuantity,
    unitCount,
    perishable,
    amountLeft,
    addedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PantryItem &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.imageUrl == this.imageUrl &&
          other.kcalPer100g == this.kcalPer100g &&
          other.proteinsPer100g == this.proteinsPer100g &&
          other.carbsPer100g == this.carbsPer100g &&
          other.sugarsPer100g == this.sugarsPer100g &&
          other.fatsPer100g == this.fatsPer100g &&
          other.packageQuantity == this.packageQuantity &&
          other.unitCount == this.unitCount &&
          other.perishable == this.perishable &&
          other.amountLeft == this.amountLeft &&
          other.addedAt == this.addedAt &&
          other.updatedAt == this.updatedAt);
}

class PantryItemsCompanion extends UpdateCompanion<PantryItem> {
  final Value<int> id;
  final Value<String?> barcode;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> imageUrl;
  final Value<double?> kcalPer100g;
  final Value<double?> proteinsPer100g;
  final Value<double?> carbsPer100g;
  final Value<double?> sugarsPer100g;
  final Value<double?> fatsPer100g;
  final Value<String?> packageQuantity;
  final Value<int?> unitCount;
  final Value<bool> perishable;
  final Value<double> amountLeft;
  final Value<DateTime> addedAt;
  final Value<DateTime> updatedAt;
  const PantryItemsCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.kcalPer100g = const Value.absent(),
    this.proteinsPer100g = const Value.absent(),
    this.carbsPer100g = const Value.absent(),
    this.sugarsPer100g = const Value.absent(),
    this.fatsPer100g = const Value.absent(),
    this.packageQuantity = const Value.absent(),
    this.unitCount = const Value.absent(),
    this.perishable = const Value.absent(),
    this.amountLeft = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PantryItemsCompanion.insert({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.kcalPer100g = const Value.absent(),
    this.proteinsPer100g = const Value.absent(),
    this.carbsPer100g = const Value.absent(),
    this.sugarsPer100g = const Value.absent(),
    this.fatsPer100g = const Value.absent(),
    this.packageQuantity = const Value.absent(),
    this.unitCount = const Value.absent(),
    this.perishable = const Value.absent(),
    this.amountLeft = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PantryItem> custom({
    Expression<int>? id,
    Expression<String>? barcode,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? imageUrl,
    Expression<double>? kcalPer100g,
    Expression<double>? proteinsPer100g,
    Expression<double>? carbsPer100g,
    Expression<double>? sugarsPer100g,
    Expression<double>? fatsPer100g,
    Expression<String>? packageQuantity,
    Expression<int>? unitCount,
    Expression<bool>? perishable,
    Expression<double>? amountLeft,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (imageUrl != null) 'image_url': imageUrl,
      if (kcalPer100g != null) 'kcal_per100g': kcalPer100g,
      if (proteinsPer100g != null) 'proteins_per100g': proteinsPer100g,
      if (carbsPer100g != null) 'carbs_per100g': carbsPer100g,
      if (sugarsPer100g != null) 'sugars_per100g': sugarsPer100g,
      if (fatsPer100g != null) 'fats_per100g': fatsPer100g,
      if (packageQuantity != null) 'package_quantity': packageQuantity,
      if (unitCount != null) 'unit_count': unitCount,
      if (perishable != null) 'perishable': perishable,
      if (amountLeft != null) 'amount_left': amountLeft,
      if (addedAt != null) 'added_at': addedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PantryItemsCompanion copyWith({
    Value<int>? id,
    Value<String?>? barcode,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? imageUrl,
    Value<double?>? kcalPer100g,
    Value<double?>? proteinsPer100g,
    Value<double?>? carbsPer100g,
    Value<double?>? sugarsPer100g,
    Value<double?>? fatsPer100g,
    Value<String?>? packageQuantity,
    Value<int?>? unitCount,
    Value<bool>? perishable,
    Value<double>? amountLeft,
    Value<DateTime>? addedAt,
    Value<DateTime>? updatedAt,
  }) {
    return PantryItemsCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      kcalPer100g: kcalPer100g ?? this.kcalPer100g,
      proteinsPer100g: proteinsPer100g ?? this.proteinsPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      sugarsPer100g: sugarsPer100g ?? this.sugarsPer100g,
      fatsPer100g: fatsPer100g ?? this.fatsPer100g,
      packageQuantity: packageQuantity ?? this.packageQuantity,
      unitCount: unitCount ?? this.unitCount,
      perishable: perishable ?? this.perishable,
      amountLeft: amountLeft ?? this.amountLeft,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (kcalPer100g.present) {
      map['kcal_per100g'] = Variable<double>(kcalPer100g.value);
    }
    if (proteinsPer100g.present) {
      map['proteins_per100g'] = Variable<double>(proteinsPer100g.value);
    }
    if (carbsPer100g.present) {
      map['carbs_per100g'] = Variable<double>(carbsPer100g.value);
    }
    if (sugarsPer100g.present) {
      map['sugars_per100g'] = Variable<double>(sugarsPer100g.value);
    }
    if (fatsPer100g.present) {
      map['fats_per100g'] = Variable<double>(fatsPer100g.value);
    }
    if (packageQuantity.present) {
      map['package_quantity'] = Variable<String>(packageQuantity.value);
    }
    if (unitCount.present) {
      map['unit_count'] = Variable<int>(unitCount.value);
    }
    if (perishable.present) {
      map['perishable'] = Variable<bool>(perishable.value);
    }
    if (amountLeft.present) {
      map['amount_left'] = Variable<double>(amountLeft.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PantryItemsCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinsPer100g: $proteinsPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('sugarsPer100g: $sugarsPer100g, ')
          ..write('fatsPer100g: $fatsPer100g, ')
          ..write('packageQuantity: $packageQuantity, ')
          ..write('unitCount: $unitCount, ')
          ..write('perishable: $perishable, ')
          ..write('amountLeft: $amountLeft, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ConsumptionEntriesTable extends ConsumptionEntries
    with TableInfo<$ConsumptionEntriesTable, ConsumptionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsumptionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pantryItemIdMeta = const VerificationMeta(
    'pantryItemId',
  );
  @override
  late final GeneratedColumn<int> pantryItemId = GeneratedColumn<int>(
    'pantry_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kcal,
    mealType,
    pantryItemId,
    grams,
    loggedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consumption_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConsumptionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('pantry_item_id')) {
      context.handle(
        _pantryItemIdMeta,
        pantryItemId.isAcceptableOrUnknown(
          data['pantry_item_id']!,
          _pantryItemIdMeta,
        ),
      );
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConsumptionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsumptionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      pantryItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pantry_item_id'],
      ),
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      ),
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
    );
  }

  @override
  $ConsumptionEntriesTable createAlias(String alias) {
    return $ConsumptionEntriesTable(attachedDatabase, alias);
  }
}

class ConsumptionEntry extends DataClass
    implements Insertable<ConsumptionEntry> {
  final int id;
  final String name;
  final double kcal;

  /// breakfast | lunch | dinner | snack
  final String mealType;
  final int? pantryItemId;
  final double? grams;
  final DateTime loggedAt;
  const ConsumptionEntry({
    required this.id,
    required this.name,
    required this.kcal,
    required this.mealType,
    this.pantryItemId,
    this.grams,
    required this.loggedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kcal'] = Variable<double>(kcal);
    map['meal_type'] = Variable<String>(mealType);
    if (!nullToAbsent || pantryItemId != null) {
      map['pantry_item_id'] = Variable<int>(pantryItemId);
    }
    if (!nullToAbsent || grams != null) {
      map['grams'] = Variable<double>(grams);
    }
    map['logged_at'] = Variable<DateTime>(loggedAt);
    return map;
  }

  ConsumptionEntriesCompanion toCompanion(bool nullToAbsent) {
    return ConsumptionEntriesCompanion(
      id: Value(id),
      name: Value(name),
      kcal: Value(kcal),
      mealType: Value(mealType),
      pantryItemId: pantryItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(pantryItemId),
      grams: grams == null && nullToAbsent
          ? const Value.absent()
          : Value(grams),
      loggedAt: Value(loggedAt),
    );
  }

  factory ConsumptionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsumptionEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kcal: serializer.fromJson<double>(json['kcal']),
      mealType: serializer.fromJson<String>(json['mealType']),
      pantryItemId: serializer.fromJson<int?>(json['pantryItemId']),
      grams: serializer.fromJson<double?>(json['grams']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kcal': serializer.toJson<double>(kcal),
      'mealType': serializer.toJson<String>(mealType),
      'pantryItemId': serializer.toJson<int?>(pantryItemId),
      'grams': serializer.toJson<double?>(grams),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
    };
  }

  ConsumptionEntry copyWith({
    int? id,
    String? name,
    double? kcal,
    String? mealType,
    Value<int?> pantryItemId = const Value.absent(),
    Value<double?> grams = const Value.absent(),
    DateTime? loggedAt,
  }) => ConsumptionEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    kcal: kcal ?? this.kcal,
    mealType: mealType ?? this.mealType,
    pantryItemId: pantryItemId.present ? pantryItemId.value : this.pantryItemId,
    grams: grams.present ? grams.value : this.grams,
    loggedAt: loggedAt ?? this.loggedAt,
  );
  ConsumptionEntry copyWithCompanion(ConsumptionEntriesCompanion data) {
    return ConsumptionEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      pantryItemId: data.pantryItemId.present
          ? data.pantryItemId.value
          : this.pantryItemId,
      grams: data.grams.present ? data.grams.value : this.grams,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsumptionEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kcal: $kcal, ')
          ..write('mealType: $mealType, ')
          ..write('pantryItemId: $pantryItemId, ')
          ..write('grams: $grams, ')
          ..write('loggedAt: $loggedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, kcal, mealType, pantryItemId, grams, loggedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsumptionEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.kcal == this.kcal &&
          other.mealType == this.mealType &&
          other.pantryItemId == this.pantryItemId &&
          other.grams == this.grams &&
          other.loggedAt == this.loggedAt);
}

class ConsumptionEntriesCompanion extends UpdateCompanion<ConsumptionEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> kcal;
  final Value<String> mealType;
  final Value<int?> pantryItemId;
  final Value<double?> grams;
  final Value<DateTime> loggedAt;
  const ConsumptionEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kcal = const Value.absent(),
    this.mealType = const Value.absent(),
    this.pantryItemId = const Value.absent(),
    this.grams = const Value.absent(),
    this.loggedAt = const Value.absent(),
  });
  ConsumptionEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double kcal,
    required String mealType,
    this.pantryItemId = const Value.absent(),
    this.grams = const Value.absent(),
    this.loggedAt = const Value.absent(),
  }) : name = Value(name),
       kcal = Value(kcal),
       mealType = Value(mealType);
  static Insertable<ConsumptionEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? kcal,
    Expression<String>? mealType,
    Expression<int>? pantryItemId,
    Expression<double>? grams,
    Expression<DateTime>? loggedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kcal != null) 'kcal': kcal,
      if (mealType != null) 'meal_type': mealType,
      if (pantryItemId != null) 'pantry_item_id': pantryItemId,
      if (grams != null) 'grams': grams,
      if (loggedAt != null) 'logged_at': loggedAt,
    });
  }

  ConsumptionEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? kcal,
    Value<String>? mealType,
    Value<int?>? pantryItemId,
    Value<double?>? grams,
    Value<DateTime>? loggedAt,
  }) {
    return ConsumptionEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kcal: kcal ?? this.kcal,
      mealType: mealType ?? this.mealType,
      pantryItemId: pantryItemId ?? this.pantryItemId,
      grams: grams ?? this.grams,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (pantryItemId.present) {
      map['pantry_item_id'] = Variable<int>(pantryItemId.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsumptionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kcal: $kcal, ')
          ..write('mealType: $mealType, ')
          ..write('pantryItemId: $pantryItemId, ')
          ..write('grams: $grams, ')
          ..write('loggedAt: $loggedAt')
          ..write(')'))
        .toString();
  }
}

class $ShoppingItemsTable extends ShoppingItems
    with TableInfo<$ShoppingItemsTable, ShoppingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, note, done, source, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $ShoppingItemsTable createAlias(String alias) {
    return $ShoppingItemsTable(attachedDatabase, alias);
  }
}

class ShoppingItem extends DataClass implements Insertable<ShoppingItem> {
  final int id;
  final String name;

  /// Optional reason/note (filled by AI suggestions).
  final String? note;
  final bool done;

  /// manual | ai
  final String source;
  final DateTime addedAt;
  const ShoppingItem({
    required this.id,
    required this.name,
    this.note,
    required this.done,
    required this.source,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['done'] = Variable<bool>(done);
    map['source'] = Variable<String>(source);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  ShoppingItemsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingItemsCompanion(
      id: Value(id),
      name: Value(name),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      done: Value(done),
      source: Value(source),
      addedAt: Value(addedAt),
    );
  }

  factory ShoppingItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      note: serializer.fromJson<String?>(json['note']),
      done: serializer.fromJson<bool>(json['done']),
      source: serializer.fromJson<String>(json['source']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'note': serializer.toJson<String?>(note),
      'done': serializer.toJson<bool>(done),
      'source': serializer.toJson<String>(source),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  ShoppingItem copyWith({
    int? id,
    String? name,
    Value<String?> note = const Value.absent(),
    bool? done,
    String? source,
    DateTime? addedAt,
  }) => ShoppingItem(
    id: id ?? this.id,
    name: name ?? this.name,
    note: note.present ? note.value : this.note,
    done: done ?? this.done,
    source: source ?? this.source,
    addedAt: addedAt ?? this.addedAt,
  );
  ShoppingItem copyWithCompanion(ShoppingItemsCompanion data) {
    return ShoppingItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
      done: data.done.present ? data.done.value : this.done,
      source: data.source.present ? data.source.value : this.source,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('done: $done, ')
          ..write('source: $source, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, note, done, source, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.note == this.note &&
          other.done == this.done &&
          other.source == this.source &&
          other.addedAt == this.addedAt);
}

class ShoppingItemsCompanion extends UpdateCompanion<ShoppingItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> note;
  final Value<bool> done;
  final Value<String> source;
  final Value<DateTime> addedAt;
  const ShoppingItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.done = const Value.absent(),
    this.source = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  ShoppingItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.note = const Value.absent(),
    this.done = const Value.absent(),
    this.source = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ShoppingItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? note,
    Expression<bool>? done,
    Expression<String>? source,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (done != null) 'done': done,
      if (source != null) 'source': source,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  ShoppingItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? note,
    Value<bool>? done,
    Value<String>? source,
    Value<DateTime>? addedAt,
  }) {
    return ShoppingItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      done: done ?? this.done,
      source: source ?? this.source,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('done: $done, ')
          ..write('source: $source, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $ArticlesTable extends Articles with TableInfo<$ArticlesTable, Article> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, url, title, summary, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Article> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Article map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Article(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ArticlesTable createAlias(String alias) {
    return $ArticlesTable(attachedDatabase, alias);
  }
}

class Article extends DataClass implements Insertable<Article> {
  final int id;
  final String url;
  final String title;
  final String summary;
  final DateTime createdAt;
  const Article({
    required this.id,
    required this.url,
    required this.title,
    required this.summary,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['summary'] = Variable<String>(summary);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ArticlesCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      summary: Value(summary),
      createdAt: Value(createdAt),
    );
  }

  factory Article.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Article(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String>(summary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Article copyWith({
    int? id,
    String? url,
    String? title,
    String? summary,
    DateTime? createdAt,
  }) => Article(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title ?? this.title,
    summary: summary ?? this.summary,
    createdAt: createdAt ?? this.createdAt,
  );
  Article copyWithCompanion(ArticlesCompanion data) {
    return Article(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Article(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url, title, summary, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Article &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.createdAt == this.createdAt);
}

class ArticlesCompanion extends UpdateCompanion<Article> {
  final Value<int> id;
  final Value<String> url;
  final Value<String> title;
  final Value<String> summary;
  final Value<DateTime> createdAt;
  const ArticlesCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ArticlesCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    required String title,
    required String summary,
    this.createdAt = const Value.absent(),
  }) : url = Value(url),
       title = Value(title),
       summary = Value(summary);
  static Insertable<Article> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ArticlesCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<String>? title,
    Value<String>? summary,
    Value<DateTime>? createdAt,
  }) {
    return ArticlesCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PantryItemsTable pantryItems = $PantryItemsTable(this);
  late final $ConsumptionEntriesTable consumptionEntries =
      $ConsumptionEntriesTable(this);
  late final $ShoppingItemsTable shoppingItems = $ShoppingItemsTable(this);
  late final $ArticlesTable articles = $ArticlesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pantryItems,
    consumptionEntries,
    shoppingItems,
    articles,
  ];
}

typedef $$PantryItemsTableCreateCompanionBuilder =
    PantryItemsCompanion Function({
      Value<int> id,
      Value<String?> barcode,
      required String name,
      Value<String?> brand,
      Value<String?> imageUrl,
      Value<double?> kcalPer100g,
      Value<double?> proteinsPer100g,
      Value<double?> carbsPer100g,
      Value<double?> sugarsPer100g,
      Value<double?> fatsPer100g,
      Value<String?> packageQuantity,
      Value<int?> unitCount,
      Value<bool> perishable,
      Value<double> amountLeft,
      Value<DateTime> addedAt,
      Value<DateTime> updatedAt,
    });
typedef $$PantryItemsTableUpdateCompanionBuilder =
    PantryItemsCompanion Function({
      Value<int> id,
      Value<String?> barcode,
      Value<String> name,
      Value<String?> brand,
      Value<String?> imageUrl,
      Value<double?> kcalPer100g,
      Value<double?> proteinsPer100g,
      Value<double?> carbsPer100g,
      Value<double?> sugarsPer100g,
      Value<double?> fatsPer100g,
      Value<String?> packageQuantity,
      Value<int?> unitCount,
      Value<bool> perishable,
      Value<double> amountLeft,
      Value<DateTime> addedAt,
      Value<DateTime> updatedAt,
    });

class $$PantryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinsPer100g => $composableBuilder(
    column: $table.proteinsPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugarsPer100g => $composableBuilder(
    column: $table.sugarsPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatsPer100g => $composableBuilder(
    column: $table.fatsPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageQuantity => $composableBuilder(
    column: $table.packageQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCount => $composableBuilder(
    column: $table.unitCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get perishable => $composableBuilder(
    column: $table.perishable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountLeft => $composableBuilder(
    column: $table.amountLeft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PantryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinsPer100g => $composableBuilder(
    column: $table.proteinsPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugarsPer100g => $composableBuilder(
    column: $table.sugarsPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatsPer100g => $composableBuilder(
    column: $table.fatsPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageQuantity => $composableBuilder(
    column: $table.packageQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCount => $composableBuilder(
    column: $table.unitCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get perishable => $composableBuilder(
    column: $table.perishable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountLeft => $composableBuilder(
    column: $table.amountLeft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PantryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinsPer100g => $composableBuilder(
    column: $table.proteinsPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sugarsPer100g => $composableBuilder(
    column: $table.sugarsPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatsPer100g => $composableBuilder(
    column: $table.fatsPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageQuantity => $composableBuilder(
    column: $table.packageQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCount =>
      $composableBuilder(column: $table.unitCount, builder: (column) => column);

  GeneratedColumn<bool> get perishable => $composableBuilder(
    column: $table.perishable,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountLeft => $composableBuilder(
    column: $table.amountLeft,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PantryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PantryItemsTable,
          PantryItem,
          $$PantryItemsTableFilterComposer,
          $$PantryItemsTableOrderingComposer,
          $$PantryItemsTableAnnotationComposer,
          $$PantryItemsTableCreateCompanionBuilder,
          $$PantryItemsTableUpdateCompanionBuilder,
          (
            PantryItem,
            BaseReferences<_$AppDatabase, $PantryItemsTable, PantryItem>,
          ),
          PantryItem,
          PrefetchHooks Function()
        > {
  $$PantryItemsTableTableManager(_$AppDatabase db, $PantryItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PantryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PantryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PantryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<double?> kcalPer100g = const Value.absent(),
                Value<double?> proteinsPer100g = const Value.absent(),
                Value<double?> carbsPer100g = const Value.absent(),
                Value<double?> sugarsPer100g = const Value.absent(),
                Value<double?> fatsPer100g = const Value.absent(),
                Value<String?> packageQuantity = const Value.absent(),
                Value<int?> unitCount = const Value.absent(),
                Value<bool> perishable = const Value.absent(),
                Value<double> amountLeft = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PantryItemsCompanion(
                id: id,
                barcode: barcode,
                name: name,
                brand: brand,
                imageUrl: imageUrl,
                kcalPer100g: kcalPer100g,
                proteinsPer100g: proteinsPer100g,
                carbsPer100g: carbsPer100g,
                sugarsPer100g: sugarsPer100g,
                fatsPer100g: fatsPer100g,
                packageQuantity: packageQuantity,
                unitCount: unitCount,
                perishable: perishable,
                amountLeft: amountLeft,
                addedAt: addedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<double?> kcalPer100g = const Value.absent(),
                Value<double?> proteinsPer100g = const Value.absent(),
                Value<double?> carbsPer100g = const Value.absent(),
                Value<double?> sugarsPer100g = const Value.absent(),
                Value<double?> fatsPer100g = const Value.absent(),
                Value<String?> packageQuantity = const Value.absent(),
                Value<int?> unitCount = const Value.absent(),
                Value<bool> perishable = const Value.absent(),
                Value<double> amountLeft = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PantryItemsCompanion.insert(
                id: id,
                barcode: barcode,
                name: name,
                brand: brand,
                imageUrl: imageUrl,
                kcalPer100g: kcalPer100g,
                proteinsPer100g: proteinsPer100g,
                carbsPer100g: carbsPer100g,
                sugarsPer100g: sugarsPer100g,
                fatsPer100g: fatsPer100g,
                packageQuantity: packageQuantity,
                unitCount: unitCount,
                perishable: perishable,
                amountLeft: amountLeft,
                addedAt: addedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PantryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PantryItemsTable,
      PantryItem,
      $$PantryItemsTableFilterComposer,
      $$PantryItemsTableOrderingComposer,
      $$PantryItemsTableAnnotationComposer,
      $$PantryItemsTableCreateCompanionBuilder,
      $$PantryItemsTableUpdateCompanionBuilder,
      (
        PantryItem,
        BaseReferences<_$AppDatabase, $PantryItemsTable, PantryItem>,
      ),
      PantryItem,
      PrefetchHooks Function()
    >;
typedef $$ConsumptionEntriesTableCreateCompanionBuilder =
    ConsumptionEntriesCompanion Function({
      Value<int> id,
      required String name,
      required double kcal,
      required String mealType,
      Value<int?> pantryItemId,
      Value<double?> grams,
      Value<DateTime> loggedAt,
    });
typedef $$ConsumptionEntriesTableUpdateCompanionBuilder =
    ConsumptionEntriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> kcal,
      Value<String> mealType,
      Value<int?> pantryItemId,
      Value<double?> grams,
      Value<DateTime> loggedAt,
    });

class $$ConsumptionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ConsumptionEntriesTable> {
  $$ConsumptionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pantryItemId => $composableBuilder(
    column: $table.pantryItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConsumptionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsumptionEntriesTable> {
  $$ConsumptionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pantryItemId => $composableBuilder(
    column: $table.pantryItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConsumptionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsumptionEntriesTable> {
  $$ConsumptionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<int> get pantryItemId => $composableBuilder(
    column: $table.pantryItemId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);
}

class $$ConsumptionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsumptionEntriesTable,
          ConsumptionEntry,
          $$ConsumptionEntriesTableFilterComposer,
          $$ConsumptionEntriesTableOrderingComposer,
          $$ConsumptionEntriesTableAnnotationComposer,
          $$ConsumptionEntriesTableCreateCompanionBuilder,
          $$ConsumptionEntriesTableUpdateCompanionBuilder,
          (
            ConsumptionEntry,
            BaseReferences<
              _$AppDatabase,
              $ConsumptionEntriesTable,
              ConsumptionEntry
            >,
          ),
          ConsumptionEntry,
          PrefetchHooks Function()
        > {
  $$ConsumptionEntriesTableTableManager(
    _$AppDatabase db,
    $ConsumptionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsumptionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsumptionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsumptionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<int?> pantryItemId = const Value.absent(),
                Value<double?> grams = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
              }) => ConsumptionEntriesCompanion(
                id: id,
                name: name,
                kcal: kcal,
                mealType: mealType,
                pantryItemId: pantryItemId,
                grams: grams,
                loggedAt: loggedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double kcal,
                required String mealType,
                Value<int?> pantryItemId = const Value.absent(),
                Value<double?> grams = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
              }) => ConsumptionEntriesCompanion.insert(
                id: id,
                name: name,
                kcal: kcal,
                mealType: mealType,
                pantryItemId: pantryItemId,
                grams: grams,
                loggedAt: loggedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConsumptionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsumptionEntriesTable,
      ConsumptionEntry,
      $$ConsumptionEntriesTableFilterComposer,
      $$ConsumptionEntriesTableOrderingComposer,
      $$ConsumptionEntriesTableAnnotationComposer,
      $$ConsumptionEntriesTableCreateCompanionBuilder,
      $$ConsumptionEntriesTableUpdateCompanionBuilder,
      (
        ConsumptionEntry,
        BaseReferences<
          _$AppDatabase,
          $ConsumptionEntriesTable,
          ConsumptionEntry
        >,
      ),
      ConsumptionEntry,
      PrefetchHooks Function()
    >;
typedef $$ShoppingItemsTableCreateCompanionBuilder =
    ShoppingItemsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> note,
      Value<bool> done,
      Value<String> source,
      Value<DateTime> addedAt,
    });
typedef $$ShoppingItemsTableUpdateCompanionBuilder =
    ShoppingItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> note,
      Value<bool> done,
      Value<String> source,
      Value<DateTime> addedAt,
    });

class $$ShoppingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShoppingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShoppingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$ShoppingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoppingItemsTable,
          ShoppingItem,
          $$ShoppingItemsTableFilterComposer,
          $$ShoppingItemsTableOrderingComposer,
          $$ShoppingItemsTableAnnotationComposer,
          $$ShoppingItemsTableCreateCompanionBuilder,
          $$ShoppingItemsTableUpdateCompanionBuilder,
          (
            ShoppingItem,
            BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItem>,
          ),
          ShoppingItem,
          PrefetchHooks Function()
        > {
  $$ShoppingItemsTableTableManager(_$AppDatabase db, $ShoppingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => ShoppingItemsCompanion(
                id: id,
                name: name,
                note: note,
                done: done,
                source: source,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> note = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => ShoppingItemsCompanion.insert(
                id: id,
                name: name,
                note: note,
                done: done,
                source: source,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShoppingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoppingItemsTable,
      ShoppingItem,
      $$ShoppingItemsTableFilterComposer,
      $$ShoppingItemsTableOrderingComposer,
      $$ShoppingItemsTableAnnotationComposer,
      $$ShoppingItemsTableCreateCompanionBuilder,
      $$ShoppingItemsTableUpdateCompanionBuilder,
      (
        ShoppingItem,
        BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItem>,
      ),
      ShoppingItem,
      PrefetchHooks Function()
    >;
typedef $$ArticlesTableCreateCompanionBuilder =
    ArticlesCompanion Function({
      Value<int> id,
      required String url,
      required String title,
      required String summary,
      Value<DateTime> createdAt,
    });
typedef $$ArticlesTableUpdateCompanionBuilder =
    ArticlesCompanion Function({
      Value<int> id,
      Value<String> url,
      Value<String> title,
      Value<String> summary,
      Value<DateTime> createdAt,
    });

class $$ArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesTable,
          Article,
          $$ArticlesTableFilterComposer,
          $$ArticlesTableOrderingComposer,
          $$ArticlesTableAnnotationComposer,
          $$ArticlesTableCreateCompanionBuilder,
          $$ArticlesTableUpdateCompanionBuilder,
          (Article, BaseReferences<_$AppDatabase, $ArticlesTable, Article>),
          Article,
          PrefetchHooks Function()
        > {
  $$ArticlesTableTableManager(_$AppDatabase db, $ArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ArticlesCompanion(
                id: id,
                url: url,
                title: title,
                summary: summary,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                required String title,
                required String summary,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ArticlesCompanion.insert(
                id: id,
                url: url,
                title: title,
                summary: summary,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesTable,
      Article,
      $$ArticlesTableFilterComposer,
      $$ArticlesTableOrderingComposer,
      $$ArticlesTableAnnotationComposer,
      $$ArticlesTableCreateCompanionBuilder,
      $$ArticlesTableUpdateCompanionBuilder,
      (Article, BaseReferences<_$AppDatabase, $ArticlesTable, Article>),
      Article,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PantryItemsTableTableManager get pantryItems =>
      $$PantryItemsTableTableManager(_db, _db.pantryItems);
  $$ConsumptionEntriesTableTableManager get consumptionEntries =>
      $$ConsumptionEntriesTableTableManager(_db, _db.consumptionEntries);
  $$ShoppingItemsTableTableManager get shoppingItems =>
      $$ShoppingItemsTableTableManager(_db, _db.shoppingItems);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db, _db.articles);
}
