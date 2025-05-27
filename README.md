# Login App - Flutter

Una aplicación simple de login y registro desarrollada en Flutter.

## Características

- ✅ Pantalla de login con validación
- ✅ Pantalla de registro con validación
- ✅ Pantalla de inicio (home) personalizada
- ✅ Servicio de autenticación simulado
- ✅ Validadores reutilizables
- ✅ Navegación entre pantallas
- ✅ Interfaz moderna y responsive

## Usuarios de Prueba

Para probar la aplicación, puedes usar estos usuarios preconfigurados:

### Usuario 1:
- **Email:** demo@example.com
- **Contraseña:** 123456

### Usuario 2:
- **Email:** admin@example.com  
- **Contraseña:** admin123

## Instalación y Ejecución

1. Asegúrate de tener Flutter instalado
2. Clona o descarga este proyecto
3. Navega al directorio del proyecto:
   ```bash
   cd login_app
   ```
4. Instala las dependencias:
   ```bash
   flutter pub get
   ```
5. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── screens/                  # Pantallas de la aplicación
│   ├── login_screen.dart     # Pantalla de login
│   ├── register_screen.dart  # Pantalla de registro
│   └── home_screen.dart      # Pantalla de inicio
├── services/                 # Servicios de la aplicación
│   └── auth_service.dart     # Servicio de autenticación
└── utils/                    # Utilidades
    └── validators.dart       # Validadores de formularios
```

## Funcionalidades

### Pantalla de Login
- Validación de email y contraseña
- Botón para ir al registro
- Indicador de carga durante autenticación
- Manejo de errores

### Pantalla de Registro
- Validación de nombre, email y contraseña
- Confirmación de contraseña
- Verificación de email duplicado
- Navegación automática al login después del registro

### Pantalla de Inicio
- Saludo personalizado con nombre del usuario
- Información del usuario logueado
- Menú con opciones (en desarrollo)
- Opción de cerrar sesión

## Tecnologías Utilizadas

- **Flutter:** Framework de desarrollo
- **Dart:** Lenguaje de programación
- **Material Design:** Sistema de diseño de Google

## Próximas Características

- [ ] Persistencia de sesión
- [ ] Integración con API real
- [ ] Recuperación de contraseña
- [ ] Perfil de usuario editable
- [ ] Temas claro/oscuro
- [ ] Autenticación biométrica

## Contribución

Si quieres contribuir a este proyecto:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Realiza los commits
4. Envía un pull request

## Licencia

Este proyecto es de código abierto y está disponible bajo la [Licencia MIT](LICENSE).
