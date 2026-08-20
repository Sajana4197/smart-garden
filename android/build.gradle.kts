allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// tflite_flutter (Phase 18) doesn't set explicit Java/Kotlin compatibility
// in its own module, which defaults inconsistently against this project's
// Java 17 setting (observed: "Inconsistent JVM-target compatibility...
// 'compileDebugJavaWithJavac' (11) and 'compileDebugKotlin' (21)"). Forces
// every subproject/plugin module to compile consistently at 17 — a known,
// common fix for this exact Flutter-plugin Gradle issue, not specific to
// one plugin, so it's applied project-wide rather than patched per-plugin.
subprojects {
    // ":app" already sets this itself and is forced to evaluate first
    // (see the evaluationDependsOn block above) — calling afterEvaluate on
    // an already-evaluated project throws, so it's excluded here.
    if (project.name != "app") {
        afterEvaluate {
            extensions.findByType<com.android.build.gradle.BaseExtension>()?.let { androidExt ->
                androidExt.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
