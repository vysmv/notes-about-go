#!/bin/bash

set -e

echo "Создаю структуру каталогов и файлов..."

# Папки и файлы с заголовками
declare -A structure=(
  ["intro/philosophy.md"]="Философия Go"
  ["basics/syntax.md"]="Синтаксис"
  ["basics/variables.md"]="Переменные и типы"
  ["basics/functions.md"]="Функции и методы"
  ["basics/control.md"]="Управляющие конструкции"
  ["types/primitives.md"]="Примитивные типы"
  ["types/pointers.md"]="Указатели"
  ["types/structs.md"]="Структуры"
  ["types/interfaces.md"]="Интерфейсы"
  ["types/slices.md"]="Слайсы"
  ["types/maps.md"]="Map и Set"
  ["concurrency/goroutines.md"]="Горутины"
  ["concurrency/channels.md"]="Каналы"
  ["concurrency/select.md"]="Select"
  ["concurrency/sync.md"]="Синхронизация"
  ["concurrency/context.md"]="Context"
  ["errors/basic.md"]="Обработка ошибок"
  ["errors/sentinel.md"]="Sentinel-ошибки"
  ["errors/wrapping.md"]="Обёртка ошибок"
  ["errors/panic.md"]="Panic и Recover"
  ["time/timers.md"]="Таймеры и время"
  ["io/files.md"]="Работа с файлами"
  ["http/server.md"]="HTTP и веб-серверы"
  ["modules/gomod.md"]="Go Modules"
  ["tools/gotools.md"]="Инструменты Go"
  ["testing/testing.md"]="Тестирование"
  ["testing/benchmarks.md"]="Бенчмарки"
  ["testing/profiling.md"]="Профилирование"
  ["architecture/clean.md"]="Чистая архитектура"
  ["architecture/services.md"]="Сервисный подход"
  ["architecture/plugins.md"]="Плагины и интерфейсы"
  ["stdlib/overview.md"]="Обзор стандартной библиотеки"
  ["infra/build.md"]="Инфраструктура, сборка"
  ["advanced/gc.md"]="Сборщик мусора"
  ["advanced/unsafe.md"]="Unsafe"
  ["advanced/reflect.md"]="Reflect"
  ["advanced/generate.md"]="Генерация кода"
  ["advanced/sysprog.md"]="Системное программирование"
  ["practice/recipes.md"]="Практика и рецепты"
  ["index.md"]="Введение"
)

mkdir -p docs

for file in "${!structure[@]}"; do
  path="docs/$file"
  mkdir -p "$(dirname "$path")"
  echo "# ${structure[$file]}" > "$path"
done

echo "Создаю mkdocs.yml..."

cat <<EOF > mkdocs.yml
site_name: Go Documentation Map
theme:
  name: material
  palette:
    - scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-7
        name: Переключить на тёмную тему
    - scheme: slate
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-4
        name: Переключить на светлую тему
  features:
    - palette.toggle

nav:
  - Введение: index.md
  - Вводная часть:
      - Философия Go: intro/philosophy.md
  - Основы языка:
      - Синтаксис: basics/syntax.md
      - Переменные и типы: basics/variables.md
      - Функции и методы: basics/functions.md
      - Управляющие конструкции: basics/control.md
  - Типы и структуры:
      - Примитивы: types/primitives.md
      - Указатели: types/pointers.md
      - Структуры: types/structs.md
      - Интерфейсы: types/interfaces.md
      - Слайсы: types/slices.md
      - Map и Set: types/maps.md
  - Параллелизм:
      - Горутины: concurrency/goroutines.md
      - Каналы: concurrency/channels.md
      - Select: concurrency/select.md
      - Синхронизация: concurrency/sync.md
      - Context: concurrency/context.md
  - Ошибки:
      - Базовая обработка: errors/basic.md
      - Sentinel-ошибки: errors/sentinel.md
      - Обёртка ошибок: errors/wrapping.md
      - Panic и Recover: errors/panic.md
  - Работа со временем: time/timers.md
  - Ввод/вывод: io/files.md
  - HTTP и веб: http/server.md
  - Модули: modules/gomod.md
  - Инструменты: tools/gotools.md
  - Тестирование:
      - Тестирование: testing/testing.md
      - Бенчмарки: testing/benchmarks.md
      - Профилирование: testing/profiling.md
  - Архитектура:
      - Чистая архитектура: architecture/clean.md
      - Сервисы: architecture/services.md
      - Плагины и интерфейсы: architecture/plugins.md
  - Стандартная библиотека: stdlib/overview.md
  - Инфраструктура и сборка: infra/build.md
  - Продвинутое:
      - GC: advanced/gc.md
      - Unsafe: advanced/unsafe.md
      - Reflect: advanced/reflect.md
      - Генерация кода: advanced/generate.md
      - Системное программирование: advanced/sysprog.md
  - Практика: practice/recipes.md
EOF

echo "✅ Всё готово! Запусти 'mkdocs serve' или Docker — и поехали!"

