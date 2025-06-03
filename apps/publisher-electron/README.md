# ColletteHealth Electron App

Estructura del proyecto y guías de uso:
- ssets/: Íconos y recursos estáticos.
- uild/: Archivos empaquetados y ejecutables.
- config/: Configuraciones globales (MSAL, endpoints, logging).
- services/: Lógica de servicios independientes (auth, websocket, livekit, recorder, storage).
- main/: Proceso principal de Electron e IPC.
- preload/: Script preload para exponer APIs seguras al Renderer.
- enderer/: UI y código de renderizado.
- 	ests/: Pruebas unitarias y e2e.
- Archivos raíz: .env, .gitignore, electron-builder.json, 	sconfig.json, webpack.*.config.js, README.

## Ejecución del script
1. Abre PowerShell como administrador.
2. Ve a la carpeta raíz del proyecto:
   `powershell
   cd C:\\ruta\\a\\electron-app
   `
3. Ejecuta el script:
   `powershell
   .\\init-folders.ps1
   `
4. Verifica que se hayan creado las carpetas y archivos según la estructura anterior.
5. A partir de ahí, abre tu editor y comienza a añadir código a cada archivo generado.
