import 'package:flutter/material.dart';

class BankCard {
  final String id;
  final String name;
  final Color color;
  final String? last4digits;

  BankCard({
    required this.id,
    required this.name,
    required this.color,
    this.last4digits,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.toARGB32(),
      'last4digits': last4digits,
    };
  }

  factory BankCard.fromMap(Map<String, dynamic> map) {
    return BankCard(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
      last4digits: map['last4digits'],
    );
  }
}
