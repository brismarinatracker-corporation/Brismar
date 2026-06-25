import 'package:flutter/material.dart';
import '../../dominio/entidades/registro_entidad.dart';

/// Lista que muestra el historial de capturas y gastos registrados con diseño premium.
class HistorialLista extends StatelessWidget {
  final List<RegistroEntidad> registros;
  final ValueChanged<RegistroEntidad> onGenerarPDF;

  const HistorialLista({
    super.key,
    required this.registros,
    required this.onGenerarPDF,
  });

  @override
  Widget build(BuildContext context) {
    if (registros.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, color: Colors.white.withValues(alpha: 0.2), size: 40),
              const SizedBox(height: 12),
              Text(
                'No se encontraron registros.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: registros.length,
      itemBuilder: (context, index) {
        final reg = registros[index];
        return _ItemRegistroCard(
          reg: reg,
          onGenerarPDF: onGenerarPDF,
        );
      },
    );
  }
}

class _ItemRegistroCard extends StatefulWidget {
  final RegistroEntidad reg;
  final ValueChanged<RegistroEntidad> onGenerarPDF;

  const _ItemRegistroCard({
    required this.reg,
    required this.onGenerarPDF,
  });

  @override
  State<_ItemRegistroCard> createState() => _ItemRegistroCardState();
}

class _ItemRegistroCardState extends State<_ItemRegistroCard> {
  bool _expandido = false;

  String _formatearNumero(double valor, {int decimales = 2}) {
    String str = valor.toStringAsFixed(decimales);
    List<String> partes = str.split('.');
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    partes[0] = partes[0].replaceAllMapped(reg, (Match m) => '${m[1]},');
    return partes.join('.');
  }

  List<MapEntry<String, double>> _obtenerGastosValidos() {
    final list = <MapEntry<String, double>>[];
    if (widget.reg.gastoFacturacion > 0) list.add(MapEntry('Facturación', widget.reg.gastoFacturacion));
    if (widget.reg.gastoPersonal > 0) list.add(MapEntry('Personal/Bahía', widget.reg.gastoPersonal));
    if (widget.reg.gastoApoyo > 0) list.add(MapEntry('Apoyo/Bahía', widget.reg.gastoApoyo));
    if (widget.reg.gastoAgua > 0) list.add(MapEntry('Agua', widget.reg.gastoAgua));
    if (widget.reg.gastoClorox > 0) list.add(MapEntry('Clorox/Sal', widget.reg.gastoClorox));
    if (widget.reg.gastoFlete > 0) list.add(MapEntry('Flete', widget.reg.gastoFlete));
    if (widget.reg.gastoHielo > 0) list.add(MapEntry('Hielo', widget.reg.gastoHielo));
    if (widget.reg.gastoPesador > 0) list.add(MapEntry('Pesador', widget.reg.gastoPesador));
    if (widget.reg.gastoOtros > 0) list.add(MapEntry('Otros', widget.reg.gastoOtros));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final gastos = _obtenerGastosValidos();
    final tieneGastos = gastos.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F224A).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ENCABEZADO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_boat_rounded, color: Color(0xFF00E5FF), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    widget.reg.nombreEmbarcacion.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              _buildIconoSincronizacion(widget.reg.sincronizado),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          const SizedBox(height: 10),

          // CUERPO DEL DETALLE PRINCIPAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Producto y Placa
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_rounded, color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          widget.reg.producto,
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (widget.reg.placaCarro != null && widget.reg.placaCarro!.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.local_shipping_rounded, color: Colors.white60, size: 14),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.reg.placaCarro!.toUpperCase(),
                              style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Muelle: ${widget.reg.muelleInicio}  |  Cajas: ${widget.reg.cajas}  |  Fecha: ${widget.reg.fecha}',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatearNumero(widget.reg.kilos, decimales: 1)} kg a S/ ${_formatearNumero(widget.reg.precioPorKilo)} /kg',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Utilidad Neta: ',
                          style: TextStyle(fontSize: 11, color: Colors.white60),
                        ),
                        Text(
                          'S/ ${_formatearNumero(widget.reg.utilidadNeta)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00E676),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => widget.onGenerarPDF(widget.reg),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 14, color: Colors.white),
                    label: const Text(
                      'PDF',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size.zero,
                      elevation: 2,
                    ),
                  ),
                  if (tieneGastos) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _expandido = !_expandido;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        _expandido ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: const Color(0xFF00E5FF),
                      ),
                      label: Text(
                        _expandido ? 'Ocultar' : 'Gastos',
                        style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]
                ],
              )
            ],
          ),

          // SECCIÓN EXPANDIBLE DE GASTOS
          if (tieneGastos && _expandido) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DESGLOSE DE GASTOS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00E5FF),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...gastos.map((gasto) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              gasto.key,
                              style: const TextStyle(fontSize: 10, color: Colors.white70),
                            ),
                            Text(
                              'S/ ${_formatearNumero(gasto.value)}',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(color: Colors.white12, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Gastos',
                        style: TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'S/ ${_formatearNumero(widget.reg.totalGastos)}',
                        style: const TextStyle(fontSize: 10, color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconoSincronizacion(bool sincronizado) {
    final colorStatus = sincronizado ? const Color(0xFF00E676) : Colors.orangeAccent;
    final labelStatus = sincronizado ? 'SINCRONIZADO' : 'PENDIENTE (OFFLINE)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorStatus.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorStatus.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            sincronizado ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
            color: colorStatus,
            size: 11,
          ),
          const SizedBox(width: 4),
          Text(
            labelStatus,
            style: TextStyle(
              color: colorStatus,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
