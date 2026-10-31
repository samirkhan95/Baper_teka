import 'package:flutter/material.dart';
import '../models/app_transaction.dart';

class TransactionHelper {
  /// Smart detection of transaction category name based on note/title
  static String getCategoryName(AppTransaction tx) {
    if (tx.type == TransactionType.cashIn) return 'Cash In / Withdrawal';
    if (tx.type == TransactionType.income) return 'From Father';

    final note = (tx.note ?? '').toLowerCase().trim();

    if (note.contains('gas') || note.contains('fuel') || note.contains('petrol') || note.contains('octane') ||
        note.contains('bus') || note.contains('rickshaw') || note.contains('auto') || note.contains('uber') ||
        note.contains('pathao') || note.contains('indrive') || note.contains('bike') || note.contains('car') ||
        note.contains('gaari') || note.contains('gari') || note.contains('train') || note.contains('metro') ||
        note.contains('ticket') || note.contains('transport') || note.contains('travel') || note.contains('cab') || note.contains('taxi')) {
      return 'Transport';
    }

    if (note.contains('router') || note.contains('wifi') || note.contains('internet') || note.contains('broadband') ||
        note.contains('net') || note.contains('bill') || note.contains('electric') || note.contains('current') ||
        note.contains('power') || note.contains('water') || note.contains('pani') || note.contains('recharge') ||
        note.contains('flexiload') || note.contains('mobile') || note.contains('phone')) {
      return 'Bills & Utilities';
    }

    if (note.contains('kola') || note.contains('banana') || note.contains('dim') || note.contains('egg') ||
        note.contains('dudh') || note.contains('dud') || note.contains('milk') ||
        note.contains('nasta') || note.contains('nashta') || note.contains('food') || note.contains('eat') ||
        note.contains('lunch') || note.contains('dinner') || note.contains('breakfast') || note.contains('snack') ||
        note.contains('tea') || note.contains('coffee') || note.contains('cha') || note.contains('cafe') ||
        note.contains('resturant') || note.contains('restaurant') || note.contains('hotel') || note.contains('kfc') ||
        note.contains('burger') || note.contains('pizza') || note.contains('biryani') || note.contains('kacchi') ||
        note.contains('rice') || note.contains('dal') || note.contains('meat') || note.contains('fish') ||
        note.contains('chicken') || note.contains('beef') || note.contains('mutton') || note.contains('sweet') ||
        note.contains('bakery') || note.contains('singara') || note.contains('samosa') || note.contains('dosa') ||
        note.contains('fuchka') || note.contains('chotpoti') || note.contains('porota') || note.contains('ruti') ||
        note.contains('roti') || note.contains('grill') || note.contains('kabab') || note.contains('muri')) {
      return 'Food & Restaurants';
    }

    if (note.contains('bazar') || note.contains('bazaar') || note.contains('grocery') || note.contains('groceries') ||
        note.contains('kachabazar') || note.contains('shop') || note.contains('cloth') || note.contains('dress') ||
        note.contains('shirt') || note.contains('jama') || note.contains('kapor') || note.contains('juta') ||
        note.contains('pant') || note.contains('daraz')) {
      return 'Shopping';
    }

    if (note.contains('med') || note.contains('doctor') || note.contains('health') || note.contains('hospital') ||
        note.contains('pharma') || note.contains('clinic') || note.contains('medicine') || note.contains('osudh') ||
        note.contains('oushodh') || note.contains('aushadh') || note.contains('daktar')) {
      return 'Medicine & Health';
    }

    return 'Others';
  }

  /// Smart detection of transaction icon based on type, note/title, and category
  static IconData getIcon(AppTransaction tx) {
    if (tx.type == TransactionType.cashIn) {
      return Icons.payments; // Money sign for withdrawal / Cash In
    }
    if (tx.type == TransactionType.income) {
      return Icons.volunteer_activism; // Money received / Income sign
    }

    final note = (tx.note ?? '').toLowerCase().trim();

    // 1. Transport / Commute / Banglish Fare (cng fare, vara, bhara, rickshaw, bus, etc.)
    if (note.contains('cng') || note.contains('fare') || note.contains('vara') || note.contains('bhara') ||
        note.contains('bhar') || note.contains('bus') || note.contains('rickshaw') || note.contains('auto') ||
        note.contains('uber') || note.contains('pathao') || note.contains('indrive') || note.contains('bike') ||
        note.contains('car') || note.contains('gaari') || note.contains('gari') || note.contains('train') ||
        note.contains('metro') || note.contains('ticket') || note.contains('transport') || note.contains('travel') ||
        note.contains('cab') || note.contains('taxi')) {
      return Icons.directions_bus;
    }

    // 2. Specific Items: Egg (Dim)
    if (note.contains('dim') || note.contains('egg')) {
      return Icons.egg_alt;
    }

    // 3. Specific Items: Milk (Dudh / Dud)
    if (note.contains('dudh') || note.contains('dud') || note.contains('milk')) {
      return Icons.local_drink;
    }

    // 4. Specific Items: Banana / Fruits (Kola)
    if (note.contains('kola') || note.contains('banana')) {
      return Icons.breakfast_dining;
    }

    // 5. Specific Items: Cooking Oil / Fuel (Tel)
    if (note == 'tel' || note.contains('tel ') || note.contains('oil') || note.contains('sorsher tel')) {
      if (note.contains('gas') || note.contains('fuel') || note.contains('petrol') || note.contains('octane') || note.contains('mobic')) {
        return Icons.local_gas_station;
      }
      return Icons.opacity;
    }

    // 6. Grocery / Bazar / Daily Shopping (bazar, kachabazar, grocery, etc.)
    if (note.contains('bazar') || note.contains('bazaar') || note.contains('grocery') || note.contains('groceries') ||
        note.contains('kachabazar') || note.contains('market') || note.contains('supermarket')) {
      return Icons.shopping_cart;
    }

    // 7. Gas / Fuel / Petrol / Octane / Mobic
    if (note.contains('gas') || note.contains('fuel') || note.contains('petrol') || note.contains('octane') ||
        note.contains('mobic')) {
      return Icons.local_gas_station;
    }

    // 8. Router / Wifi / Internet
    if (note.contains('router') || note.contains('wifi') || note.contains('internet') || note.contains('broadband') ||
        note.contains('net bill') || note.contains('net')) {
      return Icons.wifi;
    }

    // 9. Food / Banglish Snacks / Meals / Ingredients
    if (note.contains('nasta') || note.contains('nashta') || note.contains('food') || note.contains('eat') ||
        note.contains('lunch') || note.contains('dinner') || note.contains('breakfast') || note.contains('snack') ||
        note.contains('tea') || note.contains('coffee') || note.contains('cha') || note.contains('cafe') ||
        note.contains('resturant') || note.contains('restaurant') || note.contains('hotel') || note.contains('kfc') ||
        note.contains('burger') || note.contains('pizza') || note.contains('biryani') || note.contains('kacchi') ||
        note.contains('rice') || note.contains('chal') || note.contains('dal') || note.contains('meat') ||
        note.contains('fish') || note.contains('mach') || note.contains('maach') || note.contains('mangsho') ||
        note.contains('chicken') || note.contains('beef') || note.contains('mutton') || note.contains('sweet') ||
        note.contains('bakery') || note.contains('singara') || note.contains('samosa') || note.contains('dosa') ||
        note.contains('fuchka') || note.contains('chotpoti') || note.contains('porota') || note.contains('ruti') ||
        note.contains('roti') || note.contains('grill') || note.contains('kabab') || note.contains('muri')) {
      return Icons.restaurant;
    }

    // 10. Mobile recharge / Phone
    if (note.contains('recharge') || note.contains('flexiload') || note.contains('mobile') || note.contains('phone')) {
      return Icons.phone_android;
    }

    // 11. Bills / Utility / Electricity
    if (note.contains('bill') || note.contains('electric') || note.contains('current') || note.contains('power') ||
        note.contains('water') || note.contains('pani') || note.contains('bijli') || note.contains('biddut')) {
      return Icons.receipt_long;
    }

    // 12. Medicine / Doctor / Health
    if (note.contains('med') || note.contains('doctor') || note.contains('health') || note.contains('hospital') ||
        note.contains('pharma') || note.contains('clinic') || note.contains('medicine') || note.contains('osudh') ||
        note.contains('oushodh') || note.contains('aushadh') || note.contains('daktar')) {
      return Icons.medication;
    }

    // 13. Shopping / Clothes / Jama / Juta
    if (note.contains('shop') || note.contains('cloth') || note.contains('dress') || note.contains('shirt') ||
        note.contains('jama') || note.contains('kapor') || note.contains('juta') || note.contains('pant') ||
        note.contains('daraz')) {
      return Icons.shopping_bag;
    }

    // 14. Rent / House / Basa Vara
    if (note.contains('rent') || note.contains('house') || note.contains('home') || note.contains('flat') ||
        note.contains('room') || note.contains('basa') || note.contains('basha')) {
      return Icons.home;
    }

    // 15. Movie / Cinema / Fun
    if (note.contains('movie') || note.contains('cinema') || note.contains('game') || note.contains('netflix')) {
      return Icons.movie;
    }

    // Category fallback
    if (tx.category != null) {
      switch (tx.category!) {
        case ExpenseCategory.food: return Icons.restaurant;
        case ExpenseCategory.transport: return Icons.directions_bus;
        case ExpenseCategory.shopping: return Icons.shopping_bag;
        case ExpenseCategory.bills: return Icons.receipt_long;
        default: return Icons.more_horiz;
      }
    }

    return Icons.shopping_bag_outlined;
  }
}
