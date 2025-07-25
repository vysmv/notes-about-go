# Helicopter view

## Инструментарий Go разработчика

Используя go, мы имеем в распоряжении не "окружение", то есть не список технологий типа: php интерпретатор, composer, code sniffer, PHPUnit и т.д., а один инструмент `go`, который объединяет в себе:

- Компилятор (`go build`)
- Компиляцию и запуск этого кода (`go run`)
- Менеджер зависимостей (`go mod`)
- Стилистический форматер (`go fmt`)
- Тестовый раннер (`go test`)
- Линтер (`go vet`)
- Документатор (`go doc`)

То есть, мы получаем всё в одной бинарной утилите — никакой IDE, плагинов, JVM, pip, виртуальных окружений. Это прямо стандартизированный рабочий набор, который просто работает.

---

## Минимальный рабочий код Go

```go
// main.go
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
```

Вот и всё. С этим файлом уже можно делать:

```bash
go run main.go       # исполнение на лету
go build main.go     # получить бинарник
./main               # исполняемый файл, который не зависит ни от чего
```

---

## Как Go исполняет код

В Go есть два основных способа «запустить» программу:

### `go run`

Используется для быстрого запуска.  
Под капотом временно компилирует `.go` файл в бинарник → запускает → удаляет бинарник.

📦 Под капотом:

```bash
go run main.go

# реально делает что-то типа:
go build -o /tmp/go-run12345678 main.go
/tmp/go-run12345678
rm /tmp/go-run12345678
```

Удобно для прототипов, скриптов, тестов.  
Не подходит для продакшена.

---

### `go build`

Компилирует `.go` файл или весь модуль в нативный исполняемый бинарник.  
Этот бинарник можно запускать напрямую — даже если на машине не установлен Go, то есть без зависимостей.

При помощи флага `-o` можно указать желаемое имя результирующего бинарника:

```bash
go build -o yourprogram main.go
./yourprogram
```

Бинарник содержит:

- весь код программы
- стандартную библиотеку (скомпилированную)
- нужные зависимости
- встроенный Go runtime (об этом позже)

---

### `go install`

При запуске `go install` в директории с файлом `main.go`, скомпилированный файл попадёт в директорию, указанную в `$GOBIN` или `$GOPATH/bin`, и будет доступен в системе для запуска из любой директории как системная утилита, если `$GOPATH/bin` добавлен в переменную `PATH`.

Пример настройки в `.bashrc` (Linux):

```bash
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

В общем, `go install`:

- Компилирует и сохраняет бинарник в `$GOBIN` или `$GOPATH/bin`
- В качестве имени использует строку, указанную в `go.mod` в секции `module`

Удобно, если нужно переиспользовать бинарники как утилиты:

```bash
# компилируем
go install

# исполняем
program_name
```

---

### Межплатформенность

По умолчанию бинарник Go — платформозависимый:

- Если компилировать на Linux → будет ELF (Linux-бинарник)
- Если на Windows → будет `.exe`
- Если на macOS → Mach-O (бинарь под macOS)

Если нужно скомпилировать под разные системы, то используются специальные флаги для компилятора:

```bash
# 1. Linux x64
GOOS=linux GOARCH=amd64 go build -o app_linux

# 2. Windows x64
GOOS=windows GOARCH=amd64 go build -o app_windows.exe

# 3. macOS ARM64 (например, для M1/M2)
GOOS=darwin GOARCH=arm64 go build -o app_mac_arm
```


Почему так?

Go не использует виртуальную машину или переносимый байткод, как Java или .NET.  
Он компилирует в чистый машинный код под конкретную платформу — это и даёт высокую скорость исполнения, но требует отдельного бинаря на каждую платформу.


Единственное ограничение

Если код использует нативные библиотеки (через `cgo`) — кросс-компиляция усложняется, потому что Go подключает нативный C-компилятор (`gcc` и т.д.) под целевую ОС.  
Но для большинства случаев (CLI, API, веб) всё работает из коробки.

---

## Что делает `go` под капотом при сборке?

Когда мы пишем `go build`, происходит следующее:

- Анализ кода и зависимостей (из `go.mod`, если есть)
- Компиляция всех `.go` файлов → в промежуточное представление
- Оптимизация и трансформация в машинный код (с помощью `cmd/compile`)
- Линковка: всё соединяется с рантаймом Go

🛠 В результате получается один статически слинкованный бинарник.

---

## Важное отличие от интерпретируемых языков


| Категория     | Go                        | PHP / Python                   |
|---------------|---------------------------|---------------------------------|
| Подготовка    | Компиляция → бинарник     | Интерпретация текста            |
| Исполнение    | ОС запускает `.exe/.out`  | Интерпретатор читает текст      |
| Зависимости   | Вшиты в бинарь             | Требуют VM / окружение          |
| Запуск        | Мгновенный                 | Зависит от интерпретатора       |
| Библиотеки    | Компилируются              | Загружаются во время исполнения |

---

## Роль рантайма в Go

**Рантайм (runtime)** — это набор механизмов, работающих во время выполнения программы, а не во время компиляции.

Во время выполнения происходят такие вещи, как:

- работа с памятью (выделение/освобождение)
- вызовы функций
- обработка исключений (если есть)
- взаимодействие с ОС (через системные вызовы)
- планирование задач
- и многое другое

Во многих языках (особенно компилируемых, как C, Go, Rust) runtime — это небольшая библиотека или слой, который компилятор добавляет в программу, чтобы управлять этими процессами. Например, даже если мы компилируем `.go` или `.c` файл в бинарник, там будет присутствовать runtime (иногда минимальный, иногда довольно сложный).

---

### Особенности рантайма Go

В Go рантайм — это встроенная часть языка, реализованная в пакете `runtime`, написанном в основном на Go и частично на ассемблере и C.

💥 Главное отличие Go:

- Рантайм — это **не среда** (как например в java), а **библиотека**
- Она **компилируется вместе с кодом**
- Она **входит в каждый бинарник**

---

### Что входит в Go runtime?

Вот список того, что делает Go runtime (напомню, это библиотека, описанная в исходном коде самого Go в виде его стандартной библиотеки):

1. 📦 **Инициализация программы**

    - вызывает все `init()` в нужном порядке  
    - запускает `main.main()`

2. 🧵 **Планировщик goroutine**

    - управляет запуском и переключением goroutine  
    - распределяет их по ОС-потокам  
    - это как встроенный lightweight OS-level thread pool, но умнее  
    - в Go **не ОС управляет конкурентностью**, а сам язык через рантайм

3. 🧹 **Сборщик мусора (Garbage Collector)**

    - автоматически находит и очищает неиспользуемую память  
    - работает параллельно, инкрементально  
    - никогда не нужно делать `free()` — за тебя это делает runtime

4. 🛑 **Panic / Recover**

    - `panic()` вызывает ошибку  
    - `recover()` ловит её  
    - механизм аналогичен `try/catch`, но управляется рантаймом

5. ⛓ **Каналы и `select`**

    - механизм `chan` реализован внутри runtime  
    - он ставит goroutine в ожидание, снимает с ожидания, если другая пишет/читает

6. 🧮 **Таймеры: `time.After`, `time.Ticker`**

    - отложенные события (timeouts) тоже управляются внутри runtime

7. 🧪 **Профилирование и трассировка**

    - `runtime/pprof`, `runtime/trace` — позволяют профилировать память, CPU, goroutine


---

### Структура рантайма

[Внутри `runtime`](https://github.com/golang/go/tree/master/src/runtime) есть:

- `proc.go` — логика переключения горутин
- `mgc.go` — Garbage Collector
- `panic.go` — механика паник
- `runtime2.go`, `stubs.go` — glue-код между Go и ассемблером
- `asm_*.s` — низкоуровневая логика стека, переключений, атомарных операций

```
runtime/
├── asm_amd64.s     # Ассемблерная часть для amd64
├── proc.go         # Планировщик goroutine
├── mgc.go          # Garbage Collector
├── panic.go        # Обработка panic
├── chan.go         # Каналы
├── time.go         # Таймеры
├── netpoll.go      # Polling-система для net
└── ...
```

---

### Пример: goroutine в действии

Когда мы делаем:

```go
go doSomething()
```

Мы не создаём thread, как в C. Вместо этого:

- Go runtime кладёт `doSomething()` в очередь задач
- Планировщик runtime берёт из очереди и сам решает, на каком потоке ОС это исполнить
- Может переключить в любой момент на другой поток

Всё это — благодаря runtime, который мы не видим, но он работает под капотом.

---

### Почему мы никогда не "подключаем" runtime явно?

Потому что runtime:

- уже встроен в стандартную библиотеку
- подключается автоматически при компиляции

Можно явно написать `import "runtime"` — и получить доступ к его функциям  
(например, `runtime.NumGoroutine()` или `runtime.GC()`),  
но это уже мануальное вмешательство.

---

### Сравнение go рантайм с другими языками:

| Категория     | Java / Python         | Go                         |
|---------------|------------------------|-----------------------------|
| Рантайм       | Внешний (JVM, Python) | Встроенный в бинарник       |
| Запускается   | Через интерпретатор    | Как нативный код            |
| Роль          | Управляет всем         | Управляет только необходимым |
| Зависимости   | Требует окружение      | Самодостаточен              |

---
## Как Go взаимодействует с операционной системой

Go-компилятор создаёт **нативный бинарник**, который выполняется как обычная программа ОС — **без виртуальных машин**, без прослоек.

Запущенный на исполнение Go-бинарник — это такой же полноправный процесс, как любой другой, написанный на C, Rust или Assembler.

---

### Что это значит?

Когда мы запускаем Go-программу:

- ОС создаёт процесс
- Загружает бинарник в память
- Вызывает `main()` через точку входа `runtime.main`
- Go runtime стартует и вызывает `main.main()`

---

### Системные вызовы

Go **напрямую использует системные вызовы ОС** (syscalls), что означает:

- работа с файлами: `os.Open`, `os.Create`, `os.Remove`
- работа с сетью: `net.Listen`, `net.Dial`
- работа с окружением: `os.Getenv`, `os.Setenv`
- потоки ввода/вывода: `fmt.Println`, `os.Stdin`
- сигналы: `os/signal`
- управление процессами: `os/Exec`, `os.FindProcess`, `os.StartProcess`

💡 Всё это реализовано через тонкую прослойку над системными вызовами в пакете `syscall` и `internal/syscall/unix`.

---

### Пример: доступ к файловой системе

```go
package main

import (
    "fmt"
    "os"
)

func main() {
    file, err := os.Create("hello.txt")
    if err != nil {
        panic(err)
    }
    defer file.Close()

    file.WriteString("Hello, Go + OS!\n")
    fmt.Println("File written.")
}
```

**Под капотом:** Go вызывает `open` и `write` — это обычные POSIX-системные вызовы.

---

### Пример: работа с TCP

```go
ln, err := net.Listen("tcp", ":8080")
conn, err := ln.Accept()
go handleConn(conn)
```

Здесь Go использует вызовы `socket`, `bind`, `listen`, `accept` — прямые системные вызовы TCP/IP-стека ОС.

---

### Коммуникация с ОС

| Возможность ОС       | Go-интерфейс               |
|----------------------|----------------------------|
| Переменные среды     | `os.Getenv`, `os.Environ`  |
| Сигналы (SIGINT)     | `os/signal.Notify`         |
| Стандартный ввод/вывод | `os.Stdin`, `os.Stdout`, `os.Stderr` |
| Операции с файлами   | `os`, `io`, `syscall`      |
| Системные процессы   | `os/exec`, `os.FindProcess` |

---

### Go НЕ использует "эмуляцию" ОС

Go работает с ОС **нативно**, как C-программа:

- **Linux** — через `libc/syscall`
- **Windows** — через WinAPI
- **macOS** — через Darwin API

Go-компилятор знает целевую ОС (`GOOS`) и **генерирует вызовы под неё**.

---

### Goroutine ≠ потоки ОС

Go может запускать **тысячи goroutine**, не создавая тысячи потоков ОС.
Планировщик Go runtime сам распределяет goroutine по **небольшому пулу системных потоков**.
Это даёт Go **высокую масштабируемость** с минимальным overhead.

---

## Что входит в Go-бинарник

1. ✅ **Скомпилированный пользовательский код**  
    - Все `.go` файлы проекта  
    - Все зависимости (включая стандартную библиотеку и внешние модули)

2. 🔧 **Go runtime**  
    - Планировщик goroutine  
    - Сборщик мусора  
    - Обработка `panic/recover`  
    - Каналы, таймеры, `defer`

3. 🧾 **Символьная информация (частично)**  
    - Метки, стеки, точки входа  
    - Используется для профилирования, отладки  
    - Может быть удалена при `-ldflags="-s -w"`

4. 📦 **Метаданные модуля (в Go 1.18+)**  
    - Информация из `go.mod` встраивается в бинарник  
    - Извлекается с помощью: `go version -m <binary>`

5. 🛠 **Статическая линковка**  
    - Весь код (включая C-зависимости, если не используется `cgo`)  
    - **Не требует shared-библиотек** в системе

---

### Формат выходного файла

| ОС      | Формат                      |
|---------|-----------------------------|
| Linux   | ELF                         |
| Windows | PE (Portable Executable `.exe`) |
| macOS   | Mach-O                      |

Go генерирует **исполнимый файл нативного формата** — **без сторонних тулов или линкеров**.

---

### Размер бинарника

Go-бинарники обычно крупнее, чем у C-программ, особенно с отладочной информацией:

- Простая программа (`fmt.Println`) ≈ 1.5–2.5 МБ
- После `upx` или `strip` — можно уменьшить до ~1 МБ

```bash
go build -ldflags="-s -w" -o app
upx app
```

---

### Проверка содержимого бинарника

```bash
go build -o app
go version -m app
```

**Пример вывода:**

```
app: go1.21.1
    path    myapp
    mod     myapp  (devel)
    dep     golang.org/x/sys v0.9.0
```

---

### Самодостаточность

Такой бинарник:

- ❌ не требует установленного Go
- ❌ не зависит от `libgo`, `libc`, `libstdc++` (если не используется `cgo`)
- ✅ может быть запущен напрямую: `./app` или `app.exe`

---

### Go-бинарник — это:

- полностью **статически слинкованная программа**
- содержащая **код, runtime, зависимости**
- оформленная в **нативный формат ОС**
- **независимая** от интерпретаторов или виртуальных машин

## Сфера применения Go:

- CLI-инструментов
- DevOps-утилит
- Микросервисов
- Доставки исполнимых агентов

---


