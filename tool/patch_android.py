"""Ajusta o projeto Android gerado pelo `flutter create` para os plugins antigos
exigidos no enunciado (ex.: map_launcher 2.x), que não declaram `namespace` —
obrigatório a partir do Android Gradle Plugin 8.

Uso (na raiz do projeto, depois do `flutter create`):  python tool/patch_android.py
É idempotente: rodar de novo não duplica nada.
"""
from pathlib import Path

MARKER = "FastLocation: namespace para plugins antigos"

KTS = f'''// {MARKER}.
// Plugins sem `namespace` recebem o pacote do próprio AndroidManifest.xml.
subprojects {{
    plugins.withId("com.android.library") {{
        val androidExt = extensions.findByName("android") ?: return@withId
        val getNs = androidExt.javaClass.getMethod("getNamespace")
        if (getNs.invoke(androidExt) == null) {{
            val manifest = file("src/main/AndroidManifest.xml")
            val pkg = if (manifest.exists())
                Regex("package=\\"([^\\"]+)\\"").find(manifest.readText())?.groupValues?.get(1)
            else null
            androidExt.javaClass.getMethod("setNamespace", String::class.java)
                .invoke(androidExt, pkg ?: project.group.toString())
        }}
    }}
}}

'''

GROOVY = f'''// {MARKER}.
// Plugins sem `namespace` recebem o pacote do próprio AndroidManifest.xml.
subprojects {{
    plugins.withId("com.android.library") {{
        if (android.namespace == null) {{
            def manifest = file("src/main/AndroidManifest.xml")
            def pkg = null
            if (manifest.exists()) {{
                def m = manifest.text =~ /package="([^"]+)"/
                if (m.find()) pkg = m.group(1)
            }}
            android.namespace = pkg ?: project.group.toString()
        }}
    }}
}}

'''

PROPS = "kotlin.jvm.target.validation.mode=warning"


def main() -> None:
    android = Path("android")
    kts = android / "build.gradle.kts"
    groovy = android / "build.gradle"

    if kts.exists():
        target, block = kts, KTS
    elif groovy.exists():
        target, block = groovy, GROOVY
    else:
        raise SystemExit("android/build.gradle(.kts) não encontrado. Rode o flutter create antes.")

    text = target.read_text(encoding="utf-8")
    if MARKER not in text:
        target.write_text(block + text, encoding="utf-8")
        print(f"namespace: ajuste aplicado em {target}")
    else:
        print(f"namespace: {target} já ajustado")

    props = android / "gradle.properties"
    ptext = props.read_text(encoding="utf-8") if props.exists() else ""
    if PROPS not in ptext:
        props.write_text(ptext.rstrip("\n") + "\n" + PROPS + "\n", encoding="utf-8")
        print("gradle.properties: validação de JVM target como aviso")


if __name__ == "__main__":
    main()
