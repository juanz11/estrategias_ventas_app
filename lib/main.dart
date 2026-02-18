import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const EstrategiasVentasApp());
}

class _GastoDraft {
  _GastoDraft({
    required this.subCategoria,
    required this.monto,
    required this.periodicidad,
    required this.esFijo,
    required this.pagoConTarjeta,
    required this.gastoHormiga,
  });

  final TextEditingController subCategoria;
  final TextEditingController monto;
  _GastoPeriodicidad periodicidad;
  bool esFijo;
  bool pagoConTarjeta;
  bool gastoHormiga;

  void dispose() {
    subCategoria.dispose();
    monto.dispose();
  }
}

class _MultiGastoModal extends StatefulWidget {
  const _MultiGastoModal({required this.categoria});

  final String categoria;

  @override
  State<_MultiGastoModal> createState() => _MultiGastoModalState();
}

class _MultiGastoModalState extends State<_MultiGastoModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _categoria;
  final List<_GastoDraft> _drafts = [];

  @override
  void initState() {
    super.initState();
    _categoria = TextEditingController(text: widget.categoria);
    _addDraft();
  }

  @override
  void dispose() {
    _categoria.dispose();
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  void _addDraft() {
    _drafts.add(
      _GastoDraft(
        subCategoria: TextEditingController(),
        monto: TextEditingController(),
        periodicidad: _GastoPeriodicidad.mensual,
        esFijo: false,
        pagoConTarjeta: false,
        gastoHormiga: false,
      ),
    );
  }

  void _removeDraft(int index) {
    final d = _drafts.removeAt(index);
    d.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final categoria = _categoria.text.trim();
    final items = <_GastoMensual>[];

    for (final d in _drafts) {
      final sub = d.subCategoria.text.trim();
      final montoRaw = d.monto.text.trim().replaceAll(',', '.');
      final monto = double.parse(montoRaw);
      items.add(
        _GastoMensual(
          categoria: categoria,
          subCategoria: sub,
          monto: monto,
          esFijo: d.esFijo,
          pagoConTarjeta: d.pagoConTarjeta,
          gastoHormiga: d.gastoHormiga,
          periodicidad: d.periodicidad,
        ),
      );
    }

    Navigator.of(context).pop(items);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottom + 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Agregar gastos',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _categoria,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.folder_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _drafts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final d = _drafts[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Gasto ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _drafts.length <= 1
                                    ? null
                                    : () {
                                        setState(() => _removeDraft(index));
                                      },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: d.subCategoria,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Sub Categoría',
                              hintText: 'Ej: Luz / Agua / Alquiler',
                              prefixIcon: Icon(Icons.label_outline),
                            ),
                            validator: (v) {
                              final text = (v ?? '').trim();
                              if (text.isEmpty) {
                                return 'Escribe una sub categoría.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<_GastoPeriodicidad>(
                            value: d.periodicidad,
                            decoration: const InputDecoration(
                              labelText: 'Periodicidad',
                              prefixIcon: Icon(Icons.calendar_month_outlined),
                            ),
                            items: _GastoPeriodicidad.values
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(_periodicidadLabel(v)),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => d.periodicidad = v);
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: d.monto,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Monto',
                              hintText: 'Ej: 25.00',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            validator: (v) {
                              final raw = (v ?? '').trim();
                              if (raw.isEmpty) return 'Ingresa un monto.';
                              final normalized = raw.replaceAll(',', '.');
                              final parsed = double.tryParse(normalized);
                              if (parsed == null) return 'Monto inválido.';
                              if (parsed < 0) return 'No puede ser negativo.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: d.esFijo,
                            onChanged: (v) => setState(() => d.esFijo = v),
                            title: const Text('Gasto fijo'),
                          ),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: d.pagoConTarjeta,
                            onChanged: (v) =>
                                setState(() => d.pagoConTarjeta = v),
                            title: const Text('Pago con tarjeta'),
                          ),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: d.gastoHormiga,
                            onChanged: (v) =>
                                setState(() => d.gastoHormiga = v),
                            title: const Text('Gasto hormiga'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => _addDraft());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar otra sub categoría'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class EstrategiasVentasApp extends StatelessWidget {
  const EstrategiasVentasApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1565C0);
    const secondary = Color(0xFF2E7D32);
    const tertiary = Color(0xFFEF6C00);

    return MaterialApp(
      title: 'Estadísticas de ventas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          secondary: secondary,
          tertiary: tertiary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F5F7),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0x332E7D32),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _validUser = 'admin';
  static const _validPass = 'admin123';

  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscure = true;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));
    final u = _userController.text.trim();
    final p = _passController.text;

    if (!mounted) return;

    if (u != _validUser || p != _validPass) {
      setState(() {
        _loading = false;
        _error = 'Usuario o clave incorrectos.';
      });
      return;
    }

    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      height: 110,
                      width: 110,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const _AnimatedDeskIllustration(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Estadísticas de ventas',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dashboard: ventas, compras y mercado',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Ingresar',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _userController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passController,
                            obscureText: _obscure,
                            onSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              labelText: 'Clave',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: _loading ? null : _login,
                              child: _loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text('Entrar'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Demo: admin / admin123',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GastosGroupedCard extends StatelessWidget {
  const _GastosGroupedCard({
    required this.gastos,
    required this.onEdit,
    required this.onDelete,
    required this.onAddToCategoria,
  });

  final List<_GastoMensual> gastos;
  final Future<void> Function(int index) onEdit;
  final void Function(int index) onDelete;
  final Future<void> Function(String categoria) onAddToCategoria;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<MapEntry<int, _GastoMensual>>>{};
    for (var i = 0; i < gastos.length; i++) {
      final g = gastos[i];
      grouped.putIfAbsent(g.categoria, () => []).add(MapEntry(i, g));
    }

    final categories = grouped.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Gastos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final cat = categories[idx];
                final entries = grouped[cat]!;
                final subtotal = entries.fold<double>(
                  0,
                  (sum, e) => sum + e.value.monto,
                );
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cat,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              onAddToCategoria(cat);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar gasto'),
                          ),
                          Text(
                            _money(subtotal),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final entry = entries[i];
                          final index = entry.key;
                          final g = entry.value;
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        g.subCategoria,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_periodicidadLabel(g.periodicidad)} • ${g.esFijo ? 'Fijo' : 'Variable'}'
                                        '${g.pagoConTarjeta ? ' • Tarjeta' : ''}'
                                        '${g.gastoHormiga ? ' • Hormiga' : ''}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _money(g.monto),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            onEdit(index);
                                          },
                                          icon: const Icon(Icons.edit_outlined),
                                        ),
                                        IconButton(
                                          onPressed: () => onDelete(index),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  final List<_IngresoMensual> _ingresos = [
    _IngresoMensual(
      etiqueta: 'Salario mensual',
      tipo: _IngresoTipo.fija,
      monto: 1200,
    ),
  ];

  final List<String> _categoriasGasto = [
    'Hogar',
    'Transporte',
    'Mercado',
    'Familia',
  ];

  final List<_GastoMensual> _gastos = [
    _GastoMensual(
      categoria: 'Hogar',
      subCategoria: 'Internet',
      monto: 45,
      esFijo: true,
      pagoConTarjeta: true,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
    ),
    _GastoMensual(
      categoria: 'Transporte',
      subCategoria: 'Gasolina',
      monto: 25,
      esFijo: false,
      pagoConTarjeta: false,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.semanal,
    ),
  ];

  double get _totalIngresos => _ingresos.fold(0, (sum, it) => sum + it.monto);

  Future<void> _addIngreso() async {
    final result = await _openIngresoModal(context);
    if (!mounted || result == null) return;
    setState(() => _ingresos.add(result));
  }

  Future<void> _editIngreso(int index) async {
    final result = await _openIngresoModal(context, initial: _ingresos[index]);
    if (!mounted || result == null) return;
    setState(() => _ingresos[index] = result);
  }

  void _deleteIngreso(int index) {
    setState(() => _ingresos.removeAt(index));
  }

  Future<void> _addGasto() async {
    final result = await _openGastoModal(context);
    if (!mounted || result == null) return;
    setState(() => _gastos.add(result));
  }

  Future<void> _editGasto(int index) async {
    final result = await _openGastoModal(context, initial: _gastos[index]);
    if (!mounted || result == null) return;
    setState(() => _gastos[index] = result);
  }

  void _deleteGasto(int index) {
    setState(() => _gastos.removeAt(index));
  }

  Future<void> _addGastosToCategoria(String categoria) async {
    final result = await _openMultiGastoModal(context, categoria: categoria);
    if (!mounted || result == null || result.isEmpty) return;
    setState(() => _gastos.addAll(result));
  }

  Future<void> _addCategoriaGasto() async {
    final result = await _openCategoriaModal(context);
    if (!mounted || result == null) return;
    final trimmed = result.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      if (!_categoriasGasto.contains(trimmed)) {
        _categoriasGasto.add(trimmed);
      }
    });
  }

  Future<void> _deleteCategoriaGasto(String categoria) async {
    final ok = await _confirmDeleteCategoria(context, categoria);
    if (ok != true) return;
    if (!mounted) return;
    setState(() {
      _categoriasGasto.remove(categoria);
      _gastos.removeWhere((g) => g.categoria == categoria);
    });
  }

  void _openIngresosScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _IngresosMensualesScreen(
          items: _ingresos,
          gastos: _gastos,
          onAdd: _addIngreso,
          onEdit: _editIngreso,
          onDelete: _deleteIngreso,
          onAddGasto: _addGasto,
          onEditGasto: _editGasto,
          onDeleteGasto: _deleteGasto,
          onAddGastosCategoria: _addGastosToCategoria,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final views = [
      _ResumenTab(
        totalIngresos: _totalIngresos,
        onOpenIngresos: _openIngresosScreen,
      ),
      _PresupuestoTab(
        ingresos: _ingresos,
        gastos: _gastos,
        categorias: _categoriasGasto,
        onAddCategoria: _addCategoriaGasto,
        onDeleteCategoria: _deleteCategoriaGasto,
        onAddToCategoria: _addGastosToCategoria,
        onEditGasto: _editGasto,
        onDeleteGasto: _deleteGasto,
      ),
      const _MercadoTab(),
      _IngresosMensualesTab(
        items: _ingresos,
        gastos: _gastos,
        onAdd: _addIngreso,
        onEdit: _editIngreso,
        onDelete: _deleteIngreso,
        onAddGasto: _addGasto,
        onEditGasto: _editGasto,
        onDeleteGasto: _deleteGasto,
        onAddGastosCategoria: _addGastosToCategoria,
      ),
      _PerfilTab(
        onLogout: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        },
      ),
    ];

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text('Resumen'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _tab = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.savings_outlined),
                title: const Text('Presupuesto'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _tab = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.show_chart_outlined),
                title: const Text('Mercado'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _tab = 2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: const Text('Ingresos mensuales'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openIngresosScreen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _tab = 4);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 28,
              width: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.show_chart,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Estadísticas de ventas'),
          ],
        ),
      ),
      body: SafeArea(child: views[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Resumen',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Presupuesto',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Mercado',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Ingresos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _PresupuestoTab extends StatelessWidget {
  const _PresupuestoTab({
    required this.ingresos,
    required this.gastos,
    required this.categorias,
    required this.onAddCategoria,
    required this.onDeleteCategoria,
    required this.onAddToCategoria,
    required this.onEditGasto,
    required this.onDeleteGasto,
  });

  final List<_IngresoMensual> ingresos;
  final List<_GastoMensual> gastos;
  final List<String> categorias;
  final Future<void> Function() onAddCategoria;
  final Future<void> Function(String categoria) onDeleteCategoria;
  final Future<void> Function(String categoria) onAddToCategoria;
  final Future<void> Function(int index) onEditGasto;
  final void Function(int index) onDeleteGasto;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalIngresos = ingresos.fold(0.0, (sum, it) => sum + it.monto);
    final totalGastos = gastos.fold(0.0, (sum, it) => sum + it.monto);
    final balance = totalIngresos - totalGastos;

    final ingresosFijos = ingresos
        .where((i) => i.tipo == _IngresoTipo.fija)
        .fold(0.0, (sum, it) => sum + it.monto);
    final ingresosVariables = ingresos
        .where((i) => i.tipo != _IngresoTipo.fija)
        .fold(0.0, (sum, it) => sum + it.monto);

    final gastosHormiga = gastos
        .where((g) => g.gastoHormiga)
        .fold(0.0, (sum, it) => sum + it.monto);
    final gastosFijos = gastos
        .where((g) => g.esFijo && !g.gastoHormiga)
        .fold(0.0, (sum, it) => sum + it.monto);
    final gastosVariables = gastos
        .where((g) => !g.esFijo && !g.gastoHormiga)
        .fold(0.0, (sum, it) => sum + it.monto);

    final cats = {...categorias, ...gastos.map((g) => g.categoria)}.toList()
      ..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [scheme.secondary, scheme.secondary.withOpacity(0.82)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Presupuesto mensual',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _money(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ingresos: ${_money(totalIngresos)}  •  Gastos: ${_money(totalGastos)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ingresos Promedio Mensuales',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        _money(totalIngresos),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (ingresos.isEmpty)
                    const Text('Aún no tienes ingresos registrados.')
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ingresos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final it = ingresos[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.etiqueta,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _tipoLabel(it.tipo),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _money(it.monto),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ingresos vs Gastos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final label = value.toInt() == 0
                                    ? 'Ingresos'
                                    : 'Gastos';
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barTouchData: BarTouchData(enabled: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: totalIngresos,
                                width: 26,
                                borderRadius: BorderRadius.circular(10),
                                rodStackItems: [
                                  BarChartRodStackItem(
                                    0,
                                    ingresosFijos,
                                    scheme.primary,
                                  ),
                                  BarChartRodStackItem(
                                    ingresosFijos,
                                    ingresosFijos + ingresosVariables,
                                    scheme.tertiary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: totalGastos,
                                width: 26,
                                borderRadius: BorderRadius.circular(10),
                                rodStackItems: [
                                  BarChartRodStackItem(
                                    0,
                                    gastosFijos,
                                    scheme.error,
                                  ),
                                  BarChartRodStackItem(
                                    gastosFijos,
                                    gastosFijos + gastosVariables,
                                    scheme.error.withOpacity(0.65),
                                  ),
                                  BarChartRodStackItem(
                                    gastosFijos + gastosVariables,
                                    gastosFijos +
                                        gastosVariables +
                                        gastosHormiga,
                                    scheme.tertiary.withOpacity(0.85),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _LegendDot(color: scheme.primary, label: 'Ingreso fijo'),
                      _LegendDot(
                        color: scheme.tertiary,
                        label: 'Ingreso variable',
                      ),
                      _LegendDot(color: scheme.error, label: 'Gasto fijo'),
                      _LegendDot(
                        color: scheme.error.withOpacity(0.65),
                        label: 'Gasto variable',
                      ),
                      _LegendDot(
                        color: scheme.tertiary.withOpacity(0.85),
                        label: 'Gasto hormiga',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.tertiary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Cuidado con los gastos hormiga: son pequeños pero se acumulan. \nRevisa esta sección y reduce lo que no sea necesario.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Detalle de gastos',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: onAddCategoria,
                        icon: const Icon(Icons.add),
                        label: const Text('Categoría'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (cats.isEmpty)
                    const Text('Agrega una categoría para comenzar.')
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final cat = cats[i];
                        final entries = <MapEntry<int, _GastoMensual>>[];
                        for (var idx = 0; idx < gastos.length; idx++) {
                          final g = gastos[idx];
                          if (g.categoria == cat) {
                            entries.add(MapEntry(idx, g));
                          }
                        }
                        final subtotal = entries.fold<double>(
                          0,
                          (sum, e) => sum + e.value.monto,
                        );
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cat,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar categoría',
                                    onPressed: () {
                                      onDeleteCategoria(cat);
                                    },
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      onAddToCategoria(cat);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Agregar'),
                                  ),
                                  Text(
                                    _money(subtotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              if (entries.isEmpty) ...[
                                const SizedBox(height: 10),
                                const Text(
                                  'Sin gastos todavía. Usa “Agregar”.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ] else ...[
                                const SizedBox(height: 10),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: entries.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, j) {
                                    final entry = entries[j];
                                    final index = entry.key;
                                    final g = entry.value;
                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.02),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  g.subCategoria,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${_periodicidadLabel(g.periodicidad)} • ${g.esFijo ? 'Fijo' : 'Variable'}'
                                                  '${g.pagoConTarjeta ? ' • Tarjeta' : ''}'
                                                  '${g.gastoHormiga ? ' • Hormiga' : ''}',
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _money(g.monto),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      onEditGasto(index);
                                                    },
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      onDeleteGasto(index);
                                                    },
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ResumenTab extends StatelessWidget {
  const _ResumenTab({
    required this.totalIngresos,
    required this.onOpenIngresos,
  });

  final double totalIngresos;
  final VoidCallback onOpenIngresos;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _KpisGrid(),
          const SizedBox(height: 14),
          _IngresosMensualesPreviewCard(
            total: totalIngresos,
            onOpen: onOpenIngresos,
          ),
          const SizedBox(height: 14),
          _CardSection(
            title: 'Ventas (últimos 7 días)',
            child: SizedBox(height: 220, child: _VentasLineChart()),
          ),
          const SizedBox(height: 14),
          _CardSection(
            title: 'Compras por categoría',
            child: SizedBox(height: 220, child: _ComprasBarChart()),
          ),
          const SizedBox(height: 14),
          _CardSection(
            title: 'Actividad reciente',
            child: const Column(
              children: [
                _ActividadTile(
                  icon: Icons.point_of_sale,
                  title: 'Venta registrada',
                  subtitle: 'Canal: retail',
                  value: '+ USD 840',
                ),
                _ActividadTile(
                  icon: Icons.shopping_cart_checkout,
                  title: 'Compra registrada',
                  subtitle: 'Inventario: +18 unidades',
                  value: '- USD 310',
                ),
                _ActividadTile(
                  icon: Icons.trending_up,
                  title: 'Señal de mercado',
                  subtitle: 'Demanda: +8% semanal',
                  value: 'OK',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MercadoTab extends StatelessWidget {
  const _MercadoTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardSection(
            title: 'Participación de mercado',
            child: SizedBox(height: 240, child: _MercadoPieChart()),
          ),
          const SizedBox(height: 14),
          _CardSection(
            title: 'Índice de mercado (simulado)',
            child: SizedBox(height: 240, child: _IndiceLineChart()),
          ),
        ],
      ),
    );
  }
}

class _PerfilTab extends StatelessWidget {
  const _PerfilTab({required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: colorScheme.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrador',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text('Perfil demo (solo frontend)'),
                      ],
                    ),
                  ),
                  Icon(Icons.verified_user, color: colorScheme.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Exportar reporte (demo)'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Configuración (demo)'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

enum _IngresoTipo { fija, variable, sinEspecificar }

enum _GastoPeriodicidad {
  diario,
  semanal,
  quincenal,
  mensual,
  bimestral,
  trimestral,
  semestral,
  anual,
}

class _GastoMensual {
  _GastoMensual({
    required this.categoria,
    required this.subCategoria,
    required this.monto,
    required this.esFijo,
    required this.pagoConTarjeta,
    required this.gastoHormiga,
    required this.periodicidad,
  });

  final String categoria;
  final String subCategoria;
  final double monto;
  final bool esFijo;
  final bool pagoConTarjeta;
  final bool gastoHormiga;
  final _GastoPeriodicidad periodicidad;

  _GastoMensual copyWith({
    String? categoria,
    String? subCategoria,
    double? monto,
    bool? esFijo,
    bool? pagoConTarjeta,
    bool? gastoHormiga,
    _GastoPeriodicidad? periodicidad,
  }) {
    return _GastoMensual(
      categoria: categoria ?? this.categoria,
      subCategoria: subCategoria ?? this.subCategoria,
      monto: monto ?? this.monto,
      esFijo: esFijo ?? this.esFijo,
      pagoConTarjeta: pagoConTarjeta ?? this.pagoConTarjeta,
      gastoHormiga: gastoHormiga ?? this.gastoHormiga,
      periodicidad: periodicidad ?? this.periodicidad,
    );
  }
}

class _IngresoMensual {
  _IngresoMensual({
    required this.etiqueta,
    required this.tipo,
    required this.monto,
  });

  final String etiqueta;
  final _IngresoTipo tipo;
  final double monto;

  _IngresoMensual copyWith({
    String? etiqueta,
    _IngresoTipo? tipo,
    double? monto,
  }) {
    return _IngresoMensual(
      etiqueta: etiqueta ?? this.etiqueta,
      tipo: tipo ?? this.tipo,
      monto: monto ?? this.monto,
    );
  }
}

class _IngresosMensualesPreviewCard extends StatelessWidget {
  const _IngresosMensualesPreviewCard({
    required this.total,
    required this.onOpen,
  });

  final double total;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.payments_outlined, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen Mensual de ingresos',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${_money(total)}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.tonal(onPressed: onOpen, child: const Text('Ver')),
          ],
        ),
      ),
    );
  }
}

class _IngresosMensualesTab extends StatelessWidget {
  const _IngresosMensualesTab({
    required this.items,
    required this.gastos,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onAddGasto,
    required this.onEditGasto,
    required this.onDeleteGasto,
    required this.onAddGastosCategoria,
  });

  final List<_IngresoMensual> items;
  final List<_GastoMensual> gastos;
  final Future<void> Function() onAdd;
  final Future<void> Function(int index) onEdit;
  final void Function(int index) onDelete;
  final Future<void> Function() onAddGasto;
  final Future<void> Function(int index) onEditGasto;
  final void Function(int index) onDeleteGasto;
  final Future<void> Function(String categoria) onAddGastosCategoria;

  @override
  Widget build(BuildContext context) {
    return _IngresosMensualesView(
      items: items,
      gastos: gastos,
      onAdd: onAdd,
      onEdit: onEdit,
      onDelete: onDelete,
      onAddGasto: onAddGasto,
      onEditGasto: onEditGasto,
      onDeleteGasto: onDeleteGasto,
      onAddGastosCategoria: onAddGastosCategoria,
    );
  }
}

class _IngresosMensualesScreen extends StatefulWidget {
  const _IngresosMensualesScreen({
    required this.items,
    required this.gastos,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onAddGasto,
    required this.onEditGasto,
    required this.onDeleteGasto,
    required this.onAddGastosCategoria,
  });

  final List<_IngresoMensual> items;
  final List<_GastoMensual> gastos;
  final Future<void> Function() onAdd;
  final Future<void> Function(int index) onEdit;
  final void Function(int index) onDelete;
  final Future<void> Function() onAddGasto;
  final Future<void> Function(int index) onEditGasto;
  final void Function(int index) onDeleteGasto;
  final Future<void> Function(String categoria) onAddGastosCategoria;

  @override
  State<_IngresosMensualesScreen> createState() =>
      _IngresosMensualesScreenState();
}

class _IngresosMensualesScreenState extends State<_IngresosMensualesScreen> {
  Future<void> _confirmDeleteGasto(int index) async {
    final ok = await _confirmDeleteIngreso(context);
    if (ok != true) return;
    _deleteGastoAndRefresh(index);
  }

  Future<void> _confirmDelete(int index) async {
    final ok = await _confirmDeleteIngreso(context);
    if (ok != true) return;
    _deleteAndRefresh(index);
  }

  Future<void> _addAndRefresh() async {
    await widget.onAdd();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _editAndRefresh(int index) async {
    await widget.onEdit(index);
    if (!mounted) return;
    setState(() {});
  }

  void _deleteAndRefresh(int index) {
    widget.onDelete(index);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _addGastoAndRefresh() async {
    await widget.onAddGasto();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _editGastoAndRefresh(int index) async {
    await widget.onEditGasto(index);
    if (!mounted) return;
    setState(() {});
  }

  void _deleteGastoAndRefresh(int index) {
    widget.onDeleteGasto(index);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _addGastosCategoriaAndRefresh(String categoria) async {
    await widget.onAddGastosCategoria(categoria);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen Mensual de ingresos')),
      body: SafeArea(
        child: _IngresosMensualesView(
          items: widget.items,
          gastos: widget.gastos,
          onAdd: _addAndRefresh,
          onEdit: _editAndRefresh,
          onDelete: _confirmDelete,
          onAddGasto: _addGastoAndRefresh,
          onEditGasto: _editGastoAndRefresh,
          onDeleteGasto: _confirmDeleteGasto,
          onAddGastosCategoria: _addGastosCategoriaAndRefresh,
        ),
      ),
    );
  }
}

enum _MensualViewMode { ingresos, gastos }

class _IngresosMensualesView extends StatefulWidget {
  const _IngresosMensualesView({
    required this.items,
    required this.gastos,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onAddGasto,
    required this.onEditGasto,
    required this.onDeleteGasto,
    required this.onAddGastosCategoria,
  });

  final List<_IngresoMensual> items;
  final List<_GastoMensual> gastos;
  final Future<void> Function() onAdd;
  final Future<void> Function(int index) onEdit;
  final void Function(int index) onDelete;
  final Future<void> Function() onAddGasto;
  final Future<void> Function(int index) onEditGasto;
  final void Function(int index) onDeleteGasto;
  final Future<void> Function(String categoria) onAddGastosCategoria;

  @override
  State<_IngresosMensualesView> createState() => _IngresosMensualesViewState();
}

class _IngresosMensualesViewState extends State<_IngresosMensualesView> {
  _MensualViewMode _mode = _MensualViewMode.ingresos;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalIngresos = widget.items.fold(0.0, (sum, it) => sum + it.monto);
    final totalGastos = widget.gastos.fold(0.0, (sum, it) => sum + it.monto);
    final isIngresos = _mode == _MensualViewMode.ingresos;
    final total = isIngresos ? totalIngresos : totalGastos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_MensualViewMode>(
            segments: const [
              ButtonSegment(
                value: _MensualViewMode.ingresos,
                label: Text('Ingresos'),
                icon: Icon(Icons.payments_outlined),
              ),
              ButtonSegment(
                value: _MensualViewMode.gastos,
                label: Text('Gastos'),
                icon: Icon(Icons.receipt_long_outlined),
              ),
            ],
            selected: <_MensualViewMode>{_mode},
            onSelectionChanged: (value) {
              setState(() => _mode = value.first);
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.82),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Balance mensual',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _money(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isIngresos
                            ? '${widget.items.length} ingreso(s) registrado(s)'
                            : '${widget.gastos.length} gasto(s) registrado(s)',
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: colorScheme.primary,
                      ),
                      onPressed: () {
                        if (isIngresos) {
                          widget.onAdd();
                        } else {
                          widget.onAddGasto();
                        }
                      },
                      child: Text(
                        isIngresos ? 'Agregar ingreso' : 'Agregar gasto',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (isIngresos && widget.items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Agrega tu primer ingreso para ver el balance.',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (!isIngresos && widget.gastos.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Agrega tu primer gasto para ver el total mensual.',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (isIngresos)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ingresos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final it = widget.items[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  it.tipo == _IngresoTipo.fija
                                      ? Icons.lock_outline
                                      : it.tipo == _IngresoTipo.variable
                                      ? Icons.swap_horiz
                                      : Icons.help_outline,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.etiqueta,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _tipoLabel(it.tipo),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _money(it.monto),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          widget.onEdit(i);
                                        },
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        onPressed: () => widget.onDelete(i),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (!isIngresos)
            _GastosGroupedCard(
              gastos: widget.gastos,
              onEdit: widget.onEditGasto,
              onDelete: widget.onDeleteGasto,
              onAddToCategoria: widget.onAddGastosCategoria,
            ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isIngresos
                        ? 'Total de Ingresos Mensuales'
                        : 'Total de Gastos Mensuales',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  _money(total),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngresoModal extends StatefulWidget {
  const _IngresoModal({this.initial});

  final _IngresoMensual? initial;

  @override
  State<_IngresoModal> createState() => _IngresoModalState();
}

class _IngresoModalState extends State<_IngresoModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _etiqueta;
  late final TextEditingController _monto;
  late _IngresoTipo _tipo;

  @override
  void initState() {
    super.initState();
    _etiqueta = TextEditingController(text: widget.initial?.etiqueta ?? '');
    _monto = TextEditingController(
      text: widget.initial == null
          ? ''
          : widget.initial!.monto.toStringAsFixed(2),
    );
    _tipo = widget.initial?.tipo ?? _IngresoTipo.sinEspecificar;
  }

  @override
  void dispose() {
    _etiqueta.dispose();
    _monto.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final parsed = double.parse(_monto.text.trim().replaceAll(',', '.'));
    final item = _IngresoMensual(
      etiqueta: _etiqueta.text.trim(),
      tipo: _tipo,
      monto: parsed,
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initial == null ? 'Agregar ingreso' : 'Editar ingreso',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _etiqueta,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Etiqueta',
                hintText: 'Ej: Salario mensual / Ganancia p2p',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return 'Escribe una etiqueta.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<_IngresoTipo>(
              value: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de ganancia',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: const [
                DropdownMenuItem(value: _IngresoTipo.fija, child: Text('Fija')),
                DropdownMenuItem(
                  value: _IngresoTipo.variable,
                  child: Text('Variable'),
                ),
                DropdownMenuItem(
                  value: _IngresoTipo.sinEspecificar,
                  child: Text('Sin especificar'),
                ),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _tipo = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _monto,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monto',
                hintText: 'Ej: 1200.00',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                final raw = (v ?? '').trim();
                if (raw.isEmpty) return 'Ingresa un monto.';
                final normalized = raw.replaceAll(',', '.');
                final parsed = double.tryParse(normalized);
                if (parsed == null) return 'Monto inválido.';
                if (parsed < 0) return 'No puede ser negativo.';
                return null;
              },
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GastoModal extends StatefulWidget {
  const _GastoModal({this.initial});

  final _GastoMensual? initial;

  @override
  State<_GastoModal> createState() => _GastoModalState();
}

class _GastoModalState extends State<_GastoModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _categoria;
  late final TextEditingController _subCategoria;
  late final TextEditingController _monto;
  late bool _esFijo;
  late bool _pagoConTarjeta;
  late bool _gastoHormiga;
  late _GastoPeriodicidad _periodicidad;

  @override
  void initState() {
    super.initState();
    _categoria = TextEditingController(text: widget.initial?.categoria ?? '');
    _subCategoria = TextEditingController(
      text: widget.initial?.subCategoria ?? '',
    );
    _monto = TextEditingController(
      text: widget.initial == null
          ? ''
          : widget.initial!.monto.toStringAsFixed(2),
    );
    _esFijo = widget.initial?.esFijo ?? false;
    _pagoConTarjeta = widget.initial?.pagoConTarjeta ?? false;
    _gastoHormiga = widget.initial?.gastoHormiga ?? false;
    _periodicidad = widget.initial?.periodicidad ?? _GastoPeriodicidad.mensual;
  }

  @override
  void dispose() {
    _categoria.dispose();
    _subCategoria.dispose();
    _monto.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final parsed = double.parse(_monto.text.trim().replaceAll(',', '.'));
    final item = _GastoMensual(
      categoria: _categoria.text.trim(),
      subCategoria: _subCategoria.text.trim(),
      monto: parsed,
      esFijo: _esFijo,
      pagoConTarjeta: _pagoConTarjeta,
      gastoHormiga: _gastoHormiga,
      periodicidad: _periodicidad,
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initial == null ? 'Agregar gasto' : 'Editar gasto',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _categoria,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                hintText: 'Ej: Hogar / Transporte / Deporte',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return 'Escribe una categoría.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subCategoria,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Sub Categoría',
                hintText: 'Ej: Gasolina / Internet / Gym',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return 'Escribe una sub categoría.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<_GastoPeriodicidad>(
              value: _periodicidad,
              decoration: const InputDecoration(
                labelText: 'Periodicidad',
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
              items: _GastoPeriodicidad.values
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(_periodicidadLabel(v)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _periodicidad = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _monto,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monto del gasto',
                hintText: 'Ej: 25.00',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                final raw = (v ?? '').trim();
                if (raw.isEmpty) return 'Ingresa un monto.';
                final normalized = raw.replaceAll(',', '.');
                final parsed = double.tryParse(normalized);
                if (parsed == null) return 'Monto inválido.';
                if (parsed < 0) return 'No puede ser negativo.';
                return null;
              },
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _esFijo,
              onChanged: (v) => setState(() => _esFijo = v),
              title: const Text('Gasto fijo'),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _pagoConTarjeta,
              onChanged: (v) => setState(() => _pagoConTarjeta = v),
              title: const Text('Pago con tarjeta'),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _gastoHormiga,
              onChanged: (v) => setState(() => _gastoHormiga = v),
              title: const Text('Gasto hormiga'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _confirmDeleteIngreso(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: const Text('¿Está seguro que desea eliminar este ingreso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );
}

Future<bool?> _confirmDeleteCategoria(BuildContext context, String categoria) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Está seguro que desea eliminar "$categoria"?\n\nTambién se eliminarán sus gastos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );
}

Future<String?> _openCategoriaModal(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Nueva categoría'),
        content: TextField(
          controller: controller,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            hintText: 'Ej: Casa/Hogar',
          ),
          onSubmitted: (_) {
            Navigator.of(ctx).pop(controller.text);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Agregar'),
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}

Future<List<_GastoMensual>?> _openMultiGastoModal(
  BuildContext context, {
  required String categoria,
}) {
  return showModalBottomSheet<List<_GastoMensual>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return _MultiGastoModal(categoria: categoria);
    },
  );
}

Future<_GastoMensual?> _openGastoModal(
  BuildContext context, {
  _GastoMensual? initial,
}) {
  return showModalBottomSheet<_GastoMensual>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return _GastoModal(initial: initial);
    },
  );
}

class _AnimatedDeskIllustration extends StatefulWidget {
  const _AnimatedDeskIllustration();

  @override
  State<_AnimatedDeskIllustration> createState() =>
      _AnimatedDeskIllustrationState();
}

class _AnimatedDeskIllustrationState extends State<_AnimatedDeskIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _DeskPainter(
            t: _controller.value,
            primary: scheme.primary,
            secondary: scheme.secondary,
            tertiary: scheme.tertiary,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _DeskPainter extends CustomPainter {
  _DeskPainter({
    required this.t,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final double t;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = (w < h ? w : h);
    final base = Offset(w / 2, h / 2);
    final bob = (0.5 - (t - 0.5).abs()) * 2;
    final y = base.dy + (-1.6 * bob);

    final bg = Paint()..color = const Color(0xFFF3F5F7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.18)),
      bg,
    );

    final shadow = Paint()..color = Colors.black.withOpacity(0.06);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(base.dx, y + s * 0.26),
        width: s * 0.72,
        height: s * 0.18,
      ),
      shadow,
    );

    final deskTop = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(base.dx, y + s * 0.16),
        width: s * 0.80,
        height: s * 0.24,
      ),
      Radius.circular(s * 0.06),
    );
    final deskPaint = Paint()..color = const Color(0xFFB9835A);
    canvas.drawRRect(deskTop, deskPaint);

    final deskEdge = Paint()..color = const Color(0xFF9A6B4A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx, y + s * 0.21),
          width: s * 0.80,
          height: s * 0.12,
        ),
        Radius.circular(s * 0.06),
      ),
      deskEdge,
    );

    final legPaint = Paint()..color = const Color(0xFF2A2F36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx - s * 0.30, y + s * 0.32),
          width: s * 0.08,
          height: s * 0.26,
        ),
        Radius.circular(s * 0.04),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx + s * 0.30, y + s * 0.32),
          width: s * 0.08,
          height: s * 0.26,
        ),
        Radius.circular(s * 0.04),
      ),
      legPaint,
    );

    final monitorFrame = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(base.dx - s * 0.20, y - s * 0.02),
        width: s * 0.34,
        height: s * 0.22,
      ),
      Radius.circular(s * 0.05),
    );
    canvas.drawRRect(monitorFrame, Paint()..color = const Color(0xFF1B1F26));

    final shimmer = (0.5 - (t - 0.5).abs()) * 2;
    final screen = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(base.dx - s * 0.20, y - s * 0.02),
        width: s * 0.30,
        height: s * 0.18,
      ),
      Radius.circular(s * 0.04),
    );
    final screenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(primary, Colors.white, 0.35 + 0.15 * shimmer)!,
          Color.lerp(primary, secondary, 0.55)!,
        ],
      ).createShader(screen.outerRect);
    canvas.drawRRect(screen, screenPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx - s * 0.20, y + s * 0.11),
          width: s * 0.10,
          height: s * 0.03,
        ),
        Radius.circular(s * 0.03),
      ),
      Paint()..color = const Color(0xFF1B1F26),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx - s * 0.20, y + s * 0.14),
          width: s * 0.16,
          height: s * 0.02,
        ),
        Radius.circular(s * 0.03),
      ),
      Paint()..color = const Color(0xFF1B1F26),
    );

    final laptop = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(base.dx + s * 0.06, y + s * 0.12),
        width: s * 0.30,
        height: s * 0.12,
      ),
      Radius.circular(s * 0.04),
    );
    canvas.drawRRect(laptop, Paint()..color = const Color(0xFF4B5563));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx + s * 0.06, y + s * 0.10),
          width: s * 0.26,
          height: s * 0.07,
        ),
        Radius.circular(s * 0.03),
      ),
      Paint()..color = const Color(0xFF93A3B8),
    );

    final typing = (t * 2) % 1.0;
    final keyPulse =
        0.35 + 0.25 * (typing < 0.5 ? typing * 2 : (1 - typing) * 2);
    final keys = Paint()..color = Colors.white.withOpacity(keyPulse);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx + s * 0.06, y + s * 0.16),
          width: s * 0.20,
          height: s * 0.04,
        ),
        Radius.circular(s * 0.02),
      ),
      keys,
    );

    final person = Paint()..color = const Color(0xFF2A2F36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx + s * 0.22, y + s * 0.08),
          width: s * 0.20,
          height: s * 0.22,
        ),
        Radius.circular(s * 0.09),
      ),
      person,
    );

    final skin = Paint()..color = const Color(0xFFF2C7A5);
    canvas.drawCircle(Offset(base.dx + s * 0.24, y - s * 0.02), s * 0.07, skin);

    final hair = Paint()..color = const Color(0xFF1B1F26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx + s * 0.24, y - s * 0.04),
          width: s * 0.15,
          height: s * 0.09,
        ),
        Radius.circular(s * 0.06),
      ),
      hair,
    );

    final glasses = Paint()..color = tertiary.withOpacity(0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx + s * 0.22, y - s * 0.02),
          width: s * 0.06,
          height: s * 0.04,
        ),
        Radius.circular(s * 0.015),
      ),
      glasses,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx + s * 0.27, y - s * 0.02),
          width: s * 0.06,
          height: s * 0.04,
        ),
        Radius.circular(s * 0.015),
      ),
      glasses,
    );

    final arm = Paint()..color = const Color(0xFF2D3748);
    final armY = y + s * 0.10 + (0.8 * bob);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx + s * 0.18, armY),
          width: s * 0.12,
          height: s * 0.04,
        ),
        Radius.circular(s * 0.03),
      ),
      arm,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx + s * 0.12, armY + s * 0.03),
          width: s * 0.14,
          height: s * 0.04,
        ),
        Radius.circular(s * 0.03),
      ),
      arm,
    );
  }

  @override
  bool shouldRepaint(covariant _DeskPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.tertiary != tertiary;
  }
}

Future<_IngresoMensual?> _openIngresoModal(
  BuildContext context, {
  _IngresoMensual? initial,
}) {
  return showModalBottomSheet<_IngresoMensual>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return _IngresoModal(initial: initial);
    },
  );
}

String _tipoLabel(_IngresoTipo tipo) {
  switch (tipo) {
    case _IngresoTipo.fija:
      return 'Fija';
    case _IngresoTipo.variable:
      return 'Variable';
    case _IngresoTipo.sinEspecificar:
      return 'Sin especificar';
  }
}

String _periodicidadLabel(_GastoPeriodicidad v) {
  switch (v) {
    case _GastoPeriodicidad.diario:
      return 'Diario';
    case _GastoPeriodicidad.semanal:
      return 'Semanal';
    case _GastoPeriodicidad.quincenal:
      return 'Quincenal';
    case _GastoPeriodicidad.mensual:
      return 'Mensual';
    case _GastoPeriodicidad.bimestral:
      return 'Bimestral';
    case _GastoPeriodicidad.trimestral:
      return 'Trimestral';
    case _GastoPeriodicidad.semestral:
      return 'Semestral';
    case _GastoPeriodicidad.anual:
      return 'Anual';
  }
}

String _money(double value) {
  final v = value.toStringAsFixed(2);
  return 'USD $v';
}

class _KpisGrid extends StatelessWidget {
  const _KpisGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      _Kpi(
        title: 'Ventas (hoy)',
        value: 'USD 4,820',
        delta: '+12.4%',
        icon: Icons.point_of_sale,
        color: Color(0xFF1565C0),
      ),
      _Kpi(
        title: 'Compras (hoy)',
        value: 'USD 2,110',
        delta: '-3.1%',
        icon: Icons.shopping_cart,
        color: Color(0xFF6A1B9A),
      ),
      _Kpi(
        title: 'Margen',
        value: '28.6%',
        delta: '+1.8%',
        icon: Icons.percent,
        color: Color(0xFF2E7D32),
      ),
      _Kpi(
        title: 'Mercado',
        value: 'Estable',
        delta: 'Volatilidad media',
        icon: Icons.assessment_outlined,
        color: Color(0xFFEF6C00),
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: items[0]),
            const SizedBox(width: 12),
            Expanded(child: items[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: items[2]),
            const SizedBox(width: 12),
            Expanded(child: items[3]),
          ],
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.title,
    required this.value,
    required this.delta,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String delta;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    delta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActividadTile extends StatelessWidget {
  const _ActividadTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _VentasLineChart extends StatelessWidget {
  const _VentasLineChart();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const points = <FlSpot>[
      FlSpot(0, 2.1),
      FlSpot(1, 2.4),
      FlSpot(2, 2.0),
      FlSpot(3, 2.9),
      FlSpot(4, 3.2),
      FlSpot(5, 3.0),
      FlSpot(6, 3.6),
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 34),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, meta) {
                const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            barWidth: 3,
            color: colorScheme.primary,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withOpacity(0.12),
            ),
          ),
        ],
        minY: 1.6,
        maxY: 4.0,
      ),
    );
  }
}

class _ComprasBarChart extends StatelessWidget {
  const _ComprasBarChart();

  @override
  Widget build(BuildContext context) {
    BarChartGroupData bar(int x, double y, Color color) {
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            width: 18,
            borderRadius: BorderRadius.circular(6),
            color: color,
          ),
        ],
      );
    }

    final groups = <BarChartGroupData>[
      bar(0, 5.5, const Color(0xFF1565C0)),
      bar(1, 4.2, const Color(0xFF6A1B9A)),
      bar(2, 3.3, const Color(0xFF2E7D32)),
      bar(3, 2.4, const Color(0xFFEF6C00)),
    ];

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 34),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                const labels = ['Móvil', 'Hogar', 'Alim', 'Otros'];
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
        ),
        barGroups: groups,
        maxY: 6.0,
      ),
    );
  }
}

class _MercadoPieChart extends StatelessWidget {
  const _MercadoPieChart();

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[
      PieChartSectionData(
        value: 42,
        title: '42%',
        color: const Color(0xFF1565C0),
        radius: 70,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      PieChartSectionData(
        value: 28,
        title: '28%',
        color: const Color(0xFF6A1B9A),
        radius: 62,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      PieChartSectionData(
        value: 18,
        title: '18%',
        color: const Color(0xFF2E7D32),
        radius: 58,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      PieChartSectionData(
        value: 12,
        title: '12%',
        color: const Color(0xFFEF6C00),
        radius: 54,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    ];

    return PieChart(
      PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 0),
    );
  }
}

class _IndiceLineChart extends StatelessWidget {
  const _IndiceLineChart();

  @override
  Widget build(BuildContext context) {
    const points = <FlSpot>[
      FlSpot(0, 98),
      FlSpot(1, 102),
      FlSpot(2, 101),
      FlSpot(3, 104),
      FlSpot(4, 107),
      FlSpot(5, 105),
      FlSpot(6, 110),
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, meta) {
                const labels = [
                  'Ene',
                  'Feb',
                  'Mar',
                  'Abr',
                  'May',
                  'Jun',
                  'Jul',
                ];
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            barWidth: 3,
            color: const Color(0xFF1565C0),
            dotData: const FlDotData(show: false),
          ),
        ],
        minY: 94,
        maxY: 114,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
