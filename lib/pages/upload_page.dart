import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:resume_analyzer_web/pages/login_page.dart';
import 'package:resume_analyzer_web/pages/result_page.dart';
import 'package:resume_analyzer_web/services/api_service.dart';
import 'package:resume_analyzer_web/services/auth_service.dart';
import 'package:resume_analyzer_web/theme.dart';

// What the backend scores, shown so people know what is being judged.
const _scoring = [
  ('Contact info', 10),
  ('Sections', 20),
  ('Skills', 25),
  ('Impact', 30),
  ('Length & style', 15),
];

const _maxBytes = 5 * 1024 * 1024; // matches the 5MB limit on the backend

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _api = ApiService();
  PlatformFile? _file;
  bool _loading = false;
  String? _error;

  Future<void> _pick() async {
    if (_loading) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc'],
      withData: true, // required on web: gives us the file bytes
    );
    if (result == null) return; // user cancelled
    final file = result.files.single;

    if (file.size > _maxBytes) {
      setState(() {
        _file = null;
        _error = 'That file is over 5 MB. Choose a smaller PDF or Word file.';
      });
      return;
    }
    setState(() {
      _file = file;
      _error = null;
    });
  }

  Future<void> _analyze() async {
    if (_file == null || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.uploadAndAnalyze(_file!);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultPage(result: result)),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Log out'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Brand(),
                  const SizedBox(height: 56),
                  LayoutBuilder(builder: (context, c) {
                    final wide = c.maxWidth >= 860;
                    final intro = _Intro(wide: wide);
                    final panel = _buildPanel();
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: intro),
                          const SizedBox(width: 56),
                          Expanded(flex: 5, child: panel),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [intro, const SizedBox(height: 32), panel],
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    final hasFile = _file != null;

    final Widget content = hasFile ? _fileContent() : _emptyContent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: AppColors.petrol.withValues(alpha: 0.35),
            radius: 20,
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: (!hasFile && !_loading) ? _pick : null,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: content,
              ),
            ),
          ),
        ),
        if (_error != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bad.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, size: 18, color: AppColors.bad),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_error!,
                      style: AppText.body(size: 14, color: AppColors.bad)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _emptyContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.petrol.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.upload_file_outlined,
                color: AppColors.petrol, size: 28),
          ),
        ),
        const SizedBox(height: 20),
        Text('Choose your resume',
            textAlign: TextAlign.center, style: AppText.display(22)),
        const SizedBox(height: 6),
        Text('PDF or Word, up to 5 MB',
            textAlign: TextAlign.center, style: AppText.muted()),
        const SizedBox(height: 24),
        FilledButton(onPressed: _pick, child: const Text('Choose file')),
      ],
    );
  }

  Widget _fileContent() {
    final file = _file!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.petrol),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(weight: FontWeight.w600)),
                    Text(_formatSize(file.size),
                        style: AppText.muted(size: 13)),
                  ],
                ),
              ),
              TextButton(
                onPressed: _loading ? null : _pick,
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _analyze,
          child: _loading
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('Reading your resume...',
                  style: AppText.body(
                      weight: FontWeight.w600, color: Colors.white)),
            ],
          )
              : const Text('Analyze resume'),
        ),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.petrol,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description, color: AppColors.marker, size: 18),
        ),
        const SizedBox(width: 10),
        Text('Resume Analyzer', style: AppText.display(20)),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  final bool wide;
  const _Intro({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('See how your resume reads to a recruiter.',
            style: AppText.display(wide ? 52 : 38)),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            'Upload a PDF or Word file and get a score out of 100, '
                'plus specific things to fix.',
            style: AppText.muted(size: 18),
          ),
        ),
        const SizedBox(height: 36),
        Text('What we check', style: AppText.body(weight: FontWeight.w600)),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              for (final (name, points) in _scoring)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.line)),
                  ),
                  child: Row(
                    children: [
                      Text(name, style: AppText.body()),
                      const Spacer(),
                      Text('$points points', style: AppText.muted()),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(1),
        Radius.circular(radius),
      ));
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 8), paint);
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}