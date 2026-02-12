import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/constants/app_colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_totalPages > 0)
              Text(
                'Page $_currentPage of $_totalPages',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _pdfController.zoomLevel = _pdfController.zoomLevel - 0.25;
            },
            icon: const Icon(Icons.zoom_out_rounded, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              _pdfController.zoomLevel = _pdfController.zoomLevel + 0.25;
            },
            icon: const Icon(Icons.zoom_in_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_error != null)
            _buildErrorState()
          else
            SfPdfViewer.network(
              widget.pdfUrl,
              key: _pdfViewerKey,
              controller: _pdfController,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableDoubleTapZooming: true,
              onDocumentLoaded: (details) {
                setState(() {
                  _isLoading = false;
                  _totalPages = details.document.pages.count;
                });
              },
              onDocumentLoadFailed: (details) {
                setState(() {
                  _isLoading = false;
                  _error = details.description;
                });
              },
              onPageChanged: (details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
            ),
          if (_isLoading)
            Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading PDF...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to Load PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An unknown error occurred',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
