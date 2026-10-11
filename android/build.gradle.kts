allprojects {
    // home_widget uses a dynamic Glance dependency; keep every module on
    // the compatible stable release, including its protobuf security fix.
    configurations.configureEach {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.glance" && requested.name in setOf(
                "glance", "glance-appwidget", "glance-appwidget-proto",
                "glance-appwidget-external-protobuf"
            )) {
                useVersion("1.1.1")
                because("Avoid preview SDK and AGP requirements from dynamic Glance versions")
            }
        }
    }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
