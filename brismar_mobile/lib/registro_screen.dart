import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  // --- CONTROLADORES ---
  final _nombreNaveController = TextEditingController();
  final _kilosController = TextEditingController();
  final _catanaKilosController = TextEditingController();
  final _catanaPrecioController = TextEditingController();
  final _placaController = TextEditingController();
  final _cajasController = TextEditingController();
  final _muelleController = TextEditingController();
  final _precioKiloVentaController = TextEditingController();

  // Gastos
  final _facturacionController = TextEditingController(text: '0');
  final _personalController = TextEditingController(text: '0');
  final _apoyoController = TextEditingController(text: '0');
  final _aguaController = TextEditingController(text: '0');

  // --- VARIABLES DE ESTADO ---
  String? productoSeleccionado;
  double kilosTotales = 0.0;
  double totalVenta = 0.0;
  double totalGastos = 0.0;
  double totalNeto = 0.0;

  void _calcularTodo() {
    setState(() {
      kilosTotales = double.tryParse(_kilosController.text) ?? 0.0;
      double precioVenta = double.tryParse(_precioKiloVentaController.text) ?? 0.0;
      totalVenta = kilosTotales * precioVenta;

      double g1 = double.tryParse(_facturacionController.text) ?? 0.0;
      double g2 = double.tryParse(_personalController.text) ?? 0.0;
      double g3 = double.tryParse(_apoyoController.text) ?? 0.0;
      double g4 = double.tryParse(_aguaController.text) ?? 0.0;
      
      totalGastos = g1 + g2 + g3 + g4;
      totalNeto = totalVenta - totalGastos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D255F),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F4F9),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildUserHeader(),
                    const SizedBox(height: 15),
                    _buildSeccionEmbarcaciones(), // AQUÍ ESTÁ LO QUE PEDISTE
                    const SizedBox(height: 15),
                    _buildSeccionVenta(),
                    const SizedBox(height: 15),
                    _buildSeccionGastos(),
                    const SizedBox(height: 15),
                    _buildSeccionTotales(),
                    const SizedBox(height: 20),
                    _buildBotonRegistrar(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTES DEL DISEÑO ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0D255F),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                child: const Text('BRISMAR', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NEGOCIOS', style: TextStyle(fontSize: 9, color: Colors.white70)),
                  Text('BRISMAR S.R.L.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B1F31), shape: const StadiumBorder()),
            child: const Text('Salir', style: TextStyle(color: Colors.white, fontSize: 11)),
          )
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _buildTabItem("+ NUEVO REGISTRO", true),
        _buildTabItem("⚓ REGISTRADOS (0)", false),
      ],
    );
  }

  Widget _buildTabItem(String label, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.lightBlue : Colors.transparent,
          borderRadius: active ? const BorderRadius.only(topRight: Radius.circular(20)) : null,
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF1A357D), borderRadius: BorderRadius.circular(10)),
            child: const Row(
              children: [
                CircleAvatar(backgroundColor: Colors.lightBlue, radius: 14, child: Icon(Icons.person, size: 16, color: Colors.white)),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('USUARIO ACTIVO', style: TextStyle(color: Colors.white70, fontSize: 8)),
                    Text('Daniel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF1A357D), borderRadius: BorderRadius.circular(10)),
            child: const Column(
              children: [
                Text('07/05/26', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                Text('09:54 a.m.', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 9)),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSeccionEmbarcaciones() {
    return _buildCardWrapper(
      colorHeader: const Color(0xFF0D255F),
      title: '⚓ EMBARCACIONES (Hasta 5)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('EMBARCACIÓN 1', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 14, color: Colors.lightBlue),
                label: const Text('Agregar', style: TextStyle(color: Colors.lightBlue, fontSize: 11)),
              ),
            ],
          ),
          _buildTextField("Nombre", "Ej: Don José I", _nombreNaveController),
          const SizedBox(height: 8),
          _buildTextField("Kilos", "0.0", _kilosController, isNumeric: true),
          const SizedBox(height: 12),
          
          // BANNER KILOS
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFD9E2FF), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('⚖ KILOS TOTALES', style: TextStyle(color: Color(0xFF0D255F), fontWeight: FontWeight.bold, fontSize: 11)),
                Text('${kilosTotales.toStringAsFixed(1)} kg', style: const TextStyle(color: Color(0xFF321A98), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // CATANAS (AMARILLO)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFFF9C4), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.shade100)),
            child: Column(
              children: [
                const Row(children: [Icon(Icons.settings_input_component, size: 14, color: Colors.orange), SizedBox(width: 5), Text('CATANAS', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10))]),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Kilos", "0", _catanaKilosController, isNumeric: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextField("Precio/kg", "0", _catanaPrecioController, isNumeric: true)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 12),

          // PRODUCTO Y PLACA
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🐟 PRODUCTO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration("Seleccionar.."),
                      items: ["POTA", "JUREL", "BONITO", "CABALLA"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 11)))).toList(),
                      onChanged: (v) => setState(() => productoSeleccionado = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("# PLACA DE CAMARA", "ABC-123", _placaController)),
            ],
          ),
          const SizedBox(height: 12),

          // CAJAS Y MUELLE
          Row(
            children: [
              Expanded(child: _buildTextField("📦 CAJAS EN CAMARA", "0", _cajasController, isNumeric: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("📍 MUELLE DE PARTIDA", "Ej: Muelle A", _muelleController)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionVenta() {
    return _buildCardWrapper(
      colorHeader: const Color(0xFF006B3D),
      title: '\$ DATOS DE VENTA',
      child: Column(
        children: [
          _buildTextField("PRECIO POR KILO", "0.00", _precioKiloVentaController, isNumeric: true),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL DE VENTA', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
              Text('S/ ${totalVenta.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSeccionGastos() {
    return _buildCardWrapper(
      colorHeader: const Color(0xFF8B3A0F),
      title: '💵 GASTOS DEL MUELLE',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField("FACTURACIÓN", "0", _facturacionController, isNumeric: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("PERSONAL", "0", _personalController, isNumeric: true)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField("APOYO", "0", _apoyoController, isNumeric: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("AGUA", "0", _aguaController, isNumeric: true)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFFF4D1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL GASTOS', style: TextStyle(color: Color(0xFF8B3A0F), fontWeight: FontWeight.bold, fontSize: 11)),
                Text('S/ ${totalGastos.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF8B3A0F), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSeccionTotales() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF321A98), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TOTAL NETO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('Venta - Gastos', style: TextStyle(color: Colors.white54, fontSize: 9))]),
              Text('S/ ${totalNeto.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            ],
          ),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniLabel("VENTA", totalVenta),
              _buildMiniLabel("GASTOS", totalGastos),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniLabel(String label, double val) {
    return Column(children: [Text(label, style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 9, fontWeight: FontWeight.bold)), Text('S/ ${val.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))]);
  }

  Widget _buildBotonRegistrar() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0077B6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () => debugPrint("Guardando..."),
        child: const Text('REGISTRAR EMBARCACIÓN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- UTILES ---

  Widget _buildCardWrapper({required Color colorHeader, required String title, required Widget child}) {
    return Column(
      children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: colorHeader, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))), child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))), child: child),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 12),
          onChanged: (v) => _calcularTodo(),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade100)),
    );
  }
}
