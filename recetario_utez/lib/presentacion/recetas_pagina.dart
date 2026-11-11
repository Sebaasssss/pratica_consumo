import 'package:flutter/material.dart';

import 'recetas_view_model.dart';
import 'tarjeta_receta.dart';

class RecetasPagina extends StatefulWidget {
  const RecetasPagina({super.key, required this.vm});

  final RecetasViewModel vm;

  @override
  State<RecetasPagina> createState() => _RecetasPaginaState();
}

class _RecetasPaginaState extends State<RecetasPagina> {
  final _texto = TextEditingController();

  RecetasViewModel get vm => widget.vm;

  void _buscar() => vm.buscar(_texto.text);

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetario UTEZ')),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                key: const Key('busqueda'),
                controller: _texto,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _buscar(),
                decoration: const InputDecoration(
                  labelText: '¿Qué quieres cocinar?',
                  hintText: 'pasta, chicken, pizza…',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                key: const Key('buscar'),
                onPressed: vm.cargando ? null : _buscar,
                child: const Text('Buscar recetas'),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    return switch (vm.estado) {
      RecetasInicial() => const _Aviso(
        'Escribe una receta o déjalo vacío y toca Buscar recetas.',
      ),
      RecetasCargando() => const Center(child: CircularProgressIndicator()),
      RecetasVacias(:final busqueda) => _Aviso(
        busqueda.isEmpty
            ? 'No hay recetas disponibles.'
            : 'No encontramos recetas para "$busqueda".',
      ),
      RecetasFallidas(:final mensaje) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mensaje, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: vm.reintentar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      RecetasListas(:final recetas, :final total) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Mostrando ${recetas.length} de $total recetas · '
              'Rápidas: ${vm.rapidas}',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recetas.length,
              itemBuilder: (context, i) => TarjetaReceta(receta: recetas[i]),
            ),
          ),
        ],
      ),
    };
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(texto, textAlign: TextAlign.center),
    ),
  );
}
