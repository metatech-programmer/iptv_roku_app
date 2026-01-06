# Iconos Faltantes para Sidebar y UI

La carpeta roku/images necesita los siguientes iconos adicionales:

## Iconos de Sidebar (40x40px):
- **home_icon.png** - Icono de casa/inicio para el menú
- **search_icon.png** - Icono de lupa para búsqueda
- **settings_icon.png** - Icono de engranaje para configuración

## Iconos para Channel Store (requeridos para publicación):
- **mm_icon_focus_hd.png** (336x210px) - Icono principal cuando tiene foco
- **mm_icon_side_hd.png** (108x69px) - Icono lateral pequeño

## Uso Temporal:
Los iconos existentes (playlist_icon.png, add_icon.png, etc.) se pueden usar 
temporalmente para los iconos de sidebar hasta que tengas los definitivos.

Para desarrollo, puedes:
1. Copiar playlist_icon.png y renombrarlo como home_icon.png
2. Copiar favorites_icon.png y renombrarlo como search_icon.png
3. Copiar add_icon.png y renombrarlo como settings_icon.png
4. Crear iconos básicos de 336x210 y 108x69 para los iconos del channel store

## Comando PowerShell para copiar temporalmente:
```powershell
cd roku/images
Copy-Item playlist_icon.png home_icon.png
Copy-Item favorites_icon.png search_icon.png
Copy-Item add_icon.png settings_icon.png
```
