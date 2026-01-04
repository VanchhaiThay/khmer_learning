import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class KhmerPdfViewer extends StatefulWidget {
  final String title;
  final String pdfPath;

  const KhmerPdfViewer({
    super.key,
    required this.title,
    required this.pdfPath,
  });

  @override
  State<KhmerPdfViewer> createState() => _KhmerPdfViewerState();
}

class _KhmerPdfViewerState extends State<KhmerPdfViewer> {
  late PdfViewerController _pdfController;
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  void _goToFirstPage() => _pdfController.jumpToPage(1);
  void _goToLastPage() => _pdfController.jumpToPage(_totalPages);
  void _zoomIn() => _pdfController.zoomLevel += 0.25;
  void _zoomOut() {
    if (_pdfController.zoomLevel > 1) _pdfController.zoomLevel -= 0.25;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SfPdfViewer.asset(
            widget.pdfPath,
            controller: _pdfController,
            onDocumentLoaded: (details) {
              setState(() {
                _isLoading = false;
                _totalPages = details.document.pages.count;
              });
            },
            onPageChanged: (details) => setState(() => _currentPage = details.newPageNumber),
            onDocumentLoadFailed: (details) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load PDF: ${details.error}')),
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Page $_currentPage / $_totalPages',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            onPressed: _zoomIn,
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            onPressed: _zoomOut,
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "first_page",
            mini: true,
            onPressed: _goToFirstPage,
            child: const Icon(Icons.first_page),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "last_page",
            mini: true,
            onPressed: _goToLastPage,
            child: const Icon(Icons.last_page),
          ),
        ],
      ),
    );
  }
}
