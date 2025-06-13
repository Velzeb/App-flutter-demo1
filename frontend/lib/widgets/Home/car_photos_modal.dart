import 'package:flutter/material.dart';
import '../../models/carAvailable.dart';
import '../../services/image_service.dart';


/// Modal que muestra un carrusel con las fotos del auto (frontal, trasera, interior).
class CarPhotosModal extends StatefulWidget {
  final CarAvailable car;
  const CarPhotosModal({Key? key, required this.car}) : super(key: key);

  /// Lanza el diálogo
  static Future<void> show(BuildContext context, CarAvailable car) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: CarPhotosModal(car: car),
      ),
    );
  }

  @override
  _CarPhotosModalState createState() => _CarPhotosModalState();
}

class _CarPhotosModalState extends State<CarPhotosModal> {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<String> get _imageUrls => [
    ImageService.getFullImageUrl(widget.car.imageFront.toString()),
    ImageService.getFullImageUrl(widget.car.imageRear.toString()),
    ImageService.getFullImageUrl(widget.car.imageInterior.toString()),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Carrusel
          SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _imageUrls.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrls[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                // Flechas de navegación
                Positioned(
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, size: 32),
                    onPressed: () {
                      if (_currentIndex > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
                Positioned(
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, size: 32),
                    onPressed: () {
                      if (_currentIndex < _imageUrls.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Indicadores
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_imageUrls.length, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == i ? 12 : 8,
                height: _currentIndex == i ? 12 : 8,
                decoration: BoxDecoration(
                  color: _currentIndex == i
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Botón Cerrar
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}
