/// Fallas posibles al pedir recetas, ya traducidas al lenguaje del dominio.
sealed class FallaRed implements Exception {
  const FallaRed();
}

/// No se pudo llegar al servidor (sin red, DNS, conexión rechazada...).
final class SinConexion extends FallaRed {
  const SinConexion();
}

/// El servidor tardó más de lo permitido.
final class TiempoAgotado extends FallaRed {
  const TiempoAgotado();
}

/// El servidor respondió con un código 5xx.
final class ErrorDelServidor extends FallaRed {
  const ErrorDelServidor(this.codigo);
  final int codigo;
}

/// El servidor rechazó la petición (4xx u otro código no exitoso).
final class PeticionRechazada extends FallaRed {
  const PeticionRechazada(this.codigo);
  final int codigo;
}

/// La respuesta llegó, pero no tiene la forma esperada.
final class RespuestaInvalida extends FallaRed {
  const RespuestaInvalida();
}
