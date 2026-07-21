import 'package:flutter/material.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';

class BookingPriceTabsWidget extends StatefulWidget {
  final String? pricePerDay;
  final String? pricePerHour;
  final String? pricePerKm;
  final double distanceKm;
  final TextEditingController priceController;
  final Function(String) onPriceSelected;

  const BookingPriceTabsWidget({
    super.key,
    required this.pricePerDay,
    required this.pricePerHour,
    required this.pricePerKm,
    required this.distanceKm,
    required this.priceController,
    required this.onPriceSelected,
  });

  @override
  State<BookingPriceTabsWidget> createState() => _BookingPriceTabsWidgetState();
}

class _BookingPriceTabsWidgetState extends State<BookingPriceTabsWidget> {
  int? _selectedTabIndex;

  double _parseAmount(String? value) {
    return double.tryParse(value ?? '') ?? 0;
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _getPriceForIndex(int index) {
    switch (index) {
      case 0:
        return _formatAmount(_parseAmount(widget.pricePerDay));
      case 1:
        return _formatAmount(_parseAmount(widget.pricePerHour));
      case 2:
        return _formatAmount(
          _parseAmount(widget.pricePerKm) * widget.distanceKm,
        );
      default:
        return '0';
    }
  }

  void _selectPrice(String price, int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    widget.priceController.text = price;
    widget.onPriceSelected(price);
  }

  @override
  void didUpdateWidget(covariant BookingPriceTabsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedTabIndex != null) {
      final updatedPrice = _getPriceForIndex(_selectedTabIndex!);
      if (widget.priceController.text != updatedPrice) {
        widget.priceController.text = updatedPrice;
        widget.onPriceSelected(updatedPrice);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceOptions = [
      {
        'label': 'Per Day',
        'price': widget.pricePerDay,
      },
      {
        'label': 'Per Hour',
        'price': widget.pricePerHour,
      },
      {
        'label': 'Per KM',
        'price': widget.pricePerKm,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Price',
          style: rubikSemiBold.copyWith(
            color: ColorResources.getGreyBunkerColor(context),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: priceOptions.length,
            itemBuilder: (context, index) {
              final option = priceOptions[index];
              final price = index == 2
                  ? _getPriceForIndex(index)
                  : _formatAmount(_parseAmount(option['price']?.toString()));
              final isSelected = _selectedTabIndex == index;

              return Padding(
                padding:
                    const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: GestureDetector(
                  onTap: () => _selectPrice(price, index),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1)
                          : Theme.of(context).cardColor,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context)
                                .hintColor
                                .withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option['label'] as String,
                          style: rubikRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(
                          price,
                          style: rubikBold.copyWith(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text(
          'Suggestion Price',
          style: rubikSemiBold.copyWith(
            color: ColorResources.getGreyBunkerColor(context),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        TextField(
          controller: widget.priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter your price',
            hintStyle: rubikRegular.copyWith(
              color: Theme.of(context).hintColor,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              borderSide: BorderSide(
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              borderSide: BorderSide(
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
          ),
          style: rubikRegular,
        ),
      ],
    );
  }
}
