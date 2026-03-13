# Actualización de Gráficas - Resumen

## Cambios Pendientes

### 1. _BalanceMensualChart (línea ~4684)
Reemplazar la clase completa con:

```dart
class _BalanceMensualChart extends StatelessWidget {
  const _BalanceMensualChart({
    required this.ingresos,
    required this.gastos,
  });

  final List<IngresoMensual> ingresos;
  final List<GastoMensual> gastos;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Calcular datos de los últimos 6 meses
    final ahora = DateTime.now();
    final meses = <DateTime>[];
    for (int i = 5; i >= 0; i--) {
      final mes = DateTime(ahora.year, ahora.month - i, 1);
      meses.add(mes);
    }
    
    // Calcular ingresos y gastos por mes
    final ingresosPoints = <FlSpot>[];
    final gastosPoints = <FlSpot>[];
    double maxValue = 1000.0;
    
    for (int i = 0; i < meses.length; i++) {
      final mes = meses[i];
      
      final ingresosDelMes = ingresos
          .where((ing) => ing.mes.year == mes.year && ing.mes.month == mes.month)
          .fold(0.0, (sum, ing) => sum + ing.monto);
      
      final gastosDelMes = gastos
          .where((g) => g.mes.year == mes.year && g.mes.month == mes.month)
          .fold(0.0, (sum, g) => sum + g.monto);
      
      ingresosPoints.add(FlSpot(i.toDouble(), ingresosDelMes / 1000));
      gastosPoints.add(FlSpot(i.toDouble(), gastosDelMes / 1000));
      
      if (ingresosDelMes > maxValue) maxValue = ingresosDelMes;
      if (gastosDelMes > maxValue) maxValue = gastosDelMes;
    }
    
    final labels = meses.map((m) {
      const mesesNombres = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                            'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return mesesNombres[m.month - 1];
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('\$${value.toStringAsFixed(1)}K', style: const TextStyle(fontSize: 11));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, meta) {
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
            belowBarData: BarAreaData(show: true, color: colorScheme.primary.withOpacity(0.1)),
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
            belowBarData: BarAreaData(show: true, color: colorScheme.error.withOpacity(0.1)),
          ),
        ],
        minY: 0,
        maxY: (maxValue / 1000 * 1.2).ceilToDouble(),
      ),
    );
  }
}
```

### 2. _DistribucionGastosChart (línea ~4807)
Reemplazar la clase completa con:

```dart
class _DistribucionGastosChart extends StatelessWidget {
  const _DistribucionGastosChart({
    required this.gastos,
  });

  final List<GastoMensual> gastos;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Agrupar gastos por categoría
    final gastosPorCategoria = <String, double>{};
    for (final gasto in gastos) {
      gastosPorCategoria[gasto.categoria] = 
          (gastosPorCategoria[gasto.categoria] ?? 0) + gasto.monto;
    }
    
    if (gastosPorCategoria.isEmpty) {
      return const Center(
        child: Text('No hay gastos registrados'),
      );
    }
    
    final total = gastosPorCategoria.values.fold(0.0, (sum, val) => sum + val);
    
    final sections = gastosPorCategoria.entries.map((entry) {
      final porcentaje = (entry.value / total * 100);
      final colores = [
        colorScheme.primary,
        colorScheme.secondary,
        colorScheme.tertiary,
        Colors.orange,
        Colors.purple,
        Colors.teal,
      ];
      final index = gastosPorCategoria.keys.toList().indexOf(entry.key);
      final color = colores[index % colores.length];
      
      return PieChartSectionData(
        value: entry.value,
        title: '${porcentaje.toStringAsFixed(1)}%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: gastosPorCategoria.entries.map((entry) {
              final index = gastosPorCategoria.keys.toList().indexOf(entry.key);
              final colores = [
                colorScheme.primary,
                colorScheme.secondary,
                colorScheme.tertiary,
                Colors.orange,
                Colors.purple,
                Colors.teal,
              ];
              final color = colores[index % colores.length];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
```

### 3. _ActividadReciente (nuevo widget)
Agregar antes de la clase _ActividadTile:

```dart
class _ActividadReciente extends StatelessWidget {
  const _ActividadReciente({
    required this.ingresos,
    required this.gastos,
  });

  final List<IngresoMensual> ingresos;
  final List<GastoMensual> gastos;

  @override
  Widget build(BuildContext context) {
    // Obtener los últimos 3 movimientos (ingresos y gastos combinados)
    final movimientos = <Map<String, dynamic>>[];
    
    for (final ingreso in ingresos) {
      movimientos.add({
        'tipo': 'ingreso',
        'fecha': ingreso.mes,
        'titulo': 'Ingreso registrado',
        'subtitulo': 'Tipo: ${ingreso.tipo.name}',
        'valor': '+ ${_money(ingreso.monto)}',
        'icon': Icons.attach_money,
      });
    }
    
    for (final gasto in gastos) {
      movimientos.add({
        'tipo': 'gasto',
        'fecha': gasto.mes,
        'titulo': 'Gasto registrado',
        'subtitulo': 'Categoría: ${gasto.categoria}',
        'valor': '- ${_money(gasto.monto)}',
        'icon': Icons.shopping_bag_outlined,
      });
    }
    
    // Ordenar por fecha descendente
    movimientos.sort((a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));
    
    // Tomar solo los últimos 3
    final ultimos = movimientos.take(3).toList();
    
    if (ultimos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No hay actividad reciente'),
      );
    }
    
    return Column(
      children: ultimos.map((mov) {
        return _ActividadTile(
          icon: mov['icon'] as IconData,
          title: mov['titulo'] as String,
          subtitle: mov['subtitulo'] as String,
          value: mov['valor'] as String,
        );
      }).toList(),
    );
  }
}
```

## Instrucciones de Aplicación

1. Abrir `lib/main.dart`
2. Buscar `class _BalanceMensualChart` (línea ~4684)
3. Reemplazar toda la clase hasta el cierre `}`
4. Buscar `class _DistribucionGastosChart` (línea ~4807)
5. Reemplazar toda la clase hasta el cierre `}`
6. Buscar `class _ActividadTile` y agregar `_ActividadReciente` ANTES de ella
7. Guardar y compilar

## Resultado

- ✅ Gráfica de Balance Mensual muestra datos reales de los últimos 6 meses
- ✅ Gráfica de Distribución de Gastos muestra categorías reales
- ✅ Actividad Reciente muestra los últimos 3 movimientos reales
- ✅ Todo conectado a la base de datos por usuario
