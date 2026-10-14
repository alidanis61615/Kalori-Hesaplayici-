import 'package:flutter/material.dart';

import '../../controllers/nutrition_controller.dart';
import '../../controllers/nutrition_actions.dart';
import '../../widgets/nutrition_widgets.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.data, required this.actions});
  final NutritionController data;
  final NutritionActions actions;
  @override
  Widget build(BuildContext context) {
    final target = data.target;
    final pt = data.pt;
    final ct = data.ct;
    final ft = data.ft;
    final waterGoal = data.waterGoal;
    return ListView(
      key: const PageStorageKey('profile_tab'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (data.error != null)
          NutritionCard(
            Text(data.error!, style: const TextStyle(color: Colors.red)),
          ),

        NutritionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Beslenme hedeflerin',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                '${target.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Protein ${pt.toStringAsFixed(0)} g'),
              Text('Karbonhidrat ${ct.toStringAsFixed(0)} g'),
              Text('Yağ ${ft.toStringAsFixed(0)} g'),
              Text('Su hedefi ${waterGoal.toStringAsFixed(0)} ml'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: actions.editGoals,
                icon: const Icon(Icons.edit),
                label: const Text('Hedefleri düzenle'),
              ),
            ],
          ),
        ),
        NutritionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Veri yedeği',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Besin, su, hedef, favori ve kilo kayıtlarını JSON biçiminde panoya kopyala. Metni güvenli bir dosyaya kaydet.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Yedeği panoya kopyala'),
                onPressed: actions.exportBackup,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Panodaki yedeği geri yükle'),
                onPressed: actions.restoreBackup,
              ),
              const Text(
                'Geri yükleme mevcut tüm kayıtların yerini alır. Önce mevcut yedeğini al. Pano içeriği başka uygulamalar tarafından okunabilir.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        NutritionCard(
          const Text(
            'Verilerin cihazındaki SQLite veritabanında saklanır. Bulut senkronizasyonu, fotoğraftan besin analizi ve sağlık uygulaması bağlantısı bu sürümde yok.',
          ),
        ),
      ],
    );
  }
}
