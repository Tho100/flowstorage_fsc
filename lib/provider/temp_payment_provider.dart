import 'package:flutter/material.dart';

class TempPaymentProvider extends ChangeNotifier {
  
  String _countryCode = '';
  String _countryCurrency = '';
  double _currencyConversionRate = 0.0;

  String get countryCode => _countryCode;
  String get countryCurrency => _countryCurrency;
  double get currencyConversionRate => _currencyConversionRate;

  void setCurrencyConversion(double value) {
    _currencyConversionRate = value;
    notifyListeners();
  }

  void setCountryCurrency(String value) {
    _countryCurrency = value;
    notifyListeners();
  }

  void setCountryCode(String value) {
    _countryCode = value;
    notifyListeners();
  }

}