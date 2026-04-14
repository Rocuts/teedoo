import 'package:flutter/material.dart';

/// Datos mutables de una línea de factura en el wizard.
class InvoiceLineData {
  late final TextEditingController descriptionController;
  late final TextEditingController quantityController;
  late final TextEditingController unitPriceController;
  late final TextEditingController taxRateController;

  String description;
  String quantity;
  String unitPrice;
  String taxRate;

  InvoiceLineData({
    this.description = '',
    this.quantity = '',
    this.unitPrice = '',
    this.taxRate = '21',
  }) {
    descriptionController = TextEditingController(text: description)
      ..addListener(() => description = descriptionController.text);
    quantityController = TextEditingController(text: quantity)
      ..addListener(() => quantity = quantityController.text);
    unitPriceController = TextEditingController(text: unitPrice)
      ..addListener(() => unitPrice = unitPriceController.text);
    taxRateController = TextEditingController(text: taxRate)
      ..addListener(() => taxRate = taxRateController.text);
  }

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    taxRateController.dispose();
  }
}
