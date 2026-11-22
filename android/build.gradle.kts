// FastLocation: namespace para plugins antigos.
// Plugins sem `namespace` recebem o pacote do próprio AndroidManifest.xml.
subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android") ?: return@withId
        val getNs = androidExt.javaClass.getMethod("getNamespace")
        if (getNs.invoke(androidExt) == null) {
            val manifest = file("src/main/AndroidManifest.xml")
            val pkg = if (manifest.exists())
                Regex("package=\"([^\"]+)\"").find(manifest.readText())?.groupValues?.get(1)
            else null
            androidExt.javaClass.getMethod("setNamespace", String::class.java)
                .invoke(androidExt, pkg ?: project.group.toString())
        }
        // compileSdk antigo (ex.: 29 ou 33) quebra com dependências atuais; sobe para 35.
        val comps = extensions.findByName("androidComponents") ?: return@withId
        comps.javaClass.getMethod("finalizeDsl", Action::class.java).invoke(comps, Action<Any> {
            val ext = this
            val current = ext.javaClass.getMethod("getCompileSdk").invoke(ext) as Int?
            if (current == null || current < 35) {
                ext.javaClass.getMethod("setCompileSdk", Int::class.javaObjectType).invoke(ext, 35)
            }
        })
    }
}

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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
