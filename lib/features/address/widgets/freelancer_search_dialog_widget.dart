import 'package:flutter/material.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class FreelancerSearchDialogWidget extends StatefulWidget {
  final GoogleMapController? mapController;
  final EdgeInsets? margin;
  final Future<void> Function()? onResultsUpdated;
  final ValueChanged<String>? onQueryApplied;
  final List<String>? suggestionPool;
  final String? initialQuery;
  const FreelancerSearchDialogWidget(
      {super.key,
      required this.mapController,
      this.margin,
      this.onResultsUpdated,
      this.onQueryApplied,
      this.suggestionPool,
      this.initialQuery});

  @override
  State<FreelancerSearchDialogWidget> createState() =>
      _FreelancerSearchDialogWidgetState();
}

class _FreelancerSearchDialogWidgetState
    extends State<FreelancerSearchDialogWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<String> _querySuggestions = [];
  List<String> _searchVocabulary = [];

  @override
  void initState() {
    super.initState();
    _searchVocabulary = (widget.suggestionPool ?? [])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    final initialQuery = widget.initialQuery?.trim() ?? '';
    if (initialQuery.isNotEmpty) {
      _searchController.text = initialQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: initialQuery.length),
      );
      _buildSuggestions(initialQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final List<int> previous =
        List<int>.generate(b.length + 1, (index) => index);
    final List<int> current = List<int>.filled(b.length + 1, 0);

    for (int i = 1; i <= a.length; i++) {
      current[0] = i;
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        current[j] = [
          previous[j] + 1,
          current[j - 1] + 1,
          previous[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      for (int j = 0; j <= b.length; j++) {
        previous[j] = current[j];
      }
    }

    return previous[b.length];
  }

  int _allowedDistanceByLength(int length) {
    if (length <= 4) return 1;
    if (length <= 8) return 2;
    return 3;
  }

  void _buildSuggestions(String rawText) {
    final query = rawText.trim();
    if (query.isEmpty) {
      if (_querySuggestions.isNotEmpty && mounted) {
        setState(() {
          _querySuggestions = [];
        });
      }
      return;
    }

    final Set<String> suggestions = <String>{query};
    final normalizedQuery = query.toLowerCase();

    for (final candidate in _searchVocabulary) {
      final normalizedCandidate = candidate.toLowerCase();
      if (normalizedCandidate.contains(normalizedQuery) ||
          normalizedCandidate.startsWith(normalizedQuery)) {
        suggestions.add(candidate);
      } else {
        final distance = _levenshteinDistance(normalizedQuery, normalizedCandidate);
        if (distance <= _allowedDistanceByLength(normalizedQuery.length)) {
          suggestions.add(candidate);
        }
      }
    }

    final updated = suggestions.take(6).toList();
    if (mounted) {
      setState(() {
        _querySuggestions = updated;
      });
    }
  }

  Future<void> _applySearch(FreelancerProvider provider) async {
    final query = _searchController.text.trim();
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    if (query.isEmpty) {
      await provider.getFreelancerList();
    } else {
      final List<FreelancerModel> results =
          await provider.searchFreelancer(context, query);
      provider.updateFreelancerList(results);
    }

    widget.onQueryApplied?.call(query);

    final freelancers = provider.freelancerList ?? [];
    if (freelancers.isNotEmpty && widget.mapController != null) {
      final first = freelancers.first;
      final latitude = double.tryParse(first.latitude.toString());
      final longitude = double.tryParse(first.longitude.toString());
      if (latitude != null && longitude != null) {
        await widget.mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 13),
        );
      }
    }

    if (widget.onResultsUpdated != null) {
      await widget.onResultsUpdated!.call();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final FreelancerProvider freelancerProvider =
        Provider.of<FreelancerProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      margin: widget.margin ??
          const EdgeInsets.only(
            top: 75,
            right: Dimensions.paddingSizeSmall,
            left: Dimensions.paddingSizeSmall,
          ),
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 650,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
              },
              behavior: HitTestBehavior.opaque,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                      hintText: getTranslated('search_freelancer', context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(style: BorderStyle.none, width: 0),
                      ),
                      hintStyle:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).disabledColor,
                              ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      suffixIcon: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall,
                              ),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: () async {
                                await _applySearch(freelancerProvider);
                                if (!mounted) return;
                                Navigator.of(this.context).pop();
                              },
                              icon: const Icon(Icons.search),
                            ),
                    ),
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                    onChanged: (value) {
                      _buildSuggestions(value);
                    },
                    onSubmitted: (_) async {
                      await _applySearch(freelancerProvider);
                      if (!mounted) return;
                      Navigator.of(this.context).pop();
                    },
                  ),
                ),
              ),
            ),
            if (_querySuggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeSmall,
                ),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _querySuggestions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    itemBuilder: (context, index) {
                      final suggestion = _querySuggestions[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.search,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          suggestion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          _searchController.text = suggestion;
                          _searchController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: suggestion.length),
                          );
                          await _applySearch(freelancerProvider);
                          if (!mounted) return;
                          Navigator.of(this.context).pop();
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
