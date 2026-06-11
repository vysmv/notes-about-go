# Helicopter view

## [Установка Go](https://go.dev/doc/install)

1. Скачиваем https://go.dev/dl/
2. Удаляем старую версию 
```bash
 sudo rm -rf /usr/local/go
```
3. Устанавливаем в /usr/local:
```bash
sudo tar -C /usr/local -xzf go1.26.3.linux-amd64.tar.gz
go version
```

## Инструментарий Go-разработчика

Используя Go, мы имеем в распоряжении не "технологию и её окружение", то есть не список технологий типа:

- PHP-интерпретатор
- Composer
- Code Sniffer
- PHPUnit и т.д.

а один инструмент `go`, который объединяет в себе:

- Компилятор (`go build`)
- Компиляцию и запуск этого кода (`go run`)
- Менеджер зависимостей (`go mod`)
- Стилистический форматер (`go fmt`)
- Тестовый раннер (`go test`)
- Линтер (`go vet`)
- Документатор (`go doc`)

Это стандартизированный рабочий набор, который просто работает из коробки.

---

## Способы запуска

В Go есть два основных способа «запустить» программу:

### `go run`

Используется для быстрого запуска.

Под капотом:

```bash
go run main.go

# реально делает что-то типа:
go build -o /tmp/go-run12345678 main.go
/tmp/go-run12345678
rm /tmp/go-run12345678
```

---

### `go build`

Компилирует в итоговый бинарник.

При помощи флага `-o` можно указать желаемое имя результирующего бинарника:

```bash
go build -o yourprogram main.go
./yourprogram
```

---

### `go install`

Компилирует и помещает бинарник в директорию, указанную в `$GOBIN` или `$GOPATH/bin`.
Если они определены в `.bashrc` (Linux):

```bash
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```
Если не установлены то используются дефолтный путь.
Его можно посмотреть 
```bash
go env GOPATH
```

```bash
# компилируем
go install ./path/to/main/go
```

---

### Межплатформенность

По умолчанию бинарник Go — платформозависимый:

- Если компилировать на Linux → будет ELF (Linux-бинарник)
- Если на Windows → будет `.exe`
- Если на macOS → Mach-O (бинарь под macOS)

Если нужно скомпилировать под разные системы, то используются специальные флаги:

```bash
# 1. Linux x64
GOOS=linux GOARCH=amd64 go build -o app_linux

# 2. Windows x64
GOOS=windows GOARCH=amd64 go build -o app_windows.exe

# 3. macOS ARM64 (например, для M1/M2)
GOOS=darwin GOARCH=arm64 go build -o app_mac_arm
```
---



