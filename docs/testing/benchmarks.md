# Бенчмарки
Пример тестирования
Например в файле main.go у меня есть 2 функции:
- printArgsA
- printArgsB

package main

import (
	"os"
	"fmt"
	"strings"
)


func printArgsA() string {
	var s, sep string
	for _, arg := range os.Args[1:] {
		s += sep + arg
		sep = ", "
	}
	return s
}

func printArgsB() string {
	s := strings.Join(os.Args[1:], ", ")
	return s
}

func main() {

	fmt.Println(printArgsA())
	fmt.Println(printArgsB())
}

Для тестового сравнения этих функций я могу создать файл main_test.go
package main

import "testing"

func BenchmarkA(b *testing.B) {
    for i := 0; i < b.N; i++ {
        printArgsA()
    }
}

func BenchmarkB(b *testing.B) {
    for i := 0; i < b.N; i++ {
        printArgsB()
    }
}
И потом выполнить в консоле go test -bench=.