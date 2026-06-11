# Управляющие конструкции

## Четыре формы циклов

```go
// традиционный цикл for
   for i := 0; i < 10; i++ {
       fmt.Print(i*i, " ")
   }

// Бесконечный цикл
   i := 0
   for {
       if i == 10 {
           break
       }
       fmt.Print(i*i, " ")
       i++
   }

// Цикл по диапазону (range)
// Даный вид цикла может работать с:
// - Массив (array)
// - Указатель на массив (*[N]T)
// - Срез (slice)
// - Строка (string)
// - Карта (map)
// - Канал (chan)
// - Целое число (integer)
// - Функция-итератор (func(yield ...))
   aSlice := []int{-1, 2, 1, -1, 2, -2}
   for i, v := range aSlice {
       fmt.Println("index:", i, "value: ", v)
   }

// По условию
   variable := 10
   variable2 := "ivan"
   for variable < 15 && variable2 == "ivan" {
       fmt.Println(variable)
       variable++
   }  
```

## Две формы switch

```go
// с выражением после switch
   switch argument {
   case "0":
       fmt.Println("Zero!")
   case "1":
       fmt.Println("One!")
   case "2", "3", "4":
       fmt.Println("2 or 3 or 4")
       fallthrough
   default:
       fmt.Println("Value:", argument)
   }

// без выражения после switch
   switch {
   case value == 0:
       fmt.Println("Zero!")
   case value > 0:
       fmt.Println("Positive integer")
   case value < 0:
       fmt.Println("Negative integer")
   default:
       fmt.Println("This should not happen:", value)
   }
```

## Две формы if

```go
// обычный if
if value > 0 {
    fmt.Println("positive")
}

// if с короткой инструкцией
if err := doSomething(); err != nil {
    fmt.Println(err)
}
```

Особенности:

- Скобки вокруг условия не используются.
- Условие должно иметь тип bool.
- Доступна короткая инструкция перед условием.
- Конструкции тернарного оператора (`?:`) в Go нет.