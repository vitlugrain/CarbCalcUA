from pathlib import Path

p = Path('lib/main.dart')
s = p.read_text()

# Add an explicit page ScrollController once.
old = "  final amountFocusNode=FocusNode();\n  final quantitySectionKey=GlobalKey();"
new = "  final amountFocusNode=FocusNode();\n  final quantitySectionKey=GlobalKey();\n  final pageScrollController=ScrollController();"
if 'final pageScrollController=ScrollController();' not in s:
    if old not in s:
        raise SystemExit('state fields anchor not found')
    s = s.replace(old, new, 1)

old_dispose = "  @override void dispose(){controller.dispose();amountFocusNode.dispose();super.dispose();}"
new_dispose = "  @override void dispose(){controller.dispose();amountFocusNode.dispose();pageScrollController.dispose();super.dispose();}"
if 'pageScrollController.dispose()' not in s:
    if old_dispose not in s:
        raise SystemExit('dispose anchor not found')
    s = s.replace(old_dispose, new_dispose, 1)

# Replace the old ensureVisible/focus logic with explicit page scrolling.
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

# Attach the controller to the AddFoodPage ListView.
build_anchor = s.index('  @override Widget build(BuildContext c)=>FutureBuilder<List<Product>>')
old_list = "    return ListView(padding:const EdgeInsets.all(20),children:["
new_list = "    return ListView(controller:pageScrollController,padding:const EdgeInsets.all(20),children:["
if new_list not in s[build_anchor:]:
    pos = s.index(old_list, build_anchor)
    s = s[:pos] + new_list + s[pos+len(old_list):]

# Once a product is selected, collapse search results so the quantity block is not left below 10 result cards.
old_results = "      if(q.trim().isNotEmpty && list.isNotEmpty)...["
new_results = "      if(selected==null && q.trim().isNotEmpty && list.isNotEmpty)...["
if old_results in s:
    s = s.replace(old_results, new_results, 1)

old_empty = "      ] else if(q.trim().isNotEmpty && list.isEmpty)"
new_empty = "      ] else if(selected==null && q.trim().isNotEmpty && list.isEmpty)"
if old_empty in s:
    s = s.replace(old_empty, new_empty, 1)

# Put the key on the whole quantity + unit row, not only the text field.
old_row = "        Row(crossAxisAlignment:CrossAxisAlignment.start,children:[\n          Expanded(child:TextFormField(key:quantitySectionKey,focusNode:amountFocusNode,controller:controller,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Кількість',border:OutlineInputBorder()),onChanged:(v)=>setState(()=>amount=double.tryParse(v.replaceAll(',','.'))??0))),\n          const SizedBox(width:10),"
new_row = "        Container(key:quantitySectionKey,child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[\n          Expanded(child:TextFormField(focusNode:amountFocusNode,controller:controller,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Кількість',border:OutlineInputBorder()),onChanged:(v)=>setState(()=>amount=double.tryParse(v.replaceAll(',','.'))??0))),\n          const SizedBox(width:10),"
if 'Container(key:quantitySectionKey,child:Row' not in s:
    if old_row not in s:
        raise SystemExit('quantity row start anchor not found')
    s = s.replace(old_row, new_row, 1)
    anchor = s.index("Container(key:quantitySectionKey,child:Row")
    needle = "        ]),\n        const SizedBox(height:8),"
    pos = s.index(needle, anchor)
    s = s[:pos] + "        ])),\n        const SizedBox(height:8)," + s[pos+len(needle):]

p.write_text(s)
print('patched add-food UX: collapse results and explicitly scroll to quantity/unit controls')
