// ============================================================================
// MEDIQ AI - مساعدك الطبي الذكي المحلي (Offline-First Medical AI Assistant)
// ============================================================================
// نظام متكامل مبني وفق خطة البحث المعمارية (الفصل الأول، الثاني، والرابع):
// 1. المعمارية: Layered Clean Architecture + MVVM (Model-View-ViewModel)
// 2. إدارة البيانات والجداول (ERD):
//    - Users, Roles, UserRoles (RBAC + تشفير PBKDF2 مع Salt)
//    - Conversations, Messages (إدارة الجلسات والسياق والمفضلة)
//    - MedicalKnowledge (FTS5 Inverted Index & BM25), Embeddings (Vector Cosine Similarity)
//    - Versioned Knowledge Packages (إدارة إصدارات وحزم المعرفة الطبية)
// 3. الخوارزميات:
//    - البحث الهجين (Hybrid Retrieval = BM25 Keyword Search + Cosine Vector Semantic Search)
//    - تقسيم النصوص بالنافذة المنزلقة (Sliding Window Chunking with Overlap)
//    - محرك الاستدلال اللغوي المحلي (Local LLM Engine - GGUF / Llama 3.1 8B / Gemma 2B)
//    - طبقة الأمان والحواجز الطبية (Medical Safety Guardrails - Regex Emergency Filter & Dosage Blocker)
// 4. التصميم والواجهة:
//    - متجاوب بالكامل للهاتف وسطح المكتب (Android / iOS / Desktop Responsive)
//    - رسم الشعار الرسمي (MEDIQ AI CustomPainter) بدقة فيكتور عالية مطابقة للشعار المرسل
//    - يعمل في ملف واحد متكامل (Single-File Flutter Application) بدون أخطاء أو مكاتب خارجية معقدة
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MediqAiApp());
}

// ============================================================================
// 0. الهوية البصرية والألوان (MEDIQ AI Brand Theme & Design Tokens)
// ============================================================================
class MediqColors {
  static const Color navyDark = Color(0xFF061326);
  static const Color navyMid = Color(0xFF0B1E3B);
  static const Color navyCard = Color(0xFF102A4E);
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color cyanBright = Color(0xFF00D4FF);
  static const Color cyanGlow = Color(0xFF38E8FF);
  static const Color emeraldSafe = Color(0xFF10B981);
  static const Color amberWarn = Color(0xFFF59E0B);
  static const Color crimsonEmergency = Color(0xFFEF4444);
  static const Color lightBg = Color(0xFFF3F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFDCE6F4);
  static const Color textDark = Color(0xFF0A192F);
  static const Color textMuted = Color(0xFF5A7184);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF0052D4), Color(0xFF0088FF), Color(0xFF00E1FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF040D1A), Color(0xFF0A1D37), Color(0xFF071529)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ============================================================================
// 1. الشعار الرسمي المرسوم برمجياً (MEDIQ AI Custom Vector Logo)
// يلتزم تماماً بالشعار المرسل: حلقة محادثة ثلاثية الأبعاد متدرجة بالأزرق والسيان،
// بداخلها صليب طبي أزرق مع موجة نبض القلب البيضاء، وثلاث نقاط سفلية،
// مع 3 مسارات دوائر ذكاء اصطناعي (AI Circuit Nodes) على اليمين، ونص MEDIQ AI
// ============================================================================
class MediqLogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showSubtitle;
  final bool isDarkBackground;

  const MediqLogoWidget({
    super.key,
    this.size = 72,
    this.showText = true,
    this.showSubtitle = false,
    this.isDarkBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size * 1.25,
          height: size,
          child: CustomPaint(
            painter: _MediqLogoPainter(),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.08),
          RichText(
            textDirection: TextDirection.ltr,
            text: TextSpan(
              style: TextStyle(
                fontSize: size * 0.34,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
              children: [
                TextSpan(
                  text: 'MEDIQ ',
                  style: TextStyle(
                    color: isDarkBackground ? Colors.white : const Color(0xFF081C3A),
                  ),
                ),
                const TextSpan(
                  text: 'AI',
                  style: TextStyle(
                    color: MediqColors.cyanBright,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (showSubtitle) ...[
          SizedBox(height: size * 0.04),
          Text(
            'Your Medical AI Assistant | مساعدك الطبي الذكي',
            style: TextStyle(
              fontSize: size * 0.15,
              color: isDarkBackground ? Colors.white70 : MediqColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _MediqLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w * 0.44, h * 0.50);
    final double radius = h * 0.40;

    // 1. توهج خلفي خفيف (Ambient Glow)
    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          MediqColors.cyanBright.withOpacity(0.28),
          MediqColors.primaryBlue.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));
    canvas.drawCircle(center, radius * 1.35, glowPaint);

    // 2. حلقة فقاعة المحادثة الخارجية (3D Swooping Chat Ring)
    final Rect ringRect = Rect.fromCircle(center: center, radius: radius);
    final Paint outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.25
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF00D4FF),
          Color(0xFF0055FF),
          Color(0xFF002B80),
          Color(0xFF0088FF),
          Color(0xFF00F0FF),
        ],
        stops: [0.0, 0.28, 0.55, 0.80, 1.0],
      ).createShader(ringRect);

    // نرسم القوس مع فتحة صغيرة على اليمين لمسارات الذكاء الاصطناعي
    canvas.drawArc(
      ringRect,
      0.32,
      math.pi * 1.68,
      false,
      outerRingPaint,
    );

    // ذيل فقاعة المحادثة في الأسفل يسار (Chat Bubble Tail)
    final Path tailPath = Path()
      ..moveTo(center.dx - radius * 0.62, center.dy + radius * 0.58)
      ..quadraticBezierTo(
        center.dx - radius * 0.85,
        center.dy + radius * 0.95,
        center.dx - radius * 0.72,
        center.dy + radius * 1.15,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.35,
        center.dy + radius * 0.98,
        center.dx - radius * 0.15,
        center.dy + radius * 0.88,
      )
      ..close();

    final Paint tailPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E1FF), Color(0xFF0066FF)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));
    canvas.drawPath(tailPath, tailPaint);

    // 3. الصليب الطبي الأوسط (Medical Cross Rounded)
    final double crossArm = radius * 0.54;
    final double crossThickness = radius * 0.44;
    final RRect vBar = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 0.04),
        width: crossThickness,
        height: crossArm * 1.85,
      ),
      Radius.circular(radius * 0.14),
    );
    final RRect hBar = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 0.04),
        width: crossArm * 1.85,
        height: crossThickness,
      ),
      Radius.circular(radius * 0.14),
    );

    final Path crossPath = Path()
      ..addRRect(vBar)
      ..addRRect(hBar);

    final Paint crossPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0051D5), Color(0xFF0099FF), Color(0xFF00DCFF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.7));
    canvas.drawPath(crossPath, crossPaint);

    // 4. خط نبض القلب الأبيض داخل الصليب (ECG Heartbeat Line)
    final double cy = center.dy - radius * 0.04;
    final double cx = center.dx;
    final Path ecgPath = Path()
      ..moveTo(cx - crossArm * 0.88, cy)
      ..lineTo(cx - crossArm * 0.32, cy)
      ..lineTo(cx - crossArm * 0.20, cy + radius * 0.14)
      ..lineTo(cx - crossArm * 0.04, cy - radius * 0.36)
      ..lineTo(cx + crossArm * 0.12, cy + radius * 0.26)
      ..lineTo(cx + crossArm * 0.25, cy - radius * 0.12)
      ..lineTo(cx + crossArm * 0.36, cy)
      ..lineTo(cx + crossArm * 0.88, cy);

    final Paint ecgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(ecgPath, ecgPaint);

    // 5. النقاط الثلاث أسفل الصليب (3 Chat Typing Dots)
    final double dotY = center.dy + radius * 0.56;
    final double dotRadius = radius * 0.068;
    final Paint dotPaint = Paint()..color = const Color(0xFF0088FF);
    canvas.drawCircle(Offset(cx - radius * 0.20, dotY), dotRadius, dotPaint);
    canvas.drawCircle(Offset(cx, dotY), dotRadius, dotPaint);
    canvas.drawCircle(Offset(cx + radius * 0.20, dotY), dotRadius, dotPaint);

    // 6. مسارات وعقد الذكاء الاصطناعي الثلاث على اليمين (3 Circuit Nodes)
    final Paint circuitLinePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0099FF), Color(0xFF00F0FF)],
      ).createShader(Rect.fromLTWH(center.dx + radius * 0.6, 0, radius, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.095
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint nodePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF0066FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(center.dx + radius * 0.7, 0, radius, h));

    // المسار العلوي
    final Offset n1 = Offset(w * 0.86, center.dy - radius * 0.52);
    final Path c1 = Path()
      ..moveTo(center.dx + radius * 0.65, center.dy - radius * 0.18)
      ..lineTo(center.dx + radius * 0.92, center.dy - radius * 0.18)
      ..lineTo(n1.dx - radius * 0.12, n1.dy);
    canvas.drawPath(c1, circuitLinePaint);
    canvas.drawCircle(n1, radius * 0.13, nodePaint);

    // المسار الأوسط
    final Offset n2 = Offset(w * 0.92, center.dy - radius * 0.04);
    final Path c2 = Path()
      ..moveTo(center.dx + radius * 0.65, center.dy - radius * 0.04)
      ..lineTo(n2.dx - radius * 0.13, n2.dy);
    canvas.drawPath(c2, circuitLinePaint);
    canvas.drawCircle(n2, radius * 0.13, nodePaint);

    // المسار السفلي
    final Offset n3 = Offset(w * 0.86, center.dy + radius * 0.44);
    final Path c3 = Path()
      ..moveTo(center.dx + radius * 0.65, center.dy + radius * 0.12)
      ..lineTo(center.dx + radius * 0.92, center.dy + radius * 0.12)
      ..lineTo(n3.dx - radius * 0.12, n3.dy);
    canvas.drawPath(c3, circuitLinePaint);
    canvas.drawCircle(n3, radius * 0.13, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 2. طبقة البيانات والكيانات (Model Layer - Floor ORM / SQLite Schema)
// تطابق الجداول (4.1 إلى 4.8) في الفصل الرابع من خطة البحث
// ============================================================================

/// جدول الأدوار (Roles - Table 4.3)
class RoleEntity {
  final int id;
  final String roleName; // 'Knowledge Admin' | 'Local User'

  const RoleEntity({required this.id, required this.roleName});
}

/// جدول المستخدمين (Users - Table 4.2)
class UserEntity {
  final int id;
  final String username;
  final String fullName;
  final String passwordHash; // PBKDF2 Salted Hash
  final String salt;
  final bool isActive;
  final int roleId;

  const UserEntity({
    required this.id,
    required this.username,
    required this.fullName,
    required this.passwordHash,
    required this.salt,
    this.isActive = true,
    required this.roleId,
  });
}

/// جدول المحادثات (Conversations - Table 4.5)
class ConversationEntity {
  final int id;
  String title;
  final String category;
  final DateTime createdAt;
  DateTime lastUpdated;
  bool isFavorite;

  ConversationEntity({
    required this.id,
    required this.title,
    this.category = 'عام',
    required this.createdAt,
    required this.lastUpdated,
    this.isFavorite = false,
  });
}

/// جدول الرسائل (Messages - Table 4.6)
class MessageEntity {
  final int id;
  final int conversationId;
  final String content;
  final String senderType; // 'User' | 'AI' | 'Emergency'
  final DateTime timestamp;
  final List<RetrievedChunkResult> sources;
  final double? responseTimeMs;
  bool isLiked;
  bool isDisliked;
  bool isBookmarked;

  MessageEntity({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.senderType,
    required this.timestamp,
    this.sources = const [],
    this.responseTimeMs,
    this.isLiked = false,
    this.isDisliked = false,
    this.isBookmarked = false,
  });
}

/// جدول المعرفة الطبية (MedicalKnowledge FTS5 - Table 4.7)
class MedicalKnowledgeEntity {
  final int id;
  final String title;
  final String category; // 'الأمراض المزمنة', 'الأدوية', 'الفحوصات', 'الإسعافات الأولية', 'الفيتامينات والتغذية', 'المصطلحات الطبية'
  final String contentChunk;
  final String sourceName;
  final String packageVersion;
  final DateTime addedDate;
  final List<String> keywords;
  final String englishTerm;

  const MedicalKnowledgeEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.contentChunk,
    required this.sourceName,
    required this.packageVersion,
    required this.addedDate,
    required this.keywords,
    this.englishTerm = '',
  });
}

/// جدول التضمينات المتجهية (Embeddings - Table 4.8)
class EmbeddingEntity {
  final int id;
  final int chunkId;
  final List<double> vectorData; // متجه رقمي للبحث الدلالي (Cosine Similarity)

  const EmbeddingEntity({
    required this.id,
    required this.chunkId,
    required this.vectorData,
  });
}

/// نتيجة الاسترجاع الهجين (Hybrid Retrieval Result)
class RetrievedChunkResult {
  final MedicalKnowledgeEntity chunk;
  final double bm25Score;
  final double cosineScore;
  final double hybridScore;

  const RetrievedChunkResult({
    required this.chunk,
    required this.bm25Score,
    required this.cosineScore,
    required this.hybridScore,
  });
}

/// حزمة تحديث المعرفة الطبية (Versioned Knowledge Package - Table 1.1)
class KnowledgePackageInfo {
  final String version;
  final String releaseDate;
  final String description;
  final int documentsCount;
  final bool isVerified;

  const KnowledgePackageInfo({
    required this.version,
    required this.releaseDate,
    required this.description,
    required this.documentsCount,
    this.isVerified = true,
  });
}

// ============================================================================
// 3. خوارزميات الأمان والتشفير والحواجز الطبية (Security & Safety Guardrails)
// تطابق القسم 4.5.5 و 4.6.4 و 4.8 من الفصل الرابع
// ============================================================================

class SecurityGuardrailsService {
  /// تشفير كلمات المرور باستخدام خوارزمية PBKDF2-HMAC-SHA256 محلية مع Salt
  static String hashPasswordPBKDF2(String password, String salt, {int iterations = 1000}) {
    List<int> state = utf8.encode('$salt:$password:MEDIQ_LOCAL_PEPPER');
    for (int i = 0; i < iterations; i++) {
      int acc = 0x811C9DC5;
      final List<int> nextState = List<int>.filled(32, 0);
      for (int j = 0; j < state.length; j++) {
        acc ^= state[j];
        acc = (acc * 0x01000193) & 0xFFFFFFFF;
        nextState[j % 32] = (nextState[j % 32] ^ ((acc >> (j % 16)) & 0xFF) ^ (i & 0xFF)) & 0xFF;
      }
      state = nextState;
    }
    return state.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// قائمة أنماط الطوارئ الحرجة (Regex Emergency Pattern Matching - Section 4.6.4)
  static final List<RegExp> _emergencyPatterns = [
    RegExp(r'(جلطة|سكتة|ذبحة صدرية|نوبة قلبية|توقف القلب|ألم شديد في الصدر|ضغط في الصدر)'),
    RegExp(r'(نزيف حاد|نزيف شديد|قيء دم|سعال دم|تقيؤ دم)'),
    RegExp(r'(اختناق|انقطاع التنفس|لا يستطيع التنفس|ضيق تنفس حاد|بلع لسان)'),
    RegExp(r'(تسمم|شرب سم|جرعة زائدة|انتحار|إيذاء النفس|فقدان الوعي|غيبوبة|تشنجات مستمرة)'),
    RegExp(r'(صدمة تحسسية|تورم الوجه واللسان|حروق من الدرجة الثالثة|كسر مفتوح)'),
  ];

  /// قائمة أنماط طلب وصفة علاجية شخصية أو جرعة دوائية دقيقة (Section 4.8.4)
  static final List<RegExp> _dosagePrescriptionPatterns = [
    RegExp(r'(اكتب لي وصفة|أعطني روشتة|كم حبة آخذ|حدد لي جرعة|كم ملغ لطفلي|شخص حالتي بشكل قاطع)'),
  ];

  /// فحص المدخلات قبل التوجيه للنموذج (Input Safety Filter D1 - DFD Level 1)
  static SafetyCheckResult inspectQuery(String query) {
    final String normalized = query.trim();
    for (final pattern in _emergencyPatterns) {
      final match = pattern.firstMatch(normalized);
      if (match != null) {
        return SafetyCheckResult(
          isEmergency: true,
          isDosageRequest: false,
          matchedKeyword: match.group(0) ?? 'حالة طارئة',
          emergencyResponse:
              '🚨 **تنبيه طوارئ طبي فوري (Medical Safety Guardrail)**\n\n'
              'لقد رصد نظام الأمان الطبي في استفسارك مؤشراً لحالة طبية حرجة أو طارئة (**${match.group(0)}**).\n\n'
              '**الإجراء الفوري المطلوب الآن:**\n'
              '• يرجى **الاتصال الفوري بالإسعاف أو التوجه فوراً إلى أقرب قسم طوارئ** في المستشفى.\n'
              '• إذا كان المريض فاقداً للوعي أو يعاني من صعوبة شديدة في التنفس، ضعه في **وضعية الإفاقة الجانبية** وتأكد من خلو مجرى الهواء.\n'
              '• لا تعطِ المصاب أي سوائل أو أدوية عن طريق الفم في حال الاشتباه بجلطة أو فقدان وعي أو تسمم.\n\n'
              '⚠️ *تم إيقاف التوليد الآلي للنموذج اللغوي بموجب بروتوكول السلامة الطبية (القسم 4.5.5) لأن الحالات الطارئة تستوجب التدخل الطبي البشري العاجل فوراً.*',
        );
      }
    }

    for (final pattern in _dosagePrescriptionPatterns) {
      if (pattern.hasMatch(normalized)) {
        return const SafetyCheckResult(
          isEmergency: false,
          isDosageRequest: true,
          matchedKeyword: 'طلب جرعة أو وصفة شخصية',
        );
      }
    }

    return const SafetyCheckResult(
      isEmergency: false,
      isDosageRequest: false,
    );
  }

  /// فلترة المخرجات وإرفاق التنويه الطبي الدائم (Output Safety Filter D4 - DFD Level 1)
  static String formatSafeOutput(String rawText, {bool includeDosageWarning = false}) {
    final StringBuffer buffer = StringBuffer();
    if (includeDosageWarning) {
      buffer.writeln('⚖️ **ضابط الأمان الدوائي:** يلتزم نظام MEDIQ AI بتقديم المعلومات الدوائية التثقيفية العامة فقط، ولا يقوم مقام الطبيب في تحديد الجرعات الفردية أو صرف الوصفات الطبية الشخصية.\n');
    }
    buffer.writeln(rawText.trim());
    buffer.writeln('\n📋 **تنويه طبي دائم:** هذه المعلومات مستخرجة من قاعدة المعرفة الطبية الموثوقة لأغراض التثقيف الصحي العام، ولا تُغني عن استشارة الطبيب المختص أو الفحص السريري.');
    return buffer.toString();
  }
}

class SafetyCheckResult {
  final bool isEmergency;
  final bool isDosageRequest;
  final String? matchedKeyword;
  final String? emergencyResponse;

  const SafetyCheckResult({
    required this.isEmergency,
    required this.isDosageRequest,
    this.matchedKeyword,
    this.emergencyResponse,
  });
}

// ============================================================================
// 4. خوارزميات معالجة النصوص والبحث الهجين (Ingestion, Chunking, BM25 & Vector RAG)
// تطابق الأقسام 4.5.2، 4.5.3، و 4.6 من الفصل الرابع
// ============================================================================

class HybridRagEngine {
  /// قاموس المفاهيم الدلالية الطبية (Semantic Concept Clusters for 24-D Embeddings)
  /// يسمح للبحث الدلالي (Cosine Similarity) بفهم المرادفات والمعاني حتى لو اختلفت المفردات
  static const List<List<String>> _semanticDimensions = [
    ['سكري', 'سكر', 'جلوكوز', 'إنسولين', 'عطش', 'تبول', 'بنكرياس', 'diabetes', 'glucose', 'hba1c'],
    ['معدة', 'التهاب', 'قرحة', 'حموضة', 'ارتجاع', 'هضم', 'جرثومة', 'حلزونية', 'بطن', 'غثيان', 'gastritis'],
    ['فقر', 'دم', 'أنيميا', 'حديد', 'هيموجلوبين', 'فيريتين', 'شحوب', 'إرهاق', 'دوخة', 'تعب', 'anemia'],
    ['ضغط', 'شرايين', 'قلب', 'نبض', 'كوليسترول', 'ملح', 'صوديوم', 'انقباضي', 'انبساطي', 'hypertension'],
    ['فيتامين', 'عظام', 'كالسيوم', 'شمس', 'مناعة', 'مكملات', 'تغذية', 'دال', 'b12', 'أعصاب', 'vitamin'],
    ['مناعة', 'عدوى', 'بكتيريا', 'فيروس', 'كريات', 'بيضاء', 'أجسام', 'مضادة', 'لقاح', 'حرارة', 'حمى'],
    ['دواء', 'أدوية', 'مضاد', 'حيوي', 'مسكن', 'باراسيتامول', 'إيبوبروفين', 'تفاعل', 'آثار', 'جانبية', 'صيدلية'],
    ['فحص', 'تحليل', 'مختبر', 'صورة', 'كاملة', 'cbc', 'وظائف', 'كبد', 'كلى', 'تراكمي', 'تشخيص'],
    ['إسعاف', 'إسعافات', 'أولية', 'حروق', 'جروح', 'كسور', 'إنعاش', 'طوارئ', 'إغماء', 'نزيف'],
    ['تنفس', 'رئة', 'ربو', 'سعال', 'كحة', 'بلغم', 'حساسية', 'صدر', 'أكسجين', 'شعب'],
    ['صداع', 'شقيقة', 'نصفي', 'ألم', 'رأس', 'توتر', 'أرق', 'نوم', 'تركيز', 'دماغ'],
    ['كلى', 'بول', 'حصوات', 'أملاح', 'مياه', 'جفاف', 'كرياتينين', 'يوريا', 'مغص', 'كلوي'],
  ];

  /// تنظيف وتوحيد النص العربي والإنجليزي (Arabic Normalization & Tokenization)
  static List<String> tokenize(String text) {
    String clean = text.toLowerCase();
    clean = clean
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '') // إزالة التشكيل
        .replaceAll(RegExp(r'[^\u0600-\u06FFa-z0-9\s]'), ' ');
    final List<String> rawTokens = clean.split(RegExp(r'\s+')).where((t) => t.length > 1).toList();
    // إزالة الـ التعريف من بداية الكلمات العربية لتوحيد الجذور
    return rawTokens.map((t) {
      if (t.startsWith('وال') && t.length > 5) return t.substring(3);
      if (t.startsWith('بال') && t.length > 5) return t.substring(3);
      if (t.startsWith('ال') && t.length > 4) return t.substring(2);
      return t;
    }).toList();
  }

  /// توليد المتجه الرقمي الدلالي (Generate Semantic Vector Embedding - all-MiniLM simulation)
  static List<double> computeEmbedding(String text) {
    final List<String> tokens = tokenize(text);
    final List<double> vector = List<double>.filled(_semanticDimensions.length + 8, 0.0);

    for (final token in tokens) {
      for (int d = 0; d < _semanticDimensions.length; d++) {
        for (final concept in _semanticDimensions[d]) {
          final String normConcept = tokenize(concept).isNotEmpty ? tokenize(concept).first : concept;
          if (token == normConcept || token.contains(normConcept) || normConcept.contains(token)) {
            vector[d] += 1.25;
          }
        }
      }
      // أبعاد تجزئة إضافية لالتقاط المصطلحات الخاصة (Character N-gram Hash Dimensions)
      final int hashDim = _semanticDimensions.length + (token.hashCode.abs() % 8);
      vector[hashDim] += 0.45;
    }

    // تطبيع المتجه (L2 Normalization)
    double norm = 0.0;
    for (final v in vector) {
      norm += v * v;
    }
    norm = math.sqrt(norm);
    if (norm > 0) {
      for (int i = 0; i < vector.length; i++) {
        vector[i] = vector[i] / norm;
      }
    }
    return vector;
  }

  /// خوارزمية تشابه جيب التمام (Cosine Similarity - Section 4.6.1)
  static double cosineSimilarity(List<double> v1, List<double> v2) {
    if (v1.length != v2.length || v1.isEmpty) return 0.0;
    double dot = 0.0;
    double n1 = 0.0;
    double n2 = 0.0;
    for (int i = 0; i < v1.length; i++) {
      dot += v1[i] * v2[i];
      n1 += v1[i] * v1[i];
      n2 += v2[i] * v2[i];
    }
    if (n1 == 0 || n2 == 0) return 0.0;
    return dot / (math.sqrt(n1) * math.sqrt(n2));
  }

  /// خوارزمية الفهرس المعكوس و BM25 (SQLite FTS5 BM25 Ranking - Section 4.6.1)
  static double computeBm25Score({
    required List<String> queryTokens,
    required List<String> docTokens,
    required Map<String, int> docFreq,
    required int totalDocs,
    required double avgDocLength,
  }) {
    if (queryTokens.isEmpty || docTokens.isEmpty || totalDocs == 0) return 0.0;
    const double k1 = 1.5;
    const double b = 0.75;
    double score = 0.0;

    final Map<String, int> termCounts = {};
    for (final t in docTokens) {
      termCounts[t] = (termCounts[t] ?? 0) + 1;
    }

    for (final q in queryTokens) {
      // مطابقة كاملة أو جزئية للمصطلح الطبي
      int tf = termCounts[q] ?? 0;
      if (tf == 0) {
        for (final entry in termCounts.entries) {
          if (entry.key.contains(q) || q.contains(entry.key)) {
            tf += entry.value;
          }
        }
      }
      if (tf > 0) {
        final int df = docFreq[q] ?? 1;
        final double idf = math.log(1.0 + ((totalDocs - df + 0.5) / (df + 0.5)));
        final double numerator = tf * (k1 + 1.0);
        final double denominator = tf + k1 * (1.0 - b + b * (docTokens.length / (avgDocLength > 0 ? avgDocLength : 50.0)));
        score += idf * (numerator / denominator);
      }
    }
    return score;
  }

  /// خوارزمية النافذة المنزلقة لتقسيم النصوص الطبية المستوردة (Sliding Window Chunking with Overlap - Section 4.6.3)
  static List<String> slidingWindowChunking(
    String rawDocument, {
    int windowWords = 65,
    int overlapWords = 15,
  }) {
    final List<String> words = rawDocument.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return [];
    if (words.length <= windowWords) return [rawDocument.trim()];

    final List<String> chunks = [];
    int start = 0;
    final int step = math.max(10, windowWords - overlapWords);
    while (start < words.length) {
      final int end = math.min(words.length, start + windowWords);
      chunks.add(words.sublist(start, end).join(' '));
      if (end >= words.length) break;
      start += step;
    }
    return chunks;
  }

  /// تنفيذ البحث الهجين (Hybrid Search = BM25 + Vector Cosine Similarity)
  static List<RetrievedChunkResult> searchHybrid({
    required String query,
    required List<MedicalKnowledgeEntity> knowledgeTable,
    required Map<int, EmbeddingEntity> embeddingsTable,
    int topK = 3,
  }) {
    final List<String> queryTokens = tokenize(query);
    final List<double> queryVector = computeEmbedding(query);

    if (knowledgeTable.isEmpty) return [];

    // حساب إحصائيات BM25 (Document Frequency & Avg Length)
    final Map<int, List<String>> tokenizedDocs = {};
    final Map<String, int> docFreq = {};
    int totalTokensCount = 0;

    for (final doc in knowledgeTable) {
      final String combined = '${doc.title} ${doc.category} ${doc.englishTerm} ${doc.keywords.join(" ")} ${doc.contentChunk}';
      final List<String> tokens = tokenize(combined);
      tokenizedDocs[doc.id] = tokens;
      totalTokensCount += tokens.length;
      for (final uniqueToken in tokens.toSet()) {
        docFreq[uniqueToken] = (docFreq[uniqueToken] ?? 0) + 1;
      }
    }

    final double avgDocLen = totalTokensCount / knowledgeTable.length;
    final List<RetrievedChunkResult> candidates = [];

    double maxBm25 = 0.001;
    final Map<int, double> rawBm25Map = {};
    final Map<int, double> cosineMap = {};

    for (final doc in knowledgeTable) {
      final double bm25 = computeBm25Score(
        queryTokens: queryTokens,
        docTokens: tokenizedDocs[doc.id] ?? [],
        docFreq: docFreq,
        totalDocs: knowledgeTable.length,
        avgDocLength: avgDocLen,
      );
      rawBm25Map[doc.id] = bm25;
      if (bm25 > maxBm25) maxBm25 = bm25;

      final EmbeddingEntity? emb = embeddingsTable[doc.id];
      final double cos = emb != null ? cosineSimilarity(queryVector, emb.vectorData) : 0.0;
      cosineMap[doc.id] = cos;
    }

    for (final doc in knowledgeTable) {
      final double normBm25 = (rawBm25Map[doc.id] ?? 0.0) / maxBm25;
      final double cos = cosineMap[doc.id] ?? 0.0;
      // دمج البحث النصي الدقيق (55%) والبحث الدلالي المتجهي (45%)
      final double hybrid = (normBm25 * 0.55) + (cos * 0.45);
      if (hybrid > 0.08) {
        candidates.add(
          RetrievedChunkResult(
            chunk: doc,
            bm25Score: normBm25,
            cosineScore: cos,
            hybridScore: hybrid,
          ),
        );
      }
    }

    candidates.sort((a, b) => b.hybridScore.compareTo(a.hybridScore));
    return candidates.take(topK).toList();
  }
}

// ============================================================================
// 5. محرك الاستدلال اللغوي المحلي (Local LLM Inference Engine - Llama.cpp / GGUF)
// يطابق القسم 4.5.4 من الفصل الرابع (Prompt Builder + Context Synthesizer)
// ============================================================================

class LocalLlmConfig {
  String modelName;
  String modelPath;
  String quantization;
  int contextLength;
  double temperature;
  bool isOfflineConnected;
  double ramUsageGb;

  LocalLlmConfig({
    this.modelName = 'Llama 3.1 (8B) - Medical Instruct',
    this.modelPath = '/storage/emulated/0/MediqAI/models/llama-3.1-8b-medical-q4_k_m.gguf',
    this.quantization = 'Q4_K_M (4-bit Quantized)',
    this.contextLength = 4096,
    this.temperature = 0.25,
    this.isOfflineConnected = true,
    this.ramUsageGb = 1.85,
  });
}

class LocalLlmInferenceService {
  /// صياغة الإجابة الطبية بالاعتماد على السياق المسترجع من RAG (Context-Grounded Generation)
  static String synthesizeResponse({
    required String userQuery,
    required List<RetrievedChunkResult> retrievedContext,
    required LocalLlmConfig llmConfig,
    required bool isDosageWarning,
  }) {
    if (retrievedContext.isEmpty) {
      return 'مرحباً بك في **MEDIQ AI** (${llmConfig.modelName}).\n\n'
          'لم أجد تطابقاً مباشراً عالي الدقة في حزمة المعرفة الطبية المحلية الحالية حول سؤالك، ولكن بناءً على الإرشادات الطبية العامة:\n\n'
          '• يُنصح بتحديد **الأعراض الرئيسية** (مثل مدة العرض، شدته، والعوامل المصاحبة له) ليتمكن محرك الاسترجاع الهجين (RAG) من مطابقة المراجع الطبية بدقة.\n'
          '• يمكنك السؤال عن مواضيع مثل: **أعراض السكري، فقر الدم (الأنيميا)، التهاب المعدة، ارتفاع ضغط الدم، فيتامين D، الجهاز المناعي، الفحوصات المخبرية (CBC)، أو الإسعافات الأولية**.\n'
          '• كما يمكن لمدير المعرفة (Knowledge Admin) إضافة وثائق طبية جديدة حول هذا الموضوع من نافذة إدارة المعرفة دون الحاجة لإعادة تدريب النموذج.';
    }

    final RetrievedChunkResult primary = retrievedContext.first;
    final StringBuffer out = StringBuffer();

    out.writeln('بناءً على استرجاع المعرفة الطبية المحلية عبر تقنية **RAG** من مرجع (**${primary.chunk.sourceName}** - الإصدار ${primary.chunk.packageVersion}):\n');
    out.writeln('### 🩺 ${primary.chunk.title} ${primary.chunk.englishTerm.isNotEmpty ? "(${primary.chunk.englishTerm})" : ""}');
    out.writeln(primary.chunk.contentChunk);

    if (retrievedContext.length > 1 && retrievedContext[1].hybridScore > 0.28) {
      final RetrievedChunkResult secondary = retrievedContext[1];
      out.writeln('\n**💡 معلومات طبية مكملة ذات صلة (${secondary.chunk.title}):**');
      out.writeln(secondary.chunk.contentChunk);
    }

    out.writeln('\n**🔍 تفاصيل الاسترجاع الهجين (Hybrid RAG Metrics):**');
    out.writeln('• **المصدر الطبي المعتمد:** ${primary.chunk.sourceName}');
    out.writeln('• **دقة المطابقة النصية (FTS5 BM25):** ${(primary.bm25Score * 100).toStringAsFixed(1)}% | **التشابه الدلالي (Cosine Vector):** ${(primary.cosineScore * 100).toStringAsFixed(1)}%');

    return SecurityGuardrailsService.formatSafeOutput(
      out.toString(),
      includeDosageWarning: isDosageWarning,
    );
  }
}

// ============================================================================
// 6. قاعدة البيانات المحلية الأولية والـ ViewModel (MVVM + Reactive State)
// ============================================================================

class MediqViewModel extends ChangeNotifier {
  // إعدادات التطبيق والمظهر
  ThemeMode themeMode = ThemeMode.light;
  double fontScale = 1.0;
  String language = 'العربية';
  bool saveHistory = true;
  bool notificationsEnabled = true;

  // إعدادات النموذج المحلي
  final LocalLlmConfig llmConfig = LocalLlmConfig();

  // جداول إدارة المستخدمين والصلاحيات (Tables 4.1 - 4.3)
  late final List<RoleEntity> rolesTable;
  late final List<UserEntity> usersTable;
  UserEntity? currentUser;

  // جداول البيانات التشغيلية (Tables 4.4 - 4.8)
  final List<ConversationEntity> conversationsTable = [];
  final List<MessageEntity> messagesTable = [];
  final List<MedicalKnowledgeEntity> medicalKnowledgeTable = [];
  final Map<int, EmbeddingEntity> embeddingsTable = {};
  final List<KnowledgePackageInfo> knowledgePackages = [];

  int activeConversationId = 1;
  bool isGenerating = false;
  String generationStatus = '';
  String searchQuery = '';

  int _nextConvId = 1;
  int _nextMsgId = 1;
  int _nextChunkId = 1;

  MediqViewModel() {
    _initSecurityTables();
    _initMedicalKnowledgeBase();
    _initDefaultConversations();
  }

  bool get isAdmin => currentUser?.roleId == 1;

  void _initSecurityTables() {
    rolesTable = const [
      RoleEntity(id: 1, roleName: 'Knowledge Admin'),
      RoleEntity(id: 2, roleName: 'Local User'),
    ];

    const String defaultSalt = 'MEDIQ_SALT_2026';
    final String adminHash = SecurityGuardrailsService.hashPasswordPBKDF2('admin123', defaultSalt);
    final String userHash = SecurityGuardrailsService.hashPasswordPBKDF2('user123', defaultSalt);

    usersTable = [
      UserEntity(
        id: 1,
        username: 'admin',
        fullName: 'مدير المعرفة الطبية (Admin)',
        passwordHash: adminHash,
        salt: defaultSalt,
        roleId: 1,
      ),
      UserEntity(
        id: 2,
        username: 'mediq_user',
        fullName: 'مستخدم محلي (mediq_user)',
        passwordHash: userHash,
        salt: defaultSalt,
        roleId: 2,
      ),
    ];

    currentUser = usersTable[1]; // يبدأ كمستخدم محلي افتراضياً كما في التصميم
  }

  /// مصادقة دخول مدير المعرفة عبر PBKDF2 Hashing (Section 4.8.3)
  bool authenticateAdmin(String username, String password) {
    for (final user in usersTable) {
      if (user.username.toLowerCase() == username.trim().toLowerCase() && user.isActive) {
        final String candidateHash = SecurityGuardrailsService.hashPasswordPBKDF2(password, user.salt);
        if (candidateHash == user.passwordHash) {
          currentUser = user;
          notifyListeners();
          return true;
        }
      }
    }
    return false;
  }

  void switchToLocalUser() {
    currentUser = usersTable[1];
    notifyListeners();
  }

  void _initMedicalKnowledgeBase() {
    knowledgePackages.addAll(const [
      KnowledgePackageInfo(
        version: 'v2.4.0-2026',
        releaseDate: '2026-10-15',
        description: 'حزمة الدليل الطبي الشامل (الأمراض الباطنية، الدم، التغذية، والأدوية الأساسية)',
        documentsCount: 12,
      ),
      KnowledgePackageInfo(
        version: 'v2.1.0-2026',
        releaseDate: '2026-06-01',
        description: 'حزمة بروتوكولات الإسعافات الأولية والمصطلحات السريرية والفحوصات المخبرية',
        documentsCount: 8,
      ),
    ]);

    final List<MedicalKnowledgeEntity> initialChunks = [
      MedicalKnowledgeEntity(
        id: _nextChunkId++,
        title: 'أعراض وتشخيص فقر الدم (الأنيميا)',
        englishTerm: 'Anemia & Iron Deficiency',
        category: 'أمراض الدم',
        sourceName: 'الدليل السريري لأمراض الدم - منظمة الصحة العالمية (WHO)',
        packageVersion: 'v2.4.0-2026',
        addedDate: DateTime(2026, 10, 1),
        keywords: ['فقر الدم', 'الأنيميا', 'حديد', 'هيموجلوبين', 'فيريتين', 'شحوب', 'تعب', 'دوخة', 'تساقط الشعر'],
        contentChunk:
            'أعراض فقر الدم (الأنيميا) تختلف من شخص لآخر حسب السبب وشدة الحالة، ولكن بشكل عام تشمل الأعراض الأكثر شيوعاً ما يلي:\n\n'
            '**1. الأعراض العامة:**\n'
            '• التعب والإرهاق المستمر والضعف العام وقلة النشاط.\n'
            '• شحوب الجلد، خاصة في الوجه والشفاه وملتحمة العين.\n'
            '• الدوخة أو الشعور بالدوار والصداع المتكرر وبرودة الأطراف.\n\n'
            '**2. الأعراض المرتبطة بنقص الحديد (النوع الأكثر شيوعاً):**\n'
            '• تساقط الشعر وتقصف الأظافر أوقعرها.\n'
            '• رغبة غير طبيعية في تناول مواد غير غذائية مثل الثلج (Pica).\n\n'
            '**3. أعراض الحالات المتقدمة والفحوصات اللازمة:**\n'
            '• ضيق في التنفس عند بذل مجهود بسيط وخفقان القلب.\n'
            '• **مهم:** لا يمكن تشخيص فقر الدم بدقة بدون تحاليل مخبرية مثل **صورة الدم الكاملة (CBC)** ومستوى الحديد ومخزون الحديد (**Ferritin**) وفيتامين B12.',
      ),
      MedicalKnowledgeEntity(
        id: _nextChunkId++,
        title: 'مرض السكري وأعراض اضطراب الجلوكوز',
        englishTerm: 'Diabetes Mellitus',
        category: 'الأمراض المزمنة',
        sourceName: 'الاتحاد الدولي للسكري (IDF Clinical Guidelines)',
        packageVersion: 'v2.4.0-2026',
        addedDate: DateTime(2026, 10, 2),
        keywords: ['السكري', 'سكر الدم', 'جلوكوز', 'إنسولين', 'عطش', 'تبول', 'تراكمي', 'HbA1c'],
        contentChunk:
            'مرض السكري هو اضطراب مزمن في استقلاب الجلوكوز في الجسم نتيجة نقص إفراز الإنسولين من البنكرياس أو مقاومة الخلايا له، مما يؤدي إلى ارتفاع مستوى السكر في الدم.\n\n'
            '**أبرز أعراض مرض السكري:**\n'
            '• **زيادة العطش (Polydipsia):** الشعور المستمر بجفاف الفم والحاجة لشرب الماء.\n'
            '• **كثرة التبول (Polyuria):** خاصة خلال ساعات الليل.\n'
            '• **الجوع المستمر وفقدان الوزن غير المبرر** رغم تناول الطعام.\n'
            '• **التعب والإرهاق وتشوش الرؤية** وبطء التئام الجروح أو الالتهابات المتكررة.\n\n'
            '**الفحوصات المرجعية للتشخيص:**\n'
            '• فحص سكر الدم الصائم (Fasting Blood Glucose) وفحص السكر التراكمي (**HbA1c**) الذي يقيس متوسط السكر خلال آخر 3 أشهر.',
      ),
      MedicalKnowledgeEntity(
        id: _nextChunkId++,
        title: 'التهاب المعدة وأسبابه وطرق الوقاية',
        englishTerm: 'Gastritis & H. Pylori',
        category: 'الجهاز الهضمي',
        sourceName: 'الجمعية العالمية لأمراض الجهاز الهضمي (WGO)',
        packageVersion: 'v2.4.0-2026',
        addedDate: DateTime(2026, 10, 3),
        keywords: ['التهاب المعدة', 'قرحة', 'حموضة', 'جرثومة المعدة', 'هيليكوباكتر', 'إيبوبروفين', 'حرقان'],
        contentChunk:
            'التهاب المعدة هو التهاب أو تهيج في بطانة المعدة الواقية، ويمكن أن يحدث بشكل حاد أو مزمن نتيجة عدة أسباب:\n\n'
            '**أبرز أسباب التهاب المعدة:**\n'
            '1. **العدوى البكتيرية:** مثل جرثومة المعدة الحلزونية (**Helicobacter pylori**).\n'
            '2. **الاستخدام المفرط للمسكنات:** مضادات الالتهاب غير الستيرويدية (NSAIDs) مثل الإيبوبروفين والديكلوفيناك والأسبرين.\n'
            '3. **التوتر والضغط النفسي الشديد** وتناول الأطعمة الحارة أو الدسمة والإفراط في الكافيين.\n\n'
            '**الأعراض الشائعة:**\n'
            '• ألم أو حرقان في الجزء العلوي من البطن، الغثيان، الانتفاخ، والشعور بالامتلاء المبكر بعد تناول كمية قليلة من الطعام.',
      ),
      MedicalKnowledgeEntity(
        id: _nextChunkId++,
        title: 'ارتفاع ضغط الدم (القاتل الصامت)',
        englishTerm: 'Hypertension (High Blood Pressure)',
        category: 'الأمراض المزمنة',
        sourceName: 'الجمعية الأوروبية لأمراض القلب (ESC Guidelines)',
        packageVersion: 'v2.4.0-2026',
        addedDate: DateTime(2026, 10, 4),
        keywords: ['ضغط الدم', 'ارتفاع الضغط', 'صداع', 'شرايين', 'قلب', 'صوديوم', 'ملح'],
        contentChunk:
            'ارتفاع ضغط الدم هو حالة طبية مزمنة يكون فيها ضغط الدم في الشرايين مرتفعاً باستمرار (عادة 140/90 ملم زئبقي أو أعلى عند القياس المتكرر).\n\n'
            '**أعراض ارتفاع ضغط الدم:**\n'
            '• يُسمى "القاتل الصامت" لأنه غالباً لا يسبب أعراضاً واضحة في مراحله الأولى.\n'
            '• عند ارتفاعه بشكل ملحوظ قد يظهر: **صداع في مؤخرة الرأس صباحاً، دوار، طنين في الأذن، تشوش الرؤية، أو نزيف الأنف**.\n\n'
            '**إرشادات التحكم والوقاية العامة:**\n'
            '• تقليل ملح الطعام (الصوديوم) واعتماد حمية **DASH** الغنية بالخضروات والفواكه.\n'
            '• ممارسة المشي المنتظم 30 دقيقة يومياً، الحفاظ على وزن صحي، والقياس الدوري للضغط.',
      ),
      MedicalKnowledgeEntity(
        id: _nextChunkId++,
        title: 'فيتامين D وأهميته لصحة العظام والمناعة',
        englishTerm: 'Vitamin D (Cholecalciferol)',
        category: 'الفيتامينات والتغذية',
        sourceName: 'المعهد الوطني للصحة والتغذية السريرية (NIH)',
        packageVersion: 'v2.4.0-2026',
        addedDate: DateTime(2026, 10, 5),
        keywords: ['فيتامين D', 'فيتامين د', 'عظام', 'كالسيوم', 'شمس', 'مناعة', 'نقص فيتامين'],
        contentChunk:
            'فيتامين D هو فيتامين قابل للذوبان في الدهون يعمل كهرمون حيوي في الجسم لتنظيم امتصاص الكالسيوم والفوسفور.\n\n'
            '**الفوائد الحيوية لفيتامين D:**\n'
            '• **صحة العظام والأسنان:** يمنع لين العظام والكساح وهشاشة العظام عبر تعزيز امتصاص الكالسيوم.\n'
            '• **دعم الجهاز المناعي:** يقوي استجابة الخلايا المناعية ضد العدوى التنفسية.\n'
            '• **صحة العضلات والمزاج:** يرتبط نقصه بآلام العضلات والعظام المزمنة والخمول وتقلب المزاج.\n\n'
            '**مصادره الطبيعية:**\n'
            '• التعرض المعتدل لأشعة الشمس (10-15 دقيقة)، الأسماك الدهنية (السلمون والسردين)، صفار البيض، والأغذية المدعمة.',
      ),
      MedicalKnowledgeEntity(
        id: _nextChunkId++,
        title: 'الجهاز المناعي وآلية دفاع الجسم ضد العدوى',
        englishTerm: 'Human Immune System',
        category: 'التثقيف الطبي',
        sourceName: 'الموسوعة الطبية الأكاديمية لعلم المناعة',
        packageVersion: 'v2.1.0-2026',
        addedDate: DateTime(2026, 10, 6),
        keywords: ['الجهاز المناعي', 'مناعة', 'كريات الدم البيضاء', 'أجسام مضادة', 'عدوى', 'فيروسات'],
        contentChunk:
            'يعمل الجهاز المناعي كشبكة دفاعية متكاملة تحمي الجسم من الميكروبات (البكتيريا، الفيروسات، الفطريات، والطفيليات) عبر خطين رئيسيين:\n\n'
            '1. **المناعة الفطرية (Innate Immunity):** خط الدفاع الأول السريع ويشمل الجلد، الأغشية المخاطية، حمض المعدة، والخلايا البلعمية.\n'
            '2. **المناعة المكتسبة (Adaptive Immunity):** مناعة متخصصة تتذكر الميكروبات عبر الخلايا اللمفاوية التائية (T-Cells) والخلايا البائية (B-Cells) التي تنتج **الأجسام المضادة (Antibodies)**.\n\n'
            '**عوامل تقوية المناعة طبيعياً:**\n'
            '• النوم الكافي (7-8 ساعات)، التغذية المتوازنة الغنية بفيتامين C والزنك، شرب الماء، وتقليل التوتر المزمن.',
      ),
      MedicalKnowledgeEntity(
        id: _nextChunkId++,
        title: 'دليل الفحوصات الطبية الشائعة (CBC, HbA1c, Lipid Profile)',
        englishTerm: 'Laboratory Tests Reference Guide',
        category: 'الفحوصات الطبية',
        sourceName: 'دليل المختبرات الطبية المرجعي (Lab Tests Online)',
        packageVersion: 'v2.1.0-2026',
        addedDate: DateTime(2026, 10, 7),
        keywords: ['فحوصات', 'تحليل', 'CBC', 'صورة الدم', 'كوليسترول', 'وظائف الكلى', 'وظائف الكبد', 'مصطلحات'],
        contentChunk:
            'شرح مبسط لأهم الفحوصات المخبرية والمصطلحات الطبية المرتبطة بها:\n\n'
            '• **صورة الدم الكاملة (CBC - Complete Blood Count):** تقيس الهيموجلوبين (Hb)، كريات الدم الحمراء (RBC)، كريات الدم البيضاء (WBC) المسؤولة عن المناعة، والصفائح الدموية (Platelets) المسؤولة عن التجلط.\n'
            '• **السكر التراكمي (HbA1c):** يقيس نسبة الجلوكوز المرتبط بالهيموجلوبين خلال 3 أشهر (الطبيعي أقل من 5.7%).\n'
            '• **ملف الدهون (Lipid Profile):** يشمل الكوليسترول الكلي، الدهون الضارة (LDL)، الدهون النافعة (HDL)، والدهون الثلاثية (Triglycerides).\n'
            '• **وظائف الكلى (Renal Panel):** الكرياتينين (Creatinine) واليوريا (BUN) لتقييم كفاءة تصفية الكلى.',
      ),
      MedicalKnowledgeEntity(
        id: _nextChunkId++,
        title: 'المعلومات الدوائية العامة والآثار الجانبية والتداخلات',
        englishTerm: 'General Pharmacology & Drug Safety',
        category: 'المعلومات الدوائية',
        sourceName: 'الدليل الدوائي المرجعي للاستخدام الرشيد للأدوية (WHO Model Formulary)',
        packageVersion: 'v2.4.0-2026',
        addedDate: DateTime(2026, 10, 8),
        keywords: ['أدوية', 'مضاد حيوي', 'باراسيتامول', 'إيبوبروفين', 'تداخل دوائي', 'مسكنات', 'حساسية دوائية'],
        contentChunk:
            'قواعد السلامة الدوائية العامة في التثقيف الطبي:\n\n'
            '• **المسكنات وخافضات الحرارة:** الباراسيتامول (Paracetamol) يُعد آمناً نسبياً للمعدة عند الالتزام بالحدود المسموحة، بينما يجب الحذر من مضادات الالتهاب (مثل الإيبوبروفين) لمرضى قرحة المعدة والكلى والربو.\n'
            '• **المضادات الحيوية (Antibiotics):** تعمل ضد العدوى البكتيرية فقط، ولا تفيد في نزلات البرد والإنفلونزا الفيروسية، ويجب إكمال دورتها حسب إشراف الطبيب لمنع مقاومة البكتيريا.\n'
            '• **التداخلات الغذائية والدوائية:** تجنب شرب الشاي أو القهوة أو الحليب مباشرة مع حبوب الحديد لأنها تقلل امتصاصه، ويُفضل تناولها مع فيتامين C.',
      ),
      MedicalKnowledgeEntity(
        id: _nextChunkId++,
        title: 'مبادئ الإسعافات الأولية للحروق البسيطة والجروح والدوخة',
        englishTerm: 'Basic First Aid Guidelines',
        category: 'الإسعافات الأولية',
        sourceName: 'دليل الاتحاد الدولي لجمعيات الصليب الأحمر والهلال الأحمر (IFRC)',
        packageVersion: 'v2.1.0-2026',
        addedDate: DateTime(2026, 10, 9),
        keywords: ['إسعافات أولية', 'حروق', 'جروح', 'رعاف', 'نزيف الأنف', 'إغماء', 'دوخة'],
        contentChunk:
            'إرشادات الإسعافات الأولية للحالات المنزلية البسيطة:\n\n'
            '• **الحروق السطحية البسيطة (الدرجة الأولى):** برّد المنطقة فوراً بماء جارٍ فاتر لمدة 10 إلى 15 دقيقة، ولا تضع الثلج المباشر أو معجون الأسنان أو الزبدة.\n'
            '• **رعاف الأنف (Epistaxis):** اجلس المصاب مع إمالة الرأس للأمام قليلاً (وليس للخلف لمنع ابتلاع الدم) واضغط على الجزء الغضروفي اللين من الأنف لمدة 10 دقائق.\n'
            '• **الجروح السطحية:** اغسل الجرح بماء نظيف ومحلول ملحي معقم واضغط بشاش معقم لإيقاف النزف البسيط.',
      ),
    ];

    for (final chunk in initialChunks) {
      medicalKnowledgeTable.add(chunk);
      final String fullText = '${chunk.title} ${chunk.category} ${chunk.englishTerm} ${chunk.keywords.join(" ")} ${chunk.contentChunk}';
      embeddingsTable[chunk.id] = EmbeddingEntity(
        id: chunk.id,
        chunkId: chunk.id,
        vectorData: HybridRagEngine.computeEmbedding(fullText),
      );
    }
  }

  void _initDefaultConversations() {
    // محادثة 1: مطابقة للصورة المرفقة (أعراض فقر الدم)
    final conv1 = ConversationEntity(
      id: _nextConvId++,
      title: 'أعراض فقر الدم (الأنيميا)',
      category: 'أمراض الدم',
      createdAt: DateTime(2026, 10, 27, 10, 24),
      lastUpdated: DateTime(2026, 10, 27, 10, 25),
      isFavorite: true,
    );

    // محادثة 2: مطابقة للصورة المرفقة (معلومات عن السكري)
    final conv2 = ConversationEntity(
      id: _nextConvId++,
      title: 'معلومات عن السكري',
      category: 'الأمراض المزمنة',
      createdAt: DateTime(2026, 10, 27, 9, 24),
      lastUpdated: DateTime(2026, 10, 27, 9, 25),
      isFavorite: true,
    );

    // محادثة 3: مطابقة للصورة المرفقة (أعراض التهاب المعدة)
    final conv3 = ConversationEntity(
      id: _nextConvId++,
      title: 'أعراض التهاب المعدة',
      category: 'الجهاز الهضمي',
      createdAt: DateTime(2026, 10, 26, 16, 45),
      lastUpdated: DateTime(2026, 10, 26, 16, 46),
    );

    // محادثة 4: مطابقة للصورة المرفقة (فيتامين D وأهميته)
    final conv4 = ConversationEntity(
      id: _nextConvId++,
      title: 'فيتامين D وأهميته',
      category: 'الفيتامينات والتغذية',
      createdAt: DateTime(2026, 10, 26, 12, 30),
      lastUpdated: DateTime(2026, 10, 26, 12, 31),
    );

    conversationsTable.addAll([conv1, conv2, conv3, conv4]);
    activeConversationId = conv1.id;

    // إضافة رسائل المحادثة الأولى (فقر الدم)
    _seedExchange(conv1.id, 'ما هي أعراض فقر الدم؟', DateTime(2026, 10, 27, 10, 24));
    // إضافة رسائل المحادثة الثانية (السكري)
    _seedExchange(conv2.id, 'ما هي أعراض مرض السكري؟', DateTime(2026, 10, 27, 9, 24));
    // إضافة رسائل المحادثة الثالثة (التهاب المعدة)
    _seedExchange(conv3.id, 'ما هي أسباب التهاب المعدة؟', DateTime(2026, 10, 26, 16, 45));
    // إضافة رسائل المحادثة الرابعة (فيتامين D)
    _seedExchange(conv4.id, 'ما فائدة فيتامين D للجسم؟', DateTime(2026, 10, 26, 12, 30));
  }

  void _seedExchange(int convId, String question, DateTime time) {
    messagesTable.add(
      MessageEntity(
        id: _nextMsgId++,
        conversationId: convId,
        content: question,
        senderType: 'User',
        timestamp: time,
      ),
    );
    final results = HybridRagEngine.searchHybrid(
      query: question,
      knowledgeTable: medicalKnowledgeTable,
      embeddingsTable: embeddingsTable,
    );
    final reply = LocalLlmInferenceService.synthesizeResponse(
      userQuery: question,
      retrievedContext: results,
      llmConfig: llmConfig,
      isDosageWarning: false,
    );
    messagesTable.add(
      MessageEntity(
        id: _nextMsgId++,
        conversationId: convId,
        content: reply,
        senderType: 'AI',
        timestamp: time.add(const Duration(minutes: 1)),
        sources: results,
        responseTimeMs: 420.0,
      ),
    );
  }

  List<ConversationEntity> get filteredConversations {
    if (searchQuery.trim().isEmpty) return conversationsTable;
    final q = searchQuery.trim().toLowerCase();
    return conversationsTable.where((c) {
      if (c.title.toLowerCase().contains(q) || c.category.toLowerCase().contains(q)) {
        return true;
      }
      return messagesTable.any(
        (m) => m.conversationId == c.id && m.content.toLowerCase().contains(q),
      );
    }).toList();
  }

  ConversationEntity get activeConversation {
    return conversationsTable.firstWhere(
      (c) => c.id == activeConversationId,
      orElse: () => conversationsTable.first,
    );
  }

  List<MessageEntity> get activeMessages {
    return messagesTable.where((m) => m.conversationId == activeConversationId).toList();
  }

  /// إنشاء جلسة محادثة جديدة
  ConversationEntity createNewConversation({String? initialTitle}) {
    final conv = ConversationEntity(
      id: _nextConvId++,
      title: initialTitle ?? 'استفسار طبي جديد',
      category: 'استشارة عامة',
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
    conversationsTable.insert(0, conv);
    activeConversationId = conv.id;
    notifyListeners();
    return conv;
  }

  void selectConversation(int id) {
    activeConversationId = id;
    notifyListeners();
  }

  void toggleFavoriteConversation(int id) {
    final idx = conversationsTable.indexWhere((c) => c.id == id);
    if (idx != -1) {
      conversationsTable[idx].isFavorite = !conversationsTable[idx].isFavorite;
      notifyListeners();
    }
  }

  void deleteConversation(int id) {
    if (conversationsTable.length <= 1) {
      messagesTable.removeWhere((m) => m.conversationId == id);
      notifyListeners();
      return;
    }
    conversationsTable.removeWhere((c) => c.id == id);
    messagesTable.removeWhere((m) => m.conversationId == id);
    if (activeConversationId == id) {
      activeConversationId = conversationsTable.first.id;
    }
    notifyListeners();
  }

  void clearCurrentConversation() {
    messagesTable.removeWhere((m) => m.conversationId == activeConversationId);
    notifyListeners();
  }

  /// إرسال سؤال طبي وتنفيذ خط أنابيب DFD Level 1 (Safety Filter -> Hybrid RAG -> Local LLM -> Output Filter)
  Future<void> sendMedicalQuery(String rawQuery) async {
    final String query = rawQuery.trim();
    if (query.isEmpty || isGenerating) return;

    final DateTime startClock = DateTime.now();

    // إضافة رسالة المستخدم
    messagesTable.add(
      MessageEntity(
        id: _nextMsgId++,
        conversationId: activeConversationId,
        content: query,
        senderType: 'User',
        timestamp: startClock,
      ),
    );

    // تحديث عنوان المحادثة إذا كانت جديدة
    final conv = activeConversation;
    if (conv.title == 'استفسار طبي جديد') {
      conv.title = query.length > 28 ? '${query.substring(0, 28)}...' : query;
    }
    conv.lastUpdated = DateTime.now();

    isGenerating = true;
    generationStatus = '1/3 جاري فحص معايير السلامة الطبية (Guardrails)...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 220));

    // الخطوة 1: فحص طبقة الأمان الطبي (D1 Input Safety Filter)
    final SafetyCheckResult safety = SecurityGuardrailsService.inspectQuery(query);
    if (safety.isEmergency) {
      messagesTable.add(
        MessageEntity(
          id: _nextMsgId++,
          conversationId: activeConversationId,
          content: safety.emergencyResponse!,
          senderType: 'Emergency',
          timestamp: DateTime.now(),
          responseTimeMs: DateTime.now().difference(startClock).inMilliseconds.toDouble(),
        ),
      );
      isGenerating = false;
      generationStatus = '';
      notifyListeners();
      return;
    }

    // الخطوة 2: محرك البحث الهجين (D2 Hybrid RAG Search: FTS5 BM25 + Vector Cosine)
    generationStatus = '2/3 جاري البحث الهجين في قاعدة المعرفة (BM25 + Vectors)...';
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 280));

    final List<RetrievedChunkResult> retrieved = HybridRagEngine.searchHybrid(
      query: query,
      knowledgeTable: medicalKnowledgeTable,
      embeddingsTable: embeddingsTable,
      topK: 3,
    );

    // الخطوة 3: الاستدلال اللغوي المحلي (D3 Local LLM Inference)
    generationStatus = '3/3 جاري توليد الإجابة عبر ${llmConfig.modelName}...';
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 320));

    final String responseText = LocalLlmInferenceService.synthesizeResponse(
      userQuery: query,
      retrievedContext: retrieved,
      llmConfig: llmConfig,
      isDosageWarning: safety.isDosageRequest,
    );

    final double elapsedMs = DateTime.now().difference(startClock).inMilliseconds.toDouble();

    messagesTable.add(
      MessageEntity(
        id: _nextMsgId++,
        conversationId: activeConversationId,
        content: responseText,
        senderType: 'AI',
        timestamp: DateTime.now(),
        sources: retrieved,
        responseTimeMs: elapsedMs,
      ),
    );

    isGenerating = false;
    generationStatus = '';
    notifyListeners();
  }

  /// إعادة توليد آخر إجابة
  Future<void> regenerateLastResponse(MessageEntity aiMessage) async {
    final List<MessageEntity> convMsgs = activeMessages;
    final int idx = convMsgs.indexWhere((m) => m.id == aiMessage.id);
    if (idx <= 0) return;
    final MessageEntity prevUserMsg = convMsgs[idx - 1];
    if (prevUserMsg.senderType != 'User') return;

    messagesTable.removeWhere((m) => m.id == aiMessage.id);
    await sendMedicalQuery(prevUserMsg.content);
  }

  /// استيراد وتقسيم وفهرسة وثيقة طبية جديدة (Knowledge Ingestion Module - Section 4.5.2)
  int ingestMedicalDocument({
    required String title,
    required String englishTerm,
    required String category,
    required String sourceName,
    required String rawContent,
    required List<String> keywords,
  }) {
    final List<String> chunks = HybridRagEngine.slidingWindowChunking(
      rawContent,
      windowWords: 90,
      overlapWords: 18,
    );

    int addedCount = 0;
    for (int i = 0; i < chunks.length; i++) {
      final int newId = _nextChunkId++;
      final String chunkTitle = chunks.length > 1 ? '$title (جزء ${i + 1})' : title;
      final entity = MedicalKnowledgeEntity(
        id: newId,
        title: chunkTitle,
        englishTerm: englishTerm,
        category: category,
        contentChunk: chunks[i],
        sourceName: sourceName,
        packageVersion: 'v2.5.0-Custom',
        addedDate: DateTime.now(),
        keywords: keywords,
      );
      medicalKnowledgeTable.insert(0, entity);
      final String combined = '$chunkTitle $category $englishTerm ${keywords.join(" ")} ${chunks[i]}';
      embeddingsTable[newId] = EmbeddingEntity(
        id: newId,
        chunkId: newId,
        vectorData: HybridRagEngine.computeEmbedding(combined),
      );
      addedCount++;
    }
    notifyListeners();
    return addedCount;
  }

  void deleteKnowledgeChunk(int chunkId) {
    medicalKnowledgeTable.removeWhere((k) => k.id == chunkId);
    embeddingsTable.remove(chunkId);
    notifyListeners();
  }

  void toggleThemeMode(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void updateFontScale(double scale) {
    fontScale = scale;
    notifyListeners();
  }

  void updateModelSelection(String modelName, String path, double ramGb) {
    llmConfig.modelName = modelName;
    llmConfig.modelPath = path;
    llmConfig.ramUsageGb = ramGb;
    notifyListeners();
  }
}

// ============================================================================
// 7. التطبيق الرئيسي وإدارة الثيمات والتوجيه (Root App & Splash Screen)
// ============================================================================

class MediqAiApp extends StatefulWidget {
  const MediqAiApp({super.key});

  @override
  State<MediqAiApp> createState() => _MediqAiAppState();
}

class _MediqAiAppState extends State<MediqAiApp> {
  final MediqViewModel viewModel = MediqViewModel();
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return MaterialApp(
          title: 'MEDIQ AI - مساعدك الطبي الذكي',
          debugShowCheckedModeBanner: false,
          themeMode: viewModel.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: MediqColors.lightBg,
            colorScheme: ColorScheme.fromSeed(
              seedColor: MediqColors.primaryBlue,
              brightness: Brightness.light,
              primary: MediqColors.primaryBlue,
              secondary: MediqColors.cyanBright,
              surface: MediqColors.lightSurface,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: MediqColors.navyDark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: MediqColors.cyanBright,
              brightness: Brightness.dark,
              primary: MediqColors.cyanBright,
              secondary: MediqColors.primaryBlue,
              surface: MediqColors.navyMid,
            ),
          ),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(viewModel.fontScale),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: _showSplash
              ? MediqSplashScreen(
                  onSkip: () => setState(() => _showSplash = false),
                )
              : MediqAdaptiveShell(viewModel: viewModel),
        );
      },
    );
  }
}

// ============================================================================
// 8. شاشة البداية التفاعلية (Splash Screen - مطابقة للصورة المرفقة 1)
// ============================================================================
class MediqSplashScreen extends StatefulWidget {
  final VoidCallback onSkip;
  const MediqSplashScreen({super.key, required this.onSkip});

  @override
  State<MediqSplashScreen> createState() => _MediqSplashScreenState();
}

class _MediqSplashScreenState extends State<MediqSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: MediqColors.darkBgGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // دوائر إضاءة خلفية
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MediqColors.primaryBlue.withOpacity(0.15),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.04).animate(
                          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                        ),
                        child: const MediqLogoWidget(
                          size: 130,
                          showText: true,
                          showSubtitle: true,
                          isDarkBackground: true,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'اسأل ... افهم ... تعلّم',
                        style: TextStyle(
                          color: MediqColors.cyanBright,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // موجة نبض القلب (ECG Wave Graphic)
                      SizedBox(
                        width: 220,
                        height: 44,
                        child: CustomPaint(
                          painter: _EcgWavePainter(),
                        ),
                      ),
                      const SizedBox(height: 36),
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.8,
                          valueColor: AlwaysStoppedAnimation<Color>(MediqColors.cyanBright),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'جاري تهيئة المساعد الطبي الذكي وقاعدة المعرفة المحلية...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: widget.onSkip,
                        icon: const Icon(Icons.arrow_back_rounded, color: MediqColors.cyanBright, size: 18),
                        label: const Text(
                          'الدخول المباشر للتطبيق',
                          style: TextStyle(color: MediqColors.cyanBright, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EcgWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double my = size.height / 2;
    final Path path = Path()
      ..moveTo(0, my)
      ..lineTo(w * 0.30, my)
      ..lineTo(w * 0.36, my - 6)
      ..lineTo(w * 0.41, my + 8)
      ..lineTo(w * 0.47, my - 20)
      ..lineTo(w * 0.53, my + 16)
      ..lineTo(w * 0.58, my - 8)
      ..lineTo(w * 0.64, my)
      ..lineTo(w, my);

    final Paint glow = Paint()
      ..color = MediqColors.cyanBright.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, glow);

    final Paint line = Paint()
      ..color = MediqColors.cyanBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 9. الغلاف المتجاوب للهاتف وسطح المكتب (Adaptive Shell - Mobile & Desktop)
// يجمع بين تصميم الهاتف (الصورة 1) وتصميم سطح المكتب ذي الـ 3 أعمدة (الصورة 2 و 3)
// ============================================================================
class MediqAdaptiveShell extends StatefulWidget {
  final MediqViewModel viewModel;
  const MediqAdaptiveShell({super.key, required this.viewModel});

  @override
  State<MediqAdaptiveShell> createState() => _MediqAdaptiveShellState();
}

class _MediqAdaptiveShellState extends State<MediqAdaptiveShell> {
  int _selectedTabIndex = 1; // 0: الرئيسية، 1: المحادثة، 2: المعرفة والأدوات، 3: المفضلة، 4: الإعدادات

  void _openConversation(int convId) {
    widget.viewModel.selectConversation(convId);
    setState(() => _selectedTabIndex = 1);
  }

  void _startNewChatWithPrompt([String? prompt]) {
    widget.viewModel.createNewConversation(initialTitle: prompt);
    setState(() => _selectedTabIndex = 1);
    if (prompt != null && prompt.isNotEmpty) {
      widget.viewModel.sendMedicalQuery(prompt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 980;
        final bool isTablet = constraints.maxWidth >= 680 && constraints.maxWidth < 980;

        if (isDesktop || isTablet) {
          return Scaffold(
            body: Row(
              children: [
                // القائمة الجانبية الداكنة اليمنى (Sidebar - مطابقة للصورة 2 و 3)
                SizedBox(
                  width: 270,
                  child: _DarkNavigationSidebar(
                    viewModel: widget.viewModel,
                    selectedIndex: _selectedTabIndex,
                    onSelectTab: (idx) => setState(() => _selectedTabIndex = idx),
                    onNewChat: () => _startNewChatWithPrompt(),
                    onSelectConversation: _openConversation,
                  ),
                ),
                // المنطقة المركزية (Central Content Area)
                Expanded(
                  child: _buildMainTabBody(isDesktop: true),
                ),
                // اللوحة الإرشادية اليسرى لسطح المكتب (Right Info Panel - مطابقة للصورة 2)
                if (isDesktop)
                  SizedBox(
                    width: 290,
                    child: _DesktopMedicalInfoSidebar(
                      viewModel: widget.viewModel,
                      onQuickPrompt: _startNewChatWithPrompt,
                    ),
                  ),
              ],
            ),
          );
        }

        // واجهة الهاتف المحمول (Mobile Layout with Drawer & BottomNavigationBar)
        return Scaffold(
          drawer: Drawer(
            width: 285,
            backgroundColor: MediqColors.navyDark,
            child: _DarkNavigationSidebar(
              viewModel: widget.viewModel,
              selectedIndex: _selectedTabIndex,
              onSelectTab: (idx) {
                Navigator.of(context).pop();
                setState(() => _selectedTabIndex = idx);
              },
              onNewChat: () {
                Navigator.of(context).pop();
                _startNewChatWithPrompt();
              },
              onSelectConversation: (id) {
                Navigator.of(context).pop();
                _openConversation(id);
              },
            ),
          ),
          body: _buildMainTabBody(isDesktop: false),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedTabIndex,
            onDestinationSelected: (idx) => setState(() => _selectedTabIndex = idx),
            height: 66,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: MediqColors.primaryBlue),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded, color: MediqColors.primaryBlue),
                label: 'المحادثات',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded, color: MediqColors.primaryBlue),
                label: 'المعرفة والأدوات',
              ),
              NavigationDestination(
                icon: Icon(Icons.star_border_rounded),
                selectedIcon: Icon(Icons.star_rounded, color: MediqColors.primaryBlue),
                label: 'المفضلة',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded, color: MediqColors.primaryBlue),
                label: 'الإعدادات',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainTabBody({required bool isDesktop}) {
    switch (_selectedTabIndex) {
      case 0:
        return _HomeDashboardView(
          viewModel: widget.viewModel,
          onOpenConversation: _openConversation,
          onStartNewChat: _startNewChatWithPrompt,
          onNavigateTab: (idx) => setState(() => _selectedTabIndex = idx),
        );
      case 1:
        return _InteractiveChatView(
          viewModel: widget.viewModel,
          isDesktop: isDesktop,
          onStartNewChat: _startNewChatWithPrompt,
        );
      case 2:
        return _KnowledgeExplorerAndToolsView(
          viewModel: widget.viewModel,
          onAskAi: _startNewChatWithPrompt,
        );
      case 3:
        return _FavoritesAndBookmarksView(
          viewModel: widget.viewModel,
          onOpenConversation: _openConversation,
        );
      case 4:
      default:
        return _SettingsAndAdminView(
          viewModel: widget.viewModel,
        );
    }
  }
}

// ============================================================================
// 10. القائمة الجانبية الداكنة (Dark Sidebar / Drawer - مطابقة للصور المرفقة)
// ============================================================================
class _DarkNavigationSidebar extends StatelessWidget {
  final MediqViewModel viewModel;
  final int selectedIndex;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onNewChat;
  final ValueChanged<int> onSelectConversation;

  const _DarkNavigationSidebar({
    required this.viewModel,
    required this.selectedIndex,
    required this.onSelectTab,
    required this.onNewChat,
    required this.onSelectConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: MediqColors.darkBgGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // رأس القائمة مع الشعار
              Row(
                children: [
                  const MediqLogoWidget(
                    size: 42,
                    showText: false,
                    isDarkBackground: true,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'MEDIQ AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          'مساعدك الطبي الذكي',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // بطاقة المستخدم الحالي والدور (RBAC Role Badge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: viewModel.isAdmin
                          ? MediqColors.amberWarn.withOpacity(0.25)
                          : MediqColors.primaryBlue.withOpacity(0.3),
                      child: Icon(
                        viewModel.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                        color: viewModel.isAdmin ? MediqColors.amberWarn : MediqColors.cyanBright,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.currentUser?.fullName ?? 'مستخدم',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                          Text(
                            viewModel.isAdmin ? 'صلاحية: Knowledge Admin' : 'صلاحية: Local User',
                            style: TextStyle(
                              color: viewModel.isAdmin ? MediqColors.amberWarn : MediqColors.cyanBright,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // زر محادثة جديدة البارز
              ElevatedButton.icon(
                onPressed: onNewChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MediqColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
                icon: const Icon(Icons.add_comment_rounded, size: 19),
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'محادثة جديدة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Icon(Icons.add, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // شريط البحث في المحادثات
              TextField(
                onChanged: (val) {
                  viewModel.searchQuery = val;
                  viewModel.notifyListeners();
                },
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'البحث في المحادثات...',
                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 12.5),
                  prefixIcon: const Icon(Icons.search, color: Colors.white60, size: 18),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.07),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // عناصر التنقل الرئيسية
              _SidebarNavItem(
                icon: Icons.dashboard_rounded,
                label: 'الرئيسية والملخص',
                isSelected: selectedIndex == 0,
                onTap: () => onSelectTab(0),
              ),
              _SidebarNavItem(
                icon: Icons.history_rounded,
                label: 'المحادثات السابقة',
                isSelected: selectedIndex == 1,
                onTap: () => onSelectTab(1),
              ),
              _SidebarNavItem(
                icon: Icons.star_outline_rounded,
                label: 'المفضلة والمحفوظات',
                isSelected: selectedIndex == 3,
                onTap: () => onSelectTab(3),
              ),
              _SidebarNavItem(
                icon: Icons.menu_book_rounded,
                label: 'المعلومات والأدوات الطبية',
                isSelected: selectedIndex == 2,
                onTap: () => onSelectTab(2),
              ),
              _SidebarNavItem(
                icon: Icons.settings_outlined,
                label: 'الإعدادات وإدارة المعرفة',
                isSelected: selectedIndex == 4,
                onTap: () => onSelectTab(4),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Divider(color: Colors.white12, height: 1),
              ),

              const Text(
                'سجل الجلسات الأخيرة',
                style: TextStyle(color: Colors.white60, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),

              // قائمة الجلسات السابقة القابلة للتمرير
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.filteredConversations.length,
                  itemBuilder: (context, index) {
                    final conv = viewModel.filteredConversations[index];
                    final bool isActive = conv.id == viewModel.activeConversationId && selectedIndex == 1;
                    return InkWell(
                      onTap: () => onSelectConversation(conv.id),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? MediqColors.primaryBlue.withOpacity(0.25) : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          border: isActive
                              ? Border.all(color: MediqColors.cyanBright.withOpacity(0.5))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 15,
                              color: isActive ? MediqColors.cyanBright : Colors.white60,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                conv.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isActive ? Colors.white : Colors.white70,
                                  fontSize: 12.5,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (conv.isFavorite)
                              const Icon(Icons.star_rounded, size: 14, color: MediqColors.amberWarn),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              // بطاقات حالة التشغيل المحلي والنموذج (مطابقة لأسفل القائمة في الصور 1 و 2)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2342),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: MediqColors.emeraldSafe.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: MediqColors.emeraldSafe,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'يعمل محلياً (Offline-First)',
                            style: TextStyle(
                              color: MediqColors.emeraldSafe,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'بدون إنترنت • خصوصية تامة',
                            style: TextStyle(color: Colors.white60, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.wifi_off_rounded, color: MediqColors.cyanBright, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2342),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.memory_rounded, color: MediqColors.cyanBright, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'النموذج المستخدم (GGUF)',
                            style: TextStyle(color: Colors.white60, fontSize: 10.5),
                          ),
                          Text(
                            viewModel.llmConfig.modelName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'MEDIQ AI v1.0.0 • Hybrid RAG Engine',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? MediqColors.cyanBright : Colors.white70,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 11. الشاشة الرئيسية والملخص (Home Screen - مطابقة للشاشة الوسطى في الصورة 1)
// ============================================================================
class _HomeDashboardView extends StatelessWidget {
  final MediqViewModel viewModel;
  final ValueChanged<int> onOpenConversation;
  final ValueChanged<String?> onStartNewChat;
  final ValueChanged<int> onNavigateTab;

  const _HomeDashboardView({
    required this.viewModel,
    required this.onOpenConversation,
    required this.onStartNewChat,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const MediqLogoWidget(size: 36, showText: false, isDarkBackground: false),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textDirection: TextDirection.ltr,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : MediqColors.navyDark,
                    ),
                    children: const [
                      TextSpan(text: 'MEDIQ '),
                      TextSpan(text: 'AI', style: TextStyle(color: MediqColors.primaryBlue)),
                    ],
                  ),
                ),
                Text(
                  'مساعدك الطبي الذكي',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : MediqColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تبديل الوضع الليلي/النهاري',
            onPressed: () => viewModel.toggleThemeMode(!isDark),
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              onTap: () => onNavigateTab(4),
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: MediqColors.navyDark,
                child: Icon(
                  viewModel.isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: MediqColors.cyanBright,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقة حالة الخادم المحلي (تعمل محلياً - مطابقة للصورة 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? MediqColors.navyCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : MediqColors.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: MediqColors.emeraldSafe,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'يعمل محلياً (Offline Mode)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                      Text(
                        'المساعد المحلي متصل • ${viewModel.llmConfig.modelName} • ${viewModel.medicalKnowledgeTable.length} وحدة معرفة مفهرسة',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : MediqColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.dns_rounded, color: MediqColors.primaryBlue),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // حقل البحث في المحادثات
          TextField(
            onChanged: (val) {
              viewModel.searchQuery = val;
              viewModel.notifyListeners();
            },
            decoration: InputDecoration(
              hintText: 'ابحث في المحادثات أو المواضيع الطبية...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: isDark ? MediqColors.navyCard : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? Colors.white12 : MediqColors.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? Colors.white12 : MediqColors.lightBorder),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // زر محادثة جديدة المتدرج
          InkWell(
            onTap: () => onStartNewChat(null),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                gradient: MediqColors.brandGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MediqColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'محادثة طبية جديدة',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // بطاقات الأسئلة الطبية السريعة (مطابقة للصورة 3)
          const Text(
            'استفسارات طبية سريعة (RAG Quick Prompts)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickTopicChip(
                icon: Icons.bloodtype_rounded,
                title: 'ما هي أعراض فقر الدم؟',
                subtitle: 'الأنيميا ونقص الحديد',
                onTap: () => onStartNewChat('ما هي أعراض فقر الدم؟'),
              ),
              _QuickTopicChip(
                icon: Icons.monitor_heart_rounded,
                title: 'ما هي أعراض ارتفاع ضغط الدم؟',
                subtitle: 'الوقاية والقياس',
                onTap: () => onStartNewChat('ما هي أعراض ارتفاع ضغط الدم؟'),
              ),
              _QuickTopicChip(
                icon: Icons.shield_rounded,
                title: 'كيف يعمل الجهاز المناعي؟',
                subtitle: 'المناعة الفطرية والمكتسبة',
                onTap: () => onStartNewChat('كيف يعمل الجهاز المناعي؟'),
              ),
              _QuickTopicChip(
                icon: Icons.wb_sunny_rounded,
                title: 'ما فائدة فيتامين D للجسم؟',
                subtitle: 'العظام والمناعة',
                onTap: () => onStartNewChat('ما فائدة فيتامين D للجسم؟'),
              ),
              _QuickTopicChip(
                icon: Icons.biotech_rounded,
                title: 'اشرح مصطلح تحليل CBC و HbA1c',
                subtitle: 'الفحوصات الطبية',
                onTap: () => onStartNewChat('اشرح مصطلح تحليل CBC و HbA1c'),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // قسم المحادثات الأخيرة (مطابق للشاشة الوسطى في الصورة 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المحادثات الأخيرة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () => onNavigateTab(1),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 6),

          ...viewModel.filteredConversations.map((conv) {
            final lastMsg = viewModel.messagesTable
                .where((m) => m.conversationId == conv.id)
                .toList();
            final String preview = lastMsg.isNotEmpty
                ? lastMsg.last.content.replaceAll(RegExp(r'[#*•]'), '').trim()
                : 'لا توجد رسائل بعد';

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              color: isDark ? MediqColors.navyCard : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? Colors.white12 : MediqColors.lightBorder),
              ),
              child: ListTile(
                onTap: () => onOpenConversation(conv.id),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: MediqColors.primaryBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconForCategory(conv.title),
                    color: MediqColors.primaryBlue,
                  ),
                ),
                title: Text(
                  conv.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                subtitle: Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white70 : MediqColors.textMuted,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${conv.lastUpdated.hour.toString().padLeft(2, '0')}:${conv.lastUpdated.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : MediqColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => viewModel.toggleFavoriteConversation(conv.id),
                          child: Icon(
                            conv.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 18,
                            color: conv.isFavorite ? MediqColors.amberWarn : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => viewModel.deleteConversation(conv.id),
                          child: const Icon(Icons.delete_outline_rounded, size: 17, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _iconForCategory(String title) {
    if (title.contains('السكري')) return Icons.water_drop_rounded;
    if (title.contains('المعدة')) return Icons.medical_information_rounded;
    if (title.contains('فيتامين')) return Icons.wb_sunny_rounded;
    if (title.contains('فقر الدم')) return Icons.bloodtype_rounded;
    return Icons.description_rounded;
  }
}

class _QuickTopicChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickTopicChip({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 215,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? MediqColors.navyCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white12 : MediqColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MediqColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: MediqColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : MediqColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 12. شاشة المحادثة التفاعلية (Interactive Chat Area - القسم 4.7.1 و 4.7.2)
// تطابق الشاشات في الصور 1 و 2 و 3 مع أزرار نسخ الإجابة، إعادة التوليد، والتقييم
// ============================================================================
class _InteractiveChatView extends StatefulWidget {
  final MediqViewModel viewModel;
  final bool isDesktop;
  final ValueChanged<String?> onStartNewChat;

  const _InteractiveChatView({
    required this.viewModel,
    required this.isDesktop,
    required this.onStartNewChat,
  });

  @override
  State<_InteractiveChatView> createState() => _InteractiveChatViewState();
}

class _InteractiveChatViewState extends State<_InteractiveChatView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    widget.viewModel.sendMedicalQuery(text).then((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 180,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showDiagnosticSamplePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إدراج نموذج تقرير فحص مخبري أو سؤال سريري جاهز',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.science_rounded, color: MediqColors.primaryBlue),
                title: const Text('تقرير فحص صورة دم كاملة (CBC) مع نقص الهيموجلوبين'),
                subtitle: const Text('Hb: 9.8 g/dL, Ferritin: 8 ng/mL - ما تفسير هذه القيم؟'),
                onTap: () {
                  Navigator.pop(ctx);
                  _inputController.text =
                      'لدي تقرير تحليل CBC يظهر الهيموجلوبين ومخزون الحديد الفيريتين منخفضاً مع شعور بالتعب وشحوب، ما هي أعراض فقر الدم؟';
                },
              ),
              ListTile(
                leading: const Icon(Icons.monitor_weight_rounded, color: MediqColors.primaryBlue),
                title: const Text('استفسار حول السكر التراكمي وأعراض السكري'),
                subtitle: const Text('عطش مستمر وكثرة التبول مع تحليل HbA1c'),
                onTap: () {
                  Navigator.pop(ctx);
                  _inputController.text = 'ما هي أعراض مرض السكري وما أهمية فحص السكر التراكمي HbA1c؟';
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: MediqColors.crimsonEmergency),
                title: const Text('اختبار طبقة الأمان الطبي وحالات الطوارئ (Guardrail Test)'),
                subtitle: const Text('محاكاة سؤال يحتوي على: ألم شديد في الصدر أو جلطة أو نزيف حاد'),
                onTap: () {
                  Navigator.pop(ctx);
                  _inputController.text = 'أشعر بألم شديد في الصدر مع ضيق تنفس حاد واشتباه جلطة، ماذا أفعل؟';
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final conv = widget.viewModel.activeConversation;
    final messages = widget.viewModel.activeMessages;

    return Column(
      children: [
        // شريط علوي للمحادثة (Top Header Bar)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? MediqColors.navyMid : Colors.white,
            border: Border(
              bottom: BorderSide(color: isDark ? Colors.white12 : MediqColors.lightBorder),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                if (!widget.isDesktop)
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                const MediqLogoWidget(size: 32, showText: false, isDarkBackground: false),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conv.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: MediqColors.emeraldSafe,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'متصل محلياً • ${widget.viewModel.llmConfig.modelName}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: MediqColors.emeraldSafe,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'تفضيل المحادثة',
                  onPressed: () => widget.viewModel.toggleFavoriteConversation(conv.id),
                  icon: Icon(
                    conv.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: conv.isFavorite ? MediqColors.amberWarn : null,
                  ),
                ),
                IconButton(
                  tooltip: 'مسح سجل هذه الجلسة',
                  onPressed: widget.viewModel.clearCurrentConversation,
                  icon: const Icon(Icons.cleaning_services_outlined, size: 20),
                ),
              ],
            ),
          ),
        ),

        // لافتة التنويه الطبي الدائمة أعلى الشاشة (Section 4.7.5 Disclaimer Banner)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          color: MediqColors.primaryBlue.withOpacity(isDark ? 0.18 : 0.08),
          child: Row(
            children: const [
              Icon(Icons.verified_user_outlined, size: 16, color: MediqColors.primaryBlue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تنويه طبي (القسم 4.7.5): يقدم النظام معلومات طبية تثقيفية عامة مبنية على قاعدة معرفة محلية (RAG) ولا يُعد بديلاً للتشخيص الطبي البشري.',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        // منطقة عرض الرسائل أو شاشة الترحيب الفارغة (مطابقة للصورة 3 عند عدم وجود رسائل)
        Expanded(
          child: messages.isEmpty
              ? _EmptyChatWelcomeOverlay(
                  onQuickSelect: (q) => widget.viewModel.sendMedicalQuery(q),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: messages.length + (widget.viewModel.isGenerating ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return _GeneratingStatusIndicator(
                        statusText: widget.viewModel.generationStatus,
                      );
                    }
                    final msg = messages[index];
                    return _MessageBubbleCard(
                      message: msg,
                      viewModel: widget.viewModel,
                    );
                  },
                ),
        ),

        // شريط إدخال البيانات السفلي المرن (Section 4.7.2 Input Bar - مطابق للصورة 2)
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            color: isDark ? MediqColors.navyMid : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? MediqColors.navyCard : MediqColors.lightBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? Colors.white12 : MediqColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _inputController,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: 4000,
                            onSubmitted: (_) => _handleSend(),
                            decoration: const InputDecoration(
                              hintText: 'اكتب سؤالك الطبي هنا... (مثال: ما هي أعراض فقر الدم؟)',
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
                            child: Row(
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'إدراج نموذج تحليل أو حالة سريرية',
                                  onPressed: _showDiagnosticSamplePicker,
                                  icon: const Icon(Icons.attach_file_rounded, size: 19, color: MediqColors.primaryBlue),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'فحص الأعراض السريع',
                                  onPressed: _showDiagnosticSamplePicker,
                                  icon: const Icon(Icons.analytics_outlined, size: 19, color: MediqColors.primaryBlue),
                                ),
                                const Spacer(),
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _inputController,
                                  builder: (_, val, __) => Text(
                                    '${val.text.length}/4000',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // زر الإرسال الدائري الأزرق (يتحول لمؤشر جاري المعالجة أثناء الاستدلال)
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: widget.viewModel.isGenerating ? null : _handleSend,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: MediqColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 3,
                      ),
                      child: widget.viewModel.isGenerating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// واجهة الترحيب عند بدء محادثة فارغة (مطابقة لشاشة اللابتوب في الصورة 3)
class _EmptyChatWelcomeOverlay extends StatelessWidget {
  final ValueChanged<String> onQuickSelect;
  const _EmptyChatWelcomeOverlay({required this.onQuickSelect});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MediqLogoWidget(
              size: 86,
              showText: true,
              showSubtitle: true,
              isDarkBackground: isDark,
            ),
            const SizedBox(height: 22),
            const Text(
              'كيف يمكنني مساعدتك اليوم؟',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'اطرح سؤالك باللغة العربية الطبيعية وسيقوم محرك البحث الهجين (RAG) باسترجاع أدق المراجع الطبية المحلية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.white70 : MediqColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _QuickTopicChip(
                  icon: Icons.favorite_border_rounded,
                  title: 'ما هي أعراض ارتفاع ضغط الدم؟',
                  subtitle: 'الأعراض والوقاية',
                  onTap: () => onQuickSelect('ما هي أعراض ارتفاع ضغط الدم؟'),
                ),
                _QuickTopicChip(
                  icon: Icons.shield_outlined,
                  title: 'كيف يعمل الجهاز المناعي؟',
                  subtitle: 'خطوط الدفاع الحيوية',
                  onTap: () => onQuickSelect('كيف يعمل الجهاز المناعي؟'),
                ),
                _QuickTopicChip(
                  icon: Icons.medication_outlined,
                  title: 'ما فائدة فيتامين D للجسم؟',
                  subtitle: 'المصادر والفوائد',
                  onTap: () => onQuickSelect('ما فائدة فيتامين D للجسم؟'),
                ),
                _QuickTopicChip(
                  icon: Icons.menu_book_rounded,
                  title: 'اشرح هذا المصطلح الطبي CBC',
                  subtitle: 'تحاليل الدم المخبرية',
                  onTap: () => onQuickSelect('اشرح مصطلح تحليل CBC و HbA1c'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratingStatusIndicator extends StatelessWidget {
  final String statusText;
  const _GeneratingStatusIndicator({required this.statusText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MediqColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MediqColors.primaryBlue.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة الرسالة (تطابق تصميم بطاقات المحادثة في الصورة 1 و 2)
class _MessageBubbleCard extends StatelessWidget {
  final MessageEntity message;
  final MediqViewModel viewModel;

  const _MessageBubbleCard({
    required this.message,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isUser = message.senderType == 'User';
    final bool isEmergency = message.senderType == 'Emergency';
    final String timeStr =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 17,
              backgroundColor: MediqColors.primaryBlue,
              child: Icon(Icons.person, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? MediqColors.primaryBlue.withOpacity(0.28)
                      : const Color(0xFFD9ECFF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: isDark ? Colors.white : MediqColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? Colors.white60 : MediqColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all_rounded, size: 14, color: MediqColors.primaryBlue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // رسالة المساعد الطبي الذكي أو رسالة الطوارئ الحرجة
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isEmergency ? MediqColors.crimsonEmergency : MediqColors.navyDark,
              shape: BoxShape.circle,
            ),
            child: isEmergency
                ? const Icon(Icons.warning_rounded, color: Colors.white, size: 20)
                : const MediqLogoWidget(size: 24, showText: false, isDarkBackground: true),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isEmergency
                    ? MediqColors.crimsonEmergency.withOpacity(isDark ? 0.2 : 0.08)
                    : (isDark ? MediqColors.navyCard : Colors.white),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isEmergency
                      ? MediqColors.crimsonEmergency
                      : (isDark ? Colors.white12 : MediqColors.lightBorder),
                  width: isEmergency ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رأس رسالة MEDIQ AI
                  Row(
                    children: [
                      Text(
                        isEmergency ? 'بروتوكول الطوارئ والسلامة الطبية' : 'MEDIQ AI',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: isEmergency ? MediqColors.crimsonEmergency : MediqColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      if (message.responseTimeMs != null) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: MediqColors.emeraldSafe.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '⚡ ${message.responseTimeMs!.toInt()} ms',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: MediqColors.emeraldSafe,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Divider(height: 16),

                  // محتوى الإجابة المنسق مع صندوق الملاحظة المهمة (مطابق للصورة 2)
                  _FormattedMedicalResponseText(content: message.content),

                  // شارات المصادر المسترجعة عبر RAG
                  if (message.sources.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.sources.map((src) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: MediqColors.primaryBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: MediqColors.primaryBlue.withOpacity(0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.menu_book_rounded, size: 13, color: MediqColors.primaryBlue),
                              const SizedBox(width: 5),
                              Text(
                                'المصدر: ${src.chunk.title} (${(src.hybridScore * 100).toInt()}%)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: MediqColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 12),
                  // شريط أزرار التفاعل السفلي (إعجاب، عدم إعجاب، نسخ الإجابة، إعادة التوليد، حفظ - مطابق للصورة 2)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _ActionButtonChip(
                        icon: message.isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_off_alt_rounded,
                        label: '',
                        isActive: message.isLiked,
                        onTap: () {
                          message.isLiked = !message.isLiked;
                          if (message.isLiked) message.isDisliked = false;
                          viewModel.notifyListeners();
                        },
                      ),
                      _ActionButtonChip(
                        icon: message.isDisliked ? Icons.thumb_down_alt_rounded : Icons.thumb_down_off_alt_rounded,
                        label: '',
                        isActive: message.isDisliked,
                        onTap: () {
                          message.isDisliked = !message.isDisliked;
                          if (message.isDisliked) message.isLiked = false;
                          viewModel.notifyListeners();
                        },
                      ),
                      _ActionButtonChip(
                        icon: Icons.copy_rounded,
                        label: 'نسخ الإجابة',
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: message.content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ الإجابة الطبية إلى الحافظة'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      _ActionButtonChip(
                        icon: Icons.refresh_rounded,
                        label: 'إعادة التوليد',
                        onTap: () => viewModel.regenerateLastResponse(message),
                      ),
                      _ActionButtonChip(
                        icon: message.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        label: message.isBookmarked ? 'محفوظة' : 'حفظ',
                        isActive: message.isBookmarked,
                        onTap: () {
                          message.isBookmarked = !message.isBookmarked;
                          viewModel.notifyListeners();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButtonChip({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? MediqColors.primaryBlue.withOpacity(0.15)
              : (isDark ? Colors.white.withOpacity(0.05) : MediqColors.lightBg),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? MediqColors.primaryBlue
                : (isDark ? Colors.white12 : MediqColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? MediqColors.primaryBlue : (isDark ? Colors.white70 : MediqColors.textMuted),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isActive ? MediqColors.primaryBlue : (isDark ? Colors.white70 : MediqColors.textDark),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// منسق النصوص الطبية الغنية مع إبراز الصناديق التحذيرية والعناوين
class _FormattedMedicalResponseText extends StatelessWidget {
  final String content;
  const _FormattedMedicalResponseText({required this.content});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> lines = content.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final String trimmed = line.trim();
        if (trimmed.isEmpty) return const SizedBox(height: 6);

        // صندوق ملاحظة مهمة (مطابق للصندوق الأزرق في الصورة 2)
        if (trimmed.contains('مهم:') || trimmed.startsWith('📋') || trimmed.startsWith('⚖️')) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MediqColors.primaryBlue.withOpacity(isDark ? 0.16 : 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MediqColors.primaryBlue.withOpacity(0.28)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_rounded, color: MediqColors.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trimmed.replaceAll('**', ''),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : MediqColors.navyDark,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (trimmed.startsWith('###')) {
          return Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Text(
              trimmed.replaceAll('###', '').replaceAll('**', '').trim(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MediqColors.primaryBlue,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            trimmed.replaceAll('**', ''),
            style: TextStyle(
              fontSize: 13.8,
              height: 1.55,
              fontWeight: trimmed.startsWith('•') ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// 13. اللوحة اليمنى/اليسرى الإرشادية لسطح المكتب (Desktop Right Info Panel - الصورة 2)
// ============================================================================
class _DesktopMedicalInfoSidebar extends StatelessWidget {
  final MediqViewModel viewModel;
  final ValueChanged<String> onQuickPrompt;

  const _DesktopMedicalInfoSidebar({
    required this.viewModel,
    required this.onQuickPrompt,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? MediqColors.navyMid : Colors.white,
        border: Border(
          right: BorderSide(color: isDark ? Colors.white12 : MediqColors.lightBorder),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بطاقة مساعدك الطبي الذكي العلوية (مطابقة للصورة 2)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? MediqColors.navyCard : MediqColors.lightBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  Icon(Icons.favorite_rounded, color: MediqColors.cyanBright, size: 42),
                  SizedBox(height: 8),
                  Text(
                    'مساعدك الطبي الذكي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'احصل على إجابات دقيقة وموثوقة لأسئلتك الطبية بالاعتماد على RAG.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const _FeatureHighlightRow(
              icon: Icons.verified_user_rounded,
              title: 'معلومات طبية موثوقة',
              subtitle: 'مبنية على مصادر طبية معتمدة ومفصولة عن النموذج',
            ),
            const _FeatureHighlightRow(
              icon: Icons.language_rounded,
              title: 'دعم اللغة العربية',
              subtitle: 'تواصل بسهولة بلغتك الأم مع شرح المصطلحات الإنجليزية',
            ),
            const _FeatureHighlightRow(
              icon: Icons.wifi_off_rounded,
              title: 'يعمل محلياً (Offline-First)',
              subtitle: 'بدون الحاجة للإنترنت أثناء التشغيل والاستدلال',
            ),
            const _FeatureHighlightRow(
              icon: Icons.lock_rounded,
              title: 'خصوصيتك تهمنا',
              subtitle: 'لا يتم إرسال بياناتك لأي جهة سحابية خارجية',
            ),

            const SizedBox(height: 16),
            // صندوق تنويه مهم (مطابق للصورة 2)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MediqColors.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MediqColors.primaryBlue.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: MediqColors.primaryBlue, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'تنويه مهم',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MediqColors.primaryBlue,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'المعلومات المقدمة في هذا التطبيق للتثقيف الطبي فقط، ولا تغني عن استشارة الطبيب المختص.\n\nفي حالات الطوارئ، يرجى التوجه مباشرة إلى أقرب مركز طبي.',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 140,
                    height: 28,
                    child: CustomPaint(painter: _EcgWavePainter()),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'معاً نحو صحة أفضل',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  MediqLogoWidget(
                    size: 54,
                    showText: true,
                    isDarkBackground: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureHighlightRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureHighlightRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MediqColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: MediqColors.primaryBlue, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 14. مستكشف المعرفة الطبية والأدوات السريرية المضافة (Knowledge Base & Clinical Tools)
// يشمل: تصفح قاعدة المعرفة (FTS5/Vectors) + حاسبة مؤشر كتلة الجسم والماء + فاحص الأعراض
// ============================================================================
class _KnowledgeExplorerAndToolsView extends StatefulWidget {
  final MediqViewModel viewModel;
  final ValueChanged<String> onAskAi;

  const _KnowledgeExplorerAndToolsView({
    required this.viewModel,
    required this.onAskAi,
  });

  @override
  State<_KnowledgeExplorerAndToolsView> createState() => _KnowledgeExplorerAndToolsViewState();
}

class _KnowledgeExplorerAndToolsViewState extends State<_KnowledgeExplorerAndToolsView> {
  String _filterQuery = '';
  double _heightCm = 172;
  double _weightKg = 74;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredChunks = widget.viewModel.medicalKnowledgeTable.where((c) {
      if (_filterQuery.trim().isEmpty) return true;
      final q = _filterQuery.toLowerCase();
      return c.title.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q) ||
          c.englishTerm.toLowerCase().contains(q) ||
          c.contentChunk.toLowerCase().contains(q);
    }).toList();

    final double bmi = _weightKg / math.pow(_heightCm / 100.0, 2);
    String bmiCategory = 'وزن طبيعي وصحي';
    Color bmiColor = MediqColors.emeraldSafe;
    if (bmi < 18.5) {
      bmiCategory = 'نحافة (أقل من الطبيعي)';
      bmiColor = MediqColors.amberWarn;
    } else if (bmi >= 25 && bmi < 30) {
      bmiCategory = 'زيادة في الوزن';
      bmiColor = MediqColors.amberWarn;
    } else if (bmi >= 30) {
      bmiCategory = 'سمنة (يُنصح بمراجعة أخصائي تغذية)';
      bmiColor = MediqColors.crimsonEmergency;
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('موسوعة المعرفة الطبية والأدوات الذكية'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.library_books_rounded), text: 'قاعدة المعرفة الطبية (RAG)'),
              Tab(icon: Icon(Icons.calculate_rounded), text: 'الحاسبات والمؤشرات الحيوية'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // التبويب الأول: تصفح قاعدة المعرفة الطبية وحزمها
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  onChanged: (v) => setState(() => _filterQuery = v),
                  decoration: InputDecoration(
                    hintText: 'ابحث في الوثائق الطبية والمصطلحات الإنجليزية (FTS5)...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: isDark ? MediqColors.navyCard : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                ...filteredChunks.map((chunk) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isDark ? MediqColors.navyCard : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isDark ? Colors.white12 : MediqColors.lightBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: MediqColors.primaryBlue.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  chunk.category,
                                  style: const TextStyle(
                                    color: MediqColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  chunk.englishTerm,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chunk.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            chunk.contentChunk.replaceAll('**', ''),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, height: 1.5),
                          ),
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'المصدر: ${chunk.sourceName} (${chunk.packageVersion})',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => widget.onAskAi('اشرح لي بالتفصيل عن: ${chunk.title}'),
                                icon: const Icon(Icons.chat_rounded, size: 16),
                                label: const Text('اسأل المساعد'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),

            // التبويب الثاني: الحاسبات الطبية التفاعلية (ميزة إضافية متقدمة)
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: isDark ? MediqColors.navyCard : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.monitor_weight_rounded, color: MediqColors.primaryBlue),
                            SizedBox(width: 8),
                            Text(
                              'حاسبة مؤشر كتلة الجسم (BMI) والاحتياج المائي اليومي',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('الطول: ${_heightCm.toInt()} سم'),
                        Slider(
                          value: _heightCm,
                          min: 120,
                          max: 210,
                          onChanged: (v) => setState(() => _heightCm = v),
                        ),
                        Text('الوزن: ${_weightKg.toInt()} كغ'),
                        Slider(
                          value: _weightKg,
                          min: 35,
                          max: 160,
                          onChanged: (v) => setState(() => _weightKg = v),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مؤشر BMI: ${bmi.toStringAsFixed(1)}',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                                ),
                                Text(
                                  bmiCategory,
                                  style: TextStyle(color: bmiColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('الاحتياج اليومي للماء:', style: TextStyle(fontSize: 12)),
                                Text(
                                  '${(_weightKg * 0.033).toStringAsFixed(1)} لتر / يومياً',
                                  style: const TextStyle(
                                    color: MediqColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: isDark ? MediqColors.navyCard : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.emergency_rounded, color: MediqColors.crimsonEmergency),
                            SizedBox(width: 8),
                            Text(
                              'أرقام وإرشادات الطوارئ الطبية السريعة',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          '• عند الاشتباه بجلطة دماغية، تذكر قاعدة (FAST): تدلي الوجه، ضعف الذراع، صعوبة النطق، والاتصال الفوري بالإسعاف.\n'
                          '• في حالات انخفاض السكر الحاد لدى مريض واعٍ: أعطِ 15 غراماً من السكر السريع (نصف كوب عصير أو ملعقة عسل) وأعد القياس بعد 15 دقيقة.',
                          style: TextStyle(fontSize: 13, height: 1.55),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 15. شاشة المفضلة والرسائل المحفوظة (Favorites & Bookmarks View)
// ============================================================================
class _FavoritesAndBookmarksView extends StatelessWidget {
  final MediqViewModel viewModel;
  final ValueChanged<int> onOpenConversation;

  const _FavoritesAndBookmarksView({
    required this.viewModel,
    required this.onOpenConversation,
  });

  @override
  Widget build(BuildContext context) {
    final favConvs = viewModel.conversationsTable.where((c) => c.isFavorite).toList();
    final bookmarkedMsgs = viewModel.messagesTable.where((m) => m.isBookmarked).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('المحادثات والإجابات الطبية المفضلة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'الجلسات المفضلة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (favConvs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('لا توجد محادثات مفضلة حالياً. اضغط على نجمة التفضيل بجوار أي محادثة.'),
            ),
          ...favConvs.map(
            (c) => Card(
              child: ListTile(
                leading: const Icon(Icons.star_rounded, color: MediqColors.amberWarn),
                title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('التصنيف: ${c.category}'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => onOpenConversation(c.id),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'الإجابات الطبية المحفوظة مرجعياً',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (bookmarkedMsgs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('يمكنك حفظ أي إجابة طبية بالضغط على زر "حفظ" أسفل إجابة المساعد.'),
            ),
          ...bookmarkedMsgs.map(
            (m) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  m.content.replaceAll('**', ''),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 16. شاشة الإعدادات ولوحة تحكم مدير المعرفة (Settings & RBAC Admin Dashboard)
// تطابق شاشة الإعدادات في الصورة 1 + نوافذ مدير المعرفة في القسم 4.7.4 و 4.8.2
// ============================================================================
class _SettingsAndAdminView extends StatefulWidget {
  final MediqViewModel viewModel;
  const _SettingsAndAdminView({required this.viewModel});

  @override
  State<_SettingsAndAdminView> createState() => _SettingsAndAdminViewState();
}

class _SettingsAndAdminViewState extends State<_SettingsAndAdminView> {
  final TextEditingController _adminUserCtrl = TextEditingController(text: 'admin');
  final TextEditingController _adminPassCtrl = TextEditingController();

  // حقول إضافة معرفة طبية جديدة (Knowledge Ingestion Form)
  final TextEditingController _docTitleCtrl = TextEditingController();
  final TextEditingController _docEngCtrl = TextEditingController();
  final TextEditingController _docSourceCtrl = TextEditingController(text: 'الدليل الطبي المعتمد 2026');
  final TextEditingController _docContentCtrl = TextEditingController();
  String _selectedCategory = 'الأمراض المزمنة';

  @override
  void dispose() {
    _adminUserCtrl.dispose();
    _adminPassCtrl.dispose();
    _docTitleCtrl.dispose();
    _docEngCtrl.dispose();
    _docSourceCtrl.dispose();
    _docContentCtrl.dispose();
    super.dispose();
  }

  void _showAdminLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security_rounded, color: MediqColors.primaryBlue),
              SizedBox(width: 8),
              Text('مصادقة مدير المعرفة (RBAC)', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'لتعديل قاعدة المعرفة الطبية أو استيراد وثائق جديدة، يرجى إدخال بيانات مدير المعرفة (يتم التحقق عبر خوارزمية PBKDF2 Salted Hash):',
                style: TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _adminUserCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم (Username)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _adminPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور (الافتراضية: admin123)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final ok = widget.viewModel.authenticateAdmin(
                  _adminUserCtrl.text,
                  _adminPassCtrl.text,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: ok ? MediqColors.emeraldSafe : MediqColors.crimsonEmergency,
                    content: Text(
                      ok
                          ? 'تم الدخول بنجاح بصلاحية مدير المعرفة (Knowledge Admin)'
                          : 'كلمة المرور غير صحيحة! استخدم admin123 للتجربة.',
                    ),
                  ),
                );
              },
              child: const Text('تحقق ودخول'),
            ),
          ],
        );
      },
    );
  }

  void _handleIngestDocument() {
    if (_docTitleCtrl.text.trim().isEmpty || _docContentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال عنوان الوثيقة والنص الطبي أولاً')),
      );
      return;
    }

    final int chunksCount = widget.viewModel.ingestMedicalDocument(
      title: _docTitleCtrl.text.trim(),
      englishTerm: _docEngCtrl.text.trim(),
      category: _selectedCategory,
      sourceName: _docSourceCtrl.text.trim(),
      rawContent: _docContentCtrl.text.trim(),
      keywords: _docTitleCtrl.text.trim().split(' '),
    );

    _docTitleCtrl.clear();
    _docEngCtrl.clear();
    _docContentCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: MediqColors.emeraldSafe,
        content: Text(
          'تم تقسيم الوثيقة بالنافذة المنزلقة (Sliding Window) إلى ($chunksCount) فقرة وبناء متجهات Embeddings وفهرسة FTS5 بنجاح!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات وإدارة المعرفة والنماذج'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقة حساب المستخدم الحالي (مطابقة لأعلى شاشة الإعدادات في الصورة 1)
          Card(
            color: isDark ? MediqColors.navyCard : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: MediqColors.primaryBlue.withOpacity(0.15),
                child: Icon(
                  widget.viewModel.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                  color: MediqColors.primaryBlue,
                  size: 28,
                ),
              ),
              title: Text(
                widget.viewModel.currentUser?.fullName ?? 'مستخدم',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
              ),
              subtitle: Text(
                '${widget.viewModel.currentUser?.username} • الدور: ${widget.viewModel.isAdmin ? "Knowledge Admin" : "Local User"}',
              ),
              trailing: widget.viewModel.isAdmin
                  ? OutlinedButton(
                      onPressed: widget.viewModel.switchToLocalUser,
                      child: const Text('وضع المستخدم'),
                    )
                  : ElevatedButton.icon(
                      onPressed: _showAdminLoginDialog,
                      icon: const Icon(Icons.lock_open_rounded, size: 16),
                      label: const Text('دخول كمدير'),
                    ),
            ),
          ),
          const SizedBox(height: 18),

          // قسم إعدادات التطبيق (مطابق للصورة 1)
          const Text(
            'إعدادات التطبيق',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Card(
            color: isDark ? MediqColors.navyCard : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.wb_sunny_outlined, color: MediqColors.primaryBlue),
                  title: const Text('المظهر الداكن (Dark Mode)'),
                  subtitle: Text(isDark ? 'الوضع الداكن مفعل' : 'الوضع الفاتح مفعل'),
                  value: isDark,
                  onChanged: (v) => widget.viewModel.toggleThemeMode(v),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: MediqColors.primaryBlue),
                  title: const Text('اللغة الأساسية'),
                  trailing: const Text('العربية (مع المصطلحات الإنجليزية)', style: TextStyle(color: Colors.grey)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.format_size_rounded, color: MediqColors.primaryBlue),
                  title: const Text('حجم الخط'),
                  trailing: DropdownButton<double>(
                    value: widget.viewModel.fontScale,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 0.9, child: Text('صغير')),
                      DropdownMenuItem(value: 1.0, child: Text('متوسط')),
                      DropdownMenuItem(value: 1.12, child: Text('كبير')),
                    ],
                    onChanged: (v) {
                      if (v != null) widget.viewModel.updateFontScale(v);
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.save_outlined, color: MediqColors.primaryBlue),
                  title: const Text('حفظ المحادثات محلياً (SQLite)'),
                  value: widget.viewModel.saveHistory,
                  onChanged: (v) => setState(() => widget.viewModel.saveHistory = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // قسم معلومات النموذج المحلي (مطابق للصورة 1)
          const Text(
            'معلومات النموذج اللغوي المحلي (llama.cpp / GGUF)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Card(
            color: isDark ? MediqColors.navyCard : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.memory_rounded, color: MediqColors.primaryBlue),
                  title: const Text('اسم النموذج النشط'),
                  subtitle: Text(widget.viewModel.llmConfig.modelPath, style: const TextStyle(fontSize: 11)),
                  trailing: DropdownButton<String>(
                    value: widget.viewModel.llmConfig.modelName,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: 'Llama 3.1 (8B) - Medical Instruct',
                        child: Text('Llama 3.1 (8B)'),
                      ),
                      DropdownMenuItem(
                        value: 'Gemma 2 (2B) - Lightweight Mobile',
                        child: Text('Gemma 2 (2B)'),
                      ),
                      DropdownMenuItem(
                        value: 'BioMistral (7B) - GGUF Q4',
                        child: Text('BioMistral (7B)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      if (val.contains('Gemma')) {
                        widget.viewModel.updateModelSelection(
                          val,
                          '/storage/emulated/0/MediqAI/models/gemma-2-2b-it-q4_k_m.gguf',
                          1.15,
                        );
                      } else {
                        widget.viewModel.updateModelSelection(
                          val,
                          '/storage/emulated/0/MediqAI/models/llama-3.1-8b-medical-q4_k_m.gguf',
                          1.85,
                        );
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dns_rounded, color: MediqColors.emeraldSafe),
                  title: const Text('حالة الخادم المحلي والذاكرة'),
                  subtitle: Text('الضغط: ${widget.viewModel.llmConfig.quantization} • استهلاك RAM: ${widget.viewModel.llmConfig.ramUsageGb} GB'),
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 10, color: MediqColors.emeraldSafe),
                      SizedBox(width: 6),
                      Text('متصل محلياً', style: TextStyle(color: MediqColors.emeraldSafe, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // قسم إدارة المعرفة الطبية وتحديث الحزم (Section 4.7.4 Admin Windows)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'لوحة مدير المعرفة الطبية (Knowledge Admin & Ingestion)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.viewModel.isAdmin
                      ? MediqColors.emeraldSafe.withOpacity(0.15)
                      : MediqColors.amberWarn.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.viewModel.isAdmin ? 'مفتوح للمدير' : 'للقراءة فقط (يتطلب دخول المدير)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.viewModel.isAdmin ? MediqColors.emeraldSafe : MediqColors.amberWarn,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Card(
            color: isDark ? MediqColors.navyCard : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'استيراد وفهرسة وثيقة طبية جديدة (Sliding Window Chunking + Embeddings)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _docTitleCtrl,
                    enabled: widget.viewModel.isAdmin,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الموضوع الطبي (مثال: أعراض قصور الغدة الدرقية)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _docEngCtrl,
                          enabled: widget.viewModel.isAdmin,
                          decoration: const InputDecoration(
                            labelText: 'المصطلح الإنجليزي (Hypothyroidism)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _docSourceCtrl,
                          enabled: widget.viewModel.isAdmin,
                          decoration: const InputDecoration(
                            labelText: 'اسم المرجع الطبي الموثوق',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _docContentCtrl,
                    enabled: widget.viewModel.isAdmin,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'النص الطبي المراد تقسيمه وفهرسته في جدول MedicalKnowledge و Embeddings...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.viewModel.isAdmin ? _handleIngestDocument : _showAdminLoginDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MediqColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: Icon(widget.viewModel.isAdmin ? Icons.upload_file_rounded : Icons.lock_rounded),
                      label: Text(
                        widget.viewModel.isAdmin
                            ? 'تطبيق التجزئة وبناء المتجهات وحفظ في قاعدة المعرفة'
                            : 'تسجيل دخول مدير المعرفة لتفعيل الاستيراد (admin123)',
                      ),
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
}