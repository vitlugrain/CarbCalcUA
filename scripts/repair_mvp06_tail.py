from pathlib import Path

path = Path('lib/main.dart')
text = path.read_text(encoding='utf-8')
marker = 'class CustomProductDialog'
if marker not in text:
    raise SystemExit('Marker not found')
head = text.split(marker, 1)[0]

tail = r'''class CustomProductDialog extends StatefulWidget {
  const CustomProductDialog({super.key});
  @override State<CustomProductDialog> createState() => _CustomProductDialogState();
}
class _CustomProductDialogState extends State<CustomProductDialog> {
  final n=TextEditingController(),cat=TextEditingController(text:'Мої продукти'),c=TextEditingController(),p=TextEditingController(),f=TextEditingController(),fi=TextEditingController(),cal=TextEditingController();
  final barcode=TextEditingController(),gramsPerPiece=TextEditingController(),gramsPerMl=TextEditingController(),servingGrams=TextEditingController();
  double? _num(TextEditingController x)=>double.tryParse(x.text.replaceAll(',','.').trim());
  @override void dispose(){for(final x in [n,cat,c,p,f,fi,cal,barcode,gramsPerPiece,gramsPerMl,servingGrams])x.dispose();super.dispose();}
  @override Widget build(BuildContext context){return AlertDialog(title:const Text('Мій продукт'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
    TextField(controller:n,decoration:const InputDecoration(labelText:'Назва')),
    TextField(controller:cat,decoration:const InputDecoration(labelText:'Категорія')),
    TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Вуглеводи / 100 г')),
    TextField(controller:p,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Білки / 100 г')),
    TextField(controller:f,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Жири / 100 г')),
    TextField(controller:fi,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Клітковина / 100 г')),
    TextField(controller:cal,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Ккал / 100 г')),
    const SizedBox(height:8),const Align(alignment:Alignment.centerLeft,child:Text('Дані для швидкого введення',style:TextStyle(fontWeight:FontWeight.w600))),
    TextField(controller:barcode,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Штрихкод (необовʼязково)')),
    TextField(controller:gramsPerPiece,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Вага 1 шт, г')),
    TextField(controller:gramsPerMl,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Грамів у 1 мл')),
    TextField(controller:servingGrams,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Вага 1 порції, г')),
  ])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Скасувати')),FilledButton(onPressed:n.text.trim().isNotEmpty&&c.text.isNotEmpty?()=>Navigator.pop(context,Product(id:'custom_${DateTime.now().microsecondsSinceEpoch}',name:n.text.trim(),category:cat.text.trim(),carbs:_num(c)??0,protein:_num(p)??0,fat:_num(f)??0,fiber:_num(fi)??0,calories:_num(cal)??0,barcode:barcode.text.trim().isEmpty?null:barcode.text.trim(),source:'Користувач',gramsPerPiece:_num(gramsPerPiece),gramsPerMl:_num(gramsPerMl),servingGrams:_num(servingGrams))):null,child:const Text('Зберегти'))]);}
}

class ReportsPage extends StatefulWidget{const ReportsPage({super.key});@override State<ReportsPage> createState()=>_ReportsPageState();}
class _ReportsPageState extends State<ReportsPage>{int days=1;DateTime end=DateTime.now();DateTime get start=>DateTime(end.year,end.month,end.day).subtract(Duration(days:days-1));Future<List<Map<String,dynamic>>> load()async=> (await AppDb.db).query('diary',where:'date>=? AND date<?',whereArgs:[_dateKey(start),_dateKey(end.add(const Duration(days:1)))],orderBy:'date ASC,id ASC');@override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('Звіти')),body:FutureBuilder<List<Map<String,dynamic>>>(future:load(),builder:(context,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final rows=s.data!;final total=rows.fold<double>(0,(a,x)=>a+(x['carbs'] as num).toDouble());return ListView(padding:const EdgeInsets.all(16),children:[DropdownButtonFormField<int>(value:days,decoration:const InputDecoration(labelText:'Період',border:OutlineInputBorder()),items:const[DropdownMenuItem(value:1,child:Text('День')),DropdownMenuItem(value:7,child:Text('7 днів')),DropdownMenuItem(value:30,child:Text('30 днів'))],onChanged:(v){if(v!=null){setState(()=>days=v);}}),const SizedBox(height:10),Text('${_prettyDate(start)} — ${_prettyDate(end)}'),Card(child:ListTile(title:const Text('Всього вуглеводів'),trailing:Text('${total.toStringAsFixed(1)} г',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)))),if(rows.isNotEmpty)SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(columns:const[DataColumn(label:Text('Дата')),DataColumn(label:Text('Прийом')),DataColumn(label:Text('Час')),DataColumn(label:Text('Продукт')),DataColumn(label:Text('Кількість')),DataColumn(label:Text('Вуглеводи'))],rows:rows.map((r)=>DataRow(cells:[DataCell(Text(_prettyDate(DateTime.parse(r['date'] as String)))),DataCell(Text((r['meal'] as String?)??'')),DataCell(Text((r['meal_time'] as String?)??'')),DataCell(Text(r['name'] as String)),DataCell(Text(_displayDiaryAmount(r))),DataCell(Text('${(r['carbs'] as num).toStringAsFixed(1)} г'))])).toList()))else const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('За вибраний період записів немає.'))),const SizedBox(height:10),Text('Середнє за день: ${(total/days).toStringAsFixed(1)} г')]);}));}
}

class GlucoseImportPage extends StatefulWidget{const GlucoseImportPage({super.key});@override State<GlucoseImportPage> createState()=>_GlucoseImportPageState();}
class _GlucoseImportPageState extends State<GlucoseImportPage>{bool busy=false;GlucoseImportResult? result;String? fileName;Future<void> pick()async{final picked=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['csv','pdf'],withData:true);if(picked==null||picked.files.isEmpty)return;final file=picked.files.single;if(file.bytes==null)return;setState((){busy=true;fileName=file.name;});try{final parsed=file.extension?.toLowerCase()=='pdf'?GlucoseImportService.fromPdf(file.bytes!,source:file.name):GlucoseImportService.fromCsv(utf8.decode(file.bytes!,allowMalformed:true),source:file.name);final fresh=await AppDb.onlyNewGlucose(parsed.readings);final dup=parsed.readings.length-fresh.length;if(mounted)setState(()=>result=GlucoseImportResult(fresh,[...parsed.warnings,'Дублікатів: $dup']));}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Помилка імпорту: $e')));}finally{if(mounted)setState(()=>busy=false);}}Future<void> save()async{final r=result;if(r==null||r.readings.isEmpty)return;await AppDb.insertGlucoseBatch(r.readings);if(mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Імпортовано ${r.readings.length} показників.')));setState(()=>result=null);}}@override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('Імпорт глюкози')),body:ListView(padding:const EdgeInsets.all(20),children:[const Text('Універсальний імпорт',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('CSV — основний формат. PDF підтримується для текстових таблиць; для складних PDF краще використовувати CSV.'),const SizedBox(height:16),FilledButton.icon(onPressed:busy?null:pick,icon:const Icon(Icons.upload_file),label:Text(busy?'Обробка...':'Вибрати CSV або PDF')),if(fileName!=null)Text(fileName!),if(result!=null)...[const SizedBox(height:16),Text('Нових показників: ${result!.readings.length}'),...result!.readings.take(20).map((r)=>ListTile(leading:const Icon(Icons.bloodtype),title:Text('${r.valueMmol.toStringAsFixed(1)} ммоль/л'),subtitle:Text(_prettyDateTime(r.timestamp)))),FilledButton(onPressed:save,child:Text('Імпортувати ${result!.readings.length}'))]]));}}

class GlucoseHistoryPage extends StatelessWidget{const GlucoseHistoryPage({super.key});@override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('Історія глюкози')),body:FutureBuilder<List<Map<String,dynamic>>>(future:AppDb.glucose(),builder:(context,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());return ListView.builder(itemCount:s.data!.length,itemBuilder:(context,i){final r=s.data![i];final d=DateTime.parse(r['timestamp'] as String);return Card(child:ListTile(leading:const Icon(Icons.bloodtype),title:Text('${(r['value_mmol'] as num).toStringAsFixed(1)} ммоль/л'),subtitle:Text('${_prettyDateTime(d)} • ${r['source']??'імпорт'}')));});}));}}

String _prettyDateTime(DateTime d)=>'${_prettyDate(d)} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
String _n(double v)=>v%1==0?v.toStringAsFixed(0):v.toStringAsFixed(2);
String _displayDiaryAmount(Map<String,dynamic> x){final v=(x['amount_value'] as num?)?.toDouble()??(x['grams'] as num).toDouble();final u=(x['amount_unit'] as String?)??'г';return Quantity(v,_unitFromLabel(u)).display;}
QuantityUnit _unitFromLabel(String u){switch(u){case 'мл':return QuantityUnit.milliliters;case 'шт':return QuantityUnit.pieces;case 'порція':return QuantityUnit.portion;default:return QuantityUnit.grams;}}
String _dateKey(DateTime d)=>'${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
String _prettyDate(DateTime d)=>'${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}';
'''
path.write_text(head + tail, encoding='utf-8')
