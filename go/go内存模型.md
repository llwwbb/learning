https://golang.org/ref/mem
Version of May 31, 2014

# The Go Memory Model
# Go内存模型

## Introduction
## 介绍

The Go memory model specifies the conditions under which reads of a variable in one goroutine can be guaranteed to observe values produced by writes to the same variable in a different goroutine.

go内存模型阐述了，一个go程对一个变量的读取操作，在何种条件下能观测到其它go程对同一变量写入的值

## Advice
## 建议

Programs that modify data being simultaneously accessed by multiple goroutines must serialize such access.

修改被多个go程同时访问的数据的程序必须将访问串行化。

To serialize access, protect the data with channel operations or other synchronization primitives such as those in the sync and sync/atomic packages.

为串行化访问，须使用信道操作或其他同步原语，例如sync和sync/atomic包中提供的那些，来保护数据。

If you must read the rest of this document to understand the behavior of your program, you are being too clever.

如果必须阅读本文的其余部分才能理解你的程序的行为，你一定非常聪明。

Don't be clever.

不要自作聪明。

## Happens Before
## 事前发生

Within a single goroutine, reads and writes must behave as if they executed in the order specified by the program. That is, compilers and processors may reorder the reads and writes executed within a single goroutine only when the reordering does not change the behavior within that goroutine as defined by the language specification. Because of this reordering, the execution order observed by one goroutine may differ from the order perceived by another. For example, if one goroutine executes a = 1; b = 2;, another might observe the updated value of b before the updated value of a.

在单个go程中，读写操作的行为必须跟按照程序中指定的顺序执行一样。就是说，编译器和处理器可能对在单个go程中执行的读写操作进行重排序，仅当重排序不会改变这个go程中按照语言规范所定义的行为。由于这种重排序，由一个go程所观测到的执行顺序可能跟另一个所感知的不同。举个例子，如果一个go程执行a = 1; b = 2; 另一个可能观察到b值的更新在a之前。

To specify the requirements of reads and writes, we define _happens before_, a partial order on the execution of memory operations in a Go program. If event e1 happens before event e2, then we say that e2 happens after e1. Also, if e1 does not happen before e2 and does not happen after e2, then we say that e1 and e2 happen concurrently.

我们定义 _事前发生_，go程序中内存操作执行的一种偏序，来表示读写操作要求。如果事件e1在事件e2 _事前发生_，我们就说e2在e1事后发生。同样，如果e1既没有在e2事前发生，也没有在e2事后发生，我们就说e1和e2同时发生。

_Within a single goroutine, the happens-before order is the order expressed by the program._

_在单个go程中，事前发生顺序就是程序表现的顺序。_

A read r of a variable v is allowed to observe a write w to v if both of the following hold:

如果以下两个条件均成立，对变量v的读操作r _允许_ 观测对v的写操作w，

1. r does not happen before w.

    r不在w事前发生。

2. There is no other write w' to v that happens after w but before r.

    没有其它在w事后r事前发生的对v的写操作w'。

To guarantee that a read r of a variable v observes a particular write w to v, ensure that w is the only write r is allowed to observe. That is, r is guaranteed to observe w if both of the following hold:

为确保变量v的读取操作r观测到对v的特定写操作w，请确保r只被允许观测写操作w。也就是说，如果以下两个条件均成立，r保证能观察到w：

1. w happens before r.

    w在r事前发生

2. Any other write to the shared variable v either happens before w or after r.

    对共享变量v的其他写操作要么在w事前发生，要么在r事后发生

This pair of conditions is stronger than the first pair; it requires that there are no other writes happening concurrently with w or r.

这对条件比第一对更强。它要求没有其他写操作与w或r同时发生。

Within a single goroutine, there is no concurrency, so the two definitions are equivalent: a read r observes the value written by the most recent write w to v. When multiple goroutines access a shared variable v, they must use synchronization events to establish happens-before conditions that ensure reads observe the desired writes.

在单个go程中，不存在同时，因此这两个定义是一样的。一个读操作r观测到由最近的写操作w对v写入的值。当多个go程访问一个共享变量v，他们必须使用同步事件来建立事前发生条件，确保读观察到期望的写。

The initialization of variable v with the zero value for v's type behaves as a write in the memory model.

用v类型的零值对变量v的初始化与在内存模型中的写操作表现一样。

Reads and writes of values larger than a single machine word behave as multiple machine-word-sized operations in an unspecified order.

对大于一个机器字的读写操作相当于多个机器字大小的无序操作。

## Synchronization
## 同步

### Initialization
### 初始化

Program initialization runs in a single goroutine, but that goroutine may create other goroutines, which run concurrently.

程序初始化在单个go程中运行，但是这个go程可能创建其它go程，同步运行。

_If a package p imports package q, the completion of q's init functions happens before the start of any of p's._

_如果包p导入包q，q的init方法完成在p的任意方法开始的事前发生。

_The start of the function main.main happens after all init functions have finished._

_main.main方法的开始在所有init方法结束的事后发生。_

### Goroutine creation
### go程的创建

_The go statement that starts a new goroutine happens before the goroutine's execution begins._

_开始一个新go程的语句在go程开始执行的事前发生。_

For example, in this program:
例如，在这个程序中：

``` golang
var a string

func f() {
	print(a)
}

func hello() {
	a = "hello, world"
	go f()
}
```

calling hello will print "hello, world" at some point in the future (perhaps after hello has returned).
调用hello方法将在未来某时刻打印"hello, world"（可能在hello返回后）

### Goroutine destruction
### go程的销毁

The exit of a goroutine is not guaranteed to happen before any event in the program. For example, in this program:
go程的退出不保证在程序中任何事件的事前发生.例如，在这个程序中：

``` golang
var a string

func hello() {
	go func() { a = "hello" }()
	print(a)
}
```

the assignment to a is not followed by any synchronization event, so it is not guaranteed to be observed by any other goroutine. In fact, an aggressive compiler might delete the entire go statement.
对a的赋值后没有任何同步事件，所以不保证其他go程可以观测到。事实上，积极的编译器可能会删掉整个go语句。

If the effects of a goroutine must be observed by another goroutine, use a synchronization mechanism such as a lock or channel communication to establish a relative ordering.

如果一个go程必须观测另一个go程的影响，使用同步机制例如锁或者信道通讯来建立相关顺序。

### Channel communication
### 信道通讯

Channel communication is the main method of synchronization between goroutines. Each send on a particular channel is matched to a corresponding receive from that channel, usually in a different goroutine.
信道通讯是go程之间同步的主要方法。在一个特定信道上的每一个发送都匹配到一个对应接受，通常在一个不同的go程上。

A send on a channel happens before the corresponding receive from that channel completes.
一个信道上的发送在这个信道相应接收完成事前发生。


This program:
这个程序：

``` golang
var c = make(chan int, 10)
var a string

func f() {
	a = "hello, world"
	c <- 0
}

func main() {
	go f()
	<-c
	print(a)
}
```

is guaranteed to print "hello, world". The write to a happens before the send on c, which happens before the corresponding receive on c completes, which happens before the print.
保证能打印"hello, world". 对a的写入在发送到c的事前发生，也在c上对应的接收完成的事前发生，在打印事前发生。

The closing of a channel happens before a receive that returns a zero value because the channel is closed.
信道的关闭在接收到由于信道关闭而返回的一个零值的事前发生。

In the previous example, replacing c <- 0 with close(c) yields a program with the same guaranteed behavior.
在上一个例子中，将c <- 0替换为close(c)将产生一个具有相同保证行为的程序。

A receive from an unbuffered channel happens before the send on that channel completes.
来自无缓存信道的接收在该信道上的发送完成事前发生。

This program (as above, but with the send and receive statements swapped and using an unbuffered channel):
这个程序（类似上面，但是发送和接收语句调换，并且使用无缓存信道：

``` golang
var c = make(chan int)
var a string

func f() {
	a = "hello, world"
	<-c
}

func main() {
	go f()
	c <- 0
	print(a)
}
```

is also guaranteed to print "hello, world". The write to a happens before the receive on c, which happens before the corresponding send on c completes, which happens before the print.
也保证可以打印"hello, world". 对a的写入在c的接收事前发生，在c的对应发送完成事前发生，在打印事前发生。

If the channel were buffered (e.g., c = make(chan int, 1)) then the program would not be guaranteed to print "hello, world". (It might print the empty string, crash, or do something else.)
如果信道有缓存 (e.g., c = make(chan int, 1)) 那么程序不会保证打印"hello, world".（可能打印空字符串，崩溃或者其他什么）

The kth receive on a channel with capacity C happens before the k+Cth send from that channel completes.
在容量为C的信道上的第k次接收，在第k+C次此信道上的发送完成事前发生。

This rule generalizes the previous rule to buffered channels. It allows a counting semaphore to be modeled by a buffered channel: the number of items in the channel corresponds to the number of active uses, the capacity of the channel corresponds to the maximum number of simultaneous uses, sending an item acquires the semaphore, and receiving an item releases the semaphore. This is a common idiom for limiting concurrency.
该规则将前一个规则推广到缓冲信道。缓冲信道是对计数信号量的建模：信道中的项目数对应活跃的使用数，信道的容量对应同时使用的最大数量，发送项目获取信号量，接收项目释放信号量。这是限制并发的常见用法。

This program starts a goroutine for every entry in the work list, but the goroutines coordinate using the limit channel to ensure that at most three are running work functions at a time.
这个程度对work列表中的每一个入口开始了一个go程，但是go程使用有限信道进行协调，确保同时最多只有三个work方法在运行。

```golang
var limit = make(chan int, 3)

func main() {
	for _, w := range work {
		go func(w func()) {
			limit <- 1
			w()
			<-limit
		}(w)
	}
	select{}
}
```

### Locks
### 锁

The sync package implements two lock data types, sync.Mutex and sync.RWMutex.
sync包实现了两个锁数据类型，sync.Mutex 和 sync.RWMutex.

For any sync.Mutex or sync.RWMutex variable l and n < m, call n of l.Unlock() happens before call m of l.Lock() returns.
对任意sync.Mutex 或 sync.RWMutex变量l，n < m, 对l.Unlock()的调用n在对l.Lock()的调用m事前发生。

This program:
这个程序：

```golang
var l sync.Mutex
var a string

func f() {
	a = "hello, world"
	l.Unlock()
}

func main() {
	l.Lock()
	go f()
	l.Lock()
	print(a)
}
```

is guaranteed to print "hello, world". The first call to l.Unlock() (in f) happens before the second call to l.Lock() (in main) returns, which happens before the print.
保证打印"hello, world".第一次调用l.Unlock()（在f中）在第二次调用l.Lock()(在main中)返回事前发生，在打印事前发生。

For any call to l.RLock on a sync.RWMutex variable l, there is an n such that the l.RLock happens (returns) after call n to l.Unlock and the matching l.RUnlock happens before call n+1 to l.Lock.
对sync.RWMutex变量l的任意调用l.RLock, 有n，l.RLock在l.Unlock的调用n事后发生（返回），对应的l.RUnlock在对l.Lock的n+1调用事前发生。

### Once
### Once 

The sync package provides a safe mechanism for initialization in the presence of multiple goroutines through the use of the Once type. Multiple threads can execute once.Do(f) for a particular f, but only one will run f(), and the other calls block until f() has returned.
在存在多个go程的情况下,sync包通过Once类型为初始化提供了一种安全的机制.多线程可以为特定的f执行once.Do(f), 但只有一个会运行f(), 其他调用会阻塞直到f()返回。

A single call of f() from once.Do(f) happens (returns) before any call of once.Do(f) returns.
来自once.Do(f)的单个f()调用在任意对once.Do(f)返回事前发生（返回）。

In this program:
在这个程序中：

```golang
var a string
var once sync.Once

func setup() {
	a = "hello, world"
}

func doprint() {
	once.Do(setup)
	print(a)
}

func twoprint() {
	go doprint()
	go doprint()
}
```

calling twoprint will call setup exactly once. The setup function will complete before either call of print. The result will be that "hello, world" will be printed twice.
调用twoprint会调用setup一次。setup方法会在任一对print的调用之前完成。结果会是"hello, world"会被打印两次。

### Incorrect synchronization
### 不正确的同步

Note that a read r may observe the value written by a write w that happens concurrently with r. Even if this occurs, it does not imply that reads happening after r will observe writes that happened before w.
注意，读r可能观测到跟r同时发生的w写入的值。即使这发生了，也不意味着在r事后发生，的读会观测到在w事前发生的写入。

In this program:
在这个程序中：

```golang
var a, b int

func f() {
	a = 1
	b = 2
}

func g() {
	print(b)
	print(a)
}

func main() {
	go f()
	g()
}
```

it can happen that g prints 2 and then 0.
可能发生g打印2和0

This fact invalidates a few common idioms.
这个事实会使许多常见习惯无效。

Double-checked locking is an attempt to avoid the overhead of synchronization. For example, the twoprint program might be incorrectly written as:
双重检测锁是避免同步开销的一种尝试。例如，twoprint程序可能会被错误的写成：

```golang
var a string
var done bool

func setup() {
	a = "hello, world"
	done = true
}

func doprint() {
	if !done {
		once.Do(setup)
	}
	print(a)
}

func twoprint() {
	go doprint()
	go doprint()
}
```

but there is no guarantee that, in doprint, observing the write to done implies observing the write to a. This version can (incorrectly) print an empty string instead of "hello, world".
但是这不能保证，对done写入的观测意味着对a写入的观测。这个版本可能（不正确地）打印一个空字符串而不是"hello, world"。

Another incorrect idiom is busy waiting for a value, as in:
另一个不正确的习惯是对一个值忙等待，就像：

``` golang
var a string
var done bool

func setup() {
	a = "hello, world"
	done = true
}

func main() {
	go setup()
	for !done {
	}
	print(a)
}
```

As before, there is no guarantee that, in main, observing the write to done implies observing the write to a, so this program could print an empty string too. Worse, there is no guarantee that the write to done will ever be observed by main, since there are no synchronization events between the two threads. The loop in main is not guaranteed to finish.
像之前一样，不能保证，在main中，对done写入的观测意味着对a写入的观测，所以这个程序也可能打印一个空字符串。更糟糕的是，不能保证对done的写入会被main观测到，因为两个线程之间没有同步事件。main中的循环不保证会结束。

There are subtler variants on this theme, such as this program.
在这个主题中有一种微妙的变种，例如这个程序。

``` golang
type T struct {
	msg string
}

var g *T

func setup() {
	t := new(T)
	t.msg = "hello, world"
	g = t
}

func main() {
	go setup()
	for g == nil {
	}
	print(g.msg)
}
```

Even if main observes g != nil and exits its loop, there is no guarantee that it will observe the initialized value for g.msg.
即使main观测到g != nil并且在它的循环中存在，也无法保证它会观测到g.msg初始化后的值。

In all these examples, the solution is the same: use explicit synchronization.
在所有这些例子中，解决方案都是一样的：使用显示同步。