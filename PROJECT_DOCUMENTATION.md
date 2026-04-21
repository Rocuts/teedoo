# TeeDoo — Documentacion Tecnica del Proyecto

> Portal SaaS de facturacion electronica con compliance IA para el mercado espanol y europeo.

---

## Tabla de Contenidos

1. [Vision General](#1-vision-general)
2. [Stack Tecnologico](#2-stack-tecnologico)
3. [Arquitectura del Proyecto](#3-arquitectura-del-proyecto)
4. [Estructura de Directorios](#4-estructura-de-directorios)
5. [Sistema de Diseno](#5-sistema-de-diseno)
   - [Paleta de Colores](#51-paleta-de-colores)
   - [Tipografia](#52-tipografia)
   - [Sistema de Espaciado](#53-sistema-de-espaciado)
   - [Dimensiones y Sizing](#54-dimensiones-y-sizing)
   - [Border Radius](#55-border-radius)
   - [Glassmorphism](#56-glassmorphism)
   - [Motion y Animaciones](#57-motion-y-animaciones)
6. [Features](#6-features)
   - [Autenticacion](#61-autenticacion)
   - [Dashboard](#62-dashboard)
   - [Facturas](#63-facturas)
   - [Compliance IA](#64-compliance-ia)
   - [Auditoria](#65-auditoria)
   - [Configuracion](#66-configuracion)
7. [Componentes Compartidos](#7-componentes-compartidos)
8. [Gestion de Estado](#8-gestion-de-estado)
9. [Navegacion y Routing](#9-navegacion-y-routing)
10. [Networking y API](#10-networking-y-api)
11. [Integraciones de IA](#11-integraciones-de-ia)
12. [Internacionalizacion](#12-internacionalizacion)
13. [Responsive Design](#13-responsive-design)
14. [Modelos de Dominio](#14-modelos-de-dominio)
15. [Testing](#15-testing)
16. [CI/CD y Despliegue](#16-cicd-y-despliegue)
17. [Assets y Recursos](#17-assets-y-recursos)

---

## 1. Vision General

**TeeDoo** es una plataforma SaaS de facturacion electronica disenada para empresas espanolas y europeas que necesitan gestionar facturas con validacion automatica de cumplimiento normativo contra regulaciones como **TicketBAI**, **Verifactu** y **SII 2026**.

### Funcionalidades Principales

| Funcionalidad | Descripcion |
|---|---|
| **Facturacion electronica** | Creacion, gestion y envio de facturas con wizard multi-paso |
| **Compliance IA** | Validacion automatica contra normativas fiscales espanolas y europeas |
| **Audit trail** | Registro inmutable de todas las acciones sobre facturas |
| **Asistente de voz IA** | Interaccion por voz mediante OpenAI Realtime API |
| **Multi-idioma** | Soporte para espanol e ingles |
| **Temas claro/oscuro** | Sistema de diseno dual con glassmorphism |
| **Generacion de informes** | Exportacion a DOCX con graficos integrados |

---

## 2. Stack Tecnologico

### Framework y Lenguaje

| Tecnologia | Version | Proposito |
|---|---|---|
| Flutter | 3.41.2 | Framework UI multiplataforma |
| Dart | 3.11+ | Lenguaje (pattern matching, sealed classes) |

### Dependencias Principales

#### Estado y Navegacion
| Paquete | Version | Uso |
|---|---|---|
| `flutter_riverpod` | 2.6.1 | Gestion de estado reactiva |
| `riverpod_annotation` | 2.6.1 | Code generation para providers |
| `go_router` | 14.8.1 | Navegacion declarativa con guards |

#### Networking
| Paquete | Version | Uso |
|---|---|---|
| `dio` | 5.7.0 | Cliente HTTP con interceptores |
| `http` | 1.6.0 | Utilidades HTTP (OpenAI Realtime) |

#### Modelos y Serializacion
| Paquete | Version | Uso |
|---|---|---|
| `freezed_annotation` | 2.4.4 | Modelos inmutables |
| `json_annotation` | 4.9.0 | Serializacion JSON |

#### UI y Visualizacion
| Paquete | Version | Uso |
|---|---|---|
| `fl_chart` | 0.70.2 | Graficos (dashboard) |
| `lucide_icons` | 0.257.0 | Iconografia |
| `google_fonts` | 6.2.1 | Tipografia Inter |
| `flutter_animate` | 4.5.2 | Animaciones declarativas |
| `shimmer` | 3.0.0 | Skeleton loading |

#### Formularios y Validacion
| Paquete | Version | Uso |
|---|---|---|
| `reactive_forms` | 17.0.1 | Formularios reactivos |

#### Archivos y Media
| Paquete | Version | Uso |
|---|---|---|
| `file_picker` | 8.1.6 | Seleccion de archivos |
| `docx_template` | 0.4.0 | Generacion de informes DOCX |
| `record` | 5.0.5 | Grabacion de audio |
| `audioplayers` | 5.2.1 | Reproduccion de audio |
| `flutter_webrtc` | 1.3.1 | WebRTC para sesiones de voz |

#### Internacionalizacion
| Paquete | Version | Uso |
|---|---|---|
| `intl` | 0.20.2 | Formateo de fechas/numeros |
| `slang` | 3.31.2 | i18n con code generation |
| `slang_flutter` | 3.31.0 | Integracion Flutter para slang |

#### Utilidades
| Paquete | Version | Uso |
|---|---|---|
| `equatable` | 2.0.7 | Igualdad por valor |
| `uuid` | 4.5.1 | Generacion de UUIDs |
| `shared_preferences` | 2.3.2 | Almacenamiento local |

---

## 3. Arquitectura del Proyecto

### Patron: Clean Architecture + Feature-Based

Cada feature sigue una estructura de capas consistente:

```
feature/
├── data/
│   └── models/              # Modelos de datos (Invoice, User, etc.)
├── presentation/
│   ├── screens/             # Widgets de pantalla completa
│   └── widgets/             # Componentes reutilizables del feature
└── providers/               # Estado Riverpod del feature
```

### Patrones Clave

| Patron | Implementacion |
|---|---|
| **State Management** | Riverpod con NotifierProvider, StateProvider, AutoDisposeNotifier |
| **Routing** | GoRouter con guards de autenticacion y ShellRoute |
| **Networking** | Dio + `Result<T>` sealed class (manejo funcional de errores) |
| **Temas** | ThemeExtension con `lerp()` para transiciones suaves |
| **Responsividad** | Extensions en BuildContext (`isCompact`, `isMedium`, `isExpanded`) |

---

## 4. Estructura de Directorios

```
lib/
├── main.dart                          # Entry point con ProviderScope
├── app.dart                           # Widget raiz con tema/locale/router
├── core/
│   ├── constants/                     # Constantes globales
│   ├── l10n/                          # Internacionalizacion (es/en)
│   ├── mock/                          # Datos mock para modo demo
│   ├── network/
│   │   ├── dio_client.dart            # Cliente HTTP con interceptor auth
│   │   └── api_result.dart            # Result<T> sealed class
│   ├── responsive/                    # Breakpoints y helpers responsivos
│   ├── router/
│   │   └── app_router.dart            # Configuracion GoRouter
│   ├── services/
│   │   ├── ai_voice_service.dart      # OpenAI Realtime + WebRTC
│   │   └── report_template_service.dart # Generacion de informes DOCX
│   └── theme/
│       ├── app_theme.dart             # Constructor ThemeData
│       ├── app_colors_theme.dart      # Paleta de colores (dark/light)
│       ├── app_typography.dart        # Escala tipografica
│       ├── app_spacing.dart           # Sistema de espaciado
│       ├── app_dimensions.dart        # Dimensiones de componentes
│       ├── app_radius.dart            # Border radius tokens
│       ├── app_motion.dart            # Duraciones y curvas de animacion
│       └── glass_theme.dart           # Glassmorphism parameters
├── features/
│   ├── auth/                          # Autenticacion
│   ├── dashboard/                     # Panel principal
│   ├── invoices/                      # Gestion de facturas
│   ├── compliance/                    # Validacion de cumplimiento
│   ├── audit/                         # Registros de auditoria
│   └── settings/                      # Configuracion
└── shared/
    ├── layouts/
    │   ├── app_shell.dart             # Layout principal con sidebar
    │   └── auth_layout.dart           # Layout de autenticacion
    └── widgets/
        ├── ai/                        # Widget orbe IA flotante
        ├── buttons/                   # PrimaryButton, SecondaryButton, GhostButton
        ├── inputs/                    # TextInput, SearchInput, SelectInput
        ├── tables/                    # TeeDooDataTable, TablePagination
        ├── navigation/               # NavItem, AppSidebar, AppTopbar
        ├── glass_card.dart            # Tarjeta con glassmorphism
        ├── glass_modal.dart           # Modal con efecto glass
        ├── glass_toast.dart           # Notificaciones toast
        ├── status_badge.dart          # Badges de estado
        ├── file_dropzone.dart         # Zona de carga drag-and-drop
        ├── skeleton_loader.dart       # Placeholder de carga
        └── empty_state.dart           # Estado vacio
```

---

## 5. Sistema de Diseno

### 5.1 Paleta de Colores

#### Tema Oscuro (Principal)

**Fondos**
| Token | Hex | Uso |
|---|---|---|
| `bgPrimary` | `#0D1117` | Fondo principal (GitHub dark) |
| `bgSecondary` | `#161B22` | Superficie elevada |
| `bgSurface` | `#1C2128` | Fondo de tarjetas |
| `bgCard` | `#441C2128` | Relleno semi-transparente de tarjetas |
| `bgGlass` | `#331C2128` | Base glassmorphism |
| `bgGlassBorder` | `#338B5CF6` | Borde con tinte violeta |
| `bgGlassHover` | `#552D333B` | Estado hover glass |
| `bgInput` | `#660D1117` | Fondo de campos de entrada |
| `bgModal` | `#EE161B22` | Overlay de modales |
| `bgSidebar` | `#FF0D1117` | Fondo del sidebar |
| `bgTopbar` | `#99161B22` | Barra superior con transparencia |

**Texto**
| Token | Hex | Uso |
|---|---|---|
| `textPrimary` | `#F0F3F6` | Texto principal, alto contraste |
| `textSecondary` | `#9EA7B3` | Texto secundario |
| `textTertiary` | `#636E7B` | Texto terciario/hint |
| `textOnAccent` | `#FFFFFF` | Texto sobre colores de acento |

**Acentos**
| Token | Hex | Uso |
|---|---|---|
| `accentBlue` | `#8B5CF6` | Violet-500, CTA principal |
| `accentBlueHover` | `#A78BFA` | Violet-400, estado hover |
| `accentBlueSubtle` | `#1A8B5CF6` | 10% opacidad, fondos sutiles |
| `accentTeal` | `#7C3AED` | Violet-600, acento secundario |

**IA**
| Token | Hex | Uso |
|---|---|---|
| `aiPurple` | `#A78BFA` | Violet-400, badges IA |
| `aiPurpleBg` | `#1AA78BFA` | 10% opacidad, fondo IA |
| `aiPurpleBorder` | `#33A78BFA` | 20% opacidad, borde IA |

**Estados**
| Token | Hex | Uso |
|---|---|---|
| `statusSuccess` | `#3FB950` | Verde - exito |
| `statusWarning` | `#D29922` | Ambar - advertencia |
| `statusError` | `#F85149` | Rojo - error |
| `statusInfo` | `#58A6FF` | Azul - informacion |

**Bordes**
| Token | Hex | Uso |
|---|---|---|
| `borderPrimary` | `#3D444D` | Bordes principales |
| `borderSubtle` | `#448B5CF6` | Bordes sutiles con tinte violeta |
| `borderAccent` | `#448B5CF6` | Bordes de acento |

#### Tema Claro

| Token | Hex | Diferencia con Dark |
|---|---|---|
| `bgPrimary` | `#FAFAFA` | Gris claro en vez de negro |
| `bgSecondary` | `#F5F3FF` | Violet-50, toque purpura suave |
| `bgSurface` | `#FFFFFF` | Blanco puro |
| `bgSidebar` | `#FFF5F3FF` | Violet-50 |
| `textPrimary` | `#1E1B4B` | Indigo-950, muy profundo |
| `textSecondary` | `#6B7280` | Gray-500, WCAG AA |
| `accentBlue` | `#7C3AED` | Violet-600 (mayor contraste en claro) |
| `statusSuccess` | `#16A34A` | Green-600 (mas oscuro para contraste) |
| `statusError` | `#DC2626` | Red-600 |

### 5.2 Tipografia

**Familia:** Inter (via Google Fonts)

| Token | Tamano | Peso | Letter-spacing | Line-height | Uso |
|---|---|---|---|---|---|
| `h1` | 28px | 700 | -0.5px | 1.2 | KPIs, valores grandes |
| `h2` | 24px | 600 | -0.4px | 1.25 | Titulos de pagina |
| `h3` | 22px | 600 | -0.3px | 1.3 | Titulos de seccion |
| `h4` | 16px | 600 | -0.2px | 1.35 | Titulos de tarjeta |
| `body` | 14px | 400 | — | 1.5 | Texto general |
| `bodyMedium` | 14px | 500 | — | 1.5 | Texto medio |
| `bodySmall` | 13px | 400 | — | 1.45 | Subtitulos, inputs |
| `bodySmallMedium` | 13px | 500 | — | 1.45 | Labels de input |
| `caption` | 12px | 400 | 0.1px | 1.4 | Labels, links |
| `captionMedium` | 12px | 500 | 0.1px | 1.4 | Labels medios |
| `captionBold` | 12px | 600 | 0.1px | 1.4 | Badges, labels fuertes |
| `captionSmall` | 11px | 500 | 0.3px | 1.35 | Hints, headers de tabla |
| `captionSmallBold` | 11px | 600 | 0.4px | 1.35 | Headers uppercase |
| `logo` | 18px | 600 | — | — | Branding "TeeDoo" |
| `button` | 13px | 600 | — | — | Texto de boton |
| `buttonMedium` | 14px | 500 | — | — | Texto de boton mediano |

### 5.3 Sistema de Espaciado

**Base: Grid de 4px**

| Token | Valor | Uso |
|---|---|---|
| `xs` | 4px | Espaciado minimo |
| `sm` | 8px | Espaciado pequeno |
| `md` | 8px | Espaciado mediano |
| `lg` | 12px | Espaciado grande |
| `xl` | 16px | Espaciado extra grande |
| `xxl` | 20px | Espaciado doble extra |
| `s16`–`s48` | 16–48px | Valores de layout |

**Espaciado de Layout**
| Token | Valor | Uso |
|---|---|---|
| `contentPaddingVertical` | 32px | Padding vertical del contenido principal |
| `contentPaddingHorizontal` | 40px | Padding horizontal del contenido principal |
| `contentGap` | 28px | Gap entre elementos de contenido |
| `cardPadding` | 28px | Padding interno de tarjetas |
| `kpiGap` | 20px | Gap entre KPIs |
| `formGap` | 24px | Gap entre campos de formulario |
| `buttonGap` | 12px | Gap entre botones agrupados |

### 5.4 Dimensiones y Sizing

**Layout**
| Token | Valor |
|---|---|
| `sidebarExpandedWidth` | 260px |
| `sidebarCollapsedWidth` | 72px |
| `topbarHeight` | 56px |

**Iconos**
| Token | Valor |
|---|---|
| `iconSize` | 20px |
| `iconSizeSmall` | 16px |
| `iconSizeLarge` | 24px |

**Touch Targets**
| Token | Valor |
|---|---|
| `buttonHeight` | 44px |
| `touchTargetSize` | 40px |
| `avatarSize` | 32px |
| `logoSize` | 32px |

**IA/Voz**
| Token | Valor |
|---|---|
| `aiOrbIdle` | 64px |
| `aiOrbActive` | 80px |
| `aiCardWidth` | 320px |

### 5.5 Border Radius

| Token | Valor | Uso |
|---|---|---|
| `sm` | 6px | Tooltips, elementos pequenos |
| `md` | 8px | Botones, inputs |
| `lg` | 12px | Tarjetas |
| `xl` | 16px | Modales, containers grandes |
| `badge` | 5px | Status badges |
| `stepperCircle` | 14px | Circulos del stepper |

### 5.6 Glassmorphism

Implementado como `ThemeExtension<GlassTheme>` con soporte para `lerp()`.

| Propiedad | Dark | Light |
|---|---|---|
| `blurSigma` | 40.0 | 16.0 |
| `cardFill` | `#441C2128` | `#EEFFFFFF` |
| `glassFill` | `#331C2128` | `#99F5F3FF` |
| `glassBorder` | `#338B5CF6` | `#88E9D5FF` |
| `glassHover` | `#552D333B` | `#88F3E8FF` |
| `cardRadius` | 16.0px | 16.0px |

**Implementacion del GlassCard:**
```
ClipRRect → BackdropFilter → DecoratedBox
```

**Estados interactivos:**
- **Hover:** borde se ilumina (alpha +0.2), escala sutil 1.005
- **Press:** escala 0.98, borde accent blue con glow, blur reducido (min 10.0)
- **Idle:** blur estandar con borde transparente

### 5.7 Motion y Animaciones

**Duraciones**
| Token | Valor | Uso |
|---|---|---|
| `durationMicro` | 100ms | Press de boton, toggle |
| `durationFast` | 150ms | Hover, reveals pequenos |
| `durationNormal` | 300ms | Panel open, card expand |
| `durationSlow` | 500ms | Entrada de pagina, modal |
| `durationDramatic` | 800ms | Onboarding, primera carga |

**Curvas**
| Token | Valor | Uso |
|---|---|---|
| `curveStandard` | `easeOutCubic` | Mayoria de transiciones |
| `curveEmphasized` | `easeOutBack` | Elementos que demandan atencion |
| `curveDecelerate` | `decelerate` | Entradas |

**Escala (Feedback Tactil)**
| Token | Valor | Uso |
|---|---|---|
| `scalePressed` | 0.97 | Feedback de presion |
| `scaleHover` | 1.005 | Hover sutil |
| `scaleActive` | 1.02 | Highlight activo |

**Patron de animacion en botones:**
- Escala: 0.97 al presionar, 1.0 en idle (100ms press, 150ms release)
- Opacidad: 0.9 al presionar, 1.0 en idle
- Curva: `easeOutCubic`

---

## 6. Features

### 6.1 Autenticacion

**Ruta:** `/lib/features/auth/`

#### Pantallas

| Pantalla | Ruta | Descripcion |
|---|---|---|
| `LoginScreen` | `/login` | Email/password + passkeys (WebAuthn) |
| `MfaScreen` | `/mfa` | Codigo de 6 digitos con temporizador |
| `ForgotPasswordScreen` | `/forgot-password` | Recuperacion por email |
| `OnboardingScreen` | `/onboarding` | Wizard de 4 pasos para nuevas organizaciones |

#### Wizard de Onboarding
1. **Organizacion** — Nombre, NIF, direccion, pais, idioma
2. **Configuracion Fiscal** — Regimen (General/Simplificado/Recargo), moneda, serie, numeracion
3. **Integraciones** — ERP, email, API/Webhooks (opcional)
4. **Confirmacion** — Resumen de datos ingresados

#### Layout Responsivo del Login
- **Desktop:** Tarjeta de 880x520 con 2 columnas (branding izquierda, formulario derecha)
- **Tablet:** Solo formulario en tarjeta de 460px
- **Mobile:** Layout apilado a ancho completo

### 6.2 Dashboard

**Ruta:** `/lib/features/dashboard/`

#### KPI Cards
| KPI | Icono | Color |
|---|---|---|
| Facturas Emitidas | `file-text` | Azul |
| Ingresos del Mes | `dollar-sign` | Verde |
| Pendientes de Cobro | `clock` | Amarillo |
| Facturas Vencidas | `alert-triangle` | Rojo |

Cada KPI muestra: label, valor principal, indicador de tendencia (ej. "+12%") e icono con fondo codificado por color.

#### Paneles
- **MonthlyRevenueChart** — Grafico de lineas fl_chart con relleno de area, 12 meses, valores en k EUR
- **InvoiceStatusPanel** — Estados y conteos de facturas
- **ComplianceAlerts** — Alertas de cumplimiento
- **RecentActivity** — Actividad reciente

#### Animaciones
- Entrada fade-in + slide-Y escalonada
- Hover en KPI: escala 1.0 → 1.05 con sombra glow azul

### 6.3 Facturas

**Ruta:** `/lib/features/invoices/`

#### Pantallas

| Pantalla | Ruta | Descripcion |
|---|---|---|
| `InvoicesListScreen` | `/invoices` | Tabla con filtros y paginacion |
| `InvoiceCreateScreen` | `/invoices/new` | Wizard de creacion de 4 pasos |
| `InvoiceDocumentsScreen` | `/invoices/documents` | Gestion de documentos |
| Invoice Detail | `/invoices/:id` | Detalle con pestanas |

#### Wizard de Creacion
1. **Partes** — Emisor (pre-rellenado) y receptor (nombre, NIF, direccion)
2. **Lineas** — Items dinamicos: descripcion, cantidad, precio unitario, tipo impositivo
3. **Totales** — Subtotal/impuestos/total auto-calculados, metodo de pago, vencimiento
4. **Revision** — Resumen completo antes de enviar

#### Pestanas de Detalle
| Pestana | Contenido |
|---|---|
| Resumen | Datos de emisor/receptor, desglose, pago |
| Auditoria | Timeline de eventos de la factura |
| Compliance | Checks IA con badges pass/warning/fail |
| Datos Estructurados | Datos XML/JSON de la factura |
| Adjuntos | Documentos asociados |

#### Tabs de Lista
Todas | Borradores | Enviadas | Rechazadas | Pendientes (con contadores)

#### Dual-DB en lista y detalle (Fase 3 Paso 2, 2026-04-21)

Lista y detalle ya no usan `MockData`; consumen `/api/invoices` a traves del repositorio Flutter. El header del listado muestra un `DbTargetSelector` (Mongo ↔ Supabase) y un `ActiveBackendChip` con el backend servido.

- **Repositorio:** `lib/features/invoices/data/invoices_repository.dart` — envuelve `DioClient`, llama `GET /api/invoices` y `GET /api/invoices/:id`, y mapea la forma canonica wire (`InvoiceDoc`, centimos + enums SCREAMING_SNAKE) a la forma legada que ya consumen las pantallas. En el detalle hidrata NIF + direccion del emisor y receptor con dos `GET /api/parties/:id` en paralelo.
- **Providers (Riverpod):**
  - `invoicesListProvider` (autoDispose) — observa `dataSourceProvider`, refetchea al togglear.
  - `invoiceByIdProvider.family<Invoice, String>` — idem por id.
- **Estados UI:** loading con spinner, error con mensaje + boton "Reintentar" (`ref.invalidate`), empty state contextual al backend activo ("No hay facturas en MongoDB / Supabase").
- **Wizard de creacion y `LiquidityPanel`** siguen apoyados en `MockData` — migrar en la siguiente fase.

### 6.4 Compliance IA

**Ruta:** `/lib/features/compliance/`

#### Flujo de Trabajo
1. Subir documento (PDF/XML) o buscar factura existente
2. Seleccionar regulacion aplicable
3. Ejecutar analisis IA
4. Visualizar resultados con puntuacion y hallazgos

#### Regulaciones Soportadas
| Pais | Regulacion | Estado |
|---|---|---|
| Espana | Facturae / Verifactu (SII 2026) | Activo |
| Francia | Factur-X / Chorus Pro (v2.3) | Proximamente |
| Italia | FatturaPA / SDI (v1.2) | Proximamente |

#### Resultado del Analisis
- **ScoreHeader** — Puntuacion 0–100 con nivel (pass/warnings/fail)
- **FindingsList** — Hallazgos categorizados por prioridad:
  - **Alta:** NIF receptor invalido, referencia de pedido faltante
  - **Media:** Descripcion de linea generica
  - **Baja:** Codigo de pais no estandar, formato de fecha suboptimo
- **ContextChatPanel** — Chat contextual para consultas sobre los resultados

### 6.5 Auditoria

**Ruta:** `/lib/features/audit/`

#### Pestanas
| Pestana | Contenido |
|---|---|
| Log de Eventos | Timeline cronologica con eventos codificados por color |
| Integridad | Verificacion de hash de documentos |
| Exportaciones | Historial y descarga de logs exportados |

#### Tipos de Evento
| Tipo | Color | Ejemplo |
|---|---|---|
| `create` | Azul | Factura creada |
| `complianceCheck` | Purpura | Check de compliance ejecutado |
| `send` | Verde | Factura enviada a SII |
| `update` | Amarillo | Campos de pago modificados |
| `export` | Teal | Logs exportados |
| `login` | Info | Inicio de sesion |
| `delete` | Rojo | Factura eliminada |

### 6.6 Configuracion

**Ruta:** `/lib/features/settings/`

#### Pestanas
| Pestana | Contenido |
|---|---|
| Organizacion | Datos empresa, logo, certificado digital, numeracion |
| Usuarios | Gestion de usuarios y roles |
| Idioma | Seleccion de idioma y preferencias regionales |
| Integraciones | Conexiones con servicios externos (ERP, email, API) |
| Apariencia | Selector de tema (claro/oscuro) |
| Seguridad | MFA (TOTP/SMS), sesiones activas, API keys, contrasena |

#### Seguridad - Detalle
- **MFA:** TOTP habilitado, SMS deshabilitado
- **Sesiones:** Listado de sesiones activas (dispositivo, ubicacion, estado)
- **API Keys:** Claves enmascaradas (ej. `td_live_****...****7f2a`), produccion y desarrollo
- **Contrasena:** Indicador de ultimo cambio, boton de actualizacion

---

## 7. Componentes Compartidos

### Layouts
| Componente | Descripcion |
|---|---|
| `AppShell` | Layout principal con sidebar responsivo + topbar |
| `AuthLayout` | Layout para pantallas de autenticacion |

### Botones
| Componente | Estilo | Uso |
|---|---|---|
| `PrimaryButton` | Relleno accent violet, texto blanco | Acciones principales (CTA) |
| `SecondaryButton` | Glass fill + borde sutil | Acciones secundarias |
| `GhostButton` | Transparente, sin borde | Acciones terciarias |

Todos los botones implementan: estados hover/press con escala (0.97) y opacidad (0.9), estado disabled, icono opcional, estado de carga con spinner, y ancho expandible.

### Tarjetas
| Componente | Descripcion |
|---|---|
| `GlassCard` | Tarjeta con glassmorphism (header, content, actions) |
| `GlassModal` | Dialogo modal con efecto glass |
| `GlassToast` | Notificaciones toast (success/error/warning/info) |

### Inputs
| Componente | Descripcion |
|---|---|
| `TextInput` | Campo de texto con validacion |
| `SearchInput` | Campo de busqueda |
| `SelectInput` | Selector dropdown |

### Datos
| Componente | Descripcion |
|---|---|
| `TeeDooDataTable` | Tabla con paginacion |
| `TablePagination` | Controles de paginacion |
| `StatusBadge` | Indicador de estado (pass/warning/fail) |
| `AiBadge` | Badge para elementos IA |

### IA
| Componente | Descripcion |
|---|---|
| `AiOrbitWidget` | Burbuja flotante del asistente IA (bottom-right) |
| `OrbitVisualizer` | Visualizacion de forma de onda de audio |

### Utilidades
| Componente | Descripcion |
|---|---|
| `FileDropzone` | Zona drag-and-drop para carga de archivos |
| `SkeletonLoader` | Placeholder de carga |
| `EmptyState` | Estado vacio |
| `TeeDooStepper` | Stepper multi-paso para formularios |

---

## 8. Gestion de Estado

### Riverpod Providers

#### Globales (no auto-dispose)
| Provider | Tipo | Proposito |
|---|---|---|
| `authProvider` | `NotifierProvider` | Estado de autenticacion persistente |
| `themeModeProvider` | `StateProvider` | Tema actual (dark/light/system) |
| `localeProvider` | `StateProvider` | Locale actual (es/en) |
| `aiVoiceProvider` | `ChangeNotifierProvider` | Servicio de voz IA |

#### Por Feature (auto-dispose)
| Provider | Proposito |
|---|---|
| `settingsProvider` | Configuracion de la organizacion |

### Estado de Autenticacion

```dart
class AuthState {
  bool isAuthenticated;
  bool isLoading;
  bool isBootstrapping;
  UserModel? user;
  String? accessToken;
  String? refreshToken;
  String? error;
}
```

- Persistencia de tokens via `SharedPreferences`
- Bootstrap al iniciar la app (verificacion de tokens existentes)
- Soporte para login por email/password y passkeys

---

## 9. Navegacion y Routing

### GoRouter con Guards

#### Rutas Publicas (sin autenticacion)
| Ruta | Pantalla |
|---|---|
| `/login` | LoginScreen |
| `/mfa` | MfaScreen |
| `/forgot-password` | ForgotPasswordScreen |
| `/onboarding` | OnboardingScreen |

#### Rutas Protegidas (con AppShell)
| Ruta | Pantalla |
|---|---|
| `/dashboard` | DashboardScreen |
| `/invoices` | InvoicesListScreen |
| `/invoices/new` | InvoiceCreateScreen |
| `/invoices/documents` | InvoiceDocumentsScreen |
| `/invoices/:id` | Invoice Detail |
| `/compliance` | QuickCheckScreen |
| `/compliance/results/:id` | Compliance Results |
| `/audit` | AuditScreen |
| `/settings` | SettingsScreen |

### Layout Responsivo del Shell
| Viewport | Sidebar | Comportamiento |
|---|---|---|
| < 600px (Compact) | Drawer | Sin sidebar visible, hamburger menu |
| 600–1199px (Medium) | 72px colapsado | Solo iconos |
| >= 1200px (Expanded) | 260px completo | Iconos + labels |

---

## 10. Networking y API

### Cliente HTTP (Dio)

**Base URL:** `/api` por defecto (same-origin — el Flutter Web se sirve desde el mismo deploy de Vercel que expone las Functions). Overrideable con `--dart-define=TEEDOO_API_BASE_URL=…` (ej. `http://localhost:3001/api` cuando se corre contra `dev_server.js`).

**Autenticacion:** JWT Bearer tokens con interceptor automatico.

**Header `X-Data-Source`:** inyectado por `_DataSourceInterceptor` en cada request, leyendo `dataSourceProvider` (`mongo` | `postgres`). El backend enruta a Mongo Atlas o Supabase Postgres en runtime vía `api/_lib/db/factory.js`. Cuando el usuario togglea el selector, los `FutureProvider` que lo observan (lista / detalle) se auto-invalidan y refetchean.

**Patron Result<T>:**
```dart
sealed class Result<T> {
  Success(T data)
  Failure(AppException exception)
}
```

**Jerarquia de Excepciones:**
- `NetworkException` — Sin conectividad
- `ServerException` — Error del servidor (5xx)
- `AuthException` — No autorizado (401/403)
- `ValidationException` — Datos invalidos (422)

### Endpoints Principales
| Metodo | Endpoint | Descripcion |
|---|---|---|
| `POST` | `/auth/login` | Login |
| `GET` | `/invoices` | Listar facturas |
| `POST` | `/invoices` | Crear factura |
| `PUT` | `/invoices/:id` | Actualizar factura |
| `POST` | `/realtime/client-secrets` | Token efimero OpenAI |

---

## 11. Integraciones de IA

### OpenAI Realtime API (Asistente de Voz)

| Aspecto | Detalle |
|---|---|
| **Modelo** | `gpt-realtime` |
| **Voz** | "coral" |
| **Protocolo** | WebRTC + SDP offer/answer |
| **Canal de datos** | JSON events via DataChannel |

#### Funciones Disponibles (Function Calling)
| Funcion | Descripcion |
|---|---|
| `get_dashboard_kpis` | Obtener metricas del dashboard |
| `get_invoices_history` | Consultar historial de facturas |
| `highlight_ui_element` | Resaltar elementos en la interfaz |
| `generate_report` | Generar informe en Word |

### Servicios Externos
| Servicio | Uso |
|---|---|
| QuickChart.io | Generacion de graficos para informes Word |

---

## 12. Internacionalizacion

### Idiomas Soportados
| Idioma | Codigo | Estado |
|---|---|---|
| Espanol | `es` | Principal |
| Ingles | `en` | Secundario |

**Implementacion:** `slang` con code generation y `intl` para formateo de fechas/numeros/moneda.

**Cambio de idioma:** Via `localeProvider` (StateProvider de Riverpod), accesible desde Settings > Idioma.

---

## 13. Responsive Design

### Breakpoints

| Nombre | Rango | Uso |
|---|---|---|
| Compact | < 600px | Mobile |
| Medium | 600–1199px | Tablet |
| Expanded | >= 1200px | Desktop |

### Extensions en BuildContext
```dart
context.isCompact   // < 600px
context.isMedium    // 600-1199px
context.isExpanded  // >= 1200px
```

### Adaptaciones por Feature
- **Dashboard:** 1 columna (mobile) → 2x2 KPIs (tablet) → 4 en fila (desktop)
- **Login:** Full-width stacked → form-only card → 2-column branding + form
- **Invoices Detail:** Tabs apilados → 2 columnas
- **Compliance:** Panel unico → 2 columnas (selector + resultados)
- **Settings:** Tabs apilados → sidebar tabs + contenido

---

## 14. Modelos de Dominio

### Invoice
```
Invoice
├── id: String
├── number: String
├── status: InvoiceStatus (draft|pendingReview|readyToSend|sent|accepted|rejected|cancelled)
├── complianceStatus: ComplianceStatus (pass|warnings|fail|pending)
├── issuer: {name, nif, address}
├── receiver: {name, nif, address}
├── lines: List<InvoiceLine> {description, quantity, unitPrice, taxRate}
├── subtotal, taxAmount, total: double
├── currency: String
├── issueDate, dueDate: DateTime
├── paymentMethod, paymentIban: String
├── notes: String?
└── createdAt, updatedAt: DateTime
```

### Compliance
```
ComplianceResult
├── id: String
├── invoiceId: String
├── score: int (0-100)
├── level: ComplianceLevel (pass|warnings|fail)
├── findings: List<Finding>
│   ├── priority: FindingPriority (high|medium|low)
│   ├── title, description: String
│   └── fieldPath, xPath: String?
├── regulationId, regulationVersion: String
└── analyzedAt: DateTime

Regulation
├── id, country, name, version: String
├── isActive: bool
└── description: String?
```

### Audit
```
AuditEvent
├── id: String
├── type: AuditEventType (create|update|send|complianceCheck|export|login|delete)
├── title, description: String
├── userId, userName: String
├── timestamp: DateTime
├── relatedEntityId: String?
└── metadata: Map<String, dynamic>?
```

---

## 15. Testing

### Estructura
```
test/
├── core/                    # Tests de utilidades core
└── features/
    └── auth/
        └── providers/       # Tests de auth provider
```

### Herramientas
- `flutter_test` — Framework de testing unitario y de widgets
- Ejecucion: `flutter test`

---

## 16. CI/CD y Despliegue

### GitHub Actions

**Pipeline:** `.github/workflows/flutter-ci.yml`

| Paso | Comando |
|---|---|
| Checkout | `actions/checkout` |
| Setup Flutter | Canal estable |
| Dependencias | `flutter pub get` |
| Formato | `./tool/ci/check_format.sh` |
| Analisis estatico | `flutter analyze` |
| Tests | `flutter test` |

### Vercel (Despliegue Web)

**Configuracion:** `vercel.json`
| Aspecto | Valor |
|---|---|
| Build | `bash build.sh` |
| Output | `build/web` |
| CSP | Permite OpenAI API, QuickChart, Google Fonts |
| Microfono | `self` only |
| SPA Routing | Fallback a `index.html` |

**Build Script:** `build.sh`
- Descarga Flutter 3.41.2 si no esta en cache
- Inyecta variables de entorno via `--dart-define`
- Build: `flutter build web --release`

### Variables de Entorno
| Variable | Descripcion |
|---|---|
| `TEEDOO_API_BASE_URL` | URL base del API backend |
| `DEMO_AUTH_ENABLED` | Habilitar autenticacion demo |

---

## 17. Assets y Recursos

| Directorio | Contenido |
|---|---|
| `assets/images/` | Logo (PNG, JPEG) |
| `assets/templates/` | `informe_base.docx` (plantilla Word) |
| `assets/icons/` | Vacio (usa Lucide Icons) |

**Fuentes:** Inter via `google_fonts` (no requiere assets locales).

---

> Generado el 2026-03-19 — TeeDoo v1.0
