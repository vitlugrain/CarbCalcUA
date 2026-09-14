from pathlib import Path

p = Path('lib/main.dart')
s = p.read_text()

old = "  final amountFocusNode=FocusNode();\n  final quantitySectionKey=GlobalKey();"
new = "  final amountFocusNode=FocusNode();\n  final quantitySectionKey=GlobalKey();\n  final pageScrollController=ScrollController();"
if old not in s:
    raise SystemExit('state fields anchor not found')
s = s.replace(old, new, 1)

old = "  @override void dispose(){controller.dispose();amountFocusNode.dispose();super.dispose();}"
new = "  @override void dispose(){controller.dispose();amountFocusNode.dispose();pageScrollController.dispose();super.dispose();}"
if old not in s:
    raise SystemExit('dispose anchor not found')
s = s.replace(old, new, 1)

start = s.index('  void _focusQuantitySection() {')
end = s.index('\n\n  double? _toGrams', start)
replacement = '''  void _focusQuantitySection() {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!mounted || !pageScrollController.hasClients) return;
      final ctx = quantitySectionKey.currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      if (box == null) return;
      final globalTop = box.localToGlobal(Offset.zero).dy;
      final target = (pageScrollController.offset + globalTop - 170.0)
          .clamp(0.0, pageScrollController.position.maxScrollExtent)
          .toDouble();
      await pageScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    });
  }'''
s = s[:start] + replacement + s[end:]

old = "    return ListView(padding:const EdgeInsets.all(20),children:["
new = "    return ListView(controller:pageScrollController,padding:const EdgeInsets.all(20),children:["
# replace only AddFoodPage occurrence after build marker
build_anchor = s.index('  @override Widget build(BuildContext c)=>FutureBuilder<List<Product>>')
pos = s.index(old, build_anchor)
s = s[:pos] + new + s[pos+len(old):]

old = "        Row(crossAxisAlignment:CrossAxisAlignment.start,children:[\n          Expanded(child:TextFormField(key:quantitySectionKey,focusNode:amountFocusNode,controller:controller,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Кількість',border:OutlineInputBorder()),onChanged:(v)=>setState(()=>amount=double.tryParse(v.replaceAll(',','.'))??0))),\n          const SizedBox(width:10),"
new = "        Container(key:quantitySectionKey,child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[\n          Expanded(child:TextFormField(focusNode:amountFocusNode,controller:controller,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Кількість',border:OutlineInputBorder()),onChanged:(v)=>setState(()=>amount=double.tryParse(v.replaceAll(',','.'))??0))),\n          const SizedBox(width:10),"
if old not in s:
    raise SystemExit('quantity row start anchor not found')
s = s.replace(old, new, 1)

# close Container after the quantity/unit Row. Find the first matching row terminator following the new anchor.
anchor = s.index("Container(key:quantitySectionKey,child:Row")
needle = "        ]),\n        const SizedBox(height:8),"
pos = s.index(needle, anchor)
s = s[:pos] + "        ])),\n        const SizedBox(height:8)," + s[pos+len(needle):]

p.write_text(s)
print('patched lib/main.dart with explicit ScrollController quantity navigation')
