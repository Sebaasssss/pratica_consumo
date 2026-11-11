# Evidencias — Recetario UTEZ

**Nombre:** Sebastián Jiménez
**Matrícula:** 20233tn097
**Fecha:** 10 de noviembre de 2026
**Dispositivo donde se probó:** Emulador Android de Android Studio: Pixel 3, API 35

## 1. Del JSON a Dart

| JSON | Campo Dart | Tipo | Regla (obligatorio, tolerado, valor por defecto) |
|---|---|---|---|
| `id` | `id` | `int` | Obligatorio. Si falta o no es entero → `FormatException`. |
| `name` | `nombre` | `String` | Obligatorio. Si falta o no es texto → `FormatException`. |
| `cuisine` | `cocina` | `String` | Obligatorio. Si falta o no es texto → `FormatException`. |
| `difficulty` | `dificultad` | `Dificultad` | Tolerado. `Easy`/`Medium`/`Hard` → `facil`/`media`/`dificil`; cualquier otro valor, `null` o un número → `desconocida` ("Sin dato"). Nunca lanza error. |
| `prepTimeMinutes` | `minutosPreparacion` | `int` | Obligatorio. Si falta o no es entero → `FormatException`. |
| `cookTimeMinutes` | `minutosCoccion` | `int` | Obligatorio. Si falta o no es entero → `FormatException`. |
| `servings` | `porciones` | `int` | Obligatorio. Si falta o no es entero (p. ej. `"4"`) → `FormatException`. |
| `rating` | `calificacion` | `double` | Obligatorio. Acepta entero (`5`) o decimal (`4.6`) como `num` y se guarda con `.toDouble()`. |
| `tags` | `etiquetas` | `List<String>` | Opcional. Si falta → `[]`. Si no es lista o tiene un elemento que no es texto → `FormatException`. |
| `ingredients` | `ingredientes` | `List<String>` | Opcional. Si falta → `[]`. Si no es lista o tiene un elemento que no es texto → `FormatException`. |
| `recipes` | `PaginaRecetas.recetas` | `List<Receta>` | Obligatorio. Cada elemento debe ser objeto; una lista vacía es válida (no es error). |
| `total` | `PaginaRecetas.total` | `int` | Obligatorio. Si falta → `FormatException`. |
| _(demás campos: `image`, `instructions`, `skip`, `limit`, …)_ | — | — | Se ignoran. |

## 2. Escenarios probados con el servicio real

| Escenario | Cómo lo provoqué | Qué vio la persona | Línea de la bitácora | Captura | Prueba del kit que lo cubre |
|---|---|---|---|---|---|
| Éxito | Busqué `chicken` con la app normal. | Encabezado "Mostrando 8 de 8 recetas · Rápidas: 1" y tarjetas (Chicken Alfredo Pasta, Mango Salsa Chicken, Chicken Biryani…) con cocina, dificultad, tiempo, porciones y calificación. | `← 200 GET /recipes/search (2821 ms)` | `capturas/1_exito.jpeg` | etapa3 `200 → PaginaRecetas`; etapa5 `texto + botón → indicador y botón apagado → tarjetas` |
| Vacío | Busqué `zzzz` con la app normal. | El mensaje `No encontramos recetas para "zzzz".` sin tarjetas ni botón Reintentar. | `← 200 GET /recipes/search (1176 ms)` | `capturas/2_vacio.jpeg` | etapa3 `200 sin resultados → página vacía`; etapa5 `vacío con texto dice qué se buscó` |
| Error del servidor | Cambio temporal A en `main.dart` (la ruta se cambia a `/http/503`) y busqué `chicken`. | `El recetario no está disponible (503). Intenta más tarde.` y el botón Reintentar. | `✗ badResponse 503 GET /http/503 (1710 ms)` | `capturas/3_error_servidor.jpeg` | etapa3 `503 → ErrorDelServidor(503)`; etapa4 `FallaRed → Fallidas con el mensaje de mensajePara` |
| Sin red | Activé modo avión en el emulador y busqué `chicken`. | `Sin conexión. Revisa tu red e intenta de nuevo.` y el botón Reintentar. | `✗ connectionError GET /recipes/search (249 ms)` | `capturas/4_sin_red.jpeg` | etapa3 `sin red → SinConexion`; etapa5 `error → mensaje y Reintentar repite la misma búsqueda` |
| Tiempo agotado | Cambio temporal B en `main.dart` (`delay` de 5000 ms y timeouts de 2 s) y toqué Buscar recetas con el campo vacío. | Indicador de carga unos segundos y luego `El recetario tardó demasiado en responder. Intenta de nuevo.` con el botón Reintentar. | `✗ receiveTimeout GET /recipes (3269 ms)` | `capturas/5_tiempo_agotado.jpeg` | etapa3 `connectTimeout → TiempoAgotado` y `receiveTimeout → TiempoAgotado` |

## 3. Preguntas de reflexión

1. **¿En qué se diferencian el escenario "Error del servidor" y "Sin red" desde el punto de vista de HTTP?**
   En "Error del servidor" sí hubo comunicación HTTP completa: la petición llegó a DummyJSON y el servidor contestó con una respuesta que tiene código de estado (503). Dio la marca como `badResponse` y la traducimos a `ErrorDelServidor(503)`. En "Sin red" nunca existe una respuesta HTTP: falla la conexión (DNS/socket) antes de enviar la petición, así que no hay código de estado; Dio la marca como `connectionError` y la traducimos a `SinConexion`. Por eso el mensaje del 503 dice "intenta más tarde" (el problema es del servidor) y el de sin red dice "revisa tu red" (el problema es del dispositivo).

2. **¿Por qué "Vacío" no es un error?**
   Porque la petición funcionó: el servidor respondió `200` con un JSON válido `{"recipes": [], "total": 0}`. Simplemente no hay recetas que coincidan con lo que se buscó. Es un resultado legítimo del dominio, por eso tiene su propio estado (`RecetasVacias`) con un mensaje que dice qué se buscó, y no muestra el botón Reintentar (repetir la misma búsqueda daría el mismo resultado).

3. **La búsqueda de la persona viaja en la query. ¿Por qué tu bitácora no la escribe?**
   Porque lo que la persona escribe es un dato suyo y puede incluir información personal; la bitácora puede terminar en consolas, archivos o servicios de monitoreo que ven otras personas. La bitácora solo necesita método, ruta, código y tiempo para diagnosticar fallas, así que usa `options.path` (`/recipes/search`) y nunca `options.uri` ni `queryParameters`, que incluirían `?q=...`.

4. **Si DummyJSON cambiara `rating` por `score`, ¿qué archivos tendrías que modificar y por qué solo esos?**
   Solo `lib/datos/recetas_json.dart`: la llave `'rating'` del patrón en `recetaDesdeJson` pasaría a ser `'score'`. El dominio (`Receta.calificacion`), el ViewModel y las vistas no cambian porque nunca ven el JSON: trabajan con objetos `Receta`. La traducción JSON → Dart está aislada en una sola función de la capa de datos, así que un cambio en el formato del servicio solo toca esa capa.
