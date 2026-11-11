import 'package:flutter/material.dart';

import '../dominio/receta.dart';

class TarjetaReceta extends StatelessWidget {
  const TarjetaReceta({super.key, required this.receta});

  final Receta receta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(receta.nombre, style: tema.textTheme.titleMedium),
                ),
                if (receta.esRapida) ...[
                  const SizedBox(width: 8),
                  const Chip(
                    label: Text('Rápida'),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${receta.cocina} · ${receta.dificultad.etiqueta}',
              style: tema.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tiempo: ${receta.tiempoTotal} min · '
              'Porciones: ${receta.porciones}',
            ),
            Text('Calificación: ${receta.calificacion.toStringAsFixed(1)}'),
          ],
        ),
      ),
    );
  }
}
