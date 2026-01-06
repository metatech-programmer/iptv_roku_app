# Contribuyendo a Ultimate IPTV 2026 🤝

¡Gracias por tu interés en contribuir a Ultimate IPTV 2026! Este documento proporciona pautas para contribuir al proyecto.

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [¿Cómo Puedo Contribuir?](#cómo-puedo-contribuir)
- [Guía de Estilo](#guía-de-estilo)
- [Proceso de Pull Request](#proceso-de-pull-request)
- [Reportar Bugs](#reportar-bugs)
- [Sugerir Mejoras](#sugerir-mejoras)

## 📜 Código de Conducta

Este proyecto y todos los participantes están regidos por un código de conducta. Al participar, se espera que mantengas este código. Por favor reporta comportamiento inaceptable.

### Nuestro Compromiso

- Ser respetuoso con diferentes puntos de vista y experiencias
- Aceptar críticas constructivas con gracia
- Enfocarse en lo que es mejor para la comunidad
- Mostrar empatía hacia otros miembros de la comunidad

## 🤔 ¿Cómo Puedo Contribuir?

### Reportar Bugs

Los bugs se rastrean como issues de GitHub. Antes de crear un nuevo issue:

1. **Verifica** que el bug no haya sido reportado previamente
2. **Usa una etiqueta descriptiva** para el issue
3. **Describe el problema** con el mayor detalle posible
4. **Incluye pasos para reproducir** el bug
5. **Proporciona información del entorno**:
   - Modelo de Roku
   - Versión de la app
   - Versión del OS de Roku

#### Plantilla para Reportar Bugs

```markdown
**Descripción del Bug**
Una descripción clara y concisa del bug.

**Pasos para Reproducir**
1. Ve a '...'
2. Haz clic en '...'
3. Desplázate hasta '...'
4. Observa el error

**Comportamiento Esperado**
Descripción de lo que esperabas que sucediera.

**Capturas de Pantalla**
Si es aplicable, agrega capturas de pantalla.

**Entorno:**
 - Modelo Roku: [ej. Roku Ultra 4800X]
 - Versión de la App: [ej. 1.2.1]
 - Versión OS: [ej. 11.5]

**Contexto Adicional**
Cualquier otra información relevante.
```

### Sugerir Mejoras

Las mejoras también se rastrean como issues de GitHub. Al crear una sugerencia:

1. **Usa un título claro y descriptivo**
2. **Proporciona una descripción detallada** de la mejora
3. **Explica por qué sería útil** para la mayoría de usuarios
4. **Lista ejemplos** de cómo funcionaría la mejora

#### Plantilla para Sugerencias

```markdown
**¿Tu solicitud está relacionada con un problema?**
Descripción clara del problema.

**Describe la solución que te gustaría**
Descripción clara de lo que quieres que suceda.

**Describe alternativas que hayas considerado**
Descripción de soluciones o features alternativas.

**Contexto Adicional**
Cualquier otra información o capturas de pantalla.
```

### Tu Primera Contribución de Código

¿No estás seguro por dónde empezar? Busca issues etiquetados como:

- `good first issue` - Issues adecuados para principiantes
- `help wanted` - Issues donde necesitamos ayuda

### Pull Requests

1. Fork el repositorio
2. Crea una rama desde `main`:
   ```bash
   git checkout -b feature/nombre-feature
   ```
3. Realiza tus cambios siguiendo la [Guía de Estilo](#guía-de-estilo)
4. Commit tus cambios con mensajes descriptivos
5. Push a tu fork
6. Crea un Pull Request

## 🎨 Guía de Estilo

### Estilo de Código BrightScript

#### Nomenclatura

```brightscript
' Variables: camelCase
m.channelList = []
m.isLoading = false

' Constantes: UPPER_SNAKE_CASE
MAX_CHANNELS = 1000
DEFAULT_TIMEOUT = 5000

' Funciones: camelCase
function loadChannels()
    ' código
end function

' Componentes: PascalCase
' ChannelCard.xml, MainScene.xml
```

#### Comentarios

```brightscript
' Comentarios de una línea con espacio después del apóstrofe

' *************************************************************
' Bloques de comentarios para secciones importantes
' *************************************************************

' TODO: Descripción de tarea pendiente
' FIXME: Descripción de algo que necesita arreglarse
' NOTE: Nota importante sobre el código
```

#### Indentación y Formato

- **Indentación**: 4 espacios (no tabs)
- **Líneas en blanco**: Una línea entre funciones
- **Longitud de línea**: Máximo 100 caracteres
- **Espacios**: Alrededor de operadores y después de comas

```brightscript
' Bueno ✓
if condition then
    doSomething()
else
    doOtherThing()
end if

' Malo ✗
if condition then doSomething() else doOtherThing() end if
```

#### Manejo de Errores

```brightscript
' Siempre valida objetos antes de usarlos
if m.someObject <> invalid then
    result = m.someObject.someMethod()
else
    print "[ERROR] someObject is invalid"
    return invalid
end if

' Usa bloques try-catch cuando sea apropiado
function safeOperation()
    try
        ' operación que puede fallar
        return result
    catch error
        print "[ERROR] Operation failed: "; error.message
        return invalid
    end try
end function
```

### Estilo de Código XML (SceneGraph)

```xml
<!-- Indentación de 2 espacios -->
<component name="MyComponent" extends="Group">
  <interface>
    <field id="someField" type="string" />
  </interface>
  
  <children>
    <Rectangle id="background" width="1920" height="1080" color="0x000000" />
  </children>
  
  <script type="text/brightscript">
    <![CDATA[
      sub init()
        ' código
      end sub
    ]]>
  </script>
</component>
```

### Commits

Usa mensajes de commit descriptivos siguiendo este formato:

```
tipo(alcance): descripción corta

Descripción más detallada si es necesario.

- Punto adicional 1
- Punto adicional 2
```

**Tipos de commit**:
- `feat`: Nueva característica
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formato, espacios, etc. (sin cambio de código)
- `refactor`: Refactorización de código
- `test`: Agregar o corregir tests
- `chore`: Mantenimiento, build, etc.

**Ejemplos**:
```
feat(player): agregar control de volumen

fix(sidebar): corregir animación de apertura

docs(readme): actualizar instrucciones de instalación

refactor(cache): mejorar sistema de almacenamiento
```

## 🔄 Proceso de Pull Request

1. **Actualiza tu fork** con los últimos cambios del repo principal
2. **Asegúrate** de que tu código sigue la guía de estilo
3. **Prueba** tus cambios en un dispositivo Roku real
4. **Actualiza la documentación** si es necesario
5. **Describe tus cambios** en el PR:
   - ¿Qué cambia?
   - ¿Por qué es necesario?
   - ¿Cómo se prueba?
6. **Vincula issues relacionados** usando `#numero-issue`
7. **Espera la revisión** del código

### Checklist del Pull Request

- [ ] El código sigue la guía de estilo del proyecto
- [ ] He realizado una auto-revisión de mi código
- [ ] He comentado el código en áreas difíciles de entender
- [ ] He actualizado la documentación relevante
- [ ] Mis cambios no generan nuevos warnings
- [ ] He probado en un dispositivo Roku real
- [ ] Los cambios funcionan con diferentes resoluciones (HD, FHD)

## 🧪 Testing

### Testing Manual

Antes de enviar un PR, prueba tu código:

1. **Deploy en Roku** usando el developer mode
2. **Prueba todas las funciones afectadas**
3. **Verifica en diferentes modelos** si es posible:
   - Roku Express (modelo básico)
   - Roku Streaming Stick (modelo medio)
   - Roku Ultra (modelo avanzado)
4. **Prueba casos extremos**:
   - Listas M3U muy grandes
   - URLs inválidas
   - Streams que no cargan
   - Sin conexión a internet

### Áreas Críticas para Probar

- ✅ Carga y parsing de listas M3U
- ✅ Reproducción de video
- ✅ Navegación entre vistas
- ✅ Búsqueda de canales
- ✅ Sistema de favoritos
- ✅ Configuración y persistencia

## 📚 Recursos

### Documentación de Roku

- [Roku Developer Documentation](https://developer.roku.com/docs/)
- [BrightScript Reference](https://developer.roku.com/docs/references/brightscript/language/brightscript-language-reference.md)
- [SceneGraph Guide](https://developer.roku.com/docs/developer-program/core-concepts/scenegraph.md)

### Herramientas Útiles

- [BrightScript Language Extension (VS Code)](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript)
- [Roku Remote Tool](https://developer.roku.com/docs/developer-program/dev-tools/external-control-api.md)
- [Telnet Debugging](https://developer.roku.com/docs/developer-program/debugging/debugging-channels.md)

## ❓ ¿Preguntas?

Si tienes preguntas sobre cómo contribuir:

- 💬 Abre un issue con la etiqueta `question`
- 📧 Contacta al maintainer principal
- 🔍 Revisa issues y PRs anteriores

## 🎉 Reconocimientos

Todos los contribuidores serán reconocidos en el README del proyecto. ¡Gracias por hacer de Ultimate IPTV 2026 un mejor proyecto!

---

**¡Feliz codificación! 🚀**
