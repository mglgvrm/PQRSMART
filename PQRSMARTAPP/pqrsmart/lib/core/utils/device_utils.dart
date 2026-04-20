import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceUtils {
  /// Obtener el ancho del dispositivo
  static double getWitdh(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtener el ancho del dispositivo
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Detecta si el dispositivo es un móvil (menos de 600px de ancho)
  static bool isMobile(BuildContext context) {
    return getWitdh(context) < 600 && !kIsWeb;
  }

  /// Detecta si el dispositivo es una tablet (más de 600px de ancho)
  static bool isTablet(BuildContext context) {
    return getWitdh(context) >= 600 && !kIsWeb;
  }

  /// Detecta si la plataforma es Web
  static bool isWeb() {
    return kIsWeb;
  }
}
