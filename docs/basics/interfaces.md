# Интерфейсы

По своей сути это те же контракты  как и в классическом ООП. Отличия заключаются в применении (реализации).

Например:
```go
package main

import "fmt"

// Интерфейс
type Speaker interface {
   Speak()
}

// Тип (структура)
type Dog struct{}

// Метод для Dog
func (d Dog) Speak() {
   fmt.Println("Гав!")
}


func talk(s Speaker) {
   s.Speak()
}

func main() {
   d := Dog{}
   talk(d) // Работает! Потому что Dog реализует метод Speak()
}
```

> Важно!
>
> - В интерфейсе нельзя объявлять свойства, а только методы. Потому что интерфейсы в Go — это контракты на поведение, а не на структуру данных.

## Интерфейсы применительно к переменным

Переменная интерфейсного типа означает, что при объявлении этой переменной вместо конкретного типа указан интерфейс, а это значит, что в неё можно присвоить любой тип, удовлетворяющий этому интерфейсу.

Например
```go
package main

import "fmt"

// Интерфейс
type Speaker interface {
   Speak()
}

// Тип (структура)
type Dog struct {
   Name string
   Age int
}

// Метод для Dog
func (d Dog) Speak() {
   fmt.Println("Гав!")
}

func main() {
   var d Speaker = Dog{Name: "Тузик", Age: 5}

   //Вызов метода сработает без доп. действий.
   d.Speak()

   // А вот обращения к свойствам не сработают.
   // d.Name недоступно, потому что d — переменная интерфейсного типа Speaker,
   // а интерфейс Speaker не знает ничего про поля Name и Age.
   // d содержит экземпляр Dog, но Go "смотрит" на него только через интерфейс Speaker,
   // то есть только через метод Speak().
   // Для корректной работы необходимо использовать type assertion (утверждение типа) — d.(Dog).
   // Преобразуем интерфейс обратно к типу Dog
   if dog, ok := d.(Dog); ok {
       fmt.Println(dog.Name)
   } else {
       fmt.Println("Это не собака.")
   }
}
```

**Почему нужно применять type assertion?**

Интерфейс — это оболочка, в которой лежит что-то конкретное (Dog, Cat, Person),
но снаружи видно только методы, указанные в интерфейсе.
Чтобы работать с оригинальным типом (доступ к полям, другим методам и т.п.), нужно "развернуть" интерфейс обратно.

## Реализация встроенного интерфейса Stringer

[оф. док](https://pkg.go.dev/fmt#Stringer)
Данный интерфейс позволяет переопределить, то как функции вывода на экран из пакета fmt будут выводить результат. 
Например: 

```go
package main

import "fmt"

func main() {
   // допустим есть срез
	coffees := []string{"latte", "americano", "espresso"}

   // стандартный вывод будет [latte americano espresso]
	fmt.Println(coffees)

}
```

Но это поведение можно переопределить:

```go
package main

import (
	"fmt"
	"strings"
)

type CustomSlice []string 

func (c CustomSlice) String() string {
	return "[" + strings.Join(c, ", ") + "]"
}

func main() {
	var coffees CustomSlice = []string{"latte", "americano", "espresso"}

	fmt.Println(coffees) // [latte, americano, espresso]

}
```

