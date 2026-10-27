#!/data/data/com.termux/files/usr/bin/bash
# ============================================================================
# سكريبت الرفع التلقائي لمشروع MEDIQ AI عبر تطبيق Termux إلى GitHub
# لبناء ملف APK تلقائياً عبر GitHub Actions بدون الحاجة لجهاز كمبيوتر!
# ============================================================================

set -e

echo "========================================================"
echo "   MEDIQ AI - Termux to GitHub Auto-Deployer v1.0       "
echo "========================================================"

# 1. تثبيت git في Termux إن لم يكن مثبتاً
if ! command -v git &> /dev/null; then
    echo "[1/5] جاري تثبيت أداة Git في Termux..."
    pkg update -y && pkg install git -y
fi

# 2. تجهيز هيكل مجلدات المشروع
echo "[2/5] جاري تنظيم هيكل ملفات Flutter و GitHub Actions..."
mkdir -p lib .github/workflows

if [ -f "main.dart" ]; then
    cp main.dart lib/main.dart
fi

if [ -f "build_apk.yml" ]; then
    cp build_apk.yml .github/workflows/build_apk.yml
fi

# 3. تهيئة مستودع Git
echo "[3/5] جاري تهيئة مستودع Git المحلي..."
git init
git branch -M main

# إعداد الهوية الافتراضية في حال عدم ضبطها مسبقاً
git config user.name "MEDIQ-AI-Developer" || true
git config user.email "developer@mediq-ai.local" || true

git add .
git commit -m "Deploy Complete MEDIQ AI Single-File System with Hybrid RAG & Safety Guardrails" || true

echo ""
echo "========================================================"
echo "✅ تم تجهيز المشروع بالكامل للرفع!"
echo "الآن قم بتنفيذ الأمرين التاليين لربطه بمستودعك على GitHub:"
echo ""
echo "  git remote add origin https://github.com/USERNAME/REPO_NAME.git"
echo "  git push -u origin main"
echo ""
echo "بمجرد الرفع، ادخل إلى تبويب (Actions) في مستودعك على GitHub"
echo "وستجد ملف (MEDIQ-AI-Release-APK) جاهزاً للتحميل والتثبيت على هاتفك!"
echo "========================================================"