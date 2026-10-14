import 'package:flutter/material.dart';

import '../data/food_catalog.dart';

class CatalogSheet extends StatefulWidget {
  const CatalogSheet({super.key});
  @override
  State<CatalogSheet> createState() => _CatalogSheetState();
}

class _CatalogSheetState extends State<CatalogSheet> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final matches = sampleFoodCatalog.where(
      (food) => food.name.toLowerCase().contains(query.toLowerCase()),
    );
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 12,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hazır besin ara',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Besin değerleri yaklaşık örneklerdir (100 g). Ürüne ve pişirme şekline göre değişir.',
              ),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Muz, yumurta, pilav...',
                ),
                onChanged: (v) => setState(() => query = v),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: matches
                      .map(
                        (food) => ListTile(
                          title: Text(food.name),
                          subtitle: Text(
                            '${food.kcal.toStringAsFixed(0)} kcal / 100 g · P ${food.protein.toStringAsFixed(1)} g',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.pop(context, food),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
