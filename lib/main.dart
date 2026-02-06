import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const EstrategiasVentasApp());
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
    const primary = Color(0xFF0D47A1);

    return MaterialApp(
      title: 'Estadísticas de ventas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: primary,
          foregroundColor: Colors.white,
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
                      child: Image.asset(
                        'assets/logo.webp',
                        fit: BoxFit.contain,
                      ),
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final views = [
      const _ResumenTab(),
      const _MercadoTab(),
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
              child: Image.asset('assets/logo.webp', fit: BoxFit.contain),
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
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Mercado',
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

class _ResumenTab extends StatelessWidget {
  const _ResumenTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _KpisGrid(),
          const SizedBox(height: 14),
          const _IngresosMensualesSection(),
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
                    child: Image.asset('assets/logo.webp', fit: BoxFit.contain),
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

class _IngresosMensualesSection extends StatefulWidget {
  const _IngresosMensualesSection();

  @override
  State<_IngresosMensualesSection> createState() =>
      _IngresosMensualesSectionState();
}

class _IngresosMensualesSectionState extends State<_IngresosMensualesSection> {
  final List<_IngresoMensual> _items = [
    _IngresoMensual(
      etiqueta: 'Salario mensual',
      tipo: _IngresoTipo.fija,
      monto: 1200,
    ),
  ];

  double get _total => _items.fold(0, (sum, it) => sum + it.monto);

  Future<void> _openModal({int? editIndex}) async {
    final existing = editIndex == null ? null : _items[editIndex];
    final result = await showModalBottomSheet<_IngresoMensual>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return _IngresoModal(initial: existing);
      },
    );

    if (!mounted || result == null) return;
    setState(() {
      if (editIndex == null) {
        _items.add(result);
      } else {
        _items[editIndex] = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen Mensual de ingresos',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Agrega ingresos y mira el total mensual',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _openModal(),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Aún no tienes ingresos cargados.'),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final it = _items[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.payments_outlined,
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
                                style: const TextStyle(color: Colors.black54),
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
                                  onPressed: () => _openModal(editIndex: i),
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _items.removeAt(i)),
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Eliminar',
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
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total de Ingresos Mensuales',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    _money(_total),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
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
