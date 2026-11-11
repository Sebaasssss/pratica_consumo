import '../dominio/receta.dart';

/// Traduce el texto de DummyJSON a [Dificultad]. Nunca lanza error.
Dificultad dificultadDesdeTexto(Object? valor) => switch (valor) {
  'Easy' => Dificultad.facil,
  'Medium' => Dificultad.media,
  'Hard' => Dificultad.dificil,
  _ => Dificultad.desconocida,
};

/// Convierte un objeto JSON de DummyJSON en [Receta].
///
/// Obligatorios: id, name, cuisine, prepTimeMinutes, cookTimeMinutes,
/// servings y rating. Opcionales: tags e ingredients (lista vacía si faltan).
Receta recetaDesdeJson(Map<String, dynamic> json) {
  return switch (json) {
    {
      'id': int id,
      'name': String nombre,
      'cuisine': String cocina,
      'prepTimeMinutes': int preparacion,
      'cookTimeMinutes': int coccion,
      'servings': int porciones,
      'rating': num calificacion,
    } =>
      Receta(
        id: id,
        nombre: nombre,
        cocina: cocina,
        dificultad: dificultadDesdeTexto(json['difficulty']),
        minutosPreparacion: preparacion,
        minutosCoccion: coccion,
        porciones: porciones,
        calificacion: calificacion.toDouble(),
        etiquetas: _textosOpcionales(json, 'tags'),
        ingredientes: _textosOpcionales(json, 'ingredients'),
      ),
    _ => throw FormatException('Receta con campos faltantes o inválidos', json),
  };
}

/// Convierte la respuesta completa ({recipes, total, ...}) en [PaginaRecetas].
PaginaRecetas paginaDesdeJson(Map<String, dynamic> json) {
  return switch (json) {
    {'recipes': List<dynamic> lista, 'total': int total} => PaginaRecetas(
      recetas: [
        for (final elemento in lista)
          if (elemento is Map<String, dynamic>)
            recetaDesdeJson(elemento)
          else
            throw FormatException('Elemento de "recipes" no es objeto', elemento),
      ],
      total: total,
    ),
    _ => throw FormatException('Página sin "recipes" o sin "total"', json),
  };
}

/// Lista de textos opcional: si falta → []; si no es lista de textos → error.
List<String> _textosOpcionales(Map<String, dynamic> json, String llave) {
  final valor = json[llave];
  if (valor == null) return const [];
  if (valor is! List) {
    throw FormatException('"$llave" debe ser una lista', valor);
  }
  final textos = <String>[];
  for (final elemento in valor) {
    if (elemento is! String) {
      throw FormatException('"$llave" debe contener solo textos', elemento);
    }
    textos.add(elemento);
  }
  return List.unmodifiable(textos);
}
