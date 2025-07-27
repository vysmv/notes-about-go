# Управляющие конструкции

## Четыре формы циклов

```go
// традиционный цикл for
   for i := 0; i < 10; i++ {
       fmt.Print(i*i, " ")
   }

// цикл for, используемый как цикл while
   i := 0
   for {
       if i == 10 {
           break
       }
       fmt.Print(i*i, " ")
       i++
   }

// аналог foreach для работы с массивами и срезами
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