import '../dominio/receta.dart';

/// Contrato: de dónde salen las recetas. La presentación solo conoce esto.
abstract class RecetasRepositorio {
  Future<PaginaRecetas> buscar({String texto = ''});
}
