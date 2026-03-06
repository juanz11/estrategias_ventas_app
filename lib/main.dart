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
      title: 'Balance Mensual',
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
                    'Balance Mensual',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Control de presupuesto e ingresos',
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

  @override
  void initState() {
    super.initState();
    _verificarDeudasHoy();
  }

  final List<_IngresoMensual> _ingresos = [
    // Enero 2026
    _IngresoMensual(
      etiqueta: 'Salario mensual',
      tipo: _IngresoTipo.fija,
      monto: 1200,
      mes: DateTime(2026, 1, 15),
    ),
    _IngresoMensual(
      etiqueta: 'Freelance',
      tipo: _IngresoTipo.variable,
      monto: 350,
      mes: DateTime(2026, 1, 20),
    ),
    // Diciembre 2025
    _IngresoMensual(
      etiqueta: 'Salario mensual',
      tipo: _IngresoTipo.fija,
      monto: 1200,
      mes: DateTime(2025, 12, 15),
    ),
    _IngresoMensual(
      etiqueta: 'Bono',
      tipo: _IngresoTipo.variable,
      monto: 500,
      mes: DateTime(2025, 12, 25),
    ),
    // Noviembre 2025
    _IngresoMensual(
      etiqueta: 'Salario mensual',
      tipo: _IngresoTipo.fija,
      monto: 1200,
      mes: DateTime(2025, 11, 15),
    ),
    // Octubre 2025
    _IngresoMensual(
      etiqueta: 'Salario mensual',
      tipo: _IngresoTipo.fija,
      monto: 1200,
      mes: DateTime(2025, 10, 15),
    ),
    _IngresoMensual(
      etiqueta: 'Venta',
      tipo: _IngresoTipo.variable,
      monto: 280,
      mes: DateTime(2025, 10, 22),
    ),
  ];

  final List<String> _categoriasGasto = [
    'Hogar',
    'Transporte',
    'Alimentación',
    'Familia',
  ];

  final List<_GastoMensual> _gastos = [
    // Enero 2026
    _GastoMensual(
      categoria: 'Hogar',
      subCategoria: 'Internet',
      monto: 45,
      esFijo: true,
      pagoConTarjeta: true,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2026, 1, 5),
    ),
    _GastoMensual(
      categoria: 'Transporte',
      subCategoria: 'Gasolina',
      monto: 80,
      esFijo: false,
      pagoConTarjeta: false,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2026, 1, 10),
    ),
    _GastoMensual(
      categoria: 'Alimentación',
      subCategoria: 'Supermercado',
      monto: 320,
      esFijo: false,
      pagoConTarjeta: true,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2026, 1, 12),
    ),
    // Diciembre 2025
    _GastoMensual(
      categoria: 'Hogar',
      subCategoria: 'Internet',
      monto: 45,
      esFijo: true,
      pagoConTarjeta: true,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2025, 12, 5),
    ),
    _GastoMensual(
      categoria: 'Transporte',
      subCategoria: 'Gasolina',
      monto: 75,
      esFijo: false,
      pagoConTarjeta: false,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2025, 12, 8),
    ),
    _GastoMensual(
      categoria: 'Alimentación',
      subCategoria: 'Supermercado',
      monto: 380,
      esFijo: false,
      pagoConTarjeta: true,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2025, 12, 10),
    ),
    _GastoMensual(
      categoria: 'Familia',
      subCategoria: 'Regalos navidad',
      monto: 250,
      esFijo: false,
      pagoConTarjeta: true,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2025, 12, 20),
    ),
    // Noviembre 2025
    _GastoMensual(
      categoria: 'Hogar',
      subCategoria: 'Internet',
      monto: 45,
      esFijo: true,
      pagoConTarjeta: true,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2025, 11, 5),
    ),
    _GastoMensual(
      categoria: 'Transporte',
      subCategoria: 'Gasolina',
      monto: 70,
      esFijo: false,
      pagoConTarjeta: false,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2025, 11, 8),
    ),
    _GastoMensual(
      categoria: 'Alimentación',
      subCategoria: 'Supermercado',
      monto: 300,
      esFijo: false,
      pagoConTarjeta: true,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2025, 11, 12),
    ),
    // Octubre 2025
    _GastoMensual(
      categoria: 'Hogar',
      subCategoria: 'Internet',
      monto: 45,
      esFijo: true,
      pagoConTarjeta: true,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2025, 10, 5),
    ),
    _GastoMensual(
      categoria: 'Transporte',
      subCategoria: 'Gasolina',
      monto: 85,
      esFijo: false,
      pagoConTarjeta: false,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2025, 10, 10),
    ),
    _GastoMensual(
      categoria: 'Alimentación',
      subCategoria: 'Supermercado',
      monto: 340,
      esFijo: false,
      pagoConTarjeta: true,
      gastoHormiga: false,
      periodicidad: _GastoPeriodicidad.mensual,
      mes: DateTime(2025, 10, 15),
    ),
  ];

  final List<_Deuda> _deudas = [
    _Deuda(
      nombre: 'Juan Pérez',
      monto: 500,
      tipo: _TipoDeuda.porCobrar,
      descripcion: 'Préstamo personal',
      fecha: DateTime(2026, 1, 10),
    ),
    _Deuda(
      nombre: 'María García',
      monto: 300,
      tipo: _TipoDeuda.porCobrar,
      descripcion: 'Venta a crédito',
      fecha: DateTime(2026, 1, 15),
    ),
    _Deuda(
      nombre: 'Banco Nacional',
      monto: 2500,
      tipo: _TipoDeuda.porPagar,
      descripcion: 'Préstamo personal',
      fecha: DateTime(2025, 12, 1),
    ),
    _Deuda(
      nombre: 'Tienda XYZ',
      monto: 450,
      tipo: _TipoDeuda.porPagar,
      descripcion: 'Compra a crédito',
      fecha: DateTime(2026, 1, 5),
    ),
    _Deuda(
      nombre: 'Carlos López',
      monto: 200,
      tipo: _TipoDeuda.porPagar,
      descripcion: 'Préstamo amigo',
      fecha: DateTime(2026, 1, 20),
    ),
    // Deuda para HOY (se mostrará alerta al iniciar)
    _Deuda(
      nombre: 'Pago Urgente',
      monto: 150,
      tipo: _TipoDeuda.porPagar,
      descripcion: 'Pago pendiente de hoy',
      fecha: DateTime.now(),
    ),
    _Deuda(
      nombre: 'Cobro Pendiente',
      monto: 250,
      tipo: _TipoDeuda.porCobrar,
      descripcion: 'Cliente debe pagar hoy',
      fecha: DateTime.now(),
    ),
  ];

  double get _totalIngresos => _ingresos.fold(0, (sum, it) => sum + it.monto);

  double get _totalDeudasPorPagar => _deudas
      .where((d) => d.tipo == _TipoDeuda.porPagar)
      .fold(0.0, (sum, d) => sum + d.monto);

  double get _totalDeudasPorCobrar => _deudas
      .where((d) => d.tipo == _TipoDeuda.porCobrar)
      .fold(0.0, (sum, d) => sum + d.monto);

  void _openDeudasScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DeudasScreen(
          deudas: _deudas,
          onAdd: _addDeuda,
          onEdit: _editDeuda,
          onDelete: _deleteDeuda,
        ),
      ),
    );
  }

  Future<void> _addDeuda() async {
    final result = await _openDeudaModal(context);
    if (!mounted || result == null) return;
    setState(() => _deudas.add(result));
    
    // Verificar si la deuda es para hoy
    final hoy = DateTime.now();
    final esHoy = result.fecha.year == hoy.year &&
        result.fecha.month == hoy.month &&
        result.fecha.day == hoy.day;
    
    if (esHoy) {
      _mostrarAlertaDeuda(result);
    }
  }

  Future<void> _editDeuda(int index) async {
    final result = await _openDeudaModal(context, initial: _deudas[index]);
    if (!mounted || result == null) return;
    setState(() => _deudas[index] = result);
  }

  void _deleteDeuda(int index) {
    setState(() => _deudas.removeAt(index));
  }

  void _mostrarAlertaDeuda(_Deuda deuda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Recordatorio de Deuda'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deuda.tipo == _TipoDeuda.porPagar
                  ? 'Tienes una deuda por pagar HOY'
                  : 'Tienes una deuda por cobrar HOY',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: deuda.tipo == _TipoDeuda.porPagar
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Nombre:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          deuda.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Monto:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _money(deuda.monto),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: deuda.tipo == _TipoDeuda.porPagar
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (deuda.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      deuda.descripcion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _verificarDeudasHoy() {
    final hoy = DateTime.now();
    final deudasHoy = _deudas.where((deuda) {
      return deuda.fecha.year == hoy.year &&
          deuda.fecha.month == hoy.month &&
          deuda.fecha.day == hoy.day;
    }).toList();

    if (deudasHoy.isNotEmpty) {
      // Mostrar alerta después de que se construya el widget
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarAlertasDeudasHoy(deudasHoy);
      });
    }
  }

  void _mostrarAlertasDeudasHoy(List<_Deuda> deudasHoy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text('Recordatorios (${deudasHoy.length})'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tienes deudas para HOY:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              ...deudasHoy.map((deuda) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: deuda.tipo == _TipoDeuda.porPagar
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: deuda.tipo == _TipoDeuda.porPagar
                          ? Colors.red.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            deuda.tipo == _TipoDeuda.porPagar
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color: deuda.tipo == _TipoDeuda.porPagar
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deuda.tipo == _TipoDeuda.porPagar
                                ? 'Por Pagar'
                                : 'Por Cobrar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: deuda.tipo == _TipoDeuda.porPagar
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        deuda.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _money(deuda.monto),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: deuda.tipo == _TipoDeuda.porPagar
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                      if (deuda.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          deuda.descripcion,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

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

  Future<void> _deleteGastoConfirmed(int index) async {
    final ok = await _confirmDeleteGasto(context);
    if (ok != true) return;
    if (!mounted) return;
    _deleteGasto(index);
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
        ingresos: _ingresos,
        gastos: _gastos,
        onOpenIngresos: _openIngresosScreen,
      ),
      _PresupuestoTab(
        ingresos: _ingresos,
        gastos: _gastos,
        ingresosReales: _totalIngresos,
        categorias: _categoriasGasto,
        onAddIngreso: _addIngreso,
        onEditIngreso: _editIngreso,
        onDeleteIngreso: _deleteIngreso,
        onAddCategoria: _addCategoriaGasto,
        onDeleteCategoria: _deleteCategoriaGasto,
        onAddToCategoria: _addGastosToCategoria,
        onEditGasto: _editGasto,
        onDeleteGasto: _deleteGastoConfirmed,
      ),
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
      _EstadisticasTab(
        ingresos: _ingresos,
        gastos: _gastos,
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
                leading: const Icon(Icons.payments_outlined),
                title: const Text('Operaciones'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openIngresosScreen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Estadísticas'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _tab = 3);
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_outlined),
                title: const Text('Deudas Generales'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openDeudasScreen();
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
            const Text('Balance Mensual'),
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
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Operaciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
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
    required this.ingresosReales,
    required this.categorias,
    required this.onAddIngreso,
    required this.onEditIngreso,
    required this.onDeleteIngreso,
    required this.onAddCategoria,
    required this.onDeleteCategoria,
    required this.onAddToCategoria,
    required this.onEditGasto,
    required this.onDeleteGasto,
  });

  final List<_IngresoMensual> ingresos;
  final List<_GastoMensual> gastos;
  final double ingresosReales;
  final List<String> categorias;
  final Future<void> Function() onAddIngreso;
  final Future<void> Function(int index) onEditIngreso;
  final void Function(int index) onDeleteIngreso;
  final Future<void> Function() onAddCategoria;
  final Future<void> Function(String categoria) onDeleteCategoria;
  final Future<void> Function(String categoria) onAddToCategoria;
  final Future<void> Function(int index) onEditGasto;
  final Future<void> Function(int index) onDeleteGasto;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalIngresos = ingresos.fold(0.0, (sum, it) => sum + it.monto);
    final totalGastos = gastos.fold(0.0, (sum, it) => sum + it.monto);
    final balance = totalIngresos - totalGastos;

    final baseMax = totalIngresos > totalGastos ? totalIngresos : totalGastos;
    final chartGap = (baseMax * 0.02).clamp(4.0, 22.0);
    final displayIngresosTotal = totalIngresos + chartGap;
    final displayGastosTotal = totalGastos + (chartGap * 2);
    final displayMax = displayIngresosTotal > displayGastosTotal
        ? displayIngresosTotal
        : displayGastosTotal;

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
                          'Ingresos Presupuestados',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: onAddIngreso,
                        icon: const Icon(Icons.add),
                        label: const Text('Ingreso'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ${_money(totalIngresos)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                      fontSize: 16,
                    ),
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
                                        onPressed: () => onEditIngreso(i),
                                        icon: const Icon(Icons.edit_outlined),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () => onDeleteIngreso(i),
                                        icon: const Icon(Icons.delete_outline),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
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
          const SizedBox(height: 14),
          _CardSection(
            title: 'Distribución de Ingresos Presupuestados',
            child: SizedBox(
              height: 200,
              child: _DistribucionIngresosChart(ingresos: ingresos),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: BarChart(
                      swapAnimationDuration: const Duration(milliseconds: 320),
                      swapAnimationCurve: Curves.easeOutCubic,
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: displayMax * 1.15,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: (displayMax / 4).clamp(
                            1,
                            double.infinity,
                          ),
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.black.withOpacity(0.06),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            left: BorderSide(color: Colors.black, width: 1.2),
                            bottom: BorderSide(color: Colors.black, width: 1.2),
                            top: BorderSide(color: Colors.black, width: 1.2),
                            right: BorderSide(color: Colors.black, width: 1.2),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 44,
                              interval: (displayMax / 4).clamp(
                                1,
                                double.infinity,
                              ),
                              getTitlesWidget: (value, meta) {
                                String fmt(double v) {
                                  if (v >= 1000000) {
                                    return '${(v / 1000000).toStringAsFixed(1)}M';
                                  }
                                  if (v >= 1000) {
                                    return '${(v / 1000).toStringAsFixed(1)}k';
                                  }
                                  return v.toStringAsFixed(0);
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    fmt(value),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              },
                            ),
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
                        barTouchData: BarTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 12,
                            tooltipPadding: const EdgeInsets.all(10),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              if (group.x == 0) {
                                return BarTooltipItem(
                                  'Ingresos\n',
                                  const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Fijo: ${_money(ingresosFijos)}\n',
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'Variable: ${_money(ingresosVariables)}\n',
                                      style: TextStyle(
                                        color: scheme.tertiary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Total: ${_money(totalIngresos)}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return BarTooltipItem(
                                'Gastos\n',
                                const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Fijo: ${_money(gastosFijos)}\n',
                                    style: TextStyle(
                                      color: scheme.error,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'Variable: ${_money(gastosVariables)}\n',
                                    style: TextStyle(
                                      color: scheme.error.withOpacity(0.75),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Hormiga: ${_money(gastosHormiga)}\n',
                                    style: TextStyle(
                                      color: scheme.tertiary.withOpacity(0.9),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Total: ${_money(totalGastos)}',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: displayIngresosTotal,
                                width: 28,
                                borderRadius: BorderRadius.zero,
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: displayMax * 1.15,
                                  color: Colors.black.withOpacity(0.03),
                                ),
                                rodStackItems: [
                                  BarChartRodStackItem(
                                    0,
                                    ingresosFijos,
                                    scheme.primary,
                                  ),
                                  BarChartRodStackItem(
                                    ingresosFijos,
                                    ingresosFijos + chartGap,
                                    Colors.black,
                                  ),
                                  BarChartRodStackItem(
                                    ingresosFijos + chartGap,
                                    ingresosFijos +
                                        chartGap +
                                        ingresosVariables,
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
                                toY: displayGastosTotal,
                                width: 28,
                                borderRadius: BorderRadius.zero,
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: displayMax * 1.15,
                                  color: Colors.black.withOpacity(0.03),
                                ),
                                rodStackItems: [
                                  BarChartRodStackItem(
                                    0,
                                    gastosFijos,
                                    scheme.error,
                                  ),
                                  BarChartRodStackItem(
                                    gastosFijos,
                                    gastosFijos + chartGap,
                                    Colors.black,
                                  ),
                                  BarChartRodStackItem(
                                    gastosFijos + chartGap,
                                    gastosFijos + chartGap + gastosVariables,
                                    scheme.error.withOpacity(0.65),
                                  ),
                                  BarChartRodStackItem(
                                    gastosFijos + chartGap + gastosVariables,
                                    gastosFijos +
                                        (chartGap * 2) +
                                        gastosVariables,
                                    Colors.black,
                                  ),
                                  BarChartRodStackItem(
                                    gastosFijos +
                                        (chartGap * 2) +
                                        gastosVariables,
                                    gastosFijos +
                                        (chartGap * 2) +
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
          _CardSection(
            title: 'Comparación: Presupuesto vs Ingresos Reales',
            child: SizedBox(
              height: 280,
              child: _ComparacionIngresosBarChart(
                presupuesto: totalIngresos,
                ingresosReales: ingresosReales,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _CardSection(
            title: 'Tendencia: Presupuesto vs Realidad',
            child: SizedBox(
              height: 240,
              child: _TendenciaComparacionChart(
                presupuesto: totalIngresos,
                ingresosReales: ingresosReales,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _CardSection(
            title: 'Comparación: Presupuesto vs Realidad',
            child: SizedBox(
              height: 320,
              child: _ComparacionPresupuestoRealChart(
                presupuestoIngresos: totalIngresos,
                ingresosReales: ingresosReales,
                presupuestoGastos: totalGastos,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

class _EstadisticasTab extends StatefulWidget {
  const _EstadisticasTab({
    required this.ingresos,
    required this.gastos,
  });

  final List<_IngresoMensual> ingresos;
  final List<_GastoMensual> gastos;

  @override
  State<_EstadisticasTab> createState() => _EstadisticasTabState();
}

class _EstadisticasTabState extends State<_EstadisticasTab> {
  DateTime? _mesSeleccionado;
  bool _verAnual = false;

  @override
  void initState() {
    super.initState();
    _mesSeleccionado = DateTime.now();
  }

  List<DateTime> _obtenerMesesDisponibles() {
    final meses = <DateTime>{};
    for (final ingreso in widget.ingresos) {
      meses.add(DateTime(ingreso.mes.year, ingreso.mes.month));
    }
    for (final gasto in widget.gastos) {
      meses.add(DateTime(gasto.mes.year, gasto.mes.month));
    }
    final lista = meses.toList()..sort((a, b) => b.compareTo(a));
    return lista;
  }

  Map<String, double> _calcularDatosMes(DateTime mes) {
    final ingresosDelMes = widget.ingresos.where((i) =>
        i.mes.year == mes.year && i.mes.month == mes.month);
    final gastosDelMes = widget.gastos.where((g) =>
        g.mes.year == mes.year && g.mes.month == mes.month);

    final totalIngresos = ingresosDelMes.fold(0.0, (sum, i) => sum + i.monto);
    final totalGastos = gastosDelMes.fold(0.0, (sum, g) => sum + g.monto);

    return {
      'ingresos': totalIngresos,
      'gastos': totalGastos,
      'balance': totalIngresos - totalGastos,
    };
  }

  List<Map<String, dynamic>> _calcularDatosAnuales(int anio) {
    final datos = <Map<String, dynamic>>[];
    for (int mes = 1; mes <= 12; mes++) {
      final fecha = DateTime(anio, mes);
      final datosMes = _calcularDatosMes(fecha);
      datos.add({
        'mes': mes,
        'fecha': fecha,
        ...datosMes,
      });
    }
    return datos;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mesesDisponibles = _obtenerMesesDisponibles();
    
    if (mesesDisponibles.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    if (_mesSeleccionado == null || !mesesDisponibles.any((m) =>
        m.year == _mesSeleccionado!.year && m.month == _mesSeleccionado!.month)) {
      _mesSeleccionado = mesesDisponibles.first;
    }

    // Presupuesto estimado (simulado)
    const presupuestoIngresos = 1500.0;
    const presupuestoGastos = 800.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                          'Selector de período',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Switch(
                        value: _verAnual,
                        onChanged: (value) {
                          setState(() => _verAnual = value);
                        },
                      ),
                      Text(
                        _verAnual ? 'Anual' : 'Mensual',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!_verAnual) ...[
                    DropdownButtonFormField<DateTime>(
                      value: _mesSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Seleccionar mes',
                        border: OutlineInputBorder(),
                      ),
                      items: mesesDisponibles.map((mes) {
                        return DropdownMenuItem(
                          value: mes,
                          child: Text(_formatearMes(mes)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _mesSeleccionado = value);
                        }
                      },
                    ),
                  ] else ...[
                    DropdownButtonFormField<int>(
                      value: _mesSeleccionado!.year,
                      decoration: const InputDecoration(
                        labelText: 'Seleccionar año',
                        border: OutlineInputBorder(),
                      ),
                      items: () {
                        final anios = mesesDisponibles
                            .map((m) => m.year)
                            .toSet()
                            .toList();
                        anios.sort((a, b) => b.compareTo(a));
                        return anios.map((anio) {
                          return DropdownMenuItem(
                            value: anio,
                            child: Text(anio.toString()),
                          );
                        }).toList();
                      }(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _mesSeleccionado = DateTime(value, 1));
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!_verAnual) ...[
            _buildComparacionMensual(
              scheme,
              _mesSeleccionado!,
              presupuestoIngresos,
              presupuestoGastos,
            ),
          ] else ...[
            _buildComparacionAnual(
              scheme,
              _mesSeleccionado!.year,
              presupuestoIngresos,
              presupuestoGastos,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComparacionMensual(
    ColorScheme scheme,
    DateTime mes,
    double presupuestoIngresos,
    double presupuestoGastos,
  ) {
    final datos = _calcularDatosMes(mes);
    final ingresosReales = datos['ingresos']!;
    final gastosReales = datos['gastos']!;
    final balanceReal = datos['balance']!;
    final balancePresupuesto = presupuestoIngresos - presupuestoGastos;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Resumen de ${_formatearMes(mes)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        'Ingresos',
                        ingresosReales,
                        presupuestoIngresos,
                        scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        'Gastos',
                        gastosReales,
                        presupuestoGastos,
                        scheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: balanceReal >= 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Balance Real',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _money(balanceReal),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: balanceReal >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Presupuesto: ${_money(balancePresupuesto)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _CardSection(
          title: 'Comparación: Presupuesto vs Real',
          child: SizedBox(
            height: 280,
            child: _ComparacionMensualChart(
              presupuestoIngresos: presupuestoIngresos,
              presupuestoGastos: presupuestoGastos,
              ingresosReales: ingresosReales,
              gastosReales: gastosReales,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparacionAnual(
    ColorScheme scheme,
    int anio,
    double presupuestoIngresos,
    double presupuestoGastos,
  ) {
    final datosAnuales = _calcularDatosAnuales(anio);
    final totalIngresosReales = datosAnuales.fold(0.0, (sum, d) => sum + d['ingresos']);
    final totalGastosReales = datosAnuales.fold(0.0, (sum, d) => sum + d['gastos']);
    final totalPresupuestoIngresos = presupuestoIngresos * 12;
    final totalPresupuestoGastos = presupuestoGastos * 12;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Resumen anual $anio',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        'Ingresos',
                        totalIngresosReales,
                        totalPresupuestoIngresos,
                        scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        'Gastos',
                        totalGastosReales,
                        totalPresupuestoGastos,
                        scheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _CardSection(
          title: 'Evolución anual $anio',
          child: SizedBox(
            height: 300,
            child: _EvolucionAnualChart(
              datosAnuales: datosAnuales,
              presupuestoIngresos: presupuestoIngresos,
              presupuestoGastos: presupuestoGastos,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String titulo, double real, double presupuesto, Color color) {
    final porcentaje = presupuesto > 0 ? (real / presupuesto * 100) : 0.0;
    final diferencia = real - presupuesto;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _money(real),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Presup: ${_money(presupuesto)}',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                diferencia >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: diferencia >= 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '${porcentaje.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: diferencia >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatearMes(DateTime fecha) {
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${meses[fecha.month - 1]} ${fecha.year}';
  }
}

class _ResumenTab extends StatelessWidget {
  const _ResumenTab({
    required this.totalIngresos,
    required this.ingresos,
    required this.gastos,
    required this.onOpenIngresos,
  });

  final double totalIngresos;
  final List<_IngresoMensual> ingresos;
  final List<_GastoMensual> gastos;
  final VoidCallback onOpenIngresos;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    // Calcular ganancias presupuestadas (ingresos - gastos del presupuesto)
    final totalIngresosPresupuesto = ingresos.fold(0.0, (sum, i) => sum + i.monto);
    final totalGastosPresupuesto = gastos.fold(0.0, (sum, g) => sum + g.monto);
    final gananciasPresupuestadas = totalIngresosPresupuesto - totalGastosPresupuesto;
    
    // Calcular ganancias reales (ingresos reales - gastos reales)
    // Por ahora usamos los mismos datos, pero en producción vendrían de Operaciones
    final gananciasReales = totalIngresos - totalGastosPresupuesto;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _KpisGrid(),
          const SizedBox(height: 14),
          // Card de comparación de ganancias
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
                          'Ganancias del Mes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.trending_up,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Presupuestadas',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _money(gananciasPresupuestadas),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ingresos: ${_money(totalIngresosPresupuesto)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                'Gastos: ${_money(totalGastosPresupuesto)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reales',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _money(gananciasReales),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: scheme.tertiary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ingresos: ${_money(totalIngresos)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                'Gastos: ${_money(totalGastosPresupuesto)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (gananciasReales >= gananciasPresupuestadas)
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (gananciasReales >= gananciasPresupuestadas)
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_outlined,
                          color: (gananciasReales >= gananciasPresupuestadas)
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (gananciasReales >= gananciasPresupuestadas)
                                ? '¡Excelente! Superaste tu meta de ganancias'
                                : 'Falta ${_money(gananciasPresupuestadas - gananciasReales)} para alcanzar tu meta',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: (gananciasReales >= gananciasPresupuestadas)
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _IngresosMensualesPreviewCard(
            total: totalIngresos,
            onOpen: onOpenIngresos,
          ),
          const SizedBox(height: 14),
          _CardSection(
            title: 'Comparación: Ganancias Presupuestadas vs Reales',
            child: SizedBox(
              height: 240,
              child: _ComparacionGananciasChart(
                presupuestadas: gananciasPresupuestadas,
                reales: gananciasReales,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _CardSection(
            title: 'Balance mensual (últimos 6 meses)',
            child: SizedBox(height: 220, child: _BalanceMensualChart()),
          ),
          const SizedBox(height: 14),
          _CardSection(
            title: 'Distribución de gastos',
            child: SizedBox(height: 220, child: _DistribucionGastosChart()),
          ),
          const SizedBox(height: 14),
          _CardSection(
            title: 'Actividad reciente',
            child: const Column(
              children: [
                _ActividadTile(
                  icon: Icons.attach_money,
                  title: 'Ingreso registrado',
                  subtitle: 'Tipo: Fijo',
                  value: '+ USD 840',
                ),
                _ActividadTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Gasto registrado',
                  subtitle: 'Categoría: Hogar',
                  value: '- USD 310',
                ),
                _ActividadTile(
                  icon: Icons.trending_up,
                  title: 'Meta de ahorro',
                  subtitle: 'Progreso: 78% del mes',
                  value: 'En camino',
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
    DateTime? mes,
  }) : mes = mes ?? DateTime.now();

  final String categoria;
  final String subCategoria;
  final double monto;
  final bool esFijo;
  final bool pagoConTarjeta;
  final bool gastoHormiga;
  final _GastoPeriodicidad periodicidad;
  final DateTime mes;

  _GastoMensual copyWith({
    String? categoria,
    String? subCategoria,
    double? monto,
    bool? esFijo,
    bool? pagoConTarjeta,
    bool? gastoHormiga,
    _GastoPeriodicidad? periodicidad,
    DateTime? mes,
  }) {
    return _GastoMensual(
      categoria: categoria ?? this.categoria,
      subCategoria: subCategoria ?? this.subCategoria,
      monto: monto ?? this.monto,
      esFijo: esFijo ?? this.esFijo,
      pagoConTarjeta: pagoConTarjeta ?? this.pagoConTarjeta,
      gastoHormiga: gastoHormiga ?? this.gastoHormiga,
      periodicidad: periodicidad ?? this.periodicidad,
      mes: mes ?? this.mes,
    );
  }
}

class _IngresoMensual {
  _IngresoMensual({
    required this.etiqueta,
    required this.tipo,
    required this.monto,
    DateTime? mes,
  }) : mes = mes ?? DateTime.now();

  final String etiqueta;
  final _IngresoTipo tipo;
  final double monto;
  final DateTime mes;

  _IngresoMensual copyWith({
    String? etiqueta,
    _IngresoTipo? tipo,
    double? monto,
    DateTime? mes,
  }) {
    return _IngresoMensual(
      etiqueta: etiqueta ?? this.etiqueta,
      tipo: tipo ?? this.tipo,
      monto: monto ?? this.monto,
      mes: mes ?? this.mes,
    );
  }
}

enum _TipoDeuda {
  porPagar,
  porCobrar,
}

class _Deuda {
  _Deuda({
    required this.nombre,
    required this.monto,
    required this.tipo,
    DateTime? fecha,
    this.descripcion = '',
  }) : fecha = fecha ?? DateTime.now();

  final String nombre;
  final double monto;
  final _TipoDeuda tipo;
  final DateTime fecha;
  final String descripcion;

  _Deuda copyWith({
    String? nombre,
    double? monto,
    _TipoDeuda? tipo,
    DateTime? fecha,
    String? descripcion,
  }) {
    return _Deuda(
      nombre: nombre ?? this.nombre,
      monto: monto ?? this.monto,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      descripcion: descripcion ?? this.descripcion,
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
                    'Resumen de Operaciones',
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
      appBar: AppBar(title: const Text('Operaciones')),
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
                        ? 'Total de Ingresos'
                        : 'Total de Gastos',
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

Future<bool?> _confirmDeleteGasto(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Eliminar gasto'),
        content: const Text('¿Está seguro que desea eliminar este gasto?'),
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
        title: 'Ingresos (mes)',
        value: 'USD 4,820',
        delta: '+12.4%',
        icon: Icons.attach_money,
        color: Color(0xFF1565C0),
      ),
      _Kpi(
        title: 'Gastos (mes)',
        value: 'USD 2,110',
        delta: '-3.1%',
        icon: Icons.shopping_bag_outlined,
        color: Color(0xFF6A1B9A),
      ),
      _Kpi(
        title: 'Balance',
        value: 'USD 2,710',
        delta: '+18.2%',
        icon: Icons.account_balance_wallet,
        color: Color(0xFF2E7D32),
      ),
      _Kpi(
        title: 'Ahorro',
        value: '56.2%',
        delta: 'Del presupuesto',
        icon: Icons.savings_outlined,
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

class _BalanceMensualChart extends StatelessWidget {
  const _BalanceMensualChart();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Datos simulados de balance de los últimos 6 meses
    const ingresosPoints = <FlSpot>[
      FlSpot(0, 4.2),
      FlSpot(1, 4.5),
      FlSpot(2, 4.3),
      FlSpot(3, 4.8),
      FlSpot(4, 5.1),
      FlSpot(5, 4.9),
    ];
    
    const gastosPoints = <FlSpot>[
      FlSpot(0, 2.8),
      FlSpot(1, 3.1),
      FlSpot(2, 2.9),
      FlSpot(3, 3.3),
      FlSpot(4, 3.0),
      FlSpot(5, 3.2),
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toStringAsFixed(1)}K',
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, meta) {
                const labels = ['Ago', 'Sep', 'Oct', 'Nov', 'Dic', 'Ene'];
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: ingresosPoints,
            isCurved: true,
            barWidth: 3,
            color: colorScheme.primary,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: colorScheme.primary,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withOpacity(0.1),
            ),
          ),
          LineChartBarData(
            spots: gastosPoints,
            isCurved: true,
            barWidth: 3,
            color: colorScheme.error,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: colorScheme.error,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.error.withOpacity(0.1),
            ),
          ),
        ],
        minY: 2.0,
        maxY: 6.0,
      ),
    );
  }
}

class _DistribucionGastosChart extends StatelessWidget {
  const _DistribucionGastosChart();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    BarChartGroupData bar(int x, double y, Color color) {
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            color: color,
          ),
        ],
      );
    }

    final groups = <BarChartGroupData>[
      bar(0, 1.2, colorScheme.primary),
      bar(1, 0.8, colorScheme.secondary),
      bar(2, 1.5, colorScheme.tertiary),
      bar(3, 0.6, colorScheme.error.withOpacity(0.7)),
      bar(4, 0.4, const Color(0xFFEF6C00)),
    ];

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toStringAsFixed(1)}K',
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                const labels = ['Hogar', 'Trans', 'Alim', 'Serv', 'Otros'];
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        barGroups: groups,
        maxY: 2.0,
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

class _ComparacionIngresosBarChart extends StatelessWidget {
  const _ComparacionIngresosBarChart({
    required this.presupuesto,
    required this.ingresosReales,
  });

  final double presupuesto;
  final double ingresosReales;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = presupuesto > ingresosReales ? presupuesto : ingresosReales;
    final displayMax = maxValue * 1.2;

    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 16, bottom: 10),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: displayMax,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = groupIndex == 0 ? 'Presupuesto' : 'Ingresos Reales';
                      return BarTooltipItem(
                        '$label\n${_money(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ['Presupuesto', 'Reales'];
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _moneyShort(value),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: presupuesto,
                        width: 40,
                        color: scheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: ingresosReales,
                        width: 40,
                        color: scheme.tertiary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: scheme.primary, label: 'Presupuesto'),
              const SizedBox(width: 16),
              _LegendDot(color: scheme.tertiary, label: 'Ingresos Reales'),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (ingresosReales >= presupuesto)
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              ingresosReales >= presupuesto
                  ? '¡Excelente! Superaste tu presupuesto en ${_money(ingresosReales - presupuesto)}'
                  : 'Falta ${_money(presupuesto - ingresosReales)} para alcanzar tu presupuesto',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: (ingresosReales >= presupuesto)
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TendenciaComparacionChart extends StatelessWidget {
  const _TendenciaComparacionChart({
    required this.presupuesto,
    required this.ingresosReales,
  });

  final double presupuesto;
  final double ingresosReales;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    // Datos simulados de los últimos 6 meses
    final meses = ['Ago', 'Sep', 'Oct', 'Nov', 'Dic', 'Ene'];
    final presupuestoData = List.generate(6, (_) => presupuesto);
    
    // Simulamos variación alrededor de los ingresos reales actuales
    final baseReal = ingresosReales > 0 ? ingresosReales : presupuesto * 0.85;
    final ingresosRealesData = [
      baseReal * 0.88,
      baseReal * 0.96,
      baseReal * 1.03,
      baseReal * 0.98,
      baseReal * 1.08,
      baseReal,
    ];

    final maxValue = presupuesto * 1.1;

    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 16, bottom: 10),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                maxY: maxValue,
                minY: 0,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final mes = meses[spot.x.toInt()];
                        final label = spot.barIndex == 0 ? 'Presupuesto' : 'Reales';
                        return LineTooltipItem(
                          '$label\n$mes: ${_money(spot.y)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < meses.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              meses[value.toInt()],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _moneyShort(value),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      6,
                      (i) => FlSpot(i.toDouble(), presupuestoData[i]),
                    ),
                    isCurved: true,
                    color: scheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: scheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: scheme.primary.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: List.generate(
                      6,
                      (i) => FlSpot(i.toDouble(), ingresosRealesData[i]),
                    ),
                    isCurved: true,
                    color: scheme.tertiary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: scheme.tertiary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: scheme.tertiary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: scheme.primary, label: 'Presupuesto'),
              const SizedBox(width: 16),
              _LegendDot(color: scheme.tertiary, label: 'Ingresos Reales'),
            ],
          ),
        ],
      ),
    );
  }
}

String _moneyShort(double value) {
  if (value >= 1000000) {
    return '\$${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    return '\$${(value / 1000).toStringAsFixed(0)}K';
  }
  return '\$${value.toStringAsFixed(0)}';
}

class _ComparacionPresupuestoRealChart extends StatelessWidget {
  const _ComparacionPresupuestoRealChart({
    required this.presupuestoIngresos,
    required this.ingresosReales,
    required this.presupuestoGastos,
  });

  final double presupuestoIngresos;
  final double ingresosReales;
  final double presupuestoGastos;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    // Simulamos gastos reales como un porcentaje de los gastos presupuestados
    final gastosReales = presupuestoGastos * 0.92;
    
    final maxValue = [presupuestoIngresos, ingresosReales, presupuestoGastos, gastosReales]
        .reduce((a, b) => a > b ? a : b);
    final displayMax = maxValue * 1.25;

    final balancePresupuesto = presupuestoIngresos - presupuestoGastos;
    final balanceReal = ingresosReales - gastosReales;

    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 16, bottom: 10),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: displayMax,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label;
                      if (groupIndex == 0) {
                        label = rodIndex == 0 ? 'Ingresos\nPresupuesto' : 'Ingresos\nReales';
                      } else {
                        label = rodIndex == 0 ? 'Gastos\nPresupuesto' : 'Gastos\nReales';
                      }
                      return BarTooltipItem(
                        '$label\n${_money(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ['Ingresos', 'Gastos'];
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _moneyShort(value),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: presupuestoIngresos,
                        width: 28,
                        color: scheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: ingresosReales,
                        width: 28,
                        color: scheme.tertiary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: presupuestoGastos,
                        width: 28,
                        color: scheme.error.withOpacity(0.7),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: gastosReales,
                        width: 28,
                        color: scheme.error,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _LegendDot(color: scheme.primary, label: 'Presupuesto'),
              _LegendDot(color: scheme.tertiary, label: 'Ingresos Reales'),
              _LegendDot(color: scheme.error.withOpacity(0.7), label: 'Gastos Presup.'),
              _LegendDot(color: scheme.error, label: 'Gastos Reales'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Balance Presupuesto',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _money(balancePresupuesto),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: balancePresupuesto >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: balanceReal >= 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Balance Real',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _money(balanceReal),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: balanceReal >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Ingresos: ${((ingresosReales / presupuestoIngresos) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      ingresosReales >= presupuestoIngresos ? '✓ Cumplido' : '⚠ Pendiente',
                      style: TextStyle(
                        fontSize: 10,
                        color: ingresosReales >= presupuestoIngresos
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.withOpacity(0.3),
                ),
                Column(
                  children: [
                    Text(
                      'Gastos: ${((gastosReales / presupuestoGastos) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      gastosReales <= presupuestoGastos ? '✓ Bajo control' : '⚠ Excedido',
                      style: TextStyle(
                        fontSize: 10,
                        color: gastosReales <= presupuestoGastos
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparacionMensualChart extends StatelessWidget {
  const _ComparacionMensualChart({
    required this.presupuestoIngresos,
    required this.presupuestoGastos,
    required this.ingresosReales,
    required this.gastosReales,
  });

  final double presupuestoIngresos;
  final double presupuestoGastos;
  final double ingresosReales;
  final double gastosReales;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = [presupuestoIngresos, presupuestoGastos, ingresosReales, gastosReales]
        .reduce((a, b) => a > b ? a : b);
    final displayMax = maxValue * 1.2;

    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 16, bottom: 10),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: displayMax,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label;
                      if (groupIndex == 0) {
                        label = rodIndex == 0 ? 'Presupuesto' : 'Real';
                      } else {
                        label = rodIndex == 0 ? 'Presupuesto' : 'Real';
                      }
                      return BarTooltipItem(
                        '$label\n${_money(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ['Ingresos', 'Gastos'];
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _moneyShort(value),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: presupuestoIngresos,
                        width: 28,
                        color: scheme.primary.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: ingresosReales,
                        width: 28,
                        color: scheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: presupuestoGastos,
                        width: 28,
                        color: scheme.error.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: gastosReales,
                        width: 28,
                        color: scheme.error,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _LegendDot(color: scheme.primary.withOpacity(0.6), label: 'Presupuesto'),
              _LegendDot(color: scheme.primary, label: 'Real'),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvolucionAnualChart extends StatelessWidget {
  const _EvolucionAnualChart({
    required this.datosAnuales,
    required this.presupuestoIngresos,
    required this.presupuestoGastos,
  });

  final List<Map<String, dynamic>> datosAnuales;
  final double presupuestoIngresos;
  final double presupuestoGastos;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    final ingresosRealesSpots = datosAnuales
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value['ingresos']))
        .toList();
    
    final gastosRealesSpots = datosAnuales
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value['gastos']))
        .toList();
    
    final presupuestoIngresosSpots = List.generate(
      12,
      (i) => FlSpot(i.toDouble(), presupuestoIngresos),
    );
    
    final presupuestoGastosSpots = List.generate(
      12,
      (i) => FlSpot(i.toDouble(), presupuestoGastos),
    );

    final maxValue = [
      presupuestoIngresos,
      presupuestoGastos,
      ...datosAnuales.map((d) => d['ingresos'] as double),
      ...datosAnuales.map((d) => d['gastos'] as double),
    ].reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 16, bottom: 10),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                maxY: maxValue * 1.1,
                minY: 0,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                                      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
                        final mes = meses[spot.x.toInt()];
                        String label;
                        if (spot.barIndex == 0) label = 'Ing. Presup.';
                        else if (spot.barIndex == 1) label = 'Ing. Real';
                        else if (spot.barIndex == 2) label = 'Gast. Presup.';
                        else label = 'Gast. Real';
                        
                        return LineTooltipItem(
                          '$label\n$mes: ${_money(spot.y)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const meses = ['E', 'F', 'M', 'A', 'M', 'J',
                                      'J', 'A', 'S', 'O', 'N', 'D'];
                        if (value.toInt() >= 0 && value.toInt() < meses.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              meses[value.toInt()],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _moneyShort(value),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: presupuestoIngresosSpots,
                    isCurved: false,
                    color: scheme.primary.withOpacity(0.4),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  LineChartBarData(
                    spots: ingresosRealesSpots,
                    isCurved: true,
                    color: scheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: scheme.primary,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: scheme.primary.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: presupuestoGastosSpots,
                    isCurved: false,
                    color: scheme.error.withOpacity(0.4),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  LineChartBarData(
                    spots: gastosRealesSpots,
                    isCurved: true,
                    color: scheme.error,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: scheme.error,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: scheme.error.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _LegendDot(color: scheme.primary.withOpacity(0.4), label: 'Ing. Presup.'),
              _LegendDot(color: scheme.primary, label: 'Ing. Real'),
              _LegendDot(color: scheme.error.withOpacity(0.4), label: 'Gast. Presup.'),
              _LegendDot(color: scheme.error, label: 'Gast. Real'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeudasScreen extends StatelessWidget {
  const _DeudasScreen({
    required this.deudas,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<_Deuda> deudas;
  final Future<void> Function() onAdd;
  final Future<void> Function(int index) onEdit;
  final void Function(int index) onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    final deudasPorPagar = deudas.where((d) => d.tipo == _TipoDeuda.porPagar).toList();
    final deudasPorCobrar = deudas.where((d) => d.tipo == _TipoDeuda.porCobrar).toList();
    
    final totalPorPagar = deudasPorPagar.fold(0.0, (sum, d) => sum + d.monto);
    final totalPorCobrar = deudasPorCobrar.fold(0.0, (sum, d) => sum + d.monto);
    final balanceDeudas = totalPorCobrar - totalPorPagar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deudas Generales'),
        actions: [
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            tooltip: 'Agregar deuda',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_upward, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Por Pagar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _money(totalPorPagar),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${deudasPorPagar.length} deuda(s)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_downward, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Por Cobrar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _money(totalPorCobrar),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${deudasPorCobrar.length} deuda(s)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: balanceDeudas >= 0
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Balance de Deudas',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _money(balanceDeudas),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: balanceDeudas >= 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    balanceDeudas >= 0
                        ? 'Te deben más de lo que debes'
                        : 'Debes más de lo que te deben',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _CardSection(
              title: 'Deudas por Pagar',
              child: deudasPorPagar.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No tienes deudas por pagar',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: deudasPorPagar.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final deudaIndex = deudas.indexOf(deudasPorPagar[i]);
                        final deuda = deudasPorPagar[i];
                        return _DeudaTile(
                          deuda: deuda,
                          color: Colors.red.shade700,
                          onEdit: () => onEdit(deudaIndex),
                          onDelete: () => onDelete(deudaIndex),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 14),
            _CardSection(
              title: 'Deudas por Cobrar',
              child: deudasPorCobrar.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No tienes deudas por cobrar',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: deudasPorCobrar.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final deudaIndex = deudas.indexOf(deudasPorCobrar[i]);
                        final deuda = deudasPorCobrar[i];
                        return _DeudaTile(
                          deuda: deuda,
                          color: Colors.green.shade700,
                          onEdit: () => onEdit(deudaIndex),
                          onDelete: () => onDelete(deudaIndex),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeudaTile extends StatelessWidget {
  const _DeudaTile({
    required this.deuda,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  final _Deuda deuda;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              deuda.tipo == _TipoDeuda.porPagar
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deuda.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                if (deuda.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    deuda.descripcion,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  _formatearFecha(deuda.fecha),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(deuda.monto),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<_Deuda?> _openDeudaModal(BuildContext context, {_Deuda? initial}) {
  return showModalBottomSheet<_Deuda>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _DeudaModal(initial: initial),
  );
}

class _DeudaModal extends StatefulWidget {
  const _DeudaModal({this.initial});

  final _Deuda? initial;

  @override
  State<_DeudaModal> createState() => _DeudaModalState();
}

class _DeudaModalState extends State<_DeudaModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _monto;
  late final TextEditingController _descripcion;
  late _TipoDeuda _tipo;
  late DateTime _fecha;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.initial?.nombre ?? '');
    _monto = TextEditingController(
      text: widget.initial?.monto.toString() ?? '',
    );
    _descripcion = TextEditingController(
      text: widget.initial?.descripcion ?? '',
    );
    _tipo = widget.initial?.tipo ?? _TipoDeuda.porPagar;
    _fecha = widget.initial?.fecha ?? DateTime.now();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _monto.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombre.text.trim();
    final montoRaw = _monto.text.trim().replaceAll(',', '.');
    final monto = double.parse(montoRaw);
    final descripcion = _descripcion.text.trim();

    final deuda = _Deuda(
      nombre: nombre,
      monto: monto,
      tipo: _tipo,
      fecha: _fecha,
      descripcion: descripcion,
    );

    Navigator.of(context).pop(deuda);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initial == null ? 'Agregar Deuda' : 'Editar Deuda',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<_TipoDeuda>(
              value: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de deuda',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: _TipoDeuda.porPagar,
                  child: Text('Por Pagar'),
                ),
                DropdownMenuItem(
                  value: _TipoDeuda.porCobrar,
                  child: Text('Por Cobrar'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _tipo = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre (Persona o Empresa)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _monto,
              decoration: const InputDecoration(
                labelText: 'Monto',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa un monto';
                }
                final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Monto inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcion,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha'),
              subtitle: Text(_formatearFecha(_fecha)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _fecha,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _fecha = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatearFecha(DateTime fecha) {
  const meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];
  return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
}

class _ComparacionGananciasChart extends StatelessWidget {
  const _ComparacionGananciasChart({
    required this.presupuestadas,
    required this.reales,
  });

  final double presupuestadas;
  final double reales;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = presupuestadas > reales ? presupuestadas : reales;
    final displayMax = maxValue * 1.3;

    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 16, bottom: 10),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: displayMax,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = groupIndex == 0 ? 'Presupuestadas' : 'Reales';
                      return BarTooltipItem(
                        '$label\n${_money(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ['Presupuestadas', 'Reales'];
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _moneyShort(value),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: presupuestadas,
                        width: 50,
                        color: scheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary,
                            scheme.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: reales,
                        width: 50,
                        color: scheme.tertiary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            scheme.tertiary,
                            scheme.tertiary.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: scheme.primary, label: 'Presupuestadas'),
              const SizedBox(width: 16),
              _LegendDot(color: scheme.tertiary, label: 'Reales'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistribucionIngresosChart extends StatelessWidget {
  const _DistribucionIngresosChart({required this.ingresos});

  final List<_IngresoMensual> ingresos;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    if (ingresos.isEmpty) {
      return const Center(
        child: Text(
          'No hay ingresos presupuestados',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final ingresosFijos = ingresos
        .where((i) => i.tipo == _IngresoTipo.fija)
        .fold(0.0, (sum, i) => sum + i.monto);
    final ingresosVariables = ingresos
        .where((i) => i.tipo != _IngresoTipo.fija)
        .fold(0.0, (sum, i) => sum + i.monto);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (ingresosFijos > 0)
                    PieChartSectionData(
                      value: ingresosFijos,
                      title: '${((ingresosFijos / (ingresosFijos + ingresosVariables)) * 100).toStringAsFixed(0)}%',
                      color: scheme.primary,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (ingresosVariables > 0)
                    PieChartSectionData(
                      value: ingresosVariables,
                      title: '${((ingresosVariables / (ingresosFijos + ingresosVariables)) * 100).toStringAsFixed(0)}%',
                      color: scheme.tertiary,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              if (ingresosFijos > 0)
                _LegendDot(
                  color: scheme.primary,
                  label: 'Fijos: ${_money(ingresosFijos)}',
                ),
              if (ingresosVariables > 0)
                _LegendDot(
                  color: scheme.tertiary,
                  label: 'Variables: ${_money(ingresosVariables)}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
