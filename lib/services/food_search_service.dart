import '../models/product.dart';
import 'barcode_service.dart';
import 'dart:math' as math;

enum ParsedQuantityUnit { grams, milliliters, pieces, portion }

class ParsedFoodQuery {
  final String original;
  final String productQuery;
  final double? amount;
  final ParsedQuantityUnit? unit;
  const ParsedFoodQuery({required this.original, required this.productQuery, this.amount, this.unit});
}

class FoodSearchResult {
  final Product product;
  final double score;
  const FoodSearchResult(this.product, this.score);
}

class FoodSearchService {
  static ParsedFoodQuery parseQuery(String input) {
    final original = input.trim();
    if (original.isEmpty) return const ParsedFoodQuery(original: '', productQuery: '');
    final normalized = original.replaceAll(RegExp(r'(?<=\d),(?=\d)'), '.').replaceAll(RegExp(r'\s+'), ' ').trim();
    final leading = RegExp(r'^\s*(\d+(?:\.\d+)?)\s*(г|гр|грам(?:а|ів)?|мл|мл\.?|шт|штук(?:а|и)?|порц(?:ія|ії|ію)?)\s+(.+)$', caseSensitive: false).firstMatch(normalized);
    if (leading != null) return ParsedFoodQuery(original: original, productQuery: leading.group(3)!.trim(), amount: double.tryParse(leading.group(1)!), unit: _unitFromText(leading.group(2)!));
    final trailing = RegExp(r'^(.+?)\s+(\d+(?:\.\d+)?)\s*(г|гр|грам(?:а|ів)?|мл|мл\.?|шт|штук(?:а|и)?|порц(?:ія|ії|ію)?)\s*$', caseSensitive: false).firstMatch(normalized);
    if (trailing != null) return ParsedFoodQuery(original: original, productQuery: trailing.group(1)!.trim(), amount: double.tryParse(trailing.group(2)!), unit: _unitFromText(trailing.group(3)!));
    return ParsedFoodQuery(original: original, productQuery: original);
  }

  static ParsedQuantityUnit? _unitFromText(String text) {
    final t = normalize(text);
    if (t == 'г' || t.startsWith('грам')) return ParsedQuantityUnit.grams;
    if (t == 'мл') return ParsedQuantityUnit.milliliters;
    if (t == 'шт' || t.startsWith('штук')) return ParsedQuantityUnit.pieces;
    if (t.startsWith('порц')) return ParsedQuantityUnit.portion;
    return null;
  }

  static String normalize(String text) {
    var s = text.toLowerCase().trim();
    const replacements = {'ґ':'г','ё':'е','’':'',"'":'','`':'','–':' ','—':' '};
    replacements.forEach((a,b)=>s=s.replaceAll(a,b));
    s=s.replaceAll(RegExp(r'[^a-zа-яіїє0-9]+'),' ');
    return s.replaceAll(RegExp(r'\s+'),' ').trim();
  }

  static String stem(String token) {
    var t=normalize(token); if(t.isEmpty)return t;
    const aliases=<String,String>{
      'гречки':'гречк','гречку':'гречк','гречкою':'гречк','гречці':'гречк',
      'варена':'варен','варене':'варен','варені':'варен','варену':'варен','вареної':'варен','вареній':'варен','вареним':'варен','варених':'варен','варений':'варен',
      'суха':'сух','сухе':'сух','сухі':'сух','суху':'сух','сухої':'сух',
      'сирий':'сирстан','сира':'сирстан','сире':'сирстан','сирі':'сирстан','сиру':'сирстан',
      'свіже':'свіж','свіжа':'свіж','свіжий':'свіж','свіжі':'свіж',
      'печива':'печив','печиво':'печив','печивом':'печив','молоці':'молок','молоком':'молок','молочний':'молоч','молочна':'молоч','молочне':'молоч',
      'воді':'вод','водою':'вод','водний':'вод','рису':'рис','рисом':'рис','картоплі':'картопл','картоплю':'картопл','картоплею':'картопл',
      'моркви':'моркв','моркву':'моркв','банана':'банан','банану':'банан','яблука':'яблук','яблуко':'яблук','яблуці':'яблук',
      'курка':'курк','курки':'курк','курку':'курк','куркою':'курк','курятина':'курк','курятини':'курк','курятину':'курк',
      'мясо':'мяс','мяса':'мяс','мясом':'мяс','пепсі':'pepsi','пепси':'pepsi','зеро':'zero','нуль':'zero'
    };
    final alias=aliases[t]; if(alias!=null)return alias;
    const suffixes=['ами','ями','ого','ому','ими','ій','ою','ею','ам','ям','ах','ях','ів','їв','ом','ем','ові','еві','і','и','у','а','я'];
    for(final suffix in suffixes){if(t.length>suffix.length+3&&t.endsWith(suffix))return t.substring(0,t.length-suffix.length);}
    return t;
  }

  static const Map<String,List<String>> _ukToUsda={
    'хліб':['bread'],'батон':['bread','loaf'],'булк':['bread','roll'],'яйц':['egg'],'рис':['rice'],'гречк':['buckwheat'],'вівсянк':['oatmeal','oats'],'вівсян':['oat','oats'],
    'макарон':['pasta','macaroni','noodles'],'спагетті':['spaghetti'],'картопл':['potato'],'моркв':['carrot'],'буряк':['beet'],'капуст':['cabbage'],'помідор':['tomato'],'томат':['tomato'],
    'огірок':['cucumber'],'цибул':['onion'],'часник':['garlic'],'гарбуз':['pumpkin'],'кабачок':['squash','zucchini'],'баклажан':['eggplant'],'кукурудз':['corn'],'горох':['peas'],'квасол':['beans'],
    'яблук':['apple'],'груш':['pear'],'банан':['banana'],'апельсин':['orange'],'мандарин':['tangerine','mandarin'],'лимон':['lemon'],'виноград':['grapes'],'полуниц':['strawberry'],'малин':['raspberry'],
    'молок':['milk'],'кефір':['kefir'],'йогурт':['yogurt'],'сир':['cheese'],'курк':['chicken'],'індич':['turkey'],'ялович':['beef'],'свинин':['pork'],'сал':['pork fat'],'риб':['fish'],'лосос':['salmon'],
    'форел':['trout'],'скумбр':['mackerel'],'тріск':['cod'],'тун':['tuna'],'оселед':['herring'],'гриб':['mushroom'],'печериц':['mushroom','button mushroom'],'глив':['oyster mushroom'],'шиїтак':['shiitake'],
    'печив':['cookie','cookies'],'шоколад':['chocolate'],'цукор':['sugar'],'мед':['honey'],'борошн':['flour'],'булгур':['bulgur'],'кускус':['couscous'],'кіноа':['quinoa'],
    'pepsi':['pepsi'],'кола':['cola','coca cola','pepsi'],'кока':['coca cola','coke'],'zero':['zero','zero sugar','sugar free'],'безцукр':['zero sugar','sugar free','diet'],
    'варен':['cooked','boiled'],'смажен':['fried'],'запечен':['baked','roasted'],'сух':['dry','uncooked'],'свіж':['fresh'],'сирстан':['raw']
  };

  static List<String> _translatedTokens(List<String> queryTokens){
    final out=<String>[];
    for(final token in queryTokens){for(final entry in _ukToUsda.entries){if(token==entry.key||token.startsWith(entry.key)||entry.key.startsWith(token)){for(final phrase in entry.value){out.addAll(normalize(phrase).split(' ').where((x)=>x.isNotEmpty));}}}}
    return out.toSet().toList();
  }

  static List<String> _tokens(String text){
    const stop={'і','й','та','на','з','зі','із','у','в','для','по','до','або','шт','г','гр','мл','порція','порції','порцію'};
    return normalize(text).split(' ').where((x)=>x.length>=2&&!stop.contains(x)).map(stem).where((x)=>x.length>=2).toList();
  }

  static List<FoodSearchResult> search(String query,List<Product> products,{int limit=10}){
    final parsed=parseQuery(query); final q=normalize(parsed.productQuery); if(q.isEmpty)return [];
    final qTokens=_tokens(q); final translatedTokens=_translatedTokens(qTokens); final results=<FoodSearchResult>[];
    for(final p in products){
      final name=normalize(p.name); final nameTokens=_tokens(p.name); final aliasText=p.aliases.join(' '); final aliasTokens=_tokens(aliasText);
      final manufacturer=normalize(p.manufacturer??''); final manufacturerTokens=_tokens(p.manufacturer??''); final category=normalize(p.category); final categoryTokens=_tokens(p.category);
      final searchableTokens=<String>{...nameTokens,...aliasTokens,...manufacturerTokens,...categoryTokens}.toList(); var score=0.0; var matched=0;
      if(name==q)score+=180; if(name.contains(q))score+=72; if(aliasText.isNotEmpty&&normalize(aliasText).contains(q))score+=60; if(manufacturer.isNotEmpty&&manufacturer.contains(q))score+=48;
      if(category==q)score+=95; else if(category.isNotEmpty&&category.contains(q))score+=50;
      for(final token in qTokens){
        if(searchableTokens.contains(token)){score+=nameTokens.contains(token)?36:27;matched++;continue;}
        if(searchableTokens.any((n)=>n.startsWith(token)||token.startsWith(n))){score+=18;matched++;continue;}
        if(_similar(token,searchableTokens)>=0.82){score+=7;matched++;}
      }
      if(qTokens.isNotEmpty){score+=48*matched/qTokens.length;if(matched<qTokens.length)score-=30*(qTokens.length-matched);}
      if(translatedTokens.isNotEmpty){var tm=0;for(final token in translatedTokens){if(nameTokens.contains(token)){score+=22;tm++;}else if(nameTokens.any((n)=>n.startsWith(token)||token.startsWith(n))){score+=10;tm++;}}if(tm>0)score+=14;}
      final zeroQuery=qTokens.contains('zero')||q.contains('без цукру')||q.contains('sugar free');
      if(zeroQuery){final zeroLike=name.contains('zero')||name.contains('зеро')||name.contains('без цукру')||name.contains('sugar free')||name.contains('diet')||aliasText.toLowerCase().contains('zero');score+=zeroLike?75:-80;}
      if(p.id.startsWith('ua_core_'))score+=65; else if(!p.id.startsWith('usda_')&&!p.id.startsWith('off_'))score+=28; else if(p.id.startsWith('usda_'))score-=12;
      score+=_contextScore(qTokens,nameTokens);
      if(p.source?.startsWith('USDA')==true){score+=_usdaContextScore(qTokens,nameTokens);score+=_usdaSimplicityScore(qTokens,nameTokens,p.name);}
      final directEvidence=name.contains(q)||normalize(aliasText).contains(q)||manufacturer.contains(q)||category.contains(q)||matched>0;
      final translatedEvidence=translatedTokens.any((t)=>nameTokens.any((n)=>n==t||n.startsWith(t)||t.startsWith(n)));
      if((directEvidence||translatedEvidence)&&score>=45)results.add(FoodSearchResult(p,score));
    }
    results.sort((a,b){final s=b.score.compareTo(a.score);if(s!=0)return s;return a.product.name.compareTo(b.product.name);});
    final dedup=<String,FoodSearchResult>{};
    for(final r in results){final key=_dedupKey(r.product);final existing=dedup[key];if(existing==null||r.score>existing.score)dedup[key]=r;}
    final clean=dedup.values.toList()..sort((a,b){final s=b.score.compareTo(a.score);if(s!=0)return s;return a.product.name.compareTo(b.product.name);});
    return clean.take(limit).toList();
  }

  static String _dedupKey(Product p){
    var n=normalize(p.name).replaceAll('пепсі','pepsi').replaceAll('пепси','pepsi').replaceAll('кока кола','coca cola').replaceAll('кока-кола','coca cola');
    n=n.replaceAll(RegExp(r'\b(напій|газований|безалкогольний|carbonated|drink|beverage)\b'),' ').replaceAll(RegExp(r'\s+'),' ').trim();
    final m=normalize(p.manufacturer??'').replaceAll('пепсі','pepsi');
    return '$n|$m|${p.carbs.toStringAsFixed(1)}';
  }

  static Future<Product?> findByBarcode(String barcode,{CustomProductLookup? customProductLookup})=>BarcodeService.find(barcode,customProductLookup:customProductLookup);

  static double _contextScore(List<String> query,List<String> name){double score=0;bool has(String s)=>query.contains(s);bool ph(String s)=>name.contains(s);if(has('варен'))score+=ph('варен')?42:-35;if(has('сух'))score+=ph('сух')?42:-35;if(has('сирстан'))score+=ph('сирстан')?38:-30;if(has('свіж'))score+=ph('свіж')?32:-22;if(has('вод'))score+=ph('вод')?36:-12;if(has('молок'))score+=ph('молок')?36:-12;return score;}
  static double _usdaSimplicityScore(List<String> query,List<String> nameTokens,String originalName){double score=0;final lower=originalName.toLowerCase();if(query.length<=2){if(nameTokens.length<=5)score+=22;if(nameTokens.length>=10)score-=18;const noisy=['applebee','burger king','mcdonald','restaurant','fast food','babyfood','platter','sandwich','biscuit','microwaveable','packaged mix','with cheese','with sauce','native','agutu'];for(final term in noisy){if(lower.contains(term))score-=38;}}return score;}
  static double _usdaContextScore(List<String> query,List<String> name){double score=0;bool has(String s)=>query.contains(s);bool any(List<String> t)=>t.any(name.contains);if(has('варен'))score+=any(['cooked','boiled'])?34:0;if(has('смажен'))score+=any(['fried'])?34:0;if(has('запечен'))score+=any(['baked','roasted'])?34:0;if(has('сух'))score+=any(['dry','uncooked'])?28:0;if(has('свіж'))score+=any(['fresh'])?24:0;if(has('сирстан'))score+=any(['raw'])?28:0;if(has('молок'))score+=any(['milk'])?24:0;return score;}
  static double _similar(String a,List<String> candidates){var best=0.0;for(final b in candidates){final maxLen=math.max(a.length,b.length);if(maxLen==0)continue;final d=_levenshtein(a,b);best=math.max(best,1-d/maxLen);}return best;}
  static int _levenshtein(String a,String b){final prev=List<int>.generate(b.length+1,(i)=>i);for(var i=0;i<a.length;i++){var left=i+1;var diag=i;for(var j=0;j<b.length;j++){final up=prev[j+1];final cost=a.codeUnitAt(i)==b.codeUnitAt(j)?0:1;prev[j+1]=math.min(math.min(up+1,left+1),diag+cost);diag=up;left=prev[j+1];}prev[0]=i+1;}return prev[b.length];}
}
