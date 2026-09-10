import 'dart:async';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

/// Bir .glb dosyasını yükleyip döndürülebilir/yakınlaştırılabilir 3D bir
/// önizleme olarak gösteren yeniden kullanılabilir bileşen.
///
/// [assetPath] değişince ("yönetmen kamerası" hissi için) bir-iki saniye
/// otomatik döner, sonra durup kontrolü kullanıcıya bırakır — bir "reveal
/// shot" hissi vermek için.
///
/// Kamera framing, ışıklandırma ve dokunma/fare ile döndürme davranışı
/// `model_viewer_plus`'ın (Google'ın `<model-viewer>` bileşenini saran)
/// kendi varsayılanlarından geliyor — bu, ham bir Three.js sahnesi değil,
/// hazır bir bileşen olduğu için ince taneli kontrol (özel geçiş
/// animasyonları, elle ışık rig'i) burada mümkün değil.
class VehicleViewer extends StatefulWidget {
  final String assetPath;
  final String alt;
  final double height;

  const VehicleViewer({
    super.key,
    required this.assetPath,
    required this.alt,
    this.height = 320,
  });

  @override
  State<VehicleViewer> createState() => _VehicleViewerState();
}

class _VehicleViewerState extends State<VehicleViewer> {
  static const _revealDuration = Duration(milliseconds: 1800);

  bool _autoRotate = true;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    _startReveal();
  }

  void _startReveal() {
    _autoRotate = true;
    _revealTimer?.cancel();
    _revealTimer = Timer(_revealDuration, () {
      if (!mounted) return;
      setState(() => _autoRotate = false);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      // assetPath değişince tüm bileşenin yeniden kurulmasını (dolayısıyla
      // yeni modelin yüklenmesini ve reveal döndürmesinin tekrar tetiklenmesini)
      // garanti etmek için key olarak kullanılıyor.
      key: ValueKey(widget.assetPath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ColoredBox(
          color: const Color(0xFF15151C),
          child: ModelViewer(
            src: widget.assetPath,
            alt: widget.alt,
            backgroundColor: const Color(0xFF15151C),
            autoRotate: _autoRotate,
            autoRotateDelay: 0,
            cameraControls: true,
            disableZoom: false,
            // model-viewer'ın hazır stüdyo ortam ışığı ön ayarı — sahneyi
            // düz beyazdan daha "premium" gösteren yumuşak bir HDR.
            environmentImage: 'neutral',
            shadowIntensity: 0.8,
            exposure: 1.0,
          ),
        ),
      ),
    );
  }
}
