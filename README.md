# CONTROL OBRA PRO BY TST SOLUTIONS

**CONTROL OBRA PRO** es una aplicación móvil de gestión profesional de obras y construcciones desarrollada por **TST Solutions** ("Te Solucionamos Todo").

---

## 📱 ¿Qué es CONTROL OBRA PRO?

**CONTROL OBRA PRO** es una aplicación móvil de gestión profesional diseñada específicamente para constructoras, contratistas, arquitectos y profesionales del sector de la construcción que necesitan un control exhaustivo de sus obras, clientes y pagos.

> *"Technology that works. Solutions that scale."*

---

## 🎯 Público Objetivo

- Constructoras y empresas de construcción
- Contratistas independientes
- Arquitectos y ingenieros
- Profesionales del sector de obras civiles
- Cualquier negocio que gestione proyectos de construcción

---

## ✨ Características Principales

### 👥 Gestión de Clientes
- Agregar clientes con nombre, teléfono, dirección y fotos
- Buscar clientes por nombre o teléfono
- Ver historial completo de obras por cliente
- Notas personalizadas por cliente

### 🏗️ Control de Obras
- Registrar obras con concepto, monto, interés y fecha de vencimiento
- Estados: Pendiente, Parcial, Pagada, Vencida
- Actualización automática de estados
- Cálculo automático de totales con intereses

### 💳 Seguimiento de Pagos
- Registrar pagos parciales o completos
- Métodos de pago: Efectivo, Transferencia, MercadoPago, PayPal, Otro
- Cálculo automático de saldo restante
- Historial de pagos por obra

### 📊 Dashboard
- Total pendiente por cobrar
- Total vencido
- Total cobrado este mes
- Clientes con obra vencida

### 📄 Generación de PDF
- Reportes por cliente
- Lista de obras y pagos
- Resumen de totales
- Exportación profesional

### 🌐 Información de Contacto
- Web: https://tst-solutions.netlify.app/
- Facebook: https://www.facebook.com/tstsolutionsecuador/
- Twitter/X: https://x.com/SolutionsT95698
- WhatsApp: +593 99 796 2747
- Telegram: @TST_Ecuador
- Email: negocios@tstsolutions.com.ec

### ⚙️ Funcionalidades Adicionales
- Modo oscuro/claro automático
- Validaciones robustas
- Manejo centralizado de errores
- Base de datos SQLite local (100% offline)
- Respaldo y restauración de datos

---

## 🏗️ Estructura Técnica del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── data/
│   ├── datasources/            # Servicio de base de datos (SQLite)
│   ├── models/                # Modelos de datos
│   └── repositories/          # Repositorios de datos
└── presentation/
    ├── providers/              # Providers Riverpod (Estado)
    ├── router/                # Configuración de rutas (GoRouter)
    ├── screens/               # Pantallas de la app
    │   ├── about/             # Acerca de y contactos
    │   ├── clients/           # Gestión de clientes
    │   ├── dashboard/         # Pantalla principal
    │   ├── debts/             # Gestión de obras/pagos
    │   └── settings/          # Configuración
    ├── widgets/               # Widgets reutilizables
    └── theme/                 # Tema Material 3
```

---

## 🛠️ Tecnologías Utilizadas

| Tecnología | Descripción |
|------------|-------------|
| **Flutter 3.x** | Framework cross-platform |
| **Dart 3.x** | Lenguaje de programación |
| **SQLite (sqflite)** | Base de datos local offline |
| **Riverpod** | Gestión de estado |
| **GoRouter** | Navegación declarativa |
| **pdf + printing** | Generación de PDFs |
| **url_launcher** | Apertura de enlaces externos |
| **image_picker** | Selección de imágenes |
| **share_plus** | Compartir archivos |
| **Material Design 3** | Diseño UI/UX |

---

## 📋 Requisitos del Sistema

- **Android:** 5.0 (API 21) o superior
- **iOS:** 12.0 o superior
- **Espacio:** ~50 MB

---

## 🚀 Instrucciones de Instalación

### Prerrequisitos
- Flutter SDK 3.x instalado
- Dart SDK 3.x instalado
- Android Studio o VS Code

### Clonar el repositorio
```bash
git clone https://github.com/ieharo1/CONTROL-OBRA-PRO-BY-TST-SOLUTIONS.git
cd CONTROL-OBRA-PRO-BY-TST-SOLUTIONS
```

### Instalar dependencias
```bash
flutter pub get
```

### Ejecutar en modo debug
```bash
flutter run
```

### Generar APK en modo debug
```bash
flutter build apk --debug
```

### Generar APK en modo release
```bash
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🏆 Características Técnicas

✅ Diseño 100% Material Design 3  
✅ Interfaz moderna y limpia  
✅ Navegación con Bottom Navigation Bar  
✅ Modo oscuro/claro automático  
✅ Base de datos offline (SQLite)  
✅ Generación de reportes PDF  
✅ 100% funcional sin internet  
✅ Código limpio y escalable  

---

## 📄 Licencia

© 2026 CONTROL OBRA PRO BY TST SOLUTIONS - Todos los derechos reservados.

---

## 👨‍💻 Desarrollado por TST SOLUTIONS

*Technology that works. Solutions that scale.*

**TST Solutions** - Te Solucionamos Todo

Quito - Ecuador
