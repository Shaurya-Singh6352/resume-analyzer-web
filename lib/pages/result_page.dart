import 'package:flutter/material.dart';
import 'package:resume_analyzer_web/models/analysis_result.dart';
import 'package:resume_analyzer_web/theme.dart';

// One-line explanation under each category. Falls back to nothing if the
// backend adds a category we don't know about yet.
const _hints = {
  'Contact info': 'Email, phone, LinkedIn, GitHub',
  'Sections': 'Education, Experience, Skills and Projects headings',
  'Skills': 'Recognised technical skills',
  'Impact': 'Action verbs, measurable results, no weak phrases',
  'Length & style': 'About 1 to 2 pages, no first-person wording',
};

class ResultPage extends StatelessWidget {
  final AnalysisResult result;
  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: LayoutBuilder(builder: (context, c) {
                final wide = c.maxWidth >= 860;

                final headline = _ScoreHeadline(result: result, wide: wide);
                final breakdown = _Breakdown(result: result);
                final fixes = _FixList(items: result.suggestions);
                final working = _WorkingList(items: result.strengths);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(fileName: result.fileName),
                    const SizedBox(height: 32),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: headline),
                          const SizedBox(width: 56),
                          Expanded(flex: 6, child: breakdown),
                        ],
                      )
                    else ...[
                      headline,
                      const SizedBox(height: 32),
                      breakdown,
                    ],
                    const SizedBox(height: 40),
                    const Divider(color: AppColors.line, height: 1),
                    const SizedBox(height: 32),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: fixes),
                          const SizedBox(width: 56),
                          Expanded(flex: 4, child: working),
                        ],
                      )
                    else ...[
                      fixes,
                      const SizedBox(height: 32),
                      working,
                    ],
                    const SizedBox(height: 40),
                    const Divider(color: AppColors.line, height: 1),
                    const SizedBox(height: 32),
                    _SkillsSection(keywords: result.missingKeywords),
                    const SizedBox(height: 48),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String fileName;
  const _TopBar({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Analyze another resume'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            fileName,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.muted(size: 14),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppText.display(22));
}

// ---------------------------------------------------------------------------
// Score
// ---------------------------------------------------------------------------

class _ScoreHeadline extends StatelessWidget {
  final AnalysisResult result;
  final bool wide;
  const _ScoreHeadline({required this.result, required this.wide});

  (String, String) _copy(int score, int fixes) {
    final fixText = fixes == 1 ? '1 fix' : '$fixes fixes';
    if (score >= 80) {
      return (
      'A strong resume.',
      fixes == 0 ? 'Nothing urgent to fix.' : '$fixText left to polish it.',
      );
    }
    if (score >= 60) {
      return ('A solid base.', 'Work through the fixes to move it up.');
    }
    return ('Needs work.', 'Start with the fixes listed here.');
  }

  @override
  Widget build(BuildContext context) {
    final score = result.overallScore;
    final color = scoreColor(score / 100);
    final (headline, sub) = _copy(score, result.suggestions.length);
    final numeralSize = wide ? 120.0 : 88.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The one animated moment: the number counts up when the page opens.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: score.toDouble()),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${value.round()}',
                style: AppText.display(numeralSize).copyWith(
                  height: 1,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text('/ 100', style: AppText.muted(size: 22)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(headline, style: AppText.display(30)),
        const SizedBox(height: 6),
        Text(sub, style: AppText.muted(size: 17)),
      ],
    );
  }
}

class _Breakdown extends StatelessWidget {
  final AnalysisResult result;
  const _Breakdown({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Where your points came from'),
        const SizedBox(height: 16),
        _PointsBar(categories: result.categories),
        const SizedBox(height: 20),
        for (final c in result.categories) _CategoryRow(category: c),
      ],
    );
  }
}

/// One bar for the whole 100 points. Each segment is as wide as its category's
/// maximum, and filled by how much of it was earned, so you can see at a
/// glance where points were lost.
class _PointsBar extends StatelessWidget {
  final List<CategoryScore> categories;
  const _PointsBar({required this.categories});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => SizedBox(
        height: 14,
        child: Row(
          children: [
            for (int i = 0; i < categories.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                flex: categories[i].max,
                child: _Segment(category: categories[i], progress: t),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final CategoryScore category;
  final double progress;
  const _Segment({required this.category, required this.progress});

  @override
  Widget build(BuildContext context) {
    final fraction =
    category.max == 0 ? 0.0 : category.score / category.max;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          Container(color: AppColors.track),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (fraction * progress).clamp(0.0, 1.0),
            child: Container(color: scoreColor(fraction)),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryScore category;
  const _CategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    final fraction =
    category.max == 0 ? 0.0 : category.score / category.max;
    final hint = _hints[category.name];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              color: scoreColor(fraction),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name,
                    style: AppText.body(weight: FontWeight.w600)),
                if (hint != null) Text(hint, style: AppText.muted(size: 14)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${category.score} / ${category.max}',
              style: AppText.body(weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feedback
// ---------------------------------------------------------------------------

/// Shows the first few suggestions, with a toggle for the rest, so a weak
/// resume doesn't open with a wall of fourteen tips.
class _FixList extends StatefulWidget {
  final List<String> items;
  const _FixList({required this.items});

  @override
  State<_FixList> createState() => _FixListState();
}

class _FixListState extends State<_FixList> {
  static const _limit = 5;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final all = widget.items;
    final shown = _expanded ? all : all.take(_limit).toList();
    final hidden = all.length - shown.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('What to fix'),
        const SizedBox(height: 16),
        if (all.isEmpty)
          Text('Nothing to fix. This resume covers everything we check.',
              style: AppText.muted()),
        for (final s in shown) _FixRow(text: s),
        if (all.length > _limit)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'Show fewer' : 'Show $hidden more'),
          ),
      ],
    );
  }
}

class _FixRow extends StatelessWidget {
  final String text;
  const _FixRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Highlighter mark: the yellow is used only for things to act on.
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.marker,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(text, style: AppText.body())),
          ],
        ),
      ),
    );
  }
}

class _WorkingList extends StatelessWidget {
  final List<String> items;
  const _WorkingList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("What's working"),
        const SizedBox(height: 16),
        if (items.isEmpty)
          Text('Nothing stands out yet. Start with the fixes.',
              style: AppText.muted()),
        for (final s in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle,
                      size: 18, color: AppColors.good),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(s, style: AppText.body())),
              ],
            ),
          ),
      ],
    );
  }
}

class _SkillsSection extends StatelessWidget {
  final List<String> keywords;
  const _SkillsSection({required this.keywords});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Skills to consider adding'),
        const SizedBox(height: 6),
        Text('Common in job listings but not found in your resume.',
            style: AppText.muted()),
        const SizedBox(height: 16),
        if (keywords.isEmpty)
          Text('You already cover the common skills we check.',
              style: AppText.body())
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [for (final k in keywords) _SkillPill(label: k)],
          ),
      ],
    );
  }
}

class _SkillPill extends StatelessWidget {
  final String label;
  const _SkillPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, size: 16, color: AppColors.petrol),
          const SizedBox(width: 6),
          Text(label, style: AppText.body(size: 14, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}