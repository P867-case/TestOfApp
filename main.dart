import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web/web.dart' as web;

void main() {
  runApp(const MyApp());
}

/// Основное приложение, которое запускает главный виджет.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test of app',
      home: const HomePage(),
    );
  }
}

/// Виджет домашней страницы, который управляет состоянием и отображением.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// Состояние домашней страницы, которое управляет логикой и UI.
class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isActiveButton = false;
  bool _isDarkened = false;
  bool _isFullscreen = true;

  /// Обработчик изменения текста в поле ввода.
  void _onTextChanged(String text) {
    setState(() => _isActiveButton = text.isNotEmpty);
  }

  /// Добавляет изображение в HTML-контейнер.
  void _addImageToHtml(String url) {
    if (url.isEmpty) return;

    final container = html.document.getElementById('image-container');
    container?.innerHtml = '';

    final imageElement = html.ImageElement()
      ..src = url
      ..alt = 'Image from URL'
      ..style.width = '100%'
      ..style.height = '100%';

    imageElement.onDoubleClick.listen((_) => _toggleFullscreen());

    container?.append(imageElement);
  }

  /// Переключает полноэкранный режим.
  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
  }

  /// Обработчик создания HTML-элемента.
  void _onElementCreated(web.HTMLDivElement element) {
    element.id = 'image-container';

    final observer = web.ResizeObserver((entries, observer) {
      if (element.isConnected) {
        observer.disconnect();
        element.style.backgroundColor = 'green';
      }
    } as web.ResizeObserverCallback);

    observer.observe(element);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; 
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey
                    ),
                    height: _isFullscreen ? size.height - 150 : size.height - 100,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: HtmlElementView.fromTagName(
                        tagName: 'div',
                        onElementCreated: (element) => _onElementCreated(element as web.HTMLDivElement),
                      ),
                    ),
                  ),
                ),
                if (_isFullscreen)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(hintText: 'Image URL'),
                          controller: _urlController,
                          onChanged: _onTextChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isActiveButton ? () => _addImageToHtml(_urlController.text) : null,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          if (_isDarkened)
            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.darken),
              child: const ModalBarrier(dismissible: false),
            ),
          Positioned(
            right: 15,
            bottom: 15,
            child: PopupMenuButton<String>(
              offset: const Offset(0, -120),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.menu, size: 26, color: Colors.white),
              ),
              onCanceled: () => setState(() => _isDarkened = false),
              onOpened: () => setState(() => _isDarkened = true),
              onSelected: (value) {
                if (value == 'Exit fullscreen') {
                  setState(() {
                    _isDarkened = false;
                    _isFullscreen = true;
                  });
                } else {
                  setState(() {
                    _isDarkened = false;
                    _isFullscreen = false;
                  });
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'Enter fullscreen', child: Text('Enter fullscreen')),
                PopupMenuItem(value: 'Exit fullscreen', child: Text('Exit fullscreen')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
