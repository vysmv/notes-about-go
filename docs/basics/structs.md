# Структуры и методы

## Что такое структура (struct) в Go

Структура (struct) — это составной (композитный) тип данных в Go, позволяющий объединить несколько полей (разных типов) под одним именем.
Иначе говоря, структура — это способ логически сгруппировать данные, чтобы они описывали один объект, сущность или концепцию.

Пример
```go
type User struct {
    ID    int
    Name  string
    Email string
}
```

Здесь определена структура User, у которой есть три поля:

- ID — целое число,
- Name — строка,
- Email — строка.

Она описывает логическую сущность “пользователь”.


### Зачем нужны структуры в Go

- Чтобы описать сущности [домена](../glossary/glossary.md#домен) (например: User, Order, Product, Message)
- Чтобы объединить данные, передаваемые вместе (например, конфигурации, результаты)
- Чтобы определять методы, связанные с конкретным типом данных
- Чтобы организовать архитектуру приложения — например, описать:
    - запрос к API,
    - модель данных в базе,
    - структуру ответа,
    - состояние какого-либо объекта.

**Концептуально: struct = «объект без классов»**

В Go нет классов, но структуры + методы = замена классов в ООП:

- структура содержит данные (поля),
- а методы на структуре — поведение.

```go
type Point struct {
    X int
    Y int
}

func (p Point) MoveRight() Point {
    p.X += 1
    return p
}
```

## Синтаксис определения и инициализации структур

### Объявление именованной структуры

В языке Go структуры определяются через ключевое слово type в сочетании с struct. 

Пример:
```go
type Person struct {
    Name string
    Age  int
}
```

Здесь создаётся именованный тип Person, представляющий структуру с двумя полями:

- Name — строкового типа (string)
- Age — целочисленного (int)

Такая форма объявления используется для описания повторно используемых типов в коде.

### Анонимная структура

Go также позволяет создавать анонимные структуры, то есть структуры без объявления отдельного типа:
```go
user := struct {
    ID   int
    Name string
}{
    ID:   1,
    Name: "Alice",
}
```
Анонимные структуры применяются для локального или одноразового использования, например, во вспомогательных функциях, при тестировании или в качестве временных контейнеров.

### Инициализация структуры

Существует несколько подходов к созданию экземпляра структуры.

1. Именованная инициализация

```go
p := Person{
    Name: "Ivan",
    Age:  30,
}
```
Это наиболее читаемая и рекомендуемая форма: имена полей явно указаны, порядок не имеет значения.

2. Позиционная инициализация
```go
p := Person{"Ivan", 30}
```
> Работает, но не рекомендуется — легко ошибиться при добавлении новых полей или смене порядка.

3. Инициализация через new

```go
p := new(Person)
p.Name = "Ivan"
p.Age = 30
```
Функция new возвращает указатель на нулевую структуру (*Person). Используется, если необходимо сохранить объект в куче или передать по указателю.

**Zero value**
При создании структуры через var или new, все поля получают нулевые значения:
```go
var p Person
fmt.Println(p.Name) // ""
fmt.Println(p.Age)  // 0
```
Go гарантирует инициализацию всех полей по умолчанию.

### Примечание о вложенных структурах

Go допускает вложенные структуры, что используется при описании иерархий данных:

```go
type Address struct {
    City  string
    Street string
}

type Employee struct {
    Name    string
    Address Address
}
```
Инициализация вложенной структуры может быть выполнена как целиком, так и поэтапно:
```go
e := Employee{
    Name: "Olga",
    Address: Address{
        City:   "Moscow",
        Street: "Tverskaya",
    },
}
```

## Доступ к полям структуры и работа с ними

После объявления и инициализации структуры необходимо уметь обращаться к её полям, читать и изменять их. Это базовая, но очень важная часть работы со структурами в Go.

### Доступ к полям через точку `.`

Самый прямой способ:
```go
type Person struct {
    Name string
    Age  int
}

p := Person{Name: "Anna", Age: 28}

fmt.Println(p.Name) // Anna
fmt.Println(p.Age)  // 28

p.Age = 29          // изменение значения поля
fmt.Println(p.Age)  // 29
```

### Работа с указателями на структуру
Если структура создана через new() или вручную как указатель (&Struct{}), то Go позволяет автоматически разыменовывать указатель при доступе к полям:
```go
p := &Person{Name: "Ivan", Age: 30}
fmt.Println(p.Name) // Go разыменует автоматически

p.Age = 31          // тоже работает
```
Без автоматического разыменования:
```go
(*p).Age = 32
```
Разыменовывать явно можно, но это не идеоматично. 

### Инициализация отдельных полей

Можно задать поля структуры позже, по одному:
```go
var p Person
p.Name = "Nina"
p.Age = 27
```
Это часто используется, когда структура инициализируется нулевым значением (var) или при чтении данных из внешнего источника (например, JSON).

**Пример с вложенными структурами**
```go
type Address struct {
    City string
}

type Employee struct {
    Name    string
    Address Address
}

e := Employee{Name: "Oleg"}
e.Address.City = "Saint Petersburg"

fmt.Println(e.Address.City) // Saint Petersburg
```

Если Address — это указатель, то сначала нужно выделить память:

```go
type Employee struct {
    Name    string
    Address *Address
}

e := Employee{Name: "Oleg"}
e.Address = &Address{}
e.Address.City = "Kazan"
```

## Передача структур в функции: по значению и по указателю

### Как работают параметры функций в Go

Go всегда передаёт аргументы по значению — то есть копирует их.
Если передаётся структура без указателя, то функция работает с копией.

### Пример: передача по значению
```go
type User struct {
    Name string
    Age  int
}

func Rename(u User) {
    u.Name = "Anonymous"
}

func main() {
    user := User{Name: "Ivan", Age: 33}
    Rename(user)
    fmt.Println(user.Name) // Ivan (не изменилось)
}
```
Функция Rename получает копию структуры. Изменения не влияют на оригинал.

### Пример: передача по указателю
```go
func RenamePtr(u *User) {
    u.Name = "Anonymous"
}

func main() {
    user := User{Name: "Ivan", Age: 33}
    RenamePtr(&user)
    fmt.Println(user.Name) // Anonymous (изменилось)
}
```
Теперь передаётся указатель (*User) — и функция может менять оригинальные данные.

### Методы: указатель или значение

Методы на структуре можно определять как:

- func (u User) — работает с копией (read-only)
- func (u *User) — работает с оригиналом (read-write)

Пример:
```go
func (u User) SayHello() {
    fmt.Println("Hello,", u.Name)
}

func (u *User) IncrementAge() {
    u.Age++
}
```
Вызывать можно и на значении, и на указателе — Go сам определит:

```go
user := User{Name: "Anna", Age: 22}

user.SayHello()       // OK
user.IncrementAge()   // OK — Go сам возьмёт &user

fmt.Println(user.Age) // 23
```

## Методы структур в Go

Что такое метод?

В Go можно «привязать» функцию к типу, чтобы она стала методом. Это позволяет:

- описывать поведение, связанное с определённой структурой;
- реализовывать интерфейсы
- писать объектно-подобный код без классов.

### Синтаксис метода

```go
func (r ReceiverType) MethodName(args...) returnType {
    // тело метода
}
```

- `r` — имя приёмника (receiver), любое имя переменной.
- `ReceiverType` — либо T, либо *T (указатель).
- `MethodName` — любое допустимое имя.
- `args` — параметры метода.
- `returnType` — возвращаемое значение (если есть).

### Пример: метод на значении
```go
type Point struct {
    X int
    Y int
}

// Метод, который не изменяет Point
func (p Point) DistanceFromOrigin() float64 {
    return math.Sqrt(float64(p.X*p.X + p.Y*p.Y))
}
```
> Здесь p Point — копия структуры.
> Метод может читать, но не менять поля оригинала.

### Пример: метод на указателе
```go
func (p *Point) Move(dx, dy int) {
    p.X += dx
    p.Y += dy
}
```
> Здесь p *Point — указатель на структуру.
> Метод изменяет оригинальный объект.

## Композиция структур (встраивание)

Go не поддерживает наследование, как в классических ООП-языках.
Вместо этого используется композиция — включение одной структуры в другую.

Это называется встраиванием (embedding) и позволяет:

- повторно использовать поля и методы другой структуры;
- делегировать поведение без иерархии наследования.

### Пример встраивания (embedding)

```go
type Address struct {
    City  string
    Street string
}

type Person struct {
    Name string
    Address  // встраивание
}
```
Теперь Person унаследует поля Address:

```go
p := Person{
    Name: "Ivan",
    Address: Address{
        City:   "Moscow",
        Street: "Lenina",
    },
}

// доступ к полям вложенной структуры напрямую:
fmt.Println(p.City)   // OK — "Moscow"
fmt.Println(p.Street) // OK — "Lenina"

// или явное указание вложенной структуры
fmt.Println(p.Address.City)
fmt.Println(p.Address.Street)
```

> Такое поведение называется promotion: вложенные поля становятся доступными на уровне внешней структуры.

### Встраивание с указателями

Можно встраивать указатель на структуру:

```go
type Person struct {
    Name string
    *Address
}
```
И при инициализации:

```go
p := Person{
    Name:    "Anna",
    Address: &Address{City: "Kazan", Street: "Tverskaya"},
}
fmt.Println(p.City) // OK — Go разыменует автоматически
```

> Важно!
> При в встраивании, если встраиваемая структур реализует интерфейс, то и структура "хозяин" тоже реализует этот интерфей

### Методы и встраивание

Если вложенный тип имеет методы, они тоже продвигаются наружу:

```go
type Logger struct{}

func (l Logger) Log(msg string) {
    fmt.Println("LOG:", msg)
}

type Service struct {
    Logger // встраивание
}

s := Service{}
s.Log("Hello") // OK — вызывается Logger.Log
```

### Если имя поля задаётся явно — это не встраивание:

```go
package main

import (
	"fmt"
)

type Address struct {
	City   string
	Street string
}

func (a *Address) GetFullAddress() string{
	return a.City + " " + a.Street
}

type Person struct {
	Name string
	Addr Address // обычное поле
}



func main() {
	p := Person{
		Name: "Ivan",
		Addr: Address{
			City: "Suhodolsk",
			Street: "Borodina",
		},
	}

	fmt.Println(p.Addr.City)
	fmt.Println(p.Addr.Street)

	fmt.Println(p.Addr.GetFullAddress())
}
```

### Конфликты имён

Если две встроенные структуры имеют одно и то же поле или метод:

```go
type A struct{ Name string }
type B struct{ Name string }

type C struct {
    A
    B
}
```
То c.Name — ошибка компиляции, нужно уточнить:
```go
c.A.Name = "one"
c.B.Name = "two"
```

## Сравнение структур: когда можно и что нужно учитывать

> Можно ли сравнивать структуры в Go?
> 
> Да, структуры можно сравнивать оператором == или !=, если все их поля сравнимы.

###  Когда сравнение возможно

Пример простой структуры:

```go
type Point struct {
    X int
    Y int
}

p1 := Point{1, 2}
p2 := Point{1, 2}
fmt.Println(p1 == p2) // true
```
Сравнение работает, потому что:

- оба значения одного типа,
- оба значения полностью сравнимы (int — сравнимый тип).

### Когда сравнение невозможно

Если структура содержит несравнимое поле, например slice, map или function, сравнение приведёт к ошибке компиляции:

```go
type Bad struct {
    ID    int
    Tags  []string // slice несравним
}

// Ошибка: invalid operation: b1 == b2 (struct containing []string cannot be compared)
```

То же касается:

- map
- slice
- function
- channel

### Обходное решение: ручное сравнение

Если нужно сравнить такие структуры — сравниваются по полям:

```go
b1 := Bad{ID: 1, Tags: []string{"a"}}
b2 := Bad{ID: 1, Tags: []string{"a"}}

// вручную:
equal := b1.ID == b2.ID && reflect.DeepEqual(b1.Tags, b2.Tags)
```

> Используется reflect.DeepEqual, если сравнение должно быть "по содержимому", а не по ссылке.

### Сравнение указателей на структуры

```go
type User struct {
    Name string
}

u1 := &User{Name: "Ivan"}
u2 := &User{Name: "Ivan"}
fmt.Println(u1 == u2) // false — разные указатели
fmt.Println(*u1 == *u2) // true — сравнение значений
```

## JSON и структуры в Go

Работа с JSON — одна из самых частых задач в веб-разработке и API.
Go предоставляет мощные инструменты для сериализации (Marshal) и десериализации (Unmarshal) структур в JSON и обратно.

### Базовая сериализация: json.Marshal

```go
package main

import (
	"encoding/json"
	"fmt"
	"log"
)

type User struct {
	Name string
	Age  int
}

func main() {
	u := User{Name: "Ivan", Age: 30}
	data, err := json.Marshal(u)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(string(data))
}
```
> Функция json.Marshal преобразует структуру в JSON-строку (в виде []byte).

### Базовая десериализация: json.Unmarshal

```go
package main

import (
	"encoding/json"
	"fmt"
	"log"
)

type User struct {
	Name string
	Age  int
}

func main() {
	data := `{"Name":"Ivan","Age":30}`
	var u User
	
	if err := json.Unmarshal([]byte(data), &u); err != nil {
		log.Fatal(err)
	}

	fmt.Println(u2.Name)
}
```

### struct tags — управление полями в JSON

Тэги позволяют указать, как поля структуры должны отображаться в JSON.

```go
package main

import (
	"encoding/json"
	"fmt"
	"log"
)

type User struct {
	Name string `json:"user_name"`
	Age  int    `json:"user_age, omitempty"`
}

func main() {
	u := User{Name: "Ivan",}
	data, err := json.Marshal(u)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(string(data))
}
```

***Значения тэгов:***

### Значения тэгов

| Тэг                   | Что делает                                                 |
|-----------------------|------------------------------------------------------------|
| `json:"name"`         | поле в JSON будет называться `name`                        |
| `json:"-"`            | исключает поле из JSON                                     |
| `json:"age,omitempty"`| исключает поле, если оно пустое (`0`, `""`, `nil`)         |


> Важно про тэги
>
> - Тэги работают только для экспортируемых (с заглавной буквы) полей.
> - Поля с маленькой буквы (некэкспортируемые) игнорируются при json.Marshal/Unmarshal.

### Вложенные структуры

**Сериализация**

```go
package main

import (
	"encoding/json"
	"fmt"
	"log"
)

type Address struct {
    City string `json:"city"`
}

type User struct {
    Name    string  `json:"name"`
    Address Address `json:"address"`
}

func main() {
	u := User{
		Name: "Ivan",
		Address: Address{
			City: "Krasnodon",
		}, 
	}
	data, err := json.Marshal(u)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(string(data)) // {"name":"Ivan","address":{"city":"Krasnodon"}}
}
```
**Ансериализация**

```go
jsonStr := `{"name":"Ivan","address":{"city":"Kazan"}}`
var u User
json.Unmarshal([]byte(jsonStr), &u)
fmt.Println(u.Address.City) // Kazan
```
> Всё работает корректно — вложенные структуры обрабатываются рекурсивно.

### Работа с массивами и срезами

```go
type Group struct {
    Users []User `json:"users"`
}

// результирующий json после сериализации
{
  "users": [
    {"name": "Anna", "age": 24},
    {"name": "Ivan", "age": 30}
  ]
}
```