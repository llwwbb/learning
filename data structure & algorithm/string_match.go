package main

import (
	"log"
	"strings"
)

func main() {
	test := [][]string{
		{"abababc", "abc"},
		{"a", "abc"},
		{"test",""},
		{"1234123489574132123461234695741321234695741123469574132123463212346123466957112346957413212346231234695741321234646957413211234695741321234621234695741321234695741321234612346346413212346", "12346957413212346"},
		{"ishhomfweuibfesiufhdsishhoishhomfdsuibfeciufhdsishhoishhomfdsuibfesiufhdsishho", "ishhomfdsuibfesiufhdsishho"},
	}
	for _, v := range test {
		a := strings.Index(v[0], v[1])
		b := bm(v[0], v[1])
		log.Println(a, b)
	}
}

func genBC(pattern string) []int {
	badChar := make([]int, SIZE)
	for i := 0; i < len(badChar); i++ {
		badChar[i] = -1
	}
	for i := 0; i < len(pattern); i++ {
		c := pattern[i]
		badChar[c] = i
	}
	return badChar
}

func genGS(pattern string) (suffix []int, prefix []bool) {
	m := len(pattern)
	suffix = make([]int, m)
	prefix = make([]bool, m)
	for i := range suffix {
		suffix[i] = -1
	}
	for i := 0; i < m-1; i++ {
		j := i
		k := m - 1
		for j >= 0 && pattern[j] == pattern[k] {
			suffix[m-k-1] = j + 1
			j--
			k--
		}
		if j < 0 {
			prefix[m-k-1] = true
		}
	}
	return
}

func moveByGS(j, m int, suffix []int, prefix []bool) int {
	k := m - 1 - j
	if suffix[k] != -1 {
		return j - suffix[k] + 1
	}
	//匹配好后缀的后缀子串
	for r := j + 1; r < m; r++ {
		if prefix[m-r] {
			return r
		}
	}
	return m
}

const SIZE = 255

func bm(str, pattern string) int {
	n := len(str)
	m := len(pattern)
	if m > n {
		return -1
	}
	badChar := genBC(pattern)
	suffix, prefix := genGS(pattern)

	i := 0
	for i <= n-m {
		j := m - 1
		for j >= 0 && str[i+j] == pattern[j] {
			j--
		}
		if j == -1 {
			return i
		}
		x := j - badChar[str[i+j]]
		y := 0
		if j < m-1 {
			y = moveByGS(j, m, suffix, prefix)
		}
		i += max(x, y)
	}
	return -1
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
