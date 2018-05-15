
bin/kernel_nopage:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 28 af 11 00       	mov    $0x11af28,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	83 ec 04             	sub    $0x4,%esp
  10004d:	50                   	push   %eax
  10004e:	6a 00                	push   $0x0
  100050:	68 36 7a 11 00       	push   $0x117a36
  100055:	e8 7f 52 00 00       	call   1052d9 <memset>
  10005a:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
  10005d:	e8 70 15 00 00       	call   1015d2 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100062:	c7 45 f4 80 5a 10 00 	movl   $0x105a80,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100069:	83 ec 08             	sub    $0x8,%esp
  10006c:	ff 75 f4             	pushl  -0xc(%ebp)
  10006f:	68 9c 5a 10 00       	push   $0x105a9c
  100074:	e8 fa 01 00 00       	call   100273 <cprintf>
  100079:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
  10007c:	e8 91 08 00 00       	call   100912 <print_kerninfo>

    grade_backtrace();
  100081:	e8 74 00 00 00       	call   1000fa <grade_backtrace>

    pmm_init();                 // init physical memory management
  100086:	e8 ce 30 00 00       	call   103159 <pmm_init>

    pic_init();                 // init interrupt controller
  10008b:	e8 b4 16 00 00       	call   101744 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100090:	e8 15 18 00 00       	call   1018aa <idt_init>

    clock_init();               // init clock interrupt
  100095:	e8 df 0c 00 00       	call   100d79 <clock_init>
    intr_enable();              // enable irq interrupt
  10009a:	e8 e2 17 00 00       	call   101881 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  10009f:	eb fe                	jmp    10009f <kern_init+0x69>

001000a1 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a1:	55                   	push   %ebp
  1000a2:	89 e5                	mov    %esp,%ebp
  1000a4:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
  1000a7:	83 ec 04             	sub    $0x4,%esp
  1000aa:	6a 00                	push   $0x0
  1000ac:	6a 00                	push   $0x0
  1000ae:	6a 00                	push   $0x0
  1000b0:	e8 b2 0c 00 00       	call   100d67 <mon_backtrace>
  1000b5:	83 c4 10             	add    $0x10,%esp
}
  1000b8:	90                   	nop
  1000b9:	c9                   	leave  
  1000ba:	c3                   	ret    

001000bb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000bb:	55                   	push   %ebp
  1000bc:	89 e5                	mov    %esp,%ebp
  1000be:	53                   	push   %ebx
  1000bf:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000c2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000c8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1000ce:	51                   	push   %ecx
  1000cf:	52                   	push   %edx
  1000d0:	53                   	push   %ebx
  1000d1:	50                   	push   %eax
  1000d2:	e8 ca ff ff ff       	call   1000a1 <grade_backtrace2>
  1000d7:	83 c4 10             	add    $0x10,%esp
}
  1000da:	90                   	nop
  1000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000de:	c9                   	leave  
  1000df:	c3                   	ret    

001000e0 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000e0:	55                   	push   %ebp
  1000e1:	89 e5                	mov    %esp,%ebp
  1000e3:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
  1000e6:	83 ec 08             	sub    $0x8,%esp
  1000e9:	ff 75 10             	pushl  0x10(%ebp)
  1000ec:	ff 75 08             	pushl  0x8(%ebp)
  1000ef:	e8 c7 ff ff ff       	call   1000bb <grade_backtrace1>
  1000f4:	83 c4 10             	add    $0x10,%esp
}
  1000f7:	90                   	nop
  1000f8:	c9                   	leave  
  1000f9:	c3                   	ret    

001000fa <grade_backtrace>:

void
grade_backtrace(void) {
  1000fa:	55                   	push   %ebp
  1000fb:	89 e5                	mov    %esp,%ebp
  1000fd:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  100100:	b8 36 00 10 00       	mov    $0x100036,%eax
  100105:	83 ec 04             	sub    $0x4,%esp
  100108:	68 00 00 ff ff       	push   $0xffff0000
  10010d:	50                   	push   %eax
  10010e:	6a 00                	push   $0x0
  100110:	e8 cb ff ff ff       	call   1000e0 <grade_backtrace0>
  100115:	83 c4 10             	add    $0x10,%esp
}
  100118:	90                   	nop
  100119:	c9                   	leave  
  10011a:	c3                   	ret    

0010011b <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10011b:	55                   	push   %ebp
  10011c:	89 e5                	mov    %esp,%ebp
  10011e:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100121:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100124:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100127:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10012a:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10012d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100131:	0f b7 c0             	movzwl %ax,%eax
  100134:	83 e0 03             	and    $0x3,%eax
  100137:	89 c2                	mov    %eax,%edx
  100139:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10013e:	83 ec 04             	sub    $0x4,%esp
  100141:	52                   	push   %edx
  100142:	50                   	push   %eax
  100143:	68 a1 5a 10 00       	push   $0x105aa1
  100148:	e8 26 01 00 00       	call   100273 <cprintf>
  10014d:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
  100150:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100154:	0f b7 d0             	movzwl %ax,%edx
  100157:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10015c:	83 ec 04             	sub    $0x4,%esp
  10015f:	52                   	push   %edx
  100160:	50                   	push   %eax
  100161:	68 af 5a 10 00       	push   $0x105aaf
  100166:	e8 08 01 00 00       	call   100273 <cprintf>
  10016b:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
  10016e:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100172:	0f b7 d0             	movzwl %ax,%edx
  100175:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10017a:	83 ec 04             	sub    $0x4,%esp
  10017d:	52                   	push   %edx
  10017e:	50                   	push   %eax
  10017f:	68 bd 5a 10 00       	push   $0x105abd
  100184:	e8 ea 00 00 00       	call   100273 <cprintf>
  100189:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
  10018c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100190:	0f b7 d0             	movzwl %ax,%edx
  100193:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100198:	83 ec 04             	sub    $0x4,%esp
  10019b:	52                   	push   %edx
  10019c:	50                   	push   %eax
  10019d:	68 cb 5a 10 00       	push   $0x105acb
  1001a2:	e8 cc 00 00 00       	call   100273 <cprintf>
  1001a7:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
  1001aa:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001ae:	0f b7 d0             	movzwl %ax,%edx
  1001b1:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b6:	83 ec 04             	sub    $0x4,%esp
  1001b9:	52                   	push   %edx
  1001ba:	50                   	push   %eax
  1001bb:	68 d9 5a 10 00       	push   $0x105ad9
  1001c0:	e8 ae 00 00 00       	call   100273 <cprintf>
  1001c5:	83 c4 10             	add    $0x10,%esp
    round ++;
  1001c8:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001cd:	83 c0 01             	add    $0x1,%eax
  1001d0:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001d5:	90                   	nop
  1001d6:	c9                   	leave  
  1001d7:	c3                   	ret    

001001d8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001d8:	55                   	push   %ebp
  1001d9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001db:	90                   	nop
  1001dc:	5d                   	pop    %ebp
  1001dd:	c3                   	ret    

001001de <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001de:	55                   	push   %ebp
  1001df:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  1001e1:	90                   	nop
  1001e2:	5d                   	pop    %ebp
  1001e3:	c3                   	ret    

001001e4 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001e4:	55                   	push   %ebp
  1001e5:	89 e5                	mov    %esp,%ebp
  1001e7:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
  1001ea:	e8 2c ff ff ff       	call   10011b <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001ef:	83 ec 0c             	sub    $0xc,%esp
  1001f2:	68 e8 5a 10 00       	push   $0x105ae8
  1001f7:	e8 77 00 00 00       	call   100273 <cprintf>
  1001fc:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
  1001ff:	e8 d4 ff ff ff       	call   1001d8 <lab1_switch_to_user>
    lab1_print_cur_status();
  100204:	e8 12 ff ff ff       	call   10011b <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100209:	83 ec 0c             	sub    $0xc,%esp
  10020c:	68 08 5b 10 00       	push   $0x105b08
  100211:	e8 5d 00 00 00       	call   100273 <cprintf>
  100216:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
  100219:	e8 c0 ff ff ff       	call   1001de <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10021e:	e8 f8 fe ff ff       	call   10011b <lab1_print_cur_status>
}
  100223:	90                   	nop
  100224:	c9                   	leave  
  100225:	c3                   	ret    

00100226 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100226:	55                   	push   %ebp
  100227:	89 e5                	mov    %esp,%ebp
  100229:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
  10022c:	83 ec 0c             	sub    $0xc,%esp
  10022f:	ff 75 08             	pushl  0x8(%ebp)
  100232:	e8 cc 13 00 00       	call   101603 <cons_putc>
  100237:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
  10023a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10023d:	8b 00                	mov    (%eax),%eax
  10023f:	8d 50 01             	lea    0x1(%eax),%edx
  100242:	8b 45 0c             	mov    0xc(%ebp),%eax
  100245:	89 10                	mov    %edx,(%eax)
}
  100247:	90                   	nop
  100248:	c9                   	leave  
  100249:	c3                   	ret    

0010024a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10024a:	55                   	push   %ebp
  10024b:	89 e5                	mov    %esp,%ebp
  10024d:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  100250:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100257:	ff 75 0c             	pushl  0xc(%ebp)
  10025a:	ff 75 08             	pushl  0x8(%ebp)
  10025d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100260:	50                   	push   %eax
  100261:	68 26 02 10 00       	push   $0x100226
  100266:	e8 a4 53 00 00       	call   10560f <vprintfmt>
  10026b:	83 c4 10             	add    $0x10,%esp
    return cnt;
  10026e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100271:	c9                   	leave  
  100272:	c3                   	ret    

00100273 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100273:	55                   	push   %ebp
  100274:	89 e5                	mov    %esp,%ebp
  100276:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100279:	8d 45 0c             	lea    0xc(%ebp),%eax
  10027c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10027f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100282:	83 ec 08             	sub    $0x8,%esp
  100285:	50                   	push   %eax
  100286:	ff 75 08             	pushl  0x8(%ebp)
  100289:	e8 bc ff ff ff       	call   10024a <vcprintf>
  10028e:	83 c4 10             	add    $0x10,%esp
  100291:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100297:	c9                   	leave  
  100298:	c3                   	ret    

00100299 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100299:	55                   	push   %ebp
  10029a:	89 e5                	mov    %esp,%ebp
  10029c:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
  10029f:	83 ec 0c             	sub    $0xc,%esp
  1002a2:	ff 75 08             	pushl  0x8(%ebp)
  1002a5:	e8 59 13 00 00       	call   101603 <cons_putc>
  1002aa:	83 c4 10             	add    $0x10,%esp
}
  1002ad:	90                   	nop
  1002ae:	c9                   	leave  
  1002af:	c3                   	ret    

001002b0 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002b0:	55                   	push   %ebp
  1002b1:	89 e5                	mov    %esp,%ebp
  1002b3:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  1002b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002bd:	eb 14                	jmp    1002d3 <cputs+0x23>
        cputch(c, &cnt);
  1002bf:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002c3:	83 ec 08             	sub    $0x8,%esp
  1002c6:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002c9:	52                   	push   %edx
  1002ca:	50                   	push   %eax
  1002cb:	e8 56 ff ff ff       	call   100226 <cputch>
  1002d0:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1002d6:	8d 50 01             	lea    0x1(%eax),%edx
  1002d9:	89 55 08             	mov    %edx,0x8(%ebp)
  1002dc:	0f b6 00             	movzbl (%eax),%eax
  1002df:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002e2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1002e6:	75 d7                	jne    1002bf <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1002e8:	83 ec 08             	sub    $0x8,%esp
  1002eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1002ee:	50                   	push   %eax
  1002ef:	6a 0a                	push   $0xa
  1002f1:	e8 30 ff ff ff       	call   100226 <cputch>
  1002f6:	83 c4 10             	add    $0x10,%esp
    return cnt;
  1002f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1002fc:	c9                   	leave  
  1002fd:	c3                   	ret    

001002fe <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1002fe:	55                   	push   %ebp
  1002ff:	89 e5                	mov    %esp,%ebp
  100301:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100304:	e8 43 13 00 00       	call   10164c <cons_getc>
  100309:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10030c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100310:	74 f2                	je     100304 <getchar+0x6>
        /* do nothing */;
    return c;
  100312:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100315:	c9                   	leave  
  100316:	c3                   	ret    

00100317 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100317:	55                   	push   %ebp
  100318:	89 e5                	mov    %esp,%ebp
  10031a:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
  10031d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100321:	74 13                	je     100336 <readline+0x1f>
        cprintf("%s", prompt);
  100323:	83 ec 08             	sub    $0x8,%esp
  100326:	ff 75 08             	pushl  0x8(%ebp)
  100329:	68 27 5b 10 00       	push   $0x105b27
  10032e:	e8 40 ff ff ff       	call   100273 <cprintf>
  100333:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
  100336:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10033d:	e8 bc ff ff ff       	call   1002fe <getchar>
  100342:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100345:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100349:	79 0a                	jns    100355 <readline+0x3e>
            return NULL;
  10034b:	b8 00 00 00 00       	mov    $0x0,%eax
  100350:	e9 82 00 00 00       	jmp    1003d7 <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100355:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100359:	7e 2b                	jle    100386 <readline+0x6f>
  10035b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100362:	7f 22                	jg     100386 <readline+0x6f>
            cputchar(c);
  100364:	83 ec 0c             	sub    $0xc,%esp
  100367:	ff 75 f0             	pushl  -0x10(%ebp)
  10036a:	e8 2a ff ff ff       	call   100299 <cputchar>
  10036f:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
  100372:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100375:	8d 50 01             	lea    0x1(%eax),%edx
  100378:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10037b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10037e:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  100384:	eb 4c                	jmp    1003d2 <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
  100386:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  10038a:	75 1a                	jne    1003a6 <readline+0x8f>
  10038c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100390:	7e 14                	jle    1003a6 <readline+0x8f>
            cputchar(c);
  100392:	83 ec 0c             	sub    $0xc,%esp
  100395:	ff 75 f0             	pushl  -0x10(%ebp)
  100398:	e8 fc fe ff ff       	call   100299 <cputchar>
  10039d:	83 c4 10             	add    $0x10,%esp
            i --;
  1003a0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1003a4:	eb 2c                	jmp    1003d2 <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
  1003a6:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003aa:	74 06                	je     1003b2 <readline+0x9b>
  1003ac:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003b0:	75 8b                	jne    10033d <readline+0x26>
            cputchar(c);
  1003b2:	83 ec 0c             	sub    $0xc,%esp
  1003b5:	ff 75 f0             	pushl  -0x10(%ebp)
  1003b8:	e8 dc fe ff ff       	call   100299 <cputchar>
  1003bd:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
  1003c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003c3:	05 20 a0 11 00       	add    $0x11a020,%eax
  1003c8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003cb:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1003d0:	eb 05                	jmp    1003d7 <readline+0xc0>
        }
    }
  1003d2:	e9 66 ff ff ff       	jmp    10033d <readline+0x26>
}
  1003d7:	c9                   	leave  
  1003d8:	c3                   	ret    

001003d9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003d9:	55                   	push   %ebp
  1003da:	89 e5                	mov    %esp,%ebp
  1003dc:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
  1003df:	a1 20 a4 11 00       	mov    0x11a420,%eax
  1003e4:	85 c0                	test   %eax,%eax
  1003e6:	75 5f                	jne    100447 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
  1003e8:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  1003ef:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1003f2:	8d 45 14             	lea    0x14(%ebp),%eax
  1003f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1003f8:	83 ec 04             	sub    $0x4,%esp
  1003fb:	ff 75 0c             	pushl  0xc(%ebp)
  1003fe:	ff 75 08             	pushl  0x8(%ebp)
  100401:	68 2a 5b 10 00       	push   $0x105b2a
  100406:	e8 68 fe ff ff       	call   100273 <cprintf>
  10040b:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  10040e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100411:	83 ec 08             	sub    $0x8,%esp
  100414:	50                   	push   %eax
  100415:	ff 75 10             	pushl  0x10(%ebp)
  100418:	e8 2d fe ff ff       	call   10024a <vcprintf>
  10041d:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  100420:	83 ec 0c             	sub    $0xc,%esp
  100423:	68 46 5b 10 00       	push   $0x105b46
  100428:	e8 46 fe ff ff       	call   100273 <cprintf>
  10042d:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
  100430:	83 ec 0c             	sub    $0xc,%esp
  100433:	68 48 5b 10 00       	push   $0x105b48
  100438:	e8 36 fe ff ff       	call   100273 <cprintf>
  10043d:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
  100440:	e8 17 06 00 00       	call   100a5c <print_stackframe>
  100445:	eb 01                	jmp    100448 <__panic+0x6f>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
  100447:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
  100448:	e8 3b 14 00 00       	call   101888 <intr_disable>
    while (1) {
        kmonitor(NULL);
  10044d:	83 ec 0c             	sub    $0xc,%esp
  100450:	6a 00                	push   $0x0
  100452:	e8 36 08 00 00       	call   100c8d <kmonitor>
  100457:	83 c4 10             	add    $0x10,%esp
    }
  10045a:	eb f1                	jmp    10044d <__panic+0x74>

0010045c <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  10045c:	55                   	push   %ebp
  10045d:	89 e5                	mov    %esp,%ebp
  10045f:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
  100462:	8d 45 14             	lea    0x14(%ebp),%eax
  100465:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100468:	83 ec 04             	sub    $0x4,%esp
  10046b:	ff 75 0c             	pushl  0xc(%ebp)
  10046e:	ff 75 08             	pushl  0x8(%ebp)
  100471:	68 5a 5b 10 00       	push   $0x105b5a
  100476:	e8 f8 fd ff ff       	call   100273 <cprintf>
  10047b:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  10047e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100481:	83 ec 08             	sub    $0x8,%esp
  100484:	50                   	push   %eax
  100485:	ff 75 10             	pushl  0x10(%ebp)
  100488:	e8 bd fd ff ff       	call   10024a <vcprintf>
  10048d:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  100490:	83 ec 0c             	sub    $0xc,%esp
  100493:	68 46 5b 10 00       	push   $0x105b46
  100498:	e8 d6 fd ff ff       	call   100273 <cprintf>
  10049d:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  1004a0:	90                   	nop
  1004a1:	c9                   	leave  
  1004a2:	c3                   	ret    

001004a3 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004a3:	55                   	push   %ebp
  1004a4:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004a6:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  1004ab:	5d                   	pop    %ebp
  1004ac:	c3                   	ret    

001004ad <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004ad:	55                   	push   %ebp
  1004ae:	89 e5                	mov    %esp,%ebp
  1004b0:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004b6:	8b 00                	mov    (%eax),%eax
  1004b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004bb:	8b 45 10             	mov    0x10(%ebp),%eax
  1004be:	8b 00                	mov    (%eax),%eax
  1004c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004ca:	e9 d2 00 00 00       	jmp    1005a1 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  1004cf:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004d5:	01 d0                	add    %edx,%eax
  1004d7:	89 c2                	mov    %eax,%edx
  1004d9:	c1 ea 1f             	shr    $0x1f,%edx
  1004dc:	01 d0                	add    %edx,%eax
  1004de:	d1 f8                	sar    %eax
  1004e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004e6:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004e9:	eb 04                	jmp    1004ef <stab_binsearch+0x42>
            m --;
  1004eb:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004f2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004f5:	7c 1f                	jl     100516 <stab_binsearch+0x69>
  1004f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004fa:	89 d0                	mov    %edx,%eax
  1004fc:	01 c0                	add    %eax,%eax
  1004fe:	01 d0                	add    %edx,%eax
  100500:	c1 e0 02             	shl    $0x2,%eax
  100503:	89 c2                	mov    %eax,%edx
  100505:	8b 45 08             	mov    0x8(%ebp),%eax
  100508:	01 d0                	add    %edx,%eax
  10050a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10050e:	0f b6 c0             	movzbl %al,%eax
  100511:	3b 45 14             	cmp    0x14(%ebp),%eax
  100514:	75 d5                	jne    1004eb <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  100516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100519:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10051c:	7d 0b                	jge    100529 <stab_binsearch+0x7c>
            l = true_m + 1;
  10051e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100521:	83 c0 01             	add    $0x1,%eax
  100524:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100527:	eb 78                	jmp    1005a1 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100529:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100530:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100533:	89 d0                	mov    %edx,%eax
  100535:	01 c0                	add    %eax,%eax
  100537:	01 d0                	add    %edx,%eax
  100539:	c1 e0 02             	shl    $0x2,%eax
  10053c:	89 c2                	mov    %eax,%edx
  10053e:	8b 45 08             	mov    0x8(%ebp),%eax
  100541:	01 d0                	add    %edx,%eax
  100543:	8b 40 08             	mov    0x8(%eax),%eax
  100546:	3b 45 18             	cmp    0x18(%ebp),%eax
  100549:	73 13                	jae    10055e <stab_binsearch+0xb1>
            *region_left = m;
  10054b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10054e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100551:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100553:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100556:	83 c0 01             	add    $0x1,%eax
  100559:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10055c:	eb 43                	jmp    1005a1 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  10055e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100561:	89 d0                	mov    %edx,%eax
  100563:	01 c0                	add    %eax,%eax
  100565:	01 d0                	add    %edx,%eax
  100567:	c1 e0 02             	shl    $0x2,%eax
  10056a:	89 c2                	mov    %eax,%edx
  10056c:	8b 45 08             	mov    0x8(%ebp),%eax
  10056f:	01 d0                	add    %edx,%eax
  100571:	8b 40 08             	mov    0x8(%eax),%eax
  100574:	3b 45 18             	cmp    0x18(%ebp),%eax
  100577:	76 16                	jbe    10058f <stab_binsearch+0xe2>
            *region_right = m - 1;
  100579:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10057c:	8d 50 ff             	lea    -0x1(%eax),%edx
  10057f:	8b 45 10             	mov    0x10(%ebp),%eax
  100582:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  100584:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100587:	83 e8 01             	sub    $0x1,%eax
  10058a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10058d:	eb 12                	jmp    1005a1 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  10058f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100592:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100595:	89 10                	mov    %edx,(%eax)
            l = m;
  100597:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10059a:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  10059d:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1005a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005a7:	0f 8e 22 ff ff ff    	jle    1004cf <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1005ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005b1:	75 0f                	jne    1005c2 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005b6:	8b 00                	mov    (%eax),%eax
  1005b8:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005bb:	8b 45 10             	mov    0x10(%ebp),%eax
  1005be:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1005c0:	eb 3f                	jmp    100601 <stab_binsearch+0x154>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1005c2:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c5:	8b 00                	mov    (%eax),%eax
  1005c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005ca:	eb 04                	jmp    1005d0 <stab_binsearch+0x123>
  1005cc:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1005d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d3:	8b 00                	mov    (%eax),%eax
  1005d5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005d8:	7d 1f                	jge    1005f9 <stab_binsearch+0x14c>
  1005da:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005dd:	89 d0                	mov    %edx,%eax
  1005df:	01 c0                	add    %eax,%eax
  1005e1:	01 d0                	add    %edx,%eax
  1005e3:	c1 e0 02             	shl    $0x2,%eax
  1005e6:	89 c2                	mov    %eax,%edx
  1005e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1005eb:	01 d0                	add    %edx,%eax
  1005ed:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005f1:	0f b6 c0             	movzbl %al,%eax
  1005f4:	3b 45 14             	cmp    0x14(%ebp),%eax
  1005f7:	75 d3                	jne    1005cc <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  1005f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005ff:	89 10                	mov    %edx,(%eax)
    }
}
  100601:	90                   	nop
  100602:	c9                   	leave  
  100603:	c3                   	ret    

00100604 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100604:	55                   	push   %ebp
  100605:	89 e5                	mov    %esp,%ebp
  100607:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10060a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060d:	c7 00 78 5b 10 00    	movl   $0x105b78,(%eax)
    info->eip_line = 0;
  100613:	8b 45 0c             	mov    0xc(%ebp),%eax
  100616:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10061d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100620:	c7 40 08 78 5b 10 00 	movl   $0x105b78,0x8(%eax)
    info->eip_fn_namelen = 9;
  100627:	8b 45 0c             	mov    0xc(%ebp),%eax
  10062a:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100631:	8b 45 0c             	mov    0xc(%ebp),%eax
  100634:	8b 55 08             	mov    0x8(%ebp),%edx
  100637:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10063a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10063d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100644:	c7 45 f4 a8 6d 10 00 	movl   $0x106da8,-0xc(%ebp)
    stab_end = __STAB_END__;
  10064b:	c7 45 f0 cc 1b 11 00 	movl   $0x111bcc,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100652:	c7 45 ec cd 1b 11 00 	movl   $0x111bcd,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100659:	c7 45 e8 74 46 11 00 	movl   $0x114674,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100660:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100663:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100666:	76 0d                	jbe    100675 <debuginfo_eip+0x71>
  100668:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10066b:	83 e8 01             	sub    $0x1,%eax
  10066e:	0f b6 00             	movzbl (%eax),%eax
  100671:	84 c0                	test   %al,%al
  100673:	74 0a                	je     10067f <debuginfo_eip+0x7b>
        return -1;
  100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10067a:	e9 91 02 00 00       	jmp    100910 <debuginfo_eip+0x30c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  10067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100686:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068c:	29 c2                	sub    %eax,%edx
  10068e:	89 d0                	mov    %edx,%eax
  100690:	c1 f8 02             	sar    $0x2,%eax
  100693:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100699:	83 e8 01             	sub    $0x1,%eax
  10069c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  10069f:	ff 75 08             	pushl  0x8(%ebp)
  1006a2:	6a 64                	push   $0x64
  1006a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006a7:	50                   	push   %eax
  1006a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006ab:	50                   	push   %eax
  1006ac:	ff 75 f4             	pushl  -0xc(%ebp)
  1006af:	e8 f9 fd ff ff       	call   1004ad <stab_binsearch>
  1006b4:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
  1006b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006ba:	85 c0                	test   %eax,%eax
  1006bc:	75 0a                	jne    1006c8 <debuginfo_eip+0xc4>
        return -1;
  1006be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006c3:	e9 48 02 00 00       	jmp    100910 <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006cb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006d4:	ff 75 08             	pushl  0x8(%ebp)
  1006d7:	6a 24                	push   $0x24
  1006d9:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006dc:	50                   	push   %eax
  1006dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006e0:	50                   	push   %eax
  1006e1:	ff 75 f4             	pushl  -0xc(%ebp)
  1006e4:	e8 c4 fd ff ff       	call   1004ad <stab_binsearch>
  1006e9:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
  1006ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1006ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006f2:	39 c2                	cmp    %eax,%edx
  1006f4:	7f 7c                	jg     100772 <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1006f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006f9:	89 c2                	mov    %eax,%edx
  1006fb:	89 d0                	mov    %edx,%eax
  1006fd:	01 c0                	add    %eax,%eax
  1006ff:	01 d0                	add    %edx,%eax
  100701:	c1 e0 02             	shl    $0x2,%eax
  100704:	89 c2                	mov    %eax,%edx
  100706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100709:	01 d0                	add    %edx,%eax
  10070b:	8b 00                	mov    (%eax),%eax
  10070d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100710:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100713:	29 d1                	sub    %edx,%ecx
  100715:	89 ca                	mov    %ecx,%edx
  100717:	39 d0                	cmp    %edx,%eax
  100719:	73 22                	jae    10073d <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10071b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10071e:	89 c2                	mov    %eax,%edx
  100720:	89 d0                	mov    %edx,%eax
  100722:	01 c0                	add    %eax,%eax
  100724:	01 d0                	add    %edx,%eax
  100726:	c1 e0 02             	shl    $0x2,%eax
  100729:	89 c2                	mov    %eax,%edx
  10072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10072e:	01 d0                	add    %edx,%eax
  100730:	8b 10                	mov    (%eax),%edx
  100732:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100735:	01 c2                	add    %eax,%edx
  100737:	8b 45 0c             	mov    0xc(%ebp),%eax
  10073a:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10073d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100740:	89 c2                	mov    %eax,%edx
  100742:	89 d0                	mov    %edx,%eax
  100744:	01 c0                	add    %eax,%eax
  100746:	01 d0                	add    %edx,%eax
  100748:	c1 e0 02             	shl    $0x2,%eax
  10074b:	89 c2                	mov    %eax,%edx
  10074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100750:	01 d0                	add    %edx,%eax
  100752:	8b 50 08             	mov    0x8(%eax),%edx
  100755:	8b 45 0c             	mov    0xc(%ebp),%eax
  100758:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  10075b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10075e:	8b 40 10             	mov    0x10(%eax),%eax
  100761:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100764:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100767:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  10076a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10076d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100770:	eb 15                	jmp    100787 <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100772:	8b 45 0c             	mov    0xc(%ebp),%eax
  100775:	8b 55 08             	mov    0x8(%ebp),%edx
  100778:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  10077b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10077e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  100781:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100784:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  100787:	8b 45 0c             	mov    0xc(%ebp),%eax
  10078a:	8b 40 08             	mov    0x8(%eax),%eax
  10078d:	83 ec 08             	sub    $0x8,%esp
  100790:	6a 3a                	push   $0x3a
  100792:	50                   	push   %eax
  100793:	e8 b5 49 00 00       	call   10514d <strfind>
  100798:	83 c4 10             	add    $0x10,%esp
  10079b:	89 c2                	mov    %eax,%edx
  10079d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a0:	8b 40 08             	mov    0x8(%eax),%eax
  1007a3:	29 c2                	sub    %eax,%edx
  1007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007ab:	83 ec 0c             	sub    $0xc,%esp
  1007ae:	ff 75 08             	pushl  0x8(%ebp)
  1007b1:	6a 44                	push   $0x44
  1007b3:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007b6:	50                   	push   %eax
  1007b7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007ba:	50                   	push   %eax
  1007bb:	ff 75 f4             	pushl  -0xc(%ebp)
  1007be:	e8 ea fc ff ff       	call   1004ad <stab_binsearch>
  1007c3:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
  1007c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007cc:	39 c2                	cmp    %eax,%edx
  1007ce:	7f 24                	jg     1007f4 <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
  1007d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007d3:	89 c2                	mov    %eax,%edx
  1007d5:	89 d0                	mov    %edx,%eax
  1007d7:	01 c0                	add    %eax,%eax
  1007d9:	01 d0                	add    %edx,%eax
  1007db:	c1 e0 02             	shl    $0x2,%eax
  1007de:	89 c2                	mov    %eax,%edx
  1007e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007e3:	01 d0                	add    %edx,%eax
  1007e5:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  1007e9:	0f b7 d0             	movzwl %ax,%edx
  1007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007ef:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007f2:	eb 13                	jmp    100807 <debuginfo_eip+0x203>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  1007f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007f9:	e9 12 01 00 00       	jmp    100910 <debuginfo_eip+0x30c>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  1007fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100801:	83 e8 01             	sub    $0x1,%eax
  100804:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100807:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10080a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10080d:	39 c2                	cmp    %eax,%edx
  10080f:	7c 56                	jl     100867 <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
  100811:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100814:	89 c2                	mov    %eax,%edx
  100816:	89 d0                	mov    %edx,%eax
  100818:	01 c0                	add    %eax,%eax
  10081a:	01 d0                	add    %edx,%eax
  10081c:	c1 e0 02             	shl    $0x2,%eax
  10081f:	89 c2                	mov    %eax,%edx
  100821:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100824:	01 d0                	add    %edx,%eax
  100826:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10082a:	3c 84                	cmp    $0x84,%al
  10082c:	74 39                	je     100867 <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10082e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100831:	89 c2                	mov    %eax,%edx
  100833:	89 d0                	mov    %edx,%eax
  100835:	01 c0                	add    %eax,%eax
  100837:	01 d0                	add    %edx,%eax
  100839:	c1 e0 02             	shl    $0x2,%eax
  10083c:	89 c2                	mov    %eax,%edx
  10083e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100841:	01 d0                	add    %edx,%eax
  100843:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100847:	3c 64                	cmp    $0x64,%al
  100849:	75 b3                	jne    1007fe <debuginfo_eip+0x1fa>
  10084b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10084e:	89 c2                	mov    %eax,%edx
  100850:	89 d0                	mov    %edx,%eax
  100852:	01 c0                	add    %eax,%eax
  100854:	01 d0                	add    %edx,%eax
  100856:	c1 e0 02             	shl    $0x2,%eax
  100859:	89 c2                	mov    %eax,%edx
  10085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10085e:	01 d0                	add    %edx,%eax
  100860:	8b 40 08             	mov    0x8(%eax),%eax
  100863:	85 c0                	test   %eax,%eax
  100865:	74 97                	je     1007fe <debuginfo_eip+0x1fa>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100867:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10086a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10086d:	39 c2                	cmp    %eax,%edx
  10086f:	7c 46                	jl     1008b7 <debuginfo_eip+0x2b3>
  100871:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100874:	89 c2                	mov    %eax,%edx
  100876:	89 d0                	mov    %edx,%eax
  100878:	01 c0                	add    %eax,%eax
  10087a:	01 d0                	add    %edx,%eax
  10087c:	c1 e0 02             	shl    $0x2,%eax
  10087f:	89 c2                	mov    %eax,%edx
  100881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100884:	01 d0                	add    %edx,%eax
  100886:	8b 00                	mov    (%eax),%eax
  100888:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10088b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10088e:	29 d1                	sub    %edx,%ecx
  100890:	89 ca                	mov    %ecx,%edx
  100892:	39 d0                	cmp    %edx,%eax
  100894:	73 21                	jae    1008b7 <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100896:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100899:	89 c2                	mov    %eax,%edx
  10089b:	89 d0                	mov    %edx,%eax
  10089d:	01 c0                	add    %eax,%eax
  10089f:	01 d0                	add    %edx,%eax
  1008a1:	c1 e0 02             	shl    $0x2,%eax
  1008a4:	89 c2                	mov    %eax,%edx
  1008a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008a9:	01 d0                	add    %edx,%eax
  1008ab:	8b 10                	mov    (%eax),%edx
  1008ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008b0:	01 c2                	add    %eax,%edx
  1008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008b5:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008bd:	39 c2                	cmp    %eax,%edx
  1008bf:	7d 4a                	jge    10090b <debuginfo_eip+0x307>
        for (lline = lfun + 1;
  1008c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008c4:	83 c0 01             	add    $0x1,%eax
  1008c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008ca:	eb 18                	jmp    1008e4 <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008cf:	8b 40 14             	mov    0x14(%eax),%eax
  1008d2:	8d 50 01             	lea    0x1(%eax),%edx
  1008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008d8:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  1008db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008de:	83 c0 01             	add    $0x1,%eax
  1008e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  1008ea:	39 c2                	cmp    %eax,%edx
  1008ec:	7d 1d                	jge    10090b <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008f1:	89 c2                	mov    %eax,%edx
  1008f3:	89 d0                	mov    %edx,%eax
  1008f5:	01 c0                	add    %eax,%eax
  1008f7:	01 d0                	add    %edx,%eax
  1008f9:	c1 e0 02             	shl    $0x2,%eax
  1008fc:	89 c2                	mov    %eax,%edx
  1008fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100901:	01 d0                	add    %edx,%eax
  100903:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100907:	3c a0                	cmp    $0xa0,%al
  100909:	74 c1                	je     1008cc <debuginfo_eip+0x2c8>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  10090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100910:	c9                   	leave  
  100911:	c3                   	ret    

00100912 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100912:	55                   	push   %ebp
  100913:	89 e5                	mov    %esp,%ebp
  100915:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100918:	83 ec 0c             	sub    $0xc,%esp
  10091b:	68 82 5b 10 00       	push   $0x105b82
  100920:	e8 4e f9 ff ff       	call   100273 <cprintf>
  100925:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100928:	83 ec 08             	sub    $0x8,%esp
  10092b:	68 36 00 10 00       	push   $0x100036
  100930:	68 9b 5b 10 00       	push   $0x105b9b
  100935:	e8 39 f9 ff ff       	call   100273 <cprintf>
  10093a:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
  10093d:	83 ec 08             	sub    $0x8,%esp
  100940:	68 70 5a 10 00       	push   $0x105a70
  100945:	68 b3 5b 10 00       	push   $0x105bb3
  10094a:	e8 24 f9 ff ff       	call   100273 <cprintf>
  10094f:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
  100952:	83 ec 08             	sub    $0x8,%esp
  100955:	68 36 7a 11 00       	push   $0x117a36
  10095a:	68 cb 5b 10 00       	push   $0x105bcb
  10095f:	e8 0f f9 ff ff       	call   100273 <cprintf>
  100964:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
  100967:	83 ec 08             	sub    $0x8,%esp
  10096a:	68 28 af 11 00       	push   $0x11af28
  10096f:	68 e3 5b 10 00       	push   $0x105be3
  100974:	e8 fa f8 ff ff       	call   100273 <cprintf>
  100979:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  10097c:	b8 28 af 11 00       	mov    $0x11af28,%eax
  100981:	05 ff 03 00 00       	add    $0x3ff,%eax
  100986:	ba 36 00 10 00       	mov    $0x100036,%edx
  10098b:	29 d0                	sub    %edx,%eax
  10098d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100993:	85 c0                	test   %eax,%eax
  100995:	0f 48 c2             	cmovs  %edx,%eax
  100998:	c1 f8 0a             	sar    $0xa,%eax
  10099b:	83 ec 08             	sub    $0x8,%esp
  10099e:	50                   	push   %eax
  10099f:	68 fc 5b 10 00       	push   $0x105bfc
  1009a4:	e8 ca f8 ff ff       	call   100273 <cprintf>
  1009a9:	83 c4 10             	add    $0x10,%esp
}
  1009ac:	90                   	nop
  1009ad:	c9                   	leave  
  1009ae:	c3                   	ret    

001009af <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009af:	55                   	push   %ebp
  1009b0:	89 e5                	mov    %esp,%ebp
  1009b2:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009b8:	83 ec 08             	sub    $0x8,%esp
  1009bb:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009be:	50                   	push   %eax
  1009bf:	ff 75 08             	pushl  0x8(%ebp)
  1009c2:	e8 3d fc ff ff       	call   100604 <debuginfo_eip>
  1009c7:	83 c4 10             	add    $0x10,%esp
  1009ca:	85 c0                	test   %eax,%eax
  1009cc:	74 15                	je     1009e3 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009ce:	83 ec 08             	sub    $0x8,%esp
  1009d1:	ff 75 08             	pushl  0x8(%ebp)
  1009d4:	68 26 5c 10 00       	push   $0x105c26
  1009d9:	e8 95 f8 ff ff       	call   100273 <cprintf>
  1009de:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  1009e1:	eb 65                	jmp    100a48 <print_debuginfo+0x99>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009ea:	eb 1c                	jmp    100a08 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  1009ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1009ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009f2:	01 d0                	add    %edx,%eax
  1009f4:	0f b6 00             	movzbl (%eax),%eax
  1009f7:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a00:	01 ca                	add    %ecx,%edx
  100a02:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a0b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100a0e:	7f dc                	jg     1009ec <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100a10:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a19:	01 d0                	add    %edx,%eax
  100a1b:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a21:	8b 55 08             	mov    0x8(%ebp),%edx
  100a24:	89 d1                	mov    %edx,%ecx
  100a26:	29 c1                	sub    %eax,%ecx
  100a28:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a2e:	83 ec 0c             	sub    $0xc,%esp
  100a31:	51                   	push   %ecx
  100a32:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a38:	51                   	push   %ecx
  100a39:	52                   	push   %edx
  100a3a:	50                   	push   %eax
  100a3b:	68 42 5c 10 00       	push   $0x105c42
  100a40:	e8 2e f8 ff ff       	call   100273 <cprintf>
  100a45:	83 c4 20             	add    $0x20,%esp
                fnname, eip - info.eip_fn_addr);
    }
}
  100a48:	90                   	nop
  100a49:	c9                   	leave  
  100a4a:	c3                   	ret    

00100a4b <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a4b:	55                   	push   %ebp
  100a4c:	89 e5                	mov    %esp,%ebp
  100a4e:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a51:	8b 45 04             	mov    0x4(%ebp),%eax
  100a54:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a57:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a5a:	c9                   	leave  
  100a5b:	c3                   	ret    

00100a5c <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a5c:	55                   	push   %ebp
  100a5d:	89 e5                	mov    %esp,%ebp
  100a5f:	53                   	push   %ebx
  100a60:	83 ec 24             	sub    $0x24,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a63:	89 e8                	mov    %ebp,%eax
  100a65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  100a68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
  100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
  100a6e:	e8 d8 ff ff ff       	call   100a4b <read_eip>
  100a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int itr = 0; itr < STACKFRAME_DEPTH && ebp != 0; itr++) {
  100a76:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a7d:	e9 89 00 00 00       	jmp    100b0b <print_stackframe+0xaf>
        cprintf("ebp = 0x%08x, eip = 0x%08x", ebp, eip);
  100a82:	83 ec 04             	sub    $0x4,%esp
  100a85:	ff 75 f0             	pushl  -0x10(%ebp)
  100a88:	ff 75 f4             	pushl  -0xc(%ebp)
  100a8b:	68 54 5c 10 00       	push   $0x105c54
  100a90:	e8 de f7 ff ff       	call   100273 <cprintf>
  100a95:	83 c4 10             	add    $0x10,%esp
        uint32_t *ptr = (uint32_t *)(ebp + 2);
  100a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a9b:	83 c0 02             	add    $0x2,%eax
  100a9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        cprintf("arg = 0x%08x, 0x%08x, 0x%08x, 0x%08x", *(ptr), *(ptr+1), *(ptr+2), *(ptr+3));
  100aa1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100aa4:	83 c0 0c             	add    $0xc,%eax
  100aa7:	8b 18                	mov    (%eax),%ebx
  100aa9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100aac:	83 c0 08             	add    $0x8,%eax
  100aaf:	8b 08                	mov    (%eax),%ecx
  100ab1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ab4:	83 c0 04             	add    $0x4,%eax
  100ab7:	8b 10                	mov    (%eax),%edx
  100ab9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100abc:	8b 00                	mov    (%eax),%eax
  100abe:	83 ec 0c             	sub    $0xc,%esp
  100ac1:	53                   	push   %ebx
  100ac2:	51                   	push   %ecx
  100ac3:	52                   	push   %edx
  100ac4:	50                   	push   %eax
  100ac5:	68 70 5c 10 00       	push   $0x105c70
  100aca:	e8 a4 f7 ff ff       	call   100273 <cprintf>
  100acf:	83 c4 20             	add    $0x20,%esp
        cprintf("\n");
  100ad2:	83 ec 0c             	sub    $0xc,%esp
  100ad5:	68 95 5c 10 00       	push   $0x105c95
  100ada:	e8 94 f7 ff ff       	call   100273 <cprintf>
  100adf:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
  100ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100ae5:	83 e8 01             	sub    $0x1,%eax
  100ae8:	83 ec 0c             	sub    $0xc,%esp
  100aeb:	50                   	push   %eax
  100aec:	e8 be fe ff ff       	call   1009af <print_debuginfo>
  100af1:	83 c4 10             	add    $0x10,%esp

        //(3.5???)
        eip = ((uint32_t *)ebp)[1];
  100af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100af7:	83 c0 04             	add    $0x4,%eax
  100afa:	8b 00                	mov    (%eax),%eax
  100afc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b02:	8b 00                	mov    (%eax),%eax
  100b04:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
    uint32_t eip = read_eip();
    for (int itr = 0; itr < STACKFRAME_DEPTH && ebp != 0; itr++) {
  100b07:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100b0b:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b0f:	7f 0a                	jg     100b1b <print_stackframe+0xbf>
  100b11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b15:	0f 85 67 ff ff ff    	jne    100a82 <print_stackframe+0x26>

        //(3.5???)
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
  100b1b:	90                   	nop
  100b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100b1f:	c9                   	leave  
  100b20:	c3                   	ret    

00100b21 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b21:	55                   	push   %ebp
  100b22:	89 e5                	mov    %esp,%ebp
  100b24:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
  100b27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b2e:	eb 0c                	jmp    100b3c <parse+0x1b>
            *buf ++ = '\0';
  100b30:	8b 45 08             	mov    0x8(%ebp),%eax
  100b33:	8d 50 01             	lea    0x1(%eax),%edx
  100b36:	89 55 08             	mov    %edx,0x8(%ebp)
  100b39:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b3f:	0f b6 00             	movzbl (%eax),%eax
  100b42:	84 c0                	test   %al,%al
  100b44:	74 1e                	je     100b64 <parse+0x43>
  100b46:	8b 45 08             	mov    0x8(%ebp),%eax
  100b49:	0f b6 00             	movzbl (%eax),%eax
  100b4c:	0f be c0             	movsbl %al,%eax
  100b4f:	83 ec 08             	sub    $0x8,%esp
  100b52:	50                   	push   %eax
  100b53:	68 18 5d 10 00       	push   $0x105d18
  100b58:	e8 bd 45 00 00       	call   10511a <strchr>
  100b5d:	83 c4 10             	add    $0x10,%esp
  100b60:	85 c0                	test   %eax,%eax
  100b62:	75 cc                	jne    100b30 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100b64:	8b 45 08             	mov    0x8(%ebp),%eax
  100b67:	0f b6 00             	movzbl (%eax),%eax
  100b6a:	84 c0                	test   %al,%al
  100b6c:	74 69                	je     100bd7 <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b6e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b72:	75 12                	jne    100b86 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b74:	83 ec 08             	sub    $0x8,%esp
  100b77:	6a 10                	push   $0x10
  100b79:	68 1d 5d 10 00       	push   $0x105d1d
  100b7e:	e8 f0 f6 ff ff       	call   100273 <cprintf>
  100b83:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
  100b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b89:	8d 50 01             	lea    0x1(%eax),%edx
  100b8c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b96:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b99:	01 c2                	add    %eax,%edx
  100b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b9e:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100ba0:	eb 04                	jmp    100ba6 <parse+0x85>
            buf ++;
  100ba2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  100ba9:	0f b6 00             	movzbl (%eax),%eax
  100bac:	84 c0                	test   %al,%al
  100bae:	0f 84 7a ff ff ff    	je     100b2e <parse+0xd>
  100bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  100bb7:	0f b6 00             	movzbl (%eax),%eax
  100bba:	0f be c0             	movsbl %al,%eax
  100bbd:	83 ec 08             	sub    $0x8,%esp
  100bc0:	50                   	push   %eax
  100bc1:	68 18 5d 10 00       	push   $0x105d18
  100bc6:	e8 4f 45 00 00       	call   10511a <strchr>
  100bcb:	83 c4 10             	add    $0x10,%esp
  100bce:	85 c0                	test   %eax,%eax
  100bd0:	74 d0                	je     100ba2 <parse+0x81>
            buf ++;
        }
    }
  100bd2:	e9 57 ff ff ff       	jmp    100b2e <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
  100bd7:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bdb:	c9                   	leave  
  100bdc:	c3                   	ret    

00100bdd <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bdd:	55                   	push   %ebp
  100bde:	89 e5                	mov    %esp,%ebp
  100be0:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100be3:	83 ec 08             	sub    $0x8,%esp
  100be6:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100be9:	50                   	push   %eax
  100bea:	ff 75 08             	pushl  0x8(%ebp)
  100bed:	e8 2f ff ff ff       	call   100b21 <parse>
  100bf2:	83 c4 10             	add    $0x10,%esp
  100bf5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100bf8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100bfc:	75 0a                	jne    100c08 <runcmd+0x2b>
        return 0;
  100bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  100c03:	e9 83 00 00 00       	jmp    100c8b <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c0f:	eb 59                	jmp    100c6a <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c11:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c17:	89 d0                	mov    %edx,%eax
  100c19:	01 c0                	add    %eax,%eax
  100c1b:	01 d0                	add    %edx,%eax
  100c1d:	c1 e0 02             	shl    $0x2,%eax
  100c20:	05 00 70 11 00       	add    $0x117000,%eax
  100c25:	8b 00                	mov    (%eax),%eax
  100c27:	83 ec 08             	sub    $0x8,%esp
  100c2a:	51                   	push   %ecx
  100c2b:	50                   	push   %eax
  100c2c:	e8 49 44 00 00       	call   10507a <strcmp>
  100c31:	83 c4 10             	add    $0x10,%esp
  100c34:	85 c0                	test   %eax,%eax
  100c36:	75 2e                	jne    100c66 <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c3b:	89 d0                	mov    %edx,%eax
  100c3d:	01 c0                	add    %eax,%eax
  100c3f:	01 d0                	add    %edx,%eax
  100c41:	c1 e0 02             	shl    $0x2,%eax
  100c44:	05 08 70 11 00       	add    $0x117008,%eax
  100c49:	8b 10                	mov    (%eax),%edx
  100c4b:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c4e:	83 c0 04             	add    $0x4,%eax
  100c51:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c54:	83 e9 01             	sub    $0x1,%ecx
  100c57:	83 ec 04             	sub    $0x4,%esp
  100c5a:	ff 75 0c             	pushl  0xc(%ebp)
  100c5d:	50                   	push   %eax
  100c5e:	51                   	push   %ecx
  100c5f:	ff d2                	call   *%edx
  100c61:	83 c4 10             	add    $0x10,%esp
  100c64:	eb 25                	jmp    100c8b <runcmd+0xae>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c6d:	83 f8 02             	cmp    $0x2,%eax
  100c70:	76 9f                	jbe    100c11 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c72:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c75:	83 ec 08             	sub    $0x8,%esp
  100c78:	50                   	push   %eax
  100c79:	68 3b 5d 10 00       	push   $0x105d3b
  100c7e:	e8 f0 f5 ff ff       	call   100273 <cprintf>
  100c83:	83 c4 10             	add    $0x10,%esp
    return 0;
  100c86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c8b:	c9                   	leave  
  100c8c:	c3                   	ret    

00100c8d <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c8d:	55                   	push   %ebp
  100c8e:	89 e5                	mov    %esp,%ebp
  100c90:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c93:	83 ec 0c             	sub    $0xc,%esp
  100c96:	68 54 5d 10 00       	push   $0x105d54
  100c9b:	e8 d3 f5 ff ff       	call   100273 <cprintf>
  100ca0:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
  100ca3:	83 ec 0c             	sub    $0xc,%esp
  100ca6:	68 7c 5d 10 00       	push   $0x105d7c
  100cab:	e8 c3 f5 ff ff       	call   100273 <cprintf>
  100cb0:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
  100cb3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cb7:	74 0e                	je     100cc7 <kmonitor+0x3a>
        print_trapframe(tf);
  100cb9:	83 ec 0c             	sub    $0xc,%esp
  100cbc:	ff 75 08             	pushl  0x8(%ebp)
  100cbf:	e8 9e 0d 00 00       	call   101a62 <print_trapframe>
  100cc4:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cc7:	83 ec 0c             	sub    $0xc,%esp
  100cca:	68 a1 5d 10 00       	push   $0x105da1
  100ccf:	e8 43 f6 ff ff       	call   100317 <readline>
  100cd4:	83 c4 10             	add    $0x10,%esp
  100cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cde:	74 e7                	je     100cc7 <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
  100ce0:	83 ec 08             	sub    $0x8,%esp
  100ce3:	ff 75 08             	pushl  0x8(%ebp)
  100ce6:	ff 75 f4             	pushl  -0xc(%ebp)
  100ce9:	e8 ef fe ff ff       	call   100bdd <runcmd>
  100cee:	83 c4 10             	add    $0x10,%esp
  100cf1:	85 c0                	test   %eax,%eax
  100cf3:	78 02                	js     100cf7 <kmonitor+0x6a>
                break;
            }
        }
    }
  100cf5:	eb d0                	jmp    100cc7 <kmonitor+0x3a>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
  100cf7:	90                   	nop
            }
        }
    }
}
  100cf8:	90                   	nop
  100cf9:	c9                   	leave  
  100cfa:	c3                   	ret    

00100cfb <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100cfb:	55                   	push   %ebp
  100cfc:	89 e5                	mov    %esp,%ebp
  100cfe:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d08:	eb 3c                	jmp    100d46 <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d0d:	89 d0                	mov    %edx,%eax
  100d0f:	01 c0                	add    %eax,%eax
  100d11:	01 d0                	add    %edx,%eax
  100d13:	c1 e0 02             	shl    $0x2,%eax
  100d16:	05 04 70 11 00       	add    $0x117004,%eax
  100d1b:	8b 08                	mov    (%eax),%ecx
  100d1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d20:	89 d0                	mov    %edx,%eax
  100d22:	01 c0                	add    %eax,%eax
  100d24:	01 d0                	add    %edx,%eax
  100d26:	c1 e0 02             	shl    $0x2,%eax
  100d29:	05 00 70 11 00       	add    $0x117000,%eax
  100d2e:	8b 00                	mov    (%eax),%eax
  100d30:	83 ec 04             	sub    $0x4,%esp
  100d33:	51                   	push   %ecx
  100d34:	50                   	push   %eax
  100d35:	68 a5 5d 10 00       	push   $0x105da5
  100d3a:	e8 34 f5 ff ff       	call   100273 <cprintf>
  100d3f:	83 c4 10             	add    $0x10,%esp

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d42:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d49:	83 f8 02             	cmp    $0x2,%eax
  100d4c:	76 bc                	jbe    100d0a <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100d4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d53:	c9                   	leave  
  100d54:	c3                   	ret    

00100d55 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d55:	55                   	push   %ebp
  100d56:	89 e5                	mov    %esp,%ebp
  100d58:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d5b:	e8 b2 fb ff ff       	call   100912 <print_kerninfo>
    return 0;
  100d60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d65:	c9                   	leave  
  100d66:	c3                   	ret    

00100d67 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d67:	55                   	push   %ebp
  100d68:	89 e5                	mov    %esp,%ebp
  100d6a:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d6d:	e8 ea fc ff ff       	call   100a5c <print_stackframe>
    return 0;
  100d72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d77:	c9                   	leave  
  100d78:	c3                   	ret    

00100d79 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d79:	55                   	push   %ebp
  100d7a:	89 e5                	mov    %esp,%ebp
  100d7c:	83 ec 18             	sub    $0x18,%esp
  100d7f:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d85:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100d89:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  100d8d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d91:	ee                   	out    %al,(%dx)
  100d92:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
  100d98:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
  100d9c:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  100da0:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
  100da4:	ee                   	out    %al,(%dx)
  100da5:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dab:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
  100daf:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100db3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100db7:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100db8:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100dbf:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dc2:	83 ec 0c             	sub    $0xc,%esp
  100dc5:	68 ae 5d 10 00       	push   $0x105dae
  100dca:	e8 a4 f4 ff ff       	call   100273 <cprintf>
  100dcf:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
  100dd2:	83 ec 0c             	sub    $0xc,%esp
  100dd5:	6a 00                	push   $0x0
  100dd7:	e8 3b 09 00 00       	call   101717 <pic_enable>
  100ddc:	83 c4 10             	add    $0x10,%esp
}
  100ddf:	90                   	nop
  100de0:	c9                   	leave  
  100de1:	c3                   	ret    

00100de2 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100de2:	55                   	push   %ebp
  100de3:	89 e5                	mov    %esp,%ebp
  100de5:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100de8:	9c                   	pushf  
  100de9:	58                   	pop    %eax
  100dea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100df0:	25 00 02 00 00       	and    $0x200,%eax
  100df5:	85 c0                	test   %eax,%eax
  100df7:	74 0c                	je     100e05 <__intr_save+0x23>
        intr_disable();
  100df9:	e8 8a 0a 00 00       	call   101888 <intr_disable>
        return 1;
  100dfe:	b8 01 00 00 00       	mov    $0x1,%eax
  100e03:	eb 05                	jmp    100e0a <__intr_save+0x28>
    }
    return 0;
  100e05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e0a:	c9                   	leave  
  100e0b:	c3                   	ret    

00100e0c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e0c:	55                   	push   %ebp
  100e0d:	89 e5                	mov    %esp,%ebp
  100e0f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e16:	74 05                	je     100e1d <__intr_restore+0x11>
        intr_enable();
  100e18:	e8 64 0a 00 00       	call   101881 <intr_enable>
    }
}
  100e1d:	90                   	nop
  100e1e:	c9                   	leave  
  100e1f:	c3                   	ret    

00100e20 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e20:	55                   	push   %ebp
  100e21:	89 e5                	mov    %esp,%ebp
  100e23:	83 ec 10             	sub    $0x10,%esp
  100e26:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e2c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e30:	89 c2                	mov    %eax,%edx
  100e32:	ec                   	in     (%dx),%al
  100e33:	88 45 f4             	mov    %al,-0xc(%ebp)
  100e36:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
  100e3c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
  100e40:	89 c2                	mov    %eax,%edx
  100e42:	ec                   	in     (%dx),%al
  100e43:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e46:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e4c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e50:	89 c2                	mov    %eax,%edx
  100e52:	ec                   	in     (%dx),%al
  100e53:	88 45 f6             	mov    %al,-0xa(%ebp)
  100e56:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
  100e5c:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
  100e60:	89 c2                	mov    %eax,%edx
  100e62:	ec                   	in     (%dx),%al
  100e63:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e66:	90                   	nop
  100e67:	c9                   	leave  
  100e68:	c3                   	ret    

00100e69 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e69:	55                   	push   %ebp
  100e6a:	89 e5                	mov    %esp,%ebp
  100e6c:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e6f:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e76:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e79:	0f b7 00             	movzwl (%eax),%eax
  100e7c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e80:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e83:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100e88:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e8b:	0f b7 00             	movzwl (%eax),%eax
  100e8e:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e92:	74 12                	je     100ea6 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100e94:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100e9b:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100ea2:	b4 03 
  100ea4:	eb 13                	jmp    100eb9 <cga_init+0x50>
    } else {
        *cp = was;
  100ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ead:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100eb0:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100eb7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100eb9:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ec0:	0f b7 c0             	movzwl %ax,%eax
  100ec3:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  100ec7:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ecb:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  100ecf:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
  100ed3:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ed4:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100edb:	83 c0 01             	add    $0x1,%eax
  100ede:	0f b7 c0             	movzwl %ax,%eax
  100ee1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ee5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ee9:	89 c2                	mov    %eax,%edx
  100eeb:	ec                   	in     (%dx),%al
  100eec:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  100eef:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  100ef3:	0f b6 c0             	movzbl %al,%eax
  100ef6:	c1 e0 08             	shl    $0x8,%eax
  100ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100efc:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f03:	0f b7 c0             	movzwl %ax,%eax
  100f06:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
  100f0a:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f0e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
  100f12:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  100f16:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f17:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f1e:	83 c0 01             	add    $0x1,%eax
  100f21:	0f b7 c0             	movzwl %ax,%eax
  100f24:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f28:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f2c:	89 c2                	mov    %eax,%edx
  100f2e:	ec                   	in     (%dx),%al
  100f2f:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f32:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f36:	0f b6 c0             	movzbl %al,%eax
  100f39:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f3f:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f47:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f4d:	90                   	nop
  100f4e:	c9                   	leave  
  100f4f:	c3                   	ret    

00100f50 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f50:	55                   	push   %ebp
  100f51:	89 e5                	mov    %esp,%ebp
  100f53:	83 ec 28             	sub    $0x28,%esp
  100f56:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f5c:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f60:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  100f64:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f68:	ee                   	out    %al,(%dx)
  100f69:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
  100f6f:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
  100f73:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  100f77:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
  100f7b:	ee                   	out    %al,(%dx)
  100f7c:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
  100f82:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
  100f86:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  100f8a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f8e:	ee                   	out    %al,(%dx)
  100f8f:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
  100f95:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100f99:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f9d:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  100fa1:	ee                   	out    %al,(%dx)
  100fa2:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
  100fa8:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
  100fac:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  100fb0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fb4:	ee                   	out    %al,(%dx)
  100fb5:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
  100fbb:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  100fbf:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  100fc3:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
  100fc7:	ee                   	out    %al,(%dx)
  100fc8:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fce:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
  100fd2:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  100fd6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fda:	ee                   	out    %al,(%dx)
  100fdb:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100fe1:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
  100fe5:	89 c2                	mov    %eax,%edx
  100fe7:	ec                   	in     (%dx),%al
  100fe8:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
  100feb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100fef:	3c ff                	cmp    $0xff,%al
  100ff1:	0f 95 c0             	setne  %al
  100ff4:	0f b6 c0             	movzbl %al,%eax
  100ff7:	a3 48 a4 11 00       	mov    %eax,0x11a448
  100ffc:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101002:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  101006:	89 c2                	mov    %eax,%edx
  101008:	ec                   	in     (%dx),%al
  101009:	88 45 e2             	mov    %al,-0x1e(%ebp)
  10100c:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
  101012:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
  101016:	89 c2                	mov    %eax,%edx
  101018:	ec                   	in     (%dx),%al
  101019:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  10101c:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101021:	85 c0                	test   %eax,%eax
  101023:	74 0d                	je     101032 <serial_init+0xe2>
        pic_enable(IRQ_COM1);
  101025:	83 ec 0c             	sub    $0xc,%esp
  101028:	6a 04                	push   $0x4
  10102a:	e8 e8 06 00 00       	call   101717 <pic_enable>
  10102f:	83 c4 10             	add    $0x10,%esp
    }
}
  101032:	90                   	nop
  101033:	c9                   	leave  
  101034:	c3                   	ret    

00101035 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101035:	55                   	push   %ebp
  101036:	89 e5                	mov    %esp,%ebp
  101038:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10103b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101042:	eb 09                	jmp    10104d <lpt_putc_sub+0x18>
        delay();
  101044:	e8 d7 fd ff ff       	call   100e20 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101049:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10104d:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
  101053:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  101057:	89 c2                	mov    %eax,%edx
  101059:	ec                   	in     (%dx),%al
  10105a:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
  10105d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101061:	84 c0                	test   %al,%al
  101063:	78 09                	js     10106e <lpt_putc_sub+0x39>
  101065:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10106c:	7e d6                	jle    101044 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  10106e:	8b 45 08             	mov    0x8(%ebp),%eax
  101071:	0f b6 c0             	movzbl %al,%eax
  101074:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
  10107a:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10107d:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  101081:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
  101085:	ee                   	out    %al,(%dx)
  101086:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  10108c:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101090:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101094:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101098:	ee                   	out    %al,(%dx)
  101099:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
  10109f:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
  1010a3:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  1010a7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1010ab:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010ac:	90                   	nop
  1010ad:	c9                   	leave  
  1010ae:	c3                   	ret    

001010af <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010af:	55                   	push   %ebp
  1010b0:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
  1010b2:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010b6:	74 0d                	je     1010c5 <lpt_putc+0x16>
        lpt_putc_sub(c);
  1010b8:	ff 75 08             	pushl  0x8(%ebp)
  1010bb:	e8 75 ff ff ff       	call   101035 <lpt_putc_sub>
  1010c0:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010c3:	eb 1e                	jmp    1010e3 <lpt_putc+0x34>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
  1010c5:	6a 08                	push   $0x8
  1010c7:	e8 69 ff ff ff       	call   101035 <lpt_putc_sub>
  1010cc:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
  1010cf:	6a 20                	push   $0x20
  1010d1:	e8 5f ff ff ff       	call   101035 <lpt_putc_sub>
  1010d6:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
  1010d9:	6a 08                	push   $0x8
  1010db:	e8 55 ff ff ff       	call   101035 <lpt_putc_sub>
  1010e0:	83 c4 04             	add    $0x4,%esp
    }
}
  1010e3:	90                   	nop
  1010e4:	c9                   	leave  
  1010e5:	c3                   	ret    

001010e6 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010e6:	55                   	push   %ebp
  1010e7:	89 e5                	mov    %esp,%ebp
  1010e9:	53                   	push   %ebx
  1010ea:	83 ec 14             	sub    $0x14,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1010f0:	b0 00                	mov    $0x0,%al
  1010f2:	85 c0                	test   %eax,%eax
  1010f4:	75 07                	jne    1010fd <cga_putc+0x17>
        c |= 0x0700;
  1010f6:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  101100:	0f b6 c0             	movzbl %al,%eax
  101103:	83 f8 0a             	cmp    $0xa,%eax
  101106:	74 4e                	je     101156 <cga_putc+0x70>
  101108:	83 f8 0d             	cmp    $0xd,%eax
  10110b:	74 59                	je     101166 <cga_putc+0x80>
  10110d:	83 f8 08             	cmp    $0x8,%eax
  101110:	0f 85 8a 00 00 00    	jne    1011a0 <cga_putc+0xba>
    case '\b':
        if (crt_pos > 0) {
  101116:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10111d:	66 85 c0             	test   %ax,%ax
  101120:	0f 84 a0 00 00 00    	je     1011c6 <cga_putc+0xe0>
            crt_pos --;
  101126:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10112d:	83 e8 01             	sub    $0x1,%eax
  101130:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101136:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10113b:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  101142:	0f b7 d2             	movzwl %dx,%edx
  101145:	01 d2                	add    %edx,%edx
  101147:	01 d0                	add    %edx,%eax
  101149:	8b 55 08             	mov    0x8(%ebp),%edx
  10114c:	b2 00                	mov    $0x0,%dl
  10114e:	83 ca 20             	or     $0x20,%edx
  101151:	66 89 10             	mov    %dx,(%eax)
        }
        break;
  101154:	eb 70                	jmp    1011c6 <cga_putc+0xe0>
    case '\n':
        crt_pos += CRT_COLS;
  101156:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10115d:	83 c0 50             	add    $0x50,%eax
  101160:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101166:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  10116d:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  101174:	0f b7 c1             	movzwl %cx,%eax
  101177:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  10117d:	c1 e8 10             	shr    $0x10,%eax
  101180:	89 c2                	mov    %eax,%edx
  101182:	66 c1 ea 06          	shr    $0x6,%dx
  101186:	89 d0                	mov    %edx,%eax
  101188:	c1 e0 02             	shl    $0x2,%eax
  10118b:	01 d0                	add    %edx,%eax
  10118d:	c1 e0 04             	shl    $0x4,%eax
  101190:	29 c1                	sub    %eax,%ecx
  101192:	89 ca                	mov    %ecx,%edx
  101194:	89 d8                	mov    %ebx,%eax
  101196:	29 d0                	sub    %edx,%eax
  101198:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  10119e:	eb 27                	jmp    1011c7 <cga_putc+0xe1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011a0:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011a6:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011ad:	8d 50 01             	lea    0x1(%eax),%edx
  1011b0:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011b7:	0f b7 c0             	movzwl %ax,%eax
  1011ba:	01 c0                	add    %eax,%eax
  1011bc:	01 c8                	add    %ecx,%eax
  1011be:	8b 55 08             	mov    0x8(%ebp),%edx
  1011c1:	66 89 10             	mov    %dx,(%eax)
        break;
  1011c4:	eb 01                	jmp    1011c7 <cga_putc+0xe1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
  1011c6:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011c7:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011ce:	66 3d cf 07          	cmp    $0x7cf,%ax
  1011d2:	76 59                	jbe    10122d <cga_putc+0x147>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011d4:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011d9:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011df:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011e4:	83 ec 04             	sub    $0x4,%esp
  1011e7:	68 00 0f 00 00       	push   $0xf00
  1011ec:	52                   	push   %edx
  1011ed:	50                   	push   %eax
  1011ee:	e8 26 41 00 00       	call   105319 <memmove>
  1011f3:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011f6:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1011fd:	eb 15                	jmp    101214 <cga_putc+0x12e>
            crt_buf[i] = 0x0700 | ' ';
  1011ff:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101204:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101207:	01 d2                	add    %edx,%edx
  101209:	01 d0                	add    %edx,%eax
  10120b:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101210:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101214:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10121b:	7e e2                	jle    1011ff <cga_putc+0x119>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  10121d:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101224:	83 e8 50             	sub    $0x50,%eax
  101227:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10122d:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101234:	0f b7 c0             	movzwl %ax,%eax
  101237:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  10123b:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
  10123f:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
  101243:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101247:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101248:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10124f:	66 c1 e8 08          	shr    $0x8,%ax
  101253:	0f b6 c0             	movzbl %al,%eax
  101256:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  10125d:	83 c2 01             	add    $0x1,%edx
  101260:	0f b7 d2             	movzwl %dx,%edx
  101263:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
  101267:	88 45 e9             	mov    %al,-0x17(%ebp)
  10126a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10126e:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  101272:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101273:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  10127a:	0f b7 c0             	movzwl %ax,%eax
  10127d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  101281:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
  101285:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  101289:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10128d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10128e:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101295:	0f b6 c0             	movzbl %al,%eax
  101298:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  10129f:	83 c2 01             	add    $0x1,%edx
  1012a2:	0f b7 d2             	movzwl %dx,%edx
  1012a5:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
  1012a9:	88 45 eb             	mov    %al,-0x15(%ebp)
  1012ac:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  1012b0:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
  1012b4:	ee                   	out    %al,(%dx)
}
  1012b5:	90                   	nop
  1012b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1012b9:	c9                   	leave  
  1012ba:	c3                   	ret    

001012bb <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012bb:	55                   	push   %ebp
  1012bc:	89 e5                	mov    %esp,%ebp
  1012be:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012c8:	eb 09                	jmp    1012d3 <serial_putc_sub+0x18>
        delay();
  1012ca:	e8 51 fb ff ff       	call   100e20 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012cf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1012d3:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012d9:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
  1012dd:	89 c2                	mov    %eax,%edx
  1012df:	ec                   	in     (%dx),%al
  1012e0:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  1012e3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1012e7:	0f b6 c0             	movzbl %al,%eax
  1012ea:	83 e0 20             	and    $0x20,%eax
  1012ed:	85 c0                	test   %eax,%eax
  1012ef:	75 09                	jne    1012fa <serial_putc_sub+0x3f>
  1012f1:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1012f8:	7e d0                	jle    1012ca <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  1012fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1012fd:	0f b6 c0             	movzbl %al,%eax
  101300:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
  101306:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101309:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
  10130d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101311:	ee                   	out    %al,(%dx)
}
  101312:	90                   	nop
  101313:	c9                   	leave  
  101314:	c3                   	ret    

00101315 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101315:	55                   	push   %ebp
  101316:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
  101318:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10131c:	74 0d                	je     10132b <serial_putc+0x16>
        serial_putc_sub(c);
  10131e:	ff 75 08             	pushl  0x8(%ebp)
  101321:	e8 95 ff ff ff       	call   1012bb <serial_putc_sub>
  101326:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  101329:	eb 1e                	jmp    101349 <serial_putc+0x34>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
  10132b:	6a 08                	push   $0x8
  10132d:	e8 89 ff ff ff       	call   1012bb <serial_putc_sub>
  101332:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
  101335:	6a 20                	push   $0x20
  101337:	e8 7f ff ff ff       	call   1012bb <serial_putc_sub>
  10133c:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
  10133f:	6a 08                	push   $0x8
  101341:	e8 75 ff ff ff       	call   1012bb <serial_putc_sub>
  101346:	83 c4 04             	add    $0x4,%esp
    }
}
  101349:	90                   	nop
  10134a:	c9                   	leave  
  10134b:	c3                   	ret    

0010134c <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10134c:	55                   	push   %ebp
  10134d:	89 e5                	mov    %esp,%ebp
  10134f:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101352:	eb 33                	jmp    101387 <cons_intr+0x3b>
        if (c != 0) {
  101354:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101358:	74 2d                	je     101387 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10135a:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10135f:	8d 50 01             	lea    0x1(%eax),%edx
  101362:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  101368:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10136b:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101371:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101376:	3d 00 02 00 00       	cmp    $0x200,%eax
  10137b:	75 0a                	jne    101387 <cons_intr+0x3b>
                cons.wpos = 0;
  10137d:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  101384:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  101387:	8b 45 08             	mov    0x8(%ebp),%eax
  10138a:	ff d0                	call   *%eax
  10138c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10138f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101393:	75 bf                	jne    101354 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  101395:	90                   	nop
  101396:	c9                   	leave  
  101397:	c3                   	ret    

00101398 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101398:	55                   	push   %ebp
  101399:	89 e5                	mov    %esp,%ebp
  10139b:	83 ec 10             	sub    $0x10,%esp
  10139e:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013a4:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
  1013a8:	89 c2                	mov    %eax,%edx
  1013aa:	ec                   	in     (%dx),%al
  1013ab:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  1013ae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013b2:	0f b6 c0             	movzbl %al,%eax
  1013b5:	83 e0 01             	and    $0x1,%eax
  1013b8:	85 c0                	test   %eax,%eax
  1013ba:	75 07                	jne    1013c3 <serial_proc_data+0x2b>
        return -1;
  1013bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013c1:	eb 2a                	jmp    1013ed <serial_proc_data+0x55>
  1013c3:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013c9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013cd:	89 c2                	mov    %eax,%edx
  1013cf:	ec                   	in     (%dx),%al
  1013d0:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
  1013d3:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013d7:	0f b6 c0             	movzbl %al,%eax
  1013da:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013dd:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013e1:	75 07                	jne    1013ea <serial_proc_data+0x52>
        c = '\b';
  1013e3:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1013ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1013ed:	c9                   	leave  
  1013ee:	c3                   	ret    

001013ef <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1013ef:	55                   	push   %ebp
  1013f0:	89 e5                	mov    %esp,%ebp
  1013f2:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
  1013f5:	a1 48 a4 11 00       	mov    0x11a448,%eax
  1013fa:	85 c0                	test   %eax,%eax
  1013fc:	74 10                	je     10140e <serial_intr+0x1f>
        cons_intr(serial_proc_data);
  1013fe:	83 ec 0c             	sub    $0xc,%esp
  101401:	68 98 13 10 00       	push   $0x101398
  101406:	e8 41 ff ff ff       	call   10134c <cons_intr>
  10140b:	83 c4 10             	add    $0x10,%esp
    }
}
  10140e:	90                   	nop
  10140f:	c9                   	leave  
  101410:	c3                   	ret    

00101411 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101411:	55                   	push   %ebp
  101412:	89 e5                	mov    %esp,%ebp
  101414:	83 ec 18             	sub    $0x18,%esp
  101417:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10141d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101421:	89 c2                	mov    %eax,%edx
  101423:	ec                   	in     (%dx),%al
  101424:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101427:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10142b:	0f b6 c0             	movzbl %al,%eax
  10142e:	83 e0 01             	and    $0x1,%eax
  101431:	85 c0                	test   %eax,%eax
  101433:	75 0a                	jne    10143f <kbd_proc_data+0x2e>
        return -1;
  101435:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10143a:	e9 5d 01 00 00       	jmp    10159c <kbd_proc_data+0x18b>
  10143f:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101445:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101449:	89 c2                	mov    %eax,%edx
  10144b:	ec                   	in     (%dx),%al
  10144c:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
  10144f:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
  101453:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101456:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10145a:	75 17                	jne    101473 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  10145c:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101461:	83 c8 40             	or     $0x40,%eax
  101464:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  101469:	b8 00 00 00 00       	mov    $0x0,%eax
  10146e:	e9 29 01 00 00       	jmp    10159c <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
  101473:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101477:	84 c0                	test   %al,%al
  101479:	79 47                	jns    1014c2 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10147b:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101480:	83 e0 40             	and    $0x40,%eax
  101483:	85 c0                	test   %eax,%eax
  101485:	75 09                	jne    101490 <kbd_proc_data+0x7f>
  101487:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10148b:	83 e0 7f             	and    $0x7f,%eax
  10148e:	eb 04                	jmp    101494 <kbd_proc_data+0x83>
  101490:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101494:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101497:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10149b:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014a2:	83 c8 40             	or     $0x40,%eax
  1014a5:	0f b6 c0             	movzbl %al,%eax
  1014a8:	f7 d0                	not    %eax
  1014aa:	89 c2                	mov    %eax,%edx
  1014ac:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014b1:	21 d0                	and    %edx,%eax
  1014b3:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014b8:	b8 00 00 00 00       	mov    $0x0,%eax
  1014bd:	e9 da 00 00 00       	jmp    10159c <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
  1014c2:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014c7:	83 e0 40             	and    $0x40,%eax
  1014ca:	85 c0                	test   %eax,%eax
  1014cc:	74 11                	je     1014df <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014ce:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014d2:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014d7:	83 e0 bf             	and    $0xffffffbf,%eax
  1014da:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  1014df:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014e3:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014ea:	0f b6 d0             	movzbl %al,%edx
  1014ed:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014f2:	09 d0                	or     %edx,%eax
  1014f4:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  1014f9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014fd:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101504:	0f b6 d0             	movzbl %al,%edx
  101507:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10150c:	31 d0                	xor    %edx,%eax
  10150e:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  101513:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101518:	83 e0 03             	and    $0x3,%eax
  10151b:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  101522:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101526:	01 d0                	add    %edx,%eax
  101528:	0f b6 00             	movzbl (%eax),%eax
  10152b:	0f b6 c0             	movzbl %al,%eax
  10152e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101531:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101536:	83 e0 08             	and    $0x8,%eax
  101539:	85 c0                	test   %eax,%eax
  10153b:	74 22                	je     10155f <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  10153d:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101541:	7e 0c                	jle    10154f <kbd_proc_data+0x13e>
  101543:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101547:	7f 06                	jg     10154f <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101549:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10154d:	eb 10                	jmp    10155f <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  10154f:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101553:	7e 0a                	jle    10155f <kbd_proc_data+0x14e>
  101555:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101559:	7f 04                	jg     10155f <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  10155b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10155f:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101564:	f7 d0                	not    %eax
  101566:	83 e0 06             	and    $0x6,%eax
  101569:	85 c0                	test   %eax,%eax
  10156b:	75 2c                	jne    101599 <kbd_proc_data+0x188>
  10156d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101574:	75 23                	jne    101599 <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
  101576:	83 ec 0c             	sub    $0xc,%esp
  101579:	68 c9 5d 10 00       	push   $0x105dc9
  10157e:	e8 f0 ec ff ff       	call   100273 <cprintf>
  101583:	83 c4 10             	add    $0x10,%esp
  101586:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
  10158c:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101590:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101594:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101598:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101599:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10159c:	c9                   	leave  
  10159d:	c3                   	ret    

0010159e <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10159e:	55                   	push   %ebp
  10159f:	89 e5                	mov    %esp,%ebp
  1015a1:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
  1015a4:	83 ec 0c             	sub    $0xc,%esp
  1015a7:	68 11 14 10 00       	push   $0x101411
  1015ac:	e8 9b fd ff ff       	call   10134c <cons_intr>
  1015b1:	83 c4 10             	add    $0x10,%esp
}
  1015b4:	90                   	nop
  1015b5:	c9                   	leave  
  1015b6:	c3                   	ret    

001015b7 <kbd_init>:

static void
kbd_init(void) {
  1015b7:	55                   	push   %ebp
  1015b8:	89 e5                	mov    %esp,%ebp
  1015ba:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
  1015bd:	e8 dc ff ff ff       	call   10159e <kbd_intr>
    pic_enable(IRQ_KBD);
  1015c2:	83 ec 0c             	sub    $0xc,%esp
  1015c5:	6a 01                	push   $0x1
  1015c7:	e8 4b 01 00 00       	call   101717 <pic_enable>
  1015cc:	83 c4 10             	add    $0x10,%esp
}
  1015cf:	90                   	nop
  1015d0:	c9                   	leave  
  1015d1:	c3                   	ret    

001015d2 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015d2:	55                   	push   %ebp
  1015d3:	89 e5                	mov    %esp,%ebp
  1015d5:	83 ec 08             	sub    $0x8,%esp
    cga_init();
  1015d8:	e8 8c f8 ff ff       	call   100e69 <cga_init>
    serial_init();
  1015dd:	e8 6e f9 ff ff       	call   100f50 <serial_init>
    kbd_init();
  1015e2:	e8 d0 ff ff ff       	call   1015b7 <kbd_init>
    if (!serial_exists) {
  1015e7:	a1 48 a4 11 00       	mov    0x11a448,%eax
  1015ec:	85 c0                	test   %eax,%eax
  1015ee:	75 10                	jne    101600 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
  1015f0:	83 ec 0c             	sub    $0xc,%esp
  1015f3:	68 d5 5d 10 00       	push   $0x105dd5
  1015f8:	e8 76 ec ff ff       	call   100273 <cprintf>
  1015fd:	83 c4 10             	add    $0x10,%esp
    }
}
  101600:	90                   	nop
  101601:	c9                   	leave  
  101602:	c3                   	ret    

00101603 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101603:	55                   	push   %ebp
  101604:	89 e5                	mov    %esp,%ebp
  101606:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101609:	e8 d4 f7 ff ff       	call   100de2 <__intr_save>
  10160e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101611:	83 ec 0c             	sub    $0xc,%esp
  101614:	ff 75 08             	pushl  0x8(%ebp)
  101617:	e8 93 fa ff ff       	call   1010af <lpt_putc>
  10161c:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
  10161f:	83 ec 0c             	sub    $0xc,%esp
  101622:	ff 75 08             	pushl  0x8(%ebp)
  101625:	e8 bc fa ff ff       	call   1010e6 <cga_putc>
  10162a:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
  10162d:	83 ec 0c             	sub    $0xc,%esp
  101630:	ff 75 08             	pushl  0x8(%ebp)
  101633:	e8 dd fc ff ff       	call   101315 <serial_putc>
  101638:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
  10163b:	83 ec 0c             	sub    $0xc,%esp
  10163e:	ff 75 f4             	pushl  -0xc(%ebp)
  101641:	e8 c6 f7 ff ff       	call   100e0c <__intr_restore>
  101646:	83 c4 10             	add    $0x10,%esp
}
  101649:	90                   	nop
  10164a:	c9                   	leave  
  10164b:	c3                   	ret    

0010164c <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  10164c:	55                   	push   %ebp
  10164d:	89 e5                	mov    %esp,%ebp
  10164f:	83 ec 18             	sub    $0x18,%esp
    int c = 0;
  101652:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101659:	e8 84 f7 ff ff       	call   100de2 <__intr_save>
  10165e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101661:	e8 89 fd ff ff       	call   1013ef <serial_intr>
        kbd_intr();
  101666:	e8 33 ff ff ff       	call   10159e <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  10166b:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  101671:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101676:	39 c2                	cmp    %eax,%edx
  101678:	74 31                	je     1016ab <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10167a:	a1 60 a6 11 00       	mov    0x11a660,%eax
  10167f:	8d 50 01             	lea    0x1(%eax),%edx
  101682:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  101688:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  10168f:	0f b6 c0             	movzbl %al,%eax
  101692:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101695:	a1 60 a6 11 00       	mov    0x11a660,%eax
  10169a:	3d 00 02 00 00       	cmp    $0x200,%eax
  10169f:	75 0a                	jne    1016ab <cons_getc+0x5f>
                cons.rpos = 0;
  1016a1:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016a8:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016ab:	83 ec 0c             	sub    $0xc,%esp
  1016ae:	ff 75 f0             	pushl  -0x10(%ebp)
  1016b1:	e8 56 f7 ff ff       	call   100e0c <__intr_restore>
  1016b6:	83 c4 10             	add    $0x10,%esp
    return c;
  1016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016bc:	c9                   	leave  
  1016bd:	c3                   	ret    

001016be <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016be:	55                   	push   %ebp
  1016bf:	89 e5                	mov    %esp,%ebp
  1016c1:	83 ec 14             	sub    $0x14,%esp
  1016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1016c7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016cb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016cf:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016d5:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  1016da:	85 c0                	test   %eax,%eax
  1016dc:	74 36                	je     101714 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016de:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016e2:	0f b6 c0             	movzbl %al,%eax
  1016e5:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016eb:	88 45 fa             	mov    %al,-0x6(%ebp)
  1016ee:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
  1016f2:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016f6:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  1016f7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016fb:	66 c1 e8 08          	shr    $0x8,%ax
  1016ff:	0f b6 c0             	movzbl %al,%eax
  101702:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  101708:	88 45 fb             	mov    %al,-0x5(%ebp)
  10170b:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  10170f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
  101713:	ee                   	out    %al,(%dx)
    }
}
  101714:	90                   	nop
  101715:	c9                   	leave  
  101716:	c3                   	ret    

00101717 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101717:	55                   	push   %ebp
  101718:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
  10171a:	8b 45 08             	mov    0x8(%ebp),%eax
  10171d:	ba 01 00 00 00       	mov    $0x1,%edx
  101722:	89 c1                	mov    %eax,%ecx
  101724:	d3 e2                	shl    %cl,%edx
  101726:	89 d0                	mov    %edx,%eax
  101728:	f7 d0                	not    %eax
  10172a:	89 c2                	mov    %eax,%edx
  10172c:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101733:	21 d0                	and    %edx,%eax
  101735:	0f b7 c0             	movzwl %ax,%eax
  101738:	50                   	push   %eax
  101739:	e8 80 ff ff ff       	call   1016be <pic_setmask>
  10173e:	83 c4 04             	add    $0x4,%esp
}
  101741:	90                   	nop
  101742:	c9                   	leave  
  101743:	c3                   	ret    

00101744 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101744:	55                   	push   %ebp
  101745:	89 e5                	mov    %esp,%ebp
  101747:	83 ec 30             	sub    $0x30,%esp
    did_init = 1;
  10174a:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  101751:	00 00 00 
  101754:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10175a:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
  10175e:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
  101762:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101766:	ee                   	out    %al,(%dx)
  101767:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  10176d:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
  101771:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
  101775:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
  101779:	ee                   	out    %al,(%dx)
  10177a:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
  101780:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
  101784:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
  101788:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10178c:	ee                   	out    %al,(%dx)
  10178d:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
  101793:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
  101797:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10179b:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
  10179f:	ee                   	out    %al,(%dx)
  1017a0:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
  1017a6:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
  1017aa:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  1017ae:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017b2:	ee                   	out    %al,(%dx)
  1017b3:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
  1017b9:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
  1017bd:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  1017c1:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
  1017c5:	ee                   	out    %al,(%dx)
  1017c6:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
  1017cc:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
  1017d0:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  1017d4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017d8:	ee                   	out    %al,(%dx)
  1017d9:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
  1017df:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
  1017e3:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017e7:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  1017eb:	ee                   	out    %al,(%dx)
  1017ec:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  1017f2:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
  1017f6:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  1017fa:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017fe:	ee                   	out    %al,(%dx)
  1017ff:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
  101805:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
  101809:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  10180d:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
  101811:	ee                   	out    %al,(%dx)
  101812:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
  101818:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
  10181c:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  101820:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101824:	ee                   	out    %al,(%dx)
  101825:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
  10182b:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
  10182f:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101833:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  101837:	ee                   	out    %al,(%dx)
  101838:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  10183e:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
  101842:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
  101846:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10184a:	ee                   	out    %al,(%dx)
  10184b:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
  101851:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
  101855:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  101859:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
  10185d:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10185e:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101865:	66 83 f8 ff          	cmp    $0xffff,%ax
  101869:	74 13                	je     10187e <pic_init+0x13a>
        pic_setmask(irq_mask);
  10186b:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101872:	0f b7 c0             	movzwl %ax,%eax
  101875:	50                   	push   %eax
  101876:	e8 43 fe ff ff       	call   1016be <pic_setmask>
  10187b:	83 c4 04             	add    $0x4,%esp
    }
}
  10187e:	90                   	nop
  10187f:	c9                   	leave  
  101880:	c3                   	ret    

00101881 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101881:	55                   	push   %ebp
  101882:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  101884:	fb                   	sti    
    sti();
}
  101885:	90                   	nop
  101886:	5d                   	pop    %ebp
  101887:	c3                   	ret    

00101888 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101888:	55                   	push   %ebp
  101889:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  10188b:	fa                   	cli    
    cli();
}
  10188c:	90                   	nop
  10188d:	5d                   	pop    %ebp
  10188e:	c3                   	ret    

0010188f <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10188f:	55                   	push   %ebp
  101890:	89 e5                	mov    %esp,%ebp
  101892:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101895:	83 ec 08             	sub    $0x8,%esp
  101898:	6a 64                	push   $0x64
  10189a:	68 00 5e 10 00       	push   $0x105e00
  10189f:	e8 cf e9 ff ff       	call   100273 <cprintf>
  1018a4:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1018a7:	90                   	nop
  1018a8:	c9                   	leave  
  1018a9:	c3                   	ret    

001018aa <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018aa:	55                   	push   %ebp
  1018ab:	89 e5                	mov    %esp,%ebp
  1018ad:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) {
  1018b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018b7:	e9 c3 00 00 00       	jmp    10197f <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018bf:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018c6:	89 c2                	mov    %eax,%edx
  1018c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018cb:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  1018d2:	00 
  1018d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d6:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  1018dd:	00 08 00 
  1018e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e3:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018ea:	00 
  1018eb:	83 e2 e0             	and    $0xffffffe0,%edx
  1018ee:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  1018f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f8:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018ff:	00 
  101900:	83 e2 1f             	and    $0x1f,%edx
  101903:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  10190a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190d:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101914:	00 
  101915:	83 e2 f0             	and    $0xfffffff0,%edx
  101918:	83 ca 0e             	or     $0xe,%edx
  10191b:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101922:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101925:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10192c:	00 
  10192d:	83 e2 ef             	and    $0xffffffef,%edx
  101930:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101937:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10193a:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101941:	00 
  101942:	83 e2 9f             	and    $0xffffff9f,%edx
  101945:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10194c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10194f:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101956:	00 
  101957:	83 ca 80             	or     $0xffffff80,%edx
  10195a:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101961:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101964:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  10196b:	c1 e8 10             	shr    $0x10,%eax
  10196e:	89 c2                	mov    %eax,%edx
  101970:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101973:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  10197a:	00 
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) {
  10197b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10197f:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  101986:	0f 8e 30 ff ff ff    	jle    1018bc <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  10198c:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  101991:	66 a3 48 aa 11 00    	mov    %ax,0x11aa48
  101997:	66 c7 05 4a aa 11 00 	movw   $0x8,0x11aa4a
  10199e:	08 00 
  1019a0:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019a7:	83 e0 e0             	and    $0xffffffe0,%eax
  1019aa:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019af:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019b6:	83 e0 1f             	and    $0x1f,%eax
  1019b9:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019be:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019c5:	83 e0 f0             	and    $0xfffffff0,%eax
  1019c8:	83 c8 0e             	or     $0xe,%eax
  1019cb:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019d0:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019d7:	83 e0 ef             	and    $0xffffffef,%eax
  1019da:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019df:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019e6:	83 c8 60             	or     $0x60,%eax
  1019e9:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019ee:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019f5:	83 c8 80             	or     $0xffffff80,%eax
  1019f8:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019fd:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  101a02:	c1 e8 10             	shr    $0x10,%eax
  101a05:	66 a3 4e aa 11 00    	mov    %ax,0x11aa4e
  101a0b:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a12:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a15:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
  101a18:	90                   	nop
  101a19:	c9                   	leave  
  101a1a:	c3                   	ret    

00101a1b <trapname>:

static const char *
trapname(int trapno) {
  101a1b:	55                   	push   %ebp
  101a1c:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a21:	83 f8 13             	cmp    $0x13,%eax
  101a24:	77 0c                	ja     101a32 <trapname+0x17>
        return excnames[trapno];
  101a26:	8b 45 08             	mov    0x8(%ebp),%eax
  101a29:	8b 04 85 60 61 10 00 	mov    0x106160(,%eax,4),%eax
  101a30:	eb 18                	jmp    101a4a <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a32:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a36:	7e 0d                	jle    101a45 <trapname+0x2a>
  101a38:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a3c:	7f 07                	jg     101a45 <trapname+0x2a>
        return "Hardware Interrupt";
  101a3e:	b8 0a 5e 10 00       	mov    $0x105e0a,%eax
  101a43:	eb 05                	jmp    101a4a <trapname+0x2f>
    }
    return "(unknown trap)";
  101a45:	b8 1d 5e 10 00       	mov    $0x105e1d,%eax
}
  101a4a:	5d                   	pop    %ebp
  101a4b:	c3                   	ret    

00101a4c <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a4c:	55                   	push   %ebp
  101a4d:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a52:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a56:	66 83 f8 08          	cmp    $0x8,%ax
  101a5a:	0f 94 c0             	sete   %al
  101a5d:	0f b6 c0             	movzbl %al,%eax
}
  101a60:	5d                   	pop    %ebp
  101a61:	c3                   	ret    

00101a62 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a62:	55                   	push   %ebp
  101a63:	89 e5                	mov    %esp,%ebp
  101a65:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
  101a68:	83 ec 08             	sub    $0x8,%esp
  101a6b:	ff 75 08             	pushl  0x8(%ebp)
  101a6e:	68 5e 5e 10 00       	push   $0x105e5e
  101a73:	e8 fb e7 ff ff       	call   100273 <cprintf>
  101a78:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
  101a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7e:	83 ec 0c             	sub    $0xc,%esp
  101a81:	50                   	push   %eax
  101a82:	e8 b8 01 00 00       	call   101c3f <print_regs>
  101a87:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a8d:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a91:	0f b7 c0             	movzwl %ax,%eax
  101a94:	83 ec 08             	sub    $0x8,%esp
  101a97:	50                   	push   %eax
  101a98:	68 6f 5e 10 00       	push   $0x105e6f
  101a9d:	e8 d1 e7 ff ff       	call   100273 <cprintf>
  101aa2:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa8:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101aac:	0f b7 c0             	movzwl %ax,%eax
  101aaf:	83 ec 08             	sub    $0x8,%esp
  101ab2:	50                   	push   %eax
  101ab3:	68 82 5e 10 00       	push   $0x105e82
  101ab8:	e8 b6 e7 ff ff       	call   100273 <cprintf>
  101abd:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac3:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ac7:	0f b7 c0             	movzwl %ax,%eax
  101aca:	83 ec 08             	sub    $0x8,%esp
  101acd:	50                   	push   %eax
  101ace:	68 95 5e 10 00       	push   $0x105e95
  101ad3:	e8 9b e7 ff ff       	call   100273 <cprintf>
  101ad8:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101adb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ade:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ae2:	0f b7 c0             	movzwl %ax,%eax
  101ae5:	83 ec 08             	sub    $0x8,%esp
  101ae8:	50                   	push   %eax
  101ae9:	68 a8 5e 10 00       	push   $0x105ea8
  101aee:	e8 80 e7 ff ff       	call   100273 <cprintf>
  101af3:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101af6:	8b 45 08             	mov    0x8(%ebp),%eax
  101af9:	8b 40 30             	mov    0x30(%eax),%eax
  101afc:	83 ec 0c             	sub    $0xc,%esp
  101aff:	50                   	push   %eax
  101b00:	e8 16 ff ff ff       	call   101a1b <trapname>
  101b05:	83 c4 10             	add    $0x10,%esp
  101b08:	89 c2                	mov    %eax,%edx
  101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b0d:	8b 40 30             	mov    0x30(%eax),%eax
  101b10:	83 ec 04             	sub    $0x4,%esp
  101b13:	52                   	push   %edx
  101b14:	50                   	push   %eax
  101b15:	68 bb 5e 10 00       	push   $0x105ebb
  101b1a:	e8 54 e7 ff ff       	call   100273 <cprintf>
  101b1f:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b22:	8b 45 08             	mov    0x8(%ebp),%eax
  101b25:	8b 40 34             	mov    0x34(%eax),%eax
  101b28:	83 ec 08             	sub    $0x8,%esp
  101b2b:	50                   	push   %eax
  101b2c:	68 cd 5e 10 00       	push   $0x105ecd
  101b31:	e8 3d e7 ff ff       	call   100273 <cprintf>
  101b36:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b39:	8b 45 08             	mov    0x8(%ebp),%eax
  101b3c:	8b 40 38             	mov    0x38(%eax),%eax
  101b3f:	83 ec 08             	sub    $0x8,%esp
  101b42:	50                   	push   %eax
  101b43:	68 dc 5e 10 00       	push   $0x105edc
  101b48:	e8 26 e7 ff ff       	call   100273 <cprintf>
  101b4d:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b50:	8b 45 08             	mov    0x8(%ebp),%eax
  101b53:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b57:	0f b7 c0             	movzwl %ax,%eax
  101b5a:	83 ec 08             	sub    $0x8,%esp
  101b5d:	50                   	push   %eax
  101b5e:	68 eb 5e 10 00       	push   $0x105eeb
  101b63:	e8 0b e7 ff ff       	call   100273 <cprintf>
  101b68:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6e:	8b 40 40             	mov    0x40(%eax),%eax
  101b71:	83 ec 08             	sub    $0x8,%esp
  101b74:	50                   	push   %eax
  101b75:	68 fe 5e 10 00       	push   $0x105efe
  101b7a:	e8 f4 e6 ff ff       	call   100273 <cprintf>
  101b7f:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b89:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b90:	eb 3f                	jmp    101bd1 <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b92:	8b 45 08             	mov    0x8(%ebp),%eax
  101b95:	8b 50 40             	mov    0x40(%eax),%edx
  101b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b9b:	21 d0                	and    %edx,%eax
  101b9d:	85 c0                	test   %eax,%eax
  101b9f:	74 29                	je     101bca <print_trapframe+0x168>
  101ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101ba4:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101bab:	85 c0                	test   %eax,%eax
  101bad:	74 1b                	je     101bca <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
  101baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bb2:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101bb9:	83 ec 08             	sub    $0x8,%esp
  101bbc:	50                   	push   %eax
  101bbd:	68 0d 5f 10 00       	push   $0x105f0d
  101bc2:	e8 ac e6 ff ff       	call   100273 <cprintf>
  101bc7:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101bce:	d1 65 f0             	shll   -0x10(%ebp)
  101bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bd4:	83 f8 17             	cmp    $0x17,%eax
  101bd7:	76 b9                	jbe    101b92 <print_trapframe+0x130>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bdc:	8b 40 40             	mov    0x40(%eax),%eax
  101bdf:	25 00 30 00 00       	and    $0x3000,%eax
  101be4:	c1 e8 0c             	shr    $0xc,%eax
  101be7:	83 ec 08             	sub    $0x8,%esp
  101bea:	50                   	push   %eax
  101beb:	68 11 5f 10 00       	push   $0x105f11
  101bf0:	e8 7e e6 ff ff       	call   100273 <cprintf>
  101bf5:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
  101bf8:	83 ec 0c             	sub    $0xc,%esp
  101bfb:	ff 75 08             	pushl  0x8(%ebp)
  101bfe:	e8 49 fe ff ff       	call   101a4c <trap_in_kernel>
  101c03:	83 c4 10             	add    $0x10,%esp
  101c06:	85 c0                	test   %eax,%eax
  101c08:	75 32                	jne    101c3c <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0d:	8b 40 44             	mov    0x44(%eax),%eax
  101c10:	83 ec 08             	sub    $0x8,%esp
  101c13:	50                   	push   %eax
  101c14:	68 1a 5f 10 00       	push   $0x105f1a
  101c19:	e8 55 e6 ff ff       	call   100273 <cprintf>
  101c1e:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c21:	8b 45 08             	mov    0x8(%ebp),%eax
  101c24:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c28:	0f b7 c0             	movzwl %ax,%eax
  101c2b:	83 ec 08             	sub    $0x8,%esp
  101c2e:	50                   	push   %eax
  101c2f:	68 29 5f 10 00       	push   $0x105f29
  101c34:	e8 3a e6 ff ff       	call   100273 <cprintf>
  101c39:	83 c4 10             	add    $0x10,%esp
    }
}
  101c3c:	90                   	nop
  101c3d:	c9                   	leave  
  101c3e:	c3                   	ret    

00101c3f <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c3f:	55                   	push   %ebp
  101c40:	89 e5                	mov    %esp,%ebp
  101c42:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c45:	8b 45 08             	mov    0x8(%ebp),%eax
  101c48:	8b 00                	mov    (%eax),%eax
  101c4a:	83 ec 08             	sub    $0x8,%esp
  101c4d:	50                   	push   %eax
  101c4e:	68 3c 5f 10 00       	push   $0x105f3c
  101c53:	e8 1b e6 ff ff       	call   100273 <cprintf>
  101c58:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5e:	8b 40 04             	mov    0x4(%eax),%eax
  101c61:	83 ec 08             	sub    $0x8,%esp
  101c64:	50                   	push   %eax
  101c65:	68 4b 5f 10 00       	push   $0x105f4b
  101c6a:	e8 04 e6 ff ff       	call   100273 <cprintf>
  101c6f:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c72:	8b 45 08             	mov    0x8(%ebp),%eax
  101c75:	8b 40 08             	mov    0x8(%eax),%eax
  101c78:	83 ec 08             	sub    $0x8,%esp
  101c7b:	50                   	push   %eax
  101c7c:	68 5a 5f 10 00       	push   $0x105f5a
  101c81:	e8 ed e5 ff ff       	call   100273 <cprintf>
  101c86:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c89:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8c:	8b 40 0c             	mov    0xc(%eax),%eax
  101c8f:	83 ec 08             	sub    $0x8,%esp
  101c92:	50                   	push   %eax
  101c93:	68 69 5f 10 00       	push   $0x105f69
  101c98:	e8 d6 e5 ff ff       	call   100273 <cprintf>
  101c9d:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca3:	8b 40 10             	mov    0x10(%eax),%eax
  101ca6:	83 ec 08             	sub    $0x8,%esp
  101ca9:	50                   	push   %eax
  101caa:	68 78 5f 10 00       	push   $0x105f78
  101caf:	e8 bf e5 ff ff       	call   100273 <cprintf>
  101cb4:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  101cba:	8b 40 14             	mov    0x14(%eax),%eax
  101cbd:	83 ec 08             	sub    $0x8,%esp
  101cc0:	50                   	push   %eax
  101cc1:	68 87 5f 10 00       	push   $0x105f87
  101cc6:	e8 a8 e5 ff ff       	call   100273 <cprintf>
  101ccb:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cce:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd1:	8b 40 18             	mov    0x18(%eax),%eax
  101cd4:	83 ec 08             	sub    $0x8,%esp
  101cd7:	50                   	push   %eax
  101cd8:	68 96 5f 10 00       	push   $0x105f96
  101cdd:	e8 91 e5 ff ff       	call   100273 <cprintf>
  101ce2:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce8:	8b 40 1c             	mov    0x1c(%eax),%eax
  101ceb:	83 ec 08             	sub    $0x8,%esp
  101cee:	50                   	push   %eax
  101cef:	68 a5 5f 10 00       	push   $0x105fa5
  101cf4:	e8 7a e5 ff ff       	call   100273 <cprintf>
  101cf9:	83 c4 10             	add    $0x10,%esp
}
  101cfc:	90                   	nop
  101cfd:	c9                   	leave  
  101cfe:	c3                   	ret    

00101cff <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101cff:	55                   	push   %ebp
  101d00:	89 e5                	mov    %esp,%ebp
  101d02:	83 ec 18             	sub    $0x18,%esp
    char c;

    switch (tf->tf_trapno) {
  101d05:	8b 45 08             	mov    0x8(%ebp),%eax
  101d08:	8b 40 30             	mov    0x30(%eax),%eax
  101d0b:	83 f8 2f             	cmp    $0x2f,%eax
  101d0e:	77 1d                	ja     101d2d <trap_dispatch+0x2e>
  101d10:	83 f8 2e             	cmp    $0x2e,%eax
  101d13:	0f 83 e9 00 00 00    	jae    101e02 <trap_dispatch+0x103>
  101d19:	83 f8 21             	cmp    $0x21,%eax
  101d1c:	74 73                	je     101d91 <trap_dispatch+0x92>
  101d1e:	83 f8 24             	cmp    $0x24,%eax
  101d21:	74 4a                	je     101d6d <trap_dispatch+0x6e>
  101d23:	83 f8 20             	cmp    $0x20,%eax
  101d26:	74 13                	je     101d3b <trap_dispatch+0x3c>
  101d28:	e9 9f 00 00 00       	jmp    101dcc <trap_dispatch+0xcd>
  101d2d:	83 e8 78             	sub    $0x78,%eax
  101d30:	83 f8 01             	cmp    $0x1,%eax
  101d33:	0f 87 93 00 00 00    	ja     101dcc <trap_dispatch+0xcd>
  101d39:	eb 7a                	jmp    101db5 <trap_dispatch+0xb6>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
  101d3b:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d40:	83 c0 01             	add    $0x1,%eax
  101d43:	a3 0c af 11 00       	mov    %eax,0x11af0c
        if (ticks == TICK_NUM) {
  101d48:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d4d:	83 f8 64             	cmp    $0x64,%eax
  101d50:	0f 85 af 00 00 00    	jne    101e05 <trap_dispatch+0x106>
            ticks -= TICK_NUM;
  101d56:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d5b:	83 e8 64             	sub    $0x64,%eax
  101d5e:	a3 0c af 11 00       	mov    %eax,0x11af0c
            print_ticks();
  101d63:	e8 27 fb ff ff       	call   10188f <print_ticks>
        }
        break;
  101d68:	e9 98 00 00 00       	jmp    101e05 <trap_dispatch+0x106>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d6d:	e8 da f8 ff ff       	call   10164c <cons_getc>
  101d72:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d75:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d79:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d7d:	83 ec 04             	sub    $0x4,%esp
  101d80:	52                   	push   %edx
  101d81:	50                   	push   %eax
  101d82:	68 b4 5f 10 00       	push   $0x105fb4
  101d87:	e8 e7 e4 ff ff       	call   100273 <cprintf>
  101d8c:	83 c4 10             	add    $0x10,%esp
        break;
  101d8f:	eb 75                	jmp    101e06 <trap_dispatch+0x107>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d91:	e8 b6 f8 ff ff       	call   10164c <cons_getc>
  101d96:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d99:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d9d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101da1:	83 ec 04             	sub    $0x4,%esp
  101da4:	52                   	push   %edx
  101da5:	50                   	push   %eax
  101da6:	68 c6 5f 10 00       	push   $0x105fc6
  101dab:	e8 c3 e4 ff ff       	call   100273 <cprintf>
  101db0:	83 c4 10             	add    $0x10,%esp
        break;
  101db3:	eb 51                	jmp    101e06 <trap_dispatch+0x107>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101db5:	83 ec 04             	sub    $0x4,%esp
  101db8:	68 d5 5f 10 00       	push   $0x105fd5
  101dbd:	68 ad 00 00 00       	push   $0xad
  101dc2:	68 e5 5f 10 00       	push   $0x105fe5
  101dc7:	e8 0d e6 ff ff       	call   1003d9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  101dcf:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101dd3:	0f b7 c0             	movzwl %ax,%eax
  101dd6:	83 e0 03             	and    $0x3,%eax
  101dd9:	85 c0                	test   %eax,%eax
  101ddb:	75 29                	jne    101e06 <trap_dispatch+0x107>
            print_trapframe(tf);
  101ddd:	83 ec 0c             	sub    $0xc,%esp
  101de0:	ff 75 08             	pushl  0x8(%ebp)
  101de3:	e8 7a fc ff ff       	call   101a62 <print_trapframe>
  101de8:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
  101deb:	83 ec 04             	sub    $0x4,%esp
  101dee:	68 f6 5f 10 00       	push   $0x105ff6
  101df3:	68 b7 00 00 00       	push   $0xb7
  101df8:	68 e5 5f 10 00       	push   $0x105fe5
  101dfd:	e8 d7 e5 ff ff       	call   1003d9 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101e02:	90                   	nop
  101e03:	eb 01                	jmp    101e06 <trap_dispatch+0x107>
        ticks++;
        if (ticks == TICK_NUM) {
            ticks -= TICK_NUM;
            print_ticks();
        }
        break;
  101e05:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101e06:	90                   	nop
  101e07:	c9                   	leave  
  101e08:	c3                   	ret    

00101e09 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e09:	55                   	push   %ebp
  101e0a:	89 e5                	mov    %esp,%ebp
  101e0c:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e0f:	83 ec 0c             	sub    $0xc,%esp
  101e12:	ff 75 08             	pushl  0x8(%ebp)
  101e15:	e8 e5 fe ff ff       	call   101cff <trap_dispatch>
  101e1a:	83 c4 10             	add    $0x10,%esp
}
  101e1d:	90                   	nop
  101e1e:	c9                   	leave  
  101e1f:	c3                   	ret    

00101e20 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e20:	6a 00                	push   $0x0
  pushl $0
  101e22:	6a 00                	push   $0x0
  jmp __alltraps
  101e24:	e9 69 0a 00 00       	jmp    102892 <__alltraps>

00101e29 <vector1>:
.globl vector1
vector1:
  pushl $0
  101e29:	6a 00                	push   $0x0
  pushl $1
  101e2b:	6a 01                	push   $0x1
  jmp __alltraps
  101e2d:	e9 60 0a 00 00       	jmp    102892 <__alltraps>

00101e32 <vector2>:
.globl vector2
vector2:
  pushl $0
  101e32:	6a 00                	push   $0x0
  pushl $2
  101e34:	6a 02                	push   $0x2
  jmp __alltraps
  101e36:	e9 57 0a 00 00       	jmp    102892 <__alltraps>

00101e3b <vector3>:
.globl vector3
vector3:
  pushl $0
  101e3b:	6a 00                	push   $0x0
  pushl $3
  101e3d:	6a 03                	push   $0x3
  jmp __alltraps
  101e3f:	e9 4e 0a 00 00       	jmp    102892 <__alltraps>

00101e44 <vector4>:
.globl vector4
vector4:
  pushl $0
  101e44:	6a 00                	push   $0x0
  pushl $4
  101e46:	6a 04                	push   $0x4
  jmp __alltraps
  101e48:	e9 45 0a 00 00       	jmp    102892 <__alltraps>

00101e4d <vector5>:
.globl vector5
vector5:
  pushl $0
  101e4d:	6a 00                	push   $0x0
  pushl $5
  101e4f:	6a 05                	push   $0x5
  jmp __alltraps
  101e51:	e9 3c 0a 00 00       	jmp    102892 <__alltraps>

00101e56 <vector6>:
.globl vector6
vector6:
  pushl $0
  101e56:	6a 00                	push   $0x0
  pushl $6
  101e58:	6a 06                	push   $0x6
  jmp __alltraps
  101e5a:	e9 33 0a 00 00       	jmp    102892 <__alltraps>

00101e5f <vector7>:
.globl vector7
vector7:
  pushl $0
  101e5f:	6a 00                	push   $0x0
  pushl $7
  101e61:	6a 07                	push   $0x7
  jmp __alltraps
  101e63:	e9 2a 0a 00 00       	jmp    102892 <__alltraps>

00101e68 <vector8>:
.globl vector8
vector8:
  pushl $8
  101e68:	6a 08                	push   $0x8
  jmp __alltraps
  101e6a:	e9 23 0a 00 00       	jmp    102892 <__alltraps>

00101e6f <vector9>:
.globl vector9
vector9:
  pushl $0
  101e6f:	6a 00                	push   $0x0
  pushl $9
  101e71:	6a 09                	push   $0x9
  jmp __alltraps
  101e73:	e9 1a 0a 00 00       	jmp    102892 <__alltraps>

00101e78 <vector10>:
.globl vector10
vector10:
  pushl $10
  101e78:	6a 0a                	push   $0xa
  jmp __alltraps
  101e7a:	e9 13 0a 00 00       	jmp    102892 <__alltraps>

00101e7f <vector11>:
.globl vector11
vector11:
  pushl $11
  101e7f:	6a 0b                	push   $0xb
  jmp __alltraps
  101e81:	e9 0c 0a 00 00       	jmp    102892 <__alltraps>

00101e86 <vector12>:
.globl vector12
vector12:
  pushl $12
  101e86:	6a 0c                	push   $0xc
  jmp __alltraps
  101e88:	e9 05 0a 00 00       	jmp    102892 <__alltraps>

00101e8d <vector13>:
.globl vector13
vector13:
  pushl $13
  101e8d:	6a 0d                	push   $0xd
  jmp __alltraps
  101e8f:	e9 fe 09 00 00       	jmp    102892 <__alltraps>

00101e94 <vector14>:
.globl vector14
vector14:
  pushl $14
  101e94:	6a 0e                	push   $0xe
  jmp __alltraps
  101e96:	e9 f7 09 00 00       	jmp    102892 <__alltraps>

00101e9b <vector15>:
.globl vector15
vector15:
  pushl $0
  101e9b:	6a 00                	push   $0x0
  pushl $15
  101e9d:	6a 0f                	push   $0xf
  jmp __alltraps
  101e9f:	e9 ee 09 00 00       	jmp    102892 <__alltraps>

00101ea4 <vector16>:
.globl vector16
vector16:
  pushl $0
  101ea4:	6a 00                	push   $0x0
  pushl $16
  101ea6:	6a 10                	push   $0x10
  jmp __alltraps
  101ea8:	e9 e5 09 00 00       	jmp    102892 <__alltraps>

00101ead <vector17>:
.globl vector17
vector17:
  pushl $17
  101ead:	6a 11                	push   $0x11
  jmp __alltraps
  101eaf:	e9 de 09 00 00       	jmp    102892 <__alltraps>

00101eb4 <vector18>:
.globl vector18
vector18:
  pushl $0
  101eb4:	6a 00                	push   $0x0
  pushl $18
  101eb6:	6a 12                	push   $0x12
  jmp __alltraps
  101eb8:	e9 d5 09 00 00       	jmp    102892 <__alltraps>

00101ebd <vector19>:
.globl vector19
vector19:
  pushl $0
  101ebd:	6a 00                	push   $0x0
  pushl $19
  101ebf:	6a 13                	push   $0x13
  jmp __alltraps
  101ec1:	e9 cc 09 00 00       	jmp    102892 <__alltraps>

00101ec6 <vector20>:
.globl vector20
vector20:
  pushl $0
  101ec6:	6a 00                	push   $0x0
  pushl $20
  101ec8:	6a 14                	push   $0x14
  jmp __alltraps
  101eca:	e9 c3 09 00 00       	jmp    102892 <__alltraps>

00101ecf <vector21>:
.globl vector21
vector21:
  pushl $0
  101ecf:	6a 00                	push   $0x0
  pushl $21
  101ed1:	6a 15                	push   $0x15
  jmp __alltraps
  101ed3:	e9 ba 09 00 00       	jmp    102892 <__alltraps>

00101ed8 <vector22>:
.globl vector22
vector22:
  pushl $0
  101ed8:	6a 00                	push   $0x0
  pushl $22
  101eda:	6a 16                	push   $0x16
  jmp __alltraps
  101edc:	e9 b1 09 00 00       	jmp    102892 <__alltraps>

00101ee1 <vector23>:
.globl vector23
vector23:
  pushl $0
  101ee1:	6a 00                	push   $0x0
  pushl $23
  101ee3:	6a 17                	push   $0x17
  jmp __alltraps
  101ee5:	e9 a8 09 00 00       	jmp    102892 <__alltraps>

00101eea <vector24>:
.globl vector24
vector24:
  pushl $0
  101eea:	6a 00                	push   $0x0
  pushl $24
  101eec:	6a 18                	push   $0x18
  jmp __alltraps
  101eee:	e9 9f 09 00 00       	jmp    102892 <__alltraps>

00101ef3 <vector25>:
.globl vector25
vector25:
  pushl $0
  101ef3:	6a 00                	push   $0x0
  pushl $25
  101ef5:	6a 19                	push   $0x19
  jmp __alltraps
  101ef7:	e9 96 09 00 00       	jmp    102892 <__alltraps>

00101efc <vector26>:
.globl vector26
vector26:
  pushl $0
  101efc:	6a 00                	push   $0x0
  pushl $26
  101efe:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f00:	e9 8d 09 00 00       	jmp    102892 <__alltraps>

00101f05 <vector27>:
.globl vector27
vector27:
  pushl $0
  101f05:	6a 00                	push   $0x0
  pushl $27
  101f07:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f09:	e9 84 09 00 00       	jmp    102892 <__alltraps>

00101f0e <vector28>:
.globl vector28
vector28:
  pushl $0
  101f0e:	6a 00                	push   $0x0
  pushl $28
  101f10:	6a 1c                	push   $0x1c
  jmp __alltraps
  101f12:	e9 7b 09 00 00       	jmp    102892 <__alltraps>

00101f17 <vector29>:
.globl vector29
vector29:
  pushl $0
  101f17:	6a 00                	push   $0x0
  pushl $29
  101f19:	6a 1d                	push   $0x1d
  jmp __alltraps
  101f1b:	e9 72 09 00 00       	jmp    102892 <__alltraps>

00101f20 <vector30>:
.globl vector30
vector30:
  pushl $0
  101f20:	6a 00                	push   $0x0
  pushl $30
  101f22:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f24:	e9 69 09 00 00       	jmp    102892 <__alltraps>

00101f29 <vector31>:
.globl vector31
vector31:
  pushl $0
  101f29:	6a 00                	push   $0x0
  pushl $31
  101f2b:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f2d:	e9 60 09 00 00       	jmp    102892 <__alltraps>

00101f32 <vector32>:
.globl vector32
vector32:
  pushl $0
  101f32:	6a 00                	push   $0x0
  pushl $32
  101f34:	6a 20                	push   $0x20
  jmp __alltraps
  101f36:	e9 57 09 00 00       	jmp    102892 <__alltraps>

00101f3b <vector33>:
.globl vector33
vector33:
  pushl $0
  101f3b:	6a 00                	push   $0x0
  pushl $33
  101f3d:	6a 21                	push   $0x21
  jmp __alltraps
  101f3f:	e9 4e 09 00 00       	jmp    102892 <__alltraps>

00101f44 <vector34>:
.globl vector34
vector34:
  pushl $0
  101f44:	6a 00                	push   $0x0
  pushl $34
  101f46:	6a 22                	push   $0x22
  jmp __alltraps
  101f48:	e9 45 09 00 00       	jmp    102892 <__alltraps>

00101f4d <vector35>:
.globl vector35
vector35:
  pushl $0
  101f4d:	6a 00                	push   $0x0
  pushl $35
  101f4f:	6a 23                	push   $0x23
  jmp __alltraps
  101f51:	e9 3c 09 00 00       	jmp    102892 <__alltraps>

00101f56 <vector36>:
.globl vector36
vector36:
  pushl $0
  101f56:	6a 00                	push   $0x0
  pushl $36
  101f58:	6a 24                	push   $0x24
  jmp __alltraps
  101f5a:	e9 33 09 00 00       	jmp    102892 <__alltraps>

00101f5f <vector37>:
.globl vector37
vector37:
  pushl $0
  101f5f:	6a 00                	push   $0x0
  pushl $37
  101f61:	6a 25                	push   $0x25
  jmp __alltraps
  101f63:	e9 2a 09 00 00       	jmp    102892 <__alltraps>

00101f68 <vector38>:
.globl vector38
vector38:
  pushl $0
  101f68:	6a 00                	push   $0x0
  pushl $38
  101f6a:	6a 26                	push   $0x26
  jmp __alltraps
  101f6c:	e9 21 09 00 00       	jmp    102892 <__alltraps>

00101f71 <vector39>:
.globl vector39
vector39:
  pushl $0
  101f71:	6a 00                	push   $0x0
  pushl $39
  101f73:	6a 27                	push   $0x27
  jmp __alltraps
  101f75:	e9 18 09 00 00       	jmp    102892 <__alltraps>

00101f7a <vector40>:
.globl vector40
vector40:
  pushl $0
  101f7a:	6a 00                	push   $0x0
  pushl $40
  101f7c:	6a 28                	push   $0x28
  jmp __alltraps
  101f7e:	e9 0f 09 00 00       	jmp    102892 <__alltraps>

00101f83 <vector41>:
.globl vector41
vector41:
  pushl $0
  101f83:	6a 00                	push   $0x0
  pushl $41
  101f85:	6a 29                	push   $0x29
  jmp __alltraps
  101f87:	e9 06 09 00 00       	jmp    102892 <__alltraps>

00101f8c <vector42>:
.globl vector42
vector42:
  pushl $0
  101f8c:	6a 00                	push   $0x0
  pushl $42
  101f8e:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f90:	e9 fd 08 00 00       	jmp    102892 <__alltraps>

00101f95 <vector43>:
.globl vector43
vector43:
  pushl $0
  101f95:	6a 00                	push   $0x0
  pushl $43
  101f97:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f99:	e9 f4 08 00 00       	jmp    102892 <__alltraps>

00101f9e <vector44>:
.globl vector44
vector44:
  pushl $0
  101f9e:	6a 00                	push   $0x0
  pushl $44
  101fa0:	6a 2c                	push   $0x2c
  jmp __alltraps
  101fa2:	e9 eb 08 00 00       	jmp    102892 <__alltraps>

00101fa7 <vector45>:
.globl vector45
vector45:
  pushl $0
  101fa7:	6a 00                	push   $0x0
  pushl $45
  101fa9:	6a 2d                	push   $0x2d
  jmp __alltraps
  101fab:	e9 e2 08 00 00       	jmp    102892 <__alltraps>

00101fb0 <vector46>:
.globl vector46
vector46:
  pushl $0
  101fb0:	6a 00                	push   $0x0
  pushl $46
  101fb2:	6a 2e                	push   $0x2e
  jmp __alltraps
  101fb4:	e9 d9 08 00 00       	jmp    102892 <__alltraps>

00101fb9 <vector47>:
.globl vector47
vector47:
  pushl $0
  101fb9:	6a 00                	push   $0x0
  pushl $47
  101fbb:	6a 2f                	push   $0x2f
  jmp __alltraps
  101fbd:	e9 d0 08 00 00       	jmp    102892 <__alltraps>

00101fc2 <vector48>:
.globl vector48
vector48:
  pushl $0
  101fc2:	6a 00                	push   $0x0
  pushl $48
  101fc4:	6a 30                	push   $0x30
  jmp __alltraps
  101fc6:	e9 c7 08 00 00       	jmp    102892 <__alltraps>

00101fcb <vector49>:
.globl vector49
vector49:
  pushl $0
  101fcb:	6a 00                	push   $0x0
  pushl $49
  101fcd:	6a 31                	push   $0x31
  jmp __alltraps
  101fcf:	e9 be 08 00 00       	jmp    102892 <__alltraps>

00101fd4 <vector50>:
.globl vector50
vector50:
  pushl $0
  101fd4:	6a 00                	push   $0x0
  pushl $50
  101fd6:	6a 32                	push   $0x32
  jmp __alltraps
  101fd8:	e9 b5 08 00 00       	jmp    102892 <__alltraps>

00101fdd <vector51>:
.globl vector51
vector51:
  pushl $0
  101fdd:	6a 00                	push   $0x0
  pushl $51
  101fdf:	6a 33                	push   $0x33
  jmp __alltraps
  101fe1:	e9 ac 08 00 00       	jmp    102892 <__alltraps>

00101fe6 <vector52>:
.globl vector52
vector52:
  pushl $0
  101fe6:	6a 00                	push   $0x0
  pushl $52
  101fe8:	6a 34                	push   $0x34
  jmp __alltraps
  101fea:	e9 a3 08 00 00       	jmp    102892 <__alltraps>

00101fef <vector53>:
.globl vector53
vector53:
  pushl $0
  101fef:	6a 00                	push   $0x0
  pushl $53
  101ff1:	6a 35                	push   $0x35
  jmp __alltraps
  101ff3:	e9 9a 08 00 00       	jmp    102892 <__alltraps>

00101ff8 <vector54>:
.globl vector54
vector54:
  pushl $0
  101ff8:	6a 00                	push   $0x0
  pushl $54
  101ffa:	6a 36                	push   $0x36
  jmp __alltraps
  101ffc:	e9 91 08 00 00       	jmp    102892 <__alltraps>

00102001 <vector55>:
.globl vector55
vector55:
  pushl $0
  102001:	6a 00                	push   $0x0
  pushl $55
  102003:	6a 37                	push   $0x37
  jmp __alltraps
  102005:	e9 88 08 00 00       	jmp    102892 <__alltraps>

0010200a <vector56>:
.globl vector56
vector56:
  pushl $0
  10200a:	6a 00                	push   $0x0
  pushl $56
  10200c:	6a 38                	push   $0x38
  jmp __alltraps
  10200e:	e9 7f 08 00 00       	jmp    102892 <__alltraps>

00102013 <vector57>:
.globl vector57
vector57:
  pushl $0
  102013:	6a 00                	push   $0x0
  pushl $57
  102015:	6a 39                	push   $0x39
  jmp __alltraps
  102017:	e9 76 08 00 00       	jmp    102892 <__alltraps>

0010201c <vector58>:
.globl vector58
vector58:
  pushl $0
  10201c:	6a 00                	push   $0x0
  pushl $58
  10201e:	6a 3a                	push   $0x3a
  jmp __alltraps
  102020:	e9 6d 08 00 00       	jmp    102892 <__alltraps>

00102025 <vector59>:
.globl vector59
vector59:
  pushl $0
  102025:	6a 00                	push   $0x0
  pushl $59
  102027:	6a 3b                	push   $0x3b
  jmp __alltraps
  102029:	e9 64 08 00 00       	jmp    102892 <__alltraps>

0010202e <vector60>:
.globl vector60
vector60:
  pushl $0
  10202e:	6a 00                	push   $0x0
  pushl $60
  102030:	6a 3c                	push   $0x3c
  jmp __alltraps
  102032:	e9 5b 08 00 00       	jmp    102892 <__alltraps>

00102037 <vector61>:
.globl vector61
vector61:
  pushl $0
  102037:	6a 00                	push   $0x0
  pushl $61
  102039:	6a 3d                	push   $0x3d
  jmp __alltraps
  10203b:	e9 52 08 00 00       	jmp    102892 <__alltraps>

00102040 <vector62>:
.globl vector62
vector62:
  pushl $0
  102040:	6a 00                	push   $0x0
  pushl $62
  102042:	6a 3e                	push   $0x3e
  jmp __alltraps
  102044:	e9 49 08 00 00       	jmp    102892 <__alltraps>

00102049 <vector63>:
.globl vector63
vector63:
  pushl $0
  102049:	6a 00                	push   $0x0
  pushl $63
  10204b:	6a 3f                	push   $0x3f
  jmp __alltraps
  10204d:	e9 40 08 00 00       	jmp    102892 <__alltraps>

00102052 <vector64>:
.globl vector64
vector64:
  pushl $0
  102052:	6a 00                	push   $0x0
  pushl $64
  102054:	6a 40                	push   $0x40
  jmp __alltraps
  102056:	e9 37 08 00 00       	jmp    102892 <__alltraps>

0010205b <vector65>:
.globl vector65
vector65:
  pushl $0
  10205b:	6a 00                	push   $0x0
  pushl $65
  10205d:	6a 41                	push   $0x41
  jmp __alltraps
  10205f:	e9 2e 08 00 00       	jmp    102892 <__alltraps>

00102064 <vector66>:
.globl vector66
vector66:
  pushl $0
  102064:	6a 00                	push   $0x0
  pushl $66
  102066:	6a 42                	push   $0x42
  jmp __alltraps
  102068:	e9 25 08 00 00       	jmp    102892 <__alltraps>

0010206d <vector67>:
.globl vector67
vector67:
  pushl $0
  10206d:	6a 00                	push   $0x0
  pushl $67
  10206f:	6a 43                	push   $0x43
  jmp __alltraps
  102071:	e9 1c 08 00 00       	jmp    102892 <__alltraps>

00102076 <vector68>:
.globl vector68
vector68:
  pushl $0
  102076:	6a 00                	push   $0x0
  pushl $68
  102078:	6a 44                	push   $0x44
  jmp __alltraps
  10207a:	e9 13 08 00 00       	jmp    102892 <__alltraps>

0010207f <vector69>:
.globl vector69
vector69:
  pushl $0
  10207f:	6a 00                	push   $0x0
  pushl $69
  102081:	6a 45                	push   $0x45
  jmp __alltraps
  102083:	e9 0a 08 00 00       	jmp    102892 <__alltraps>

00102088 <vector70>:
.globl vector70
vector70:
  pushl $0
  102088:	6a 00                	push   $0x0
  pushl $70
  10208a:	6a 46                	push   $0x46
  jmp __alltraps
  10208c:	e9 01 08 00 00       	jmp    102892 <__alltraps>

00102091 <vector71>:
.globl vector71
vector71:
  pushl $0
  102091:	6a 00                	push   $0x0
  pushl $71
  102093:	6a 47                	push   $0x47
  jmp __alltraps
  102095:	e9 f8 07 00 00       	jmp    102892 <__alltraps>

0010209a <vector72>:
.globl vector72
vector72:
  pushl $0
  10209a:	6a 00                	push   $0x0
  pushl $72
  10209c:	6a 48                	push   $0x48
  jmp __alltraps
  10209e:	e9 ef 07 00 00       	jmp    102892 <__alltraps>

001020a3 <vector73>:
.globl vector73
vector73:
  pushl $0
  1020a3:	6a 00                	push   $0x0
  pushl $73
  1020a5:	6a 49                	push   $0x49
  jmp __alltraps
  1020a7:	e9 e6 07 00 00       	jmp    102892 <__alltraps>

001020ac <vector74>:
.globl vector74
vector74:
  pushl $0
  1020ac:	6a 00                	push   $0x0
  pushl $74
  1020ae:	6a 4a                	push   $0x4a
  jmp __alltraps
  1020b0:	e9 dd 07 00 00       	jmp    102892 <__alltraps>

001020b5 <vector75>:
.globl vector75
vector75:
  pushl $0
  1020b5:	6a 00                	push   $0x0
  pushl $75
  1020b7:	6a 4b                	push   $0x4b
  jmp __alltraps
  1020b9:	e9 d4 07 00 00       	jmp    102892 <__alltraps>

001020be <vector76>:
.globl vector76
vector76:
  pushl $0
  1020be:	6a 00                	push   $0x0
  pushl $76
  1020c0:	6a 4c                	push   $0x4c
  jmp __alltraps
  1020c2:	e9 cb 07 00 00       	jmp    102892 <__alltraps>

001020c7 <vector77>:
.globl vector77
vector77:
  pushl $0
  1020c7:	6a 00                	push   $0x0
  pushl $77
  1020c9:	6a 4d                	push   $0x4d
  jmp __alltraps
  1020cb:	e9 c2 07 00 00       	jmp    102892 <__alltraps>

001020d0 <vector78>:
.globl vector78
vector78:
  pushl $0
  1020d0:	6a 00                	push   $0x0
  pushl $78
  1020d2:	6a 4e                	push   $0x4e
  jmp __alltraps
  1020d4:	e9 b9 07 00 00       	jmp    102892 <__alltraps>

001020d9 <vector79>:
.globl vector79
vector79:
  pushl $0
  1020d9:	6a 00                	push   $0x0
  pushl $79
  1020db:	6a 4f                	push   $0x4f
  jmp __alltraps
  1020dd:	e9 b0 07 00 00       	jmp    102892 <__alltraps>

001020e2 <vector80>:
.globl vector80
vector80:
  pushl $0
  1020e2:	6a 00                	push   $0x0
  pushl $80
  1020e4:	6a 50                	push   $0x50
  jmp __alltraps
  1020e6:	e9 a7 07 00 00       	jmp    102892 <__alltraps>

001020eb <vector81>:
.globl vector81
vector81:
  pushl $0
  1020eb:	6a 00                	push   $0x0
  pushl $81
  1020ed:	6a 51                	push   $0x51
  jmp __alltraps
  1020ef:	e9 9e 07 00 00       	jmp    102892 <__alltraps>

001020f4 <vector82>:
.globl vector82
vector82:
  pushl $0
  1020f4:	6a 00                	push   $0x0
  pushl $82
  1020f6:	6a 52                	push   $0x52
  jmp __alltraps
  1020f8:	e9 95 07 00 00       	jmp    102892 <__alltraps>

001020fd <vector83>:
.globl vector83
vector83:
  pushl $0
  1020fd:	6a 00                	push   $0x0
  pushl $83
  1020ff:	6a 53                	push   $0x53
  jmp __alltraps
  102101:	e9 8c 07 00 00       	jmp    102892 <__alltraps>

00102106 <vector84>:
.globl vector84
vector84:
  pushl $0
  102106:	6a 00                	push   $0x0
  pushl $84
  102108:	6a 54                	push   $0x54
  jmp __alltraps
  10210a:	e9 83 07 00 00       	jmp    102892 <__alltraps>

0010210f <vector85>:
.globl vector85
vector85:
  pushl $0
  10210f:	6a 00                	push   $0x0
  pushl $85
  102111:	6a 55                	push   $0x55
  jmp __alltraps
  102113:	e9 7a 07 00 00       	jmp    102892 <__alltraps>

00102118 <vector86>:
.globl vector86
vector86:
  pushl $0
  102118:	6a 00                	push   $0x0
  pushl $86
  10211a:	6a 56                	push   $0x56
  jmp __alltraps
  10211c:	e9 71 07 00 00       	jmp    102892 <__alltraps>

00102121 <vector87>:
.globl vector87
vector87:
  pushl $0
  102121:	6a 00                	push   $0x0
  pushl $87
  102123:	6a 57                	push   $0x57
  jmp __alltraps
  102125:	e9 68 07 00 00       	jmp    102892 <__alltraps>

0010212a <vector88>:
.globl vector88
vector88:
  pushl $0
  10212a:	6a 00                	push   $0x0
  pushl $88
  10212c:	6a 58                	push   $0x58
  jmp __alltraps
  10212e:	e9 5f 07 00 00       	jmp    102892 <__alltraps>

00102133 <vector89>:
.globl vector89
vector89:
  pushl $0
  102133:	6a 00                	push   $0x0
  pushl $89
  102135:	6a 59                	push   $0x59
  jmp __alltraps
  102137:	e9 56 07 00 00       	jmp    102892 <__alltraps>

0010213c <vector90>:
.globl vector90
vector90:
  pushl $0
  10213c:	6a 00                	push   $0x0
  pushl $90
  10213e:	6a 5a                	push   $0x5a
  jmp __alltraps
  102140:	e9 4d 07 00 00       	jmp    102892 <__alltraps>

00102145 <vector91>:
.globl vector91
vector91:
  pushl $0
  102145:	6a 00                	push   $0x0
  pushl $91
  102147:	6a 5b                	push   $0x5b
  jmp __alltraps
  102149:	e9 44 07 00 00       	jmp    102892 <__alltraps>

0010214e <vector92>:
.globl vector92
vector92:
  pushl $0
  10214e:	6a 00                	push   $0x0
  pushl $92
  102150:	6a 5c                	push   $0x5c
  jmp __alltraps
  102152:	e9 3b 07 00 00       	jmp    102892 <__alltraps>

00102157 <vector93>:
.globl vector93
vector93:
  pushl $0
  102157:	6a 00                	push   $0x0
  pushl $93
  102159:	6a 5d                	push   $0x5d
  jmp __alltraps
  10215b:	e9 32 07 00 00       	jmp    102892 <__alltraps>

00102160 <vector94>:
.globl vector94
vector94:
  pushl $0
  102160:	6a 00                	push   $0x0
  pushl $94
  102162:	6a 5e                	push   $0x5e
  jmp __alltraps
  102164:	e9 29 07 00 00       	jmp    102892 <__alltraps>

00102169 <vector95>:
.globl vector95
vector95:
  pushl $0
  102169:	6a 00                	push   $0x0
  pushl $95
  10216b:	6a 5f                	push   $0x5f
  jmp __alltraps
  10216d:	e9 20 07 00 00       	jmp    102892 <__alltraps>

00102172 <vector96>:
.globl vector96
vector96:
  pushl $0
  102172:	6a 00                	push   $0x0
  pushl $96
  102174:	6a 60                	push   $0x60
  jmp __alltraps
  102176:	e9 17 07 00 00       	jmp    102892 <__alltraps>

0010217b <vector97>:
.globl vector97
vector97:
  pushl $0
  10217b:	6a 00                	push   $0x0
  pushl $97
  10217d:	6a 61                	push   $0x61
  jmp __alltraps
  10217f:	e9 0e 07 00 00       	jmp    102892 <__alltraps>

00102184 <vector98>:
.globl vector98
vector98:
  pushl $0
  102184:	6a 00                	push   $0x0
  pushl $98
  102186:	6a 62                	push   $0x62
  jmp __alltraps
  102188:	e9 05 07 00 00       	jmp    102892 <__alltraps>

0010218d <vector99>:
.globl vector99
vector99:
  pushl $0
  10218d:	6a 00                	push   $0x0
  pushl $99
  10218f:	6a 63                	push   $0x63
  jmp __alltraps
  102191:	e9 fc 06 00 00       	jmp    102892 <__alltraps>

00102196 <vector100>:
.globl vector100
vector100:
  pushl $0
  102196:	6a 00                	push   $0x0
  pushl $100
  102198:	6a 64                	push   $0x64
  jmp __alltraps
  10219a:	e9 f3 06 00 00       	jmp    102892 <__alltraps>

0010219f <vector101>:
.globl vector101
vector101:
  pushl $0
  10219f:	6a 00                	push   $0x0
  pushl $101
  1021a1:	6a 65                	push   $0x65
  jmp __alltraps
  1021a3:	e9 ea 06 00 00       	jmp    102892 <__alltraps>

001021a8 <vector102>:
.globl vector102
vector102:
  pushl $0
  1021a8:	6a 00                	push   $0x0
  pushl $102
  1021aa:	6a 66                	push   $0x66
  jmp __alltraps
  1021ac:	e9 e1 06 00 00       	jmp    102892 <__alltraps>

001021b1 <vector103>:
.globl vector103
vector103:
  pushl $0
  1021b1:	6a 00                	push   $0x0
  pushl $103
  1021b3:	6a 67                	push   $0x67
  jmp __alltraps
  1021b5:	e9 d8 06 00 00       	jmp    102892 <__alltraps>

001021ba <vector104>:
.globl vector104
vector104:
  pushl $0
  1021ba:	6a 00                	push   $0x0
  pushl $104
  1021bc:	6a 68                	push   $0x68
  jmp __alltraps
  1021be:	e9 cf 06 00 00       	jmp    102892 <__alltraps>

001021c3 <vector105>:
.globl vector105
vector105:
  pushl $0
  1021c3:	6a 00                	push   $0x0
  pushl $105
  1021c5:	6a 69                	push   $0x69
  jmp __alltraps
  1021c7:	e9 c6 06 00 00       	jmp    102892 <__alltraps>

001021cc <vector106>:
.globl vector106
vector106:
  pushl $0
  1021cc:	6a 00                	push   $0x0
  pushl $106
  1021ce:	6a 6a                	push   $0x6a
  jmp __alltraps
  1021d0:	e9 bd 06 00 00       	jmp    102892 <__alltraps>

001021d5 <vector107>:
.globl vector107
vector107:
  pushl $0
  1021d5:	6a 00                	push   $0x0
  pushl $107
  1021d7:	6a 6b                	push   $0x6b
  jmp __alltraps
  1021d9:	e9 b4 06 00 00       	jmp    102892 <__alltraps>

001021de <vector108>:
.globl vector108
vector108:
  pushl $0
  1021de:	6a 00                	push   $0x0
  pushl $108
  1021e0:	6a 6c                	push   $0x6c
  jmp __alltraps
  1021e2:	e9 ab 06 00 00       	jmp    102892 <__alltraps>

001021e7 <vector109>:
.globl vector109
vector109:
  pushl $0
  1021e7:	6a 00                	push   $0x0
  pushl $109
  1021e9:	6a 6d                	push   $0x6d
  jmp __alltraps
  1021eb:	e9 a2 06 00 00       	jmp    102892 <__alltraps>

001021f0 <vector110>:
.globl vector110
vector110:
  pushl $0
  1021f0:	6a 00                	push   $0x0
  pushl $110
  1021f2:	6a 6e                	push   $0x6e
  jmp __alltraps
  1021f4:	e9 99 06 00 00       	jmp    102892 <__alltraps>

001021f9 <vector111>:
.globl vector111
vector111:
  pushl $0
  1021f9:	6a 00                	push   $0x0
  pushl $111
  1021fb:	6a 6f                	push   $0x6f
  jmp __alltraps
  1021fd:	e9 90 06 00 00       	jmp    102892 <__alltraps>

00102202 <vector112>:
.globl vector112
vector112:
  pushl $0
  102202:	6a 00                	push   $0x0
  pushl $112
  102204:	6a 70                	push   $0x70
  jmp __alltraps
  102206:	e9 87 06 00 00       	jmp    102892 <__alltraps>

0010220b <vector113>:
.globl vector113
vector113:
  pushl $0
  10220b:	6a 00                	push   $0x0
  pushl $113
  10220d:	6a 71                	push   $0x71
  jmp __alltraps
  10220f:	e9 7e 06 00 00       	jmp    102892 <__alltraps>

00102214 <vector114>:
.globl vector114
vector114:
  pushl $0
  102214:	6a 00                	push   $0x0
  pushl $114
  102216:	6a 72                	push   $0x72
  jmp __alltraps
  102218:	e9 75 06 00 00       	jmp    102892 <__alltraps>

0010221d <vector115>:
.globl vector115
vector115:
  pushl $0
  10221d:	6a 00                	push   $0x0
  pushl $115
  10221f:	6a 73                	push   $0x73
  jmp __alltraps
  102221:	e9 6c 06 00 00       	jmp    102892 <__alltraps>

00102226 <vector116>:
.globl vector116
vector116:
  pushl $0
  102226:	6a 00                	push   $0x0
  pushl $116
  102228:	6a 74                	push   $0x74
  jmp __alltraps
  10222a:	e9 63 06 00 00       	jmp    102892 <__alltraps>

0010222f <vector117>:
.globl vector117
vector117:
  pushl $0
  10222f:	6a 00                	push   $0x0
  pushl $117
  102231:	6a 75                	push   $0x75
  jmp __alltraps
  102233:	e9 5a 06 00 00       	jmp    102892 <__alltraps>

00102238 <vector118>:
.globl vector118
vector118:
  pushl $0
  102238:	6a 00                	push   $0x0
  pushl $118
  10223a:	6a 76                	push   $0x76
  jmp __alltraps
  10223c:	e9 51 06 00 00       	jmp    102892 <__alltraps>

00102241 <vector119>:
.globl vector119
vector119:
  pushl $0
  102241:	6a 00                	push   $0x0
  pushl $119
  102243:	6a 77                	push   $0x77
  jmp __alltraps
  102245:	e9 48 06 00 00       	jmp    102892 <__alltraps>

0010224a <vector120>:
.globl vector120
vector120:
  pushl $0
  10224a:	6a 00                	push   $0x0
  pushl $120
  10224c:	6a 78                	push   $0x78
  jmp __alltraps
  10224e:	e9 3f 06 00 00       	jmp    102892 <__alltraps>

00102253 <vector121>:
.globl vector121
vector121:
  pushl $0
  102253:	6a 00                	push   $0x0
  pushl $121
  102255:	6a 79                	push   $0x79
  jmp __alltraps
  102257:	e9 36 06 00 00       	jmp    102892 <__alltraps>

0010225c <vector122>:
.globl vector122
vector122:
  pushl $0
  10225c:	6a 00                	push   $0x0
  pushl $122
  10225e:	6a 7a                	push   $0x7a
  jmp __alltraps
  102260:	e9 2d 06 00 00       	jmp    102892 <__alltraps>

00102265 <vector123>:
.globl vector123
vector123:
  pushl $0
  102265:	6a 00                	push   $0x0
  pushl $123
  102267:	6a 7b                	push   $0x7b
  jmp __alltraps
  102269:	e9 24 06 00 00       	jmp    102892 <__alltraps>

0010226e <vector124>:
.globl vector124
vector124:
  pushl $0
  10226e:	6a 00                	push   $0x0
  pushl $124
  102270:	6a 7c                	push   $0x7c
  jmp __alltraps
  102272:	e9 1b 06 00 00       	jmp    102892 <__alltraps>

00102277 <vector125>:
.globl vector125
vector125:
  pushl $0
  102277:	6a 00                	push   $0x0
  pushl $125
  102279:	6a 7d                	push   $0x7d
  jmp __alltraps
  10227b:	e9 12 06 00 00       	jmp    102892 <__alltraps>

00102280 <vector126>:
.globl vector126
vector126:
  pushl $0
  102280:	6a 00                	push   $0x0
  pushl $126
  102282:	6a 7e                	push   $0x7e
  jmp __alltraps
  102284:	e9 09 06 00 00       	jmp    102892 <__alltraps>

00102289 <vector127>:
.globl vector127
vector127:
  pushl $0
  102289:	6a 00                	push   $0x0
  pushl $127
  10228b:	6a 7f                	push   $0x7f
  jmp __alltraps
  10228d:	e9 00 06 00 00       	jmp    102892 <__alltraps>

00102292 <vector128>:
.globl vector128
vector128:
  pushl $0
  102292:	6a 00                	push   $0x0
  pushl $128
  102294:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102299:	e9 f4 05 00 00       	jmp    102892 <__alltraps>

0010229e <vector129>:
.globl vector129
vector129:
  pushl $0
  10229e:	6a 00                	push   $0x0
  pushl $129
  1022a0:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1022a5:	e9 e8 05 00 00       	jmp    102892 <__alltraps>

001022aa <vector130>:
.globl vector130
vector130:
  pushl $0
  1022aa:	6a 00                	push   $0x0
  pushl $130
  1022ac:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1022b1:	e9 dc 05 00 00       	jmp    102892 <__alltraps>

001022b6 <vector131>:
.globl vector131
vector131:
  pushl $0
  1022b6:	6a 00                	push   $0x0
  pushl $131
  1022b8:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1022bd:	e9 d0 05 00 00       	jmp    102892 <__alltraps>

001022c2 <vector132>:
.globl vector132
vector132:
  pushl $0
  1022c2:	6a 00                	push   $0x0
  pushl $132
  1022c4:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1022c9:	e9 c4 05 00 00       	jmp    102892 <__alltraps>

001022ce <vector133>:
.globl vector133
vector133:
  pushl $0
  1022ce:	6a 00                	push   $0x0
  pushl $133
  1022d0:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1022d5:	e9 b8 05 00 00       	jmp    102892 <__alltraps>

001022da <vector134>:
.globl vector134
vector134:
  pushl $0
  1022da:	6a 00                	push   $0x0
  pushl $134
  1022dc:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1022e1:	e9 ac 05 00 00       	jmp    102892 <__alltraps>

001022e6 <vector135>:
.globl vector135
vector135:
  pushl $0
  1022e6:	6a 00                	push   $0x0
  pushl $135
  1022e8:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1022ed:	e9 a0 05 00 00       	jmp    102892 <__alltraps>

001022f2 <vector136>:
.globl vector136
vector136:
  pushl $0
  1022f2:	6a 00                	push   $0x0
  pushl $136
  1022f4:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1022f9:	e9 94 05 00 00       	jmp    102892 <__alltraps>

001022fe <vector137>:
.globl vector137
vector137:
  pushl $0
  1022fe:	6a 00                	push   $0x0
  pushl $137
  102300:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102305:	e9 88 05 00 00       	jmp    102892 <__alltraps>

0010230a <vector138>:
.globl vector138
vector138:
  pushl $0
  10230a:	6a 00                	push   $0x0
  pushl $138
  10230c:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102311:	e9 7c 05 00 00       	jmp    102892 <__alltraps>

00102316 <vector139>:
.globl vector139
vector139:
  pushl $0
  102316:	6a 00                	push   $0x0
  pushl $139
  102318:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10231d:	e9 70 05 00 00       	jmp    102892 <__alltraps>

00102322 <vector140>:
.globl vector140
vector140:
  pushl $0
  102322:	6a 00                	push   $0x0
  pushl $140
  102324:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102329:	e9 64 05 00 00       	jmp    102892 <__alltraps>

0010232e <vector141>:
.globl vector141
vector141:
  pushl $0
  10232e:	6a 00                	push   $0x0
  pushl $141
  102330:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102335:	e9 58 05 00 00       	jmp    102892 <__alltraps>

0010233a <vector142>:
.globl vector142
vector142:
  pushl $0
  10233a:	6a 00                	push   $0x0
  pushl $142
  10233c:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102341:	e9 4c 05 00 00       	jmp    102892 <__alltraps>

00102346 <vector143>:
.globl vector143
vector143:
  pushl $0
  102346:	6a 00                	push   $0x0
  pushl $143
  102348:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10234d:	e9 40 05 00 00       	jmp    102892 <__alltraps>

00102352 <vector144>:
.globl vector144
vector144:
  pushl $0
  102352:	6a 00                	push   $0x0
  pushl $144
  102354:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102359:	e9 34 05 00 00       	jmp    102892 <__alltraps>

0010235e <vector145>:
.globl vector145
vector145:
  pushl $0
  10235e:	6a 00                	push   $0x0
  pushl $145
  102360:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102365:	e9 28 05 00 00       	jmp    102892 <__alltraps>

0010236a <vector146>:
.globl vector146
vector146:
  pushl $0
  10236a:	6a 00                	push   $0x0
  pushl $146
  10236c:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102371:	e9 1c 05 00 00       	jmp    102892 <__alltraps>

00102376 <vector147>:
.globl vector147
vector147:
  pushl $0
  102376:	6a 00                	push   $0x0
  pushl $147
  102378:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10237d:	e9 10 05 00 00       	jmp    102892 <__alltraps>

00102382 <vector148>:
.globl vector148
vector148:
  pushl $0
  102382:	6a 00                	push   $0x0
  pushl $148
  102384:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102389:	e9 04 05 00 00       	jmp    102892 <__alltraps>

0010238e <vector149>:
.globl vector149
vector149:
  pushl $0
  10238e:	6a 00                	push   $0x0
  pushl $149
  102390:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102395:	e9 f8 04 00 00       	jmp    102892 <__alltraps>

0010239a <vector150>:
.globl vector150
vector150:
  pushl $0
  10239a:	6a 00                	push   $0x0
  pushl $150
  10239c:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1023a1:	e9 ec 04 00 00       	jmp    102892 <__alltraps>

001023a6 <vector151>:
.globl vector151
vector151:
  pushl $0
  1023a6:	6a 00                	push   $0x0
  pushl $151
  1023a8:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1023ad:	e9 e0 04 00 00       	jmp    102892 <__alltraps>

001023b2 <vector152>:
.globl vector152
vector152:
  pushl $0
  1023b2:	6a 00                	push   $0x0
  pushl $152
  1023b4:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1023b9:	e9 d4 04 00 00       	jmp    102892 <__alltraps>

001023be <vector153>:
.globl vector153
vector153:
  pushl $0
  1023be:	6a 00                	push   $0x0
  pushl $153
  1023c0:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1023c5:	e9 c8 04 00 00       	jmp    102892 <__alltraps>

001023ca <vector154>:
.globl vector154
vector154:
  pushl $0
  1023ca:	6a 00                	push   $0x0
  pushl $154
  1023cc:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1023d1:	e9 bc 04 00 00       	jmp    102892 <__alltraps>

001023d6 <vector155>:
.globl vector155
vector155:
  pushl $0
  1023d6:	6a 00                	push   $0x0
  pushl $155
  1023d8:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1023dd:	e9 b0 04 00 00       	jmp    102892 <__alltraps>

001023e2 <vector156>:
.globl vector156
vector156:
  pushl $0
  1023e2:	6a 00                	push   $0x0
  pushl $156
  1023e4:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1023e9:	e9 a4 04 00 00       	jmp    102892 <__alltraps>

001023ee <vector157>:
.globl vector157
vector157:
  pushl $0
  1023ee:	6a 00                	push   $0x0
  pushl $157
  1023f0:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1023f5:	e9 98 04 00 00       	jmp    102892 <__alltraps>

001023fa <vector158>:
.globl vector158
vector158:
  pushl $0
  1023fa:	6a 00                	push   $0x0
  pushl $158
  1023fc:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102401:	e9 8c 04 00 00       	jmp    102892 <__alltraps>

00102406 <vector159>:
.globl vector159
vector159:
  pushl $0
  102406:	6a 00                	push   $0x0
  pushl $159
  102408:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10240d:	e9 80 04 00 00       	jmp    102892 <__alltraps>

00102412 <vector160>:
.globl vector160
vector160:
  pushl $0
  102412:	6a 00                	push   $0x0
  pushl $160
  102414:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102419:	e9 74 04 00 00       	jmp    102892 <__alltraps>

0010241e <vector161>:
.globl vector161
vector161:
  pushl $0
  10241e:	6a 00                	push   $0x0
  pushl $161
  102420:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102425:	e9 68 04 00 00       	jmp    102892 <__alltraps>

0010242a <vector162>:
.globl vector162
vector162:
  pushl $0
  10242a:	6a 00                	push   $0x0
  pushl $162
  10242c:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102431:	e9 5c 04 00 00       	jmp    102892 <__alltraps>

00102436 <vector163>:
.globl vector163
vector163:
  pushl $0
  102436:	6a 00                	push   $0x0
  pushl $163
  102438:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10243d:	e9 50 04 00 00       	jmp    102892 <__alltraps>

00102442 <vector164>:
.globl vector164
vector164:
  pushl $0
  102442:	6a 00                	push   $0x0
  pushl $164
  102444:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102449:	e9 44 04 00 00       	jmp    102892 <__alltraps>

0010244e <vector165>:
.globl vector165
vector165:
  pushl $0
  10244e:	6a 00                	push   $0x0
  pushl $165
  102450:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102455:	e9 38 04 00 00       	jmp    102892 <__alltraps>

0010245a <vector166>:
.globl vector166
vector166:
  pushl $0
  10245a:	6a 00                	push   $0x0
  pushl $166
  10245c:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102461:	e9 2c 04 00 00       	jmp    102892 <__alltraps>

00102466 <vector167>:
.globl vector167
vector167:
  pushl $0
  102466:	6a 00                	push   $0x0
  pushl $167
  102468:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10246d:	e9 20 04 00 00       	jmp    102892 <__alltraps>

00102472 <vector168>:
.globl vector168
vector168:
  pushl $0
  102472:	6a 00                	push   $0x0
  pushl $168
  102474:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102479:	e9 14 04 00 00       	jmp    102892 <__alltraps>

0010247e <vector169>:
.globl vector169
vector169:
  pushl $0
  10247e:	6a 00                	push   $0x0
  pushl $169
  102480:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102485:	e9 08 04 00 00       	jmp    102892 <__alltraps>

0010248a <vector170>:
.globl vector170
vector170:
  pushl $0
  10248a:	6a 00                	push   $0x0
  pushl $170
  10248c:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102491:	e9 fc 03 00 00       	jmp    102892 <__alltraps>

00102496 <vector171>:
.globl vector171
vector171:
  pushl $0
  102496:	6a 00                	push   $0x0
  pushl $171
  102498:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10249d:	e9 f0 03 00 00       	jmp    102892 <__alltraps>

001024a2 <vector172>:
.globl vector172
vector172:
  pushl $0
  1024a2:	6a 00                	push   $0x0
  pushl $172
  1024a4:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1024a9:	e9 e4 03 00 00       	jmp    102892 <__alltraps>

001024ae <vector173>:
.globl vector173
vector173:
  pushl $0
  1024ae:	6a 00                	push   $0x0
  pushl $173
  1024b0:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1024b5:	e9 d8 03 00 00       	jmp    102892 <__alltraps>

001024ba <vector174>:
.globl vector174
vector174:
  pushl $0
  1024ba:	6a 00                	push   $0x0
  pushl $174
  1024bc:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1024c1:	e9 cc 03 00 00       	jmp    102892 <__alltraps>

001024c6 <vector175>:
.globl vector175
vector175:
  pushl $0
  1024c6:	6a 00                	push   $0x0
  pushl $175
  1024c8:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1024cd:	e9 c0 03 00 00       	jmp    102892 <__alltraps>

001024d2 <vector176>:
.globl vector176
vector176:
  pushl $0
  1024d2:	6a 00                	push   $0x0
  pushl $176
  1024d4:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1024d9:	e9 b4 03 00 00       	jmp    102892 <__alltraps>

001024de <vector177>:
.globl vector177
vector177:
  pushl $0
  1024de:	6a 00                	push   $0x0
  pushl $177
  1024e0:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1024e5:	e9 a8 03 00 00       	jmp    102892 <__alltraps>

001024ea <vector178>:
.globl vector178
vector178:
  pushl $0
  1024ea:	6a 00                	push   $0x0
  pushl $178
  1024ec:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1024f1:	e9 9c 03 00 00       	jmp    102892 <__alltraps>

001024f6 <vector179>:
.globl vector179
vector179:
  pushl $0
  1024f6:	6a 00                	push   $0x0
  pushl $179
  1024f8:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1024fd:	e9 90 03 00 00       	jmp    102892 <__alltraps>

00102502 <vector180>:
.globl vector180
vector180:
  pushl $0
  102502:	6a 00                	push   $0x0
  pushl $180
  102504:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102509:	e9 84 03 00 00       	jmp    102892 <__alltraps>

0010250e <vector181>:
.globl vector181
vector181:
  pushl $0
  10250e:	6a 00                	push   $0x0
  pushl $181
  102510:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102515:	e9 78 03 00 00       	jmp    102892 <__alltraps>

0010251a <vector182>:
.globl vector182
vector182:
  pushl $0
  10251a:	6a 00                	push   $0x0
  pushl $182
  10251c:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102521:	e9 6c 03 00 00       	jmp    102892 <__alltraps>

00102526 <vector183>:
.globl vector183
vector183:
  pushl $0
  102526:	6a 00                	push   $0x0
  pushl $183
  102528:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10252d:	e9 60 03 00 00       	jmp    102892 <__alltraps>

00102532 <vector184>:
.globl vector184
vector184:
  pushl $0
  102532:	6a 00                	push   $0x0
  pushl $184
  102534:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102539:	e9 54 03 00 00       	jmp    102892 <__alltraps>

0010253e <vector185>:
.globl vector185
vector185:
  pushl $0
  10253e:	6a 00                	push   $0x0
  pushl $185
  102540:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102545:	e9 48 03 00 00       	jmp    102892 <__alltraps>

0010254a <vector186>:
.globl vector186
vector186:
  pushl $0
  10254a:	6a 00                	push   $0x0
  pushl $186
  10254c:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102551:	e9 3c 03 00 00       	jmp    102892 <__alltraps>

00102556 <vector187>:
.globl vector187
vector187:
  pushl $0
  102556:	6a 00                	push   $0x0
  pushl $187
  102558:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10255d:	e9 30 03 00 00       	jmp    102892 <__alltraps>

00102562 <vector188>:
.globl vector188
vector188:
  pushl $0
  102562:	6a 00                	push   $0x0
  pushl $188
  102564:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102569:	e9 24 03 00 00       	jmp    102892 <__alltraps>

0010256e <vector189>:
.globl vector189
vector189:
  pushl $0
  10256e:	6a 00                	push   $0x0
  pushl $189
  102570:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102575:	e9 18 03 00 00       	jmp    102892 <__alltraps>

0010257a <vector190>:
.globl vector190
vector190:
  pushl $0
  10257a:	6a 00                	push   $0x0
  pushl $190
  10257c:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102581:	e9 0c 03 00 00       	jmp    102892 <__alltraps>

00102586 <vector191>:
.globl vector191
vector191:
  pushl $0
  102586:	6a 00                	push   $0x0
  pushl $191
  102588:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10258d:	e9 00 03 00 00       	jmp    102892 <__alltraps>

00102592 <vector192>:
.globl vector192
vector192:
  pushl $0
  102592:	6a 00                	push   $0x0
  pushl $192
  102594:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102599:	e9 f4 02 00 00       	jmp    102892 <__alltraps>

0010259e <vector193>:
.globl vector193
vector193:
  pushl $0
  10259e:	6a 00                	push   $0x0
  pushl $193
  1025a0:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1025a5:	e9 e8 02 00 00       	jmp    102892 <__alltraps>

001025aa <vector194>:
.globl vector194
vector194:
  pushl $0
  1025aa:	6a 00                	push   $0x0
  pushl $194
  1025ac:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1025b1:	e9 dc 02 00 00       	jmp    102892 <__alltraps>

001025b6 <vector195>:
.globl vector195
vector195:
  pushl $0
  1025b6:	6a 00                	push   $0x0
  pushl $195
  1025b8:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1025bd:	e9 d0 02 00 00       	jmp    102892 <__alltraps>

001025c2 <vector196>:
.globl vector196
vector196:
  pushl $0
  1025c2:	6a 00                	push   $0x0
  pushl $196
  1025c4:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1025c9:	e9 c4 02 00 00       	jmp    102892 <__alltraps>

001025ce <vector197>:
.globl vector197
vector197:
  pushl $0
  1025ce:	6a 00                	push   $0x0
  pushl $197
  1025d0:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1025d5:	e9 b8 02 00 00       	jmp    102892 <__alltraps>

001025da <vector198>:
.globl vector198
vector198:
  pushl $0
  1025da:	6a 00                	push   $0x0
  pushl $198
  1025dc:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1025e1:	e9 ac 02 00 00       	jmp    102892 <__alltraps>

001025e6 <vector199>:
.globl vector199
vector199:
  pushl $0
  1025e6:	6a 00                	push   $0x0
  pushl $199
  1025e8:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1025ed:	e9 a0 02 00 00       	jmp    102892 <__alltraps>

001025f2 <vector200>:
.globl vector200
vector200:
  pushl $0
  1025f2:	6a 00                	push   $0x0
  pushl $200
  1025f4:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1025f9:	e9 94 02 00 00       	jmp    102892 <__alltraps>

001025fe <vector201>:
.globl vector201
vector201:
  pushl $0
  1025fe:	6a 00                	push   $0x0
  pushl $201
  102600:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102605:	e9 88 02 00 00       	jmp    102892 <__alltraps>

0010260a <vector202>:
.globl vector202
vector202:
  pushl $0
  10260a:	6a 00                	push   $0x0
  pushl $202
  10260c:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102611:	e9 7c 02 00 00       	jmp    102892 <__alltraps>

00102616 <vector203>:
.globl vector203
vector203:
  pushl $0
  102616:	6a 00                	push   $0x0
  pushl $203
  102618:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10261d:	e9 70 02 00 00       	jmp    102892 <__alltraps>

00102622 <vector204>:
.globl vector204
vector204:
  pushl $0
  102622:	6a 00                	push   $0x0
  pushl $204
  102624:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102629:	e9 64 02 00 00       	jmp    102892 <__alltraps>

0010262e <vector205>:
.globl vector205
vector205:
  pushl $0
  10262e:	6a 00                	push   $0x0
  pushl $205
  102630:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102635:	e9 58 02 00 00       	jmp    102892 <__alltraps>

0010263a <vector206>:
.globl vector206
vector206:
  pushl $0
  10263a:	6a 00                	push   $0x0
  pushl $206
  10263c:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102641:	e9 4c 02 00 00       	jmp    102892 <__alltraps>

00102646 <vector207>:
.globl vector207
vector207:
  pushl $0
  102646:	6a 00                	push   $0x0
  pushl $207
  102648:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10264d:	e9 40 02 00 00       	jmp    102892 <__alltraps>

00102652 <vector208>:
.globl vector208
vector208:
  pushl $0
  102652:	6a 00                	push   $0x0
  pushl $208
  102654:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102659:	e9 34 02 00 00       	jmp    102892 <__alltraps>

0010265e <vector209>:
.globl vector209
vector209:
  pushl $0
  10265e:	6a 00                	push   $0x0
  pushl $209
  102660:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102665:	e9 28 02 00 00       	jmp    102892 <__alltraps>

0010266a <vector210>:
.globl vector210
vector210:
  pushl $0
  10266a:	6a 00                	push   $0x0
  pushl $210
  10266c:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102671:	e9 1c 02 00 00       	jmp    102892 <__alltraps>

00102676 <vector211>:
.globl vector211
vector211:
  pushl $0
  102676:	6a 00                	push   $0x0
  pushl $211
  102678:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10267d:	e9 10 02 00 00       	jmp    102892 <__alltraps>

00102682 <vector212>:
.globl vector212
vector212:
  pushl $0
  102682:	6a 00                	push   $0x0
  pushl $212
  102684:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102689:	e9 04 02 00 00       	jmp    102892 <__alltraps>

0010268e <vector213>:
.globl vector213
vector213:
  pushl $0
  10268e:	6a 00                	push   $0x0
  pushl $213
  102690:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102695:	e9 f8 01 00 00       	jmp    102892 <__alltraps>

0010269a <vector214>:
.globl vector214
vector214:
  pushl $0
  10269a:	6a 00                	push   $0x0
  pushl $214
  10269c:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1026a1:	e9 ec 01 00 00       	jmp    102892 <__alltraps>

001026a6 <vector215>:
.globl vector215
vector215:
  pushl $0
  1026a6:	6a 00                	push   $0x0
  pushl $215
  1026a8:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1026ad:	e9 e0 01 00 00       	jmp    102892 <__alltraps>

001026b2 <vector216>:
.globl vector216
vector216:
  pushl $0
  1026b2:	6a 00                	push   $0x0
  pushl $216
  1026b4:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1026b9:	e9 d4 01 00 00       	jmp    102892 <__alltraps>

001026be <vector217>:
.globl vector217
vector217:
  pushl $0
  1026be:	6a 00                	push   $0x0
  pushl $217
  1026c0:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1026c5:	e9 c8 01 00 00       	jmp    102892 <__alltraps>

001026ca <vector218>:
.globl vector218
vector218:
  pushl $0
  1026ca:	6a 00                	push   $0x0
  pushl $218
  1026cc:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1026d1:	e9 bc 01 00 00       	jmp    102892 <__alltraps>

001026d6 <vector219>:
.globl vector219
vector219:
  pushl $0
  1026d6:	6a 00                	push   $0x0
  pushl $219
  1026d8:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1026dd:	e9 b0 01 00 00       	jmp    102892 <__alltraps>

001026e2 <vector220>:
.globl vector220
vector220:
  pushl $0
  1026e2:	6a 00                	push   $0x0
  pushl $220
  1026e4:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1026e9:	e9 a4 01 00 00       	jmp    102892 <__alltraps>

001026ee <vector221>:
.globl vector221
vector221:
  pushl $0
  1026ee:	6a 00                	push   $0x0
  pushl $221
  1026f0:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1026f5:	e9 98 01 00 00       	jmp    102892 <__alltraps>

001026fa <vector222>:
.globl vector222
vector222:
  pushl $0
  1026fa:	6a 00                	push   $0x0
  pushl $222
  1026fc:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102701:	e9 8c 01 00 00       	jmp    102892 <__alltraps>

00102706 <vector223>:
.globl vector223
vector223:
  pushl $0
  102706:	6a 00                	push   $0x0
  pushl $223
  102708:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10270d:	e9 80 01 00 00       	jmp    102892 <__alltraps>

00102712 <vector224>:
.globl vector224
vector224:
  pushl $0
  102712:	6a 00                	push   $0x0
  pushl $224
  102714:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102719:	e9 74 01 00 00       	jmp    102892 <__alltraps>

0010271e <vector225>:
.globl vector225
vector225:
  pushl $0
  10271e:	6a 00                	push   $0x0
  pushl $225
  102720:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102725:	e9 68 01 00 00       	jmp    102892 <__alltraps>

0010272a <vector226>:
.globl vector226
vector226:
  pushl $0
  10272a:	6a 00                	push   $0x0
  pushl $226
  10272c:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102731:	e9 5c 01 00 00       	jmp    102892 <__alltraps>

00102736 <vector227>:
.globl vector227
vector227:
  pushl $0
  102736:	6a 00                	push   $0x0
  pushl $227
  102738:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10273d:	e9 50 01 00 00       	jmp    102892 <__alltraps>

00102742 <vector228>:
.globl vector228
vector228:
  pushl $0
  102742:	6a 00                	push   $0x0
  pushl $228
  102744:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102749:	e9 44 01 00 00       	jmp    102892 <__alltraps>

0010274e <vector229>:
.globl vector229
vector229:
  pushl $0
  10274e:	6a 00                	push   $0x0
  pushl $229
  102750:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102755:	e9 38 01 00 00       	jmp    102892 <__alltraps>

0010275a <vector230>:
.globl vector230
vector230:
  pushl $0
  10275a:	6a 00                	push   $0x0
  pushl $230
  10275c:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102761:	e9 2c 01 00 00       	jmp    102892 <__alltraps>

00102766 <vector231>:
.globl vector231
vector231:
  pushl $0
  102766:	6a 00                	push   $0x0
  pushl $231
  102768:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  10276d:	e9 20 01 00 00       	jmp    102892 <__alltraps>

00102772 <vector232>:
.globl vector232
vector232:
  pushl $0
  102772:	6a 00                	push   $0x0
  pushl $232
  102774:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102779:	e9 14 01 00 00       	jmp    102892 <__alltraps>

0010277e <vector233>:
.globl vector233
vector233:
  pushl $0
  10277e:	6a 00                	push   $0x0
  pushl $233
  102780:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102785:	e9 08 01 00 00       	jmp    102892 <__alltraps>

0010278a <vector234>:
.globl vector234
vector234:
  pushl $0
  10278a:	6a 00                	push   $0x0
  pushl $234
  10278c:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102791:	e9 fc 00 00 00       	jmp    102892 <__alltraps>

00102796 <vector235>:
.globl vector235
vector235:
  pushl $0
  102796:	6a 00                	push   $0x0
  pushl $235
  102798:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10279d:	e9 f0 00 00 00       	jmp    102892 <__alltraps>

001027a2 <vector236>:
.globl vector236
vector236:
  pushl $0
  1027a2:	6a 00                	push   $0x0
  pushl $236
  1027a4:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1027a9:	e9 e4 00 00 00       	jmp    102892 <__alltraps>

001027ae <vector237>:
.globl vector237
vector237:
  pushl $0
  1027ae:	6a 00                	push   $0x0
  pushl $237
  1027b0:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1027b5:	e9 d8 00 00 00       	jmp    102892 <__alltraps>

001027ba <vector238>:
.globl vector238
vector238:
  pushl $0
  1027ba:	6a 00                	push   $0x0
  pushl $238
  1027bc:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1027c1:	e9 cc 00 00 00       	jmp    102892 <__alltraps>

001027c6 <vector239>:
.globl vector239
vector239:
  pushl $0
  1027c6:	6a 00                	push   $0x0
  pushl $239
  1027c8:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1027cd:	e9 c0 00 00 00       	jmp    102892 <__alltraps>

001027d2 <vector240>:
.globl vector240
vector240:
  pushl $0
  1027d2:	6a 00                	push   $0x0
  pushl $240
  1027d4:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1027d9:	e9 b4 00 00 00       	jmp    102892 <__alltraps>

001027de <vector241>:
.globl vector241
vector241:
  pushl $0
  1027de:	6a 00                	push   $0x0
  pushl $241
  1027e0:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1027e5:	e9 a8 00 00 00       	jmp    102892 <__alltraps>

001027ea <vector242>:
.globl vector242
vector242:
  pushl $0
  1027ea:	6a 00                	push   $0x0
  pushl $242
  1027ec:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1027f1:	e9 9c 00 00 00       	jmp    102892 <__alltraps>

001027f6 <vector243>:
.globl vector243
vector243:
  pushl $0
  1027f6:	6a 00                	push   $0x0
  pushl $243
  1027f8:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1027fd:	e9 90 00 00 00       	jmp    102892 <__alltraps>

00102802 <vector244>:
.globl vector244
vector244:
  pushl $0
  102802:	6a 00                	push   $0x0
  pushl $244
  102804:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102809:	e9 84 00 00 00       	jmp    102892 <__alltraps>

0010280e <vector245>:
.globl vector245
vector245:
  pushl $0
  10280e:	6a 00                	push   $0x0
  pushl $245
  102810:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102815:	e9 78 00 00 00       	jmp    102892 <__alltraps>

0010281a <vector246>:
.globl vector246
vector246:
  pushl $0
  10281a:	6a 00                	push   $0x0
  pushl $246
  10281c:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102821:	e9 6c 00 00 00       	jmp    102892 <__alltraps>

00102826 <vector247>:
.globl vector247
vector247:
  pushl $0
  102826:	6a 00                	push   $0x0
  pushl $247
  102828:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  10282d:	e9 60 00 00 00       	jmp    102892 <__alltraps>

00102832 <vector248>:
.globl vector248
vector248:
  pushl $0
  102832:	6a 00                	push   $0x0
  pushl $248
  102834:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102839:	e9 54 00 00 00       	jmp    102892 <__alltraps>

0010283e <vector249>:
.globl vector249
vector249:
  pushl $0
  10283e:	6a 00                	push   $0x0
  pushl $249
  102840:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102845:	e9 48 00 00 00       	jmp    102892 <__alltraps>

0010284a <vector250>:
.globl vector250
vector250:
  pushl $0
  10284a:	6a 00                	push   $0x0
  pushl $250
  10284c:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102851:	e9 3c 00 00 00       	jmp    102892 <__alltraps>

00102856 <vector251>:
.globl vector251
vector251:
  pushl $0
  102856:	6a 00                	push   $0x0
  pushl $251
  102858:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  10285d:	e9 30 00 00 00       	jmp    102892 <__alltraps>

00102862 <vector252>:
.globl vector252
vector252:
  pushl $0
  102862:	6a 00                	push   $0x0
  pushl $252
  102864:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102869:	e9 24 00 00 00       	jmp    102892 <__alltraps>

0010286e <vector253>:
.globl vector253
vector253:
  pushl $0
  10286e:	6a 00                	push   $0x0
  pushl $253
  102870:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102875:	e9 18 00 00 00       	jmp    102892 <__alltraps>

0010287a <vector254>:
.globl vector254
vector254:
  pushl $0
  10287a:	6a 00                	push   $0x0
  pushl $254
  10287c:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102881:	e9 0c 00 00 00       	jmp    102892 <__alltraps>

00102886 <vector255>:
.globl vector255
vector255:
  pushl $0
  102886:	6a 00                	push   $0x0
  pushl $255
  102888:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10288d:	e9 00 00 00 00       	jmp    102892 <__alltraps>

00102892 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102892:	1e                   	push   %ds
    pushl %es
  102893:	06                   	push   %es
    pushl %fs
  102894:	0f a0                	push   %fs
    pushl %gs
  102896:	0f a8                	push   %gs
    pushal
  102898:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102899:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10289e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  1028a0:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  1028a2:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  1028a3:	e8 61 f5 ff ff       	call   101e09 <trap>

    # pop the pushed stack pointer
    popl %esp
  1028a8:	5c                   	pop    %esp

001028a9 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  1028a9:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  1028aa:	0f a9                	pop    %gs
    popl %fs
  1028ac:	0f a1                	pop    %fs
    popl %es
  1028ae:	07                   	pop    %es
    popl %ds
  1028af:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  1028b0:	83 c4 08             	add    $0x8,%esp
    iret
  1028b3:	cf                   	iret   

001028b4 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1028b4:	55                   	push   %ebp
  1028b5:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1028b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1028ba:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  1028c0:	29 d0                	sub    %edx,%eax
  1028c2:	c1 f8 02             	sar    $0x2,%eax
  1028c5:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1028cb:	5d                   	pop    %ebp
  1028cc:	c3                   	ret    

001028cd <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1028cd:	55                   	push   %ebp
  1028ce:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
  1028d0:	ff 75 08             	pushl  0x8(%ebp)
  1028d3:	e8 dc ff ff ff       	call   1028b4 <page2ppn>
  1028d8:	83 c4 04             	add    $0x4,%esp
  1028db:	c1 e0 0c             	shl    $0xc,%eax
}
  1028de:	c9                   	leave  
  1028df:	c3                   	ret    

001028e0 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  1028e0:	55                   	push   %ebp
  1028e1:	89 e5                	mov    %esp,%ebp
  1028e3:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
  1028e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1028e9:	c1 e8 0c             	shr    $0xc,%eax
  1028ec:	89 c2                	mov    %eax,%edx
  1028ee:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1028f3:	39 c2                	cmp    %eax,%edx
  1028f5:	72 14                	jb     10290b <pa2page+0x2b>
        panic("pa2page called with invalid pa");
  1028f7:	83 ec 04             	sub    $0x4,%esp
  1028fa:	68 b0 61 10 00       	push   $0x1061b0
  1028ff:	6a 5a                	push   $0x5a
  102901:	68 cf 61 10 00       	push   $0x1061cf
  102906:	e8 ce da ff ff       	call   1003d9 <__panic>
    }
    return &pages[PPN(pa)];
  10290b:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  102911:	8b 45 08             	mov    0x8(%ebp),%eax
  102914:	c1 e8 0c             	shr    $0xc,%eax
  102917:	89 c2                	mov    %eax,%edx
  102919:	89 d0                	mov    %edx,%eax
  10291b:	c1 e0 02             	shl    $0x2,%eax
  10291e:	01 d0                	add    %edx,%eax
  102920:	c1 e0 02             	shl    $0x2,%eax
  102923:	01 c8                	add    %ecx,%eax
}
  102925:	c9                   	leave  
  102926:	c3                   	ret    

00102927 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  102927:	55                   	push   %ebp
  102928:	89 e5                	mov    %esp,%ebp
  10292a:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
  10292d:	ff 75 08             	pushl  0x8(%ebp)
  102930:	e8 98 ff ff ff       	call   1028cd <page2pa>
  102935:	83 c4 04             	add    $0x4,%esp
  102938:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10293b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10293e:	c1 e8 0c             	shr    $0xc,%eax
  102941:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102944:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102949:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  10294c:	72 14                	jb     102962 <page2kva+0x3b>
  10294e:	ff 75 f4             	pushl  -0xc(%ebp)
  102951:	68 e0 61 10 00       	push   $0x1061e0
  102956:	6a 61                	push   $0x61
  102958:	68 cf 61 10 00       	push   $0x1061cf
  10295d:	e8 77 da ff ff       	call   1003d9 <__panic>
  102962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102965:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  10296a:	c9                   	leave  
  10296b:	c3                   	ret    

0010296c <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  10296c:	55                   	push   %ebp
  10296d:	89 e5                	mov    %esp,%ebp
  10296f:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
  102972:	8b 45 08             	mov    0x8(%ebp),%eax
  102975:	83 e0 01             	and    $0x1,%eax
  102978:	85 c0                	test   %eax,%eax
  10297a:	75 14                	jne    102990 <pte2page+0x24>
        panic("pte2page called with invalid pte");
  10297c:	83 ec 04             	sub    $0x4,%esp
  10297f:	68 04 62 10 00       	push   $0x106204
  102984:	6a 6c                	push   $0x6c
  102986:	68 cf 61 10 00       	push   $0x1061cf
  10298b:	e8 49 da ff ff       	call   1003d9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102990:	8b 45 08             	mov    0x8(%ebp),%eax
  102993:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102998:	83 ec 0c             	sub    $0xc,%esp
  10299b:	50                   	push   %eax
  10299c:	e8 3f ff ff ff       	call   1028e0 <pa2page>
  1029a1:	83 c4 10             	add    $0x10,%esp
}
  1029a4:	c9                   	leave  
  1029a5:	c3                   	ret    

001029a6 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  1029a6:	55                   	push   %ebp
  1029a7:	89 e5                	mov    %esp,%ebp
  1029a9:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
  1029ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1029af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1029b4:	83 ec 0c             	sub    $0xc,%esp
  1029b7:	50                   	push   %eax
  1029b8:	e8 23 ff ff ff       	call   1028e0 <pa2page>
  1029bd:	83 c4 10             	add    $0x10,%esp
}
  1029c0:	c9                   	leave  
  1029c1:	c3                   	ret    

001029c2 <page_ref>:

static inline int
page_ref(struct Page *page) {
  1029c2:	55                   	push   %ebp
  1029c3:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1029c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1029c8:	8b 00                	mov    (%eax),%eax
}
  1029ca:	5d                   	pop    %ebp
  1029cb:	c3                   	ret    

001029cc <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1029cc:	55                   	push   %ebp
  1029cd:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1029cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1029d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029d5:	89 10                	mov    %edx,(%eax)
}
  1029d7:	90                   	nop
  1029d8:	5d                   	pop    %ebp
  1029d9:	c3                   	ret    

001029da <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  1029da:	55                   	push   %ebp
  1029db:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  1029dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1029e0:	8b 00                	mov    (%eax),%eax
  1029e2:	8d 50 01             	lea    0x1(%eax),%edx
  1029e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1029e8:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1029ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ed:	8b 00                	mov    (%eax),%eax
}
  1029ef:	5d                   	pop    %ebp
  1029f0:	c3                   	ret    

001029f1 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  1029f1:	55                   	push   %ebp
  1029f2:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  1029f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f7:	8b 00                	mov    (%eax),%eax
  1029f9:	8d 50 ff             	lea    -0x1(%eax),%edx
  1029fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ff:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102a01:	8b 45 08             	mov    0x8(%ebp),%eax
  102a04:	8b 00                	mov    (%eax),%eax
}
  102a06:	5d                   	pop    %ebp
  102a07:	c3                   	ret    

00102a08 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  102a08:	55                   	push   %ebp
  102a09:	89 e5                	mov    %esp,%ebp
  102a0b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102a0e:	9c                   	pushf  
  102a0f:	58                   	pop    %eax
  102a10:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102a16:	25 00 02 00 00       	and    $0x200,%eax
  102a1b:	85 c0                	test   %eax,%eax
  102a1d:	74 0c                	je     102a2b <__intr_save+0x23>
        intr_disable();
  102a1f:	e8 64 ee ff ff       	call   101888 <intr_disable>
        return 1;
  102a24:	b8 01 00 00 00       	mov    $0x1,%eax
  102a29:	eb 05                	jmp    102a30 <__intr_save+0x28>
    }
    return 0;
  102a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102a30:	c9                   	leave  
  102a31:	c3                   	ret    

00102a32 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  102a32:	55                   	push   %ebp
  102a33:	89 e5                	mov    %esp,%ebp
  102a35:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102a38:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a3c:	74 05                	je     102a43 <__intr_restore+0x11>
        intr_enable();
  102a3e:	e8 3e ee ff ff       	call   101881 <intr_enable>
    }
}
  102a43:	90                   	nop
  102a44:	c9                   	leave  
  102a45:	c3                   	ret    

00102a46 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102a46:	55                   	push   %ebp
  102a47:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102a49:	8b 45 08             	mov    0x8(%ebp),%eax
  102a4c:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a4f:	b8 23 00 00 00       	mov    $0x23,%eax
  102a54:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a56:	b8 23 00 00 00       	mov    $0x23,%eax
  102a5b:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a5d:	b8 10 00 00 00       	mov    $0x10,%eax
  102a62:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a64:	b8 10 00 00 00       	mov    $0x10,%eax
  102a69:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a6b:	b8 10 00 00 00       	mov    $0x10,%eax
  102a70:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a72:	ea 79 2a 10 00 08 00 	ljmp   $0x8,$0x102a79
}
  102a79:	90                   	nop
  102a7a:	5d                   	pop    %ebp
  102a7b:	c3                   	ret    

00102a7c <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102a7c:	55                   	push   %ebp
  102a7d:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  102a82:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  102a87:	90                   	nop
  102a88:	5d                   	pop    %ebp
  102a89:	c3                   	ret    

00102a8a <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a8a:	55                   	push   %ebp
  102a8b:	89 e5                	mov    %esp,%ebp
  102a8d:	83 ec 10             	sub    $0x10,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102a90:	b8 00 70 11 00       	mov    $0x117000,%eax
  102a95:	50                   	push   %eax
  102a96:	e8 e1 ff ff ff       	call   102a7c <load_esp0>
  102a9b:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
  102a9e:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  102aa5:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102aa7:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  102aae:	68 00 
  102ab0:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102ab5:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  102abb:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102ac0:	c1 e8 10             	shr    $0x10,%eax
  102ac3:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  102ac8:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102acf:	83 e0 f0             	and    $0xfffffff0,%eax
  102ad2:	83 c8 09             	or     $0x9,%eax
  102ad5:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102ada:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ae1:	83 e0 ef             	and    $0xffffffef,%eax
  102ae4:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102ae9:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102af0:	83 e0 9f             	and    $0xffffff9f,%eax
  102af3:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102af8:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102aff:	83 c8 80             	or     $0xffffff80,%eax
  102b02:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b07:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b0e:	83 e0 f0             	and    $0xfffffff0,%eax
  102b11:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b16:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b1d:	83 e0 ef             	and    $0xffffffef,%eax
  102b20:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b25:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b2c:	83 e0 df             	and    $0xffffffdf,%eax
  102b2f:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b34:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b3b:	83 c8 40             	or     $0x40,%eax
  102b3e:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b43:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b4a:	83 e0 7f             	and    $0x7f,%eax
  102b4d:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b52:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102b57:	c1 e8 18             	shr    $0x18,%eax
  102b5a:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b5f:	68 30 7a 11 00       	push   $0x117a30
  102b64:	e8 dd fe ff ff       	call   102a46 <lgdt>
  102b69:	83 c4 04             	add    $0x4,%esp
  102b6c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102b72:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b76:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b79:	90                   	nop
  102b7a:	c9                   	leave  
  102b7b:	c3                   	ret    

00102b7c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102b7c:	55                   	push   %ebp
  102b7d:	89 e5                	mov    %esp,%ebp
  102b7f:	83 ec 08             	sub    $0x8,%esp
    pmm_manager = &default_pmm_manager;
  102b82:	c7 05 10 af 11 00 90 	movl   $0x106b90,0x11af10
  102b89:	6b 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102b8c:	a1 10 af 11 00       	mov    0x11af10,%eax
  102b91:	8b 00                	mov    (%eax),%eax
  102b93:	83 ec 08             	sub    $0x8,%esp
  102b96:	50                   	push   %eax
  102b97:	68 30 62 10 00       	push   $0x106230
  102b9c:	e8 d2 d6 ff ff       	call   100273 <cprintf>
  102ba1:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
  102ba4:	a1 10 af 11 00       	mov    0x11af10,%eax
  102ba9:	8b 40 04             	mov    0x4(%eax),%eax
  102bac:	ff d0                	call   *%eax
}
  102bae:	90                   	nop
  102baf:	c9                   	leave  
  102bb0:	c3                   	ret    

00102bb1 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102bb1:	55                   	push   %ebp
  102bb2:	89 e5                	mov    %esp,%ebp
  102bb4:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->init_memmap(base, n);
  102bb7:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bbc:	8b 40 08             	mov    0x8(%eax),%eax
  102bbf:	83 ec 08             	sub    $0x8,%esp
  102bc2:	ff 75 0c             	pushl  0xc(%ebp)
  102bc5:	ff 75 08             	pushl  0x8(%ebp)
  102bc8:	ff d0                	call   *%eax
  102bca:	83 c4 10             	add    $0x10,%esp
}
  102bcd:	90                   	nop
  102bce:	c9                   	leave  
  102bcf:	c3                   	ret    

00102bd0 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102bd0:	55                   	push   %ebp
  102bd1:	89 e5                	mov    %esp,%ebp
  102bd3:	83 ec 18             	sub    $0x18,%esp
    struct Page *page=NULL;
  102bd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102bdd:	e8 26 fe ff ff       	call   102a08 <__intr_save>
  102be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102be5:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bea:	8b 40 0c             	mov    0xc(%eax),%eax
  102bed:	83 ec 0c             	sub    $0xc,%esp
  102bf0:	ff 75 08             	pushl  0x8(%ebp)
  102bf3:	ff d0                	call   *%eax
  102bf5:	83 c4 10             	add    $0x10,%esp
  102bf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102bfb:	83 ec 0c             	sub    $0xc,%esp
  102bfe:	ff 75 f0             	pushl  -0x10(%ebp)
  102c01:	e8 2c fe ff ff       	call   102a32 <__intr_restore>
  102c06:	83 c4 10             	add    $0x10,%esp
    return page;
  102c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102c0c:	c9                   	leave  
  102c0d:	c3                   	ret    

00102c0e <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102c0e:	55                   	push   %ebp
  102c0f:	89 e5                	mov    %esp,%ebp
  102c11:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102c14:	e8 ef fd ff ff       	call   102a08 <__intr_save>
  102c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102c1c:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c21:	8b 40 10             	mov    0x10(%eax),%eax
  102c24:	83 ec 08             	sub    $0x8,%esp
  102c27:	ff 75 0c             	pushl  0xc(%ebp)
  102c2a:	ff 75 08             	pushl  0x8(%ebp)
  102c2d:	ff d0                	call   *%eax
  102c2f:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
  102c32:	83 ec 0c             	sub    $0xc,%esp
  102c35:	ff 75 f4             	pushl  -0xc(%ebp)
  102c38:	e8 f5 fd ff ff       	call   102a32 <__intr_restore>
  102c3d:	83 c4 10             	add    $0x10,%esp
}
  102c40:	90                   	nop
  102c41:	c9                   	leave  
  102c42:	c3                   	ret    

00102c43 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102c43:	55                   	push   %ebp
  102c44:	89 e5                	mov    %esp,%ebp
  102c46:	83 ec 18             	sub    $0x18,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102c49:	e8 ba fd ff ff       	call   102a08 <__intr_save>
  102c4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102c51:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c56:	8b 40 14             	mov    0x14(%eax),%eax
  102c59:	ff d0                	call   *%eax
  102c5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102c5e:	83 ec 0c             	sub    $0xc,%esp
  102c61:	ff 75 f4             	pushl  -0xc(%ebp)
  102c64:	e8 c9 fd ff ff       	call   102a32 <__intr_restore>
  102c69:	83 c4 10             	add    $0x10,%esp
    return ret;
  102c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102c6f:	c9                   	leave  
  102c70:	c3                   	ret    

00102c71 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102c71:	55                   	push   %ebp
  102c72:	89 e5                	mov    %esp,%ebp
  102c74:	57                   	push   %edi
  102c75:	56                   	push   %esi
  102c76:	53                   	push   %ebx
  102c77:	83 ec 7c             	sub    $0x7c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102c7a:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102c81:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102c88:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c8f:	83 ec 0c             	sub    $0xc,%esp
  102c92:	68 47 62 10 00       	push   $0x106247
  102c97:	e8 d7 d5 ff ff       	call   100273 <cprintf>
  102c9c:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102c9f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102ca6:	e9 fc 00 00 00       	jmp    102da7 <page_init+0x136>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102cab:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cae:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cb1:	89 d0                	mov    %edx,%eax
  102cb3:	c1 e0 02             	shl    $0x2,%eax
  102cb6:	01 d0                	add    %edx,%eax
  102cb8:	c1 e0 02             	shl    $0x2,%eax
  102cbb:	01 c8                	add    %ecx,%eax
  102cbd:	8b 50 08             	mov    0x8(%eax),%edx
  102cc0:	8b 40 04             	mov    0x4(%eax),%eax
  102cc3:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102cc6:	89 55 bc             	mov    %edx,-0x44(%ebp)
  102cc9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ccc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ccf:	89 d0                	mov    %edx,%eax
  102cd1:	c1 e0 02             	shl    $0x2,%eax
  102cd4:	01 d0                	add    %edx,%eax
  102cd6:	c1 e0 02             	shl    $0x2,%eax
  102cd9:	01 c8                	add    %ecx,%eax
  102cdb:	8b 48 0c             	mov    0xc(%eax),%ecx
  102cde:	8b 58 10             	mov    0x10(%eax),%ebx
  102ce1:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102ce4:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102ce7:	01 c8                	add    %ecx,%eax
  102ce9:	11 da                	adc    %ebx,%edx
  102ceb:	89 45 b0             	mov    %eax,-0x50(%ebp)
  102cee:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102cf1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cf4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cf7:	89 d0                	mov    %edx,%eax
  102cf9:	c1 e0 02             	shl    $0x2,%eax
  102cfc:	01 d0                	add    %edx,%eax
  102cfe:	c1 e0 02             	shl    $0x2,%eax
  102d01:	01 c8                	add    %ecx,%eax
  102d03:	83 c0 14             	add    $0x14,%eax
  102d06:	8b 00                	mov    (%eax),%eax
  102d08:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102d0b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102d0e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d11:	83 c0 ff             	add    $0xffffffff,%eax
  102d14:	83 d2 ff             	adc    $0xffffffff,%edx
  102d17:	89 c1                	mov    %eax,%ecx
  102d19:	89 d3                	mov    %edx,%ebx
  102d1b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102d1e:	89 55 80             	mov    %edx,-0x80(%ebp)
  102d21:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d24:	89 d0                	mov    %edx,%eax
  102d26:	c1 e0 02             	shl    $0x2,%eax
  102d29:	01 d0                	add    %edx,%eax
  102d2b:	c1 e0 02             	shl    $0x2,%eax
  102d2e:	03 45 80             	add    -0x80(%ebp),%eax
  102d31:	8b 50 10             	mov    0x10(%eax),%edx
  102d34:	8b 40 0c             	mov    0xc(%eax),%eax
  102d37:	ff 75 84             	pushl  -0x7c(%ebp)
  102d3a:	53                   	push   %ebx
  102d3b:	51                   	push   %ecx
  102d3c:	ff 75 bc             	pushl  -0x44(%ebp)
  102d3f:	ff 75 b8             	pushl  -0x48(%ebp)
  102d42:	52                   	push   %edx
  102d43:	50                   	push   %eax
  102d44:	68 54 62 10 00       	push   $0x106254
  102d49:	e8 25 d5 ff ff       	call   100273 <cprintf>
  102d4e:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102d51:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d54:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d57:	89 d0                	mov    %edx,%eax
  102d59:	c1 e0 02             	shl    $0x2,%eax
  102d5c:	01 d0                	add    %edx,%eax
  102d5e:	c1 e0 02             	shl    $0x2,%eax
  102d61:	01 c8                	add    %ecx,%eax
  102d63:	83 c0 14             	add    $0x14,%eax
  102d66:	8b 00                	mov    (%eax),%eax
  102d68:	83 f8 01             	cmp    $0x1,%eax
  102d6b:	75 36                	jne    102da3 <page_init+0x132>
            if (maxpa < end && begin < KMEMSIZE) {
  102d6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d73:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d76:	77 2b                	ja     102da3 <page_init+0x132>
  102d78:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d7b:	72 05                	jb     102d82 <page_init+0x111>
  102d7d:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  102d80:	73 21                	jae    102da3 <page_init+0x132>
  102d82:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102d86:	77 1b                	ja     102da3 <page_init+0x132>
  102d88:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102d8c:	72 09                	jb     102d97 <page_init+0x126>
  102d8e:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  102d95:	77 0c                	ja     102da3 <page_init+0x132>
                maxpa = end;
  102d97:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102d9a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102da0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102da3:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  102da7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102daa:	8b 00                	mov    (%eax),%eax
  102dac:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  102daf:	0f 8f f6 fe ff ff    	jg     102cab <page_init+0x3a>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102db5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102db9:	72 1d                	jb     102dd8 <page_init+0x167>
  102dbb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102dbf:	77 09                	ja     102dca <page_init+0x159>
  102dc1:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102dc8:	76 0e                	jbe    102dd8 <page_init+0x167>
        maxpa = KMEMSIZE;
  102dca:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102dd1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102dd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ddb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102dde:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102de2:	c1 ea 0c             	shr    $0xc,%edx
  102de5:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102dea:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  102df1:	b8 28 af 11 00       	mov    $0x11af28,%eax
  102df6:	8d 50 ff             	lea    -0x1(%eax),%edx
  102df9:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102dfc:	01 d0                	add    %edx,%eax
  102dfe:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102e01:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102e04:	ba 00 00 00 00       	mov    $0x0,%edx
  102e09:	f7 75 ac             	divl   -0x54(%ebp)
  102e0c:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102e0f:	29 d0                	sub    %edx,%eax
  102e11:	a3 18 af 11 00       	mov    %eax,0x11af18

    for (i = 0; i < npage; i ++) {
  102e16:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e1d:	eb 2f                	jmp    102e4e <page_init+0x1dd>
        SetPageReserved(pages + i);
  102e1f:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  102e25:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e28:	89 d0                	mov    %edx,%eax
  102e2a:	c1 e0 02             	shl    $0x2,%eax
  102e2d:	01 d0                	add    %edx,%eax
  102e2f:	c1 e0 02             	shl    $0x2,%eax
  102e32:	01 c8                	add    %ecx,%eax
  102e34:	83 c0 04             	add    $0x4,%eax
  102e37:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  102e3e:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e41:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e44:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e47:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  102e4a:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  102e4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e51:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102e56:	39 c2                	cmp    %eax,%edx
  102e58:	72 c5                	jb     102e1f <page_init+0x1ae>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e5a:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102e60:	89 d0                	mov    %edx,%eax
  102e62:	c1 e0 02             	shl    $0x2,%eax
  102e65:	01 d0                	add    %edx,%eax
  102e67:	c1 e0 02             	shl    $0x2,%eax
  102e6a:	89 c2                	mov    %eax,%edx
  102e6c:	a1 18 af 11 00       	mov    0x11af18,%eax
  102e71:	01 d0                	add    %edx,%eax
  102e73:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  102e76:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  102e7d:	77 17                	ja     102e96 <page_init+0x225>
  102e7f:	ff 75 a4             	pushl  -0x5c(%ebp)
  102e82:	68 84 62 10 00       	push   $0x106284
  102e87:	68 dc 00 00 00       	push   $0xdc
  102e8c:	68 a8 62 10 00       	push   $0x1062a8
  102e91:	e8 43 d5 ff ff       	call   1003d9 <__panic>
  102e96:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102e99:	05 00 00 00 40       	add    $0x40000000,%eax
  102e9e:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102ea1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102ea8:	e9 69 01 00 00       	jmp    103016 <page_init+0x3a5>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102ead:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102eb0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102eb3:	89 d0                	mov    %edx,%eax
  102eb5:	c1 e0 02             	shl    $0x2,%eax
  102eb8:	01 d0                	add    %edx,%eax
  102eba:	c1 e0 02             	shl    $0x2,%eax
  102ebd:	01 c8                	add    %ecx,%eax
  102ebf:	8b 50 08             	mov    0x8(%eax),%edx
  102ec2:	8b 40 04             	mov    0x4(%eax),%eax
  102ec5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ec8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102ecb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ece:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ed1:	89 d0                	mov    %edx,%eax
  102ed3:	c1 e0 02             	shl    $0x2,%eax
  102ed6:	01 d0                	add    %edx,%eax
  102ed8:	c1 e0 02             	shl    $0x2,%eax
  102edb:	01 c8                	add    %ecx,%eax
  102edd:	8b 48 0c             	mov    0xc(%eax),%ecx
  102ee0:	8b 58 10             	mov    0x10(%eax),%ebx
  102ee3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102ee6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102ee9:	01 c8                	add    %ecx,%eax
  102eeb:	11 da                	adc    %ebx,%edx
  102eed:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102ef0:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102ef3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ef6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ef9:	89 d0                	mov    %edx,%eax
  102efb:	c1 e0 02             	shl    $0x2,%eax
  102efe:	01 d0                	add    %edx,%eax
  102f00:	c1 e0 02             	shl    $0x2,%eax
  102f03:	01 c8                	add    %ecx,%eax
  102f05:	83 c0 14             	add    $0x14,%eax
  102f08:	8b 00                	mov    (%eax),%eax
  102f0a:	83 f8 01             	cmp    $0x1,%eax
  102f0d:	0f 85 ff 00 00 00    	jne    103012 <page_init+0x3a1>
            if (begin < freemem) {
  102f13:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f16:	ba 00 00 00 00       	mov    $0x0,%edx
  102f1b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f1e:	72 17                	jb     102f37 <page_init+0x2c6>
  102f20:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f23:	77 05                	ja     102f2a <page_init+0x2b9>
  102f25:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102f28:	76 0d                	jbe    102f37 <page_init+0x2c6>
                begin = freemem;
  102f2a:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f30:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102f37:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f3b:	72 1d                	jb     102f5a <page_init+0x2e9>
  102f3d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f41:	77 09                	ja     102f4c <page_init+0x2db>
  102f43:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102f4a:	76 0e                	jbe    102f5a <page_init+0x2e9>
                end = KMEMSIZE;
  102f4c:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102f53:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102f5a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f5d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f60:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f63:	0f 87 a9 00 00 00    	ja     103012 <page_init+0x3a1>
  102f69:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f6c:	72 09                	jb     102f77 <page_init+0x306>
  102f6e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f71:	0f 83 9b 00 00 00    	jae    103012 <page_init+0x3a1>
                begin = ROUNDUP(begin, PGSIZE);
  102f77:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  102f7e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102f81:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102f84:	01 d0                	add    %edx,%eax
  102f86:	83 e8 01             	sub    $0x1,%eax
  102f89:	89 45 98             	mov    %eax,-0x68(%ebp)
  102f8c:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f8f:	ba 00 00 00 00       	mov    $0x0,%edx
  102f94:	f7 75 9c             	divl   -0x64(%ebp)
  102f97:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f9a:	29 d0                	sub    %edx,%eax
  102f9c:	ba 00 00 00 00       	mov    $0x0,%edx
  102fa1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102fa4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102fa7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102faa:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102fad:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  102fb5:	89 c3                	mov    %eax,%ebx
  102fb7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  102fbd:	89 de                	mov    %ebx,%esi
  102fbf:	89 d0                	mov    %edx,%eax
  102fc1:	83 e0 00             	and    $0x0,%eax
  102fc4:	89 c7                	mov    %eax,%edi
  102fc6:	89 75 c8             	mov    %esi,-0x38(%ebp)
  102fc9:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  102fcc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fcf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102fd2:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102fd5:	77 3b                	ja     103012 <page_init+0x3a1>
  102fd7:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102fda:	72 05                	jb     102fe1 <page_init+0x370>
  102fdc:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102fdf:	73 31                	jae    103012 <page_init+0x3a1>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  102fe1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102fe4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102fe7:	2b 45 d0             	sub    -0x30(%ebp),%eax
  102fea:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  102fed:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102ff1:	c1 ea 0c             	shr    $0xc,%edx
  102ff4:	89 c3                	mov    %eax,%ebx
  102ff6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102ff9:	83 ec 0c             	sub    $0xc,%esp
  102ffc:	50                   	push   %eax
  102ffd:	e8 de f8 ff ff       	call   1028e0 <pa2page>
  103002:	83 c4 10             	add    $0x10,%esp
  103005:	83 ec 08             	sub    $0x8,%esp
  103008:	53                   	push   %ebx
  103009:	50                   	push   %eax
  10300a:	e8 a2 fb ff ff       	call   102bb1 <init_memmap>
  10300f:	83 c4 10             	add    $0x10,%esp
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  103012:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103016:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103019:	8b 00                	mov    (%eax),%eax
  10301b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  10301e:	0f 8f 89 fe ff ff    	jg     102ead <page_init+0x23c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  103024:	90                   	nop
  103025:	8d 65 f4             	lea    -0xc(%ebp),%esp
  103028:	5b                   	pop    %ebx
  103029:	5e                   	pop    %esi
  10302a:	5f                   	pop    %edi
  10302b:	5d                   	pop    %ebp
  10302c:	c3                   	ret    

0010302d <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  10302d:	55                   	push   %ebp
  10302e:	89 e5                	mov    %esp,%ebp
  103030:	83 ec 28             	sub    $0x28,%esp
    assert(PGOFF(la) == PGOFF(pa));
  103033:	8b 45 0c             	mov    0xc(%ebp),%eax
  103036:	33 45 14             	xor    0x14(%ebp),%eax
  103039:	25 ff 0f 00 00       	and    $0xfff,%eax
  10303e:	85 c0                	test   %eax,%eax
  103040:	74 19                	je     10305b <boot_map_segment+0x2e>
  103042:	68 b6 62 10 00       	push   $0x1062b6
  103047:	68 cd 62 10 00       	push   $0x1062cd
  10304c:	68 fa 00 00 00       	push   $0xfa
  103051:	68 a8 62 10 00       	push   $0x1062a8
  103056:	e8 7e d3 ff ff       	call   1003d9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10305b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  103062:	8b 45 0c             	mov    0xc(%ebp),%eax
  103065:	25 ff 0f 00 00       	and    $0xfff,%eax
  10306a:	89 c2                	mov    %eax,%edx
  10306c:	8b 45 10             	mov    0x10(%ebp),%eax
  10306f:	01 c2                	add    %eax,%edx
  103071:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103074:	01 d0                	add    %edx,%eax
  103076:	83 e8 01             	sub    $0x1,%eax
  103079:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10307c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10307f:	ba 00 00 00 00       	mov    $0x0,%edx
  103084:	f7 75 f0             	divl   -0x10(%ebp)
  103087:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10308a:	29 d0                	sub    %edx,%eax
  10308c:	c1 e8 0c             	shr    $0xc,%eax
  10308f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  103092:	8b 45 0c             	mov    0xc(%ebp),%eax
  103095:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103098:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10309b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030a0:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1030a3:	8b 45 14             	mov    0x14(%ebp),%eax
  1030a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1030a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1030ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030b1:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1030b4:	eb 57                	jmp    10310d <boot_map_segment+0xe0>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1030b6:	83 ec 04             	sub    $0x4,%esp
  1030b9:	6a 01                	push   $0x1
  1030bb:	ff 75 0c             	pushl  0xc(%ebp)
  1030be:	ff 75 08             	pushl  0x8(%ebp)
  1030c1:	e8 53 01 00 00       	call   103219 <get_pte>
  1030c6:	83 c4 10             	add    $0x10,%esp
  1030c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1030cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1030d0:	75 19                	jne    1030eb <boot_map_segment+0xbe>
  1030d2:	68 e2 62 10 00       	push   $0x1062e2
  1030d7:	68 cd 62 10 00       	push   $0x1062cd
  1030dc:	68 00 01 00 00       	push   $0x100
  1030e1:	68 a8 62 10 00       	push   $0x1062a8
  1030e6:	e8 ee d2 ff ff       	call   1003d9 <__panic>
        *ptep = pa | PTE_P | perm;
  1030eb:	8b 45 14             	mov    0x14(%ebp),%eax
  1030ee:	0b 45 18             	or     0x18(%ebp),%eax
  1030f1:	83 c8 01             	or     $0x1,%eax
  1030f4:	89 c2                	mov    %eax,%edx
  1030f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030f9:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1030fb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1030ff:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  103106:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  10310d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103111:	75 a3                	jne    1030b6 <boot_map_segment+0x89>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  103113:	90                   	nop
  103114:	c9                   	leave  
  103115:	c3                   	ret    

00103116 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  103116:	55                   	push   %ebp
  103117:	89 e5                	mov    %esp,%ebp
  103119:	83 ec 18             	sub    $0x18,%esp
    struct Page *p = alloc_page();
  10311c:	83 ec 0c             	sub    $0xc,%esp
  10311f:	6a 01                	push   $0x1
  103121:	e8 aa fa ff ff       	call   102bd0 <alloc_pages>
  103126:	83 c4 10             	add    $0x10,%esp
  103129:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  10312c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103130:	75 17                	jne    103149 <boot_alloc_page+0x33>
        panic("boot_alloc_page failed.\n");
  103132:	83 ec 04             	sub    $0x4,%esp
  103135:	68 ef 62 10 00       	push   $0x1062ef
  10313a:	68 0c 01 00 00       	push   $0x10c
  10313f:	68 a8 62 10 00       	push   $0x1062a8
  103144:	e8 90 d2 ff ff       	call   1003d9 <__panic>
    }
    return page2kva(p);
  103149:	83 ec 0c             	sub    $0xc,%esp
  10314c:	ff 75 f4             	pushl  -0xc(%ebp)
  10314f:	e8 d3 f7 ff ff       	call   102927 <page2kva>
  103154:	83 c4 10             	add    $0x10,%esp
}
  103157:	c9                   	leave  
  103158:	c3                   	ret    

00103159 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  103159:	55                   	push   %ebp
  10315a:	89 e5                	mov    %esp,%ebp
  10315c:	83 ec 18             	sub    $0x18,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  10315f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103164:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103167:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10316e:	77 17                	ja     103187 <pmm_init+0x2e>
  103170:	ff 75 f4             	pushl  -0xc(%ebp)
  103173:	68 84 62 10 00       	push   $0x106284
  103178:	68 16 01 00 00       	push   $0x116
  10317d:	68 a8 62 10 00       	push   $0x1062a8
  103182:	e8 52 d2 ff ff       	call   1003d9 <__panic>
  103187:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10318a:	05 00 00 00 40       	add    $0x40000000,%eax
  10318f:	a3 14 af 11 00       	mov    %eax,0x11af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  103194:	e8 e3 f9 ff ff       	call   102b7c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  103199:	e8 d3 fa ff ff       	call   102c71 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  10319e:	e8 9d 03 00 00       	call   103540 <check_alloc_page>

    check_pgdir();
  1031a3:	e8 bb 03 00 00       	call   103563 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1031a8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031ad:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  1031b3:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031bb:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1031c2:	77 17                	ja     1031db <pmm_init+0x82>
  1031c4:	ff 75 f0             	pushl  -0x10(%ebp)
  1031c7:	68 84 62 10 00       	push   $0x106284
  1031cc:	68 2c 01 00 00       	push   $0x12c
  1031d1:	68 a8 62 10 00       	push   $0x1062a8
  1031d6:	e8 fe d1 ff ff       	call   1003d9 <__panic>
  1031db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031de:	05 00 00 00 40       	add    $0x40000000,%eax
  1031e3:	83 c8 03             	or     $0x3,%eax
  1031e6:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1031e8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031ed:	83 ec 0c             	sub    $0xc,%esp
  1031f0:	6a 02                	push   $0x2
  1031f2:	6a 00                	push   $0x0
  1031f4:	68 00 00 00 38       	push   $0x38000000
  1031f9:	68 00 00 00 c0       	push   $0xc0000000
  1031fe:	50                   	push   %eax
  1031ff:	e8 29 fe ff ff       	call   10302d <boot_map_segment>
  103204:	83 c4 20             	add    $0x20,%esp

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  103207:	e8 7e f8 ff ff       	call   102a8a <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  10320c:	e8 b8 08 00 00       	call   103ac9 <check_boot_pgdir>

    print_pgdir();
  103211:	e8 ae 0c 00 00       	call   103ec4 <print_pgdir>

}
  103216:	90                   	nop
  103217:	c9                   	leave  
  103218:	c3                   	ret    

00103219 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  103219:	55                   	push   %ebp
  10321a:	89 e5                	mov    %esp,%ebp
  10321c:	83 ec 28             	sub    $0x28,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif*/
    pde_t *pdep = &(pgdir[PDX(la)]);
  10321f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103222:	c1 e8 16             	shr    $0x16,%eax
  103225:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10322c:	8b 45 08             	mov    0x8(%ebp),%eax
  10322f:	01 d0                	add    %edx,%eax
  103231:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if ( !(*pdep & PTE_P)) {
  103234:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103237:	8b 00                	mov    (%eax),%eax
  103239:	83 e0 01             	and    $0x1,%eax
  10323c:	85 c0                	test   %eax,%eax
  10323e:	0f 85 ac 00 00 00    	jne    1032f0 <get_pte+0xd7>
        if (create) {
  103244:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103248:	0f 84 9b 00 00 00    	je     1032e9 <get_pte+0xd0>
            struct Page *page_new = alloc_page();
  10324e:	83 ec 0c             	sub    $0xc,%esp
  103251:	6a 01                	push   $0x1
  103253:	e8 78 f9 ff ff       	call   102bd0 <alloc_pages>
  103258:	83 c4 10             	add    $0x10,%esp
  10325b:	89 45 f0             	mov    %eax,-0x10(%ebp)
            if (page_new == NULL) {
  10325e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103262:	75 0a                	jne    10326e <get_pte+0x55>
                return NULL;
  103264:	b8 00 00 00 00       	mov    $0x0,%eax
  103269:	e9 d3 00 00 00       	jmp    103341 <get_pte+0x128>
            }
            set_page_ref(page_new, 1);
  10326e:	83 ec 08             	sub    $0x8,%esp
  103271:	6a 01                	push   $0x1
  103273:	ff 75 f0             	pushl  -0x10(%ebp)
  103276:	e8 51 f7 ff ff       	call   1029cc <set_page_ref>
  10327b:	83 c4 10             	add    $0x10,%esp
            uintptr_t pa = page2pa(page_new);
  10327e:	83 ec 0c             	sub    $0xc,%esp
  103281:	ff 75 f0             	pushl  -0x10(%ebp)
  103284:	e8 44 f6 ff ff       	call   1028cd <page2pa>
  103289:	83 c4 10             	add    $0x10,%esp
  10328c:	89 45 ec             	mov    %eax,-0x14(%ebp)
            memset(KADDR(pa), 0, PGSIZE);
  10328f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103292:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103295:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103298:	c1 e8 0c             	shr    $0xc,%eax
  10329b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10329e:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1032a3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1032a6:	72 17                	jb     1032bf <get_pte+0xa6>
  1032a8:	ff 75 e8             	pushl  -0x18(%ebp)
  1032ab:	68 e0 61 10 00       	push   $0x1061e0
  1032b0:	68 73 01 00 00       	push   $0x173
  1032b5:	68 a8 62 10 00       	push   $0x1062a8
  1032ba:	e8 1a d1 ff ff       	call   1003d9 <__panic>
  1032bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032c2:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1032c7:	83 ec 04             	sub    $0x4,%esp
  1032ca:	68 00 10 00 00       	push   $0x1000
  1032cf:	6a 00                	push   $0x0
  1032d1:	50                   	push   %eax
  1032d2:	e8 02 20 00 00       	call   1052d9 <memset>
  1032d7:	83 c4 10             	add    $0x10,%esp
            *pdep = pa | PTE_U | PTE_W | PTE_P;
  1032da:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032dd:	83 c8 07             	or     $0x7,%eax
  1032e0:	89 c2                	mov    %eax,%edx
  1032e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032e5:	89 10                	mov    %edx,(%eax)
  1032e7:	eb 07                	jmp    1032f0 <get_pte+0xd7>
        }
        else {
            return NULL;
  1032e9:	b8 00 00 00 00       	mov    $0x0,%eax
  1032ee:	eb 51                	jmp    103341 <get_pte+0x128>
        }
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];  
  1032f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032f3:	8b 00                	mov    (%eax),%eax
  1032f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1032fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1032fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103300:	c1 e8 0c             	shr    $0xc,%eax
  103303:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103306:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10330b:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10330e:	72 17                	jb     103327 <get_pte+0x10e>
  103310:	ff 75 e0             	pushl  -0x20(%ebp)
  103313:	68 e0 61 10 00       	push   $0x1061e0
  103318:	68 7a 01 00 00       	push   $0x17a
  10331d:	68 a8 62 10 00       	push   $0x1062a8
  103322:	e8 b2 d0 ff ff       	call   1003d9 <__panic>
  103327:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10332a:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10332f:	89 c2                	mov    %eax,%edx
  103331:	8b 45 0c             	mov    0xc(%ebp),%eax
  103334:	c1 e8 0c             	shr    $0xc,%eax
  103337:	25 ff 03 00 00       	and    $0x3ff,%eax
  10333c:	c1 e0 02             	shl    $0x2,%eax
  10333f:	01 d0                	add    %edx,%eax
}
  103341:	c9                   	leave  
  103342:	c3                   	ret    

00103343 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  103343:	55                   	push   %ebp
  103344:	89 e5                	mov    %esp,%ebp
  103346:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103349:	83 ec 04             	sub    $0x4,%esp
  10334c:	6a 00                	push   $0x0
  10334e:	ff 75 0c             	pushl  0xc(%ebp)
  103351:	ff 75 08             	pushl  0x8(%ebp)
  103354:	e8 c0 fe ff ff       	call   103219 <get_pte>
  103359:	83 c4 10             	add    $0x10,%esp
  10335c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  10335f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103363:	74 08                	je     10336d <get_page+0x2a>
        *ptep_store = ptep;
  103365:	8b 45 10             	mov    0x10(%ebp),%eax
  103368:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10336b:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  10336d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103371:	74 1f                	je     103392 <get_page+0x4f>
  103373:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103376:	8b 00                	mov    (%eax),%eax
  103378:	83 e0 01             	and    $0x1,%eax
  10337b:	85 c0                	test   %eax,%eax
  10337d:	74 13                	je     103392 <get_page+0x4f>
        return pte2page(*ptep);
  10337f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103382:	8b 00                	mov    (%eax),%eax
  103384:	83 ec 0c             	sub    $0xc,%esp
  103387:	50                   	push   %eax
  103388:	e8 df f5 ff ff       	call   10296c <pte2page>
  10338d:	83 c4 10             	add    $0x10,%esp
  103390:	eb 05                	jmp    103397 <get_page+0x54>
    }
    return NULL;
  103392:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103397:	c9                   	leave  
  103398:	c3                   	ret    

00103399 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  103399:	55                   	push   %ebp
  10339a:	89 e5                	mov    %esp,%ebp
  10339c:	83 ec 18             	sub    $0x18,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif*/
    if (*ptep & PTE_P) {
  10339f:	8b 45 10             	mov    0x10(%ebp),%eax
  1033a2:	8b 00                	mov    (%eax),%eax
  1033a4:	83 e0 01             	and    $0x1,%eax
  1033a7:	85 c0                	test   %eax,%eax
  1033a9:	74 50                	je     1033fb <page_remove_pte+0x62>
        struct Page *page = pte2page(*ptep);
  1033ab:	8b 45 10             	mov    0x10(%ebp),%eax
  1033ae:	8b 00                	mov    (%eax),%eax
  1033b0:	83 ec 0c             	sub    $0xc,%esp
  1033b3:	50                   	push   %eax
  1033b4:	e8 b3 f5 ff ff       	call   10296c <pte2page>
  1033b9:	83 c4 10             	add    $0x10,%esp
  1033bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if ((page_ref_dec(page)) == 0) {
  1033bf:	83 ec 0c             	sub    $0xc,%esp
  1033c2:	ff 75 f4             	pushl  -0xc(%ebp)
  1033c5:	e8 27 f6 ff ff       	call   1029f1 <page_ref_dec>
  1033ca:	83 c4 10             	add    $0x10,%esp
  1033cd:	85 c0                	test   %eax,%eax
  1033cf:	75 10                	jne    1033e1 <page_remove_pte+0x48>
            free_page(page);
  1033d1:	83 ec 08             	sub    $0x8,%esp
  1033d4:	6a 01                	push   $0x1
  1033d6:	ff 75 f4             	pushl  -0xc(%ebp)
  1033d9:	e8 30 f8 ff ff       	call   102c0e <free_pages>
  1033de:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0;
  1033e1:	8b 45 10             	mov    0x10(%ebp),%eax
  1033e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  1033ea:	83 ec 08             	sub    $0x8,%esp
  1033ed:	ff 75 0c             	pushl  0xc(%ebp)
  1033f0:	ff 75 08             	pushl  0x8(%ebp)
  1033f3:	e8 f8 00 00 00       	call   1034f0 <tlb_invalidate>
  1033f8:	83 c4 10             	add    $0x10,%esp
    }
}
  1033fb:	90                   	nop
  1033fc:	c9                   	leave  
  1033fd:	c3                   	ret    

001033fe <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1033fe:	55                   	push   %ebp
  1033ff:	89 e5                	mov    %esp,%ebp
  103401:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103404:	83 ec 04             	sub    $0x4,%esp
  103407:	6a 00                	push   $0x0
  103409:	ff 75 0c             	pushl  0xc(%ebp)
  10340c:	ff 75 08             	pushl  0x8(%ebp)
  10340f:	e8 05 fe ff ff       	call   103219 <get_pte>
  103414:	83 c4 10             	add    $0x10,%esp
  103417:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  10341a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10341e:	74 14                	je     103434 <page_remove+0x36>
        page_remove_pte(pgdir, la, ptep);
  103420:	83 ec 04             	sub    $0x4,%esp
  103423:	ff 75 f4             	pushl  -0xc(%ebp)
  103426:	ff 75 0c             	pushl  0xc(%ebp)
  103429:	ff 75 08             	pushl  0x8(%ebp)
  10342c:	e8 68 ff ff ff       	call   103399 <page_remove_pte>
  103431:	83 c4 10             	add    $0x10,%esp
    }
}
  103434:	90                   	nop
  103435:	c9                   	leave  
  103436:	c3                   	ret    

00103437 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103437:	55                   	push   %ebp
  103438:	89 e5                	mov    %esp,%ebp
  10343a:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10343d:	83 ec 04             	sub    $0x4,%esp
  103440:	6a 01                	push   $0x1
  103442:	ff 75 10             	pushl  0x10(%ebp)
  103445:	ff 75 08             	pushl  0x8(%ebp)
  103448:	e8 cc fd ff ff       	call   103219 <get_pte>
  10344d:	83 c4 10             	add    $0x10,%esp
  103450:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  103453:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103457:	75 0a                	jne    103463 <page_insert+0x2c>
        return -E_NO_MEM;
  103459:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  10345e:	e9 8b 00 00 00       	jmp    1034ee <page_insert+0xb7>
    }
    page_ref_inc(page);
  103463:	83 ec 0c             	sub    $0xc,%esp
  103466:	ff 75 0c             	pushl  0xc(%ebp)
  103469:	e8 6c f5 ff ff       	call   1029da <page_ref_inc>
  10346e:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {
  103471:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103474:	8b 00                	mov    (%eax),%eax
  103476:	83 e0 01             	and    $0x1,%eax
  103479:	85 c0                	test   %eax,%eax
  10347b:	74 40                	je     1034bd <page_insert+0x86>
        struct Page *p = pte2page(*ptep);
  10347d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103480:	8b 00                	mov    (%eax),%eax
  103482:	83 ec 0c             	sub    $0xc,%esp
  103485:	50                   	push   %eax
  103486:	e8 e1 f4 ff ff       	call   10296c <pte2page>
  10348b:	83 c4 10             	add    $0x10,%esp
  10348e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  103491:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103494:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103497:	75 10                	jne    1034a9 <page_insert+0x72>
            page_ref_dec(page);
  103499:	83 ec 0c             	sub    $0xc,%esp
  10349c:	ff 75 0c             	pushl  0xc(%ebp)
  10349f:	e8 4d f5 ff ff       	call   1029f1 <page_ref_dec>
  1034a4:	83 c4 10             	add    $0x10,%esp
  1034a7:	eb 14                	jmp    1034bd <page_insert+0x86>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1034a9:	83 ec 04             	sub    $0x4,%esp
  1034ac:	ff 75 f4             	pushl  -0xc(%ebp)
  1034af:	ff 75 10             	pushl  0x10(%ebp)
  1034b2:	ff 75 08             	pushl  0x8(%ebp)
  1034b5:	e8 df fe ff ff       	call   103399 <page_remove_pte>
  1034ba:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1034bd:	83 ec 0c             	sub    $0xc,%esp
  1034c0:	ff 75 0c             	pushl  0xc(%ebp)
  1034c3:	e8 05 f4 ff ff       	call   1028cd <page2pa>
  1034c8:	83 c4 10             	add    $0x10,%esp
  1034cb:	0b 45 14             	or     0x14(%ebp),%eax
  1034ce:	83 c8 01             	or     $0x1,%eax
  1034d1:	89 c2                	mov    %eax,%edx
  1034d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034d6:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1034d8:	83 ec 08             	sub    $0x8,%esp
  1034db:	ff 75 10             	pushl  0x10(%ebp)
  1034de:	ff 75 08             	pushl  0x8(%ebp)
  1034e1:	e8 0a 00 00 00       	call   1034f0 <tlb_invalidate>
  1034e6:	83 c4 10             	add    $0x10,%esp
    return 0;
  1034e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1034ee:	c9                   	leave  
  1034ef:	c3                   	ret    

001034f0 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1034f0:	55                   	push   %ebp
  1034f1:	89 e5                	mov    %esp,%ebp
  1034f3:	83 ec 18             	sub    $0x18,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1034f6:	0f 20 d8             	mov    %cr3,%eax
  1034f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
  1034fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  1034ff:	8b 45 08             	mov    0x8(%ebp),%eax
  103502:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103505:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10350c:	77 17                	ja     103525 <tlb_invalidate+0x35>
  10350e:	ff 75 f0             	pushl  -0x10(%ebp)
  103511:	68 84 62 10 00       	push   $0x106284
  103516:	68 dc 01 00 00       	push   $0x1dc
  10351b:	68 a8 62 10 00       	push   $0x1062a8
  103520:	e8 b4 ce ff ff       	call   1003d9 <__panic>
  103525:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103528:	05 00 00 00 40       	add    $0x40000000,%eax
  10352d:	39 c2                	cmp    %eax,%edx
  10352f:	75 0c                	jne    10353d <tlb_invalidate+0x4d>
        invlpg((void *)la);
  103531:	8b 45 0c             	mov    0xc(%ebp),%eax
  103534:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103537:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10353a:	0f 01 38             	invlpg (%eax)
    }
}
  10353d:	90                   	nop
  10353e:	c9                   	leave  
  10353f:	c3                   	ret    

00103540 <check_alloc_page>:

static void
check_alloc_page(void) {
  103540:	55                   	push   %ebp
  103541:	89 e5                	mov    %esp,%ebp
  103543:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->check();
  103546:	a1 10 af 11 00       	mov    0x11af10,%eax
  10354b:	8b 40 18             	mov    0x18(%eax),%eax
  10354e:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  103550:	83 ec 0c             	sub    $0xc,%esp
  103553:	68 08 63 10 00       	push   $0x106308
  103558:	e8 16 cd ff ff       	call   100273 <cprintf>
  10355d:	83 c4 10             	add    $0x10,%esp
}
  103560:	90                   	nop
  103561:	c9                   	leave  
  103562:	c3                   	ret    

00103563 <check_pgdir>:

static void
check_pgdir(void) {
  103563:	55                   	push   %ebp
  103564:	89 e5                	mov    %esp,%ebp
  103566:	83 ec 28             	sub    $0x28,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  103569:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10356e:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103573:	76 19                	jbe    10358e <check_pgdir+0x2b>
  103575:	68 27 63 10 00       	push   $0x106327
  10357a:	68 cd 62 10 00       	push   $0x1062cd
  10357f:	68 e9 01 00 00       	push   $0x1e9
  103584:	68 a8 62 10 00       	push   $0x1062a8
  103589:	e8 4b ce ff ff       	call   1003d9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  10358e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103593:	85 c0                	test   %eax,%eax
  103595:	74 0e                	je     1035a5 <check_pgdir+0x42>
  103597:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10359c:	25 ff 0f 00 00       	and    $0xfff,%eax
  1035a1:	85 c0                	test   %eax,%eax
  1035a3:	74 19                	je     1035be <check_pgdir+0x5b>
  1035a5:	68 44 63 10 00       	push   $0x106344
  1035aa:	68 cd 62 10 00       	push   $0x1062cd
  1035af:	68 ea 01 00 00       	push   $0x1ea
  1035b4:	68 a8 62 10 00       	push   $0x1062a8
  1035b9:	e8 1b ce ff ff       	call   1003d9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1035be:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1035c3:	83 ec 04             	sub    $0x4,%esp
  1035c6:	6a 00                	push   $0x0
  1035c8:	6a 00                	push   $0x0
  1035ca:	50                   	push   %eax
  1035cb:	e8 73 fd ff ff       	call   103343 <get_page>
  1035d0:	83 c4 10             	add    $0x10,%esp
  1035d3:	85 c0                	test   %eax,%eax
  1035d5:	74 19                	je     1035f0 <check_pgdir+0x8d>
  1035d7:	68 7c 63 10 00       	push   $0x10637c
  1035dc:	68 cd 62 10 00       	push   $0x1062cd
  1035e1:	68 eb 01 00 00       	push   $0x1eb
  1035e6:	68 a8 62 10 00       	push   $0x1062a8
  1035eb:	e8 e9 cd ff ff       	call   1003d9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1035f0:	83 ec 0c             	sub    $0xc,%esp
  1035f3:	6a 01                	push   $0x1
  1035f5:	e8 d6 f5 ff ff       	call   102bd0 <alloc_pages>
  1035fa:	83 c4 10             	add    $0x10,%esp
  1035fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  103600:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103605:	6a 00                	push   $0x0
  103607:	6a 00                	push   $0x0
  103609:	ff 75 f4             	pushl  -0xc(%ebp)
  10360c:	50                   	push   %eax
  10360d:	e8 25 fe ff ff       	call   103437 <page_insert>
  103612:	83 c4 10             	add    $0x10,%esp
  103615:	85 c0                	test   %eax,%eax
  103617:	74 19                	je     103632 <check_pgdir+0xcf>
  103619:	68 a4 63 10 00       	push   $0x1063a4
  10361e:	68 cd 62 10 00       	push   $0x1062cd
  103623:	68 ef 01 00 00       	push   $0x1ef
  103628:	68 a8 62 10 00       	push   $0x1062a8
  10362d:	e8 a7 cd ff ff       	call   1003d9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  103632:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103637:	83 ec 04             	sub    $0x4,%esp
  10363a:	6a 00                	push   $0x0
  10363c:	6a 00                	push   $0x0
  10363e:	50                   	push   %eax
  10363f:	e8 d5 fb ff ff       	call   103219 <get_pte>
  103644:	83 c4 10             	add    $0x10,%esp
  103647:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10364a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10364e:	75 19                	jne    103669 <check_pgdir+0x106>
  103650:	68 d0 63 10 00       	push   $0x1063d0
  103655:	68 cd 62 10 00       	push   $0x1062cd
  10365a:	68 f2 01 00 00       	push   $0x1f2
  10365f:	68 a8 62 10 00       	push   $0x1062a8
  103664:	e8 70 cd ff ff       	call   1003d9 <__panic>
    assert(pte2page(*ptep) == p1);
  103669:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10366c:	8b 00                	mov    (%eax),%eax
  10366e:	83 ec 0c             	sub    $0xc,%esp
  103671:	50                   	push   %eax
  103672:	e8 f5 f2 ff ff       	call   10296c <pte2page>
  103677:	83 c4 10             	add    $0x10,%esp
  10367a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10367d:	74 19                	je     103698 <check_pgdir+0x135>
  10367f:	68 fd 63 10 00       	push   $0x1063fd
  103684:	68 cd 62 10 00       	push   $0x1062cd
  103689:	68 f3 01 00 00       	push   $0x1f3
  10368e:	68 a8 62 10 00       	push   $0x1062a8
  103693:	e8 41 cd ff ff       	call   1003d9 <__panic>
    assert(page_ref(p1) == 1);
  103698:	83 ec 0c             	sub    $0xc,%esp
  10369b:	ff 75 f4             	pushl  -0xc(%ebp)
  10369e:	e8 1f f3 ff ff       	call   1029c2 <page_ref>
  1036a3:	83 c4 10             	add    $0x10,%esp
  1036a6:	83 f8 01             	cmp    $0x1,%eax
  1036a9:	74 19                	je     1036c4 <check_pgdir+0x161>
  1036ab:	68 13 64 10 00       	push   $0x106413
  1036b0:	68 cd 62 10 00       	push   $0x1062cd
  1036b5:	68 f4 01 00 00       	push   $0x1f4
  1036ba:	68 a8 62 10 00       	push   $0x1062a8
  1036bf:	e8 15 cd ff ff       	call   1003d9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1036c4:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1036c9:	8b 00                	mov    (%eax),%eax
  1036cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1036d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1036d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1036d6:	c1 e8 0c             	shr    $0xc,%eax
  1036d9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1036dc:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1036e1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1036e4:	72 17                	jb     1036fd <check_pgdir+0x19a>
  1036e6:	ff 75 ec             	pushl  -0x14(%ebp)
  1036e9:	68 e0 61 10 00       	push   $0x1061e0
  1036ee:	68 f6 01 00 00       	push   $0x1f6
  1036f3:	68 a8 62 10 00       	push   $0x1062a8
  1036f8:	e8 dc cc ff ff       	call   1003d9 <__panic>
  1036fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103700:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103705:	83 c0 04             	add    $0x4,%eax
  103708:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  10370b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103710:	83 ec 04             	sub    $0x4,%esp
  103713:	6a 00                	push   $0x0
  103715:	68 00 10 00 00       	push   $0x1000
  10371a:	50                   	push   %eax
  10371b:	e8 f9 fa ff ff       	call   103219 <get_pte>
  103720:	83 c4 10             	add    $0x10,%esp
  103723:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103726:	74 19                	je     103741 <check_pgdir+0x1de>
  103728:	68 28 64 10 00       	push   $0x106428
  10372d:	68 cd 62 10 00       	push   $0x1062cd
  103732:	68 f7 01 00 00       	push   $0x1f7
  103737:	68 a8 62 10 00       	push   $0x1062a8
  10373c:	e8 98 cc ff ff       	call   1003d9 <__panic>

    p2 = alloc_page();
  103741:	83 ec 0c             	sub    $0xc,%esp
  103744:	6a 01                	push   $0x1
  103746:	e8 85 f4 ff ff       	call   102bd0 <alloc_pages>
  10374b:	83 c4 10             	add    $0x10,%esp
  10374e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  103751:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103756:	6a 06                	push   $0x6
  103758:	68 00 10 00 00       	push   $0x1000
  10375d:	ff 75 e4             	pushl  -0x1c(%ebp)
  103760:	50                   	push   %eax
  103761:	e8 d1 fc ff ff       	call   103437 <page_insert>
  103766:	83 c4 10             	add    $0x10,%esp
  103769:	85 c0                	test   %eax,%eax
  10376b:	74 19                	je     103786 <check_pgdir+0x223>
  10376d:	68 50 64 10 00       	push   $0x106450
  103772:	68 cd 62 10 00       	push   $0x1062cd
  103777:	68 fa 01 00 00       	push   $0x1fa
  10377c:	68 a8 62 10 00       	push   $0x1062a8
  103781:	e8 53 cc ff ff       	call   1003d9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103786:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10378b:	83 ec 04             	sub    $0x4,%esp
  10378e:	6a 00                	push   $0x0
  103790:	68 00 10 00 00       	push   $0x1000
  103795:	50                   	push   %eax
  103796:	e8 7e fa ff ff       	call   103219 <get_pte>
  10379b:	83 c4 10             	add    $0x10,%esp
  10379e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1037a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1037a5:	75 19                	jne    1037c0 <check_pgdir+0x25d>
  1037a7:	68 88 64 10 00       	push   $0x106488
  1037ac:	68 cd 62 10 00       	push   $0x1062cd
  1037b1:	68 fb 01 00 00       	push   $0x1fb
  1037b6:	68 a8 62 10 00       	push   $0x1062a8
  1037bb:	e8 19 cc ff ff       	call   1003d9 <__panic>
    assert(*ptep & PTE_U);
  1037c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1037c3:	8b 00                	mov    (%eax),%eax
  1037c5:	83 e0 04             	and    $0x4,%eax
  1037c8:	85 c0                	test   %eax,%eax
  1037ca:	75 19                	jne    1037e5 <check_pgdir+0x282>
  1037cc:	68 b8 64 10 00       	push   $0x1064b8
  1037d1:	68 cd 62 10 00       	push   $0x1062cd
  1037d6:	68 fc 01 00 00       	push   $0x1fc
  1037db:	68 a8 62 10 00       	push   $0x1062a8
  1037e0:	e8 f4 cb ff ff       	call   1003d9 <__panic>
    assert(*ptep & PTE_W);
  1037e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1037e8:	8b 00                	mov    (%eax),%eax
  1037ea:	83 e0 02             	and    $0x2,%eax
  1037ed:	85 c0                	test   %eax,%eax
  1037ef:	75 19                	jne    10380a <check_pgdir+0x2a7>
  1037f1:	68 c6 64 10 00       	push   $0x1064c6
  1037f6:	68 cd 62 10 00       	push   $0x1062cd
  1037fb:	68 fd 01 00 00       	push   $0x1fd
  103800:	68 a8 62 10 00       	push   $0x1062a8
  103805:	e8 cf cb ff ff       	call   1003d9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  10380a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10380f:	8b 00                	mov    (%eax),%eax
  103811:	83 e0 04             	and    $0x4,%eax
  103814:	85 c0                	test   %eax,%eax
  103816:	75 19                	jne    103831 <check_pgdir+0x2ce>
  103818:	68 d4 64 10 00       	push   $0x1064d4
  10381d:	68 cd 62 10 00       	push   $0x1062cd
  103822:	68 fe 01 00 00       	push   $0x1fe
  103827:	68 a8 62 10 00       	push   $0x1062a8
  10382c:	e8 a8 cb ff ff       	call   1003d9 <__panic>
    assert(page_ref(p2) == 1);
  103831:	83 ec 0c             	sub    $0xc,%esp
  103834:	ff 75 e4             	pushl  -0x1c(%ebp)
  103837:	e8 86 f1 ff ff       	call   1029c2 <page_ref>
  10383c:	83 c4 10             	add    $0x10,%esp
  10383f:	83 f8 01             	cmp    $0x1,%eax
  103842:	74 19                	je     10385d <check_pgdir+0x2fa>
  103844:	68 ea 64 10 00       	push   $0x1064ea
  103849:	68 cd 62 10 00       	push   $0x1062cd
  10384e:	68 ff 01 00 00       	push   $0x1ff
  103853:	68 a8 62 10 00       	push   $0x1062a8
  103858:	e8 7c cb ff ff       	call   1003d9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  10385d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103862:	6a 00                	push   $0x0
  103864:	68 00 10 00 00       	push   $0x1000
  103869:	ff 75 f4             	pushl  -0xc(%ebp)
  10386c:	50                   	push   %eax
  10386d:	e8 c5 fb ff ff       	call   103437 <page_insert>
  103872:	83 c4 10             	add    $0x10,%esp
  103875:	85 c0                	test   %eax,%eax
  103877:	74 19                	je     103892 <check_pgdir+0x32f>
  103879:	68 fc 64 10 00       	push   $0x1064fc
  10387e:	68 cd 62 10 00       	push   $0x1062cd
  103883:	68 01 02 00 00       	push   $0x201
  103888:	68 a8 62 10 00       	push   $0x1062a8
  10388d:	e8 47 cb ff ff       	call   1003d9 <__panic>
    assert(page_ref(p1) == 2);
  103892:	83 ec 0c             	sub    $0xc,%esp
  103895:	ff 75 f4             	pushl  -0xc(%ebp)
  103898:	e8 25 f1 ff ff       	call   1029c2 <page_ref>
  10389d:	83 c4 10             	add    $0x10,%esp
  1038a0:	83 f8 02             	cmp    $0x2,%eax
  1038a3:	74 19                	je     1038be <check_pgdir+0x35b>
  1038a5:	68 28 65 10 00       	push   $0x106528
  1038aa:	68 cd 62 10 00       	push   $0x1062cd
  1038af:	68 02 02 00 00       	push   $0x202
  1038b4:	68 a8 62 10 00       	push   $0x1062a8
  1038b9:	e8 1b cb ff ff       	call   1003d9 <__panic>
    assert(page_ref(p2) == 0);
  1038be:	83 ec 0c             	sub    $0xc,%esp
  1038c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  1038c4:	e8 f9 f0 ff ff       	call   1029c2 <page_ref>
  1038c9:	83 c4 10             	add    $0x10,%esp
  1038cc:	85 c0                	test   %eax,%eax
  1038ce:	74 19                	je     1038e9 <check_pgdir+0x386>
  1038d0:	68 3a 65 10 00       	push   $0x10653a
  1038d5:	68 cd 62 10 00       	push   $0x1062cd
  1038da:	68 03 02 00 00       	push   $0x203
  1038df:	68 a8 62 10 00       	push   $0x1062a8
  1038e4:	e8 f0 ca ff ff       	call   1003d9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  1038e9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1038ee:	83 ec 04             	sub    $0x4,%esp
  1038f1:	6a 00                	push   $0x0
  1038f3:	68 00 10 00 00       	push   $0x1000
  1038f8:	50                   	push   %eax
  1038f9:	e8 1b f9 ff ff       	call   103219 <get_pte>
  1038fe:	83 c4 10             	add    $0x10,%esp
  103901:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103904:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103908:	75 19                	jne    103923 <check_pgdir+0x3c0>
  10390a:	68 88 64 10 00       	push   $0x106488
  10390f:	68 cd 62 10 00       	push   $0x1062cd
  103914:	68 04 02 00 00       	push   $0x204
  103919:	68 a8 62 10 00       	push   $0x1062a8
  10391e:	e8 b6 ca ff ff       	call   1003d9 <__panic>
    assert(pte2page(*ptep) == p1);
  103923:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103926:	8b 00                	mov    (%eax),%eax
  103928:	83 ec 0c             	sub    $0xc,%esp
  10392b:	50                   	push   %eax
  10392c:	e8 3b f0 ff ff       	call   10296c <pte2page>
  103931:	83 c4 10             	add    $0x10,%esp
  103934:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103937:	74 19                	je     103952 <check_pgdir+0x3ef>
  103939:	68 fd 63 10 00       	push   $0x1063fd
  10393e:	68 cd 62 10 00       	push   $0x1062cd
  103943:	68 05 02 00 00       	push   $0x205
  103948:	68 a8 62 10 00       	push   $0x1062a8
  10394d:	e8 87 ca ff ff       	call   1003d9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103952:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103955:	8b 00                	mov    (%eax),%eax
  103957:	83 e0 04             	and    $0x4,%eax
  10395a:	85 c0                	test   %eax,%eax
  10395c:	74 19                	je     103977 <check_pgdir+0x414>
  10395e:	68 4c 65 10 00       	push   $0x10654c
  103963:	68 cd 62 10 00       	push   $0x1062cd
  103968:	68 06 02 00 00       	push   $0x206
  10396d:	68 a8 62 10 00       	push   $0x1062a8
  103972:	e8 62 ca ff ff       	call   1003d9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103977:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10397c:	83 ec 08             	sub    $0x8,%esp
  10397f:	6a 00                	push   $0x0
  103981:	50                   	push   %eax
  103982:	e8 77 fa ff ff       	call   1033fe <page_remove>
  103987:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
  10398a:	83 ec 0c             	sub    $0xc,%esp
  10398d:	ff 75 f4             	pushl  -0xc(%ebp)
  103990:	e8 2d f0 ff ff       	call   1029c2 <page_ref>
  103995:	83 c4 10             	add    $0x10,%esp
  103998:	83 f8 01             	cmp    $0x1,%eax
  10399b:	74 19                	je     1039b6 <check_pgdir+0x453>
  10399d:	68 13 64 10 00       	push   $0x106413
  1039a2:	68 cd 62 10 00       	push   $0x1062cd
  1039a7:	68 09 02 00 00       	push   $0x209
  1039ac:	68 a8 62 10 00       	push   $0x1062a8
  1039b1:	e8 23 ca ff ff       	call   1003d9 <__panic>
    assert(page_ref(p2) == 0);
  1039b6:	83 ec 0c             	sub    $0xc,%esp
  1039b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  1039bc:	e8 01 f0 ff ff       	call   1029c2 <page_ref>
  1039c1:	83 c4 10             	add    $0x10,%esp
  1039c4:	85 c0                	test   %eax,%eax
  1039c6:	74 19                	je     1039e1 <check_pgdir+0x47e>
  1039c8:	68 3a 65 10 00       	push   $0x10653a
  1039cd:	68 cd 62 10 00       	push   $0x1062cd
  1039d2:	68 0a 02 00 00       	push   $0x20a
  1039d7:	68 a8 62 10 00       	push   $0x1062a8
  1039dc:	e8 f8 c9 ff ff       	call   1003d9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  1039e1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1039e6:	83 ec 08             	sub    $0x8,%esp
  1039e9:	68 00 10 00 00       	push   $0x1000
  1039ee:	50                   	push   %eax
  1039ef:	e8 0a fa ff ff       	call   1033fe <page_remove>
  1039f4:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
  1039f7:	83 ec 0c             	sub    $0xc,%esp
  1039fa:	ff 75 f4             	pushl  -0xc(%ebp)
  1039fd:	e8 c0 ef ff ff       	call   1029c2 <page_ref>
  103a02:	83 c4 10             	add    $0x10,%esp
  103a05:	85 c0                	test   %eax,%eax
  103a07:	74 19                	je     103a22 <check_pgdir+0x4bf>
  103a09:	68 61 65 10 00       	push   $0x106561
  103a0e:	68 cd 62 10 00       	push   $0x1062cd
  103a13:	68 0d 02 00 00       	push   $0x20d
  103a18:	68 a8 62 10 00       	push   $0x1062a8
  103a1d:	e8 b7 c9 ff ff       	call   1003d9 <__panic>
    assert(page_ref(p2) == 0);
  103a22:	83 ec 0c             	sub    $0xc,%esp
  103a25:	ff 75 e4             	pushl  -0x1c(%ebp)
  103a28:	e8 95 ef ff ff       	call   1029c2 <page_ref>
  103a2d:	83 c4 10             	add    $0x10,%esp
  103a30:	85 c0                	test   %eax,%eax
  103a32:	74 19                	je     103a4d <check_pgdir+0x4ea>
  103a34:	68 3a 65 10 00       	push   $0x10653a
  103a39:	68 cd 62 10 00       	push   $0x1062cd
  103a3e:	68 0e 02 00 00       	push   $0x20e
  103a43:	68 a8 62 10 00       	push   $0x1062a8
  103a48:	e8 8c c9 ff ff       	call   1003d9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103a4d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103a52:	8b 00                	mov    (%eax),%eax
  103a54:	83 ec 0c             	sub    $0xc,%esp
  103a57:	50                   	push   %eax
  103a58:	e8 49 ef ff ff       	call   1029a6 <pde2page>
  103a5d:	83 c4 10             	add    $0x10,%esp
  103a60:	83 ec 0c             	sub    $0xc,%esp
  103a63:	50                   	push   %eax
  103a64:	e8 59 ef ff ff       	call   1029c2 <page_ref>
  103a69:	83 c4 10             	add    $0x10,%esp
  103a6c:	83 f8 01             	cmp    $0x1,%eax
  103a6f:	74 19                	je     103a8a <check_pgdir+0x527>
  103a71:	68 74 65 10 00       	push   $0x106574
  103a76:	68 cd 62 10 00       	push   $0x1062cd
  103a7b:	68 10 02 00 00       	push   $0x210
  103a80:	68 a8 62 10 00       	push   $0x1062a8
  103a85:	e8 4f c9 ff ff       	call   1003d9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103a8a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103a8f:	8b 00                	mov    (%eax),%eax
  103a91:	83 ec 0c             	sub    $0xc,%esp
  103a94:	50                   	push   %eax
  103a95:	e8 0c ef ff ff       	call   1029a6 <pde2page>
  103a9a:	83 c4 10             	add    $0x10,%esp
  103a9d:	83 ec 08             	sub    $0x8,%esp
  103aa0:	6a 01                	push   $0x1
  103aa2:	50                   	push   %eax
  103aa3:	e8 66 f1 ff ff       	call   102c0e <free_pages>
  103aa8:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
  103aab:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ab0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103ab6:	83 ec 0c             	sub    $0xc,%esp
  103ab9:	68 9b 65 10 00       	push   $0x10659b
  103abe:	e8 b0 c7 ff ff       	call   100273 <cprintf>
  103ac3:	83 c4 10             	add    $0x10,%esp
}
  103ac6:	90                   	nop
  103ac7:	c9                   	leave  
  103ac8:	c3                   	ret    

00103ac9 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103ac9:	55                   	push   %ebp
  103aca:	89 e5                	mov    %esp,%ebp
  103acc:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103acf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103ad6:	e9 a3 00 00 00       	jmp    103b7e <check_boot_pgdir+0xb5>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103ae4:	c1 e8 0c             	shr    $0xc,%eax
  103ae7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103aea:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103aef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103af2:	72 17                	jb     103b0b <check_boot_pgdir+0x42>
  103af4:	ff 75 f0             	pushl  -0x10(%ebp)
  103af7:	68 e0 61 10 00       	push   $0x1061e0
  103afc:	68 1c 02 00 00       	push   $0x21c
  103b01:	68 a8 62 10 00       	push   $0x1062a8
  103b06:	e8 ce c8 ff ff       	call   1003d9 <__panic>
  103b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b0e:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103b13:	89 c2                	mov    %eax,%edx
  103b15:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b1a:	83 ec 04             	sub    $0x4,%esp
  103b1d:	6a 00                	push   $0x0
  103b1f:	52                   	push   %edx
  103b20:	50                   	push   %eax
  103b21:	e8 f3 f6 ff ff       	call   103219 <get_pte>
  103b26:	83 c4 10             	add    $0x10,%esp
  103b29:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103b2c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103b30:	75 19                	jne    103b4b <check_boot_pgdir+0x82>
  103b32:	68 b8 65 10 00       	push   $0x1065b8
  103b37:	68 cd 62 10 00       	push   $0x1062cd
  103b3c:	68 1c 02 00 00       	push   $0x21c
  103b41:	68 a8 62 10 00       	push   $0x1062a8
  103b46:	e8 8e c8 ff ff       	call   1003d9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103b4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103b4e:	8b 00                	mov    (%eax),%eax
  103b50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b55:	89 c2                	mov    %eax,%edx
  103b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b5a:	39 c2                	cmp    %eax,%edx
  103b5c:	74 19                	je     103b77 <check_boot_pgdir+0xae>
  103b5e:	68 f5 65 10 00       	push   $0x1065f5
  103b63:	68 cd 62 10 00       	push   $0x1062cd
  103b68:	68 1d 02 00 00       	push   $0x21d
  103b6d:	68 a8 62 10 00       	push   $0x1062a8
  103b72:	e8 62 c8 ff ff       	call   1003d9 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103b77:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103b7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103b81:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103b86:	39 c2                	cmp    %eax,%edx
  103b88:	0f 82 4d ff ff ff    	jb     103adb <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103b8e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b93:	05 ac 0f 00 00       	add    $0xfac,%eax
  103b98:	8b 00                	mov    (%eax),%eax
  103b9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b9f:	89 c2                	mov    %eax,%edx
  103ba1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ba6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103ba9:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  103bb0:	77 17                	ja     103bc9 <check_boot_pgdir+0x100>
  103bb2:	ff 75 e4             	pushl  -0x1c(%ebp)
  103bb5:	68 84 62 10 00       	push   $0x106284
  103bba:	68 20 02 00 00       	push   $0x220
  103bbf:	68 a8 62 10 00       	push   $0x1062a8
  103bc4:	e8 10 c8 ff ff       	call   1003d9 <__panic>
  103bc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103bcc:	05 00 00 00 40       	add    $0x40000000,%eax
  103bd1:	39 c2                	cmp    %eax,%edx
  103bd3:	74 19                	je     103bee <check_boot_pgdir+0x125>
  103bd5:	68 0c 66 10 00       	push   $0x10660c
  103bda:	68 cd 62 10 00       	push   $0x1062cd
  103bdf:	68 20 02 00 00       	push   $0x220
  103be4:	68 a8 62 10 00       	push   $0x1062a8
  103be9:	e8 eb c7 ff ff       	call   1003d9 <__panic>

    assert(boot_pgdir[0] == 0);
  103bee:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103bf3:	8b 00                	mov    (%eax),%eax
  103bf5:	85 c0                	test   %eax,%eax
  103bf7:	74 19                	je     103c12 <check_boot_pgdir+0x149>
  103bf9:	68 40 66 10 00       	push   $0x106640
  103bfe:	68 cd 62 10 00       	push   $0x1062cd
  103c03:	68 22 02 00 00       	push   $0x222
  103c08:	68 a8 62 10 00       	push   $0x1062a8
  103c0d:	e8 c7 c7 ff ff       	call   1003d9 <__panic>

    struct Page *p;
    p = alloc_page();
  103c12:	83 ec 0c             	sub    $0xc,%esp
  103c15:	6a 01                	push   $0x1
  103c17:	e8 b4 ef ff ff       	call   102bd0 <alloc_pages>
  103c1c:	83 c4 10             	add    $0x10,%esp
  103c1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103c22:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c27:	6a 02                	push   $0x2
  103c29:	68 00 01 00 00       	push   $0x100
  103c2e:	ff 75 e0             	pushl  -0x20(%ebp)
  103c31:	50                   	push   %eax
  103c32:	e8 00 f8 ff ff       	call   103437 <page_insert>
  103c37:	83 c4 10             	add    $0x10,%esp
  103c3a:	85 c0                	test   %eax,%eax
  103c3c:	74 19                	je     103c57 <check_boot_pgdir+0x18e>
  103c3e:	68 54 66 10 00       	push   $0x106654
  103c43:	68 cd 62 10 00       	push   $0x1062cd
  103c48:	68 26 02 00 00       	push   $0x226
  103c4d:	68 a8 62 10 00       	push   $0x1062a8
  103c52:	e8 82 c7 ff ff       	call   1003d9 <__panic>
    assert(page_ref(p) == 1);
  103c57:	83 ec 0c             	sub    $0xc,%esp
  103c5a:	ff 75 e0             	pushl  -0x20(%ebp)
  103c5d:	e8 60 ed ff ff       	call   1029c2 <page_ref>
  103c62:	83 c4 10             	add    $0x10,%esp
  103c65:	83 f8 01             	cmp    $0x1,%eax
  103c68:	74 19                	je     103c83 <check_boot_pgdir+0x1ba>
  103c6a:	68 82 66 10 00       	push   $0x106682
  103c6f:	68 cd 62 10 00       	push   $0x1062cd
  103c74:	68 27 02 00 00       	push   $0x227
  103c79:	68 a8 62 10 00       	push   $0x1062a8
  103c7e:	e8 56 c7 ff ff       	call   1003d9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103c83:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c88:	6a 02                	push   $0x2
  103c8a:	68 00 11 00 00       	push   $0x1100
  103c8f:	ff 75 e0             	pushl  -0x20(%ebp)
  103c92:	50                   	push   %eax
  103c93:	e8 9f f7 ff ff       	call   103437 <page_insert>
  103c98:	83 c4 10             	add    $0x10,%esp
  103c9b:	85 c0                	test   %eax,%eax
  103c9d:	74 19                	je     103cb8 <check_boot_pgdir+0x1ef>
  103c9f:	68 94 66 10 00       	push   $0x106694
  103ca4:	68 cd 62 10 00       	push   $0x1062cd
  103ca9:	68 28 02 00 00       	push   $0x228
  103cae:	68 a8 62 10 00       	push   $0x1062a8
  103cb3:	e8 21 c7 ff ff       	call   1003d9 <__panic>
    assert(page_ref(p) == 2);
  103cb8:	83 ec 0c             	sub    $0xc,%esp
  103cbb:	ff 75 e0             	pushl  -0x20(%ebp)
  103cbe:	e8 ff ec ff ff       	call   1029c2 <page_ref>
  103cc3:	83 c4 10             	add    $0x10,%esp
  103cc6:	83 f8 02             	cmp    $0x2,%eax
  103cc9:	74 19                	je     103ce4 <check_boot_pgdir+0x21b>
  103ccb:	68 cb 66 10 00       	push   $0x1066cb
  103cd0:	68 cd 62 10 00       	push   $0x1062cd
  103cd5:	68 29 02 00 00       	push   $0x229
  103cda:	68 a8 62 10 00       	push   $0x1062a8
  103cdf:	e8 f5 c6 ff ff       	call   1003d9 <__panic>

    const char *str = "ucore: Hello world!!";
  103ce4:	c7 45 dc dc 66 10 00 	movl   $0x1066dc,-0x24(%ebp)
    strcpy((void *)0x100, str);
  103ceb:	83 ec 08             	sub    $0x8,%esp
  103cee:	ff 75 dc             	pushl  -0x24(%ebp)
  103cf1:	68 00 01 00 00       	push   $0x100
  103cf6:	e8 05 13 00 00       	call   105000 <strcpy>
  103cfb:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103cfe:	83 ec 08             	sub    $0x8,%esp
  103d01:	68 00 11 00 00       	push   $0x1100
  103d06:	68 00 01 00 00       	push   $0x100
  103d0b:	e8 6a 13 00 00       	call   10507a <strcmp>
  103d10:	83 c4 10             	add    $0x10,%esp
  103d13:	85 c0                	test   %eax,%eax
  103d15:	74 19                	je     103d30 <check_boot_pgdir+0x267>
  103d17:	68 f4 66 10 00       	push   $0x1066f4
  103d1c:	68 cd 62 10 00       	push   $0x1062cd
  103d21:	68 2d 02 00 00       	push   $0x22d
  103d26:	68 a8 62 10 00       	push   $0x1062a8
  103d2b:	e8 a9 c6 ff ff       	call   1003d9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103d30:	83 ec 0c             	sub    $0xc,%esp
  103d33:	ff 75 e0             	pushl  -0x20(%ebp)
  103d36:	e8 ec eb ff ff       	call   102927 <page2kva>
  103d3b:	83 c4 10             	add    $0x10,%esp
  103d3e:	05 00 01 00 00       	add    $0x100,%eax
  103d43:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103d46:	83 ec 0c             	sub    $0xc,%esp
  103d49:	68 00 01 00 00       	push   $0x100
  103d4e:	e8 55 12 00 00       	call   104fa8 <strlen>
  103d53:	83 c4 10             	add    $0x10,%esp
  103d56:	85 c0                	test   %eax,%eax
  103d58:	74 19                	je     103d73 <check_boot_pgdir+0x2aa>
  103d5a:	68 2c 67 10 00       	push   $0x10672c
  103d5f:	68 cd 62 10 00       	push   $0x1062cd
  103d64:	68 30 02 00 00       	push   $0x230
  103d69:	68 a8 62 10 00       	push   $0x1062a8
  103d6e:	e8 66 c6 ff ff       	call   1003d9 <__panic>

    free_page(p);
  103d73:	83 ec 08             	sub    $0x8,%esp
  103d76:	6a 01                	push   $0x1
  103d78:	ff 75 e0             	pushl  -0x20(%ebp)
  103d7b:	e8 8e ee ff ff       	call   102c0e <free_pages>
  103d80:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(boot_pgdir[0]));
  103d83:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d88:	8b 00                	mov    (%eax),%eax
  103d8a:	83 ec 0c             	sub    $0xc,%esp
  103d8d:	50                   	push   %eax
  103d8e:	e8 13 ec ff ff       	call   1029a6 <pde2page>
  103d93:	83 c4 10             	add    $0x10,%esp
  103d96:	83 ec 08             	sub    $0x8,%esp
  103d99:	6a 01                	push   $0x1
  103d9b:	50                   	push   %eax
  103d9c:	e8 6d ee ff ff       	call   102c0e <free_pages>
  103da1:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
  103da4:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103da9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  103daf:	83 ec 0c             	sub    $0xc,%esp
  103db2:	68 50 67 10 00       	push   $0x106750
  103db7:	e8 b7 c4 ff ff       	call   100273 <cprintf>
  103dbc:	83 c4 10             	add    $0x10,%esp
}
  103dbf:	90                   	nop
  103dc0:	c9                   	leave  
  103dc1:	c3                   	ret    

00103dc2 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  103dc2:	55                   	push   %ebp
  103dc3:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  103dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  103dc8:	83 e0 04             	and    $0x4,%eax
  103dcb:	85 c0                	test   %eax,%eax
  103dcd:	74 07                	je     103dd6 <perm2str+0x14>
  103dcf:	b8 75 00 00 00       	mov    $0x75,%eax
  103dd4:	eb 05                	jmp    103ddb <perm2str+0x19>
  103dd6:	b8 2d 00 00 00       	mov    $0x2d,%eax
  103ddb:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  103de0:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  103de7:	8b 45 08             	mov    0x8(%ebp),%eax
  103dea:	83 e0 02             	and    $0x2,%eax
  103ded:	85 c0                	test   %eax,%eax
  103def:	74 07                	je     103df8 <perm2str+0x36>
  103df1:	b8 77 00 00 00       	mov    $0x77,%eax
  103df6:	eb 05                	jmp    103dfd <perm2str+0x3b>
  103df8:	b8 2d 00 00 00       	mov    $0x2d,%eax
  103dfd:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  103e02:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  103e09:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  103e0e:	5d                   	pop    %ebp
  103e0f:	c3                   	ret    

00103e10 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  103e10:	55                   	push   %ebp
  103e11:	89 e5                	mov    %esp,%ebp
  103e13:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  103e16:	8b 45 10             	mov    0x10(%ebp),%eax
  103e19:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103e1c:	72 0e                	jb     103e2c <get_pgtable_items+0x1c>
        return 0;
  103e1e:	b8 00 00 00 00       	mov    $0x0,%eax
  103e23:	e9 9a 00 00 00       	jmp    103ec2 <get_pgtable_items+0xb2>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  103e28:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  103e2c:	8b 45 10             	mov    0x10(%ebp),%eax
  103e2f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103e32:	73 18                	jae    103e4c <get_pgtable_items+0x3c>
  103e34:	8b 45 10             	mov    0x10(%ebp),%eax
  103e37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103e3e:	8b 45 14             	mov    0x14(%ebp),%eax
  103e41:	01 d0                	add    %edx,%eax
  103e43:	8b 00                	mov    (%eax),%eax
  103e45:	83 e0 01             	and    $0x1,%eax
  103e48:	85 c0                	test   %eax,%eax
  103e4a:	74 dc                	je     103e28 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
  103e4c:	8b 45 10             	mov    0x10(%ebp),%eax
  103e4f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103e52:	73 69                	jae    103ebd <get_pgtable_items+0xad>
        if (left_store != NULL) {
  103e54:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  103e58:	74 08                	je     103e62 <get_pgtable_items+0x52>
            *left_store = start;
  103e5a:	8b 45 18             	mov    0x18(%ebp),%eax
  103e5d:	8b 55 10             	mov    0x10(%ebp),%edx
  103e60:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  103e62:	8b 45 10             	mov    0x10(%ebp),%eax
  103e65:	8d 50 01             	lea    0x1(%eax),%edx
  103e68:	89 55 10             	mov    %edx,0x10(%ebp)
  103e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103e72:	8b 45 14             	mov    0x14(%ebp),%eax
  103e75:	01 d0                	add    %edx,%eax
  103e77:	8b 00                	mov    (%eax),%eax
  103e79:	83 e0 07             	and    $0x7,%eax
  103e7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  103e7f:	eb 04                	jmp    103e85 <get_pgtable_items+0x75>
            start ++;
  103e81:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  103e85:	8b 45 10             	mov    0x10(%ebp),%eax
  103e88:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103e8b:	73 1d                	jae    103eaa <get_pgtable_items+0x9a>
  103e8d:	8b 45 10             	mov    0x10(%ebp),%eax
  103e90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103e97:	8b 45 14             	mov    0x14(%ebp),%eax
  103e9a:	01 d0                	add    %edx,%eax
  103e9c:	8b 00                	mov    (%eax),%eax
  103e9e:	83 e0 07             	and    $0x7,%eax
  103ea1:	89 c2                	mov    %eax,%edx
  103ea3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103ea6:	39 c2                	cmp    %eax,%edx
  103ea8:	74 d7                	je     103e81 <get_pgtable_items+0x71>
            start ++;
        }
        if (right_store != NULL) {
  103eaa:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  103eae:	74 08                	je     103eb8 <get_pgtable_items+0xa8>
            *right_store = start;
  103eb0:	8b 45 1c             	mov    0x1c(%ebp),%eax
  103eb3:	8b 55 10             	mov    0x10(%ebp),%edx
  103eb6:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  103eb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103ebb:	eb 05                	jmp    103ec2 <get_pgtable_items+0xb2>
    }
    return 0;
  103ebd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103ec2:	c9                   	leave  
  103ec3:	c3                   	ret    

00103ec4 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  103ec4:	55                   	push   %ebp
  103ec5:	89 e5                	mov    %esp,%ebp
  103ec7:	57                   	push   %edi
  103ec8:	56                   	push   %esi
  103ec9:	53                   	push   %ebx
  103eca:	83 ec 2c             	sub    $0x2c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  103ecd:	83 ec 0c             	sub    $0xc,%esp
  103ed0:	68 70 67 10 00       	push   $0x106770
  103ed5:	e8 99 c3 ff ff       	call   100273 <cprintf>
  103eda:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
  103edd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  103ee4:	e9 e5 00 00 00       	jmp    103fce <print_pgdir+0x10a>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  103ee9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103eec:	83 ec 0c             	sub    $0xc,%esp
  103eef:	50                   	push   %eax
  103ef0:	e8 cd fe ff ff       	call   103dc2 <perm2str>
  103ef5:	83 c4 10             	add    $0x10,%esp
  103ef8:	89 c7                	mov    %eax,%edi
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  103efa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103efd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f00:	29 c2                	sub    %eax,%edx
  103f02:	89 d0                	mov    %edx,%eax
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  103f04:	c1 e0 16             	shl    $0x16,%eax
  103f07:	89 c3                	mov    %eax,%ebx
  103f09:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103f0c:	c1 e0 16             	shl    $0x16,%eax
  103f0f:	89 c1                	mov    %eax,%ecx
  103f11:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f14:	c1 e0 16             	shl    $0x16,%eax
  103f17:	89 c2                	mov    %eax,%edx
  103f19:	8b 75 dc             	mov    -0x24(%ebp),%esi
  103f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f1f:	29 c6                	sub    %eax,%esi
  103f21:	89 f0                	mov    %esi,%eax
  103f23:	83 ec 08             	sub    $0x8,%esp
  103f26:	57                   	push   %edi
  103f27:	53                   	push   %ebx
  103f28:	51                   	push   %ecx
  103f29:	52                   	push   %edx
  103f2a:	50                   	push   %eax
  103f2b:	68 a1 67 10 00       	push   $0x1067a1
  103f30:	e8 3e c3 ff ff       	call   100273 <cprintf>
  103f35:	83 c4 20             	add    $0x20,%esp
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  103f38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f3b:	c1 e0 0a             	shl    $0xa,%eax
  103f3e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  103f41:	eb 4f                	jmp    103f92 <print_pgdir+0xce>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  103f43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103f46:	83 ec 0c             	sub    $0xc,%esp
  103f49:	50                   	push   %eax
  103f4a:	e8 73 fe ff ff       	call   103dc2 <perm2str>
  103f4f:	83 c4 10             	add    $0x10,%esp
  103f52:	89 c7                	mov    %eax,%edi
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  103f54:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103f57:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103f5a:	29 c2                	sub    %eax,%edx
  103f5c:	89 d0                	mov    %edx,%eax
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  103f5e:	c1 e0 0c             	shl    $0xc,%eax
  103f61:	89 c3                	mov    %eax,%ebx
  103f63:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103f66:	c1 e0 0c             	shl    $0xc,%eax
  103f69:	89 c1                	mov    %eax,%ecx
  103f6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103f6e:	c1 e0 0c             	shl    $0xc,%eax
  103f71:	89 c2                	mov    %eax,%edx
  103f73:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  103f76:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103f79:	29 c6                	sub    %eax,%esi
  103f7b:	89 f0                	mov    %esi,%eax
  103f7d:	83 ec 08             	sub    $0x8,%esp
  103f80:	57                   	push   %edi
  103f81:	53                   	push   %ebx
  103f82:	51                   	push   %ecx
  103f83:	52                   	push   %edx
  103f84:	50                   	push   %eax
  103f85:	68 c0 67 10 00       	push   $0x1067c0
  103f8a:	e8 e4 c2 ff ff       	call   100273 <cprintf>
  103f8f:	83 c4 20             	add    $0x20,%esp
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  103f92:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  103f97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103f9a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f9d:	89 d3                	mov    %edx,%ebx
  103f9f:	c1 e3 0a             	shl    $0xa,%ebx
  103fa2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103fa5:	89 d1                	mov    %edx,%ecx
  103fa7:	c1 e1 0a             	shl    $0xa,%ecx
  103faa:	83 ec 08             	sub    $0x8,%esp
  103fad:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  103fb0:	52                   	push   %edx
  103fb1:	8d 55 d8             	lea    -0x28(%ebp),%edx
  103fb4:	52                   	push   %edx
  103fb5:	56                   	push   %esi
  103fb6:	50                   	push   %eax
  103fb7:	53                   	push   %ebx
  103fb8:	51                   	push   %ecx
  103fb9:	e8 52 fe ff ff       	call   103e10 <get_pgtable_items>
  103fbe:	83 c4 20             	add    $0x20,%esp
  103fc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103fc4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103fc8:	0f 85 75 ff ff ff    	jne    103f43 <print_pgdir+0x7f>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  103fce:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  103fd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103fd6:	83 ec 08             	sub    $0x8,%esp
  103fd9:	8d 55 dc             	lea    -0x24(%ebp),%edx
  103fdc:	52                   	push   %edx
  103fdd:	8d 55 e0             	lea    -0x20(%ebp),%edx
  103fe0:	52                   	push   %edx
  103fe1:	51                   	push   %ecx
  103fe2:	50                   	push   %eax
  103fe3:	68 00 04 00 00       	push   $0x400
  103fe8:	6a 00                	push   $0x0
  103fea:	e8 21 fe ff ff       	call   103e10 <get_pgtable_items>
  103fef:	83 c4 20             	add    $0x20,%esp
  103ff2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103ff5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103ff9:	0f 85 ea fe ff ff    	jne    103ee9 <print_pgdir+0x25>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  103fff:	83 ec 0c             	sub    $0xc,%esp
  104002:	68 e4 67 10 00       	push   $0x1067e4
  104007:	e8 67 c2 ff ff       	call   100273 <cprintf>
  10400c:	83 c4 10             	add    $0x10,%esp
}
  10400f:	90                   	nop
  104010:	8d 65 f4             	lea    -0xc(%ebp),%esp
  104013:	5b                   	pop    %ebx
  104014:	5e                   	pop    %esi
  104015:	5f                   	pop    %edi
  104016:	5d                   	pop    %ebp
  104017:	c3                   	ret    

00104018 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  104018:	55                   	push   %ebp
  104019:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10401b:	8b 45 08             	mov    0x8(%ebp),%eax
  10401e:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  104024:	29 d0                	sub    %edx,%eax
  104026:	c1 f8 02             	sar    $0x2,%eax
  104029:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10402f:	5d                   	pop    %ebp
  104030:	c3                   	ret    

00104031 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  104031:	55                   	push   %ebp
  104032:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
  104034:	ff 75 08             	pushl  0x8(%ebp)
  104037:	e8 dc ff ff ff       	call   104018 <page2ppn>
  10403c:	83 c4 04             	add    $0x4,%esp
  10403f:	c1 e0 0c             	shl    $0xc,%eax
}
  104042:	c9                   	leave  
  104043:	c3                   	ret    

00104044 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  104044:	55                   	push   %ebp
  104045:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104047:	8b 45 08             	mov    0x8(%ebp),%eax
  10404a:	8b 00                	mov    (%eax),%eax
}
  10404c:	5d                   	pop    %ebp
  10404d:	c3                   	ret    

0010404e <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  10404e:	55                   	push   %ebp
  10404f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104051:	8b 45 08             	mov    0x8(%ebp),%eax
  104054:	8b 55 0c             	mov    0xc(%ebp),%edx
  104057:	89 10                	mov    %edx,(%eax)
}
  104059:	90                   	nop
  10405a:	5d                   	pop    %ebp
  10405b:	c3                   	ret    

0010405c <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  10405c:	55                   	push   %ebp
  10405d:	89 e5                	mov    %esp,%ebp
  10405f:	83 ec 10             	sub    $0x10,%esp
  104062:	c7 45 fc 1c af 11 00 	movl   $0x11af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104069:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10406c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10406f:	89 50 04             	mov    %edx,0x4(%eax)
  104072:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104075:	8b 50 04             	mov    0x4(%eax),%edx
  104078:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10407b:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  10407d:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104084:	00 00 00 
}
  104087:	90                   	nop
  104088:	c9                   	leave  
  104089:	c3                   	ret    

0010408a <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  10408a:	55                   	push   %ebp
  10408b:	89 e5                	mov    %esp,%ebp
  10408d:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  104090:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104094:	75 16                	jne    1040ac <default_init_memmap+0x22>
  104096:	68 18 68 10 00       	push   $0x106818
  10409b:	68 1e 68 10 00       	push   $0x10681e
  1040a0:	6a 6d                	push   $0x6d
  1040a2:	68 33 68 10 00       	push   $0x106833
  1040a7:	e8 2d c3 ff ff       	call   1003d9 <__panic>
    struct Page *p = base;
  1040ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1040af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1040b2:	e9 cb 00 00 00       	jmp    104182 <default_init_memmap+0xf8>
        assert(PageReserved(p));
  1040b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1040ba:	83 c0 04             	add    $0x4,%eax
  1040bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1040c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1040c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1040ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1040cd:	0f a3 10             	bt     %edx,(%eax)
  1040d0:	19 c0                	sbb    %eax,%eax
  1040d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return oldbit != 0;
  1040d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1040d9:	0f 95 c0             	setne  %al
  1040dc:	0f b6 c0             	movzbl %al,%eax
  1040df:	85 c0                	test   %eax,%eax
  1040e1:	75 16                	jne    1040f9 <default_init_memmap+0x6f>
  1040e3:	68 49 68 10 00       	push   $0x106849
  1040e8:	68 1e 68 10 00       	push   $0x10681e
  1040ed:	6a 70                	push   $0x70
  1040ef:	68 33 68 10 00       	push   $0x106833
  1040f4:	e8 e0 c2 ff ff       	call   1003d9 <__panic>
        p->property = 0;
  1040f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1040fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        SetPageProperty(p);
  104103:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104106:	83 c0 04             	add    $0x4,%eax
  104109:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
  104110:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104113:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104116:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104119:	0f ab 10             	bts    %edx,(%eax)
        p->flags = 0;
  10411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10411f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  104126:	83 ec 08             	sub    $0x8,%esp
  104129:	6a 00                	push   $0x0
  10412b:	ff 75 f4             	pushl  -0xc(%ebp)
  10412e:	e8 1b ff ff ff       	call   10404e <set_page_ref>
  104133:	83 c4 10             	add    $0x10,%esp
        list_add_before(&free_list, &(p->page_link));
  104136:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104139:	83 c0 0c             	add    $0xc,%eax
  10413c:	c7 45 f0 1c af 11 00 	movl   $0x11af1c,-0x10(%ebp)
  104143:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  104146:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104149:	8b 00                	mov    (%eax),%eax
  10414b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10414e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104151:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104154:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104157:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  10415a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10415d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104160:	89 10                	mov    %edx,(%eax)
  104162:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104165:	8b 10                	mov    (%eax),%edx
  104167:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10416a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10416d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104170:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104173:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104176:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104179:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10417c:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  10417e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104182:	8b 55 0c             	mov    0xc(%ebp),%edx
  104185:	89 d0                	mov    %edx,%eax
  104187:	c1 e0 02             	shl    $0x2,%eax
  10418a:	01 d0                	add    %edx,%eax
  10418c:	c1 e0 02             	shl    $0x2,%eax
  10418f:	89 c2                	mov    %eax,%edx
  104191:	8b 45 08             	mov    0x8(%ebp),%eax
  104194:	01 d0                	add    %edx,%eax
  104196:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104199:	0f 85 18 ff ff ff    	jne    1040b7 <default_init_memmap+0x2d>
        SetPageProperty(p);
        p->flags = 0;
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }
    base->property = n;
  10419f:	8b 45 08             	mov    0x8(%ebp),%eax
  1041a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1041a5:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1041a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1041ab:	83 c0 04             	add    $0x4,%eax
  1041ae:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  1041b5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  1041b8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1041bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1041be:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  1041c1:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  1041c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1041ca:	01 d0                	add    %edx,%eax
  1041cc:	a3 24 af 11 00       	mov    %eax,0x11af24
}
  1041d1:	90                   	nop
  1041d2:	c9                   	leave  
  1041d3:	c3                   	ret    

001041d4 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  1041d4:	55                   	push   %ebp
  1041d5:	89 e5                	mov    %esp,%ebp
  1041d7:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  1041da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1041de:	75 16                	jne    1041f6 <default_alloc_pages+0x22>
  1041e0:	68 18 68 10 00       	push   $0x106818
  1041e5:	68 1e 68 10 00       	push   $0x10681e
  1041ea:	6a 7e                	push   $0x7e
  1041ec:	68 33 68 10 00       	push   $0x106833
  1041f1:	e8 e3 c1 ff ff       	call   1003d9 <__panic>
    if (n > nr_free) {
  1041f6:	a1 24 af 11 00       	mov    0x11af24,%eax
  1041fb:	3b 45 08             	cmp    0x8(%ebp),%eax
  1041fe:	73 0a                	jae    10420a <default_alloc_pages+0x36>
        return NULL;
  104200:	b8 00 00 00 00       	mov    $0x0,%eax
  104205:	e9 21 01 00 00       	jmp    10432b <default_alloc_pages+0x157>
    }
    struct Page *page = NULL;
  10420a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  104211:	c7 45 f0 1c af 11 00 	movl   $0x11af1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104218:	eb 1c                	jmp    104236 <default_alloc_pages+0x62>
        struct Page *p = le2page(le, page_link);
  10421a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10421d:	83 e8 0c             	sub    $0xc,%eax
  104220:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if (p->property >= n) {
  104223:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104226:	8b 40 08             	mov    0x8(%eax),%eax
  104229:	3b 45 08             	cmp    0x8(%ebp),%eax
  10422c:	72 08                	jb     104236 <default_alloc_pages+0x62>
            page = p;
  10422e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104231:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  104234:	eb 18                	jmp    10424e <default_alloc_pages+0x7a>
  104236:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104239:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  10423c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10423f:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  104242:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104245:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  10424c:	75 cc                	jne    10421a <default_alloc_pages+0x46>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page == NULL) return NULL;
  10424e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104252:	75 0a                	jne    10425e <default_alloc_pages+0x8a>
  104254:	b8 00 00 00 00       	mov    $0x0,%eax
  104259:	e9 cd 00 00 00       	jmp    10432b <default_alloc_pages+0x157>
  10425e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104261:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104264:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104267:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *currle = list_next(le);
  10426a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    for (int i = 0; i < n; i++ ) {
  10426d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  104274:	eb 7c                	jmp    1042f2 <default_alloc_pages+0x11e>
  104276:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104279:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10427c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10427f:	8b 40 04             	mov    0x4(%eax),%eax
        list_entry_t *currle = list_next(currle);
  104282:	89 45 e8             	mov    %eax,-0x18(%ebp)
        struct Page *page_item = le2page(le, page_link);
  104285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104288:	83 e8 0c             	sub    $0xc,%eax
  10428b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        SetPageReserved(page_item);
  10428e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104291:	83 c0 04             	add    $0x4,%eax
  104294:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  10429b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  10429e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1042a1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1042a4:	0f ab 10             	bts    %edx,(%eax)
        ClearPageProperty(page_item);
  1042a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1042aa:	83 c0 04             	add    $0x4,%eax
  1042ad:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  1042b4:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1042b7:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1042ba:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1042bd:	0f b3 10             	btr    %edx,(%eax)
  1042c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1042c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  1042c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1042c9:	8b 40 04             	mov    0x4(%eax),%eax
  1042cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1042cf:	8b 12                	mov    (%edx),%edx
  1042d1:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1042d4:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1042d7:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1042da:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1042dd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1042e0:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1042e3:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1042e6:	89 10                	mov    %edx,(%eax)
        list_del(le);
        le = currle;
  1042e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1042eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
            break;
        }
    }
    if (page == NULL) return NULL;
    list_entry_t *currle = list_next(le);
    for (int i = 0; i < n; i++ ) {
  1042ee:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  1042f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1042f5:	3b 45 08             	cmp    0x8(%ebp),%eax
  1042f8:	0f 82 78 ff ff ff    	jb     104276 <default_alloc_pages+0xa2>
        SetPageReserved(page_item);
        ClearPageProperty(page_item);
        list_del(le);
        le = currle;
    }
    if (page->property > n) {
  1042fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104301:	8b 40 08             	mov    0x8(%eax),%eax
  104304:	3b 45 08             	cmp    0x8(%ebp),%eax
  104307:	76 12                	jbe    10431b <default_alloc_pages+0x147>
        le2page(le, page_link)->property = page->property - n;
  104309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10430c:	8d 50 f4             	lea    -0xc(%eax),%edx
  10430f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104312:	8b 40 08             	mov    0x8(%eax),%eax
  104315:	2b 45 08             	sub    0x8(%ebp),%eax
  104318:	89 42 08             	mov    %eax,0x8(%edx)
    }
    nr_free -= n;
  10431b:	a1 24 af 11 00       	mov    0x11af24,%eax
  104320:	2b 45 08             	sub    0x8(%ebp),%eax
  104323:	a3 24 af 11 00       	mov    %eax,0x11af24
    return page;
  104328:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10432b:	c9                   	leave  
  10432c:	c3                   	ret    

0010432d <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  10432d:	55                   	push   %ebp
  10432e:	89 e5                	mov    %esp,%ebp
  104330:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
  104336:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10433a:	75 19                	jne    104355 <default_free_pages+0x28>
  10433c:	68 18 68 10 00       	push   $0x106818
  104341:	68 1e 68 10 00       	push   $0x10681e
  104346:	68 9e 00 00 00       	push   $0x9e
  10434b:	68 33 68 10 00       	push   $0x106833
  104350:	e8 84 c0 ff ff       	call   1003d9 <__panic>
    struct Page *p = base;
  104355:	8b 45 08             	mov    0x8(%ebp),%eax
  104358:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  10435b:	e9 8f 00 00 00       	jmp    1043ef <default_free_pages+0xc2>
        assert(!PageReserved(p) && !PageProperty(p));
  104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104363:	83 c0 04             	add    $0x4,%eax
  104366:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  10436d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104370:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104373:	8b 55 c8             	mov    -0x38(%ebp),%edx
  104376:	0f a3 10             	bt     %edx,(%eax)
  104379:	19 c0                	sbb    %eax,%eax
  10437b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
  10437e:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  104382:	0f 95 c0             	setne  %al
  104385:	0f b6 c0             	movzbl %al,%eax
  104388:	85 c0                	test   %eax,%eax
  10438a:	75 2c                	jne    1043b8 <default_free_pages+0x8b>
  10438c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10438f:	83 c0 04             	add    $0x4,%eax
  104392:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  104399:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10439c:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10439f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1043a2:	0f a3 10             	bt     %edx,(%eax)
  1043a5:	19 c0                	sbb    %eax,%eax
  1043a7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1043aa:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1043ae:	0f 95 c0             	setne  %al
  1043b1:	0f b6 c0             	movzbl %al,%eax
  1043b4:	85 c0                	test   %eax,%eax
  1043b6:	74 19                	je     1043d1 <default_free_pages+0xa4>
  1043b8:	68 5c 68 10 00       	push   $0x10685c
  1043bd:	68 1e 68 10 00       	push   $0x10681e
  1043c2:	68 a1 00 00 00       	push   $0xa1
  1043c7:	68 33 68 10 00       	push   $0x106833
  1043cc:	e8 08 c0 ff ff       	call   1003d9 <__panic>
        p->flags = 0;
  1043d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043d4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  1043db:	83 ec 08             	sub    $0x8,%esp
  1043de:	6a 00                	push   $0x0
  1043e0:	ff 75 f4             	pushl  -0xc(%ebp)
  1043e3:	e8 66 fc ff ff       	call   10404e <set_page_ref>
  1043e8:	83 c4 10             	add    $0x10,%esp

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  1043eb:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1043ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  1043f2:	89 d0                	mov    %edx,%eax
  1043f4:	c1 e0 02             	shl    $0x2,%eax
  1043f7:	01 d0                	add    %edx,%eax
  1043f9:	c1 e0 02             	shl    $0x2,%eax
  1043fc:	89 c2                	mov    %eax,%edx
  1043fe:	8b 45 08             	mov    0x8(%ebp),%eax
  104401:	01 d0                	add    %edx,%eax
  104403:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104406:	0f 85 54 ff ff ff    	jne    104360 <default_free_pages+0x33>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  10440c:	8b 45 08             	mov    0x8(%ebp),%eax
  10440f:	8b 55 0c             	mov    0xc(%ebp),%edx
  104412:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104415:	8b 45 08             	mov    0x8(%ebp),%eax
  104418:	83 c0 04             	add    $0x4,%eax
  10441b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  104422:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104425:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104428:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10442b:	0f ab 10             	bts    %edx,(%eax)
  10442e:	c7 45 e8 1c af 11 00 	movl   $0x11af1c,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  104435:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104438:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  10443b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  10443e:	e9 08 01 00 00       	jmp    10454b <default_free_pages+0x21e>
        p = le2page(le, page_link);
  104443:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104446:	83 e8 0c             	sub    $0xc,%eax
  104449:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10444c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10444f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104452:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104455:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  104458:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  10445b:	8b 45 08             	mov    0x8(%ebp),%eax
  10445e:	8b 50 08             	mov    0x8(%eax),%edx
  104461:	89 d0                	mov    %edx,%eax
  104463:	c1 e0 02             	shl    $0x2,%eax
  104466:	01 d0                	add    %edx,%eax
  104468:	c1 e0 02             	shl    $0x2,%eax
  10446b:	89 c2                	mov    %eax,%edx
  10446d:	8b 45 08             	mov    0x8(%ebp),%eax
  104470:	01 d0                	add    %edx,%eax
  104472:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104475:	75 5a                	jne    1044d1 <default_free_pages+0x1a4>
            base->property += p->property;
  104477:	8b 45 08             	mov    0x8(%ebp),%eax
  10447a:	8b 50 08             	mov    0x8(%eax),%edx
  10447d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104480:	8b 40 08             	mov    0x8(%eax),%eax
  104483:	01 c2                	add    %eax,%edx
  104485:	8b 45 08             	mov    0x8(%ebp),%eax
  104488:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  10448b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10448e:	83 c0 04             	add    $0x4,%eax
  104491:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  104498:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10449b:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10449e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1044a1:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  1044a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044a7:	83 c0 0c             	add    $0xc,%eax
  1044aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  1044ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1044b0:	8b 40 04             	mov    0x4(%eax),%eax
  1044b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1044b6:	8b 12                	mov    (%edx),%edx
  1044b8:	89 55 b0             	mov    %edx,-0x50(%ebp)
  1044bb:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1044be:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1044c1:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1044c4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1044c7:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1044ca:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1044cd:	89 10                	mov    %edx,(%eax)
  1044cf:	eb 7a                	jmp    10454b <default_free_pages+0x21e>
        }
        else if (p + p->property == base) {
  1044d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044d4:	8b 50 08             	mov    0x8(%eax),%edx
  1044d7:	89 d0                	mov    %edx,%eax
  1044d9:	c1 e0 02             	shl    $0x2,%eax
  1044dc:	01 d0                	add    %edx,%eax
  1044de:	c1 e0 02             	shl    $0x2,%eax
  1044e1:	89 c2                	mov    %eax,%edx
  1044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044e6:	01 d0                	add    %edx,%eax
  1044e8:	3b 45 08             	cmp    0x8(%ebp),%eax
  1044eb:	75 5e                	jne    10454b <default_free_pages+0x21e>
            p->property += base->property;
  1044ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044f0:	8b 50 08             	mov    0x8(%eax),%edx
  1044f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1044f6:	8b 40 08             	mov    0x8(%eax),%eax
  1044f9:	01 c2                	add    %eax,%edx
  1044fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044fe:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  104501:	8b 45 08             	mov    0x8(%ebp),%eax
  104504:	83 c0 04             	add    $0x4,%eax
  104507:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  10450e:	89 45 9c             	mov    %eax,-0x64(%ebp)
  104511:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104514:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104517:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  10451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10451d:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104523:	83 c0 0c             	add    $0xc,%eax
  104526:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  104529:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10452c:	8b 40 04             	mov    0x4(%eax),%eax
  10452f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104532:	8b 12                	mov    (%edx),%edx
  104534:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  104537:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  10453a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  10453d:	8b 55 a0             	mov    -0x60(%ebp),%edx
  104540:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104543:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104546:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104549:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  10454b:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  104552:	0f 85 eb fe ff ff    	jne    104443 <default_free_pages+0x116>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  104558:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  10455e:	8b 45 0c             	mov    0xc(%ebp),%eax
  104561:	01 d0                	add    %edx,%eax
  104563:	a3 24 af 11 00       	mov    %eax,0x11af24
    list_add(&free_list, &(base->page_link));
  104568:	8b 45 08             	mov    0x8(%ebp),%eax
  10456b:	83 c0 0c             	add    $0xc,%eax
  10456e:	c7 45 d0 1c af 11 00 	movl   $0x11af1c,-0x30(%ebp)
  104575:	89 45 98             	mov    %eax,-0x68(%ebp)
  104578:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10457b:	89 45 94             	mov    %eax,-0x6c(%ebp)
  10457e:	8b 45 98             	mov    -0x68(%ebp),%eax
  104581:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  104584:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104587:	8b 40 04             	mov    0x4(%eax),%eax
  10458a:	8b 55 90             	mov    -0x70(%ebp),%edx
  10458d:	89 55 8c             	mov    %edx,-0x74(%ebp)
  104590:	8b 55 94             	mov    -0x6c(%ebp),%edx
  104593:	89 55 88             	mov    %edx,-0x78(%ebp)
  104596:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  104599:	8b 45 84             	mov    -0x7c(%ebp),%eax
  10459c:	8b 55 8c             	mov    -0x74(%ebp),%edx
  10459f:	89 10                	mov    %edx,(%eax)
  1045a1:	8b 45 84             	mov    -0x7c(%ebp),%eax
  1045a4:	8b 10                	mov    (%eax),%edx
  1045a6:	8b 45 88             	mov    -0x78(%ebp),%eax
  1045a9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1045ac:	8b 45 8c             	mov    -0x74(%ebp),%eax
  1045af:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1045b2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1045b5:	8b 45 8c             	mov    -0x74(%ebp),%eax
  1045b8:	8b 55 88             	mov    -0x78(%ebp),%edx
  1045bb:	89 10                	mov    %edx,(%eax)
}
  1045bd:	90                   	nop
  1045be:	c9                   	leave  
  1045bf:	c3                   	ret    

001045c0 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  1045c0:	55                   	push   %ebp
  1045c1:	89 e5                	mov    %esp,%ebp
    return nr_free;
  1045c3:	a1 24 af 11 00       	mov    0x11af24,%eax
}
  1045c8:	5d                   	pop    %ebp
  1045c9:	c3                   	ret    

001045ca <basic_check>:

static void
basic_check(void) {
  1045ca:	55                   	push   %ebp
  1045cb:	89 e5                	mov    %esp,%ebp
  1045cd:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  1045d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1045d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1045dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  1045e3:	83 ec 0c             	sub    $0xc,%esp
  1045e6:	6a 01                	push   $0x1
  1045e8:	e8 e3 e5 ff ff       	call   102bd0 <alloc_pages>
  1045ed:	83 c4 10             	add    $0x10,%esp
  1045f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1045f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1045f7:	75 19                	jne    104612 <basic_check+0x48>
  1045f9:	68 81 68 10 00       	push   $0x106881
  1045fe:	68 1e 68 10 00       	push   $0x10681e
  104603:	68 c4 00 00 00       	push   $0xc4
  104608:	68 33 68 10 00       	push   $0x106833
  10460d:	e8 c7 bd ff ff       	call   1003d9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104612:	83 ec 0c             	sub    $0xc,%esp
  104615:	6a 01                	push   $0x1
  104617:	e8 b4 e5 ff ff       	call   102bd0 <alloc_pages>
  10461c:	83 c4 10             	add    $0x10,%esp
  10461f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104622:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104626:	75 19                	jne    104641 <basic_check+0x77>
  104628:	68 9d 68 10 00       	push   $0x10689d
  10462d:	68 1e 68 10 00       	push   $0x10681e
  104632:	68 c5 00 00 00       	push   $0xc5
  104637:	68 33 68 10 00       	push   $0x106833
  10463c:	e8 98 bd ff ff       	call   1003d9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104641:	83 ec 0c             	sub    $0xc,%esp
  104644:	6a 01                	push   $0x1
  104646:	e8 85 e5 ff ff       	call   102bd0 <alloc_pages>
  10464b:	83 c4 10             	add    $0x10,%esp
  10464e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104651:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104655:	75 19                	jne    104670 <basic_check+0xa6>
  104657:	68 b9 68 10 00       	push   $0x1068b9
  10465c:	68 1e 68 10 00       	push   $0x10681e
  104661:	68 c6 00 00 00       	push   $0xc6
  104666:	68 33 68 10 00       	push   $0x106833
  10466b:	e8 69 bd ff ff       	call   1003d9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104670:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104673:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104676:	74 10                	je     104688 <basic_check+0xbe>
  104678:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10467b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10467e:	74 08                	je     104688 <basic_check+0xbe>
  104680:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104683:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104686:	75 19                	jne    1046a1 <basic_check+0xd7>
  104688:	68 d8 68 10 00       	push   $0x1068d8
  10468d:	68 1e 68 10 00       	push   $0x10681e
  104692:	68 c8 00 00 00       	push   $0xc8
  104697:	68 33 68 10 00       	push   $0x106833
  10469c:	e8 38 bd ff ff       	call   1003d9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  1046a1:	83 ec 0c             	sub    $0xc,%esp
  1046a4:	ff 75 ec             	pushl  -0x14(%ebp)
  1046a7:	e8 98 f9 ff ff       	call   104044 <page_ref>
  1046ac:	83 c4 10             	add    $0x10,%esp
  1046af:	85 c0                	test   %eax,%eax
  1046b1:	75 24                	jne    1046d7 <basic_check+0x10d>
  1046b3:	83 ec 0c             	sub    $0xc,%esp
  1046b6:	ff 75 f0             	pushl  -0x10(%ebp)
  1046b9:	e8 86 f9 ff ff       	call   104044 <page_ref>
  1046be:	83 c4 10             	add    $0x10,%esp
  1046c1:	85 c0                	test   %eax,%eax
  1046c3:	75 12                	jne    1046d7 <basic_check+0x10d>
  1046c5:	83 ec 0c             	sub    $0xc,%esp
  1046c8:	ff 75 f4             	pushl  -0xc(%ebp)
  1046cb:	e8 74 f9 ff ff       	call   104044 <page_ref>
  1046d0:	83 c4 10             	add    $0x10,%esp
  1046d3:	85 c0                	test   %eax,%eax
  1046d5:	74 19                	je     1046f0 <basic_check+0x126>
  1046d7:	68 fc 68 10 00       	push   $0x1068fc
  1046dc:	68 1e 68 10 00       	push   $0x10681e
  1046e1:	68 c9 00 00 00       	push   $0xc9
  1046e6:	68 33 68 10 00       	push   $0x106833
  1046eb:	e8 e9 bc ff ff       	call   1003d9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1046f0:	83 ec 0c             	sub    $0xc,%esp
  1046f3:	ff 75 ec             	pushl  -0x14(%ebp)
  1046f6:	e8 36 f9 ff ff       	call   104031 <page2pa>
  1046fb:	83 c4 10             	add    $0x10,%esp
  1046fe:	89 c2                	mov    %eax,%edx
  104700:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104705:	c1 e0 0c             	shl    $0xc,%eax
  104708:	39 c2                	cmp    %eax,%edx
  10470a:	72 19                	jb     104725 <basic_check+0x15b>
  10470c:	68 38 69 10 00       	push   $0x106938
  104711:	68 1e 68 10 00       	push   $0x10681e
  104716:	68 cb 00 00 00       	push   $0xcb
  10471b:	68 33 68 10 00       	push   $0x106833
  104720:	e8 b4 bc ff ff       	call   1003d9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104725:	83 ec 0c             	sub    $0xc,%esp
  104728:	ff 75 f0             	pushl  -0x10(%ebp)
  10472b:	e8 01 f9 ff ff       	call   104031 <page2pa>
  104730:	83 c4 10             	add    $0x10,%esp
  104733:	89 c2                	mov    %eax,%edx
  104735:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10473a:	c1 e0 0c             	shl    $0xc,%eax
  10473d:	39 c2                	cmp    %eax,%edx
  10473f:	72 19                	jb     10475a <basic_check+0x190>
  104741:	68 55 69 10 00       	push   $0x106955
  104746:	68 1e 68 10 00       	push   $0x10681e
  10474b:	68 cc 00 00 00       	push   $0xcc
  104750:	68 33 68 10 00       	push   $0x106833
  104755:	e8 7f bc ff ff       	call   1003d9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  10475a:	83 ec 0c             	sub    $0xc,%esp
  10475d:	ff 75 f4             	pushl  -0xc(%ebp)
  104760:	e8 cc f8 ff ff       	call   104031 <page2pa>
  104765:	83 c4 10             	add    $0x10,%esp
  104768:	89 c2                	mov    %eax,%edx
  10476a:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10476f:	c1 e0 0c             	shl    $0xc,%eax
  104772:	39 c2                	cmp    %eax,%edx
  104774:	72 19                	jb     10478f <basic_check+0x1c5>
  104776:	68 72 69 10 00       	push   $0x106972
  10477b:	68 1e 68 10 00       	push   $0x10681e
  104780:	68 cd 00 00 00       	push   $0xcd
  104785:	68 33 68 10 00       	push   $0x106833
  10478a:	e8 4a bc ff ff       	call   1003d9 <__panic>

    list_entry_t free_list_store = free_list;
  10478f:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104794:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  10479a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10479d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1047a0:	c7 45 e4 1c af 11 00 	movl   $0x11af1c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1047a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1047aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1047ad:	89 50 04             	mov    %edx,0x4(%eax)
  1047b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1047b3:	8b 50 04             	mov    0x4(%eax),%edx
  1047b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1047b9:	89 10                	mov    %edx,(%eax)
  1047bb:	c7 45 d8 1c af 11 00 	movl   $0x11af1c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  1047c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1047c5:	8b 40 04             	mov    0x4(%eax),%eax
  1047c8:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  1047cb:	0f 94 c0             	sete   %al
  1047ce:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1047d1:	85 c0                	test   %eax,%eax
  1047d3:	75 19                	jne    1047ee <basic_check+0x224>
  1047d5:	68 8f 69 10 00       	push   $0x10698f
  1047da:	68 1e 68 10 00       	push   $0x10681e
  1047df:	68 d1 00 00 00       	push   $0xd1
  1047e4:	68 33 68 10 00       	push   $0x106833
  1047e9:	e8 eb bb ff ff       	call   1003d9 <__panic>

    unsigned int nr_free_store = nr_free;
  1047ee:	a1 24 af 11 00       	mov    0x11af24,%eax
  1047f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  1047f6:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  1047fd:	00 00 00 

    assert(alloc_page() == NULL);
  104800:	83 ec 0c             	sub    $0xc,%esp
  104803:	6a 01                	push   $0x1
  104805:	e8 c6 e3 ff ff       	call   102bd0 <alloc_pages>
  10480a:	83 c4 10             	add    $0x10,%esp
  10480d:	85 c0                	test   %eax,%eax
  10480f:	74 19                	je     10482a <basic_check+0x260>
  104811:	68 a6 69 10 00       	push   $0x1069a6
  104816:	68 1e 68 10 00       	push   $0x10681e
  10481b:	68 d6 00 00 00       	push   $0xd6
  104820:	68 33 68 10 00       	push   $0x106833
  104825:	e8 af bb ff ff       	call   1003d9 <__panic>

    free_page(p0);
  10482a:	83 ec 08             	sub    $0x8,%esp
  10482d:	6a 01                	push   $0x1
  10482f:	ff 75 ec             	pushl  -0x14(%ebp)
  104832:	e8 d7 e3 ff ff       	call   102c0e <free_pages>
  104837:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
  10483a:	83 ec 08             	sub    $0x8,%esp
  10483d:	6a 01                	push   $0x1
  10483f:	ff 75 f0             	pushl  -0x10(%ebp)
  104842:	e8 c7 e3 ff ff       	call   102c0e <free_pages>
  104847:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
  10484a:	83 ec 08             	sub    $0x8,%esp
  10484d:	6a 01                	push   $0x1
  10484f:	ff 75 f4             	pushl  -0xc(%ebp)
  104852:	e8 b7 e3 ff ff       	call   102c0e <free_pages>
  104857:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
  10485a:	a1 24 af 11 00       	mov    0x11af24,%eax
  10485f:	83 f8 03             	cmp    $0x3,%eax
  104862:	74 19                	je     10487d <basic_check+0x2b3>
  104864:	68 bb 69 10 00       	push   $0x1069bb
  104869:	68 1e 68 10 00       	push   $0x10681e
  10486e:	68 db 00 00 00       	push   $0xdb
  104873:	68 33 68 10 00       	push   $0x106833
  104878:	e8 5c bb ff ff       	call   1003d9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  10487d:	83 ec 0c             	sub    $0xc,%esp
  104880:	6a 01                	push   $0x1
  104882:	e8 49 e3 ff ff       	call   102bd0 <alloc_pages>
  104887:	83 c4 10             	add    $0x10,%esp
  10488a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10488d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104891:	75 19                	jne    1048ac <basic_check+0x2e2>
  104893:	68 81 68 10 00       	push   $0x106881
  104898:	68 1e 68 10 00       	push   $0x10681e
  10489d:	68 dd 00 00 00       	push   $0xdd
  1048a2:	68 33 68 10 00       	push   $0x106833
  1048a7:	e8 2d bb ff ff       	call   1003d9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  1048ac:	83 ec 0c             	sub    $0xc,%esp
  1048af:	6a 01                	push   $0x1
  1048b1:	e8 1a e3 ff ff       	call   102bd0 <alloc_pages>
  1048b6:	83 c4 10             	add    $0x10,%esp
  1048b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1048c0:	75 19                	jne    1048db <basic_check+0x311>
  1048c2:	68 9d 68 10 00       	push   $0x10689d
  1048c7:	68 1e 68 10 00       	push   $0x10681e
  1048cc:	68 de 00 00 00       	push   $0xde
  1048d1:	68 33 68 10 00       	push   $0x106833
  1048d6:	e8 fe ba ff ff       	call   1003d9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1048db:	83 ec 0c             	sub    $0xc,%esp
  1048de:	6a 01                	push   $0x1
  1048e0:	e8 eb e2 ff ff       	call   102bd0 <alloc_pages>
  1048e5:	83 c4 10             	add    $0x10,%esp
  1048e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1048eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1048ef:	75 19                	jne    10490a <basic_check+0x340>
  1048f1:	68 b9 68 10 00       	push   $0x1068b9
  1048f6:	68 1e 68 10 00       	push   $0x10681e
  1048fb:	68 df 00 00 00       	push   $0xdf
  104900:	68 33 68 10 00       	push   $0x106833
  104905:	e8 cf ba ff ff       	call   1003d9 <__panic>

    assert(alloc_page() == NULL);
  10490a:	83 ec 0c             	sub    $0xc,%esp
  10490d:	6a 01                	push   $0x1
  10490f:	e8 bc e2 ff ff       	call   102bd0 <alloc_pages>
  104914:	83 c4 10             	add    $0x10,%esp
  104917:	85 c0                	test   %eax,%eax
  104919:	74 19                	je     104934 <basic_check+0x36a>
  10491b:	68 a6 69 10 00       	push   $0x1069a6
  104920:	68 1e 68 10 00       	push   $0x10681e
  104925:	68 e1 00 00 00       	push   $0xe1
  10492a:	68 33 68 10 00       	push   $0x106833
  10492f:	e8 a5 ba ff ff       	call   1003d9 <__panic>

    free_page(p0);
  104934:	83 ec 08             	sub    $0x8,%esp
  104937:	6a 01                	push   $0x1
  104939:	ff 75 ec             	pushl  -0x14(%ebp)
  10493c:	e8 cd e2 ff ff       	call   102c0e <free_pages>
  104941:	83 c4 10             	add    $0x10,%esp
  104944:	c7 45 e8 1c af 11 00 	movl   $0x11af1c,-0x18(%ebp)
  10494b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10494e:	8b 40 04             	mov    0x4(%eax),%eax
  104951:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104954:	0f 94 c0             	sete   %al
  104957:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  10495a:	85 c0                	test   %eax,%eax
  10495c:	74 19                	je     104977 <basic_check+0x3ad>
  10495e:	68 c8 69 10 00       	push   $0x1069c8
  104963:	68 1e 68 10 00       	push   $0x10681e
  104968:	68 e4 00 00 00       	push   $0xe4
  10496d:	68 33 68 10 00       	push   $0x106833
  104972:	e8 62 ba ff ff       	call   1003d9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104977:	83 ec 0c             	sub    $0xc,%esp
  10497a:	6a 01                	push   $0x1
  10497c:	e8 4f e2 ff ff       	call   102bd0 <alloc_pages>
  104981:	83 c4 10             	add    $0x10,%esp
  104984:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104987:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10498a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10498d:	74 19                	je     1049a8 <basic_check+0x3de>
  10498f:	68 e0 69 10 00       	push   $0x1069e0
  104994:	68 1e 68 10 00       	push   $0x10681e
  104999:	68 e7 00 00 00       	push   $0xe7
  10499e:	68 33 68 10 00       	push   $0x106833
  1049a3:	e8 31 ba ff ff       	call   1003d9 <__panic>
    assert(alloc_page() == NULL);
  1049a8:	83 ec 0c             	sub    $0xc,%esp
  1049ab:	6a 01                	push   $0x1
  1049ad:	e8 1e e2 ff ff       	call   102bd0 <alloc_pages>
  1049b2:	83 c4 10             	add    $0x10,%esp
  1049b5:	85 c0                	test   %eax,%eax
  1049b7:	74 19                	je     1049d2 <basic_check+0x408>
  1049b9:	68 a6 69 10 00       	push   $0x1069a6
  1049be:	68 1e 68 10 00       	push   $0x10681e
  1049c3:	68 e8 00 00 00       	push   $0xe8
  1049c8:	68 33 68 10 00       	push   $0x106833
  1049cd:	e8 07 ba ff ff       	call   1003d9 <__panic>

    assert(nr_free == 0);
  1049d2:	a1 24 af 11 00       	mov    0x11af24,%eax
  1049d7:	85 c0                	test   %eax,%eax
  1049d9:	74 19                	je     1049f4 <basic_check+0x42a>
  1049db:	68 f9 69 10 00       	push   $0x1069f9
  1049e0:	68 1e 68 10 00       	push   $0x10681e
  1049e5:	68 ea 00 00 00       	push   $0xea
  1049ea:	68 33 68 10 00       	push   $0x106833
  1049ef:	e8 e5 b9 ff ff       	call   1003d9 <__panic>
    free_list = free_list_store;
  1049f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1049f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1049fa:	a3 1c af 11 00       	mov    %eax,0x11af1c
  1049ff:	89 15 20 af 11 00    	mov    %edx,0x11af20
    nr_free = nr_free_store;
  104a05:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a08:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_page(p);
  104a0d:	83 ec 08             	sub    $0x8,%esp
  104a10:	6a 01                	push   $0x1
  104a12:	ff 75 dc             	pushl  -0x24(%ebp)
  104a15:	e8 f4 e1 ff ff       	call   102c0e <free_pages>
  104a1a:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
  104a1d:	83 ec 08             	sub    $0x8,%esp
  104a20:	6a 01                	push   $0x1
  104a22:	ff 75 f0             	pushl  -0x10(%ebp)
  104a25:	e8 e4 e1 ff ff       	call   102c0e <free_pages>
  104a2a:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
  104a2d:	83 ec 08             	sub    $0x8,%esp
  104a30:	6a 01                	push   $0x1
  104a32:	ff 75 f4             	pushl  -0xc(%ebp)
  104a35:	e8 d4 e1 ff ff       	call   102c0e <free_pages>
  104a3a:	83 c4 10             	add    $0x10,%esp
}
  104a3d:	90                   	nop
  104a3e:	c9                   	leave  
  104a3f:	c3                   	ret    

00104a40 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104a40:	55                   	push   %ebp
  104a41:	89 e5                	mov    %esp,%ebp
  104a43:	81 ec 88 00 00 00    	sub    $0x88,%esp
    int count = 0, total = 0;
  104a49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104a50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104a57:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104a5e:	eb 60                	jmp    104ac0 <default_check+0x80>
        struct Page *p = le2page(le, page_link);
  104a60:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a63:	83 e8 0c             	sub    $0xc,%eax
  104a66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
  104a69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104a6c:	83 c0 04             	add    $0x4,%eax
  104a6f:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  104a76:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104a79:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104a7c:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104a7f:	0f a3 10             	bt     %edx,(%eax)
  104a82:	19 c0                	sbb    %eax,%eax
  104a84:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
  104a87:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
  104a8b:	0f 95 c0             	setne  %al
  104a8e:	0f b6 c0             	movzbl %al,%eax
  104a91:	85 c0                	test   %eax,%eax
  104a93:	75 19                	jne    104aae <default_check+0x6e>
  104a95:	68 06 6a 10 00       	push   $0x106a06
  104a9a:	68 1e 68 10 00       	push   $0x10681e
  104a9f:	68 fb 00 00 00       	push   $0xfb
  104aa4:	68 33 68 10 00       	push   $0x106833
  104aa9:	e8 2b b9 ff ff       	call   1003d9 <__panic>
        count ++, total += p->property;
  104aae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  104ab2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ab5:	8b 50 08             	mov    0x8(%eax),%edx
  104ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104abb:	01 d0                	add    %edx,%eax
  104abd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ac0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ac3:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  104ac6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104ac9:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  104acc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104acf:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  104ad6:	75 88                	jne    104a60 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  104ad8:	e8 66 e1 ff ff       	call   102c43 <nr_free_pages>
  104add:	89 c2                	mov    %eax,%edx
  104adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ae2:	39 c2                	cmp    %eax,%edx
  104ae4:	74 19                	je     104aff <default_check+0xbf>
  104ae6:	68 16 6a 10 00       	push   $0x106a16
  104aeb:	68 1e 68 10 00       	push   $0x10681e
  104af0:	68 fe 00 00 00       	push   $0xfe
  104af5:	68 33 68 10 00       	push   $0x106833
  104afa:	e8 da b8 ff ff       	call   1003d9 <__panic>

    basic_check();
  104aff:	e8 c6 fa ff ff       	call   1045ca <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104b04:	83 ec 0c             	sub    $0xc,%esp
  104b07:	6a 05                	push   $0x5
  104b09:	e8 c2 e0 ff ff       	call   102bd0 <alloc_pages>
  104b0e:	83 c4 10             	add    $0x10,%esp
  104b11:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
  104b14:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104b18:	75 19                	jne    104b33 <default_check+0xf3>
  104b1a:	68 2f 6a 10 00       	push   $0x106a2f
  104b1f:	68 1e 68 10 00       	push   $0x10681e
  104b24:	68 03 01 00 00       	push   $0x103
  104b29:	68 33 68 10 00       	push   $0x106833
  104b2e:	e8 a6 b8 ff ff       	call   1003d9 <__panic>
    assert(!PageProperty(p0));
  104b33:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104b36:	83 c0 04             	add    $0x4,%eax
  104b39:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
  104b40:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104b43:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104b46:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104b49:	0f a3 10             	bt     %edx,(%eax)
  104b4c:	19 c0                	sbb    %eax,%eax
  104b4e:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
  104b51:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
  104b55:	0f 95 c0             	setne  %al
  104b58:	0f b6 c0             	movzbl %al,%eax
  104b5b:	85 c0                	test   %eax,%eax
  104b5d:	74 19                	je     104b78 <default_check+0x138>
  104b5f:	68 3a 6a 10 00       	push   $0x106a3a
  104b64:	68 1e 68 10 00       	push   $0x10681e
  104b69:	68 04 01 00 00       	push   $0x104
  104b6e:	68 33 68 10 00       	push   $0x106833
  104b73:	e8 61 b8 ff ff       	call   1003d9 <__panic>

    list_entry_t free_list_store = free_list;
  104b78:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104b7d:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104b83:	89 45 80             	mov    %eax,-0x80(%ebp)
  104b86:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104b89:	c7 45 d0 1c af 11 00 	movl   $0x11af1c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104b90:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104b93:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104b96:	89 50 04             	mov    %edx,0x4(%eax)
  104b99:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104b9c:	8b 50 04             	mov    0x4(%eax),%edx
  104b9f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104ba2:	89 10                	mov    %edx,(%eax)
  104ba4:	c7 45 d8 1c af 11 00 	movl   $0x11af1c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  104bab:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104bae:	8b 40 04             	mov    0x4(%eax),%eax
  104bb1:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104bb4:	0f 94 c0             	sete   %al
  104bb7:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104bba:	85 c0                	test   %eax,%eax
  104bbc:	75 19                	jne    104bd7 <default_check+0x197>
  104bbe:	68 8f 69 10 00       	push   $0x10698f
  104bc3:	68 1e 68 10 00       	push   $0x10681e
  104bc8:	68 08 01 00 00       	push   $0x108
  104bcd:	68 33 68 10 00       	push   $0x106833
  104bd2:	e8 02 b8 ff ff       	call   1003d9 <__panic>
    assert(alloc_page() == NULL);
  104bd7:	83 ec 0c             	sub    $0xc,%esp
  104bda:	6a 01                	push   $0x1
  104bdc:	e8 ef df ff ff       	call   102bd0 <alloc_pages>
  104be1:	83 c4 10             	add    $0x10,%esp
  104be4:	85 c0                	test   %eax,%eax
  104be6:	74 19                	je     104c01 <default_check+0x1c1>
  104be8:	68 a6 69 10 00       	push   $0x1069a6
  104bed:	68 1e 68 10 00       	push   $0x10681e
  104bf2:	68 09 01 00 00       	push   $0x109
  104bf7:	68 33 68 10 00       	push   $0x106833
  104bfc:	e8 d8 b7 ff ff       	call   1003d9 <__panic>

    unsigned int nr_free_store = nr_free;
  104c01:	a1 24 af 11 00       	mov    0x11af24,%eax
  104c06:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
  104c09:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104c10:	00 00 00 

    free_pages(p0 + 2, 3);
  104c13:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c16:	83 c0 28             	add    $0x28,%eax
  104c19:	83 ec 08             	sub    $0x8,%esp
  104c1c:	6a 03                	push   $0x3
  104c1e:	50                   	push   %eax
  104c1f:	e8 ea df ff ff       	call   102c0e <free_pages>
  104c24:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
  104c27:	83 ec 0c             	sub    $0xc,%esp
  104c2a:	6a 04                	push   $0x4
  104c2c:	e8 9f df ff ff       	call   102bd0 <alloc_pages>
  104c31:	83 c4 10             	add    $0x10,%esp
  104c34:	85 c0                	test   %eax,%eax
  104c36:	74 19                	je     104c51 <default_check+0x211>
  104c38:	68 4c 6a 10 00       	push   $0x106a4c
  104c3d:	68 1e 68 10 00       	push   $0x10681e
  104c42:	68 0f 01 00 00       	push   $0x10f
  104c47:	68 33 68 10 00       	push   $0x106833
  104c4c:	e8 88 b7 ff ff       	call   1003d9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104c51:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c54:	83 c0 28             	add    $0x28,%eax
  104c57:	83 c0 04             	add    $0x4,%eax
  104c5a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  104c61:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104c64:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104c67:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104c6a:	0f a3 10             	bt     %edx,(%eax)
  104c6d:	19 c0                	sbb    %eax,%eax
  104c6f:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  104c72:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  104c76:	0f 95 c0             	setne  %al
  104c79:	0f b6 c0             	movzbl %al,%eax
  104c7c:	85 c0                	test   %eax,%eax
  104c7e:	74 0e                	je     104c8e <default_check+0x24e>
  104c80:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c83:	83 c0 28             	add    $0x28,%eax
  104c86:	8b 40 08             	mov    0x8(%eax),%eax
  104c89:	83 f8 03             	cmp    $0x3,%eax
  104c8c:	74 19                	je     104ca7 <default_check+0x267>
  104c8e:	68 64 6a 10 00       	push   $0x106a64
  104c93:	68 1e 68 10 00       	push   $0x10681e
  104c98:	68 10 01 00 00       	push   $0x110
  104c9d:	68 33 68 10 00       	push   $0x106833
  104ca2:	e8 32 b7 ff ff       	call   1003d9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  104ca7:	83 ec 0c             	sub    $0xc,%esp
  104caa:	6a 03                	push   $0x3
  104cac:	e8 1f df ff ff       	call   102bd0 <alloc_pages>
  104cb1:	83 c4 10             	add    $0x10,%esp
  104cb4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  104cb7:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  104cbb:	75 19                	jne    104cd6 <default_check+0x296>
  104cbd:	68 90 6a 10 00       	push   $0x106a90
  104cc2:	68 1e 68 10 00       	push   $0x10681e
  104cc7:	68 11 01 00 00       	push   $0x111
  104ccc:	68 33 68 10 00       	push   $0x106833
  104cd1:	e8 03 b7 ff ff       	call   1003d9 <__panic>
    assert(alloc_page() == NULL);
  104cd6:	83 ec 0c             	sub    $0xc,%esp
  104cd9:	6a 01                	push   $0x1
  104cdb:	e8 f0 de ff ff       	call   102bd0 <alloc_pages>
  104ce0:	83 c4 10             	add    $0x10,%esp
  104ce3:	85 c0                	test   %eax,%eax
  104ce5:	74 19                	je     104d00 <default_check+0x2c0>
  104ce7:	68 a6 69 10 00       	push   $0x1069a6
  104cec:	68 1e 68 10 00       	push   $0x10681e
  104cf1:	68 12 01 00 00       	push   $0x112
  104cf6:	68 33 68 10 00       	push   $0x106833
  104cfb:	e8 d9 b6 ff ff       	call   1003d9 <__panic>
    assert(p0 + 2 == p1);
  104d00:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104d03:	83 c0 28             	add    $0x28,%eax
  104d06:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
  104d09:	74 19                	je     104d24 <default_check+0x2e4>
  104d0b:	68 ae 6a 10 00       	push   $0x106aae
  104d10:	68 1e 68 10 00       	push   $0x10681e
  104d15:	68 13 01 00 00       	push   $0x113
  104d1a:	68 33 68 10 00       	push   $0x106833
  104d1f:	e8 b5 b6 ff ff       	call   1003d9 <__panic>

    p2 = p0 + 1;
  104d24:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104d27:	83 c0 14             	add    $0x14,%eax
  104d2a:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
  104d2d:	83 ec 08             	sub    $0x8,%esp
  104d30:	6a 01                	push   $0x1
  104d32:	ff 75 dc             	pushl  -0x24(%ebp)
  104d35:	e8 d4 de ff ff       	call   102c0e <free_pages>
  104d3a:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
  104d3d:	83 ec 08             	sub    $0x8,%esp
  104d40:	6a 03                	push   $0x3
  104d42:	ff 75 c4             	pushl  -0x3c(%ebp)
  104d45:	e8 c4 de ff ff       	call   102c0e <free_pages>
  104d4a:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
  104d4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104d50:	83 c0 04             	add    $0x4,%eax
  104d53:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  104d5a:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104d5d:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104d60:	8b 55 c8             	mov    -0x38(%ebp),%edx
  104d63:	0f a3 10             	bt     %edx,(%eax)
  104d66:	19 c0                	sbb    %eax,%eax
  104d68:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
  104d6b:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
  104d6f:	0f 95 c0             	setne  %al
  104d72:	0f b6 c0             	movzbl %al,%eax
  104d75:	85 c0                	test   %eax,%eax
  104d77:	74 0b                	je     104d84 <default_check+0x344>
  104d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104d7c:	8b 40 08             	mov    0x8(%eax),%eax
  104d7f:	83 f8 01             	cmp    $0x1,%eax
  104d82:	74 19                	je     104d9d <default_check+0x35d>
  104d84:	68 bc 6a 10 00       	push   $0x106abc
  104d89:	68 1e 68 10 00       	push   $0x10681e
  104d8e:	68 18 01 00 00       	push   $0x118
  104d93:	68 33 68 10 00       	push   $0x106833
  104d98:	e8 3c b6 ff ff       	call   1003d9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  104d9d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104da0:	83 c0 04             	add    $0x4,%eax
  104da3:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  104daa:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104dad:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104db0:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104db3:	0f a3 10             	bt     %edx,(%eax)
  104db6:	19 c0                	sbb    %eax,%eax
  104db8:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
  104dbb:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
  104dbf:	0f 95 c0             	setne  %al
  104dc2:	0f b6 c0             	movzbl %al,%eax
  104dc5:	85 c0                	test   %eax,%eax
  104dc7:	74 0b                	je     104dd4 <default_check+0x394>
  104dc9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104dcc:	8b 40 08             	mov    0x8(%eax),%eax
  104dcf:	83 f8 03             	cmp    $0x3,%eax
  104dd2:	74 19                	je     104ded <default_check+0x3ad>
  104dd4:	68 e4 6a 10 00       	push   $0x106ae4
  104dd9:	68 1e 68 10 00       	push   $0x10681e
  104dde:	68 19 01 00 00       	push   $0x119
  104de3:	68 33 68 10 00       	push   $0x106833
  104de8:	e8 ec b5 ff ff       	call   1003d9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  104ded:	83 ec 0c             	sub    $0xc,%esp
  104df0:	6a 01                	push   $0x1
  104df2:	e8 d9 dd ff ff       	call   102bd0 <alloc_pages>
  104df7:	83 c4 10             	add    $0x10,%esp
  104dfa:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104dfd:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104e00:	83 e8 14             	sub    $0x14,%eax
  104e03:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104e06:	74 19                	je     104e21 <default_check+0x3e1>
  104e08:	68 0a 6b 10 00       	push   $0x106b0a
  104e0d:	68 1e 68 10 00       	push   $0x10681e
  104e12:	68 1b 01 00 00       	push   $0x11b
  104e17:	68 33 68 10 00       	push   $0x106833
  104e1c:	e8 b8 b5 ff ff       	call   1003d9 <__panic>
    free_page(p0);
  104e21:	83 ec 08             	sub    $0x8,%esp
  104e24:	6a 01                	push   $0x1
  104e26:	ff 75 dc             	pushl  -0x24(%ebp)
  104e29:	e8 e0 dd ff ff       	call   102c0e <free_pages>
  104e2e:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
  104e31:	83 ec 0c             	sub    $0xc,%esp
  104e34:	6a 02                	push   $0x2
  104e36:	e8 95 dd ff ff       	call   102bd0 <alloc_pages>
  104e3b:	83 c4 10             	add    $0x10,%esp
  104e3e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104e41:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104e44:	83 c0 14             	add    $0x14,%eax
  104e47:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104e4a:	74 19                	je     104e65 <default_check+0x425>
  104e4c:	68 28 6b 10 00       	push   $0x106b28
  104e51:	68 1e 68 10 00       	push   $0x10681e
  104e56:	68 1d 01 00 00       	push   $0x11d
  104e5b:	68 33 68 10 00       	push   $0x106833
  104e60:	e8 74 b5 ff ff       	call   1003d9 <__panic>

    free_pages(p0, 2);
  104e65:	83 ec 08             	sub    $0x8,%esp
  104e68:	6a 02                	push   $0x2
  104e6a:	ff 75 dc             	pushl  -0x24(%ebp)
  104e6d:	e8 9c dd ff ff       	call   102c0e <free_pages>
  104e72:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
  104e75:	83 ec 08             	sub    $0x8,%esp
  104e78:	6a 01                	push   $0x1
  104e7a:	ff 75 c0             	pushl  -0x40(%ebp)
  104e7d:	e8 8c dd ff ff       	call   102c0e <free_pages>
  104e82:	83 c4 10             	add    $0x10,%esp

    assert((p0 = alloc_pages(5)) != NULL);
  104e85:	83 ec 0c             	sub    $0xc,%esp
  104e88:	6a 05                	push   $0x5
  104e8a:	e8 41 dd ff ff       	call   102bd0 <alloc_pages>
  104e8f:	83 c4 10             	add    $0x10,%esp
  104e92:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104e95:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104e99:	75 19                	jne    104eb4 <default_check+0x474>
  104e9b:	68 48 6b 10 00       	push   $0x106b48
  104ea0:	68 1e 68 10 00       	push   $0x10681e
  104ea5:	68 22 01 00 00       	push   $0x122
  104eaa:	68 33 68 10 00       	push   $0x106833
  104eaf:	e8 25 b5 ff ff       	call   1003d9 <__panic>
    assert(alloc_page() == NULL);
  104eb4:	83 ec 0c             	sub    $0xc,%esp
  104eb7:	6a 01                	push   $0x1
  104eb9:	e8 12 dd ff ff       	call   102bd0 <alloc_pages>
  104ebe:	83 c4 10             	add    $0x10,%esp
  104ec1:	85 c0                	test   %eax,%eax
  104ec3:	74 19                	je     104ede <default_check+0x49e>
  104ec5:	68 a6 69 10 00       	push   $0x1069a6
  104eca:	68 1e 68 10 00       	push   $0x10681e
  104ecf:	68 23 01 00 00       	push   $0x123
  104ed4:	68 33 68 10 00       	push   $0x106833
  104ed9:	e8 fb b4 ff ff       	call   1003d9 <__panic>

    assert(nr_free == 0);
  104ede:	a1 24 af 11 00       	mov    0x11af24,%eax
  104ee3:	85 c0                	test   %eax,%eax
  104ee5:	74 19                	je     104f00 <default_check+0x4c0>
  104ee7:	68 f9 69 10 00       	push   $0x1069f9
  104eec:	68 1e 68 10 00       	push   $0x10681e
  104ef1:	68 25 01 00 00       	push   $0x125
  104ef6:	68 33 68 10 00       	push   $0x106833
  104efb:	e8 d9 b4 ff ff       	call   1003d9 <__panic>
    nr_free = nr_free_store;
  104f00:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104f03:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_list = free_list_store;
  104f08:	8b 45 80             	mov    -0x80(%ebp),%eax
  104f0b:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104f0e:	a3 1c af 11 00       	mov    %eax,0x11af1c
  104f13:	89 15 20 af 11 00    	mov    %edx,0x11af20
    free_pages(p0, 5);
  104f19:	83 ec 08             	sub    $0x8,%esp
  104f1c:	6a 05                	push   $0x5
  104f1e:	ff 75 dc             	pushl  -0x24(%ebp)
  104f21:	e8 e8 dc ff ff       	call   102c0e <free_pages>
  104f26:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
  104f29:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104f30:	eb 1d                	jmp    104f4f <default_check+0x50f>
        struct Page *p = le2page(le, page_link);
  104f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104f35:	83 e8 0c             	sub    $0xc,%eax
  104f38:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
  104f3b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  104f3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  104f42:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f45:	8b 40 08             	mov    0x8(%eax),%eax
  104f48:	29 c2                	sub    %eax,%edx
  104f4a:	89 d0                	mov    %edx,%eax
  104f4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104f52:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  104f55:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104f58:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  104f5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104f5e:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  104f65:	75 cb                	jne    104f32 <default_check+0x4f2>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  104f67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104f6b:	74 19                	je     104f86 <default_check+0x546>
  104f6d:	68 66 6b 10 00       	push   $0x106b66
  104f72:	68 1e 68 10 00       	push   $0x10681e
  104f77:	68 30 01 00 00       	push   $0x130
  104f7c:	68 33 68 10 00       	push   $0x106833
  104f81:	e8 53 b4 ff ff       	call   1003d9 <__panic>
    assert(total == 0);
  104f86:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104f8a:	74 19                	je     104fa5 <default_check+0x565>
  104f8c:	68 71 6b 10 00       	push   $0x106b71
  104f91:	68 1e 68 10 00       	push   $0x10681e
  104f96:	68 31 01 00 00       	push   $0x131
  104f9b:	68 33 68 10 00       	push   $0x106833
  104fa0:	e8 34 b4 ff ff       	call   1003d9 <__panic>
}
  104fa5:	90                   	nop
  104fa6:	c9                   	leave  
  104fa7:	c3                   	ret    

00104fa8 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  104fa8:	55                   	push   %ebp
  104fa9:	89 e5                	mov    %esp,%ebp
  104fab:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  104fae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  104fb5:	eb 04                	jmp    104fbb <strlen+0x13>
        cnt ++;
  104fb7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  104fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  104fbe:	8d 50 01             	lea    0x1(%eax),%edx
  104fc1:	89 55 08             	mov    %edx,0x8(%ebp)
  104fc4:	0f b6 00             	movzbl (%eax),%eax
  104fc7:	84 c0                	test   %al,%al
  104fc9:	75 ec                	jne    104fb7 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  104fcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  104fce:	c9                   	leave  
  104fcf:	c3                   	ret    

00104fd0 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  104fd0:	55                   	push   %ebp
  104fd1:	89 e5                	mov    %esp,%ebp
  104fd3:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  104fd6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  104fdd:	eb 04                	jmp    104fe3 <strnlen+0x13>
        cnt ++;
  104fdf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  104fe3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104fe6:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104fe9:	73 10                	jae    104ffb <strnlen+0x2b>
  104feb:	8b 45 08             	mov    0x8(%ebp),%eax
  104fee:	8d 50 01             	lea    0x1(%eax),%edx
  104ff1:	89 55 08             	mov    %edx,0x8(%ebp)
  104ff4:	0f b6 00             	movzbl (%eax),%eax
  104ff7:	84 c0                	test   %al,%al
  104ff9:	75 e4                	jne    104fdf <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  104ffb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  104ffe:	c9                   	leave  
  104fff:	c3                   	ret    

00105000 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105000:	55                   	push   %ebp
  105001:	89 e5                	mov    %esp,%ebp
  105003:	57                   	push   %edi
  105004:	56                   	push   %esi
  105005:	83 ec 20             	sub    $0x20,%esp
  105008:	8b 45 08             	mov    0x8(%ebp),%eax
  10500b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10500e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105011:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105014:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10501a:	89 d1                	mov    %edx,%ecx
  10501c:	89 c2                	mov    %eax,%edx
  10501e:	89 ce                	mov    %ecx,%esi
  105020:	89 d7                	mov    %edx,%edi
  105022:	ac                   	lods   %ds:(%esi),%al
  105023:	aa                   	stos   %al,%es:(%edi)
  105024:	84 c0                	test   %al,%al
  105026:	75 fa                	jne    105022 <strcpy+0x22>
  105028:	89 fa                	mov    %edi,%edx
  10502a:	89 f1                	mov    %esi,%ecx
  10502c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10502f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105032:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105035:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  105038:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105039:	83 c4 20             	add    $0x20,%esp
  10503c:	5e                   	pop    %esi
  10503d:	5f                   	pop    %edi
  10503e:	5d                   	pop    %ebp
  10503f:	c3                   	ret    

00105040 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105040:	55                   	push   %ebp
  105041:	89 e5                	mov    %esp,%ebp
  105043:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105046:	8b 45 08             	mov    0x8(%ebp),%eax
  105049:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  10504c:	eb 21                	jmp    10506f <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  10504e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105051:	0f b6 10             	movzbl (%eax),%edx
  105054:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105057:	88 10                	mov    %dl,(%eax)
  105059:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10505c:	0f b6 00             	movzbl (%eax),%eax
  10505f:	84 c0                	test   %al,%al
  105061:	74 04                	je     105067 <strncpy+0x27>
            src ++;
  105063:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105067:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10506b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  10506f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105073:	75 d9                	jne    10504e <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105075:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105078:	c9                   	leave  
  105079:	c3                   	ret    

0010507a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  10507a:	55                   	push   %ebp
  10507b:	89 e5                	mov    %esp,%ebp
  10507d:	57                   	push   %edi
  10507e:	56                   	push   %esi
  10507f:	83 ec 20             	sub    $0x20,%esp
  105082:	8b 45 08             	mov    0x8(%ebp),%eax
  105085:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105088:	8b 45 0c             	mov    0xc(%ebp),%eax
  10508b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  10508e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105091:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105094:	89 d1                	mov    %edx,%ecx
  105096:	89 c2                	mov    %eax,%edx
  105098:	89 ce                	mov    %ecx,%esi
  10509a:	89 d7                	mov    %edx,%edi
  10509c:	ac                   	lods   %ds:(%esi),%al
  10509d:	ae                   	scas   %es:(%edi),%al
  10509e:	75 08                	jne    1050a8 <strcmp+0x2e>
  1050a0:	84 c0                	test   %al,%al
  1050a2:	75 f8                	jne    10509c <strcmp+0x22>
  1050a4:	31 c0                	xor    %eax,%eax
  1050a6:	eb 04                	jmp    1050ac <strcmp+0x32>
  1050a8:	19 c0                	sbb    %eax,%eax
  1050aa:	0c 01                	or     $0x1,%al
  1050ac:	89 fa                	mov    %edi,%edx
  1050ae:	89 f1                	mov    %esi,%ecx
  1050b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1050b3:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1050b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  1050b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  1050bc:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1050bd:	83 c4 20             	add    $0x20,%esp
  1050c0:	5e                   	pop    %esi
  1050c1:	5f                   	pop    %edi
  1050c2:	5d                   	pop    %ebp
  1050c3:	c3                   	ret    

001050c4 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1050c4:	55                   	push   %ebp
  1050c5:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1050c7:	eb 0c                	jmp    1050d5 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  1050c9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1050cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1050d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1050d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1050d9:	74 1a                	je     1050f5 <strncmp+0x31>
  1050db:	8b 45 08             	mov    0x8(%ebp),%eax
  1050de:	0f b6 00             	movzbl (%eax),%eax
  1050e1:	84 c0                	test   %al,%al
  1050e3:	74 10                	je     1050f5 <strncmp+0x31>
  1050e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1050e8:	0f b6 10             	movzbl (%eax),%edx
  1050eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1050ee:	0f b6 00             	movzbl (%eax),%eax
  1050f1:	38 c2                	cmp    %al,%dl
  1050f3:	74 d4                	je     1050c9 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1050f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1050f9:	74 18                	je     105113 <strncmp+0x4f>
  1050fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1050fe:	0f b6 00             	movzbl (%eax),%eax
  105101:	0f b6 d0             	movzbl %al,%edx
  105104:	8b 45 0c             	mov    0xc(%ebp),%eax
  105107:	0f b6 00             	movzbl (%eax),%eax
  10510a:	0f b6 c0             	movzbl %al,%eax
  10510d:	29 c2                	sub    %eax,%edx
  10510f:	89 d0                	mov    %edx,%eax
  105111:	eb 05                	jmp    105118 <strncmp+0x54>
  105113:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105118:	5d                   	pop    %ebp
  105119:	c3                   	ret    

0010511a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  10511a:	55                   	push   %ebp
  10511b:	89 e5                	mov    %esp,%ebp
  10511d:	83 ec 04             	sub    $0x4,%esp
  105120:	8b 45 0c             	mov    0xc(%ebp),%eax
  105123:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105126:	eb 14                	jmp    10513c <strchr+0x22>
        if (*s == c) {
  105128:	8b 45 08             	mov    0x8(%ebp),%eax
  10512b:	0f b6 00             	movzbl (%eax),%eax
  10512e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105131:	75 05                	jne    105138 <strchr+0x1e>
            return (char *)s;
  105133:	8b 45 08             	mov    0x8(%ebp),%eax
  105136:	eb 13                	jmp    10514b <strchr+0x31>
        }
        s ++;
  105138:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  10513c:	8b 45 08             	mov    0x8(%ebp),%eax
  10513f:	0f b6 00             	movzbl (%eax),%eax
  105142:	84 c0                	test   %al,%al
  105144:	75 e2                	jne    105128 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105146:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10514b:	c9                   	leave  
  10514c:	c3                   	ret    

0010514d <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  10514d:	55                   	push   %ebp
  10514e:	89 e5                	mov    %esp,%ebp
  105150:	83 ec 04             	sub    $0x4,%esp
  105153:	8b 45 0c             	mov    0xc(%ebp),%eax
  105156:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105159:	eb 0f                	jmp    10516a <strfind+0x1d>
        if (*s == c) {
  10515b:	8b 45 08             	mov    0x8(%ebp),%eax
  10515e:	0f b6 00             	movzbl (%eax),%eax
  105161:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105164:	74 10                	je     105176 <strfind+0x29>
            break;
        }
        s ++;
  105166:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  10516a:	8b 45 08             	mov    0x8(%ebp),%eax
  10516d:	0f b6 00             	movzbl (%eax),%eax
  105170:	84 c0                	test   %al,%al
  105172:	75 e7                	jne    10515b <strfind+0xe>
  105174:	eb 01                	jmp    105177 <strfind+0x2a>
        if (*s == c) {
            break;
  105176:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  105177:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10517a:	c9                   	leave  
  10517b:	c3                   	ret    

0010517c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  10517c:	55                   	push   %ebp
  10517d:	89 e5                	mov    %esp,%ebp
  10517f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105182:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105189:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105190:	eb 04                	jmp    105196 <strtol+0x1a>
        s ++;
  105192:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105196:	8b 45 08             	mov    0x8(%ebp),%eax
  105199:	0f b6 00             	movzbl (%eax),%eax
  10519c:	3c 20                	cmp    $0x20,%al
  10519e:	74 f2                	je     105192 <strtol+0x16>
  1051a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1051a3:	0f b6 00             	movzbl (%eax),%eax
  1051a6:	3c 09                	cmp    $0x9,%al
  1051a8:	74 e8                	je     105192 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  1051aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1051ad:	0f b6 00             	movzbl (%eax),%eax
  1051b0:	3c 2b                	cmp    $0x2b,%al
  1051b2:	75 06                	jne    1051ba <strtol+0x3e>
        s ++;
  1051b4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1051b8:	eb 15                	jmp    1051cf <strtol+0x53>
    }
    else if (*s == '-') {
  1051ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1051bd:	0f b6 00             	movzbl (%eax),%eax
  1051c0:	3c 2d                	cmp    $0x2d,%al
  1051c2:	75 0b                	jne    1051cf <strtol+0x53>
        s ++, neg = 1;
  1051c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1051c8:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1051cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1051d3:	74 06                	je     1051db <strtol+0x5f>
  1051d5:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1051d9:	75 24                	jne    1051ff <strtol+0x83>
  1051db:	8b 45 08             	mov    0x8(%ebp),%eax
  1051de:	0f b6 00             	movzbl (%eax),%eax
  1051e1:	3c 30                	cmp    $0x30,%al
  1051e3:	75 1a                	jne    1051ff <strtol+0x83>
  1051e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1051e8:	83 c0 01             	add    $0x1,%eax
  1051eb:	0f b6 00             	movzbl (%eax),%eax
  1051ee:	3c 78                	cmp    $0x78,%al
  1051f0:	75 0d                	jne    1051ff <strtol+0x83>
        s += 2, base = 16;
  1051f2:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1051f6:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1051fd:	eb 2a                	jmp    105229 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  1051ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105203:	75 17                	jne    10521c <strtol+0xa0>
  105205:	8b 45 08             	mov    0x8(%ebp),%eax
  105208:	0f b6 00             	movzbl (%eax),%eax
  10520b:	3c 30                	cmp    $0x30,%al
  10520d:	75 0d                	jne    10521c <strtol+0xa0>
        s ++, base = 8;
  10520f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105213:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  10521a:	eb 0d                	jmp    105229 <strtol+0xad>
    }
    else if (base == 0) {
  10521c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105220:	75 07                	jne    105229 <strtol+0xad>
        base = 10;
  105222:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105229:	8b 45 08             	mov    0x8(%ebp),%eax
  10522c:	0f b6 00             	movzbl (%eax),%eax
  10522f:	3c 2f                	cmp    $0x2f,%al
  105231:	7e 1b                	jle    10524e <strtol+0xd2>
  105233:	8b 45 08             	mov    0x8(%ebp),%eax
  105236:	0f b6 00             	movzbl (%eax),%eax
  105239:	3c 39                	cmp    $0x39,%al
  10523b:	7f 11                	jg     10524e <strtol+0xd2>
            dig = *s - '0';
  10523d:	8b 45 08             	mov    0x8(%ebp),%eax
  105240:	0f b6 00             	movzbl (%eax),%eax
  105243:	0f be c0             	movsbl %al,%eax
  105246:	83 e8 30             	sub    $0x30,%eax
  105249:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10524c:	eb 48                	jmp    105296 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  10524e:	8b 45 08             	mov    0x8(%ebp),%eax
  105251:	0f b6 00             	movzbl (%eax),%eax
  105254:	3c 60                	cmp    $0x60,%al
  105256:	7e 1b                	jle    105273 <strtol+0xf7>
  105258:	8b 45 08             	mov    0x8(%ebp),%eax
  10525b:	0f b6 00             	movzbl (%eax),%eax
  10525e:	3c 7a                	cmp    $0x7a,%al
  105260:	7f 11                	jg     105273 <strtol+0xf7>
            dig = *s - 'a' + 10;
  105262:	8b 45 08             	mov    0x8(%ebp),%eax
  105265:	0f b6 00             	movzbl (%eax),%eax
  105268:	0f be c0             	movsbl %al,%eax
  10526b:	83 e8 57             	sub    $0x57,%eax
  10526e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105271:	eb 23                	jmp    105296 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105273:	8b 45 08             	mov    0x8(%ebp),%eax
  105276:	0f b6 00             	movzbl (%eax),%eax
  105279:	3c 40                	cmp    $0x40,%al
  10527b:	7e 3c                	jle    1052b9 <strtol+0x13d>
  10527d:	8b 45 08             	mov    0x8(%ebp),%eax
  105280:	0f b6 00             	movzbl (%eax),%eax
  105283:	3c 5a                	cmp    $0x5a,%al
  105285:	7f 32                	jg     1052b9 <strtol+0x13d>
            dig = *s - 'A' + 10;
  105287:	8b 45 08             	mov    0x8(%ebp),%eax
  10528a:	0f b6 00             	movzbl (%eax),%eax
  10528d:	0f be c0             	movsbl %al,%eax
  105290:	83 e8 37             	sub    $0x37,%eax
  105293:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105296:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105299:	3b 45 10             	cmp    0x10(%ebp),%eax
  10529c:	7d 1a                	jge    1052b8 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
  10529e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1052a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1052a5:	0f af 45 10          	imul   0x10(%ebp),%eax
  1052a9:	89 c2                	mov    %eax,%edx
  1052ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1052ae:	01 d0                	add    %edx,%eax
  1052b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  1052b3:	e9 71 ff ff ff       	jmp    105229 <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  1052b8:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  1052b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1052bd:	74 08                	je     1052c7 <strtol+0x14b>
        *endptr = (char *) s;
  1052bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1052c2:	8b 55 08             	mov    0x8(%ebp),%edx
  1052c5:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1052c7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1052cb:	74 07                	je     1052d4 <strtol+0x158>
  1052cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1052d0:	f7 d8                	neg    %eax
  1052d2:	eb 03                	jmp    1052d7 <strtol+0x15b>
  1052d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1052d7:	c9                   	leave  
  1052d8:	c3                   	ret    

001052d9 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1052d9:	55                   	push   %ebp
  1052da:	89 e5                	mov    %esp,%ebp
  1052dc:	57                   	push   %edi
  1052dd:	83 ec 24             	sub    $0x24,%esp
  1052e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1052e3:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1052e6:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  1052ea:	8b 55 08             	mov    0x8(%ebp),%edx
  1052ed:	89 55 f8             	mov    %edx,-0x8(%ebp)
  1052f0:	88 45 f7             	mov    %al,-0x9(%ebp)
  1052f3:	8b 45 10             	mov    0x10(%ebp),%eax
  1052f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1052f9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1052fc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105300:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105303:	89 d7                	mov    %edx,%edi
  105305:	f3 aa                	rep stos %al,%es:(%edi)
  105307:	89 fa                	mov    %edi,%edx
  105309:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10530c:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  10530f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105312:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105313:	83 c4 24             	add    $0x24,%esp
  105316:	5f                   	pop    %edi
  105317:	5d                   	pop    %ebp
  105318:	c3                   	ret    

00105319 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105319:	55                   	push   %ebp
  10531a:	89 e5                	mov    %esp,%ebp
  10531c:	57                   	push   %edi
  10531d:	56                   	push   %esi
  10531e:	53                   	push   %ebx
  10531f:	83 ec 30             	sub    $0x30,%esp
  105322:	8b 45 08             	mov    0x8(%ebp),%eax
  105325:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105328:	8b 45 0c             	mov    0xc(%ebp),%eax
  10532b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10532e:	8b 45 10             	mov    0x10(%ebp),%eax
  105331:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105334:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105337:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10533a:	73 42                	jae    10537e <memmove+0x65>
  10533c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10533f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105342:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105345:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105348:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10534b:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10534e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105351:	c1 e8 02             	shr    $0x2,%eax
  105354:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105356:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105359:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10535c:	89 d7                	mov    %edx,%edi
  10535e:	89 c6                	mov    %eax,%esi
  105360:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105362:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105365:	83 e1 03             	and    $0x3,%ecx
  105368:	74 02                	je     10536c <memmove+0x53>
  10536a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10536c:	89 f0                	mov    %esi,%eax
  10536e:	89 fa                	mov    %edi,%edx
  105370:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105373:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105376:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105379:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  10537c:	eb 36                	jmp    1053b4 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  10537e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105381:	8d 50 ff             	lea    -0x1(%eax),%edx
  105384:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105387:	01 c2                	add    %eax,%edx
  105389:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10538c:	8d 48 ff             	lea    -0x1(%eax),%ecx
  10538f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105392:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  105395:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105398:	89 c1                	mov    %eax,%ecx
  10539a:	89 d8                	mov    %ebx,%eax
  10539c:	89 d6                	mov    %edx,%esi
  10539e:	89 c7                	mov    %eax,%edi
  1053a0:	fd                   	std    
  1053a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1053a3:	fc                   	cld    
  1053a4:	89 f8                	mov    %edi,%eax
  1053a6:	89 f2                	mov    %esi,%edx
  1053a8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1053ab:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1053ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  1053b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1053b4:	83 c4 30             	add    $0x30,%esp
  1053b7:	5b                   	pop    %ebx
  1053b8:	5e                   	pop    %esi
  1053b9:	5f                   	pop    %edi
  1053ba:	5d                   	pop    %ebp
  1053bb:	c3                   	ret    

001053bc <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1053bc:	55                   	push   %ebp
  1053bd:	89 e5                	mov    %esp,%ebp
  1053bf:	57                   	push   %edi
  1053c0:	56                   	push   %esi
  1053c1:	83 ec 20             	sub    $0x20,%esp
  1053c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1053c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1053ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1053d0:	8b 45 10             	mov    0x10(%ebp),%eax
  1053d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1053d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1053d9:	c1 e8 02             	shr    $0x2,%eax
  1053dc:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  1053de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1053e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1053e4:	89 d7                	mov    %edx,%edi
  1053e6:	89 c6                	mov    %eax,%esi
  1053e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1053ea:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1053ed:	83 e1 03             	and    $0x3,%ecx
  1053f0:	74 02                	je     1053f4 <memcpy+0x38>
  1053f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1053f4:	89 f0                	mov    %esi,%eax
  1053f6:	89 fa                	mov    %edi,%edx
  1053f8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1053fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1053fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105401:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  105404:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105405:	83 c4 20             	add    $0x20,%esp
  105408:	5e                   	pop    %esi
  105409:	5f                   	pop    %edi
  10540a:	5d                   	pop    %ebp
  10540b:	c3                   	ret    

0010540c <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10540c:	55                   	push   %ebp
  10540d:	89 e5                	mov    %esp,%ebp
  10540f:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105412:	8b 45 08             	mov    0x8(%ebp),%eax
  105415:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105418:	8b 45 0c             	mov    0xc(%ebp),%eax
  10541b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  10541e:	eb 30                	jmp    105450 <memcmp+0x44>
        if (*s1 != *s2) {
  105420:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105423:	0f b6 10             	movzbl (%eax),%edx
  105426:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105429:	0f b6 00             	movzbl (%eax),%eax
  10542c:	38 c2                	cmp    %al,%dl
  10542e:	74 18                	je     105448 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105430:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105433:	0f b6 00             	movzbl (%eax),%eax
  105436:	0f b6 d0             	movzbl %al,%edx
  105439:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10543c:	0f b6 00             	movzbl (%eax),%eax
  10543f:	0f b6 c0             	movzbl %al,%eax
  105442:	29 c2                	sub    %eax,%edx
  105444:	89 d0                	mov    %edx,%eax
  105446:	eb 1a                	jmp    105462 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105448:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10544c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  105450:	8b 45 10             	mov    0x10(%ebp),%eax
  105453:	8d 50 ff             	lea    -0x1(%eax),%edx
  105456:	89 55 10             	mov    %edx,0x10(%ebp)
  105459:	85 c0                	test   %eax,%eax
  10545b:	75 c3                	jne    105420 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  10545d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105462:	c9                   	leave  
  105463:	c3                   	ret    

00105464 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105464:	55                   	push   %ebp
  105465:	89 e5                	mov    %esp,%ebp
  105467:	83 ec 38             	sub    $0x38,%esp
  10546a:	8b 45 10             	mov    0x10(%ebp),%eax
  10546d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105470:	8b 45 14             	mov    0x14(%ebp),%eax
  105473:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105476:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105479:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10547c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10547f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105482:	8b 45 18             	mov    0x18(%ebp),%eax
  105485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105488:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10548b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10548e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105491:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105494:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105497:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10549a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10549e:	74 1c                	je     1054bc <printnum+0x58>
  1054a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054a3:	ba 00 00 00 00       	mov    $0x0,%edx
  1054a8:	f7 75 e4             	divl   -0x1c(%ebp)
  1054ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1054ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054b1:	ba 00 00 00 00       	mov    $0x0,%edx
  1054b6:	f7 75 e4             	divl   -0x1c(%ebp)
  1054b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1054bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1054bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1054c2:	f7 75 e4             	divl   -0x1c(%ebp)
  1054c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1054c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1054cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1054ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1054d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1054d4:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1054d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1054da:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1054dd:	8b 45 18             	mov    0x18(%ebp),%eax
  1054e0:	ba 00 00 00 00       	mov    $0x0,%edx
  1054e5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1054e8:	77 41                	ja     10552b <printnum+0xc7>
  1054ea:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1054ed:	72 05                	jb     1054f4 <printnum+0x90>
  1054ef:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1054f2:	77 37                	ja     10552b <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
  1054f4:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1054f7:	83 e8 01             	sub    $0x1,%eax
  1054fa:	83 ec 04             	sub    $0x4,%esp
  1054fd:	ff 75 20             	pushl  0x20(%ebp)
  105500:	50                   	push   %eax
  105501:	ff 75 18             	pushl  0x18(%ebp)
  105504:	ff 75 ec             	pushl  -0x14(%ebp)
  105507:	ff 75 e8             	pushl  -0x18(%ebp)
  10550a:	ff 75 0c             	pushl  0xc(%ebp)
  10550d:	ff 75 08             	pushl  0x8(%ebp)
  105510:	e8 4f ff ff ff       	call   105464 <printnum>
  105515:	83 c4 20             	add    $0x20,%esp
  105518:	eb 1b                	jmp    105535 <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10551a:	83 ec 08             	sub    $0x8,%esp
  10551d:	ff 75 0c             	pushl  0xc(%ebp)
  105520:	ff 75 20             	pushl  0x20(%ebp)
  105523:	8b 45 08             	mov    0x8(%ebp),%eax
  105526:	ff d0                	call   *%eax
  105528:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  10552b:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  10552f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105533:	7f e5                	jg     10551a <printnum+0xb6>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105535:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105538:	05 2c 6c 10 00       	add    $0x106c2c,%eax
  10553d:	0f b6 00             	movzbl (%eax),%eax
  105540:	0f be c0             	movsbl %al,%eax
  105543:	83 ec 08             	sub    $0x8,%esp
  105546:	ff 75 0c             	pushl  0xc(%ebp)
  105549:	50                   	push   %eax
  10554a:	8b 45 08             	mov    0x8(%ebp),%eax
  10554d:	ff d0                	call   *%eax
  10554f:	83 c4 10             	add    $0x10,%esp
}
  105552:	90                   	nop
  105553:	c9                   	leave  
  105554:	c3                   	ret    

00105555 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105555:	55                   	push   %ebp
  105556:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105558:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10555c:	7e 14                	jle    105572 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  10555e:	8b 45 08             	mov    0x8(%ebp),%eax
  105561:	8b 00                	mov    (%eax),%eax
  105563:	8d 48 08             	lea    0x8(%eax),%ecx
  105566:	8b 55 08             	mov    0x8(%ebp),%edx
  105569:	89 0a                	mov    %ecx,(%edx)
  10556b:	8b 50 04             	mov    0x4(%eax),%edx
  10556e:	8b 00                	mov    (%eax),%eax
  105570:	eb 30                	jmp    1055a2 <getuint+0x4d>
    }
    else if (lflag) {
  105572:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105576:	74 16                	je     10558e <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105578:	8b 45 08             	mov    0x8(%ebp),%eax
  10557b:	8b 00                	mov    (%eax),%eax
  10557d:	8d 48 04             	lea    0x4(%eax),%ecx
  105580:	8b 55 08             	mov    0x8(%ebp),%edx
  105583:	89 0a                	mov    %ecx,(%edx)
  105585:	8b 00                	mov    (%eax),%eax
  105587:	ba 00 00 00 00       	mov    $0x0,%edx
  10558c:	eb 14                	jmp    1055a2 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  10558e:	8b 45 08             	mov    0x8(%ebp),%eax
  105591:	8b 00                	mov    (%eax),%eax
  105593:	8d 48 04             	lea    0x4(%eax),%ecx
  105596:	8b 55 08             	mov    0x8(%ebp),%edx
  105599:	89 0a                	mov    %ecx,(%edx)
  10559b:	8b 00                	mov    (%eax),%eax
  10559d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1055a2:	5d                   	pop    %ebp
  1055a3:	c3                   	ret    

001055a4 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1055a4:	55                   	push   %ebp
  1055a5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1055a7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1055ab:	7e 14                	jle    1055c1 <getint+0x1d>
        return va_arg(*ap, long long);
  1055ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1055b0:	8b 00                	mov    (%eax),%eax
  1055b2:	8d 48 08             	lea    0x8(%eax),%ecx
  1055b5:	8b 55 08             	mov    0x8(%ebp),%edx
  1055b8:	89 0a                	mov    %ecx,(%edx)
  1055ba:	8b 50 04             	mov    0x4(%eax),%edx
  1055bd:	8b 00                	mov    (%eax),%eax
  1055bf:	eb 28                	jmp    1055e9 <getint+0x45>
    }
    else if (lflag) {
  1055c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1055c5:	74 12                	je     1055d9 <getint+0x35>
        return va_arg(*ap, long);
  1055c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1055ca:	8b 00                	mov    (%eax),%eax
  1055cc:	8d 48 04             	lea    0x4(%eax),%ecx
  1055cf:	8b 55 08             	mov    0x8(%ebp),%edx
  1055d2:	89 0a                	mov    %ecx,(%edx)
  1055d4:	8b 00                	mov    (%eax),%eax
  1055d6:	99                   	cltd   
  1055d7:	eb 10                	jmp    1055e9 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1055d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1055dc:	8b 00                	mov    (%eax),%eax
  1055de:	8d 48 04             	lea    0x4(%eax),%ecx
  1055e1:	8b 55 08             	mov    0x8(%ebp),%edx
  1055e4:	89 0a                	mov    %ecx,(%edx)
  1055e6:	8b 00                	mov    (%eax),%eax
  1055e8:	99                   	cltd   
    }
}
  1055e9:	5d                   	pop    %ebp
  1055ea:	c3                   	ret    

001055eb <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1055eb:	55                   	push   %ebp
  1055ec:	89 e5                	mov    %esp,%ebp
  1055ee:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  1055f1:	8d 45 14             	lea    0x14(%ebp),%eax
  1055f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1055f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055fa:	50                   	push   %eax
  1055fb:	ff 75 10             	pushl  0x10(%ebp)
  1055fe:	ff 75 0c             	pushl  0xc(%ebp)
  105601:	ff 75 08             	pushl  0x8(%ebp)
  105604:	e8 06 00 00 00       	call   10560f <vprintfmt>
  105609:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  10560c:	90                   	nop
  10560d:	c9                   	leave  
  10560e:	c3                   	ret    

0010560f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10560f:	55                   	push   %ebp
  105610:	89 e5                	mov    %esp,%ebp
  105612:	56                   	push   %esi
  105613:	53                   	push   %ebx
  105614:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105617:	eb 17                	jmp    105630 <vprintfmt+0x21>
            if (ch == '\0') {
  105619:	85 db                	test   %ebx,%ebx
  10561b:	0f 84 8e 03 00 00    	je     1059af <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
  105621:	83 ec 08             	sub    $0x8,%esp
  105624:	ff 75 0c             	pushl  0xc(%ebp)
  105627:	53                   	push   %ebx
  105628:	8b 45 08             	mov    0x8(%ebp),%eax
  10562b:	ff d0                	call   *%eax
  10562d:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105630:	8b 45 10             	mov    0x10(%ebp),%eax
  105633:	8d 50 01             	lea    0x1(%eax),%edx
  105636:	89 55 10             	mov    %edx,0x10(%ebp)
  105639:	0f b6 00             	movzbl (%eax),%eax
  10563c:	0f b6 d8             	movzbl %al,%ebx
  10563f:	83 fb 25             	cmp    $0x25,%ebx
  105642:	75 d5                	jne    105619 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  105644:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105648:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10564f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105652:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105655:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10565c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10565f:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105662:	8b 45 10             	mov    0x10(%ebp),%eax
  105665:	8d 50 01             	lea    0x1(%eax),%edx
  105668:	89 55 10             	mov    %edx,0x10(%ebp)
  10566b:	0f b6 00             	movzbl (%eax),%eax
  10566e:	0f b6 d8             	movzbl %al,%ebx
  105671:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105674:	83 f8 55             	cmp    $0x55,%eax
  105677:	0f 87 05 03 00 00    	ja     105982 <vprintfmt+0x373>
  10567d:	8b 04 85 50 6c 10 00 	mov    0x106c50(,%eax,4),%eax
  105684:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105686:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  10568a:	eb d6                	jmp    105662 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10568c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105690:	eb d0                	jmp    105662 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105692:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105699:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10569c:	89 d0                	mov    %edx,%eax
  10569e:	c1 e0 02             	shl    $0x2,%eax
  1056a1:	01 d0                	add    %edx,%eax
  1056a3:	01 c0                	add    %eax,%eax
  1056a5:	01 d8                	add    %ebx,%eax
  1056a7:	83 e8 30             	sub    $0x30,%eax
  1056aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1056ad:	8b 45 10             	mov    0x10(%ebp),%eax
  1056b0:	0f b6 00             	movzbl (%eax),%eax
  1056b3:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1056b6:	83 fb 2f             	cmp    $0x2f,%ebx
  1056b9:	7e 39                	jle    1056f4 <vprintfmt+0xe5>
  1056bb:	83 fb 39             	cmp    $0x39,%ebx
  1056be:	7f 34                	jg     1056f4 <vprintfmt+0xe5>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1056c0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  1056c4:	eb d3                	jmp    105699 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  1056c6:	8b 45 14             	mov    0x14(%ebp),%eax
  1056c9:	8d 50 04             	lea    0x4(%eax),%edx
  1056cc:	89 55 14             	mov    %edx,0x14(%ebp)
  1056cf:	8b 00                	mov    (%eax),%eax
  1056d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1056d4:	eb 1f                	jmp    1056f5 <vprintfmt+0xe6>

        case '.':
            if (width < 0)
  1056d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056da:	79 86                	jns    105662 <vprintfmt+0x53>
                width = 0;
  1056dc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1056e3:	e9 7a ff ff ff       	jmp    105662 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  1056e8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1056ef:	e9 6e ff ff ff       	jmp    105662 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  1056f4:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  1056f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056f9:	0f 89 63 ff ff ff    	jns    105662 <vprintfmt+0x53>
                width = precision, precision = -1;
  1056ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105702:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105705:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  10570c:	e9 51 ff ff ff       	jmp    105662 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105711:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  105715:	e9 48 ff ff ff       	jmp    105662 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  10571a:	8b 45 14             	mov    0x14(%ebp),%eax
  10571d:	8d 50 04             	lea    0x4(%eax),%edx
  105720:	89 55 14             	mov    %edx,0x14(%ebp)
  105723:	8b 00                	mov    (%eax),%eax
  105725:	83 ec 08             	sub    $0x8,%esp
  105728:	ff 75 0c             	pushl  0xc(%ebp)
  10572b:	50                   	push   %eax
  10572c:	8b 45 08             	mov    0x8(%ebp),%eax
  10572f:	ff d0                	call   *%eax
  105731:	83 c4 10             	add    $0x10,%esp
            break;
  105734:	e9 71 02 00 00       	jmp    1059aa <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105739:	8b 45 14             	mov    0x14(%ebp),%eax
  10573c:	8d 50 04             	lea    0x4(%eax),%edx
  10573f:	89 55 14             	mov    %edx,0x14(%ebp)
  105742:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105744:	85 db                	test   %ebx,%ebx
  105746:	79 02                	jns    10574a <vprintfmt+0x13b>
                err = -err;
  105748:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  10574a:	83 fb 06             	cmp    $0x6,%ebx
  10574d:	7f 0b                	jg     10575a <vprintfmt+0x14b>
  10574f:	8b 34 9d 10 6c 10 00 	mov    0x106c10(,%ebx,4),%esi
  105756:	85 f6                	test   %esi,%esi
  105758:	75 19                	jne    105773 <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
  10575a:	53                   	push   %ebx
  10575b:	68 3d 6c 10 00       	push   $0x106c3d
  105760:	ff 75 0c             	pushl  0xc(%ebp)
  105763:	ff 75 08             	pushl  0x8(%ebp)
  105766:	e8 80 fe ff ff       	call   1055eb <printfmt>
  10576b:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10576e:	e9 37 02 00 00       	jmp    1059aa <vprintfmt+0x39b>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  105773:	56                   	push   %esi
  105774:	68 46 6c 10 00       	push   $0x106c46
  105779:	ff 75 0c             	pushl  0xc(%ebp)
  10577c:	ff 75 08             	pushl  0x8(%ebp)
  10577f:	e8 67 fe ff ff       	call   1055eb <printfmt>
  105784:	83 c4 10             	add    $0x10,%esp
            }
            break;
  105787:	e9 1e 02 00 00       	jmp    1059aa <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10578c:	8b 45 14             	mov    0x14(%ebp),%eax
  10578f:	8d 50 04             	lea    0x4(%eax),%edx
  105792:	89 55 14             	mov    %edx,0x14(%ebp)
  105795:	8b 30                	mov    (%eax),%esi
  105797:	85 f6                	test   %esi,%esi
  105799:	75 05                	jne    1057a0 <vprintfmt+0x191>
                p = "(null)";
  10579b:	be 49 6c 10 00       	mov    $0x106c49,%esi
            }
            if (width > 0 && padc != '-') {
  1057a0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1057a4:	7e 76                	jle    10581c <vprintfmt+0x20d>
  1057a6:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1057aa:	74 70                	je     10581c <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1057ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1057af:	83 ec 08             	sub    $0x8,%esp
  1057b2:	50                   	push   %eax
  1057b3:	56                   	push   %esi
  1057b4:	e8 17 f8 ff ff       	call   104fd0 <strnlen>
  1057b9:	83 c4 10             	add    $0x10,%esp
  1057bc:	89 c2                	mov    %eax,%edx
  1057be:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057c1:	29 d0                	sub    %edx,%eax
  1057c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1057c6:	eb 17                	jmp    1057df <vprintfmt+0x1d0>
                    putch(padc, putdat);
  1057c8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1057cc:	83 ec 08             	sub    $0x8,%esp
  1057cf:	ff 75 0c             	pushl  0xc(%ebp)
  1057d2:	50                   	push   %eax
  1057d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1057d6:	ff d0                	call   *%eax
  1057d8:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  1057db:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1057df:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1057e3:	7f e3                	jg     1057c8 <vprintfmt+0x1b9>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1057e5:	eb 35                	jmp    10581c <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
  1057e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1057eb:	74 1c                	je     105809 <vprintfmt+0x1fa>
  1057ed:	83 fb 1f             	cmp    $0x1f,%ebx
  1057f0:	7e 05                	jle    1057f7 <vprintfmt+0x1e8>
  1057f2:	83 fb 7e             	cmp    $0x7e,%ebx
  1057f5:	7e 12                	jle    105809 <vprintfmt+0x1fa>
                    putch('?', putdat);
  1057f7:	83 ec 08             	sub    $0x8,%esp
  1057fa:	ff 75 0c             	pushl  0xc(%ebp)
  1057fd:	6a 3f                	push   $0x3f
  1057ff:	8b 45 08             	mov    0x8(%ebp),%eax
  105802:	ff d0                	call   *%eax
  105804:	83 c4 10             	add    $0x10,%esp
  105807:	eb 0f                	jmp    105818 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
  105809:	83 ec 08             	sub    $0x8,%esp
  10580c:	ff 75 0c             	pushl  0xc(%ebp)
  10580f:	53                   	push   %ebx
  105810:	8b 45 08             	mov    0x8(%ebp),%eax
  105813:	ff d0                	call   *%eax
  105815:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105818:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  10581c:	89 f0                	mov    %esi,%eax
  10581e:	8d 70 01             	lea    0x1(%eax),%esi
  105821:	0f b6 00             	movzbl (%eax),%eax
  105824:	0f be d8             	movsbl %al,%ebx
  105827:	85 db                	test   %ebx,%ebx
  105829:	74 26                	je     105851 <vprintfmt+0x242>
  10582b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10582f:	78 b6                	js     1057e7 <vprintfmt+0x1d8>
  105831:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  105835:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105839:	79 ac                	jns    1057e7 <vprintfmt+0x1d8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10583b:	eb 14                	jmp    105851 <vprintfmt+0x242>
                putch(' ', putdat);
  10583d:	83 ec 08             	sub    $0x8,%esp
  105840:	ff 75 0c             	pushl  0xc(%ebp)
  105843:	6a 20                	push   $0x20
  105845:	8b 45 08             	mov    0x8(%ebp),%eax
  105848:	ff d0                	call   *%eax
  10584a:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10584d:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105851:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105855:	7f e6                	jg     10583d <vprintfmt+0x22e>
                putch(' ', putdat);
            }
            break;
  105857:	e9 4e 01 00 00       	jmp    1059aa <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  10585c:	83 ec 08             	sub    $0x8,%esp
  10585f:	ff 75 e0             	pushl  -0x20(%ebp)
  105862:	8d 45 14             	lea    0x14(%ebp),%eax
  105865:	50                   	push   %eax
  105866:	e8 39 fd ff ff       	call   1055a4 <getint>
  10586b:	83 c4 10             	add    $0x10,%esp
  10586e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105871:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105874:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105877:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10587a:	85 d2                	test   %edx,%edx
  10587c:	79 23                	jns    1058a1 <vprintfmt+0x292>
                putch('-', putdat);
  10587e:	83 ec 08             	sub    $0x8,%esp
  105881:	ff 75 0c             	pushl  0xc(%ebp)
  105884:	6a 2d                	push   $0x2d
  105886:	8b 45 08             	mov    0x8(%ebp),%eax
  105889:	ff d0                	call   *%eax
  10588b:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
  10588e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105891:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105894:	f7 d8                	neg    %eax
  105896:	83 d2 00             	adc    $0x0,%edx
  105899:	f7 da                	neg    %edx
  10589b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10589e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1058a1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1058a8:	e9 9f 00 00 00       	jmp    10594c <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1058ad:	83 ec 08             	sub    $0x8,%esp
  1058b0:	ff 75 e0             	pushl  -0x20(%ebp)
  1058b3:	8d 45 14             	lea    0x14(%ebp),%eax
  1058b6:	50                   	push   %eax
  1058b7:	e8 99 fc ff ff       	call   105555 <getuint>
  1058bc:	83 c4 10             	add    $0x10,%esp
  1058bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1058c5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1058cc:	eb 7e                	jmp    10594c <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1058ce:	83 ec 08             	sub    $0x8,%esp
  1058d1:	ff 75 e0             	pushl  -0x20(%ebp)
  1058d4:	8d 45 14             	lea    0x14(%ebp),%eax
  1058d7:	50                   	push   %eax
  1058d8:	e8 78 fc ff ff       	call   105555 <getuint>
  1058dd:	83 c4 10             	add    $0x10,%esp
  1058e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058e3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1058e6:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1058ed:	eb 5d                	jmp    10594c <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
  1058ef:	83 ec 08             	sub    $0x8,%esp
  1058f2:	ff 75 0c             	pushl  0xc(%ebp)
  1058f5:	6a 30                	push   $0x30
  1058f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1058fa:	ff d0                	call   *%eax
  1058fc:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
  1058ff:	83 ec 08             	sub    $0x8,%esp
  105902:	ff 75 0c             	pushl  0xc(%ebp)
  105905:	6a 78                	push   $0x78
  105907:	8b 45 08             	mov    0x8(%ebp),%eax
  10590a:	ff d0                	call   *%eax
  10590c:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  10590f:	8b 45 14             	mov    0x14(%ebp),%eax
  105912:	8d 50 04             	lea    0x4(%eax),%edx
  105915:	89 55 14             	mov    %edx,0x14(%ebp)
  105918:	8b 00                	mov    (%eax),%eax
  10591a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10591d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105924:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  10592b:	eb 1f                	jmp    10594c <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  10592d:	83 ec 08             	sub    $0x8,%esp
  105930:	ff 75 e0             	pushl  -0x20(%ebp)
  105933:	8d 45 14             	lea    0x14(%ebp),%eax
  105936:	50                   	push   %eax
  105937:	e8 19 fc ff ff       	call   105555 <getuint>
  10593c:	83 c4 10             	add    $0x10,%esp
  10593f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105942:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105945:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  10594c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105950:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105953:	83 ec 04             	sub    $0x4,%esp
  105956:	52                   	push   %edx
  105957:	ff 75 e8             	pushl  -0x18(%ebp)
  10595a:	50                   	push   %eax
  10595b:	ff 75 f4             	pushl  -0xc(%ebp)
  10595e:	ff 75 f0             	pushl  -0x10(%ebp)
  105961:	ff 75 0c             	pushl  0xc(%ebp)
  105964:	ff 75 08             	pushl  0x8(%ebp)
  105967:	e8 f8 fa ff ff       	call   105464 <printnum>
  10596c:	83 c4 20             	add    $0x20,%esp
            break;
  10596f:	eb 39                	jmp    1059aa <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105971:	83 ec 08             	sub    $0x8,%esp
  105974:	ff 75 0c             	pushl  0xc(%ebp)
  105977:	53                   	push   %ebx
  105978:	8b 45 08             	mov    0x8(%ebp),%eax
  10597b:	ff d0                	call   *%eax
  10597d:	83 c4 10             	add    $0x10,%esp
            break;
  105980:	eb 28                	jmp    1059aa <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105982:	83 ec 08             	sub    $0x8,%esp
  105985:	ff 75 0c             	pushl  0xc(%ebp)
  105988:	6a 25                	push   $0x25
  10598a:	8b 45 08             	mov    0x8(%ebp),%eax
  10598d:	ff d0                	call   *%eax
  10598f:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
  105992:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105996:	eb 04                	jmp    10599c <vprintfmt+0x38d>
  105998:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10599c:	8b 45 10             	mov    0x10(%ebp),%eax
  10599f:	83 e8 01             	sub    $0x1,%eax
  1059a2:	0f b6 00             	movzbl (%eax),%eax
  1059a5:	3c 25                	cmp    $0x25,%al
  1059a7:	75 ef                	jne    105998 <vprintfmt+0x389>
                /* do nothing */;
            break;
  1059a9:	90                   	nop
        }
    }
  1059aa:	e9 68 fc ff ff       	jmp    105617 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  1059af:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  1059b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  1059b3:	5b                   	pop    %ebx
  1059b4:	5e                   	pop    %esi
  1059b5:	5d                   	pop    %ebp
  1059b6:	c3                   	ret    

001059b7 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1059b7:	55                   	push   %ebp
  1059b8:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1059ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059bd:	8b 40 08             	mov    0x8(%eax),%eax
  1059c0:	8d 50 01             	lea    0x1(%eax),%edx
  1059c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059c6:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1059c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059cc:	8b 10                	mov    (%eax),%edx
  1059ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059d1:	8b 40 04             	mov    0x4(%eax),%eax
  1059d4:	39 c2                	cmp    %eax,%edx
  1059d6:	73 12                	jae    1059ea <sprintputch+0x33>
        *b->buf ++ = ch;
  1059d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059db:	8b 00                	mov    (%eax),%eax
  1059dd:	8d 48 01             	lea    0x1(%eax),%ecx
  1059e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  1059e3:	89 0a                	mov    %ecx,(%edx)
  1059e5:	8b 55 08             	mov    0x8(%ebp),%edx
  1059e8:	88 10                	mov    %dl,(%eax)
    }
}
  1059ea:	90                   	nop
  1059eb:	5d                   	pop    %ebp
  1059ec:	c3                   	ret    

001059ed <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1059ed:	55                   	push   %ebp
  1059ee:	89 e5                	mov    %esp,%ebp
  1059f0:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1059f3:	8d 45 14             	lea    0x14(%ebp),%eax
  1059f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  1059f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059fc:	50                   	push   %eax
  1059fd:	ff 75 10             	pushl  0x10(%ebp)
  105a00:	ff 75 0c             	pushl  0xc(%ebp)
  105a03:	ff 75 08             	pushl  0x8(%ebp)
  105a06:	e8 0b 00 00 00       	call   105a16 <vsnprintf>
  105a0b:	83 c4 10             	add    $0x10,%esp
  105a0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105a14:	c9                   	leave  
  105a15:	c3                   	ret    

00105a16 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105a16:	55                   	push   %ebp
  105a17:	89 e5                	mov    %esp,%ebp
  105a19:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  105a1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a25:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a28:	8b 45 08             	mov    0x8(%ebp),%eax
  105a2b:	01 d0                	add    %edx,%eax
  105a2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a30:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105a37:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105a3b:	74 0a                	je     105a47 <vsnprintf+0x31>
  105a3d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a43:	39 c2                	cmp    %eax,%edx
  105a45:	76 07                	jbe    105a4e <vsnprintf+0x38>
        return -E_INVAL;
  105a47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105a4c:	eb 20                	jmp    105a6e <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105a4e:	ff 75 14             	pushl  0x14(%ebp)
  105a51:	ff 75 10             	pushl  0x10(%ebp)
  105a54:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105a57:	50                   	push   %eax
  105a58:	68 b7 59 10 00       	push   $0x1059b7
  105a5d:	e8 ad fb ff ff       	call   10560f <vprintfmt>
  105a62:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
  105a65:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a68:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105a6e:	c9                   	leave  
  105a6f:	c3                   	ret    
