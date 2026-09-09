import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// S-H3: imzolash sirlari faqat fayl/CI secret orqali keladi, repoda emas.
val keystorePropertiesFile: File = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

android {
    namespace = "com.devline.eld_logistics"
    // B-93: `flutter_secure_storage` AAR metadatasi compileSdk >= 37 talab qiladi
    // (Flutter SDK hozir 36 beradi). compileSdk faqat kompilyatsiya API sathini
    // oshiradi — targetSdk (runtime xatti-harakati) va minSdk ga TEGMAYDI.
    compileSdk = maxOf(37, flutter.compileSdkVersion)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.devline.eld_logistics"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // tz-mobile §18: minimal qo'llab-quvvatlanadigan versiya — Android 10 (API 29).
        // BLE skan + ACCESS_BACKGROUND_LOCATION siyosati shu versiyadan boshlanadi.
        minSdk = maxOf(29, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // S-H3: release AAB/APK **hech qachon** debug kalit bilan imzolanmaydi.
        // Kalit ma'lumotlari `android/key.properties` da (repoga tushmaydi, .gitignore da);
        // CI da esa KEYSTORE_* env/secret'lardan yoziladi. Namuna: key.properties.example.
        create("release") {
            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties.getProperty("storeFile")!!)
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Kalit bo'lmasa signingConfig = null (imzosiz chiqadi) va quyidagi
            // taskGraph tekshiruvi build'ni ANIQ xato bilan to'xtatadi.
            // Jimgina debug kalitga tushish TAQIQ — S-H3.
            signingConfig =
                if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else null
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

// S-H3: release artefakt yig'ilayotgan bo'lsa va kalit yo'q bo'lsa — build TO'XTAYDI.
// Konfiguratsiya bosqichida emas, task grafi tayyor bo'lganda tekshiriladi, shuning uchun
// `flutter build apk --debug` / `flutter test` ga ta'sir qilmaydi.
gradle.taskGraph.whenReady {
    val releaseArtifactRequested = allTasks.any { task ->
        task.name.endsWith("Release") &&
            (
                task.name.startsWith("assemble") ||
                    task.name.startsWith("bundle") ||
                    task.name.startsWith("package")
            )
    }
    if (releaseArtifactRequested && !keystorePropertiesFile.exists()) {
        throw GradleException(
            "Release signing key topilmadi: android/key.properties yo'q. " +
                "Namunadan nusxa oling (android/key.properties.example) yoki CI da " +
                "KEYSTORE_BASE64 / KEYSTORE_PASSWORD / KEY_ALIAS / KEY_PASSWORD " +
                "secret'laridan generatsiya qiling. Batafsil: mobile/RELEASE.md",
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
