import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../dominio/entidades/cuadre_entidad.dart';
import '../controladores/controlador_cuadres.dart';

class FormularioCuadreTabs extends ConsumerStatefulWidget {
  const FormularioCuadreTabs({super.key});

  @override
  ConsumerState<FormularioCuadreTabs> createState() => _FormularioCuadreTabsState();
}

class _FormularioCuadreTabsState extends ConsumerState<FormularioCuadreTabs> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controladores Generales
  final _placaCtrl = TextEditingController();
  final _fechaZarpeCtrl = TextEditingController();

  // Listas de items en memoria antes de guardar
  final List<CompraEntidad> _compras = [];
  final List<GastoEntidad> _gastos = [];
  final List<VentaEntidad> _ventas = [];

  void _guardarCuadre() {
    if (!_formKey.currentState!.validate()) return;
    
    // Validar al menos una compra
    if (_compras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos una Compra (Embarcación)')),
      );
      return;
    }

    // Calcular estado: si no hay ventas, es borrador.
    final estado = _ventas.isEmpty ? 'borrador' : 'completo';

    final nuevoCuadre = CuadreEntidad(
      id: const Uuid().v4(),
      usuarioId: 'local-placeholder', // Esto debe reemplazarse por el ID real de Supabase Auth
      placa: _placaCtrl.text,
      fechaZarpe: _fechaZarpeCtrl.text,
      estado: estado,
      compras: _compras,
      gastos: _gastos,
      ventas: _ventas,
    );

    ref.read(cuadresProvider.notifier).guardarCuadre(nuevoCuadre);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Cuadre')),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep += 1);
            } else {
              _guardarCuadre();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              Navigator.of(context).pop();
            }
          },
          steps: [
            Step(
              title: const Text('General'),
              isActive: _currentStep >= 0,
              content: Column(
                children: [
                  TextFormField(
                    controller: _placaCtrl,
                    decoration: const InputDecoration(labelText: 'Placa Cámara'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: _fechaZarpeCtrl,
                    decoration: const InputDecoration(labelText: 'Fecha de Zarpe (Opcional)'),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Compras'),
              isActive: _currentStep >= 1,
              content: Column(
                children: [
                  ElevatedButton(
                    onPressed: _agregarCompraDialog,
                    child: const Text('Añadir Compra (Embarcación)'),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _compras.length,
                    itemBuilder: (ctx, i) {
                      final c = _compras[i];
                      return ListTile(
                        title: Text('${c.embarcacion} - ${c.producto}'),
                        subtitle: Text('${c.kilos}kg a S/${c.precioUnitario}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() => _compras.removeAt(i)),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
            Step(
              title: const Text('Gastos'),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  ElevatedButton(
                    onPressed: _agregarGastoDialog,
                    child: const Text('Añadir Gasto'),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _gastos.length,
                    itemBuilder: (ctx, i) {
                      final g = _gastos[i];
                      return ListTile(
                        title: Text('${g.tipo}: ${g.concepto}'),
                        subtitle: Text('S/${g.total}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() => _gastos.removeAt(i)),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
            Step(
              title: const Text('Ventas'),
              isActive: _currentStep >= 3,
              content: Column(
                children: [
                  const Text('Nota: Si no ingresa ventas, el cuadre se guardará como Borrador.', style: TextStyle(color: Colors.orange)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _agregarVentaDialog,
                    child: const Text('Añadir Venta'),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ventas.length,
                    itemBuilder: (ctx, i) {
                      final v = _ventas[i];
                      return ListTile(
                        title: Text('${v.lugar} - ${v.producto}'),
                        subtitle: Text('${v.kilos}kg a S/${v.precioUnitario}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() => _ventas.removeAt(i)),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _agregarCompraDialog() {
    final embCtrl = TextEditingController();
    String _productoSeleccionado = 'POTA';
    final kilosCtrl = TextEditingController();
    final precioCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Nueva Compra'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: embCtrl, decoration: const InputDecoration(labelText: 'Embarcación')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _productoSeleccionado,
                    dropdownColor: const Color(0xFF162A5B),
                    decoration: const InputDecoration(labelText: 'Producto'),
                    items: ["POTA", "JUREL", "BONITO", "CABALLA"]
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (BuildContext context) {
                      return ["POTA", "JUREL", "BONITO", "CABALLA"].map((String value) {
                        final Map<String, Color> coloresProductos = {
                          "POTA": const Color(0xFFE040FB),
                          "JUREL": const Color(0xFF29B6F6),
                          "BONITO": const Color(0xFF00E676),
                          "CABALLA": const Color(0xFFFFB74D),
                        };
                        final colorTag = coloresProductos[value] ?? const Color(0xFF00E5FF);
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorTag.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colorTag.withValues(alpha: 0.35), width: 1.2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: colorTag,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: colorTag,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                    onChanged: (val) {
                      if (val != null) {
                        setStateDialog(() {
                          _productoSeleccionado = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: kilosCtrl, decoration: const InputDecoration(labelText: 'Kilos'), keyboardType: TextInputType.number),
                  TextField(controller: precioCtrl, decoration: const InputDecoration(labelText: 'Precio/Kg'), keyboardType: TextInputType.number),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              TextButton(
                onPressed: () {
                  final k = double.tryParse(kilosCtrl.text) ?? 0;
                  final p = double.tryParse(precioCtrl.text) ?? 0;
                  setState(() {
                    _compras.add(CompraEntidad(
                      id: const Uuid().v4(),
                      cuadreId: '', // Se asignará en base de datos local
                      embarcacion: embCtrl.text,
                      producto: _productoSeleccionado,
                      kilos: k,
                      precioUnitario: p,
                      total: k * p,
                    ));
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              )
            ],
          );
        }
      ),
    );
  }

  void _agregarGastoDialog() {
    final tipoCtrl = TextEditingController(text: 'Muelle');
    final conceptoCtrl = TextEditingController();
    final totalCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Gasto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: tipoCtrl, decoration: const InputDecoration(labelText: 'Tipo (Muelle/Admin)')),
              TextField(controller: conceptoCtrl, decoration: const InputDecoration(labelText: 'Concepto (Hielo, Personal)')),
              TextField(controller: totalCtrl, decoration: const InputDecoration(labelText: 'Total S/'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final t = double.tryParse(totalCtrl.text) ?? 0;
              setState(() {
                _gastos.add(GastoEntidad(
                  id: const Uuid().v4(),
                  cuadreId: '',
                  tipo: tipoCtrl.text,
                  concepto: conceptoCtrl.text,
                  cantidad: 1,
                  costoUnitario: t,
                  total: t,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }

  void _agregarVentaDialog() {
    final lugarCtrl = TextEditingController();
    String _productoSeleccionado = 'POTA';
    final kilosCtrl = TextEditingController();
    final precioCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Nueva Venta'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: lugarCtrl, decoration: const InputDecoration(labelText: 'Destino/Lugar')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _productoSeleccionado,
                    dropdownColor: const Color(0xFF162A5B),
                    decoration: const InputDecoration(labelText: 'Producto'),
                    items: ["POTA", "JUREL", "BONITO", "CABALLA"]
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (BuildContext context) {
                      return ["POTA", "JUREL", "BONITO", "CABALLA"].map((String value) {
                        final Map<String, Color> coloresProductos = {
                          "POTA": const Color(0xFFE040FB),
                          "JUREL": const Color(0xFF29B6F6),
                          "BONITO": const Color(0xFF00E676),
                          "CABALLA": const Color(0xFFFFB74D),
                        };
                        final colorTag = coloresProductos[value] ?? const Color(0xFF00E5FF);
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorTag.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colorTag.withValues(alpha: 0.35), width: 1.2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: colorTag,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: colorTag,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                    onChanged: (val) {
                      if (val != null) {
                        setStateDialog(() {
                          _productoSeleccionado = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: kilosCtrl, decoration: const InputDecoration(labelText: 'Kilos'), keyboardType: TextInputType.number),
                  TextField(controller: precioCtrl, decoration: const InputDecoration(labelText: 'Precio Venta'), keyboardType: TextInputType.number),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              TextButton(
                onPressed: () {
                  final k = double.tryParse(kilosCtrl.text) ?? 0;
                  final p = double.tryParse(precioCtrl.text) ?? 0;
                  setState(() {
                    _ventas.add(VentaEntidad(
                      id: const Uuid().v4(),
                      cuadreId: '',
                      lugar: lugarCtrl.text,
                      producto: _productoSeleccionado,
                      kilos: k,
                      precioUnitario: p,
                      total: k * p,
                    ));
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              )
            ],
          );
        }
      ),
    );
  }
}
