@echo off
setlocal

REM ===== Create Directories =====
for %%d in (
lib
lib\core
lib\core\theme
lib\core\network
lib\core\network\interceptors
lib\core\utils
lib\core\errors
lib\models
lib\services
lib\features
lib\features\auth
lib\features\auth\providers
lib\features\auth\screens
lib\features\dashboard
lib\features\dashboard\screens
lib\features\compose
lib\features\compose\providers
lib\features\compose\screens
lib\features\history
lib\features\history\providers
lib\features\history\screens
lib\features\templates
lib\features\templates\providers
lib\features\templates\screens
lib\features\profile
lib\features\profile\providers
lib\features\profile\screens
lib\widgets
) do (
    if not exist "%%d" mkdir "%%d"
)

REM ===== Create Files (only if not exists) =====
for %%f in (
lib\main.dart
lib\app.dart

lib\core\theme\app_theme.dart
lib\core\theme\app_colors.dart
lib\core\theme\app_typography.dart
lib\core\theme\app_spacing.dart

lib\core\network\api_client.dart
lib\core\network\api_endpoints.dart
lib\core\network\interceptors\auth_interceptor.dart
lib\core\network\interceptors\error_interceptor.dart

lib\core\utils\validators.dart
lib\core\utils\extensions.dart
lib\core\utils\helpers.dart

lib\core\errors\app_exception.dart

lib\models\user_model.dart
lib\models\email_model.dart
lib\models\template_model.dart

lib\services\auth_service.dart
lib\services\email_service.dart
lib\services\storage_service.dart

lib\features\auth\providers\auth_provider.dart
lib\features\auth\screens\login_screen.dart
lib\features\auth\screens\register_screen.dart
lib\features\auth\screens\forgot_password_screen.dart

lib\features\dashboard\screens\dashboard_screen.dart

lib\features\compose\providers\compose_provider.dart
lib\features\compose\screens\compose_screen.dart

lib\features\history\providers\history_provider.dart
lib\features\history\screens\history_screen.dart
lib\features\history\screens\email_detail_screen.dart

lib\features\templates\providers\templates_provider.dart
lib\features\templates\screens\templates_screen.dart

lib\features\profile\providers\profile_provider.dart
lib\features\profile\screens\profile_screen.dart

lib\widgets\app_button.dart
lib\widgets\app_text_field.dart
lib\widgets\glass_card.dart
lib\widgets\email_card.dart
lib\widgets\app_header.dart
lib\widgets\loading_skeleton.dart
lib\widgets\status_badge.dart
lib\widgets\bottom_nav.dart
) do (
    if not exist "%%f" type nul > "%%f"
)

echo.
echo Structure created successfully.
echo Existing files were not overwritten.
pause