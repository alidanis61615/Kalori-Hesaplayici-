import 'package:flutter/material.dart';
import 'nutrition_trends.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const CalorieApp()); }
const green = Color(0xFF006C62);
class Food {
  final int? id;
  final String name, meal, date;
  final double grams, kcal, protein, carbs, fat;
  Food({this.id, required this.name, required this.meal, required this.date, required this.grams, required this.kcal, required this.protein, required this.carbs, required this.fat});
  double get energy => grams * kcal / 100;
  double get p => grams * protein / 100;
  double get c => grams * carbs / 100;
  double get f => grams * fat / 100;
  Map<String,Object?> toMap() => {'name':name,'meal':meal,'created_at':date,'grams':grams,'kcal_per_100g':kcal,'protein':protein,'carbs':carbs,'fat':fat};
  factory Food.fromMap(Map<String,Object?> m) => Food(id:m['id'] as int,name:m['name'] as String,meal:m['meal'] as String,date:m['created_at'] as String,grams:(m['grams'] as num).toDouble(),kcal:(m['kcal_per_100g'] as num).toDouble(),protein:(m['protein'] as num).toDouble(),carbs:(m['carbs'] as num).toDouble(),fat:(m['fat'] as num).toDouble());
}
String day(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
class WeightRecord {
  final int id;
  final String date;
  final double kg;
  const WeightRecord({required this.id,required this.date,required this.kg});
}
class Store {
  static Database? _db;
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await openDatabase(p.join(await getDatabasesPath(),'calorie_tracker.db'),version:4,
      onCreate:(d,v) async {
        await d.execute('CREATE TABLE food_entries (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,grams REAL NOT NULL,kcal_per_100g REAL NOT NULL,created_at TEXT NOT NULL,meal TEXT NOT NULL DEFAULT "Diğer",protein REAL NOT NULL DEFAULT 0,carbs REAL NOT NULL DEFAULT 0,fat REAL NOT NULL DEFAULT 0)');
        await d.execute('CREATE TABLE water_entries (day TEXT PRIMARY KEY,ml INTEGER NOT NULL)');
        await d.execute('CREATE TABLE settings (key TEXT PRIMARY KEY,value TEXT NOT NULL)');
        await d.execute('CREATE TABLE favorites (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,grams REAL NOT NULL,kcal_per_100g REAL NOT NULL,protein REAL NOT NULL,carbs REAL NOT NULL,fat REAL NOT NULL)');
        await d.execute('CREATE TABLE weight_entries (id INTEGER PRIMARY KEY AUTOINCREMENT,day TEXT NOT NULL,kg REAL NOT NULL CHECK(kg>0))');
      },
      onUpgrade:(d,old,v) async { if(old<2) {
        for(final col in ['meal TEXT NOT NULL DEFAULT "Diğer"','protein REAL NOT NULL DEFAULT 0','carbs REAL NOT NULL DEFAULT 0','fat REAL NOT NULL DEFAULT 0']) { await d.execute('ALTER TABLE food_entries ADD COLUMN $col'); }
        await d.execute('CREATE TABLE water_entries (day TEXT PRIMARY KEY,ml INTEGER NOT NULL)');
        await d.execute('CREATE TABLE settings (key TEXT PRIMARY KEY,value TEXT NOT NULL)');
      } if(old<3){await d.execute('CREATE TABLE favorites (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,grams REAL NOT NULL,kcal_per_100g REAL NOT NULL,protein REAL NOT NULL,carbs REAL NOT NULL,fat REAL NOT NULL)');} if(old<4){await d.execute('CREATE TABLE weight_entries (id INTEGER PRIMARY KEY AUTOINCREMENT,day TEXT NOT NULL,kg REAL NOT NULL CHECK(kg>0))');}});
    return _db!;
  }
  static Future<List<WeightRecord>> weights() async {
    final rows=await (await db).query('weight_entries',orderBy:'day DESC,id DESC');
    return rows.map((r)=>WeightRecord(id:r['id'] as int,date:r['day'] as String,kg:(r['kg'] as num).toDouble())).toList();
  }
  static Future<void> addWeight(String date,double kg) async {
    if(!kg.isFinite || kg<=0 || kg>500)throw ArgumentError('Geçerli bir kilo girin');
    await (await db).insert('weight_entries',{'day':date,'kg':kg});
  }
  static Future<void> deleteWeight(int id) async {
    await (await db).delete('weight_entries',where:'id=?',whereArgs:[id]);
  }
  static Future<List<Food>> foods() async => (await (await db).query('food_entries',orderBy:'created_at DESC,id DESC')).map(Food.fromMap).toList();
  static Future<void> add(Food f) async { await (await db).insert('food_entries',f.toMap()); }
  static Future<List<Food>> favorites() async => (await (await db).query('favorites',orderBy:'name COLLATE NOCASE')).map((m)=>Food(id:m['id'] as int,name:m['name'] as String,meal:'Kahvaltı',date:'',grams:(m['grams'] as num).toDouble(),kcal:(m['kcal_per_100g'] as num).toDouble(),protein:(m['protein'] as num).toDouble(),carbs:(m['carbs'] as num).toDouble(),fat:(m['fat'] as num).toDouble())).toList();
  static Future<void> saveFavorite(Food f) async {await (await db).insert('favorites',{'name':f.name,'grams':f.grams,'kcal_per_100g':f.kcal,'protein':f.protein,'carbs':f.carbs,'fat':f.fat});}
  static Future<void> removeFavorite(int id) async {await (await db).delete('favorites',where:'id=?',whereArgs:[id]);}
  static Future<void> delete(int id) async { await (await db).delete('food_entries',where:'id=?',whereArgs:[id]); }
  static Future<void> update(Food f) async { if(f.id==null) throw ArgumentError('Missing food id'); await (await db).update('food_entries',f.toMap(),where:'id=?',whereArgs:[f.id]); }
  static Future<int> water(String date) async { final rows=await (await db).query('water_entries',where:'day=?',whereArgs:[date]); return rows.isEmpty?0:rows.first['ml'] as int; }
  static Future<void> addWater(String date,int ml) async { final total=await water(date)+ml; await (await db).insert('water_entries',{'day':date,'ml':total},conflictAlgorithm:ConflictAlgorithm.replace); }
  static Future<void> removeWater(String date,int ml) async { final total=((await water(date))-ml).clamp(0,1000000); await (await db).insert('water_entries',{'day':date,'ml':total},conflictAlgorithm:ConflictAlgorithm.replace); }
  static Future<String?> getSetting(String key) async { final rows=await (await db).query('settings',where:'key=?',whereArgs:[key]); return rows.isEmpty?null:rows.first['value'] as String; }
  static Future<void> setSetting(String key,String value) async { await (await db).insert('settings',{'key':key,'value':value},conflictAlgorithm:ConflictAlgorithm.replace); }
}
class CalorieApp extends StatelessWidget {
  const CalorieApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(title:'Kalori Hesaplayıcı',debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:const Color(0xFFF5F7F5),colorScheme:ColorScheme.fromSeed(seedColor:green)),home:const Home());
}
class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState()=>_HomeState(); }
class _HomeState extends State<Home> {
  List<Food> foods=[]; List<WeightRecord> weights=[]; DateTime selected=DateTime.now(); int tab=0,water=0,trendDays=30;
  double target=2200,pt=120,ct=260,ft=70; String filter='Tümü'; String? error;
  final meals=['Kahvaltı','Öğle','Akşam','Atıştırmalık','Diğer'];
  @override void initState(){super.initState();reload();}
  Future<void> reload() async {try {
    final f=await Store.foods(), w=await Store.water(day(selected)), weightRecords=await Store.weights();
    final settings=await Future.wait(['calories','protein','carbs','fat'].map(Store.getSetting));
    if(mounted)setState((){foods=f;weights=weightRecords;water=w;target=double.tryParse(settings[0]??'')??2200;pt=double.tryParse(settings[1]??'')??120;ct=double.tryParse(settings[2]??'')??260;ft=double.tryParse(settings[3]??'')??70;error=null;});
  }catch(e){if(mounted)setState(()=>error='Veriler yüklenemedi: $e');}}
  void fail(Object e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('İşlem başarısız: $e')));}
  Widget card(Widget child)=>Card(color:Colors.white,elevation:0,margin:const EdgeInsets.only(bottom:16),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(24),side:const BorderSide(color:Color(0xFFE0E5E2))),child:Padding(padding:const EdgeInsets.all(20),child:child));
  Widget meter(String title,double value,double goal,String unit)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title),Text('${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit'),const SizedBox(height:8),LinearProgressIndicator(value:goal>0?(value/goal).clamp(0.0,1.0):0,minHeight:8,borderRadius:BorderRadius.circular(8),backgroundColor:const Color(0xFFE8EEEC))]);
  Widget number(TextEditingController c,String label,{bool positive=false})=>TextFormField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:label),validator:(v){final n=double.tryParse((v??'').replaceAll(',','.'));return n==null||!n.isFinite||(positive?n<=0:n<0)?'Geçerli değer girin':null;});
  Future<void> addFood([Food? existing]) async {
    final name=TextEditingController(text:existing?.name??''),grams=TextEditingController(text:existing?.grams.toString()??''),kcal=TextEditingController(text:existing?.kcal.toString()??''),protein=TextEditingController(text:existing?.protein.toString()??'0'),carbs=TextEditingController(text:existing?.carbs.toString()??'0'),fat=TextEditingController(text:existing?.fat.toString()??'0');
    final form=GlobalKey<FormState>();String meal=existing?.meal??meals.first;
    final result=await showModalBottomSheet<Food>(context:context,isScrollControlled:true,showDragHandle:true,builder:(sheet)=>StatefulBuilder(builder:(ctx,update)=>Padding(padding:EdgeInsets.fromLTRB(20,8,20,MediaQuery.viewInsetsOf(ctx).bottom+24),child:Form(key:form,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text(existing==null?'Öğün ekle':'Öğünü düzenle',style:Theme.of(ctx).textTheme.headlineSmall),
      const Text('Besin değerlerini 100 gram için gir.'),
      DropdownButtonFormField<String>(initialValue:meal,decoration:const InputDecoration(labelText:'Öğün'),items:meals.map((m)=>DropdownMenuItem(value:m,child:Text(m))).toList(),onChanged:(v){if(v!=null)update(()=>meal=v);}),
      TextFormField(controller:name,decoration:const InputDecoration(labelText:'Yiyecek adı'),validator:(v)=>v==null||v.trim().isEmpty?'Yiyecek adı gerekli':null),
      number(grams,'Porsiyon (gram)',positive:true),number(kcal,'Kalori (kcal / 100 g)'),number(protein,'Protein (g / 100 g)'),number(carbs,'Karbonhidrat (g / 100 g)'),number(fat,'Yağ (g / 100 g)'),
      const SizedBox(height:16),FilledButton(onPressed:(){if(!form.currentState!.validate())return;double val(TextEditingController c)=>double.parse(c.text.replaceAll(',','.'));Navigator.pop(sheet,Food(id:existing?.id,name:name.text.trim(),meal:meal,date:existing?.date??day(selected),grams:val(grams),kcal:val(kcal),protein:val(protein),carbs:val(carbs),fat:val(fat)));},child:const Text('Kaydet'))
    ]))))));
    if(result!=null){try{if(existing==null){await Store.add(result);}else{await Store.update(result);}await reload();}catch(e){fail(e);}}
  }
  Future<void> searchCatalog() async {
    // Approximate sample values per 100 g; users can edit values before saving.
    final catalog=<Food>[
      Food(name:'Muz',meal:'Atıştırmalık',date:'',grams:100,kcal:89,protein:1.1,carbs:22.8,fat:0.3),
      Food(name:'Elma',meal:'Atıştırmalık',date:'',grams:100,kcal:52,protein:0.3,carbs:13.8,fat:0.2),
      Food(name:'Yumurta (haşlanmış)',meal:'Kahvaltı',date:'',grams:100,kcal:155,protein:12.6,carbs:1.1,fat:10.6),
      Food(name:'Süt (tam yağlı)',meal:'Kahvaltı',date:'',grams:100,kcal:61,protein:3.2,carbs:4.8,fat:3.3),
      Food(name:'Yoğurt (sade)',meal:'Atıştırmalık',date:'',grams:100,kcal:61,protein:3.5,carbs:4.7,fat:3.3),
      Food(name:'Beyaz peynir',meal:'Kahvaltı',date:'',grams:100,kcal:264,protein:14.2,carbs:3.9,fat:21.3),
      Food(name:'Ekmek (beyaz)',meal:'Kahvaltı',date:'',grams:100,kcal:265,protein:9,carbs:49,fat:3.2),
      Food(name:'Pirinç pilavı (pişmiş)',meal:'Öğle',date:'',grams:100,kcal:130,protein:2.7,carbs:28.2,fat:0.3),
      Food(name:'Makarna (haşlanmış)',meal:'Öğle',date:'',grams:100,kcal:158,protein:5.8,carbs:30.9,fat:0.9),
      Food(name:'Tavuk göğsü (pişmiş)',meal:'Akşam',date:'',grams:100,kcal:165,protein:31,carbs:0,fat:3.6),
      Food(name:'Mercimek (haşlanmış)',meal:'Öğle',date:'',grams:100,kcal:116,protein:9,carbs:20.1,fat:0.4),
      Food(name:'Patates (haşlanmış)',meal:'Akşam',date:'',grams:100,kcal:87,protein:1.9,carbs:20.1,fat:0.1),
    ];
    String query='';
    final chosen=await showModalBottomSheet<Food>(context:context,isScrollControlled:true,showDragHandle:true,builder:(sheet)=>StatefulBuilder(builder:(ctx,update){
      final matches=catalog.where((f)=>f.name.toLowerCase().contains(query.toLowerCase())).toList();
      return SafeArea(child:Padding(padding:EdgeInsets.fromLTRB(16,8,16,MediaQuery.viewInsetsOf(ctx).bottom+12),child:SizedBox(height:MediaQuery.sizeOf(ctx).height*0.65,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Text('Hazır besin ara',style:Theme.of(ctx).textTheme.headlineSmall),
        const SizedBox(height:8),
        const Text('Besin değerleri yaklaşık örneklerdir (100 g). Ürüne ve pişirme şekline göre değişir.'),
        const SizedBox(height:12),
        TextField(autofocus:true,decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Muz, yumurta, pilav...'),onChanged:(v)=>update(()=>query=v)),
        const SizedBox(height:8),
        Expanded(child:ListView(children:matches.map((f)=>ListTile(title:Text(f.name),subtitle:Text('${f.kcal.toStringAsFixed(0)} kcal / 100 g · P ${f.protein.toStringAsFixed(1)} g'),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.pop(sheet,f))).toList())),
      ]))));
    }));
    if(chosen!=null&&mounted){await addFood(chosen);}
  }
  Future<void> addFromSaved(Food food) async {
    try {await Store.add(Food(name:food.name,meal:'Kahvaltı',date:day(selected),grams:food.grams,kcal:food.kcal,protein:food.protein,carbs:food.carbs,fat:food.fat));await reload();
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${food.name} eklendi')));
    } catch(e){fail(e);}
  }
  Future<void> savedFoods() async {
    final saved=await Store.favorites();
    if(!mounted)return;
    await showModalBottomSheet<void>(context:context,isScrollControlled:true,showDragHandle:true,builder:(sheet)=>SafeArea(child:Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Favori besinler',style:Theme.of(sheet).textTheme.headlineSmall),
      const SizedBox(height:12),
      if(saved.isEmpty)const Padding(padding:EdgeInsets.all(20),child:Text('Henüz favori yok. Önce bir öğün kaydet, ardından kalp simgesine dokun.')),
      Flexible(child:ListView(shrinkWrap:true,children:saved.map((f)=>ListTile(title:Text(f.name),subtitle:Text('${f.grams.toStringAsFixed(0)} g · ${f.energy.toStringAsFixed(0)} kcal'),trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()async{try{await Store.removeFavorite(f.id!);if(sheet.mounted)Navigator.pop(sheet);await savedFoods();}catch(e){fail(e);}}),onTap:()async{Navigator.pop(sheet);await addFromSaved(f);})).toList()))
    ]))));
  }
  Future<void> copyMealsToTomorrow() async {
    final current=foods.where((f)=>f.date==day(selected)).toList();
    if(current.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Önce bu güne öğün eklemelisin.')));return;}
    final tomorrow=day(selected.add(const Duration(days:1)));
    final existing=foods.where((f)=>f.date==tomorrow).toList();
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title:const Text('Yarının öğün planı'),
      content:Text('${current.length} öğün $tomorrow tarihine plan olarak kopyalanacak. ${existing.isNotEmpty ? "Yarın için mevcut ${existing.length} kayıt korunacak." : ""} Planlanan öğünler, tüketildi olarak değil günlük kayıt olarak sayılır.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Vazgeç')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Kopyala'))]));
    if(ok!=true)return;
    try {
      for(final f in current){await Store.add(Food(name:f.name,meal:f.meal,date:tomorrow,grams:f.grams,kcal:f.kcal,protein:f.protein,carbs:f.carbs,fat:f.fat));}
      await reload();
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${current.length} öğün yarına kopyalandı.')));
    }catch(e){fail(e);}
  }
  Future<void> addWeightRecord() async {
    final controller=TextEditingController();
    final form=GlobalKey<FormState>();
    final kg=await showDialog<double>(context:context,builder:(ctx)=>AlertDialog(
      title:const Text('Kilo kaydı ekle'),
      content:Form(key:form,child:TextFormField(
        controller:controller,autofocus:true,
        keyboardType:const TextInputType.numberWithOptions(decimal:true),
        decoration:const InputDecoration(labelText:'Kilo (kg)',hintText:'78,5'),
        validator:(value){final n=double.tryParse((value??'').replaceAll(',','.'));return n==null||!n.isFinite||n<=0||n>500?'1–500 kg arasında değer girin':null;},
      )),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('İptal')),
        FilledButton(onPressed:(){if(form.currentState!.validate())Navigator.pop(ctx,double.parse(controller.text.replaceAll(',','.')));},child:const Text('Kaydet'))],
    ));
    if(kg!=null){try{await Store.addWeight(day(selected),kg);await reload();}catch(e){fail(e);}}
    controller.dispose();
  }
  Future<void> editGoals() async {
    final fields=[target,pt,ct,ft].map((n)=>TextEditingController(text:n.toStringAsFixed(0))).toList(),form=GlobalKey<FormState>();
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Günlük hedefler'),content:Form(key:form,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[number(fields[0],'Kalori (kcal)',positive:true),number(fields[1],'Protein (g)',positive:true),number(fields[2],'Karbonhidrat (g)',positive:true),number(fields[3],'Yağ (g)',positive:true)]))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('İptal')),FilledButton(onPressed:(){if(form.currentState!.validate())Navigator.pop(ctx,true);},child:const Text('Kaydet'))]));
    if(ok==true){try{for(var i=0;i<4;i++){await Store.setSetting(['calories','protein','carbs','fat'][i],fields[i].text.replaceAll(',','.'));}await reload();}catch(e){fail(e);}}
  }
  @override Widget build(BuildContext context){
    final today=foods.where((f)=>f.date==day(selected)).toList();
    final calories=today.fold<double>(0,(s,f)=>s+f.energy),protein=today.fold<double>(0,(s,f)=>s+f.p),carbs=today.fold<double>(0,(s,f)=>s+f.c),fat=today.fold<double>(0,(s,f)=>s+f.f);
    return Scaffold(appBar:AppBar(title:Text(['Gün özeti','Trendler','Ekle','Raporlar','Profil'][tab],style:const TextStyle(fontWeight:FontWeight.bold))),
      bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i){if(i==2){addFood();return;}setState(()=>tab=i);},destinations:const [
        NavigationDestination(icon:Icon(Icons.home_outlined),label:'Bugün'),NavigationDestination(icon:Icon(Icons.show_chart),label:'Trendler'),NavigationDestination(icon:Icon(Icons.add_circle_outline),label:'Ekle'),NavigationDestination(icon:Icon(Icons.description_outlined),label:'Raporlar'),NavigationDestination(icon:Icon(Icons.person_outline),label:'Profil')]),
      body:SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(16,12,16,24),children:[
        if(error!=null)card(Text(error!,style:const TextStyle(color:Colors.red))),
        if(tab==0)...[
          const Text('Küçük adımlar, düzenli ilerleme.'),const SizedBox(height:16),
          card(Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
            IconButton(onPressed:()async{setState(()=>selected=selected.subtract(const Duration(days:1)));await reload();},icon:const Icon(Icons.chevron_left)),
            Text(day(selected),style:const TextStyle(fontSize:18)),IconButton(onPressed:()async{setState(()=>selected=selected.add(const Duration(days:1)));await reload();},icon:const Icon(Icons.chevron_right))])),
          card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('Günlük enerji',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:14),
            Text('${calories.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} kcal',style:const TextStyle(fontSize:27,fontWeight:FontWeight.bold)),
            const SizedBox(height:14),meter('Kalori',calories,target,'kcal'),const Divider(height:30),
            meter('Protein',protein,pt,'g'),const SizedBox(height:14),meter('Karbonhidrat',carbs,ct,'g'),const SizedBox(height:14),meter('Yağ',fat,ft,'g')])),
          card(Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            const Text('Günün öğünleri',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),Text('${today.length} kayıt · ${calories.toStringAsFixed(0)} kcal'),const SizedBox(height:12),
            SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:['Tümü',...meals].map((m)=>Padding(padding:const EdgeInsets.only(right:6),child:ChoiceChip(label:Text(m),selected:filter==m,onSelected:(_)=>setState(()=>filter=m)))).toList())),
            if(today.where((f)=>filter=='Tümü'||f.meal==filter).isEmpty)const Padding(padding:EdgeInsets.all(16),child:Text('Bu öğün için henüz kayıt yok.')),
            ...today.where((f)=>filter=='Tümü'||f.meal==filter).map((f)=>ListTile(contentPadding:EdgeInsets.zero,title:Text(f.name),subtitle:Text('${f.meal} · ${f.grams.toStringAsFixed(0)} g · ${f.energy.toStringAsFixed(0)} kcal'),onTap:()=>addFood(f),trailing:PopupMenuButton<String>(tooltip:'Öğün işlemleri',onSelected:(action)async{if(action=='edit'){await addFood(f);}else if(action=='favorite'){try{await Store.saveFavorite(f);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Favorilere eklendi')));}catch(e){fail(e);}}else{final confirmed=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Öğün silinsin mi?'),content:Text('${f.name} kaydı silinecek.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Vazgeç')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Sil'))]));if(confirmed==true){try{await Store.delete(f.id!);await reload();}catch(e){fail(e);}}}},itemBuilder:(_)=>const [PopupMenuItem(value:'edit',child:Text('Düzenle')),PopupMenuItem(value:'favorite',child:Text('Favorilere ekle')),PopupMenuItem(value:'delete',child:Text('Sil'))]))),
            FilledButton.icon(onPressed:()=>addFood(),icon:const Icon(Icons.add),label:const Text('Besin ekle')),const SizedBox(height:8),OutlinedButton.icon(onPressed:searchCatalog,icon:const Icon(Icons.search),label:const Text('Hazır besin ara')),const SizedBox(height:8),OutlinedButton.icon(onPressed:savedFoods,icon:const Icon(Icons.favorite_outline),label:const Text('Favorilerden ekle')),const SizedBox(height:8),OutlinedButton.icon(onPressed:copyMealsToTomorrow,icon:const Icon(Icons.event_note_outlined),label:const Text('Öğünleri yarına kopyala'))])),
          card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Su takibi',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:12),meter('Günlük su',water.toDouble(),2000,'ml'),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:[...([100,250,500].map((ml)=>OutlinedButton(onPressed:()async{try{await Store.addWater(day(selected),ml);await reload();}catch(e){fail(e);}},child:Text('+$ml ml')))),OutlinedButton.icon(onPressed:water==0?null:()async{try{await Store.removeWater(day(selected),100);await reload();}catch(e){fail(e);}},icon:const Icon(Icons.remove),label:const Text('100 ml geri al'))])]))
        ]else if(tab==1)...[
          const Text('Değişimi birlikte takip et',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
          const Text('Kaydettiğin beslenme düzeni ve günlük ortalamalar.'),
          const SizedBox(height:16),
          Wrap(spacing:8,children:[7,30,90].map((n)=>ChoiceChip(label:Text('$n gün'),selected:trendDays==n,onSelected:(_)=>setState(()=>trendDays=n))).toList()),
          Builder(builder:(context){
            final entries=foods.map((f)=>DailyNutrition(
              date:DateTime.parse(f.date),calories:f.energy,protein:f.p,carbs:f.c,fat:f.f));
            final summary=summarizeNutrition(entries,end:DateTime.now(),days:trendDays);
            return card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              const Text('Beslenme trendi',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
              const SizedBox(height:8),
              Text('${summary.recordedDays}/$trendDays gün kayıtlı'),
              const SizedBox(height:16),
              if(summary.recordedDays==0)
                const Text('Bu dönemde kayıt yok. Öğün ekledikçe ortalamaların burada görünür.')
              else ...[
                Text('Kayıtlı gün ortalaması: ${summary.averageCalories.toStringAsFixed(0)} kcal',
                  style:const TextStyle(fontSize:19,fontWeight:FontWeight.w600)),
                const SizedBox(height:12),
                Text('Protein: ${summary.averageProtein.toStringAsFixed(1)} g'),
                Text('Karbonhidrat: ${summary.averageCarbs.toStringAsFixed(1)} g'),
                Text('Yağ: ${summary.averageFat.toStringAsFixed(1)} g'),
                const SizedBox(height:12),
                meter('Ortalama enerji',summary.averageCalories,target,'kcal'),
              ],
              const SizedBox(height:16),
              const Text('Ortalamalar yalnızca öğün kaydı olan günlerden hesaplanır. Eksik kayıtlar gerçek tüketimi yansıtmayabilir.')
            ]));
          }),
          card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(children:[const Expanded(child:Text('Kilo kayıtları',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold))),
              IconButton(tooltip:'Kilo ekle',onPressed:addWeightRecord,icon:const Icon(Icons.add_circle_outline))]),
            if(weights.isEmpty)const Padding(padding:EdgeInsets.symmetric(vertical:12),child:Text('Henüz kilo ölçümü yok. İlk ölçümünü ekle.'))
            else ...[
              Text('Son ölçüm: ${weights.first.kg.toStringAsFixed(1)} kg'),
              if(weights.length>=2)Text('Önceki ölçüme göre: ${(weights.first.kg-weights[1].kg).toStringAsFixed(1)} kg'),
              const SizedBox(height:8),
              ...weights.take(5).map((w)=>ListTile(
                contentPadding:EdgeInsets.zero,title:Text('${w.kg.toStringAsFixed(1)} kg'),subtitle:Text(w.date),
                trailing:IconButton(tooltip:'Kaydı sil',icon:const Icon(Icons.delete_outline),onPressed:()async{
                  final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
                    title:const Text('Kilo kaydını sil?'),content:Text('${w.date} tarihli ölçüm silinecek.'),
                    actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Vazgeç')),
                      FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Sil'))]));
                  if(ok==true){try{await Store.deleteWeight(w.id);await reload();}catch(e){fail(e);}}
                }),
              )),
            ],
          ])),
          const Text('Son 7 günün kalori kayıtları',style:TextStyle(fontSize:18,fontWeight:FontWeight.w600)),
          const SizedBox(height:12),
          ...List.generate(7,(i){final d=DateTime.now().subtract(Duration(days:6-i)),group=foods.where((f)=>f.date==day(d)).toList(),total=group.fold<double>(0,(s,f)=>s+f.energy);return card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(day(d)),const SizedBox(height:8),meter('Kalori',total,target,'kcal'),const SizedBox(height:6),Text(group.isEmpty?'Kayıt yok':total>target?'Hedefin üzerinde':'Hedefin altında',style:const TextStyle(color:green))]));}),
          const Text('Grafikler yalnızca kaydedilen öğünleri yansıtır.')
        ]else if(tab==3)...[
          card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('Seçili günün raporu',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
            const SizedBox(height:8),Text(day(selected)),const SizedBox(height:12),
            Text('Toplam enerji: ${calories.toStringAsFixed(0)} kcal'),
            Text('Protein: ${protein.toStringAsFixed(1)} g'),
            Text('Karbonhidrat: ${carbs.toStringAsFixed(1)} g'),
            Text('Yağ: ${fat.toStringAsFixed(1)} g'),
            Text('Su: $water ml'),const Divider(height:28),
            ...meals.map((m){final group=today.where((f)=>f.meal==m).toList();final sum=group.fold<double>(0,(a,f)=>a+f.energy);return Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Text('$m: ${group.length} kayıt · ${sum.toStringAsFixed(0)} kcal'));}),
            const SizedBox(height:8),const Text('Bu rapor yalnızca manuel kaydedilen öğün ve su verilerini içerir.')
          ])),
          Builder(builder:(context){
            final records=foods.map((f)=>DailyNutrition(date:DateTime.parse(f.date),
              calories:f.energy,protein:f.p,carbs:f.c,fat:f.f));
            final weekly=summarizeNutrition(records,end:selected,days:7);
            final monthly=summarizeNutrition(records,end:selected,days:30);
            return card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              const Text('Beslenme özeti',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
              const SizedBox(height:12),
              Text('Son 7 gün: ${weekly.recordedDays} kayıtlı gün'),
              Text('Ortalama enerji: ${weekly.averageCalories.toStringAsFixed(0)} kcal'),
              Text('Ortalama protein: ${weekly.averageProtein.toStringAsFixed(1)} g'),
              const Divider(height:24),
              Text('Son 30 gün: ${monthly.recordedDays} kayıtlı gün'),
              Text('Ortalama enerji: ${monthly.averageCalories.toStringAsFixed(0)} kcal'),
              Text('Ortalama karbonhidrat: ${monthly.averageCarbs.toStringAsFixed(1)} g'),
              Text('Ortalama yağ: ${monthly.averageFat.toStringAsFixed(1)} g'),
              const SizedBox(height:10),
              const Text('Ortalamalar yalnızca öğün kaydı bulunan günleri içerir.'),
            ]));
          }),
          card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('Kilo ölçüm özeti',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
            const SizedBox(height:12),
            if(weights.isEmpty)const Text('Henüz kilo kaydı bulunmuyor.')
            else ...[
              Text('Son ölçüm: ${weights.first.kg.toStringAsFixed(1)} kg (${weights.first.date})'),
              if(weights.length>1)Text('İlk kayda göre değişim: ${(weights.first.kg-weights.last.kg).toStringAsFixed(1)} kg'),
              Text('Toplam ölçüm: ${weights.length}'),
            ],
            const SizedBox(height:8),
            const Text('Bu değerler manuel kayıtlardır; tıbbi değerlendirme değildir.'),
          ])),
          card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('Son 7 gün',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
            const SizedBox(height:12),
            ...List.generate(7,(i){final d=DateTime.now().subtract(Duration(days:6-i));final group=foods.where((f)=>f.date==day(d)).toList();final total=group.fold<double>(0,(a,f)=>a+f.energy);return Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Text('${day(d)} · ${group.length} öğün · ${total.toStringAsFixed(0)} kcal'));})
          ]))
        ]else if(tab==4)...[
          card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Beslenme hedeflerin',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:12),Text('${target.toStringAsFixed(0)} kcal',style:const TextStyle(fontSize:30,fontWeight:FontWeight.bold)),Text('Protein ${pt.toStringAsFixed(0)} g'),Text('Karbonhidrat ${ct.toStringAsFixed(0)} g'),Text('Yağ ${ft.toStringAsFixed(0)} g'),const SizedBox(height:12),OutlinedButton.icon(onPressed:editGoals,icon:const Icon(Icons.edit),label:const Text('Hedefleri düzenle'))])),
          card(const Text('Verilerin cihazındaki SQLite veritabanında saklanır. Bulut senkronizasyonu, fotoğraftan besin analizi ve sağlık uygulaması bağlantısı bu sürümde yok.'))
        ]
      ])));
  }
}
