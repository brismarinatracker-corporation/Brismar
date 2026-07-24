import 'package:flutter/material.dart';
import 'package:bris_tracker/nucleo/componentes/carga_orbital.dart';
import 'package:bris_tracker/nucleo/matematica/motor_calculos_cuadre.dart';
import 'package:bris_tracker/nucleo/utilidades/formateador_brismar.dart';

/// Panel de cálculo en vivo para el resumen de compras, gastos y utilidades de zarpe.
class PanelCalculoVivo extends StatelessWidget {
  /// Total de kilogramos acumulados en las compras.
  final double totalKilosCompras;

  /// Total del monto asignado para compras.
  final double totalCostoCompras;

  /// Total de gastos operativos de muelle.
  final double totalGastosOperativos;

  /// Indica si el proceso de guardado está en ejecución.
  final bool guardando;

  /// Callback invocado al confirmar el despacho.
  final VoidCallback onGuardar;

  /// Crea una instancia del panel de cálculos en vivo.
  const PanelCalculoVivo({
    super.key,
    required this.totalKilosCompras,
    required this.totalCostoCompras,
    required this.totalGastosOperativos,
    required this.guardando,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _construirDecoracionContenedor(tema),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _construirHijosColumna(context),
      ),
    );
  }

  BoxDecoration _construirDecoracionContenedor(ThemeData tema) {
    return BoxDecoration(
      color: tema.colorScheme.surface,
      border: Border(top: BorderSide(color: tema.dividerColor, width: 1)),
    );
  }

  List<Widget> _construirHijosColumna(BuildContext context) {
    final tema = Theme.of(context);
    return [
      Text(
        'CUADRE EN VIVO',
        style: tema.textTheme.titleMedium?.copyWith(
          color: tema.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      _construirResumen(context),
      Divider(color: tema.dividerColor, height: 32, thickness: 1),
      _construirEstimaciones(context),
      const SizedBox(height: 24),
      Text(
        '⚠️ Al guardar, el lote quedará en estado "Borrador" hasta el pesaje en planta.',
        style: tema.textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      _construirBotonGuardar(context),
    ];
  }

  Widget _construirResumen(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      children: [
        _construirFilaResumen(
          'Kilos Totales',
          FormateadorBrismar.formatearKilos(totalKilosCompras),
          tema.colorScheme.onSurface,
          context,
        ),
        Divider(color: tema.dividerColor, height: 24),
        _construirFilaResumen(
          'Poder de Compra',
          FormateadorBrismar.formatearMoneda(totalCostoCompras),
          tema.colorScheme.onSurface,
          context,
        ),
        _construirFilaResumen(
          'Gastos Muelle',
          '- ${FormateadorBrismar.formatearMoneda(totalGastosOperativos)}',
          tema.colorScheme.error,
          context,
        ),
      ],
    );
  }

  Widget _construirEstimaciones(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tema.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _construirDetalleUtilidad(context),
          Divider(color: tema.dividerColor, height: 24),
          _construirDetallePagoEmbarcacion(context),
        ],
      ),
    );
  }

  Widget _construirDetalleUtilidad(BuildContext context) {
    final tema = Theme.of(context);
    final utilidadBruta = MotorCalculosCuadre.calcularUtilidadOperativa(
      totalCostoCompras,
      totalGastosOperativos,
    );
    final reparto = MotorCalculosCuadre.calcularReparto5050(utilidadBruta);
    return Column(
      children: [
        Text(
          'ESTIMADO UTILIDAD (50/50)',
          style: tema.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${FormateadorBrismar.formatearMoneda(reparto)} c/u',
          style: tema.textTheme.headlineMedium?.copyWith(
            color: tema.colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _construirDetallePagoEmbarcacion(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      children: [
        Text(
          'PAGO LÍQUIDO A EMBARCACIÓN',
          style: tema.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          FormateadorBrismar.formatearMoneda(totalCostoCompras),
          style: tema.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _construirBotonGuardar(BuildContext context) {
    final tema = Theme.of(context);
    return SizedBox(
      height: 64,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: tema.colorScheme.primary,
          foregroundColor: tema.colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: guardando ? null : onGuardar,
        icon: guardando
            ? const CargaOrbital(tamano: 24, colorPrimario: Colors.white)
            : const Icon(Icons.save_rounded, size: 28),
        label: Text(
          guardando ? 'GUARDANDO...' : 'CONFIRMAR DESPACHO',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _construirFilaResumen(
    String etiqueta,
    String valor,
    Color colorValor,
    BuildContext context,
  ) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: tema.textTheme.bodyMedium),
          Text(
            valor,
            style: tema.textTheme.titleMedium?.copyWith(
              color: colorValor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
