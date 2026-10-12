import 'package:flutter/material.dart';
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
class Store {
  static Database? _db;
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await openDatabase(p.join(await getDatabasesPath(),'calorie_tracker.db'),version:2,
      onCreate:(d,v) async {
        await d.execute('CREATE TABLE food_entries (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,grams REAL NOT NULL,kcal_per_100g REAL NOT NULL,created_at TEXT NOT NULL,meal TEXT NOT NULL DEFAULT "Diğer",protein REAL NOT NULL DEFAULT 0,carbs REAL NOT NULL DEFAULT 0,fat REAL NOT NULL DEFAULT 0)');
        await d.execute('CREATE TABLE water_entries (day TEXT PRIMARY KEY,ml INTEGER NOT NULL)');
        await d.execute('CREATE TABLE settings (key TEXT PRIMARY KEY,value TEXT NOT NULL)');
      },
      onUpgrade:(d,old,v) async { if(old<2) {
        for(final col in ['meal TEXT NOT NULL DEFAULT "Diğer"','protein REAL NOT NULL DEFAULT 0','carbs REAL NOT NULL DEFAULT 0','fat REAL NOT NULL DEFAULT 0']) { await d.execute('ALTER TABLE food_entries ADD COLUMN $col'); }
        await d.execute('CREATE TABLE water_entries (day TEXT PRIMARY KEY,ml INTEGER NOT NULL)');
        await d.execute('CREATE TABLE settings (key TEXT PRIMARY KEY,value TEXT NOT NULL)');
      }});
    return _db!;
  }
  static Future<List<Food>> foods() async => (await (await db).query('food_entries',orderBy:'created_at DESC,id DESC')).map(Food.fromMap).toList();
  static Future<void> add(Food f) async { await (await db).insert('food_entries',f.toMap()); }
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
  List<Food> foods=[]; DateTime selected=DateTime.now(); int tab=0,water=0;
  double target=2200,pt=120,ct=260,ft=70; String filter='Tümü'; String? error;
  final meals=['Kahvaltı','Öğle','Akşam','Atıştırmalık','Diğer'];
  @override void initState(){super.initState();reload();}
  Future<void> reload() async {try {
    final f=await Store.foods(), w=await Store.water(day(selected));
    final settings=await Future.wait(['calories','protein','carbs','fat'].map(Store.getSetting));
    if(mounted)setState((){foods=f;water=w;target=double.tryParse(settings[0]??'')??2200;pt=double.tryParse(settings[1]??'')??120;ct=double.tryParse(settings[2]??'')??260;ft=double.tryParse(settings[3]??'')??70;error=null;});
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
            ...today.where((f)=>filter=='Tümü'||f.meal==filter).map((f)=>ListTile(contentPadding:EdgeInsets.zero,title:Text(f.name),subtitle:Text('${f.meal} · ${f.grams.toStringAsFixed(0)} g · ${f.energy.toStringAsFixed(0)} kcal'),onTap:()=>addFood(f),trailing:PopupMenuButton<String>(tooltip:'Öğün işlemleri',onSelected:(action)async{if(action=='edit'){await addFood(f);}else{final confirmed=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Öğün silinsin mi?'),content:Text('${f.name} kaydı silinecek.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Vazgeç')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Sil'))]));if(confirmed==true){try{await Store.delete(f.id!);await reload();}catch(e){fail(e);}}}},itemBuilder:(_)=>const [PopupMenuItem(value:'edit',child:Text('Düzenle')),PopupMenuItem(value:'delete',child:Text('Sil'))]))),
            FilledButton.icon(onPressed:()=>addFood(),icon:const Icon(Icons.add),label:const Text('Besin ekle'))])),
          card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Su takibi',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:12),meter('Günlük su',water.toDouble(),2000,'ml'),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:[...([100,250,500].map((ml)=>OutlinedButton(onPressed:()async{try{await Store.addWater(day(selected),ml);await reload();}catch(e){fail(e);}},child:Text('+$ml ml')))),OutlinedButton.icon(onPressed:water==0?null:()async{try{await Store.removeWater(day(selected),100);await reload();}catch(e){fail(e);}},icon:const Icon(Icons.remove),label:const Text('100 ml geri al'))])]))
        ]else if(tab==1)...[
          const Text('Son 7 günün kalori kayıtları'),const SizedBox(height:16),
          ...List.generate(7,(i){final d=DateTime.now().subtract(Duration(days:6-i)),total=foods.where((f)=>f.date==day(d)).fold<double>(0,(s,f)=>s+f.energy);return card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(day(d)),const SizedBox(height:8),meter('Kalori',total,target,'kcal'),const SizedBox(height:6),Text(total==0?'Kayıt yok':total>target?'Hedefin üzerinde': 'Hedefin altında',style:const TextStyle(color:green))]));}),
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
