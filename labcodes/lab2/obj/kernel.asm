
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	83 ec 04             	sub    $0x4,%esp
c010004d:	50                   	push   %eax
c010004e:	6a 00                	push   $0x0
c0100050:	68 00 a0 11 c0       	push   $0xc011a000
c0100055:	e8 7f 52 00 00       	call   c01052d9 <memset>
c010005a:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
c010005d:	e8 70 15 00 00       	call   c01015d2 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100062:	c7 45 f4 80 5a 10 c0 	movl   $0xc0105a80,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100069:	83 ec 08             	sub    $0x8,%esp
c010006c:	ff 75 f4             	pushl  -0xc(%ebp)
c010006f:	68 9c 5a 10 c0       	push   $0xc0105a9c
c0100074:	e8 fa 01 00 00       	call   c0100273 <cprintf>
c0100079:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c010007c:	e8 91 08 00 00       	call   c0100912 <print_kerninfo>

    grade_backtrace();
c0100081:	e8 74 00 00 00       	call   c01000fa <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100086:	e8 ce 30 00 00       	call   c0103159 <pmm_init>

    pic_init();                 // init interrupt controller
c010008b:	e8 b4 16 00 00       	call   c0101744 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100090:	e8 15 18 00 00       	call   c01018aa <idt_init>

    clock_init();               // init clock interrupt
c0100095:	e8 df 0c 00 00       	call   c0100d79 <clock_init>
    intr_enable();              // enable irq interrupt
c010009a:	e8 e2 17 00 00       	call   c0101881 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c010009f:	eb fe                	jmp    c010009f <kern_init+0x69>

c01000a1 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a1:	55                   	push   %ebp
c01000a2:	89 e5                	mov    %esp,%ebp
c01000a4:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
c01000a7:	83 ec 04             	sub    $0x4,%esp
c01000aa:	6a 00                	push   $0x0
c01000ac:	6a 00                	push   $0x0
c01000ae:	6a 00                	push   $0x0
c01000b0:	e8 b2 0c 00 00       	call   c0100d67 <mon_backtrace>
c01000b5:	83 c4 10             	add    $0x10,%esp
}
c01000b8:	90                   	nop
c01000b9:	c9                   	leave  
c01000ba:	c3                   	ret    

c01000bb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000bb:	55                   	push   %ebp
c01000bc:	89 e5                	mov    %esp,%ebp
c01000be:	53                   	push   %ebx
c01000bf:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000c2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000c5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000c8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ce:	51                   	push   %ecx
c01000cf:	52                   	push   %edx
c01000d0:	53                   	push   %ebx
c01000d1:	50                   	push   %eax
c01000d2:	e8 ca ff ff ff       	call   c01000a1 <grade_backtrace2>
c01000d7:	83 c4 10             	add    $0x10,%esp
}
c01000da:	90                   	nop
c01000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000de:	c9                   	leave  
c01000df:	c3                   	ret    

c01000e0 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000e0:	55                   	push   %ebp
c01000e1:	89 e5                	mov    %esp,%ebp
c01000e3:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
c01000e6:	83 ec 08             	sub    $0x8,%esp
c01000e9:	ff 75 10             	pushl  0x10(%ebp)
c01000ec:	ff 75 08             	pushl  0x8(%ebp)
c01000ef:	e8 c7 ff ff ff       	call   c01000bb <grade_backtrace1>
c01000f4:	83 c4 10             	add    $0x10,%esp
}
c01000f7:	90                   	nop
c01000f8:	c9                   	leave  
c01000f9:	c3                   	ret    

c01000fa <grade_backtrace>:

void
grade_backtrace(void) {
c01000fa:	55                   	push   %ebp
c01000fb:	89 e5                	mov    %esp,%ebp
c01000fd:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100100:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100105:	83 ec 04             	sub    $0x4,%esp
c0100108:	68 00 00 ff ff       	push   $0xffff0000
c010010d:	50                   	push   %eax
c010010e:	6a 00                	push   $0x0
c0100110:	e8 cb ff ff ff       	call   c01000e0 <grade_backtrace0>
c0100115:	83 c4 10             	add    $0x10,%esp
}
c0100118:	90                   	nop
c0100119:	c9                   	leave  
c010011a:	c3                   	ret    

c010011b <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010011b:	55                   	push   %ebp
c010011c:	89 e5                	mov    %esp,%ebp
c010011e:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100121:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100124:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100127:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010012a:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010012d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100131:	0f b7 c0             	movzwl %ax,%eax
c0100134:	83 e0 03             	and    $0x3,%eax
c0100137:	89 c2                	mov    %eax,%edx
c0100139:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010013e:	83 ec 04             	sub    $0x4,%esp
c0100141:	52                   	push   %edx
c0100142:	50                   	push   %eax
c0100143:	68 a1 5a 10 c0       	push   $0xc0105aa1
c0100148:	e8 26 01 00 00       	call   c0100273 <cprintf>
c010014d:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
c0100150:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100154:	0f b7 d0             	movzwl %ax,%edx
c0100157:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010015c:	83 ec 04             	sub    $0x4,%esp
c010015f:	52                   	push   %edx
c0100160:	50                   	push   %eax
c0100161:	68 af 5a 10 c0       	push   $0xc0105aaf
c0100166:	e8 08 01 00 00       	call   c0100273 <cprintf>
c010016b:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
c010016e:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100172:	0f b7 d0             	movzwl %ax,%edx
c0100175:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010017a:	83 ec 04             	sub    $0x4,%esp
c010017d:	52                   	push   %edx
c010017e:	50                   	push   %eax
c010017f:	68 bd 5a 10 c0       	push   $0xc0105abd
c0100184:	e8 ea 00 00 00       	call   c0100273 <cprintf>
c0100189:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
c010018c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100190:	0f b7 d0             	movzwl %ax,%edx
c0100193:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100198:	83 ec 04             	sub    $0x4,%esp
c010019b:	52                   	push   %edx
c010019c:	50                   	push   %eax
c010019d:	68 cb 5a 10 c0       	push   $0xc0105acb
c01001a2:	e8 cc 00 00 00       	call   c0100273 <cprintf>
c01001a7:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
c01001aa:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001ae:	0f b7 d0             	movzwl %ax,%edx
c01001b1:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b6:	83 ec 04             	sub    $0x4,%esp
c01001b9:	52                   	push   %edx
c01001ba:	50                   	push   %eax
c01001bb:	68 d9 5a 10 c0       	push   $0xc0105ad9
c01001c0:	e8 ae 00 00 00       	call   c0100273 <cprintf>
c01001c5:	83 c4 10             	add    $0x10,%esp
    round ++;
c01001c8:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001cd:	83 c0 01             	add    $0x1,%eax
c01001d0:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001d5:	90                   	nop
c01001d6:	c9                   	leave  
c01001d7:	c3                   	ret    

c01001d8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001d8:	55                   	push   %ebp
c01001d9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001db:	90                   	nop
c01001dc:	5d                   	pop    %ebp
c01001dd:	c3                   	ret    

c01001de <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001de:	55                   	push   %ebp
c01001df:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c01001e1:	90                   	nop
c01001e2:	5d                   	pop    %ebp
c01001e3:	c3                   	ret    

c01001e4 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c01001e4:	55                   	push   %ebp
c01001e5:	89 e5                	mov    %esp,%ebp
c01001e7:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
c01001ea:	e8 2c ff ff ff       	call   c010011b <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c01001ef:	83 ec 0c             	sub    $0xc,%esp
c01001f2:	68 e8 5a 10 c0       	push   $0xc0105ae8
c01001f7:	e8 77 00 00 00       	call   c0100273 <cprintf>
c01001fc:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
c01001ff:	e8 d4 ff ff ff       	call   c01001d8 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100204:	e8 12 ff ff ff       	call   c010011b <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100209:	83 ec 0c             	sub    $0xc,%esp
c010020c:	68 08 5b 10 c0       	push   $0xc0105b08
c0100211:	e8 5d 00 00 00       	call   c0100273 <cprintf>
c0100216:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
c0100219:	e8 c0 ff ff ff       	call   c01001de <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010021e:	e8 f8 fe ff ff       	call   c010011b <lab1_print_cur_status>
}
c0100223:	90                   	nop
c0100224:	c9                   	leave  
c0100225:	c3                   	ret    

c0100226 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100226:	55                   	push   %ebp
c0100227:	89 e5                	mov    %esp,%ebp
c0100229:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c010022c:	83 ec 0c             	sub    $0xc,%esp
c010022f:	ff 75 08             	pushl  0x8(%ebp)
c0100232:	e8 cc 13 00 00       	call   c0101603 <cons_putc>
c0100237:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c010023a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010023d:	8b 00                	mov    (%eax),%eax
c010023f:	8d 50 01             	lea    0x1(%eax),%edx
c0100242:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100245:	89 10                	mov    %edx,(%eax)
}
c0100247:	90                   	nop
c0100248:	c9                   	leave  
c0100249:	c3                   	ret    

c010024a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010024a:	55                   	push   %ebp
c010024b:	89 e5                	mov    %esp,%ebp
c010024d:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c0100250:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100257:	ff 75 0c             	pushl  0xc(%ebp)
c010025a:	ff 75 08             	pushl  0x8(%ebp)
c010025d:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100260:	50                   	push   %eax
c0100261:	68 26 02 10 c0       	push   $0xc0100226
c0100266:	e8 a4 53 00 00       	call   c010560f <vprintfmt>
c010026b:	83 c4 10             	add    $0x10,%esp
    return cnt;
c010026e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100271:	c9                   	leave  
c0100272:	c3                   	ret    

c0100273 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100273:	55                   	push   %ebp
c0100274:	89 e5                	mov    %esp,%ebp
c0100276:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100279:	8d 45 0c             	lea    0xc(%ebp),%eax
c010027c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010027f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100282:	83 ec 08             	sub    $0x8,%esp
c0100285:	50                   	push   %eax
c0100286:	ff 75 08             	pushl  0x8(%ebp)
c0100289:	e8 bc ff ff ff       	call   c010024a <vcprintf>
c010028e:	83 c4 10             	add    $0x10,%esp
c0100291:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100297:	c9                   	leave  
c0100298:	c3                   	ret    

c0100299 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100299:	55                   	push   %ebp
c010029a:	89 e5                	mov    %esp,%ebp
c010029c:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c010029f:	83 ec 0c             	sub    $0xc,%esp
c01002a2:	ff 75 08             	pushl  0x8(%ebp)
c01002a5:	e8 59 13 00 00       	call   c0101603 <cons_putc>
c01002aa:	83 c4 10             	add    $0x10,%esp
}
c01002ad:	90                   	nop
c01002ae:	c9                   	leave  
c01002af:	c3                   	ret    

c01002b0 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002b0:	55                   	push   %ebp
c01002b1:	89 e5                	mov    %esp,%ebp
c01002b3:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c01002b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002bd:	eb 14                	jmp    c01002d3 <cputs+0x23>
        cputch(c, &cnt);
c01002bf:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002c3:	83 ec 08             	sub    $0x8,%esp
c01002c6:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002c9:	52                   	push   %edx
c01002ca:	50                   	push   %eax
c01002cb:	e8 56 ff ff ff       	call   c0100226 <cputch>
c01002d0:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01002d6:	8d 50 01             	lea    0x1(%eax),%edx
c01002d9:	89 55 08             	mov    %edx,0x8(%ebp)
c01002dc:	0f b6 00             	movzbl (%eax),%eax
c01002df:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002e2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01002e6:	75 d7                	jne    c01002bf <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01002e8:	83 ec 08             	sub    $0x8,%esp
c01002eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01002ee:	50                   	push   %eax
c01002ef:	6a 0a                	push   $0xa
c01002f1:	e8 30 ff ff ff       	call   c0100226 <cputch>
c01002f6:	83 c4 10             	add    $0x10,%esp
    return cnt;
c01002f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01002fc:	c9                   	leave  
c01002fd:	c3                   	ret    

c01002fe <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01002fe:	55                   	push   %ebp
c01002ff:	89 e5                	mov    %esp,%ebp
c0100301:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100304:	e8 43 13 00 00       	call   c010164c <cons_getc>
c0100309:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010030c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100310:	74 f2                	je     c0100304 <getchar+0x6>
        /* do nothing */;
    return c;
c0100312:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100315:	c9                   	leave  
c0100316:	c3                   	ret    

c0100317 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100317:	55                   	push   %ebp
c0100318:	89 e5                	mov    %esp,%ebp
c010031a:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
c010031d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100321:	74 13                	je     c0100336 <readline+0x1f>
        cprintf("%s", prompt);
c0100323:	83 ec 08             	sub    $0x8,%esp
c0100326:	ff 75 08             	pushl  0x8(%ebp)
c0100329:	68 27 5b 10 c0       	push   $0xc0105b27
c010032e:	e8 40 ff ff ff       	call   c0100273 <cprintf>
c0100333:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
c0100336:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010033d:	e8 bc ff ff ff       	call   c01002fe <getchar>
c0100342:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100345:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100349:	79 0a                	jns    c0100355 <readline+0x3e>
            return NULL;
c010034b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100350:	e9 82 00 00 00       	jmp    c01003d7 <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100355:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100359:	7e 2b                	jle    c0100386 <readline+0x6f>
c010035b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100362:	7f 22                	jg     c0100386 <readline+0x6f>
            cputchar(c);
c0100364:	83 ec 0c             	sub    $0xc,%esp
c0100367:	ff 75 f0             	pushl  -0x10(%ebp)
c010036a:	e8 2a ff ff ff       	call   c0100299 <cputchar>
c010036f:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c0100372:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100375:	8d 50 01             	lea    0x1(%eax),%edx
c0100378:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010037b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010037e:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c0100384:	eb 4c                	jmp    c01003d2 <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
c0100386:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c010038a:	75 1a                	jne    c01003a6 <readline+0x8f>
c010038c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100390:	7e 14                	jle    c01003a6 <readline+0x8f>
            cputchar(c);
c0100392:	83 ec 0c             	sub    $0xc,%esp
c0100395:	ff 75 f0             	pushl  -0x10(%ebp)
c0100398:	e8 fc fe ff ff       	call   c0100299 <cputchar>
c010039d:	83 c4 10             	add    $0x10,%esp
            i --;
c01003a0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01003a4:	eb 2c                	jmp    c01003d2 <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
c01003a6:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003aa:	74 06                	je     c01003b2 <readline+0x9b>
c01003ac:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003b0:	75 8b                	jne    c010033d <readline+0x26>
            cputchar(c);
c01003b2:	83 ec 0c             	sub    $0xc,%esp
c01003b5:	ff 75 f0             	pushl  -0x10(%ebp)
c01003b8:	e8 dc fe ff ff       	call   c0100299 <cputchar>
c01003bd:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c01003c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003c3:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01003c8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003cb:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01003d0:	eb 05                	jmp    c01003d7 <readline+0xc0>
        }
    }
c01003d2:	e9 66 ff ff ff       	jmp    c010033d <readline+0x26>
}
c01003d7:	c9                   	leave  
c01003d8:	c3                   	ret    

c01003d9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003d9:	55                   	push   %ebp
c01003da:	89 e5                	mov    %esp,%ebp
c01003dc:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
c01003df:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c01003e4:	85 c0                	test   %eax,%eax
c01003e6:	75 5f                	jne    c0100447 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c01003e8:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c01003ef:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c01003f2:	8d 45 14             	lea    0x14(%ebp),%eax
c01003f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c01003f8:	83 ec 04             	sub    $0x4,%esp
c01003fb:	ff 75 0c             	pushl  0xc(%ebp)
c01003fe:	ff 75 08             	pushl  0x8(%ebp)
c0100401:	68 2a 5b 10 c0       	push   $0xc0105b2a
c0100406:	e8 68 fe ff ff       	call   c0100273 <cprintf>
c010040b:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010040e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100411:	83 ec 08             	sub    $0x8,%esp
c0100414:	50                   	push   %eax
c0100415:	ff 75 10             	pushl  0x10(%ebp)
c0100418:	e8 2d fe ff ff       	call   c010024a <vcprintf>
c010041d:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0100420:	83 ec 0c             	sub    $0xc,%esp
c0100423:	68 46 5b 10 c0       	push   $0xc0105b46
c0100428:	e8 46 fe ff ff       	call   c0100273 <cprintf>
c010042d:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
c0100430:	83 ec 0c             	sub    $0xc,%esp
c0100433:	68 48 5b 10 c0       	push   $0xc0105b48
c0100438:	e8 36 fe ff ff       	call   c0100273 <cprintf>
c010043d:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
c0100440:	e8 17 06 00 00       	call   c0100a5c <print_stackframe>
c0100445:	eb 01                	jmp    c0100448 <__panic+0x6f>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c0100447:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100448:	e8 3b 14 00 00       	call   c0101888 <intr_disable>
    while (1) {
        kmonitor(NULL);
c010044d:	83 ec 0c             	sub    $0xc,%esp
c0100450:	6a 00                	push   $0x0
c0100452:	e8 36 08 00 00       	call   c0100c8d <kmonitor>
c0100457:	83 c4 10             	add    $0x10,%esp
    }
c010045a:	eb f1                	jmp    c010044d <__panic+0x74>

c010045c <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c010045c:	55                   	push   %ebp
c010045d:	89 e5                	mov    %esp,%ebp
c010045f:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
c0100462:	8d 45 14             	lea    0x14(%ebp),%eax
c0100465:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100468:	83 ec 04             	sub    $0x4,%esp
c010046b:	ff 75 0c             	pushl  0xc(%ebp)
c010046e:	ff 75 08             	pushl  0x8(%ebp)
c0100471:	68 5a 5b 10 c0       	push   $0xc0105b5a
c0100476:	e8 f8 fd ff ff       	call   c0100273 <cprintf>
c010047b:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010047e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100481:	83 ec 08             	sub    $0x8,%esp
c0100484:	50                   	push   %eax
c0100485:	ff 75 10             	pushl  0x10(%ebp)
c0100488:	e8 bd fd ff ff       	call   c010024a <vcprintf>
c010048d:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0100490:	83 ec 0c             	sub    $0xc,%esp
c0100493:	68 46 5b 10 c0       	push   $0xc0105b46
c0100498:	e8 d6 fd ff ff       	call   c0100273 <cprintf>
c010049d:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c01004a0:	90                   	nop
c01004a1:	c9                   	leave  
c01004a2:	c3                   	ret    

c01004a3 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004a3:	55                   	push   %ebp
c01004a4:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004a6:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c01004ab:	5d                   	pop    %ebp
c01004ac:	c3                   	ret    

c01004ad <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004ad:	55                   	push   %ebp
c01004ae:	89 e5                	mov    %esp,%ebp
c01004b0:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004b6:	8b 00                	mov    (%eax),%eax
c01004b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004be:	8b 00                	mov    (%eax),%eax
c01004c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004ca:	e9 d2 00 00 00       	jmp    c01005a1 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01004cf:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004d5:	01 d0                	add    %edx,%eax
c01004d7:	89 c2                	mov    %eax,%edx
c01004d9:	c1 ea 1f             	shr    $0x1f,%edx
c01004dc:	01 d0                	add    %edx,%eax
c01004de:	d1 f8                	sar    %eax
c01004e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004e6:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004e9:	eb 04                	jmp    c01004ef <stab_binsearch+0x42>
            m --;
c01004eb:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004f5:	7c 1f                	jl     c0100516 <stab_binsearch+0x69>
c01004f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004fa:	89 d0                	mov    %edx,%eax
c01004fc:	01 c0                	add    %eax,%eax
c01004fe:	01 d0                	add    %edx,%eax
c0100500:	c1 e0 02             	shl    $0x2,%eax
c0100503:	89 c2                	mov    %eax,%edx
c0100505:	8b 45 08             	mov    0x8(%ebp),%eax
c0100508:	01 d0                	add    %edx,%eax
c010050a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010050e:	0f b6 c0             	movzbl %al,%eax
c0100511:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100514:	75 d5                	jne    c01004eb <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100516:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100519:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010051c:	7d 0b                	jge    c0100529 <stab_binsearch+0x7c>
            l = true_m + 1;
c010051e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100521:	83 c0 01             	add    $0x1,%eax
c0100524:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100527:	eb 78                	jmp    c01005a1 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100529:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100530:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100533:	89 d0                	mov    %edx,%eax
c0100535:	01 c0                	add    %eax,%eax
c0100537:	01 d0                	add    %edx,%eax
c0100539:	c1 e0 02             	shl    $0x2,%eax
c010053c:	89 c2                	mov    %eax,%edx
c010053e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100541:	01 d0                	add    %edx,%eax
c0100543:	8b 40 08             	mov    0x8(%eax),%eax
c0100546:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100549:	73 13                	jae    c010055e <stab_binsearch+0xb1>
            *region_left = m;
c010054b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010054e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100551:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100553:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100556:	83 c0 01             	add    $0x1,%eax
c0100559:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010055c:	eb 43                	jmp    c01005a1 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010055e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100561:	89 d0                	mov    %edx,%eax
c0100563:	01 c0                	add    %eax,%eax
c0100565:	01 d0                	add    %edx,%eax
c0100567:	c1 e0 02             	shl    $0x2,%eax
c010056a:	89 c2                	mov    %eax,%edx
c010056c:	8b 45 08             	mov    0x8(%ebp),%eax
c010056f:	01 d0                	add    %edx,%eax
c0100571:	8b 40 08             	mov    0x8(%eax),%eax
c0100574:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100577:	76 16                	jbe    c010058f <stab_binsearch+0xe2>
            *region_right = m - 1;
c0100579:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010057c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010057f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100582:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100584:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100587:	83 e8 01             	sub    $0x1,%eax
c010058a:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010058d:	eb 12                	jmp    c01005a1 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c010058f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100592:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100595:	89 10                	mov    %edx,(%eax)
            l = m;
c0100597:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059a:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c010059d:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005a7:	0f 8e 22 ff ff ff    	jle    c01004cf <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005b1:	75 0f                	jne    c01005c2 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b6:	8b 00                	mov    (%eax),%eax
c01005b8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01005be:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005c0:	eb 3f                	jmp    c0100601 <stab_binsearch+0x154>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005c2:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c5:	8b 00                	mov    (%eax),%eax
c01005c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005ca:	eb 04                	jmp    c01005d0 <stab_binsearch+0x123>
c01005cc:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01005d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d3:	8b 00                	mov    (%eax),%eax
c01005d5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005d8:	7d 1f                	jge    c01005f9 <stab_binsearch+0x14c>
c01005da:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005dd:	89 d0                	mov    %edx,%eax
c01005df:	01 c0                	add    %eax,%eax
c01005e1:	01 d0                	add    %edx,%eax
c01005e3:	c1 e0 02             	shl    $0x2,%eax
c01005e6:	89 c2                	mov    %eax,%edx
c01005e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01005eb:	01 d0                	add    %edx,%eax
c01005ed:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01005f1:	0f b6 c0             	movzbl %al,%eax
c01005f4:	3b 45 14             	cmp    0x14(%ebp),%eax
c01005f7:	75 d3                	jne    c01005cc <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c01005f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005ff:	89 10                	mov    %edx,(%eax)
    }
}
c0100601:	90                   	nop
c0100602:	c9                   	leave  
c0100603:	c3                   	ret    

c0100604 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100604:	55                   	push   %ebp
c0100605:	89 e5                	mov    %esp,%ebp
c0100607:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010060a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060d:	c7 00 78 5b 10 c0    	movl   $0xc0105b78,(%eax)
    info->eip_line = 0;
c0100613:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100616:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010061d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100620:	c7 40 08 78 5b 10 c0 	movl   $0xc0105b78,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100627:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062a:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100631:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100634:	8b 55 08             	mov    0x8(%ebp),%edx
c0100637:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010063a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100644:	c7 45 f4 a8 6d 10 c0 	movl   $0xc0106da8,-0xc(%ebp)
    stab_end = __STAB_END__;
c010064b:	c7 45 f0 cc 1b 11 c0 	movl   $0xc0111bcc,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100652:	c7 45 ec cd 1b 11 c0 	movl   $0xc0111bcd,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100659:	c7 45 e8 74 46 11 c0 	movl   $0xc0114674,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100660:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100663:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100666:	76 0d                	jbe    c0100675 <debuginfo_eip+0x71>
c0100668:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010066b:	83 e8 01             	sub    $0x1,%eax
c010066e:	0f b6 00             	movzbl (%eax),%eax
c0100671:	84 c0                	test   %al,%al
c0100673:	74 0a                	je     c010067f <debuginfo_eip+0x7b>
        return -1;
c0100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010067a:	e9 91 02 00 00       	jmp    c0100910 <debuginfo_eip+0x30c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100686:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100689:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068c:	29 c2                	sub    %eax,%edx
c010068e:	89 d0                	mov    %edx,%eax
c0100690:	c1 f8 02             	sar    $0x2,%eax
c0100693:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0100699:	83 e8 01             	sub    $0x1,%eax
c010069c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c010069f:	ff 75 08             	pushl  0x8(%ebp)
c01006a2:	6a 64                	push   $0x64
c01006a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006a7:	50                   	push   %eax
c01006a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006ab:	50                   	push   %eax
c01006ac:	ff 75 f4             	pushl  -0xc(%ebp)
c01006af:	e8 f9 fd ff ff       	call   c01004ad <stab_binsearch>
c01006b4:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
c01006b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006ba:	85 c0                	test   %eax,%eax
c01006bc:	75 0a                	jne    c01006c8 <debuginfo_eip+0xc4>
        return -1;
c01006be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006c3:	e9 48 02 00 00       	jmp    c0100910 <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006cb:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006d4:	ff 75 08             	pushl  0x8(%ebp)
c01006d7:	6a 24                	push   $0x24
c01006d9:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006dc:	50                   	push   %eax
c01006dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006e0:	50                   	push   %eax
c01006e1:	ff 75 f4             	pushl  -0xc(%ebp)
c01006e4:	e8 c4 fd ff ff       	call   c01004ad <stab_binsearch>
c01006e9:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
c01006ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01006ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006f2:	39 c2                	cmp    %eax,%edx
c01006f4:	7f 7c                	jg     c0100772 <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c01006f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006f9:	89 c2                	mov    %eax,%edx
c01006fb:	89 d0                	mov    %edx,%eax
c01006fd:	01 c0                	add    %eax,%eax
c01006ff:	01 d0                	add    %edx,%eax
c0100701:	c1 e0 02             	shl    $0x2,%eax
c0100704:	89 c2                	mov    %eax,%edx
c0100706:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100709:	01 d0                	add    %edx,%eax
c010070b:	8b 00                	mov    (%eax),%eax
c010070d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100710:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100713:	29 d1                	sub    %edx,%ecx
c0100715:	89 ca                	mov    %ecx,%edx
c0100717:	39 d0                	cmp    %edx,%eax
c0100719:	73 22                	jae    c010073d <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010071b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010071e:	89 c2                	mov    %eax,%edx
c0100720:	89 d0                	mov    %edx,%eax
c0100722:	01 c0                	add    %eax,%eax
c0100724:	01 d0                	add    %edx,%eax
c0100726:	c1 e0 02             	shl    $0x2,%eax
c0100729:	89 c2                	mov    %eax,%edx
c010072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010072e:	01 d0                	add    %edx,%eax
c0100730:	8b 10                	mov    (%eax),%edx
c0100732:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100735:	01 c2                	add    %eax,%edx
c0100737:	8b 45 0c             	mov    0xc(%ebp),%eax
c010073a:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010073d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100740:	89 c2                	mov    %eax,%edx
c0100742:	89 d0                	mov    %edx,%eax
c0100744:	01 c0                	add    %eax,%eax
c0100746:	01 d0                	add    %edx,%eax
c0100748:	c1 e0 02             	shl    $0x2,%eax
c010074b:	89 c2                	mov    %eax,%edx
c010074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100750:	01 d0                	add    %edx,%eax
c0100752:	8b 50 08             	mov    0x8(%eax),%edx
c0100755:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100758:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c010075b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010075e:	8b 40 10             	mov    0x10(%eax),%eax
c0100761:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100764:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100767:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c010076a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010076d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0100770:	eb 15                	jmp    c0100787 <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100772:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100775:	8b 55 08             	mov    0x8(%ebp),%edx
c0100778:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c010077b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010077e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0100781:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100784:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0100787:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078a:	8b 40 08             	mov    0x8(%eax),%eax
c010078d:	83 ec 08             	sub    $0x8,%esp
c0100790:	6a 3a                	push   $0x3a
c0100792:	50                   	push   %eax
c0100793:	e8 b5 49 00 00       	call   c010514d <strfind>
c0100798:	83 c4 10             	add    $0x10,%esp
c010079b:	89 c2                	mov    %eax,%edx
c010079d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a0:	8b 40 08             	mov    0x8(%eax),%eax
c01007a3:	29 c2                	sub    %eax,%edx
c01007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007ab:	83 ec 0c             	sub    $0xc,%esp
c01007ae:	ff 75 08             	pushl  0x8(%ebp)
c01007b1:	6a 44                	push   $0x44
c01007b3:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007b6:	50                   	push   %eax
c01007b7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007ba:	50                   	push   %eax
c01007bb:	ff 75 f4             	pushl  -0xc(%ebp)
c01007be:	e8 ea fc ff ff       	call   c01004ad <stab_binsearch>
c01007c3:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c01007c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007cc:	39 c2                	cmp    %eax,%edx
c01007ce:	7f 24                	jg     c01007f4 <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
c01007d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007d3:	89 c2                	mov    %eax,%edx
c01007d5:	89 d0                	mov    %edx,%eax
c01007d7:	01 c0                	add    %eax,%eax
c01007d9:	01 d0                	add    %edx,%eax
c01007db:	c1 e0 02             	shl    $0x2,%eax
c01007de:	89 c2                	mov    %eax,%edx
c01007e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007e3:	01 d0                	add    %edx,%eax
c01007e5:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c01007e9:	0f b7 d0             	movzwl %ax,%edx
c01007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ef:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c01007f2:	eb 13                	jmp    c0100807 <debuginfo_eip+0x203>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c01007f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01007f9:	e9 12 01 00 00       	jmp    c0100910 <debuginfo_eip+0x30c>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c01007fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100801:	83 e8 01             	sub    $0x1,%eax
c0100804:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100807:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010080a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010080d:	39 c2                	cmp    %eax,%edx
c010080f:	7c 56                	jl     c0100867 <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
c0100811:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100814:	89 c2                	mov    %eax,%edx
c0100816:	89 d0                	mov    %edx,%eax
c0100818:	01 c0                	add    %eax,%eax
c010081a:	01 d0                	add    %edx,%eax
c010081c:	c1 e0 02             	shl    $0x2,%eax
c010081f:	89 c2                	mov    %eax,%edx
c0100821:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100824:	01 d0                	add    %edx,%eax
c0100826:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010082a:	3c 84                	cmp    $0x84,%al
c010082c:	74 39                	je     c0100867 <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010082e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100831:	89 c2                	mov    %eax,%edx
c0100833:	89 d0                	mov    %edx,%eax
c0100835:	01 c0                	add    %eax,%eax
c0100837:	01 d0                	add    %edx,%eax
c0100839:	c1 e0 02             	shl    $0x2,%eax
c010083c:	89 c2                	mov    %eax,%edx
c010083e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100841:	01 d0                	add    %edx,%eax
c0100843:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100847:	3c 64                	cmp    $0x64,%al
c0100849:	75 b3                	jne    c01007fe <debuginfo_eip+0x1fa>
c010084b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084e:	89 c2                	mov    %eax,%edx
c0100850:	89 d0                	mov    %edx,%eax
c0100852:	01 c0                	add    %eax,%eax
c0100854:	01 d0                	add    %edx,%eax
c0100856:	c1 e0 02             	shl    $0x2,%eax
c0100859:	89 c2                	mov    %eax,%edx
c010085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085e:	01 d0                	add    %edx,%eax
c0100860:	8b 40 08             	mov    0x8(%eax),%eax
c0100863:	85 c0                	test   %eax,%eax
c0100865:	74 97                	je     c01007fe <debuginfo_eip+0x1fa>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100867:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010086a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010086d:	39 c2                	cmp    %eax,%edx
c010086f:	7c 46                	jl     c01008b7 <debuginfo_eip+0x2b3>
c0100871:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100874:	89 c2                	mov    %eax,%edx
c0100876:	89 d0                	mov    %edx,%eax
c0100878:	01 c0                	add    %eax,%eax
c010087a:	01 d0                	add    %edx,%eax
c010087c:	c1 e0 02             	shl    $0x2,%eax
c010087f:	89 c2                	mov    %eax,%edx
c0100881:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100884:	01 d0                	add    %edx,%eax
c0100886:	8b 00                	mov    (%eax),%eax
c0100888:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010088b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010088e:	29 d1                	sub    %edx,%ecx
c0100890:	89 ca                	mov    %ecx,%edx
c0100892:	39 d0                	cmp    %edx,%eax
c0100894:	73 21                	jae    c01008b7 <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100896:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100899:	89 c2                	mov    %eax,%edx
c010089b:	89 d0                	mov    %edx,%eax
c010089d:	01 c0                	add    %eax,%eax
c010089f:	01 d0                	add    %edx,%eax
c01008a1:	c1 e0 02             	shl    $0x2,%eax
c01008a4:	89 c2                	mov    %eax,%edx
c01008a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a9:	01 d0                	add    %edx,%eax
c01008ab:	8b 10                	mov    (%eax),%edx
c01008ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008b0:	01 c2                	add    %eax,%edx
c01008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008b5:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008bd:	39 c2                	cmp    %eax,%edx
c01008bf:	7d 4a                	jge    c010090b <debuginfo_eip+0x307>
        for (lline = lfun + 1;
c01008c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008c4:	83 c0 01             	add    $0x1,%eax
c01008c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008ca:	eb 18                	jmp    c01008e4 <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008cf:	8b 40 14             	mov    0x14(%eax),%eax
c01008d2:	8d 50 01             	lea    0x1(%eax),%edx
c01008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008d8:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c01008db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008de:	83 c0 01             	add    $0x1,%eax
c01008e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c01008ea:	39 c2                	cmp    %eax,%edx
c01008ec:	7d 1d                	jge    c010090b <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008f1:	89 c2                	mov    %eax,%edx
c01008f3:	89 d0                	mov    %edx,%eax
c01008f5:	01 c0                	add    %eax,%eax
c01008f7:	01 d0                	add    %edx,%eax
c01008f9:	c1 e0 02             	shl    $0x2,%eax
c01008fc:	89 c2                	mov    %eax,%edx
c01008fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100901:	01 d0                	add    %edx,%eax
c0100903:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100907:	3c a0                	cmp    $0xa0,%al
c0100909:	74 c1                	je     c01008cc <debuginfo_eip+0x2c8>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c010090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100910:	c9                   	leave  
c0100911:	c3                   	ret    

c0100912 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100912:	55                   	push   %ebp
c0100913:	89 e5                	mov    %esp,%ebp
c0100915:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100918:	83 ec 0c             	sub    $0xc,%esp
c010091b:	68 82 5b 10 c0       	push   $0xc0105b82
c0100920:	e8 4e f9 ff ff       	call   c0100273 <cprintf>
c0100925:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100928:	83 ec 08             	sub    $0x8,%esp
c010092b:	68 36 00 10 c0       	push   $0xc0100036
c0100930:	68 9b 5b 10 c0       	push   $0xc0105b9b
c0100935:	e8 39 f9 ff ff       	call   c0100273 <cprintf>
c010093a:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c010093d:	83 ec 08             	sub    $0x8,%esp
c0100940:	68 70 5a 10 c0       	push   $0xc0105a70
c0100945:	68 b3 5b 10 c0       	push   $0xc0105bb3
c010094a:	e8 24 f9 ff ff       	call   c0100273 <cprintf>
c010094f:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100952:	83 ec 08             	sub    $0x8,%esp
c0100955:	68 00 a0 11 c0       	push   $0xc011a000
c010095a:	68 cb 5b 10 c0       	push   $0xc0105bcb
c010095f:	e8 0f f9 ff ff       	call   c0100273 <cprintf>
c0100964:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c0100967:	83 ec 08             	sub    $0x8,%esp
c010096a:	68 28 af 11 c0       	push   $0xc011af28
c010096f:	68 e3 5b 10 c0       	push   $0xc0105be3
c0100974:	e8 fa f8 ff ff       	call   c0100273 <cprintf>
c0100979:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010097c:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0100981:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100986:	ba 36 00 10 c0       	mov    $0xc0100036,%edx
c010098b:	29 d0                	sub    %edx,%eax
c010098d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100993:	85 c0                	test   %eax,%eax
c0100995:	0f 48 c2             	cmovs  %edx,%eax
c0100998:	c1 f8 0a             	sar    $0xa,%eax
c010099b:	83 ec 08             	sub    $0x8,%esp
c010099e:	50                   	push   %eax
c010099f:	68 fc 5b 10 c0       	push   $0xc0105bfc
c01009a4:	e8 ca f8 ff ff       	call   c0100273 <cprintf>
c01009a9:	83 c4 10             	add    $0x10,%esp
}
c01009ac:	90                   	nop
c01009ad:	c9                   	leave  
c01009ae:	c3                   	ret    

c01009af <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009af:	55                   	push   %ebp
c01009b0:	89 e5                	mov    %esp,%ebp
c01009b2:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009b8:	83 ec 08             	sub    $0x8,%esp
c01009bb:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009be:	50                   	push   %eax
c01009bf:	ff 75 08             	pushl  0x8(%ebp)
c01009c2:	e8 3d fc ff ff       	call   c0100604 <debuginfo_eip>
c01009c7:	83 c4 10             	add    $0x10,%esp
c01009ca:	85 c0                	test   %eax,%eax
c01009cc:	74 15                	je     c01009e3 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009ce:	83 ec 08             	sub    $0x8,%esp
c01009d1:	ff 75 08             	pushl  0x8(%ebp)
c01009d4:	68 26 5c 10 c0       	push   $0xc0105c26
c01009d9:	e8 95 f8 ff ff       	call   c0100273 <cprintf>
c01009de:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c01009e1:	eb 65                	jmp    c0100a48 <print_debuginfo+0x99>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01009e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01009ea:	eb 1c                	jmp    c0100a08 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c01009ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01009ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f2:	01 d0                	add    %edx,%eax
c01009f4:	0f b6 00             	movzbl (%eax),%eax
c01009f7:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a00:	01 ca                	add    %ecx,%edx
c0100a02:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a0b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a0e:	7f dc                	jg     c01009ec <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a10:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a19:	01 d0                	add    %edx,%eax
c0100a1b:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a21:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a24:	89 d1                	mov    %edx,%ecx
c0100a26:	29 c1                	sub    %eax,%ecx
c0100a28:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a2e:	83 ec 0c             	sub    $0xc,%esp
c0100a31:	51                   	push   %ecx
c0100a32:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a38:	51                   	push   %ecx
c0100a39:	52                   	push   %edx
c0100a3a:	50                   	push   %eax
c0100a3b:	68 42 5c 10 c0       	push   $0xc0105c42
c0100a40:	e8 2e f8 ff ff       	call   c0100273 <cprintf>
c0100a45:	83 c4 20             	add    $0x20,%esp
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a48:	90                   	nop
c0100a49:	c9                   	leave  
c0100a4a:	c3                   	ret    

c0100a4b <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a4b:	55                   	push   %ebp
c0100a4c:	89 e5                	mov    %esp,%ebp
c0100a4e:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a51:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a54:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a57:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a5a:	c9                   	leave  
c0100a5b:	c3                   	ret    

c0100a5c <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a5c:	55                   	push   %ebp
c0100a5d:	89 e5                	mov    %esp,%ebp
c0100a5f:	53                   	push   %ebx
c0100a60:	83 ec 24             	sub    $0x24,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a63:	89 e8                	mov    %ebp,%eax
c0100a65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100a68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
c0100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
c0100a6e:	e8 d8 ff ff ff       	call   c0100a4b <read_eip>
c0100a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int itr = 0; itr < STACKFRAME_DEPTH && ebp != 0; itr++) {
c0100a76:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100a7d:	e9 89 00 00 00       	jmp    c0100b0b <print_stackframe+0xaf>
        cprintf("ebp = 0x%08x, eip = 0x%08x", ebp, eip);
c0100a82:	83 ec 04             	sub    $0x4,%esp
c0100a85:	ff 75 f0             	pushl  -0x10(%ebp)
c0100a88:	ff 75 f4             	pushl  -0xc(%ebp)
c0100a8b:	68 54 5c 10 c0       	push   $0xc0105c54
c0100a90:	e8 de f7 ff ff       	call   c0100273 <cprintf>
c0100a95:	83 c4 10             	add    $0x10,%esp
        uint32_t *ptr = (uint32_t *)(ebp + 2);
c0100a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a9b:	83 c0 02             	add    $0x2,%eax
c0100a9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        cprintf("arg = 0x%08x, 0x%08x, 0x%08x, 0x%08x", *(ptr), *(ptr+1), *(ptr+2), *(ptr+3));
c0100aa1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100aa4:	83 c0 0c             	add    $0xc,%eax
c0100aa7:	8b 18                	mov    (%eax),%ebx
c0100aa9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100aac:	83 c0 08             	add    $0x8,%eax
c0100aaf:	8b 08                	mov    (%eax),%ecx
c0100ab1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ab4:	83 c0 04             	add    $0x4,%eax
c0100ab7:	8b 10                	mov    (%eax),%edx
c0100ab9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100abc:	8b 00                	mov    (%eax),%eax
c0100abe:	83 ec 0c             	sub    $0xc,%esp
c0100ac1:	53                   	push   %ebx
c0100ac2:	51                   	push   %ecx
c0100ac3:	52                   	push   %edx
c0100ac4:	50                   	push   %eax
c0100ac5:	68 70 5c 10 c0       	push   $0xc0105c70
c0100aca:	e8 a4 f7 ff ff       	call   c0100273 <cprintf>
c0100acf:	83 c4 20             	add    $0x20,%esp
        cprintf("\n");
c0100ad2:	83 ec 0c             	sub    $0xc,%esp
c0100ad5:	68 95 5c 10 c0       	push   $0xc0105c95
c0100ada:	e8 94 f7 ff ff       	call   c0100273 <cprintf>
c0100adf:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
c0100ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ae5:	83 e8 01             	sub    $0x1,%eax
c0100ae8:	83 ec 0c             	sub    $0xc,%esp
c0100aeb:	50                   	push   %eax
c0100aec:	e8 be fe ff ff       	call   c01009af <print_debuginfo>
c0100af1:	83 c4 10             	add    $0x10,%esp

        //(3.5???)
        eip = ((uint32_t *)ebp)[1];
c0100af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100af7:	83 c0 04             	add    $0x4,%eax
c0100afa:	8b 00                	mov    (%eax),%eax
c0100afc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b02:	8b 00                	mov    (%eax),%eax
c0100b04:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
    uint32_t eip = read_eip();
    for (int itr = 0; itr < STACKFRAME_DEPTH && ebp != 0; itr++) {
c0100b07:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b0b:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b0f:	7f 0a                	jg     c0100b1b <print_stackframe+0xbf>
c0100b11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b15:	0f 85 67 ff ff ff    	jne    c0100a82 <print_stackframe+0x26>

        //(3.5???)
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100b1b:	90                   	nop
c0100b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100b1f:	c9                   	leave  
c0100b20:	c3                   	ret    

c0100b21 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b21:	55                   	push   %ebp
c0100b22:	89 e5                	mov    %esp,%ebp
c0100b24:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
c0100b27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b2e:	eb 0c                	jmp    c0100b3c <parse+0x1b>
            *buf ++ = '\0';
c0100b30:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b33:	8d 50 01             	lea    0x1(%eax),%edx
c0100b36:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b39:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b3f:	0f b6 00             	movzbl (%eax),%eax
c0100b42:	84 c0                	test   %al,%al
c0100b44:	74 1e                	je     c0100b64 <parse+0x43>
c0100b46:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b49:	0f b6 00             	movzbl (%eax),%eax
c0100b4c:	0f be c0             	movsbl %al,%eax
c0100b4f:	83 ec 08             	sub    $0x8,%esp
c0100b52:	50                   	push   %eax
c0100b53:	68 18 5d 10 c0       	push   $0xc0105d18
c0100b58:	e8 bd 45 00 00       	call   c010511a <strchr>
c0100b5d:	83 c4 10             	add    $0x10,%esp
c0100b60:	85 c0                	test   %eax,%eax
c0100b62:	75 cc                	jne    c0100b30 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100b64:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b67:	0f b6 00             	movzbl (%eax),%eax
c0100b6a:	84 c0                	test   %al,%al
c0100b6c:	74 69                	je     c0100bd7 <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b6e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b72:	75 12                	jne    c0100b86 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b74:	83 ec 08             	sub    $0x8,%esp
c0100b77:	6a 10                	push   $0x10
c0100b79:	68 1d 5d 10 c0       	push   $0xc0105d1d
c0100b7e:	e8 f0 f6 ff ff       	call   c0100273 <cprintf>
c0100b83:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0100b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b89:	8d 50 01             	lea    0x1(%eax),%edx
c0100b8c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b99:	01 c2                	add    %eax,%edx
c0100b9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b9e:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100ba0:	eb 04                	jmp    c0100ba6 <parse+0x85>
            buf ++;
c0100ba2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100ba6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ba9:	0f b6 00             	movzbl (%eax),%eax
c0100bac:	84 c0                	test   %al,%al
c0100bae:	0f 84 7a ff ff ff    	je     c0100b2e <parse+0xd>
c0100bb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb7:	0f b6 00             	movzbl (%eax),%eax
c0100bba:	0f be c0             	movsbl %al,%eax
c0100bbd:	83 ec 08             	sub    $0x8,%esp
c0100bc0:	50                   	push   %eax
c0100bc1:	68 18 5d 10 c0       	push   $0xc0105d18
c0100bc6:	e8 4f 45 00 00       	call   c010511a <strchr>
c0100bcb:	83 c4 10             	add    $0x10,%esp
c0100bce:	85 c0                	test   %eax,%eax
c0100bd0:	74 d0                	je     c0100ba2 <parse+0x81>
            buf ++;
        }
    }
c0100bd2:	e9 57 ff ff ff       	jmp    c0100b2e <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100bd7:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100bdb:	c9                   	leave  
c0100bdc:	c3                   	ret    

c0100bdd <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100bdd:	55                   	push   %ebp
c0100bde:	89 e5                	mov    %esp,%ebp
c0100be0:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100be3:	83 ec 08             	sub    $0x8,%esp
c0100be6:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100be9:	50                   	push   %eax
c0100bea:	ff 75 08             	pushl  0x8(%ebp)
c0100bed:	e8 2f ff ff ff       	call   c0100b21 <parse>
c0100bf2:	83 c4 10             	add    $0x10,%esp
c0100bf5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100bf8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100bfc:	75 0a                	jne    c0100c08 <runcmd+0x2b>
        return 0;
c0100bfe:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c03:	e9 83 00 00 00       	jmp    c0100c8b <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c0f:	eb 59                	jmp    c0100c6a <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c11:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c14:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c17:	89 d0                	mov    %edx,%eax
c0100c19:	01 c0                	add    %eax,%eax
c0100c1b:	01 d0                	add    %edx,%eax
c0100c1d:	c1 e0 02             	shl    $0x2,%eax
c0100c20:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c25:	8b 00                	mov    (%eax),%eax
c0100c27:	83 ec 08             	sub    $0x8,%esp
c0100c2a:	51                   	push   %ecx
c0100c2b:	50                   	push   %eax
c0100c2c:	e8 49 44 00 00       	call   c010507a <strcmp>
c0100c31:	83 c4 10             	add    $0x10,%esp
c0100c34:	85 c0                	test   %eax,%eax
c0100c36:	75 2e                	jne    c0100c66 <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c38:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c3b:	89 d0                	mov    %edx,%eax
c0100c3d:	01 c0                	add    %eax,%eax
c0100c3f:	01 d0                	add    %edx,%eax
c0100c41:	c1 e0 02             	shl    $0x2,%eax
c0100c44:	05 08 70 11 c0       	add    $0xc0117008,%eax
c0100c49:	8b 10                	mov    (%eax),%edx
c0100c4b:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c4e:	83 c0 04             	add    $0x4,%eax
c0100c51:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c54:	83 e9 01             	sub    $0x1,%ecx
c0100c57:	83 ec 04             	sub    $0x4,%esp
c0100c5a:	ff 75 0c             	pushl  0xc(%ebp)
c0100c5d:	50                   	push   %eax
c0100c5e:	51                   	push   %ecx
c0100c5f:	ff d2                	call   *%edx
c0100c61:	83 c4 10             	add    $0x10,%esp
c0100c64:	eb 25                	jmp    c0100c8b <runcmd+0xae>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c6d:	83 f8 02             	cmp    $0x2,%eax
c0100c70:	76 9f                	jbe    c0100c11 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c72:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c75:	83 ec 08             	sub    $0x8,%esp
c0100c78:	50                   	push   %eax
c0100c79:	68 3b 5d 10 c0       	push   $0xc0105d3b
c0100c7e:	e8 f0 f5 ff ff       	call   c0100273 <cprintf>
c0100c83:	83 c4 10             	add    $0x10,%esp
    return 0;
c0100c86:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c8b:	c9                   	leave  
c0100c8c:	c3                   	ret    

c0100c8d <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c8d:	55                   	push   %ebp
c0100c8e:	89 e5                	mov    %esp,%ebp
c0100c90:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c93:	83 ec 0c             	sub    $0xc,%esp
c0100c96:	68 54 5d 10 c0       	push   $0xc0105d54
c0100c9b:	e8 d3 f5 ff ff       	call   c0100273 <cprintf>
c0100ca0:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c0100ca3:	83 ec 0c             	sub    $0xc,%esp
c0100ca6:	68 7c 5d 10 c0       	push   $0xc0105d7c
c0100cab:	e8 c3 f5 ff ff       	call   c0100273 <cprintf>
c0100cb0:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
c0100cb3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cb7:	74 0e                	je     c0100cc7 <kmonitor+0x3a>
        print_trapframe(tf);
c0100cb9:	83 ec 0c             	sub    $0xc,%esp
c0100cbc:	ff 75 08             	pushl  0x8(%ebp)
c0100cbf:	e8 9e 0d 00 00       	call   c0101a62 <print_trapframe>
c0100cc4:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cc7:	83 ec 0c             	sub    $0xc,%esp
c0100cca:	68 a1 5d 10 c0       	push   $0xc0105da1
c0100ccf:	e8 43 f6 ff ff       	call   c0100317 <readline>
c0100cd4:	83 c4 10             	add    $0x10,%esp
c0100cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100cda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100cde:	74 e7                	je     c0100cc7 <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
c0100ce0:	83 ec 08             	sub    $0x8,%esp
c0100ce3:	ff 75 08             	pushl  0x8(%ebp)
c0100ce6:	ff 75 f4             	pushl  -0xc(%ebp)
c0100ce9:	e8 ef fe ff ff       	call   c0100bdd <runcmd>
c0100cee:	83 c4 10             	add    $0x10,%esp
c0100cf1:	85 c0                	test   %eax,%eax
c0100cf3:	78 02                	js     c0100cf7 <kmonitor+0x6a>
                break;
            }
        }
    }
c0100cf5:	eb d0                	jmp    c0100cc7 <kmonitor+0x3a>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100cf7:	90                   	nop
            }
        }
    }
}
c0100cf8:	90                   	nop
c0100cf9:	c9                   	leave  
c0100cfa:	c3                   	ret    

c0100cfb <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100cfb:	55                   	push   %ebp
c0100cfc:	89 e5                	mov    %esp,%ebp
c0100cfe:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d08:	eb 3c                	jmp    c0100d46 <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d0d:	89 d0                	mov    %edx,%eax
c0100d0f:	01 c0                	add    %eax,%eax
c0100d11:	01 d0                	add    %edx,%eax
c0100d13:	c1 e0 02             	shl    $0x2,%eax
c0100d16:	05 04 70 11 c0       	add    $0xc0117004,%eax
c0100d1b:	8b 08                	mov    (%eax),%ecx
c0100d1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d20:	89 d0                	mov    %edx,%eax
c0100d22:	01 c0                	add    %eax,%eax
c0100d24:	01 d0                	add    %edx,%eax
c0100d26:	c1 e0 02             	shl    $0x2,%eax
c0100d29:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100d2e:	8b 00                	mov    (%eax),%eax
c0100d30:	83 ec 04             	sub    $0x4,%esp
c0100d33:	51                   	push   %ecx
c0100d34:	50                   	push   %eax
c0100d35:	68 a5 5d 10 c0       	push   $0xc0105da5
c0100d3a:	e8 34 f5 ff ff       	call   c0100273 <cprintf>
c0100d3f:	83 c4 10             	add    $0x10,%esp

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d42:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d49:	83 f8 02             	cmp    $0x2,%eax
c0100d4c:	76 bc                	jbe    c0100d0a <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100d4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d53:	c9                   	leave  
c0100d54:	c3                   	ret    

c0100d55 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d55:	55                   	push   %ebp
c0100d56:	89 e5                	mov    %esp,%ebp
c0100d58:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d5b:	e8 b2 fb ff ff       	call   c0100912 <print_kerninfo>
    return 0;
c0100d60:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d65:	c9                   	leave  
c0100d66:	c3                   	ret    

c0100d67 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d67:	55                   	push   %ebp
c0100d68:	89 e5                	mov    %esp,%ebp
c0100d6a:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d6d:	e8 ea fc ff ff       	call   c0100a5c <print_stackframe>
    return 0;
c0100d72:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d77:	c9                   	leave  
c0100d78:	c3                   	ret    

c0100d79 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d79:	55                   	push   %ebp
c0100d7a:	89 e5                	mov    %esp,%ebp
c0100d7c:	83 ec 18             	sub    $0x18,%esp
c0100d7f:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100d85:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d89:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c0100d8d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100d91:	ee                   	out    %al,(%dx)
c0100d92:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0100d98:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0100d9c:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0100da0:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0100da4:	ee                   	out    %al,(%dx)
c0100da5:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dab:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c0100daf:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100db3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100db7:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100db8:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100dbf:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dc2:	83 ec 0c             	sub    $0xc,%esp
c0100dc5:	68 ae 5d 10 c0       	push   $0xc0105dae
c0100dca:	e8 a4 f4 ff ff       	call   c0100273 <cprintf>
c0100dcf:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c0100dd2:	83 ec 0c             	sub    $0xc,%esp
c0100dd5:	6a 00                	push   $0x0
c0100dd7:	e8 3b 09 00 00       	call   c0101717 <pic_enable>
c0100ddc:	83 c4 10             	add    $0x10,%esp
}
c0100ddf:	90                   	nop
c0100de0:	c9                   	leave  
c0100de1:	c3                   	ret    

c0100de2 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100de2:	55                   	push   %ebp
c0100de3:	89 e5                	mov    %esp,%ebp
c0100de5:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100de8:	9c                   	pushf  
c0100de9:	58                   	pop    %eax
c0100dea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100df0:	25 00 02 00 00       	and    $0x200,%eax
c0100df5:	85 c0                	test   %eax,%eax
c0100df7:	74 0c                	je     c0100e05 <__intr_save+0x23>
        intr_disable();
c0100df9:	e8 8a 0a 00 00       	call   c0101888 <intr_disable>
        return 1;
c0100dfe:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e03:	eb 05                	jmp    c0100e0a <__intr_save+0x28>
    }
    return 0;
c0100e05:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e0a:	c9                   	leave  
c0100e0b:	c3                   	ret    

c0100e0c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e0c:	55                   	push   %ebp
c0100e0d:	89 e5                	mov    %esp,%ebp
c0100e0f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e16:	74 05                	je     c0100e1d <__intr_restore+0x11>
        intr_enable();
c0100e18:	e8 64 0a 00 00       	call   c0101881 <intr_enable>
    }
}
c0100e1d:	90                   	nop
c0100e1e:	c9                   	leave  
c0100e1f:	c3                   	ret    

c0100e20 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e20:	55                   	push   %ebp
c0100e21:	89 e5                	mov    %esp,%ebp
c0100e23:	83 ec 10             	sub    $0x10,%esp
c0100e26:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e2c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e30:	89 c2                	mov    %eax,%edx
c0100e32:	ec                   	in     (%dx),%al
c0100e33:	88 45 f4             	mov    %al,-0xc(%ebp)
c0100e36:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c0100e3c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0100e40:	89 c2                	mov    %eax,%edx
c0100e42:	ec                   	in     (%dx),%al
c0100e43:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e46:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e4c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e50:	89 c2                	mov    %eax,%edx
c0100e52:	ec                   	in     (%dx),%al
c0100e53:	88 45 f6             	mov    %al,-0xa(%ebp)
c0100e56:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c0100e5c:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0100e60:	89 c2                	mov    %eax,%edx
c0100e62:	ec                   	in     (%dx),%al
c0100e63:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e66:	90                   	nop
c0100e67:	c9                   	leave  
c0100e68:	c3                   	ret    

c0100e69 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e69:	55                   	push   %ebp
c0100e6a:	89 e5                	mov    %esp,%ebp
c0100e6c:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e6f:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e76:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e79:	0f b7 00             	movzwl (%eax),%eax
c0100e7c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e80:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e83:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100e88:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e8b:	0f b7 00             	movzwl (%eax),%eax
c0100e8e:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100e92:	74 12                	je     c0100ea6 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100e94:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100e9b:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100ea2:	b4 03 
c0100ea4:	eb 13                	jmp    c0100eb9 <cga_init+0x50>
    } else {
        *cp = was;
c0100ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ead:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100eb0:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100eb7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100eb9:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ec0:	0f b7 c0             	movzwl %ax,%eax
c0100ec3:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0100ec7:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ecb:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0100ecf:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0100ed3:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ed4:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100edb:	83 c0 01             	add    $0x1,%eax
c0100ede:	0f b7 c0             	movzwl %ax,%eax
c0100ee1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ee5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100ee9:	89 c2                	mov    %eax,%edx
c0100eeb:	ec                   	in     (%dx),%al
c0100eec:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0100eef:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0100ef3:	0f b6 c0             	movzbl %al,%eax
c0100ef6:	c1 e0 08             	shl    $0x8,%eax
c0100ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100efc:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f03:	0f b7 c0             	movzwl %ax,%eax
c0100f06:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0100f0a:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f0e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0100f12:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0100f16:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f17:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f1e:	83 c0 01             	add    $0x1,%eax
c0100f21:	0f b7 c0             	movzwl %ax,%eax
c0100f24:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f28:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f2c:	89 c2                	mov    %eax,%edx
c0100f2e:	ec                   	in     (%dx),%al
c0100f2f:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f32:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f36:	0f b6 c0             	movzbl %al,%eax
c0100f39:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f3f:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f47:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f4d:	90                   	nop
c0100f4e:	c9                   	leave  
c0100f4f:	c3                   	ret    

c0100f50 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f50:	55                   	push   %ebp
c0100f51:	89 e5                	mov    %esp,%ebp
c0100f53:	83 ec 28             	sub    $0x28,%esp
c0100f56:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f5c:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f60:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0100f64:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f68:	ee                   	out    %al,(%dx)
c0100f69:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c0100f6f:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c0100f73:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0100f77:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0100f7b:	ee                   	out    %al,(%dx)
c0100f7c:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0100f82:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0100f86:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0100f8a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f8e:	ee                   	out    %al,(%dx)
c0100f8f:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0100f95:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0100f99:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100f9d:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0100fa1:	ee                   	out    %al,(%dx)
c0100fa2:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0100fa8:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0100fac:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0100fb0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fb4:	ee                   	out    %al,(%dx)
c0100fb5:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0100fbb:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0100fbf:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0100fc3:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0100fc7:	ee                   	out    %al,(%dx)
c0100fc8:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fce:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0100fd2:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0100fd6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fda:	ee                   	out    %al,(%dx)
c0100fdb:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fe1:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
c0100fe5:	89 c2                	mov    %eax,%edx
c0100fe7:	ec                   	in     (%dx),%al
c0100fe8:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0100feb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100fef:	3c ff                	cmp    $0xff,%al
c0100ff1:	0f 95 c0             	setne  %al
c0100ff4:	0f b6 c0             	movzbl %al,%eax
c0100ff7:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0100ffc:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101002:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101006:	89 c2                	mov    %eax,%edx
c0101008:	ec                   	in     (%dx),%al
c0101009:	88 45 e2             	mov    %al,-0x1e(%ebp)
c010100c:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c0101012:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
c0101016:	89 c2                	mov    %eax,%edx
c0101018:	ec                   	in     (%dx),%al
c0101019:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010101c:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101021:	85 c0                	test   %eax,%eax
c0101023:	74 0d                	je     c0101032 <serial_init+0xe2>
        pic_enable(IRQ_COM1);
c0101025:	83 ec 0c             	sub    $0xc,%esp
c0101028:	6a 04                	push   $0x4
c010102a:	e8 e8 06 00 00       	call   c0101717 <pic_enable>
c010102f:	83 c4 10             	add    $0x10,%esp
    }
}
c0101032:	90                   	nop
c0101033:	c9                   	leave  
c0101034:	c3                   	ret    

c0101035 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101035:	55                   	push   %ebp
c0101036:	89 e5                	mov    %esp,%ebp
c0101038:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010103b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101042:	eb 09                	jmp    c010104d <lpt_putc_sub+0x18>
        delay();
c0101044:	e8 d7 fd ff ff       	call   c0100e20 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101049:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010104d:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c0101053:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0101057:	89 c2                	mov    %eax,%edx
c0101059:	ec                   	in     (%dx),%al
c010105a:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c010105d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101061:	84 c0                	test   %al,%al
c0101063:	78 09                	js     c010106e <lpt_putc_sub+0x39>
c0101065:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010106c:	7e d6                	jle    c0101044 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c010106e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101071:	0f b6 c0             	movzbl %al,%eax
c0101074:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c010107a:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010107d:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0101081:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0101085:	ee                   	out    %al,(%dx)
c0101086:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c010108c:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101090:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101094:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101098:	ee                   	out    %al,(%dx)
c0101099:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c010109f:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c01010a3:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c01010a7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01010ab:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010ac:	90                   	nop
c01010ad:	c9                   	leave  
c01010ae:	c3                   	ret    

c01010af <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010af:	55                   	push   %ebp
c01010b0:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c01010b2:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010b6:	74 0d                	je     c01010c5 <lpt_putc+0x16>
        lpt_putc_sub(c);
c01010b8:	ff 75 08             	pushl  0x8(%ebp)
c01010bb:	e8 75 ff ff ff       	call   c0101035 <lpt_putc_sub>
c01010c0:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01010c3:	eb 1e                	jmp    c01010e3 <lpt_putc+0x34>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c01010c5:	6a 08                	push   $0x8
c01010c7:	e8 69 ff ff ff       	call   c0101035 <lpt_putc_sub>
c01010cc:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
c01010cf:	6a 20                	push   $0x20
c01010d1:	e8 5f ff ff ff       	call   c0101035 <lpt_putc_sub>
c01010d6:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
c01010d9:	6a 08                	push   $0x8
c01010db:	e8 55 ff ff ff       	call   c0101035 <lpt_putc_sub>
c01010e0:	83 c4 04             	add    $0x4,%esp
    }
}
c01010e3:	90                   	nop
c01010e4:	c9                   	leave  
c01010e5:	c3                   	ret    

c01010e6 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01010e6:	55                   	push   %ebp
c01010e7:	89 e5                	mov    %esp,%ebp
c01010e9:	53                   	push   %ebx
c01010ea:	83 ec 14             	sub    $0x14,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01010ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f0:	b0 00                	mov    $0x0,%al
c01010f2:	85 c0                	test   %eax,%eax
c01010f4:	75 07                	jne    c01010fd <cga_putc+0x17>
        c |= 0x0700;
c01010f6:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01010fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101100:	0f b6 c0             	movzbl %al,%eax
c0101103:	83 f8 0a             	cmp    $0xa,%eax
c0101106:	74 4e                	je     c0101156 <cga_putc+0x70>
c0101108:	83 f8 0d             	cmp    $0xd,%eax
c010110b:	74 59                	je     c0101166 <cga_putc+0x80>
c010110d:	83 f8 08             	cmp    $0x8,%eax
c0101110:	0f 85 8a 00 00 00    	jne    c01011a0 <cga_putc+0xba>
    case '\b':
        if (crt_pos > 0) {
c0101116:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010111d:	66 85 c0             	test   %ax,%ax
c0101120:	0f 84 a0 00 00 00    	je     c01011c6 <cga_putc+0xe0>
            crt_pos --;
c0101126:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010112d:	83 e8 01             	sub    $0x1,%eax
c0101130:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101136:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010113b:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c0101142:	0f b7 d2             	movzwl %dx,%edx
c0101145:	01 d2                	add    %edx,%edx
c0101147:	01 d0                	add    %edx,%eax
c0101149:	8b 55 08             	mov    0x8(%ebp),%edx
c010114c:	b2 00                	mov    $0x0,%dl
c010114e:	83 ca 20             	or     $0x20,%edx
c0101151:	66 89 10             	mov    %dx,(%eax)
        }
        break;
c0101154:	eb 70                	jmp    c01011c6 <cga_putc+0xe0>
    case '\n':
        crt_pos += CRT_COLS;
c0101156:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010115d:	83 c0 50             	add    $0x50,%eax
c0101160:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101166:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c010116d:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101174:	0f b7 c1             	movzwl %cx,%eax
c0101177:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010117d:	c1 e8 10             	shr    $0x10,%eax
c0101180:	89 c2                	mov    %eax,%edx
c0101182:	66 c1 ea 06          	shr    $0x6,%dx
c0101186:	89 d0                	mov    %edx,%eax
c0101188:	c1 e0 02             	shl    $0x2,%eax
c010118b:	01 d0                	add    %edx,%eax
c010118d:	c1 e0 04             	shl    $0x4,%eax
c0101190:	29 c1                	sub    %eax,%ecx
c0101192:	89 ca                	mov    %ecx,%edx
c0101194:	89 d8                	mov    %ebx,%eax
c0101196:	29 d0                	sub    %edx,%eax
c0101198:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c010119e:	eb 27                	jmp    c01011c7 <cga_putc+0xe1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011a0:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011a6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ad:	8d 50 01             	lea    0x1(%eax),%edx
c01011b0:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011b7:	0f b7 c0             	movzwl %ax,%eax
c01011ba:	01 c0                	add    %eax,%eax
c01011bc:	01 c8                	add    %ecx,%eax
c01011be:	8b 55 08             	mov    0x8(%ebp),%edx
c01011c1:	66 89 10             	mov    %dx,(%eax)
        break;
c01011c4:	eb 01                	jmp    c01011c7 <cga_putc+0xe1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c01011c6:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011c7:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ce:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011d2:	76 59                	jbe    c010122d <cga_putc+0x147>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011d4:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011d9:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011df:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011e4:	83 ec 04             	sub    $0x4,%esp
c01011e7:	68 00 0f 00 00       	push   $0xf00
c01011ec:	52                   	push   %edx
c01011ed:	50                   	push   %eax
c01011ee:	e8 26 41 00 00       	call   c0105319 <memmove>
c01011f3:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01011f6:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01011fd:	eb 15                	jmp    c0101214 <cga_putc+0x12e>
            crt_buf[i] = 0x0700 | ' ';
c01011ff:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101204:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101207:	01 d2                	add    %edx,%edx
c0101209:	01 d0                	add    %edx,%eax
c010120b:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101210:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101214:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010121b:	7e e2                	jle    c01011ff <cga_putc+0x119>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010121d:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101224:	83 e8 50             	sub    $0x50,%eax
c0101227:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010122d:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101234:	0f b7 c0             	movzwl %ax,%eax
c0101237:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010123b:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c010123f:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c0101243:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101247:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101248:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010124f:	66 c1 e8 08          	shr    $0x8,%ax
c0101253:	0f b6 c0             	movzbl %al,%eax
c0101256:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c010125d:	83 c2 01             	add    $0x1,%edx
c0101260:	0f b7 d2             	movzwl %dx,%edx
c0101263:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0101267:	88 45 e9             	mov    %al,-0x17(%ebp)
c010126a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010126e:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0101272:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101273:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010127a:	0f b7 c0             	movzwl %ax,%eax
c010127d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101281:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c0101285:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101289:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010128d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c010128e:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101295:	0f b6 c0             	movzbl %al,%eax
c0101298:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c010129f:	83 c2 01             	add    $0x1,%edx
c01012a2:	0f b7 d2             	movzwl %dx,%edx
c01012a5:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c01012a9:	88 45 eb             	mov    %al,-0x15(%ebp)
c01012ac:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c01012b0:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c01012b4:	ee                   	out    %al,(%dx)
}
c01012b5:	90                   	nop
c01012b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01012b9:	c9                   	leave  
c01012ba:	c3                   	ret    

c01012bb <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012bb:	55                   	push   %ebp
c01012bc:	89 e5                	mov    %esp,%ebp
c01012be:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012c8:	eb 09                	jmp    c01012d3 <serial_putc_sub+0x18>
        delay();
c01012ca:	e8 51 fb ff ff       	call   c0100e20 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012cf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012d3:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012d9:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c01012dd:	89 c2                	mov    %eax,%edx
c01012df:	ec                   	in     (%dx),%al
c01012e0:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01012e3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01012e7:	0f b6 c0             	movzbl %al,%eax
c01012ea:	83 e0 20             	and    $0x20,%eax
c01012ed:	85 c0                	test   %eax,%eax
c01012ef:	75 09                	jne    c01012fa <serial_putc_sub+0x3f>
c01012f1:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01012f8:	7e d0                	jle    c01012ca <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c01012fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01012fd:	0f b6 c0             	movzbl %al,%eax
c0101300:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0101306:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101309:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c010130d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101311:	ee                   	out    %al,(%dx)
}
c0101312:	90                   	nop
c0101313:	c9                   	leave  
c0101314:	c3                   	ret    

c0101315 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101315:	55                   	push   %ebp
c0101316:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0101318:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010131c:	74 0d                	je     c010132b <serial_putc+0x16>
        serial_putc_sub(c);
c010131e:	ff 75 08             	pushl  0x8(%ebp)
c0101321:	e8 95 ff ff ff       	call   c01012bb <serial_putc_sub>
c0101326:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101329:	eb 1e                	jmp    c0101349 <serial_putc+0x34>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c010132b:	6a 08                	push   $0x8
c010132d:	e8 89 ff ff ff       	call   c01012bb <serial_putc_sub>
c0101332:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
c0101335:	6a 20                	push   $0x20
c0101337:	e8 7f ff ff ff       	call   c01012bb <serial_putc_sub>
c010133c:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
c010133f:	6a 08                	push   $0x8
c0101341:	e8 75 ff ff ff       	call   c01012bb <serial_putc_sub>
c0101346:	83 c4 04             	add    $0x4,%esp
    }
}
c0101349:	90                   	nop
c010134a:	c9                   	leave  
c010134b:	c3                   	ret    

c010134c <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010134c:	55                   	push   %ebp
c010134d:	89 e5                	mov    %esp,%ebp
c010134f:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101352:	eb 33                	jmp    c0101387 <cons_intr+0x3b>
        if (c != 0) {
c0101354:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101358:	74 2d                	je     c0101387 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010135a:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010135f:	8d 50 01             	lea    0x1(%eax),%edx
c0101362:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c0101368:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010136b:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101371:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101376:	3d 00 02 00 00       	cmp    $0x200,%eax
c010137b:	75 0a                	jne    c0101387 <cons_intr+0x3b>
                cons.wpos = 0;
c010137d:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c0101384:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101387:	8b 45 08             	mov    0x8(%ebp),%eax
c010138a:	ff d0                	call   *%eax
c010138c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010138f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101393:	75 bf                	jne    c0101354 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101395:	90                   	nop
c0101396:	c9                   	leave  
c0101397:	c3                   	ret    

c0101398 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101398:	55                   	push   %ebp
c0101399:	89 e5                	mov    %esp,%ebp
c010139b:	83 ec 10             	sub    $0x10,%esp
c010139e:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013a4:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c01013a8:	89 c2                	mov    %eax,%edx
c01013aa:	ec                   	in     (%dx),%al
c01013ab:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01013ae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013b2:	0f b6 c0             	movzbl %al,%eax
c01013b5:	83 e0 01             	and    $0x1,%eax
c01013b8:	85 c0                	test   %eax,%eax
c01013ba:	75 07                	jne    c01013c3 <serial_proc_data+0x2b>
        return -1;
c01013bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013c1:	eb 2a                	jmp    c01013ed <serial_proc_data+0x55>
c01013c3:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013c9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013cd:	89 c2                	mov    %eax,%edx
c01013cf:	ec                   	in     (%dx),%al
c01013d0:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c01013d3:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013d7:	0f b6 c0             	movzbl %al,%eax
c01013da:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01013dd:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01013e1:	75 07                	jne    c01013ea <serial_proc_data+0x52>
        c = '\b';
c01013e3:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01013ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01013ed:	c9                   	leave  
c01013ee:	c3                   	ret    

c01013ef <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01013ef:	55                   	push   %ebp
c01013f0:	89 e5                	mov    %esp,%ebp
c01013f2:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
c01013f5:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c01013fa:	85 c0                	test   %eax,%eax
c01013fc:	74 10                	je     c010140e <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c01013fe:	83 ec 0c             	sub    $0xc,%esp
c0101401:	68 98 13 10 c0       	push   $0xc0101398
c0101406:	e8 41 ff ff ff       	call   c010134c <cons_intr>
c010140b:	83 c4 10             	add    $0x10,%esp
    }
}
c010140e:	90                   	nop
c010140f:	c9                   	leave  
c0101410:	c3                   	ret    

c0101411 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101411:	55                   	push   %ebp
c0101412:	89 e5                	mov    %esp,%ebp
c0101414:	83 ec 18             	sub    $0x18,%esp
c0101417:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010141d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101421:	89 c2                	mov    %eax,%edx
c0101423:	ec                   	in     (%dx),%al
c0101424:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101427:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010142b:	0f b6 c0             	movzbl %al,%eax
c010142e:	83 e0 01             	and    $0x1,%eax
c0101431:	85 c0                	test   %eax,%eax
c0101433:	75 0a                	jne    c010143f <kbd_proc_data+0x2e>
        return -1;
c0101435:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010143a:	e9 5d 01 00 00       	jmp    c010159c <kbd_proc_data+0x18b>
c010143f:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101445:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101449:	89 c2                	mov    %eax,%edx
c010144b:	ec                   	in     (%dx),%al
c010144c:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c010144f:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101453:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101456:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010145a:	75 17                	jne    c0101473 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010145c:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101461:	83 c8 40             	or     $0x40,%eax
c0101464:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c0101469:	b8 00 00 00 00       	mov    $0x0,%eax
c010146e:	e9 29 01 00 00       	jmp    c010159c <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
c0101473:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101477:	84 c0                	test   %al,%al
c0101479:	79 47                	jns    c01014c2 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010147b:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101480:	83 e0 40             	and    $0x40,%eax
c0101483:	85 c0                	test   %eax,%eax
c0101485:	75 09                	jne    c0101490 <kbd_proc_data+0x7f>
c0101487:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010148b:	83 e0 7f             	and    $0x7f,%eax
c010148e:	eb 04                	jmp    c0101494 <kbd_proc_data+0x83>
c0101490:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101494:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101497:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010149b:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014a2:	83 c8 40             	or     $0x40,%eax
c01014a5:	0f b6 c0             	movzbl %al,%eax
c01014a8:	f7 d0                	not    %eax
c01014aa:	89 c2                	mov    %eax,%edx
c01014ac:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014b1:	21 d0                	and    %edx,%eax
c01014b3:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014b8:	b8 00 00 00 00       	mov    $0x0,%eax
c01014bd:	e9 da 00 00 00       	jmp    c010159c <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
c01014c2:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014c7:	83 e0 40             	and    $0x40,%eax
c01014ca:	85 c0                	test   %eax,%eax
c01014cc:	74 11                	je     c01014df <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014ce:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014d2:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014d7:	83 e0 bf             	and    $0xffffffbf,%eax
c01014da:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c01014df:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014e3:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014ea:	0f b6 d0             	movzbl %al,%edx
c01014ed:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f2:	09 d0                	or     %edx,%eax
c01014f4:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c01014f9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014fd:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101504:	0f b6 d0             	movzbl %al,%edx
c0101507:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010150c:	31 d0                	xor    %edx,%eax
c010150e:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101513:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101518:	83 e0 03             	and    $0x3,%eax
c010151b:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101522:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101526:	01 d0                	add    %edx,%eax
c0101528:	0f b6 00             	movzbl (%eax),%eax
c010152b:	0f b6 c0             	movzbl %al,%eax
c010152e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101531:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101536:	83 e0 08             	and    $0x8,%eax
c0101539:	85 c0                	test   %eax,%eax
c010153b:	74 22                	je     c010155f <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010153d:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101541:	7e 0c                	jle    c010154f <kbd_proc_data+0x13e>
c0101543:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101547:	7f 06                	jg     c010154f <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101549:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010154d:	eb 10                	jmp    c010155f <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010154f:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101553:	7e 0a                	jle    c010155f <kbd_proc_data+0x14e>
c0101555:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101559:	7f 04                	jg     c010155f <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010155b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010155f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101564:	f7 d0                	not    %eax
c0101566:	83 e0 06             	and    $0x6,%eax
c0101569:	85 c0                	test   %eax,%eax
c010156b:	75 2c                	jne    c0101599 <kbd_proc_data+0x188>
c010156d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101574:	75 23                	jne    c0101599 <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
c0101576:	83 ec 0c             	sub    $0xc,%esp
c0101579:	68 c9 5d 10 c0       	push   $0xc0105dc9
c010157e:	e8 f0 ec ff ff       	call   c0100273 <cprintf>
c0101583:	83 c4 10             	add    $0x10,%esp
c0101586:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c010158c:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101590:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101594:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101598:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101599:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010159c:	c9                   	leave  
c010159d:	c3                   	ret    

c010159e <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010159e:	55                   	push   %ebp
c010159f:	89 e5                	mov    %esp,%ebp
c01015a1:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
c01015a4:	83 ec 0c             	sub    $0xc,%esp
c01015a7:	68 11 14 10 c0       	push   $0xc0101411
c01015ac:	e8 9b fd ff ff       	call   c010134c <cons_intr>
c01015b1:	83 c4 10             	add    $0x10,%esp
}
c01015b4:	90                   	nop
c01015b5:	c9                   	leave  
c01015b6:	c3                   	ret    

c01015b7 <kbd_init>:

static void
kbd_init(void) {
c01015b7:	55                   	push   %ebp
c01015b8:	89 e5                	mov    %esp,%ebp
c01015ba:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
c01015bd:	e8 dc ff ff ff       	call   c010159e <kbd_intr>
    pic_enable(IRQ_KBD);
c01015c2:	83 ec 0c             	sub    $0xc,%esp
c01015c5:	6a 01                	push   $0x1
c01015c7:	e8 4b 01 00 00       	call   c0101717 <pic_enable>
c01015cc:	83 c4 10             	add    $0x10,%esp
}
c01015cf:	90                   	nop
c01015d0:	c9                   	leave  
c01015d1:	c3                   	ret    

c01015d2 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015d2:	55                   	push   %ebp
c01015d3:	89 e5                	mov    %esp,%ebp
c01015d5:	83 ec 08             	sub    $0x8,%esp
    cga_init();
c01015d8:	e8 8c f8 ff ff       	call   c0100e69 <cga_init>
    serial_init();
c01015dd:	e8 6e f9 ff ff       	call   c0100f50 <serial_init>
    kbd_init();
c01015e2:	e8 d0 ff ff ff       	call   c01015b7 <kbd_init>
    if (!serial_exists) {
c01015e7:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c01015ec:	85 c0                	test   %eax,%eax
c01015ee:	75 10                	jne    c0101600 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c01015f0:	83 ec 0c             	sub    $0xc,%esp
c01015f3:	68 d5 5d 10 c0       	push   $0xc0105dd5
c01015f8:	e8 76 ec ff ff       	call   c0100273 <cprintf>
c01015fd:	83 c4 10             	add    $0x10,%esp
    }
}
c0101600:	90                   	nop
c0101601:	c9                   	leave  
c0101602:	c3                   	ret    

c0101603 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101603:	55                   	push   %ebp
c0101604:	89 e5                	mov    %esp,%ebp
c0101606:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101609:	e8 d4 f7 ff ff       	call   c0100de2 <__intr_save>
c010160e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101611:	83 ec 0c             	sub    $0xc,%esp
c0101614:	ff 75 08             	pushl  0x8(%ebp)
c0101617:	e8 93 fa ff ff       	call   c01010af <lpt_putc>
c010161c:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
c010161f:	83 ec 0c             	sub    $0xc,%esp
c0101622:	ff 75 08             	pushl  0x8(%ebp)
c0101625:	e8 bc fa ff ff       	call   c01010e6 <cga_putc>
c010162a:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
c010162d:	83 ec 0c             	sub    $0xc,%esp
c0101630:	ff 75 08             	pushl  0x8(%ebp)
c0101633:	e8 dd fc ff ff       	call   c0101315 <serial_putc>
c0101638:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c010163b:	83 ec 0c             	sub    $0xc,%esp
c010163e:	ff 75 f4             	pushl  -0xc(%ebp)
c0101641:	e8 c6 f7 ff ff       	call   c0100e0c <__intr_restore>
c0101646:	83 c4 10             	add    $0x10,%esp
}
c0101649:	90                   	nop
c010164a:	c9                   	leave  
c010164b:	c3                   	ret    

c010164c <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010164c:	55                   	push   %ebp
c010164d:	89 e5                	mov    %esp,%ebp
c010164f:	83 ec 18             	sub    $0x18,%esp
    int c = 0;
c0101652:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101659:	e8 84 f7 ff ff       	call   c0100de2 <__intr_save>
c010165e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101661:	e8 89 fd ff ff       	call   c01013ef <serial_intr>
        kbd_intr();
c0101666:	e8 33 ff ff ff       	call   c010159e <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010166b:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101671:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101676:	39 c2                	cmp    %eax,%edx
c0101678:	74 31                	je     c01016ab <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010167a:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010167f:	8d 50 01             	lea    0x1(%eax),%edx
c0101682:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c0101688:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c010168f:	0f b6 c0             	movzbl %al,%eax
c0101692:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101695:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010169a:	3d 00 02 00 00       	cmp    $0x200,%eax
c010169f:	75 0a                	jne    c01016ab <cons_getc+0x5f>
                cons.rpos = 0;
c01016a1:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016a8:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016ab:	83 ec 0c             	sub    $0xc,%esp
c01016ae:	ff 75 f0             	pushl  -0x10(%ebp)
c01016b1:	e8 56 f7 ff ff       	call   c0100e0c <__intr_restore>
c01016b6:	83 c4 10             	add    $0x10,%esp
    return c;
c01016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016bc:	c9                   	leave  
c01016bd:	c3                   	ret    

c01016be <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016be:	55                   	push   %ebp
c01016bf:	89 e5                	mov    %esp,%ebp
c01016c1:	83 ec 14             	sub    $0x14,%esp
c01016c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01016c7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016cb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016cf:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016d5:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016da:	85 c0                	test   %eax,%eax
c01016dc:	74 36                	je     c0101714 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016de:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016e2:	0f b6 c0             	movzbl %al,%eax
c01016e5:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016eb:	88 45 fa             	mov    %al,-0x6(%ebp)
c01016ee:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c01016f2:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01016f6:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01016f7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016fb:	66 c1 e8 08          	shr    $0x8,%ax
c01016ff:	0f b6 c0             	movzbl %al,%eax
c0101702:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101708:	88 45 fb             	mov    %al,-0x5(%ebp)
c010170b:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c010170f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101713:	ee                   	out    %al,(%dx)
    }
}
c0101714:	90                   	nop
c0101715:	c9                   	leave  
c0101716:	c3                   	ret    

c0101717 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101717:	55                   	push   %ebp
c0101718:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
c010171a:	8b 45 08             	mov    0x8(%ebp),%eax
c010171d:	ba 01 00 00 00       	mov    $0x1,%edx
c0101722:	89 c1                	mov    %eax,%ecx
c0101724:	d3 e2                	shl    %cl,%edx
c0101726:	89 d0                	mov    %edx,%eax
c0101728:	f7 d0                	not    %eax
c010172a:	89 c2                	mov    %eax,%edx
c010172c:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101733:	21 d0                	and    %edx,%eax
c0101735:	0f b7 c0             	movzwl %ax,%eax
c0101738:	50                   	push   %eax
c0101739:	e8 80 ff ff ff       	call   c01016be <pic_setmask>
c010173e:	83 c4 04             	add    $0x4,%esp
}
c0101741:	90                   	nop
c0101742:	c9                   	leave  
c0101743:	c3                   	ret    

c0101744 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101744:	55                   	push   %ebp
c0101745:	89 e5                	mov    %esp,%ebp
c0101747:	83 ec 30             	sub    $0x30,%esp
    did_init = 1;
c010174a:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c0101751:	00 00 00 
c0101754:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010175a:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c010175e:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c0101762:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101766:	ee                   	out    %al,(%dx)
c0101767:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c010176d:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c0101771:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101775:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101779:	ee                   	out    %al,(%dx)
c010177a:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c0101780:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c0101784:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101788:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010178c:	ee                   	out    %al,(%dx)
c010178d:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c0101793:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0101797:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010179b:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c010179f:	ee                   	out    %al,(%dx)
c01017a0:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c01017a6:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c01017aa:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01017ae:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017b2:	ee                   	out    %al,(%dx)
c01017b3:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c01017b9:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c01017bd:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01017c1:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c01017c5:	ee                   	out    %al,(%dx)
c01017c6:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c01017cc:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c01017d0:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c01017d4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017d8:	ee                   	out    %al,(%dx)
c01017d9:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c01017df:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c01017e3:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017e7:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c01017eb:	ee                   	out    %al,(%dx)
c01017ec:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01017f2:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c01017f6:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c01017fa:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017fe:	ee                   	out    %al,(%dx)
c01017ff:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c0101805:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c0101809:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c010180d:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0101811:	ee                   	out    %al,(%dx)
c0101812:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c0101818:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c010181c:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101820:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101824:	ee                   	out    %al,(%dx)
c0101825:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c010182b:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c010182f:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101833:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101837:	ee                   	out    %al,(%dx)
c0101838:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c010183e:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c0101842:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c0101846:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010184a:	ee                   	out    %al,(%dx)
c010184b:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c0101851:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c0101855:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c0101859:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c010185d:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010185e:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101865:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101869:	74 13                	je     c010187e <pic_init+0x13a>
        pic_setmask(irq_mask);
c010186b:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101872:	0f b7 c0             	movzwl %ax,%eax
c0101875:	50                   	push   %eax
c0101876:	e8 43 fe ff ff       	call   c01016be <pic_setmask>
c010187b:	83 c4 04             	add    $0x4,%esp
    }
}
c010187e:	90                   	nop
c010187f:	c9                   	leave  
c0101880:	c3                   	ret    

c0101881 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101881:	55                   	push   %ebp
c0101882:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101884:	fb                   	sti    
    sti();
}
c0101885:	90                   	nop
c0101886:	5d                   	pop    %ebp
c0101887:	c3                   	ret    

c0101888 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101888:	55                   	push   %ebp
c0101889:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c010188b:	fa                   	cli    
    cli();
}
c010188c:	90                   	nop
c010188d:	5d                   	pop    %ebp
c010188e:	c3                   	ret    

c010188f <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010188f:	55                   	push   %ebp
c0101890:	89 e5                	mov    %esp,%ebp
c0101892:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101895:	83 ec 08             	sub    $0x8,%esp
c0101898:	6a 64                	push   $0x64
c010189a:	68 00 5e 10 c0       	push   $0xc0105e00
c010189f:	e8 cf e9 ff ff       	call   c0100273 <cprintf>
c01018a4:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01018a7:	90                   	nop
c01018a8:	c9                   	leave  
c01018a9:	c3                   	ret    

c01018aa <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018aa:	55                   	push   %ebp
c01018ab:	89 e5                	mov    %esp,%ebp
c01018ad:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) {
c01018b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018b7:	e9 c3 00 00 00       	jmp    c010197f <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018bf:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018c6:	89 c2                	mov    %eax,%edx
c01018c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018cb:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018d2:	c0 
c01018d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d6:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c01018dd:	c0 08 00 
c01018e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e3:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018ea:	c0 
c01018eb:	83 e2 e0             	and    $0xffffffe0,%edx
c01018ee:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c01018f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f8:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018ff:	c0 
c0101900:	83 e2 1f             	and    $0x1f,%edx
c0101903:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c010190a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010190d:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101914:	c0 
c0101915:	83 e2 f0             	and    $0xfffffff0,%edx
c0101918:	83 ca 0e             	or     $0xe,%edx
c010191b:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101922:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101925:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010192c:	c0 
c010192d:	83 e2 ef             	and    $0xffffffef,%edx
c0101930:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101937:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010193a:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101941:	c0 
c0101942:	83 e2 9f             	and    $0xffffff9f,%edx
c0101945:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010194c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010194f:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101956:	c0 
c0101957:	83 ca 80             	or     $0xffffff80,%edx
c010195a:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101961:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101964:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c010196b:	c1 e8 10             	shr    $0x10,%eax
c010196e:	89 c2                	mov    %eax,%edx
c0101970:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101973:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c010197a:	c0 
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) {
c010197b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010197f:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c0101986:	0f 8e 30 ff ff ff    	jle    c01018bc <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c010198c:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c0101991:	66 a3 48 aa 11 c0    	mov    %ax,0xc011aa48
c0101997:	66 c7 05 4a aa 11 c0 	movw   $0x8,0xc011aa4a
c010199e:	08 00 
c01019a0:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019a7:	83 e0 e0             	and    $0xffffffe0,%eax
c01019aa:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019af:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019b6:	83 e0 1f             	and    $0x1f,%eax
c01019b9:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019be:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019c5:	83 e0 f0             	and    $0xfffffff0,%eax
c01019c8:	83 c8 0e             	or     $0xe,%eax
c01019cb:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019d0:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019d7:	83 e0 ef             	and    $0xffffffef,%eax
c01019da:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019df:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019e6:	83 c8 60             	or     $0x60,%eax
c01019e9:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019ee:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019f5:	83 c8 80             	or     $0xffffff80,%eax
c01019f8:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019fd:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c0101a02:	c1 e8 10             	shr    $0x10,%eax
c0101a05:	66 a3 4e aa 11 c0    	mov    %ax,0xc011aa4e
c0101a0b:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a12:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a15:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c0101a18:	90                   	nop
c0101a19:	c9                   	leave  
c0101a1a:	c3                   	ret    

c0101a1b <trapname>:

static const char *
trapname(int trapno) {
c0101a1b:	55                   	push   %ebp
c0101a1c:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a21:	83 f8 13             	cmp    $0x13,%eax
c0101a24:	77 0c                	ja     c0101a32 <trapname+0x17>
        return excnames[trapno];
c0101a26:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a29:	8b 04 85 60 61 10 c0 	mov    -0x3fef9ea0(,%eax,4),%eax
c0101a30:	eb 18                	jmp    c0101a4a <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a32:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a36:	7e 0d                	jle    c0101a45 <trapname+0x2a>
c0101a38:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a3c:	7f 07                	jg     c0101a45 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a3e:	b8 0a 5e 10 c0       	mov    $0xc0105e0a,%eax
c0101a43:	eb 05                	jmp    c0101a4a <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a45:	b8 1d 5e 10 c0       	mov    $0xc0105e1d,%eax
}
c0101a4a:	5d                   	pop    %ebp
c0101a4b:	c3                   	ret    

c0101a4c <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a4c:	55                   	push   %ebp
c0101a4d:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a52:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a56:	66 83 f8 08          	cmp    $0x8,%ax
c0101a5a:	0f 94 c0             	sete   %al
c0101a5d:	0f b6 c0             	movzbl %al,%eax
}
c0101a60:	5d                   	pop    %ebp
c0101a61:	c3                   	ret    

c0101a62 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a62:	55                   	push   %ebp
c0101a63:	89 e5                	mov    %esp,%ebp
c0101a65:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
c0101a68:	83 ec 08             	sub    $0x8,%esp
c0101a6b:	ff 75 08             	pushl  0x8(%ebp)
c0101a6e:	68 5e 5e 10 c0       	push   $0xc0105e5e
c0101a73:	e8 fb e7 ff ff       	call   c0100273 <cprintf>
c0101a78:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
c0101a7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7e:	83 ec 0c             	sub    $0xc,%esp
c0101a81:	50                   	push   %eax
c0101a82:	e8 b8 01 00 00       	call   c0101c3f <print_regs>
c0101a87:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a8d:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a91:	0f b7 c0             	movzwl %ax,%eax
c0101a94:	83 ec 08             	sub    $0x8,%esp
c0101a97:	50                   	push   %eax
c0101a98:	68 6f 5e 10 c0       	push   $0xc0105e6f
c0101a9d:	e8 d1 e7 ff ff       	call   c0100273 <cprintf>
c0101aa2:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa8:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101aac:	0f b7 c0             	movzwl %ax,%eax
c0101aaf:	83 ec 08             	sub    $0x8,%esp
c0101ab2:	50                   	push   %eax
c0101ab3:	68 82 5e 10 c0       	push   $0xc0105e82
c0101ab8:	e8 b6 e7 ff ff       	call   c0100273 <cprintf>
c0101abd:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101ac0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac3:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101ac7:	0f b7 c0             	movzwl %ax,%eax
c0101aca:	83 ec 08             	sub    $0x8,%esp
c0101acd:	50                   	push   %eax
c0101ace:	68 95 5e 10 c0       	push   $0xc0105e95
c0101ad3:	e8 9b e7 ff ff       	call   c0100273 <cprintf>
c0101ad8:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101adb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ade:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101ae2:	0f b7 c0             	movzwl %ax,%eax
c0101ae5:	83 ec 08             	sub    $0x8,%esp
c0101ae8:	50                   	push   %eax
c0101ae9:	68 a8 5e 10 c0       	push   $0xc0105ea8
c0101aee:	e8 80 e7 ff ff       	call   c0100273 <cprintf>
c0101af3:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101af6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af9:	8b 40 30             	mov    0x30(%eax),%eax
c0101afc:	83 ec 0c             	sub    $0xc,%esp
c0101aff:	50                   	push   %eax
c0101b00:	e8 16 ff ff ff       	call   c0101a1b <trapname>
c0101b05:	83 c4 10             	add    $0x10,%esp
c0101b08:	89 c2                	mov    %eax,%edx
c0101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b0d:	8b 40 30             	mov    0x30(%eax),%eax
c0101b10:	83 ec 04             	sub    $0x4,%esp
c0101b13:	52                   	push   %edx
c0101b14:	50                   	push   %eax
c0101b15:	68 bb 5e 10 c0       	push   $0xc0105ebb
c0101b1a:	e8 54 e7 ff ff       	call   c0100273 <cprintf>
c0101b1f:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b22:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b25:	8b 40 34             	mov    0x34(%eax),%eax
c0101b28:	83 ec 08             	sub    $0x8,%esp
c0101b2b:	50                   	push   %eax
c0101b2c:	68 cd 5e 10 c0       	push   $0xc0105ecd
c0101b31:	e8 3d e7 ff ff       	call   c0100273 <cprintf>
c0101b36:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b39:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b3c:	8b 40 38             	mov    0x38(%eax),%eax
c0101b3f:	83 ec 08             	sub    $0x8,%esp
c0101b42:	50                   	push   %eax
c0101b43:	68 dc 5e 10 c0       	push   $0xc0105edc
c0101b48:	e8 26 e7 ff ff       	call   c0100273 <cprintf>
c0101b4d:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b50:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b53:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b57:	0f b7 c0             	movzwl %ax,%eax
c0101b5a:	83 ec 08             	sub    $0x8,%esp
c0101b5d:	50                   	push   %eax
c0101b5e:	68 eb 5e 10 c0       	push   $0xc0105eeb
c0101b63:	e8 0b e7 ff ff       	call   c0100273 <cprintf>
c0101b68:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6e:	8b 40 40             	mov    0x40(%eax),%eax
c0101b71:	83 ec 08             	sub    $0x8,%esp
c0101b74:	50                   	push   %eax
c0101b75:	68 fe 5e 10 c0       	push   $0xc0105efe
c0101b7a:	e8 f4 e6 ff ff       	call   c0100273 <cprintf>
c0101b7f:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b89:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b90:	eb 3f                	jmp    c0101bd1 <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b92:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b95:	8b 50 40             	mov    0x40(%eax),%edx
c0101b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b9b:	21 d0                	and    %edx,%eax
c0101b9d:	85 c0                	test   %eax,%eax
c0101b9f:	74 29                	je     c0101bca <print_trapframe+0x168>
c0101ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ba4:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101bab:	85 c0                	test   %eax,%eax
c0101bad:	74 1b                	je     c0101bca <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
c0101baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bb2:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101bb9:	83 ec 08             	sub    $0x8,%esp
c0101bbc:	50                   	push   %eax
c0101bbd:	68 0d 5f 10 c0       	push   $0xc0105f0d
c0101bc2:	e8 ac e6 ff ff       	call   c0100273 <cprintf>
c0101bc7:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101bce:	d1 65 f0             	shll   -0x10(%ebp)
c0101bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bd4:	83 f8 17             	cmp    $0x17,%eax
c0101bd7:	76 b9                	jbe    c0101b92 <print_trapframe+0x130>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bdc:	8b 40 40             	mov    0x40(%eax),%eax
c0101bdf:	25 00 30 00 00       	and    $0x3000,%eax
c0101be4:	c1 e8 0c             	shr    $0xc,%eax
c0101be7:	83 ec 08             	sub    $0x8,%esp
c0101bea:	50                   	push   %eax
c0101beb:	68 11 5f 10 c0       	push   $0xc0105f11
c0101bf0:	e8 7e e6 ff ff       	call   c0100273 <cprintf>
c0101bf5:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
c0101bf8:	83 ec 0c             	sub    $0xc,%esp
c0101bfb:	ff 75 08             	pushl  0x8(%ebp)
c0101bfe:	e8 49 fe ff ff       	call   c0101a4c <trap_in_kernel>
c0101c03:	83 c4 10             	add    $0x10,%esp
c0101c06:	85 c0                	test   %eax,%eax
c0101c08:	75 32                	jne    c0101c3c <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0d:	8b 40 44             	mov    0x44(%eax),%eax
c0101c10:	83 ec 08             	sub    $0x8,%esp
c0101c13:	50                   	push   %eax
c0101c14:	68 1a 5f 10 c0       	push   $0xc0105f1a
c0101c19:	e8 55 e6 ff ff       	call   c0100273 <cprintf>
c0101c1e:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c21:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c24:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c28:	0f b7 c0             	movzwl %ax,%eax
c0101c2b:	83 ec 08             	sub    $0x8,%esp
c0101c2e:	50                   	push   %eax
c0101c2f:	68 29 5f 10 c0       	push   $0xc0105f29
c0101c34:	e8 3a e6 ff ff       	call   c0100273 <cprintf>
c0101c39:	83 c4 10             	add    $0x10,%esp
    }
}
c0101c3c:	90                   	nop
c0101c3d:	c9                   	leave  
c0101c3e:	c3                   	ret    

c0101c3f <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c3f:	55                   	push   %ebp
c0101c40:	89 e5                	mov    %esp,%ebp
c0101c42:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c48:	8b 00                	mov    (%eax),%eax
c0101c4a:	83 ec 08             	sub    $0x8,%esp
c0101c4d:	50                   	push   %eax
c0101c4e:	68 3c 5f 10 c0       	push   $0xc0105f3c
c0101c53:	e8 1b e6 ff ff       	call   c0100273 <cprintf>
c0101c58:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5e:	8b 40 04             	mov    0x4(%eax),%eax
c0101c61:	83 ec 08             	sub    $0x8,%esp
c0101c64:	50                   	push   %eax
c0101c65:	68 4b 5f 10 c0       	push   $0xc0105f4b
c0101c6a:	e8 04 e6 ff ff       	call   c0100273 <cprintf>
c0101c6f:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c72:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c75:	8b 40 08             	mov    0x8(%eax),%eax
c0101c78:	83 ec 08             	sub    $0x8,%esp
c0101c7b:	50                   	push   %eax
c0101c7c:	68 5a 5f 10 c0       	push   $0xc0105f5a
c0101c81:	e8 ed e5 ff ff       	call   c0100273 <cprintf>
c0101c86:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c89:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c8c:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c8f:	83 ec 08             	sub    $0x8,%esp
c0101c92:	50                   	push   %eax
c0101c93:	68 69 5f 10 c0       	push   $0xc0105f69
c0101c98:	e8 d6 e5 ff ff       	call   c0100273 <cprintf>
c0101c9d:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ca3:	8b 40 10             	mov    0x10(%eax),%eax
c0101ca6:	83 ec 08             	sub    $0x8,%esp
c0101ca9:	50                   	push   %eax
c0101caa:	68 78 5f 10 c0       	push   $0xc0105f78
c0101caf:	e8 bf e5 ff ff       	call   c0100273 <cprintf>
c0101cb4:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101cb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cba:	8b 40 14             	mov    0x14(%eax),%eax
c0101cbd:	83 ec 08             	sub    $0x8,%esp
c0101cc0:	50                   	push   %eax
c0101cc1:	68 87 5f 10 c0       	push   $0xc0105f87
c0101cc6:	e8 a8 e5 ff ff       	call   c0100273 <cprintf>
c0101ccb:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101cce:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd1:	8b 40 18             	mov    0x18(%eax),%eax
c0101cd4:	83 ec 08             	sub    $0x8,%esp
c0101cd7:	50                   	push   %eax
c0101cd8:	68 96 5f 10 c0       	push   $0xc0105f96
c0101cdd:	e8 91 e5 ff ff       	call   c0100273 <cprintf>
c0101ce2:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101ce5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ce8:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101ceb:	83 ec 08             	sub    $0x8,%esp
c0101cee:	50                   	push   %eax
c0101cef:	68 a5 5f 10 c0       	push   $0xc0105fa5
c0101cf4:	e8 7a e5 ff ff       	call   c0100273 <cprintf>
c0101cf9:	83 c4 10             	add    $0x10,%esp
}
c0101cfc:	90                   	nop
c0101cfd:	c9                   	leave  
c0101cfe:	c3                   	ret    

c0101cff <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101cff:	55                   	push   %ebp
c0101d00:	89 e5                	mov    %esp,%ebp
c0101d02:	83 ec 18             	sub    $0x18,%esp
    char c;

    switch (tf->tf_trapno) {
c0101d05:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d08:	8b 40 30             	mov    0x30(%eax),%eax
c0101d0b:	83 f8 2f             	cmp    $0x2f,%eax
c0101d0e:	77 1d                	ja     c0101d2d <trap_dispatch+0x2e>
c0101d10:	83 f8 2e             	cmp    $0x2e,%eax
c0101d13:	0f 83 e9 00 00 00    	jae    c0101e02 <trap_dispatch+0x103>
c0101d19:	83 f8 21             	cmp    $0x21,%eax
c0101d1c:	74 73                	je     c0101d91 <trap_dispatch+0x92>
c0101d1e:	83 f8 24             	cmp    $0x24,%eax
c0101d21:	74 4a                	je     c0101d6d <trap_dispatch+0x6e>
c0101d23:	83 f8 20             	cmp    $0x20,%eax
c0101d26:	74 13                	je     c0101d3b <trap_dispatch+0x3c>
c0101d28:	e9 9f 00 00 00       	jmp    c0101dcc <trap_dispatch+0xcd>
c0101d2d:	83 e8 78             	sub    $0x78,%eax
c0101d30:	83 f8 01             	cmp    $0x1,%eax
c0101d33:	0f 87 93 00 00 00    	ja     c0101dcc <trap_dispatch+0xcd>
c0101d39:	eb 7a                	jmp    c0101db5 <trap_dispatch+0xb6>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
c0101d3b:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d40:	83 c0 01             	add    $0x1,%eax
c0101d43:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
        if (ticks == TICK_NUM) {
c0101d48:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d4d:	83 f8 64             	cmp    $0x64,%eax
c0101d50:	0f 85 af 00 00 00    	jne    c0101e05 <trap_dispatch+0x106>
            ticks -= TICK_NUM;
c0101d56:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d5b:	83 e8 64             	sub    $0x64,%eax
c0101d5e:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
            print_ticks();
c0101d63:	e8 27 fb ff ff       	call   c010188f <print_ticks>
        }
        break;
c0101d68:	e9 98 00 00 00       	jmp    c0101e05 <trap_dispatch+0x106>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d6d:	e8 da f8 ff ff       	call   c010164c <cons_getc>
c0101d72:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d75:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d79:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d7d:	83 ec 04             	sub    $0x4,%esp
c0101d80:	52                   	push   %edx
c0101d81:	50                   	push   %eax
c0101d82:	68 b4 5f 10 c0       	push   $0xc0105fb4
c0101d87:	e8 e7 e4 ff ff       	call   c0100273 <cprintf>
c0101d8c:	83 c4 10             	add    $0x10,%esp
        break;
c0101d8f:	eb 75                	jmp    c0101e06 <trap_dispatch+0x107>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d91:	e8 b6 f8 ff ff       	call   c010164c <cons_getc>
c0101d96:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d99:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d9d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101da1:	83 ec 04             	sub    $0x4,%esp
c0101da4:	52                   	push   %edx
c0101da5:	50                   	push   %eax
c0101da6:	68 c6 5f 10 c0       	push   $0xc0105fc6
c0101dab:	e8 c3 e4 ff ff       	call   c0100273 <cprintf>
c0101db0:	83 c4 10             	add    $0x10,%esp
        break;
c0101db3:	eb 51                	jmp    c0101e06 <trap_dispatch+0x107>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101db5:	83 ec 04             	sub    $0x4,%esp
c0101db8:	68 d5 5f 10 c0       	push   $0xc0105fd5
c0101dbd:	68 ad 00 00 00       	push   $0xad
c0101dc2:	68 e5 5f 10 c0       	push   $0xc0105fe5
c0101dc7:	e8 0d e6 ff ff       	call   c01003d9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dcf:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101dd3:	0f b7 c0             	movzwl %ax,%eax
c0101dd6:	83 e0 03             	and    $0x3,%eax
c0101dd9:	85 c0                	test   %eax,%eax
c0101ddb:	75 29                	jne    c0101e06 <trap_dispatch+0x107>
            print_trapframe(tf);
c0101ddd:	83 ec 0c             	sub    $0xc,%esp
c0101de0:	ff 75 08             	pushl  0x8(%ebp)
c0101de3:	e8 7a fc ff ff       	call   c0101a62 <print_trapframe>
c0101de8:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
c0101deb:	83 ec 04             	sub    $0x4,%esp
c0101dee:	68 f6 5f 10 c0       	push   $0xc0105ff6
c0101df3:	68 b7 00 00 00       	push   $0xb7
c0101df8:	68 e5 5f 10 c0       	push   $0xc0105fe5
c0101dfd:	e8 d7 e5 ff ff       	call   c01003d9 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101e02:	90                   	nop
c0101e03:	eb 01                	jmp    c0101e06 <trap_dispatch+0x107>
        ticks++;
        if (ticks == TICK_NUM) {
            ticks -= TICK_NUM;
            print_ticks();
        }
        break;
c0101e05:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101e06:	90                   	nop
c0101e07:	c9                   	leave  
c0101e08:	c3                   	ret    

c0101e09 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101e09:	55                   	push   %ebp
c0101e0a:	89 e5                	mov    %esp,%ebp
c0101e0c:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101e0f:	83 ec 0c             	sub    $0xc,%esp
c0101e12:	ff 75 08             	pushl  0x8(%ebp)
c0101e15:	e8 e5 fe ff ff       	call   c0101cff <trap_dispatch>
c0101e1a:	83 c4 10             	add    $0x10,%esp
}
c0101e1d:	90                   	nop
c0101e1e:	c9                   	leave  
c0101e1f:	c3                   	ret    

c0101e20 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101e20:	6a 00                	push   $0x0
  pushl $0
c0101e22:	6a 00                	push   $0x0
  jmp __alltraps
c0101e24:	e9 69 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e29 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101e29:	6a 00                	push   $0x0
  pushl $1
c0101e2b:	6a 01                	push   $0x1
  jmp __alltraps
c0101e2d:	e9 60 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e32 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101e32:	6a 00                	push   $0x0
  pushl $2
c0101e34:	6a 02                	push   $0x2
  jmp __alltraps
c0101e36:	e9 57 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e3b <vector3>:
.globl vector3
vector3:
  pushl $0
c0101e3b:	6a 00                	push   $0x0
  pushl $3
c0101e3d:	6a 03                	push   $0x3
  jmp __alltraps
c0101e3f:	e9 4e 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e44 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101e44:	6a 00                	push   $0x0
  pushl $4
c0101e46:	6a 04                	push   $0x4
  jmp __alltraps
c0101e48:	e9 45 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e4d <vector5>:
.globl vector5
vector5:
  pushl $0
c0101e4d:	6a 00                	push   $0x0
  pushl $5
c0101e4f:	6a 05                	push   $0x5
  jmp __alltraps
c0101e51:	e9 3c 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e56 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101e56:	6a 00                	push   $0x0
  pushl $6
c0101e58:	6a 06                	push   $0x6
  jmp __alltraps
c0101e5a:	e9 33 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e5f <vector7>:
.globl vector7
vector7:
  pushl $0
c0101e5f:	6a 00                	push   $0x0
  pushl $7
c0101e61:	6a 07                	push   $0x7
  jmp __alltraps
c0101e63:	e9 2a 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e68 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e68:	6a 08                	push   $0x8
  jmp __alltraps
c0101e6a:	e9 23 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e6f <vector9>:
.globl vector9
vector9:
  pushl $0
c0101e6f:	6a 00                	push   $0x0
  pushl $9
c0101e71:	6a 09                	push   $0x9
  jmp __alltraps
c0101e73:	e9 1a 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e78 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e78:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e7a:	e9 13 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e7f <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e7f:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e81:	e9 0c 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e86 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e86:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e88:	e9 05 0a 00 00       	jmp    c0102892 <__alltraps>

c0101e8d <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e8d:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e8f:	e9 fe 09 00 00       	jmp    c0102892 <__alltraps>

c0101e94 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e94:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e96:	e9 f7 09 00 00       	jmp    c0102892 <__alltraps>

c0101e9b <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e9b:	6a 00                	push   $0x0
  pushl $15
c0101e9d:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e9f:	e9 ee 09 00 00       	jmp    c0102892 <__alltraps>

c0101ea4 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101ea4:	6a 00                	push   $0x0
  pushl $16
c0101ea6:	6a 10                	push   $0x10
  jmp __alltraps
c0101ea8:	e9 e5 09 00 00       	jmp    c0102892 <__alltraps>

c0101ead <vector17>:
.globl vector17
vector17:
  pushl $17
c0101ead:	6a 11                	push   $0x11
  jmp __alltraps
c0101eaf:	e9 de 09 00 00       	jmp    c0102892 <__alltraps>

c0101eb4 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101eb4:	6a 00                	push   $0x0
  pushl $18
c0101eb6:	6a 12                	push   $0x12
  jmp __alltraps
c0101eb8:	e9 d5 09 00 00       	jmp    c0102892 <__alltraps>

c0101ebd <vector19>:
.globl vector19
vector19:
  pushl $0
c0101ebd:	6a 00                	push   $0x0
  pushl $19
c0101ebf:	6a 13                	push   $0x13
  jmp __alltraps
c0101ec1:	e9 cc 09 00 00       	jmp    c0102892 <__alltraps>

c0101ec6 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101ec6:	6a 00                	push   $0x0
  pushl $20
c0101ec8:	6a 14                	push   $0x14
  jmp __alltraps
c0101eca:	e9 c3 09 00 00       	jmp    c0102892 <__alltraps>

c0101ecf <vector21>:
.globl vector21
vector21:
  pushl $0
c0101ecf:	6a 00                	push   $0x0
  pushl $21
c0101ed1:	6a 15                	push   $0x15
  jmp __alltraps
c0101ed3:	e9 ba 09 00 00       	jmp    c0102892 <__alltraps>

c0101ed8 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101ed8:	6a 00                	push   $0x0
  pushl $22
c0101eda:	6a 16                	push   $0x16
  jmp __alltraps
c0101edc:	e9 b1 09 00 00       	jmp    c0102892 <__alltraps>

c0101ee1 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101ee1:	6a 00                	push   $0x0
  pushl $23
c0101ee3:	6a 17                	push   $0x17
  jmp __alltraps
c0101ee5:	e9 a8 09 00 00       	jmp    c0102892 <__alltraps>

c0101eea <vector24>:
.globl vector24
vector24:
  pushl $0
c0101eea:	6a 00                	push   $0x0
  pushl $24
c0101eec:	6a 18                	push   $0x18
  jmp __alltraps
c0101eee:	e9 9f 09 00 00       	jmp    c0102892 <__alltraps>

c0101ef3 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101ef3:	6a 00                	push   $0x0
  pushl $25
c0101ef5:	6a 19                	push   $0x19
  jmp __alltraps
c0101ef7:	e9 96 09 00 00       	jmp    c0102892 <__alltraps>

c0101efc <vector26>:
.globl vector26
vector26:
  pushl $0
c0101efc:	6a 00                	push   $0x0
  pushl $26
c0101efe:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101f00:	e9 8d 09 00 00       	jmp    c0102892 <__alltraps>

c0101f05 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101f05:	6a 00                	push   $0x0
  pushl $27
c0101f07:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101f09:	e9 84 09 00 00       	jmp    c0102892 <__alltraps>

c0101f0e <vector28>:
.globl vector28
vector28:
  pushl $0
c0101f0e:	6a 00                	push   $0x0
  pushl $28
c0101f10:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101f12:	e9 7b 09 00 00       	jmp    c0102892 <__alltraps>

c0101f17 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101f17:	6a 00                	push   $0x0
  pushl $29
c0101f19:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101f1b:	e9 72 09 00 00       	jmp    c0102892 <__alltraps>

c0101f20 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101f20:	6a 00                	push   $0x0
  pushl $30
c0101f22:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101f24:	e9 69 09 00 00       	jmp    c0102892 <__alltraps>

c0101f29 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101f29:	6a 00                	push   $0x0
  pushl $31
c0101f2b:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101f2d:	e9 60 09 00 00       	jmp    c0102892 <__alltraps>

c0101f32 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101f32:	6a 00                	push   $0x0
  pushl $32
c0101f34:	6a 20                	push   $0x20
  jmp __alltraps
c0101f36:	e9 57 09 00 00       	jmp    c0102892 <__alltraps>

c0101f3b <vector33>:
.globl vector33
vector33:
  pushl $0
c0101f3b:	6a 00                	push   $0x0
  pushl $33
c0101f3d:	6a 21                	push   $0x21
  jmp __alltraps
c0101f3f:	e9 4e 09 00 00       	jmp    c0102892 <__alltraps>

c0101f44 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101f44:	6a 00                	push   $0x0
  pushl $34
c0101f46:	6a 22                	push   $0x22
  jmp __alltraps
c0101f48:	e9 45 09 00 00       	jmp    c0102892 <__alltraps>

c0101f4d <vector35>:
.globl vector35
vector35:
  pushl $0
c0101f4d:	6a 00                	push   $0x0
  pushl $35
c0101f4f:	6a 23                	push   $0x23
  jmp __alltraps
c0101f51:	e9 3c 09 00 00       	jmp    c0102892 <__alltraps>

c0101f56 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101f56:	6a 00                	push   $0x0
  pushl $36
c0101f58:	6a 24                	push   $0x24
  jmp __alltraps
c0101f5a:	e9 33 09 00 00       	jmp    c0102892 <__alltraps>

c0101f5f <vector37>:
.globl vector37
vector37:
  pushl $0
c0101f5f:	6a 00                	push   $0x0
  pushl $37
c0101f61:	6a 25                	push   $0x25
  jmp __alltraps
c0101f63:	e9 2a 09 00 00       	jmp    c0102892 <__alltraps>

c0101f68 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f68:	6a 00                	push   $0x0
  pushl $38
c0101f6a:	6a 26                	push   $0x26
  jmp __alltraps
c0101f6c:	e9 21 09 00 00       	jmp    c0102892 <__alltraps>

c0101f71 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f71:	6a 00                	push   $0x0
  pushl $39
c0101f73:	6a 27                	push   $0x27
  jmp __alltraps
c0101f75:	e9 18 09 00 00       	jmp    c0102892 <__alltraps>

c0101f7a <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f7a:	6a 00                	push   $0x0
  pushl $40
c0101f7c:	6a 28                	push   $0x28
  jmp __alltraps
c0101f7e:	e9 0f 09 00 00       	jmp    c0102892 <__alltraps>

c0101f83 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f83:	6a 00                	push   $0x0
  pushl $41
c0101f85:	6a 29                	push   $0x29
  jmp __alltraps
c0101f87:	e9 06 09 00 00       	jmp    c0102892 <__alltraps>

c0101f8c <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f8c:	6a 00                	push   $0x0
  pushl $42
c0101f8e:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f90:	e9 fd 08 00 00       	jmp    c0102892 <__alltraps>

c0101f95 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f95:	6a 00                	push   $0x0
  pushl $43
c0101f97:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f99:	e9 f4 08 00 00       	jmp    c0102892 <__alltraps>

c0101f9e <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f9e:	6a 00                	push   $0x0
  pushl $44
c0101fa0:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101fa2:	e9 eb 08 00 00       	jmp    c0102892 <__alltraps>

c0101fa7 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101fa7:	6a 00                	push   $0x0
  pushl $45
c0101fa9:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101fab:	e9 e2 08 00 00       	jmp    c0102892 <__alltraps>

c0101fb0 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101fb0:	6a 00                	push   $0x0
  pushl $46
c0101fb2:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101fb4:	e9 d9 08 00 00       	jmp    c0102892 <__alltraps>

c0101fb9 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101fb9:	6a 00                	push   $0x0
  pushl $47
c0101fbb:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101fbd:	e9 d0 08 00 00       	jmp    c0102892 <__alltraps>

c0101fc2 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101fc2:	6a 00                	push   $0x0
  pushl $48
c0101fc4:	6a 30                	push   $0x30
  jmp __alltraps
c0101fc6:	e9 c7 08 00 00       	jmp    c0102892 <__alltraps>

c0101fcb <vector49>:
.globl vector49
vector49:
  pushl $0
c0101fcb:	6a 00                	push   $0x0
  pushl $49
c0101fcd:	6a 31                	push   $0x31
  jmp __alltraps
c0101fcf:	e9 be 08 00 00       	jmp    c0102892 <__alltraps>

c0101fd4 <vector50>:
.globl vector50
vector50:
  pushl $0
c0101fd4:	6a 00                	push   $0x0
  pushl $50
c0101fd6:	6a 32                	push   $0x32
  jmp __alltraps
c0101fd8:	e9 b5 08 00 00       	jmp    c0102892 <__alltraps>

c0101fdd <vector51>:
.globl vector51
vector51:
  pushl $0
c0101fdd:	6a 00                	push   $0x0
  pushl $51
c0101fdf:	6a 33                	push   $0x33
  jmp __alltraps
c0101fe1:	e9 ac 08 00 00       	jmp    c0102892 <__alltraps>

c0101fe6 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101fe6:	6a 00                	push   $0x0
  pushl $52
c0101fe8:	6a 34                	push   $0x34
  jmp __alltraps
c0101fea:	e9 a3 08 00 00       	jmp    c0102892 <__alltraps>

c0101fef <vector53>:
.globl vector53
vector53:
  pushl $0
c0101fef:	6a 00                	push   $0x0
  pushl $53
c0101ff1:	6a 35                	push   $0x35
  jmp __alltraps
c0101ff3:	e9 9a 08 00 00       	jmp    c0102892 <__alltraps>

c0101ff8 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101ff8:	6a 00                	push   $0x0
  pushl $54
c0101ffa:	6a 36                	push   $0x36
  jmp __alltraps
c0101ffc:	e9 91 08 00 00       	jmp    c0102892 <__alltraps>

c0102001 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102001:	6a 00                	push   $0x0
  pushl $55
c0102003:	6a 37                	push   $0x37
  jmp __alltraps
c0102005:	e9 88 08 00 00       	jmp    c0102892 <__alltraps>

c010200a <vector56>:
.globl vector56
vector56:
  pushl $0
c010200a:	6a 00                	push   $0x0
  pushl $56
c010200c:	6a 38                	push   $0x38
  jmp __alltraps
c010200e:	e9 7f 08 00 00       	jmp    c0102892 <__alltraps>

c0102013 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102013:	6a 00                	push   $0x0
  pushl $57
c0102015:	6a 39                	push   $0x39
  jmp __alltraps
c0102017:	e9 76 08 00 00       	jmp    c0102892 <__alltraps>

c010201c <vector58>:
.globl vector58
vector58:
  pushl $0
c010201c:	6a 00                	push   $0x0
  pushl $58
c010201e:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102020:	e9 6d 08 00 00       	jmp    c0102892 <__alltraps>

c0102025 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102025:	6a 00                	push   $0x0
  pushl $59
c0102027:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102029:	e9 64 08 00 00       	jmp    c0102892 <__alltraps>

c010202e <vector60>:
.globl vector60
vector60:
  pushl $0
c010202e:	6a 00                	push   $0x0
  pushl $60
c0102030:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102032:	e9 5b 08 00 00       	jmp    c0102892 <__alltraps>

c0102037 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102037:	6a 00                	push   $0x0
  pushl $61
c0102039:	6a 3d                	push   $0x3d
  jmp __alltraps
c010203b:	e9 52 08 00 00       	jmp    c0102892 <__alltraps>

c0102040 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102040:	6a 00                	push   $0x0
  pushl $62
c0102042:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102044:	e9 49 08 00 00       	jmp    c0102892 <__alltraps>

c0102049 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102049:	6a 00                	push   $0x0
  pushl $63
c010204b:	6a 3f                	push   $0x3f
  jmp __alltraps
c010204d:	e9 40 08 00 00       	jmp    c0102892 <__alltraps>

c0102052 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102052:	6a 00                	push   $0x0
  pushl $64
c0102054:	6a 40                	push   $0x40
  jmp __alltraps
c0102056:	e9 37 08 00 00       	jmp    c0102892 <__alltraps>

c010205b <vector65>:
.globl vector65
vector65:
  pushl $0
c010205b:	6a 00                	push   $0x0
  pushl $65
c010205d:	6a 41                	push   $0x41
  jmp __alltraps
c010205f:	e9 2e 08 00 00       	jmp    c0102892 <__alltraps>

c0102064 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102064:	6a 00                	push   $0x0
  pushl $66
c0102066:	6a 42                	push   $0x42
  jmp __alltraps
c0102068:	e9 25 08 00 00       	jmp    c0102892 <__alltraps>

c010206d <vector67>:
.globl vector67
vector67:
  pushl $0
c010206d:	6a 00                	push   $0x0
  pushl $67
c010206f:	6a 43                	push   $0x43
  jmp __alltraps
c0102071:	e9 1c 08 00 00       	jmp    c0102892 <__alltraps>

c0102076 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102076:	6a 00                	push   $0x0
  pushl $68
c0102078:	6a 44                	push   $0x44
  jmp __alltraps
c010207a:	e9 13 08 00 00       	jmp    c0102892 <__alltraps>

c010207f <vector69>:
.globl vector69
vector69:
  pushl $0
c010207f:	6a 00                	push   $0x0
  pushl $69
c0102081:	6a 45                	push   $0x45
  jmp __alltraps
c0102083:	e9 0a 08 00 00       	jmp    c0102892 <__alltraps>

c0102088 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102088:	6a 00                	push   $0x0
  pushl $70
c010208a:	6a 46                	push   $0x46
  jmp __alltraps
c010208c:	e9 01 08 00 00       	jmp    c0102892 <__alltraps>

c0102091 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102091:	6a 00                	push   $0x0
  pushl $71
c0102093:	6a 47                	push   $0x47
  jmp __alltraps
c0102095:	e9 f8 07 00 00       	jmp    c0102892 <__alltraps>

c010209a <vector72>:
.globl vector72
vector72:
  pushl $0
c010209a:	6a 00                	push   $0x0
  pushl $72
c010209c:	6a 48                	push   $0x48
  jmp __alltraps
c010209e:	e9 ef 07 00 00       	jmp    c0102892 <__alltraps>

c01020a3 <vector73>:
.globl vector73
vector73:
  pushl $0
c01020a3:	6a 00                	push   $0x0
  pushl $73
c01020a5:	6a 49                	push   $0x49
  jmp __alltraps
c01020a7:	e9 e6 07 00 00       	jmp    c0102892 <__alltraps>

c01020ac <vector74>:
.globl vector74
vector74:
  pushl $0
c01020ac:	6a 00                	push   $0x0
  pushl $74
c01020ae:	6a 4a                	push   $0x4a
  jmp __alltraps
c01020b0:	e9 dd 07 00 00       	jmp    c0102892 <__alltraps>

c01020b5 <vector75>:
.globl vector75
vector75:
  pushl $0
c01020b5:	6a 00                	push   $0x0
  pushl $75
c01020b7:	6a 4b                	push   $0x4b
  jmp __alltraps
c01020b9:	e9 d4 07 00 00       	jmp    c0102892 <__alltraps>

c01020be <vector76>:
.globl vector76
vector76:
  pushl $0
c01020be:	6a 00                	push   $0x0
  pushl $76
c01020c0:	6a 4c                	push   $0x4c
  jmp __alltraps
c01020c2:	e9 cb 07 00 00       	jmp    c0102892 <__alltraps>

c01020c7 <vector77>:
.globl vector77
vector77:
  pushl $0
c01020c7:	6a 00                	push   $0x0
  pushl $77
c01020c9:	6a 4d                	push   $0x4d
  jmp __alltraps
c01020cb:	e9 c2 07 00 00       	jmp    c0102892 <__alltraps>

c01020d0 <vector78>:
.globl vector78
vector78:
  pushl $0
c01020d0:	6a 00                	push   $0x0
  pushl $78
c01020d2:	6a 4e                	push   $0x4e
  jmp __alltraps
c01020d4:	e9 b9 07 00 00       	jmp    c0102892 <__alltraps>

c01020d9 <vector79>:
.globl vector79
vector79:
  pushl $0
c01020d9:	6a 00                	push   $0x0
  pushl $79
c01020db:	6a 4f                	push   $0x4f
  jmp __alltraps
c01020dd:	e9 b0 07 00 00       	jmp    c0102892 <__alltraps>

c01020e2 <vector80>:
.globl vector80
vector80:
  pushl $0
c01020e2:	6a 00                	push   $0x0
  pushl $80
c01020e4:	6a 50                	push   $0x50
  jmp __alltraps
c01020e6:	e9 a7 07 00 00       	jmp    c0102892 <__alltraps>

c01020eb <vector81>:
.globl vector81
vector81:
  pushl $0
c01020eb:	6a 00                	push   $0x0
  pushl $81
c01020ed:	6a 51                	push   $0x51
  jmp __alltraps
c01020ef:	e9 9e 07 00 00       	jmp    c0102892 <__alltraps>

c01020f4 <vector82>:
.globl vector82
vector82:
  pushl $0
c01020f4:	6a 00                	push   $0x0
  pushl $82
c01020f6:	6a 52                	push   $0x52
  jmp __alltraps
c01020f8:	e9 95 07 00 00       	jmp    c0102892 <__alltraps>

c01020fd <vector83>:
.globl vector83
vector83:
  pushl $0
c01020fd:	6a 00                	push   $0x0
  pushl $83
c01020ff:	6a 53                	push   $0x53
  jmp __alltraps
c0102101:	e9 8c 07 00 00       	jmp    c0102892 <__alltraps>

c0102106 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102106:	6a 00                	push   $0x0
  pushl $84
c0102108:	6a 54                	push   $0x54
  jmp __alltraps
c010210a:	e9 83 07 00 00       	jmp    c0102892 <__alltraps>

c010210f <vector85>:
.globl vector85
vector85:
  pushl $0
c010210f:	6a 00                	push   $0x0
  pushl $85
c0102111:	6a 55                	push   $0x55
  jmp __alltraps
c0102113:	e9 7a 07 00 00       	jmp    c0102892 <__alltraps>

c0102118 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102118:	6a 00                	push   $0x0
  pushl $86
c010211a:	6a 56                	push   $0x56
  jmp __alltraps
c010211c:	e9 71 07 00 00       	jmp    c0102892 <__alltraps>

c0102121 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102121:	6a 00                	push   $0x0
  pushl $87
c0102123:	6a 57                	push   $0x57
  jmp __alltraps
c0102125:	e9 68 07 00 00       	jmp    c0102892 <__alltraps>

c010212a <vector88>:
.globl vector88
vector88:
  pushl $0
c010212a:	6a 00                	push   $0x0
  pushl $88
c010212c:	6a 58                	push   $0x58
  jmp __alltraps
c010212e:	e9 5f 07 00 00       	jmp    c0102892 <__alltraps>

c0102133 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102133:	6a 00                	push   $0x0
  pushl $89
c0102135:	6a 59                	push   $0x59
  jmp __alltraps
c0102137:	e9 56 07 00 00       	jmp    c0102892 <__alltraps>

c010213c <vector90>:
.globl vector90
vector90:
  pushl $0
c010213c:	6a 00                	push   $0x0
  pushl $90
c010213e:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102140:	e9 4d 07 00 00       	jmp    c0102892 <__alltraps>

c0102145 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102145:	6a 00                	push   $0x0
  pushl $91
c0102147:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102149:	e9 44 07 00 00       	jmp    c0102892 <__alltraps>

c010214e <vector92>:
.globl vector92
vector92:
  pushl $0
c010214e:	6a 00                	push   $0x0
  pushl $92
c0102150:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102152:	e9 3b 07 00 00       	jmp    c0102892 <__alltraps>

c0102157 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102157:	6a 00                	push   $0x0
  pushl $93
c0102159:	6a 5d                	push   $0x5d
  jmp __alltraps
c010215b:	e9 32 07 00 00       	jmp    c0102892 <__alltraps>

c0102160 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102160:	6a 00                	push   $0x0
  pushl $94
c0102162:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102164:	e9 29 07 00 00       	jmp    c0102892 <__alltraps>

c0102169 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102169:	6a 00                	push   $0x0
  pushl $95
c010216b:	6a 5f                	push   $0x5f
  jmp __alltraps
c010216d:	e9 20 07 00 00       	jmp    c0102892 <__alltraps>

c0102172 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102172:	6a 00                	push   $0x0
  pushl $96
c0102174:	6a 60                	push   $0x60
  jmp __alltraps
c0102176:	e9 17 07 00 00       	jmp    c0102892 <__alltraps>

c010217b <vector97>:
.globl vector97
vector97:
  pushl $0
c010217b:	6a 00                	push   $0x0
  pushl $97
c010217d:	6a 61                	push   $0x61
  jmp __alltraps
c010217f:	e9 0e 07 00 00       	jmp    c0102892 <__alltraps>

c0102184 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102184:	6a 00                	push   $0x0
  pushl $98
c0102186:	6a 62                	push   $0x62
  jmp __alltraps
c0102188:	e9 05 07 00 00       	jmp    c0102892 <__alltraps>

c010218d <vector99>:
.globl vector99
vector99:
  pushl $0
c010218d:	6a 00                	push   $0x0
  pushl $99
c010218f:	6a 63                	push   $0x63
  jmp __alltraps
c0102191:	e9 fc 06 00 00       	jmp    c0102892 <__alltraps>

c0102196 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102196:	6a 00                	push   $0x0
  pushl $100
c0102198:	6a 64                	push   $0x64
  jmp __alltraps
c010219a:	e9 f3 06 00 00       	jmp    c0102892 <__alltraps>

c010219f <vector101>:
.globl vector101
vector101:
  pushl $0
c010219f:	6a 00                	push   $0x0
  pushl $101
c01021a1:	6a 65                	push   $0x65
  jmp __alltraps
c01021a3:	e9 ea 06 00 00       	jmp    c0102892 <__alltraps>

c01021a8 <vector102>:
.globl vector102
vector102:
  pushl $0
c01021a8:	6a 00                	push   $0x0
  pushl $102
c01021aa:	6a 66                	push   $0x66
  jmp __alltraps
c01021ac:	e9 e1 06 00 00       	jmp    c0102892 <__alltraps>

c01021b1 <vector103>:
.globl vector103
vector103:
  pushl $0
c01021b1:	6a 00                	push   $0x0
  pushl $103
c01021b3:	6a 67                	push   $0x67
  jmp __alltraps
c01021b5:	e9 d8 06 00 00       	jmp    c0102892 <__alltraps>

c01021ba <vector104>:
.globl vector104
vector104:
  pushl $0
c01021ba:	6a 00                	push   $0x0
  pushl $104
c01021bc:	6a 68                	push   $0x68
  jmp __alltraps
c01021be:	e9 cf 06 00 00       	jmp    c0102892 <__alltraps>

c01021c3 <vector105>:
.globl vector105
vector105:
  pushl $0
c01021c3:	6a 00                	push   $0x0
  pushl $105
c01021c5:	6a 69                	push   $0x69
  jmp __alltraps
c01021c7:	e9 c6 06 00 00       	jmp    c0102892 <__alltraps>

c01021cc <vector106>:
.globl vector106
vector106:
  pushl $0
c01021cc:	6a 00                	push   $0x0
  pushl $106
c01021ce:	6a 6a                	push   $0x6a
  jmp __alltraps
c01021d0:	e9 bd 06 00 00       	jmp    c0102892 <__alltraps>

c01021d5 <vector107>:
.globl vector107
vector107:
  pushl $0
c01021d5:	6a 00                	push   $0x0
  pushl $107
c01021d7:	6a 6b                	push   $0x6b
  jmp __alltraps
c01021d9:	e9 b4 06 00 00       	jmp    c0102892 <__alltraps>

c01021de <vector108>:
.globl vector108
vector108:
  pushl $0
c01021de:	6a 00                	push   $0x0
  pushl $108
c01021e0:	6a 6c                	push   $0x6c
  jmp __alltraps
c01021e2:	e9 ab 06 00 00       	jmp    c0102892 <__alltraps>

c01021e7 <vector109>:
.globl vector109
vector109:
  pushl $0
c01021e7:	6a 00                	push   $0x0
  pushl $109
c01021e9:	6a 6d                	push   $0x6d
  jmp __alltraps
c01021eb:	e9 a2 06 00 00       	jmp    c0102892 <__alltraps>

c01021f0 <vector110>:
.globl vector110
vector110:
  pushl $0
c01021f0:	6a 00                	push   $0x0
  pushl $110
c01021f2:	6a 6e                	push   $0x6e
  jmp __alltraps
c01021f4:	e9 99 06 00 00       	jmp    c0102892 <__alltraps>

c01021f9 <vector111>:
.globl vector111
vector111:
  pushl $0
c01021f9:	6a 00                	push   $0x0
  pushl $111
c01021fb:	6a 6f                	push   $0x6f
  jmp __alltraps
c01021fd:	e9 90 06 00 00       	jmp    c0102892 <__alltraps>

c0102202 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102202:	6a 00                	push   $0x0
  pushl $112
c0102204:	6a 70                	push   $0x70
  jmp __alltraps
c0102206:	e9 87 06 00 00       	jmp    c0102892 <__alltraps>

c010220b <vector113>:
.globl vector113
vector113:
  pushl $0
c010220b:	6a 00                	push   $0x0
  pushl $113
c010220d:	6a 71                	push   $0x71
  jmp __alltraps
c010220f:	e9 7e 06 00 00       	jmp    c0102892 <__alltraps>

c0102214 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102214:	6a 00                	push   $0x0
  pushl $114
c0102216:	6a 72                	push   $0x72
  jmp __alltraps
c0102218:	e9 75 06 00 00       	jmp    c0102892 <__alltraps>

c010221d <vector115>:
.globl vector115
vector115:
  pushl $0
c010221d:	6a 00                	push   $0x0
  pushl $115
c010221f:	6a 73                	push   $0x73
  jmp __alltraps
c0102221:	e9 6c 06 00 00       	jmp    c0102892 <__alltraps>

c0102226 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102226:	6a 00                	push   $0x0
  pushl $116
c0102228:	6a 74                	push   $0x74
  jmp __alltraps
c010222a:	e9 63 06 00 00       	jmp    c0102892 <__alltraps>

c010222f <vector117>:
.globl vector117
vector117:
  pushl $0
c010222f:	6a 00                	push   $0x0
  pushl $117
c0102231:	6a 75                	push   $0x75
  jmp __alltraps
c0102233:	e9 5a 06 00 00       	jmp    c0102892 <__alltraps>

c0102238 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102238:	6a 00                	push   $0x0
  pushl $118
c010223a:	6a 76                	push   $0x76
  jmp __alltraps
c010223c:	e9 51 06 00 00       	jmp    c0102892 <__alltraps>

c0102241 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102241:	6a 00                	push   $0x0
  pushl $119
c0102243:	6a 77                	push   $0x77
  jmp __alltraps
c0102245:	e9 48 06 00 00       	jmp    c0102892 <__alltraps>

c010224a <vector120>:
.globl vector120
vector120:
  pushl $0
c010224a:	6a 00                	push   $0x0
  pushl $120
c010224c:	6a 78                	push   $0x78
  jmp __alltraps
c010224e:	e9 3f 06 00 00       	jmp    c0102892 <__alltraps>

c0102253 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102253:	6a 00                	push   $0x0
  pushl $121
c0102255:	6a 79                	push   $0x79
  jmp __alltraps
c0102257:	e9 36 06 00 00       	jmp    c0102892 <__alltraps>

c010225c <vector122>:
.globl vector122
vector122:
  pushl $0
c010225c:	6a 00                	push   $0x0
  pushl $122
c010225e:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102260:	e9 2d 06 00 00       	jmp    c0102892 <__alltraps>

c0102265 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102265:	6a 00                	push   $0x0
  pushl $123
c0102267:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102269:	e9 24 06 00 00       	jmp    c0102892 <__alltraps>

c010226e <vector124>:
.globl vector124
vector124:
  pushl $0
c010226e:	6a 00                	push   $0x0
  pushl $124
c0102270:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102272:	e9 1b 06 00 00       	jmp    c0102892 <__alltraps>

c0102277 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102277:	6a 00                	push   $0x0
  pushl $125
c0102279:	6a 7d                	push   $0x7d
  jmp __alltraps
c010227b:	e9 12 06 00 00       	jmp    c0102892 <__alltraps>

c0102280 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102280:	6a 00                	push   $0x0
  pushl $126
c0102282:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102284:	e9 09 06 00 00       	jmp    c0102892 <__alltraps>

c0102289 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102289:	6a 00                	push   $0x0
  pushl $127
c010228b:	6a 7f                	push   $0x7f
  jmp __alltraps
c010228d:	e9 00 06 00 00       	jmp    c0102892 <__alltraps>

c0102292 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102292:	6a 00                	push   $0x0
  pushl $128
c0102294:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102299:	e9 f4 05 00 00       	jmp    c0102892 <__alltraps>

c010229e <vector129>:
.globl vector129
vector129:
  pushl $0
c010229e:	6a 00                	push   $0x0
  pushl $129
c01022a0:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01022a5:	e9 e8 05 00 00       	jmp    c0102892 <__alltraps>

c01022aa <vector130>:
.globl vector130
vector130:
  pushl $0
c01022aa:	6a 00                	push   $0x0
  pushl $130
c01022ac:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01022b1:	e9 dc 05 00 00       	jmp    c0102892 <__alltraps>

c01022b6 <vector131>:
.globl vector131
vector131:
  pushl $0
c01022b6:	6a 00                	push   $0x0
  pushl $131
c01022b8:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01022bd:	e9 d0 05 00 00       	jmp    c0102892 <__alltraps>

c01022c2 <vector132>:
.globl vector132
vector132:
  pushl $0
c01022c2:	6a 00                	push   $0x0
  pushl $132
c01022c4:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01022c9:	e9 c4 05 00 00       	jmp    c0102892 <__alltraps>

c01022ce <vector133>:
.globl vector133
vector133:
  pushl $0
c01022ce:	6a 00                	push   $0x0
  pushl $133
c01022d0:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01022d5:	e9 b8 05 00 00       	jmp    c0102892 <__alltraps>

c01022da <vector134>:
.globl vector134
vector134:
  pushl $0
c01022da:	6a 00                	push   $0x0
  pushl $134
c01022dc:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01022e1:	e9 ac 05 00 00       	jmp    c0102892 <__alltraps>

c01022e6 <vector135>:
.globl vector135
vector135:
  pushl $0
c01022e6:	6a 00                	push   $0x0
  pushl $135
c01022e8:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01022ed:	e9 a0 05 00 00       	jmp    c0102892 <__alltraps>

c01022f2 <vector136>:
.globl vector136
vector136:
  pushl $0
c01022f2:	6a 00                	push   $0x0
  pushl $136
c01022f4:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01022f9:	e9 94 05 00 00       	jmp    c0102892 <__alltraps>

c01022fe <vector137>:
.globl vector137
vector137:
  pushl $0
c01022fe:	6a 00                	push   $0x0
  pushl $137
c0102300:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102305:	e9 88 05 00 00       	jmp    c0102892 <__alltraps>

c010230a <vector138>:
.globl vector138
vector138:
  pushl $0
c010230a:	6a 00                	push   $0x0
  pushl $138
c010230c:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102311:	e9 7c 05 00 00       	jmp    c0102892 <__alltraps>

c0102316 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102316:	6a 00                	push   $0x0
  pushl $139
c0102318:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c010231d:	e9 70 05 00 00       	jmp    c0102892 <__alltraps>

c0102322 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102322:	6a 00                	push   $0x0
  pushl $140
c0102324:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102329:	e9 64 05 00 00       	jmp    c0102892 <__alltraps>

c010232e <vector141>:
.globl vector141
vector141:
  pushl $0
c010232e:	6a 00                	push   $0x0
  pushl $141
c0102330:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102335:	e9 58 05 00 00       	jmp    c0102892 <__alltraps>

c010233a <vector142>:
.globl vector142
vector142:
  pushl $0
c010233a:	6a 00                	push   $0x0
  pushl $142
c010233c:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102341:	e9 4c 05 00 00       	jmp    c0102892 <__alltraps>

c0102346 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102346:	6a 00                	push   $0x0
  pushl $143
c0102348:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c010234d:	e9 40 05 00 00       	jmp    c0102892 <__alltraps>

c0102352 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102352:	6a 00                	push   $0x0
  pushl $144
c0102354:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102359:	e9 34 05 00 00       	jmp    c0102892 <__alltraps>

c010235e <vector145>:
.globl vector145
vector145:
  pushl $0
c010235e:	6a 00                	push   $0x0
  pushl $145
c0102360:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102365:	e9 28 05 00 00       	jmp    c0102892 <__alltraps>

c010236a <vector146>:
.globl vector146
vector146:
  pushl $0
c010236a:	6a 00                	push   $0x0
  pushl $146
c010236c:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102371:	e9 1c 05 00 00       	jmp    c0102892 <__alltraps>

c0102376 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102376:	6a 00                	push   $0x0
  pushl $147
c0102378:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010237d:	e9 10 05 00 00       	jmp    c0102892 <__alltraps>

c0102382 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102382:	6a 00                	push   $0x0
  pushl $148
c0102384:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102389:	e9 04 05 00 00       	jmp    c0102892 <__alltraps>

c010238e <vector149>:
.globl vector149
vector149:
  pushl $0
c010238e:	6a 00                	push   $0x0
  pushl $149
c0102390:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102395:	e9 f8 04 00 00       	jmp    c0102892 <__alltraps>

c010239a <vector150>:
.globl vector150
vector150:
  pushl $0
c010239a:	6a 00                	push   $0x0
  pushl $150
c010239c:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01023a1:	e9 ec 04 00 00       	jmp    c0102892 <__alltraps>

c01023a6 <vector151>:
.globl vector151
vector151:
  pushl $0
c01023a6:	6a 00                	push   $0x0
  pushl $151
c01023a8:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01023ad:	e9 e0 04 00 00       	jmp    c0102892 <__alltraps>

c01023b2 <vector152>:
.globl vector152
vector152:
  pushl $0
c01023b2:	6a 00                	push   $0x0
  pushl $152
c01023b4:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01023b9:	e9 d4 04 00 00       	jmp    c0102892 <__alltraps>

c01023be <vector153>:
.globl vector153
vector153:
  pushl $0
c01023be:	6a 00                	push   $0x0
  pushl $153
c01023c0:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01023c5:	e9 c8 04 00 00       	jmp    c0102892 <__alltraps>

c01023ca <vector154>:
.globl vector154
vector154:
  pushl $0
c01023ca:	6a 00                	push   $0x0
  pushl $154
c01023cc:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01023d1:	e9 bc 04 00 00       	jmp    c0102892 <__alltraps>

c01023d6 <vector155>:
.globl vector155
vector155:
  pushl $0
c01023d6:	6a 00                	push   $0x0
  pushl $155
c01023d8:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01023dd:	e9 b0 04 00 00       	jmp    c0102892 <__alltraps>

c01023e2 <vector156>:
.globl vector156
vector156:
  pushl $0
c01023e2:	6a 00                	push   $0x0
  pushl $156
c01023e4:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01023e9:	e9 a4 04 00 00       	jmp    c0102892 <__alltraps>

c01023ee <vector157>:
.globl vector157
vector157:
  pushl $0
c01023ee:	6a 00                	push   $0x0
  pushl $157
c01023f0:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01023f5:	e9 98 04 00 00       	jmp    c0102892 <__alltraps>

c01023fa <vector158>:
.globl vector158
vector158:
  pushl $0
c01023fa:	6a 00                	push   $0x0
  pushl $158
c01023fc:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102401:	e9 8c 04 00 00       	jmp    c0102892 <__alltraps>

c0102406 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102406:	6a 00                	push   $0x0
  pushl $159
c0102408:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010240d:	e9 80 04 00 00       	jmp    c0102892 <__alltraps>

c0102412 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102412:	6a 00                	push   $0x0
  pushl $160
c0102414:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102419:	e9 74 04 00 00       	jmp    c0102892 <__alltraps>

c010241e <vector161>:
.globl vector161
vector161:
  pushl $0
c010241e:	6a 00                	push   $0x0
  pushl $161
c0102420:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102425:	e9 68 04 00 00       	jmp    c0102892 <__alltraps>

c010242a <vector162>:
.globl vector162
vector162:
  pushl $0
c010242a:	6a 00                	push   $0x0
  pushl $162
c010242c:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102431:	e9 5c 04 00 00       	jmp    c0102892 <__alltraps>

c0102436 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102436:	6a 00                	push   $0x0
  pushl $163
c0102438:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010243d:	e9 50 04 00 00       	jmp    c0102892 <__alltraps>

c0102442 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102442:	6a 00                	push   $0x0
  pushl $164
c0102444:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102449:	e9 44 04 00 00       	jmp    c0102892 <__alltraps>

c010244e <vector165>:
.globl vector165
vector165:
  pushl $0
c010244e:	6a 00                	push   $0x0
  pushl $165
c0102450:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102455:	e9 38 04 00 00       	jmp    c0102892 <__alltraps>

c010245a <vector166>:
.globl vector166
vector166:
  pushl $0
c010245a:	6a 00                	push   $0x0
  pushl $166
c010245c:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102461:	e9 2c 04 00 00       	jmp    c0102892 <__alltraps>

c0102466 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102466:	6a 00                	push   $0x0
  pushl $167
c0102468:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010246d:	e9 20 04 00 00       	jmp    c0102892 <__alltraps>

c0102472 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102472:	6a 00                	push   $0x0
  pushl $168
c0102474:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102479:	e9 14 04 00 00       	jmp    c0102892 <__alltraps>

c010247e <vector169>:
.globl vector169
vector169:
  pushl $0
c010247e:	6a 00                	push   $0x0
  pushl $169
c0102480:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102485:	e9 08 04 00 00       	jmp    c0102892 <__alltraps>

c010248a <vector170>:
.globl vector170
vector170:
  pushl $0
c010248a:	6a 00                	push   $0x0
  pushl $170
c010248c:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102491:	e9 fc 03 00 00       	jmp    c0102892 <__alltraps>

c0102496 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102496:	6a 00                	push   $0x0
  pushl $171
c0102498:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010249d:	e9 f0 03 00 00       	jmp    c0102892 <__alltraps>

c01024a2 <vector172>:
.globl vector172
vector172:
  pushl $0
c01024a2:	6a 00                	push   $0x0
  pushl $172
c01024a4:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01024a9:	e9 e4 03 00 00       	jmp    c0102892 <__alltraps>

c01024ae <vector173>:
.globl vector173
vector173:
  pushl $0
c01024ae:	6a 00                	push   $0x0
  pushl $173
c01024b0:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01024b5:	e9 d8 03 00 00       	jmp    c0102892 <__alltraps>

c01024ba <vector174>:
.globl vector174
vector174:
  pushl $0
c01024ba:	6a 00                	push   $0x0
  pushl $174
c01024bc:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01024c1:	e9 cc 03 00 00       	jmp    c0102892 <__alltraps>

c01024c6 <vector175>:
.globl vector175
vector175:
  pushl $0
c01024c6:	6a 00                	push   $0x0
  pushl $175
c01024c8:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01024cd:	e9 c0 03 00 00       	jmp    c0102892 <__alltraps>

c01024d2 <vector176>:
.globl vector176
vector176:
  pushl $0
c01024d2:	6a 00                	push   $0x0
  pushl $176
c01024d4:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01024d9:	e9 b4 03 00 00       	jmp    c0102892 <__alltraps>

c01024de <vector177>:
.globl vector177
vector177:
  pushl $0
c01024de:	6a 00                	push   $0x0
  pushl $177
c01024e0:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01024e5:	e9 a8 03 00 00       	jmp    c0102892 <__alltraps>

c01024ea <vector178>:
.globl vector178
vector178:
  pushl $0
c01024ea:	6a 00                	push   $0x0
  pushl $178
c01024ec:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01024f1:	e9 9c 03 00 00       	jmp    c0102892 <__alltraps>

c01024f6 <vector179>:
.globl vector179
vector179:
  pushl $0
c01024f6:	6a 00                	push   $0x0
  pushl $179
c01024f8:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01024fd:	e9 90 03 00 00       	jmp    c0102892 <__alltraps>

c0102502 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102502:	6a 00                	push   $0x0
  pushl $180
c0102504:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102509:	e9 84 03 00 00       	jmp    c0102892 <__alltraps>

c010250e <vector181>:
.globl vector181
vector181:
  pushl $0
c010250e:	6a 00                	push   $0x0
  pushl $181
c0102510:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102515:	e9 78 03 00 00       	jmp    c0102892 <__alltraps>

c010251a <vector182>:
.globl vector182
vector182:
  pushl $0
c010251a:	6a 00                	push   $0x0
  pushl $182
c010251c:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102521:	e9 6c 03 00 00       	jmp    c0102892 <__alltraps>

c0102526 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102526:	6a 00                	push   $0x0
  pushl $183
c0102528:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010252d:	e9 60 03 00 00       	jmp    c0102892 <__alltraps>

c0102532 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102532:	6a 00                	push   $0x0
  pushl $184
c0102534:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102539:	e9 54 03 00 00       	jmp    c0102892 <__alltraps>

c010253e <vector185>:
.globl vector185
vector185:
  pushl $0
c010253e:	6a 00                	push   $0x0
  pushl $185
c0102540:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102545:	e9 48 03 00 00       	jmp    c0102892 <__alltraps>

c010254a <vector186>:
.globl vector186
vector186:
  pushl $0
c010254a:	6a 00                	push   $0x0
  pushl $186
c010254c:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102551:	e9 3c 03 00 00       	jmp    c0102892 <__alltraps>

c0102556 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102556:	6a 00                	push   $0x0
  pushl $187
c0102558:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010255d:	e9 30 03 00 00       	jmp    c0102892 <__alltraps>

c0102562 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102562:	6a 00                	push   $0x0
  pushl $188
c0102564:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102569:	e9 24 03 00 00       	jmp    c0102892 <__alltraps>

c010256e <vector189>:
.globl vector189
vector189:
  pushl $0
c010256e:	6a 00                	push   $0x0
  pushl $189
c0102570:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102575:	e9 18 03 00 00       	jmp    c0102892 <__alltraps>

c010257a <vector190>:
.globl vector190
vector190:
  pushl $0
c010257a:	6a 00                	push   $0x0
  pushl $190
c010257c:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102581:	e9 0c 03 00 00       	jmp    c0102892 <__alltraps>

c0102586 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102586:	6a 00                	push   $0x0
  pushl $191
c0102588:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010258d:	e9 00 03 00 00       	jmp    c0102892 <__alltraps>

c0102592 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102592:	6a 00                	push   $0x0
  pushl $192
c0102594:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102599:	e9 f4 02 00 00       	jmp    c0102892 <__alltraps>

c010259e <vector193>:
.globl vector193
vector193:
  pushl $0
c010259e:	6a 00                	push   $0x0
  pushl $193
c01025a0:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01025a5:	e9 e8 02 00 00       	jmp    c0102892 <__alltraps>

c01025aa <vector194>:
.globl vector194
vector194:
  pushl $0
c01025aa:	6a 00                	push   $0x0
  pushl $194
c01025ac:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01025b1:	e9 dc 02 00 00       	jmp    c0102892 <__alltraps>

c01025b6 <vector195>:
.globl vector195
vector195:
  pushl $0
c01025b6:	6a 00                	push   $0x0
  pushl $195
c01025b8:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01025bd:	e9 d0 02 00 00       	jmp    c0102892 <__alltraps>

c01025c2 <vector196>:
.globl vector196
vector196:
  pushl $0
c01025c2:	6a 00                	push   $0x0
  pushl $196
c01025c4:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01025c9:	e9 c4 02 00 00       	jmp    c0102892 <__alltraps>

c01025ce <vector197>:
.globl vector197
vector197:
  pushl $0
c01025ce:	6a 00                	push   $0x0
  pushl $197
c01025d0:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01025d5:	e9 b8 02 00 00       	jmp    c0102892 <__alltraps>

c01025da <vector198>:
.globl vector198
vector198:
  pushl $0
c01025da:	6a 00                	push   $0x0
  pushl $198
c01025dc:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01025e1:	e9 ac 02 00 00       	jmp    c0102892 <__alltraps>

c01025e6 <vector199>:
.globl vector199
vector199:
  pushl $0
c01025e6:	6a 00                	push   $0x0
  pushl $199
c01025e8:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01025ed:	e9 a0 02 00 00       	jmp    c0102892 <__alltraps>

c01025f2 <vector200>:
.globl vector200
vector200:
  pushl $0
c01025f2:	6a 00                	push   $0x0
  pushl $200
c01025f4:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01025f9:	e9 94 02 00 00       	jmp    c0102892 <__alltraps>

c01025fe <vector201>:
.globl vector201
vector201:
  pushl $0
c01025fe:	6a 00                	push   $0x0
  pushl $201
c0102600:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102605:	e9 88 02 00 00       	jmp    c0102892 <__alltraps>

c010260a <vector202>:
.globl vector202
vector202:
  pushl $0
c010260a:	6a 00                	push   $0x0
  pushl $202
c010260c:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102611:	e9 7c 02 00 00       	jmp    c0102892 <__alltraps>

c0102616 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102616:	6a 00                	push   $0x0
  pushl $203
c0102618:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010261d:	e9 70 02 00 00       	jmp    c0102892 <__alltraps>

c0102622 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102622:	6a 00                	push   $0x0
  pushl $204
c0102624:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102629:	e9 64 02 00 00       	jmp    c0102892 <__alltraps>

c010262e <vector205>:
.globl vector205
vector205:
  pushl $0
c010262e:	6a 00                	push   $0x0
  pushl $205
c0102630:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102635:	e9 58 02 00 00       	jmp    c0102892 <__alltraps>

c010263a <vector206>:
.globl vector206
vector206:
  pushl $0
c010263a:	6a 00                	push   $0x0
  pushl $206
c010263c:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102641:	e9 4c 02 00 00       	jmp    c0102892 <__alltraps>

c0102646 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102646:	6a 00                	push   $0x0
  pushl $207
c0102648:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010264d:	e9 40 02 00 00       	jmp    c0102892 <__alltraps>

c0102652 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102652:	6a 00                	push   $0x0
  pushl $208
c0102654:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102659:	e9 34 02 00 00       	jmp    c0102892 <__alltraps>

c010265e <vector209>:
.globl vector209
vector209:
  pushl $0
c010265e:	6a 00                	push   $0x0
  pushl $209
c0102660:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102665:	e9 28 02 00 00       	jmp    c0102892 <__alltraps>

c010266a <vector210>:
.globl vector210
vector210:
  pushl $0
c010266a:	6a 00                	push   $0x0
  pushl $210
c010266c:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102671:	e9 1c 02 00 00       	jmp    c0102892 <__alltraps>

c0102676 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102676:	6a 00                	push   $0x0
  pushl $211
c0102678:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010267d:	e9 10 02 00 00       	jmp    c0102892 <__alltraps>

c0102682 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102682:	6a 00                	push   $0x0
  pushl $212
c0102684:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102689:	e9 04 02 00 00       	jmp    c0102892 <__alltraps>

c010268e <vector213>:
.globl vector213
vector213:
  pushl $0
c010268e:	6a 00                	push   $0x0
  pushl $213
c0102690:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102695:	e9 f8 01 00 00       	jmp    c0102892 <__alltraps>

c010269a <vector214>:
.globl vector214
vector214:
  pushl $0
c010269a:	6a 00                	push   $0x0
  pushl $214
c010269c:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01026a1:	e9 ec 01 00 00       	jmp    c0102892 <__alltraps>

c01026a6 <vector215>:
.globl vector215
vector215:
  pushl $0
c01026a6:	6a 00                	push   $0x0
  pushl $215
c01026a8:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01026ad:	e9 e0 01 00 00       	jmp    c0102892 <__alltraps>

c01026b2 <vector216>:
.globl vector216
vector216:
  pushl $0
c01026b2:	6a 00                	push   $0x0
  pushl $216
c01026b4:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01026b9:	e9 d4 01 00 00       	jmp    c0102892 <__alltraps>

c01026be <vector217>:
.globl vector217
vector217:
  pushl $0
c01026be:	6a 00                	push   $0x0
  pushl $217
c01026c0:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01026c5:	e9 c8 01 00 00       	jmp    c0102892 <__alltraps>

c01026ca <vector218>:
.globl vector218
vector218:
  pushl $0
c01026ca:	6a 00                	push   $0x0
  pushl $218
c01026cc:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01026d1:	e9 bc 01 00 00       	jmp    c0102892 <__alltraps>

c01026d6 <vector219>:
.globl vector219
vector219:
  pushl $0
c01026d6:	6a 00                	push   $0x0
  pushl $219
c01026d8:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01026dd:	e9 b0 01 00 00       	jmp    c0102892 <__alltraps>

c01026e2 <vector220>:
.globl vector220
vector220:
  pushl $0
c01026e2:	6a 00                	push   $0x0
  pushl $220
c01026e4:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01026e9:	e9 a4 01 00 00       	jmp    c0102892 <__alltraps>

c01026ee <vector221>:
.globl vector221
vector221:
  pushl $0
c01026ee:	6a 00                	push   $0x0
  pushl $221
c01026f0:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01026f5:	e9 98 01 00 00       	jmp    c0102892 <__alltraps>

c01026fa <vector222>:
.globl vector222
vector222:
  pushl $0
c01026fa:	6a 00                	push   $0x0
  pushl $222
c01026fc:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102701:	e9 8c 01 00 00       	jmp    c0102892 <__alltraps>

c0102706 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102706:	6a 00                	push   $0x0
  pushl $223
c0102708:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010270d:	e9 80 01 00 00       	jmp    c0102892 <__alltraps>

c0102712 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102712:	6a 00                	push   $0x0
  pushl $224
c0102714:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102719:	e9 74 01 00 00       	jmp    c0102892 <__alltraps>

c010271e <vector225>:
.globl vector225
vector225:
  pushl $0
c010271e:	6a 00                	push   $0x0
  pushl $225
c0102720:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102725:	e9 68 01 00 00       	jmp    c0102892 <__alltraps>

c010272a <vector226>:
.globl vector226
vector226:
  pushl $0
c010272a:	6a 00                	push   $0x0
  pushl $226
c010272c:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102731:	e9 5c 01 00 00       	jmp    c0102892 <__alltraps>

c0102736 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102736:	6a 00                	push   $0x0
  pushl $227
c0102738:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010273d:	e9 50 01 00 00       	jmp    c0102892 <__alltraps>

c0102742 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102742:	6a 00                	push   $0x0
  pushl $228
c0102744:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102749:	e9 44 01 00 00       	jmp    c0102892 <__alltraps>

c010274e <vector229>:
.globl vector229
vector229:
  pushl $0
c010274e:	6a 00                	push   $0x0
  pushl $229
c0102750:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102755:	e9 38 01 00 00       	jmp    c0102892 <__alltraps>

c010275a <vector230>:
.globl vector230
vector230:
  pushl $0
c010275a:	6a 00                	push   $0x0
  pushl $230
c010275c:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102761:	e9 2c 01 00 00       	jmp    c0102892 <__alltraps>

c0102766 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102766:	6a 00                	push   $0x0
  pushl $231
c0102768:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010276d:	e9 20 01 00 00       	jmp    c0102892 <__alltraps>

c0102772 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102772:	6a 00                	push   $0x0
  pushl $232
c0102774:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102779:	e9 14 01 00 00       	jmp    c0102892 <__alltraps>

c010277e <vector233>:
.globl vector233
vector233:
  pushl $0
c010277e:	6a 00                	push   $0x0
  pushl $233
c0102780:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102785:	e9 08 01 00 00       	jmp    c0102892 <__alltraps>

c010278a <vector234>:
.globl vector234
vector234:
  pushl $0
c010278a:	6a 00                	push   $0x0
  pushl $234
c010278c:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102791:	e9 fc 00 00 00       	jmp    c0102892 <__alltraps>

c0102796 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102796:	6a 00                	push   $0x0
  pushl $235
c0102798:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010279d:	e9 f0 00 00 00       	jmp    c0102892 <__alltraps>

c01027a2 <vector236>:
.globl vector236
vector236:
  pushl $0
c01027a2:	6a 00                	push   $0x0
  pushl $236
c01027a4:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01027a9:	e9 e4 00 00 00       	jmp    c0102892 <__alltraps>

c01027ae <vector237>:
.globl vector237
vector237:
  pushl $0
c01027ae:	6a 00                	push   $0x0
  pushl $237
c01027b0:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01027b5:	e9 d8 00 00 00       	jmp    c0102892 <__alltraps>

c01027ba <vector238>:
.globl vector238
vector238:
  pushl $0
c01027ba:	6a 00                	push   $0x0
  pushl $238
c01027bc:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01027c1:	e9 cc 00 00 00       	jmp    c0102892 <__alltraps>

c01027c6 <vector239>:
.globl vector239
vector239:
  pushl $0
c01027c6:	6a 00                	push   $0x0
  pushl $239
c01027c8:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01027cd:	e9 c0 00 00 00       	jmp    c0102892 <__alltraps>

c01027d2 <vector240>:
.globl vector240
vector240:
  pushl $0
c01027d2:	6a 00                	push   $0x0
  pushl $240
c01027d4:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01027d9:	e9 b4 00 00 00       	jmp    c0102892 <__alltraps>

c01027de <vector241>:
.globl vector241
vector241:
  pushl $0
c01027de:	6a 00                	push   $0x0
  pushl $241
c01027e0:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01027e5:	e9 a8 00 00 00       	jmp    c0102892 <__alltraps>

c01027ea <vector242>:
.globl vector242
vector242:
  pushl $0
c01027ea:	6a 00                	push   $0x0
  pushl $242
c01027ec:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01027f1:	e9 9c 00 00 00       	jmp    c0102892 <__alltraps>

c01027f6 <vector243>:
.globl vector243
vector243:
  pushl $0
c01027f6:	6a 00                	push   $0x0
  pushl $243
c01027f8:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01027fd:	e9 90 00 00 00       	jmp    c0102892 <__alltraps>

c0102802 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102802:	6a 00                	push   $0x0
  pushl $244
c0102804:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102809:	e9 84 00 00 00       	jmp    c0102892 <__alltraps>

c010280e <vector245>:
.globl vector245
vector245:
  pushl $0
c010280e:	6a 00                	push   $0x0
  pushl $245
c0102810:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102815:	e9 78 00 00 00       	jmp    c0102892 <__alltraps>

c010281a <vector246>:
.globl vector246
vector246:
  pushl $0
c010281a:	6a 00                	push   $0x0
  pushl $246
c010281c:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102821:	e9 6c 00 00 00       	jmp    c0102892 <__alltraps>

c0102826 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102826:	6a 00                	push   $0x0
  pushl $247
c0102828:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010282d:	e9 60 00 00 00       	jmp    c0102892 <__alltraps>

c0102832 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102832:	6a 00                	push   $0x0
  pushl $248
c0102834:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102839:	e9 54 00 00 00       	jmp    c0102892 <__alltraps>

c010283e <vector249>:
.globl vector249
vector249:
  pushl $0
c010283e:	6a 00                	push   $0x0
  pushl $249
c0102840:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102845:	e9 48 00 00 00       	jmp    c0102892 <__alltraps>

c010284a <vector250>:
.globl vector250
vector250:
  pushl $0
c010284a:	6a 00                	push   $0x0
  pushl $250
c010284c:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102851:	e9 3c 00 00 00       	jmp    c0102892 <__alltraps>

c0102856 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102856:	6a 00                	push   $0x0
  pushl $251
c0102858:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010285d:	e9 30 00 00 00       	jmp    c0102892 <__alltraps>

c0102862 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102862:	6a 00                	push   $0x0
  pushl $252
c0102864:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102869:	e9 24 00 00 00       	jmp    c0102892 <__alltraps>

c010286e <vector253>:
.globl vector253
vector253:
  pushl $0
c010286e:	6a 00                	push   $0x0
  pushl $253
c0102870:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102875:	e9 18 00 00 00       	jmp    c0102892 <__alltraps>

c010287a <vector254>:
.globl vector254
vector254:
  pushl $0
c010287a:	6a 00                	push   $0x0
  pushl $254
c010287c:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102881:	e9 0c 00 00 00       	jmp    c0102892 <__alltraps>

c0102886 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102886:	6a 00                	push   $0x0
  pushl $255
c0102888:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010288d:	e9 00 00 00 00       	jmp    c0102892 <__alltraps>

c0102892 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102892:	1e                   	push   %ds
    pushl %es
c0102893:	06                   	push   %es
    pushl %fs
c0102894:	0f a0                	push   %fs
    pushl %gs
c0102896:	0f a8                	push   %gs
    pushal
c0102898:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102899:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010289e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01028a0:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01028a2:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01028a3:	e8 61 f5 ff ff       	call   c0101e09 <trap>

    # pop the pushed stack pointer
    popl %esp
c01028a8:	5c                   	pop    %esp

c01028a9 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01028a9:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01028aa:	0f a9                	pop    %gs
    popl %fs
c01028ac:	0f a1                	pop    %fs
    popl %es
c01028ae:	07                   	pop    %es
    popl %ds
c01028af:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01028b0:	83 c4 08             	add    $0x8,%esp
    iret
c01028b3:	cf                   	iret   

c01028b4 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01028b4:	55                   	push   %ebp
c01028b5:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01028b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01028ba:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c01028c0:	29 d0                	sub    %edx,%eax
c01028c2:	c1 f8 02             	sar    $0x2,%eax
c01028c5:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01028cb:	5d                   	pop    %ebp
c01028cc:	c3                   	ret    

c01028cd <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01028cd:	55                   	push   %ebp
c01028ce:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c01028d0:	ff 75 08             	pushl  0x8(%ebp)
c01028d3:	e8 dc ff ff ff       	call   c01028b4 <page2ppn>
c01028d8:	83 c4 04             	add    $0x4,%esp
c01028db:	c1 e0 0c             	shl    $0xc,%eax
}
c01028de:	c9                   	leave  
c01028df:	c3                   	ret    

c01028e0 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01028e0:	55                   	push   %ebp
c01028e1:	89 e5                	mov    %esp,%ebp
c01028e3:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c01028e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01028e9:	c1 e8 0c             	shr    $0xc,%eax
c01028ec:	89 c2                	mov    %eax,%edx
c01028ee:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01028f3:	39 c2                	cmp    %eax,%edx
c01028f5:	72 14                	jb     c010290b <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c01028f7:	83 ec 04             	sub    $0x4,%esp
c01028fa:	68 b0 61 10 c0       	push   $0xc01061b0
c01028ff:	6a 5a                	push   $0x5a
c0102901:	68 cf 61 10 c0       	push   $0xc01061cf
c0102906:	e8 ce da ff ff       	call   c01003d9 <__panic>
    }
    return &pages[PPN(pa)];
c010290b:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c0102911:	8b 45 08             	mov    0x8(%ebp),%eax
c0102914:	c1 e8 0c             	shr    $0xc,%eax
c0102917:	89 c2                	mov    %eax,%edx
c0102919:	89 d0                	mov    %edx,%eax
c010291b:	c1 e0 02             	shl    $0x2,%eax
c010291e:	01 d0                	add    %edx,%eax
c0102920:	c1 e0 02             	shl    $0x2,%eax
c0102923:	01 c8                	add    %ecx,%eax
}
c0102925:	c9                   	leave  
c0102926:	c3                   	ret    

c0102927 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0102927:	55                   	push   %ebp
c0102928:	89 e5                	mov    %esp,%ebp
c010292a:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c010292d:	ff 75 08             	pushl  0x8(%ebp)
c0102930:	e8 98 ff ff ff       	call   c01028cd <page2pa>
c0102935:	83 c4 04             	add    $0x4,%esp
c0102938:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010293b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010293e:	c1 e8 0c             	shr    $0xc,%eax
c0102941:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102944:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102949:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010294c:	72 14                	jb     c0102962 <page2kva+0x3b>
c010294e:	ff 75 f4             	pushl  -0xc(%ebp)
c0102951:	68 e0 61 10 c0       	push   $0xc01061e0
c0102956:	6a 61                	push   $0x61
c0102958:	68 cf 61 10 c0       	push   $0xc01061cf
c010295d:	e8 77 da ff ff       	call   c01003d9 <__panic>
c0102962:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102965:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010296a:	c9                   	leave  
c010296b:	c3                   	ret    

c010296c <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c010296c:	55                   	push   %ebp
c010296d:	89 e5                	mov    %esp,%ebp
c010296f:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c0102972:	8b 45 08             	mov    0x8(%ebp),%eax
c0102975:	83 e0 01             	and    $0x1,%eax
c0102978:	85 c0                	test   %eax,%eax
c010297a:	75 14                	jne    c0102990 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c010297c:	83 ec 04             	sub    $0x4,%esp
c010297f:	68 04 62 10 c0       	push   $0xc0106204
c0102984:	6a 6c                	push   $0x6c
c0102986:	68 cf 61 10 c0       	push   $0xc01061cf
c010298b:	e8 49 da ff ff       	call   c01003d9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102990:	8b 45 08             	mov    0x8(%ebp),%eax
c0102993:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102998:	83 ec 0c             	sub    $0xc,%esp
c010299b:	50                   	push   %eax
c010299c:	e8 3f ff ff ff       	call   c01028e0 <pa2page>
c01029a1:	83 c4 10             	add    $0x10,%esp
}
c01029a4:	c9                   	leave  
c01029a5:	c3                   	ret    

c01029a6 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c01029a6:	55                   	push   %ebp
c01029a7:	89 e5                	mov    %esp,%ebp
c01029a9:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c01029ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01029af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01029b4:	83 ec 0c             	sub    $0xc,%esp
c01029b7:	50                   	push   %eax
c01029b8:	e8 23 ff ff ff       	call   c01028e0 <pa2page>
c01029bd:	83 c4 10             	add    $0x10,%esp
}
c01029c0:	c9                   	leave  
c01029c1:	c3                   	ret    

c01029c2 <page_ref>:

static inline int
page_ref(struct Page *page) {
c01029c2:	55                   	push   %ebp
c01029c3:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01029c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01029c8:	8b 00                	mov    (%eax),%eax
}
c01029ca:	5d                   	pop    %ebp
c01029cb:	c3                   	ret    

c01029cc <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01029cc:	55                   	push   %ebp
c01029cd:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01029cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01029d2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029d5:	89 10                	mov    %edx,(%eax)
}
c01029d7:	90                   	nop
c01029d8:	5d                   	pop    %ebp
c01029d9:	c3                   	ret    

c01029da <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01029da:	55                   	push   %ebp
c01029db:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01029dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e0:	8b 00                	mov    (%eax),%eax
c01029e2:	8d 50 01             	lea    0x1(%eax),%edx
c01029e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e8:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01029ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ed:	8b 00                	mov    (%eax),%eax
}
c01029ef:	5d                   	pop    %ebp
c01029f0:	c3                   	ret    

c01029f1 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01029f1:	55                   	push   %ebp
c01029f2:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01029f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f7:	8b 00                	mov    (%eax),%eax
c01029f9:	8d 50 ff             	lea    -0x1(%eax),%edx
c01029fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ff:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102a01:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a04:	8b 00                	mov    (%eax),%eax
}
c0102a06:	5d                   	pop    %ebp
c0102a07:	c3                   	ret    

c0102a08 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0102a08:	55                   	push   %ebp
c0102a09:	89 e5                	mov    %esp,%ebp
c0102a0b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102a0e:	9c                   	pushf  
c0102a0f:	58                   	pop    %eax
c0102a10:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102a16:	25 00 02 00 00       	and    $0x200,%eax
c0102a1b:	85 c0                	test   %eax,%eax
c0102a1d:	74 0c                	je     c0102a2b <__intr_save+0x23>
        intr_disable();
c0102a1f:	e8 64 ee ff ff       	call   c0101888 <intr_disable>
        return 1;
c0102a24:	b8 01 00 00 00       	mov    $0x1,%eax
c0102a29:	eb 05                	jmp    c0102a30 <__intr_save+0x28>
    }
    return 0;
c0102a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102a30:	c9                   	leave  
c0102a31:	c3                   	ret    

c0102a32 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0102a32:	55                   	push   %ebp
c0102a33:	89 e5                	mov    %esp,%ebp
c0102a35:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102a38:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a3c:	74 05                	je     c0102a43 <__intr_restore+0x11>
        intr_enable();
c0102a3e:	e8 3e ee ff ff       	call   c0101881 <intr_enable>
    }
}
c0102a43:	90                   	nop
c0102a44:	c9                   	leave  
c0102a45:	c3                   	ret    

c0102a46 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102a46:	55                   	push   %ebp
c0102a47:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102a49:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a4c:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102a4f:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a54:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102a56:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a5b:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102a5d:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a62:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102a64:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a69:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102a6b:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a70:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102a72:	ea 79 2a 10 c0 08 00 	ljmp   $0x8,$0xc0102a79
}
c0102a79:	90                   	nop
c0102a7a:	5d                   	pop    %ebp
c0102a7b:	c3                   	ret    

c0102a7c <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102a7c:	55                   	push   %ebp
c0102a7d:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102a7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a82:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0102a87:	90                   	nop
c0102a88:	5d                   	pop    %ebp
c0102a89:	c3                   	ret    

c0102a8a <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102a8a:	55                   	push   %ebp
c0102a8b:	89 e5                	mov    %esp,%ebp
c0102a8d:	83 ec 10             	sub    $0x10,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102a90:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0102a95:	50                   	push   %eax
c0102a96:	e8 e1 ff ff ff       	call   c0102a7c <load_esp0>
c0102a9b:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
c0102a9e:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0102aa5:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102aa7:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0102aae:	68 00 
c0102ab0:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102ab5:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0102abb:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102ac0:	c1 e8 10             	shr    $0x10,%eax
c0102ac3:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0102ac8:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102acf:	83 e0 f0             	and    $0xfffffff0,%eax
c0102ad2:	83 c8 09             	or     $0x9,%eax
c0102ad5:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102ada:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102ae1:	83 e0 ef             	and    $0xffffffef,%eax
c0102ae4:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102ae9:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102af0:	83 e0 9f             	and    $0xffffff9f,%eax
c0102af3:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102af8:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102aff:	83 c8 80             	or     $0xffffff80,%eax
c0102b02:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102b07:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b0e:	83 e0 f0             	and    $0xfffffff0,%eax
c0102b11:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b16:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b1d:	83 e0 ef             	and    $0xffffffef,%eax
c0102b20:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b25:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b2c:	83 e0 df             	and    $0xffffffdf,%eax
c0102b2f:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b34:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b3b:	83 c8 40             	or     $0x40,%eax
c0102b3e:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b43:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b4a:	83 e0 7f             	and    $0x7f,%eax
c0102b4d:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b52:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102b57:	c1 e8 18             	shr    $0x18,%eax
c0102b5a:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102b5f:	68 30 7a 11 c0       	push   $0xc0117a30
c0102b64:	e8 dd fe ff ff       	call   c0102a46 <lgdt>
c0102b69:	83 c4 04             	add    $0x4,%esp
c0102b6c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102b72:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102b76:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102b79:	90                   	nop
c0102b7a:	c9                   	leave  
c0102b7b:	c3                   	ret    

c0102b7c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102b7c:	55                   	push   %ebp
c0102b7d:	89 e5                	mov    %esp,%ebp
c0102b7f:	83 ec 08             	sub    $0x8,%esp
    pmm_manager = &default_pmm_manager;
c0102b82:	c7 05 10 af 11 c0 90 	movl   $0xc0106b90,0xc011af10
c0102b89:	6b 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b8c:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102b91:	8b 00                	mov    (%eax),%eax
c0102b93:	83 ec 08             	sub    $0x8,%esp
c0102b96:	50                   	push   %eax
c0102b97:	68 30 62 10 c0       	push   $0xc0106230
c0102b9c:	e8 d2 d6 ff ff       	call   c0100273 <cprintf>
c0102ba1:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
c0102ba4:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102ba9:	8b 40 04             	mov    0x4(%eax),%eax
c0102bac:	ff d0                	call   *%eax
}
c0102bae:	90                   	nop
c0102baf:	c9                   	leave  
c0102bb0:	c3                   	ret    

c0102bb1 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102bb1:	55                   	push   %ebp
c0102bb2:	89 e5                	mov    %esp,%ebp
c0102bb4:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->init_memmap(base, n);
c0102bb7:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102bbc:	8b 40 08             	mov    0x8(%eax),%eax
c0102bbf:	83 ec 08             	sub    $0x8,%esp
c0102bc2:	ff 75 0c             	pushl  0xc(%ebp)
c0102bc5:	ff 75 08             	pushl  0x8(%ebp)
c0102bc8:	ff d0                	call   *%eax
c0102bca:	83 c4 10             	add    $0x10,%esp
}
c0102bcd:	90                   	nop
c0102bce:	c9                   	leave  
c0102bcf:	c3                   	ret    

c0102bd0 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102bd0:	55                   	push   %ebp
c0102bd1:	89 e5                	mov    %esp,%ebp
c0102bd3:	83 ec 18             	sub    $0x18,%esp
    struct Page *page=NULL;
c0102bd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bdd:	e8 26 fe ff ff       	call   c0102a08 <__intr_save>
c0102be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102be5:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102bea:	8b 40 0c             	mov    0xc(%eax),%eax
c0102bed:	83 ec 0c             	sub    $0xc,%esp
c0102bf0:	ff 75 08             	pushl  0x8(%ebp)
c0102bf3:	ff d0                	call   *%eax
c0102bf5:	83 c4 10             	add    $0x10,%esp
c0102bf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102bfb:	83 ec 0c             	sub    $0xc,%esp
c0102bfe:	ff 75 f0             	pushl  -0x10(%ebp)
c0102c01:	e8 2c fe ff ff       	call   c0102a32 <__intr_restore>
c0102c06:	83 c4 10             	add    $0x10,%esp
    return page;
c0102c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102c0c:	c9                   	leave  
c0102c0d:	c3                   	ret    

c0102c0e <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102c0e:	55                   	push   %ebp
c0102c0f:	89 e5                	mov    %esp,%ebp
c0102c11:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c14:	e8 ef fd ff ff       	call   c0102a08 <__intr_save>
c0102c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102c1c:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102c21:	8b 40 10             	mov    0x10(%eax),%eax
c0102c24:	83 ec 08             	sub    $0x8,%esp
c0102c27:	ff 75 0c             	pushl  0xc(%ebp)
c0102c2a:	ff 75 08             	pushl  0x8(%ebp)
c0102c2d:	ff d0                	call   *%eax
c0102c2f:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c0102c32:	83 ec 0c             	sub    $0xc,%esp
c0102c35:	ff 75 f4             	pushl  -0xc(%ebp)
c0102c38:	e8 f5 fd ff ff       	call   c0102a32 <__intr_restore>
c0102c3d:	83 c4 10             	add    $0x10,%esp
}
c0102c40:	90                   	nop
c0102c41:	c9                   	leave  
c0102c42:	c3                   	ret    

c0102c43 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102c43:	55                   	push   %ebp
c0102c44:	89 e5                	mov    %esp,%ebp
c0102c46:	83 ec 18             	sub    $0x18,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c49:	e8 ba fd ff ff       	call   c0102a08 <__intr_save>
c0102c4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102c51:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102c56:	8b 40 14             	mov    0x14(%eax),%eax
c0102c59:	ff d0                	call   *%eax
c0102c5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102c5e:	83 ec 0c             	sub    $0xc,%esp
c0102c61:	ff 75 f4             	pushl  -0xc(%ebp)
c0102c64:	e8 c9 fd ff ff       	call   c0102a32 <__intr_restore>
c0102c69:	83 c4 10             	add    $0x10,%esp
    return ret;
c0102c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102c6f:	c9                   	leave  
c0102c70:	c3                   	ret    

c0102c71 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102c71:	55                   	push   %ebp
c0102c72:	89 e5                	mov    %esp,%ebp
c0102c74:	57                   	push   %edi
c0102c75:	56                   	push   %esi
c0102c76:	53                   	push   %ebx
c0102c77:	83 ec 7c             	sub    $0x7c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102c7a:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102c81:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102c88:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102c8f:	83 ec 0c             	sub    $0xc,%esp
c0102c92:	68 47 62 10 c0       	push   $0xc0106247
c0102c97:	e8 d7 d5 ff ff       	call   c0100273 <cprintf>
c0102c9c:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102c9f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102ca6:	e9 fc 00 00 00       	jmp    c0102da7 <page_init+0x136>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102cab:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cae:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cb1:	89 d0                	mov    %edx,%eax
c0102cb3:	c1 e0 02             	shl    $0x2,%eax
c0102cb6:	01 d0                	add    %edx,%eax
c0102cb8:	c1 e0 02             	shl    $0x2,%eax
c0102cbb:	01 c8                	add    %ecx,%eax
c0102cbd:	8b 50 08             	mov    0x8(%eax),%edx
c0102cc0:	8b 40 04             	mov    0x4(%eax),%eax
c0102cc3:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102cc6:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0102cc9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ccc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ccf:	89 d0                	mov    %edx,%eax
c0102cd1:	c1 e0 02             	shl    $0x2,%eax
c0102cd4:	01 d0                	add    %edx,%eax
c0102cd6:	c1 e0 02             	shl    $0x2,%eax
c0102cd9:	01 c8                	add    %ecx,%eax
c0102cdb:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102cde:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ce1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102ce4:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102ce7:	01 c8                	add    %ecx,%eax
c0102ce9:	11 da                	adc    %ebx,%edx
c0102ceb:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0102cee:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102cf1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cf4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cf7:	89 d0                	mov    %edx,%eax
c0102cf9:	c1 e0 02             	shl    $0x2,%eax
c0102cfc:	01 d0                	add    %edx,%eax
c0102cfe:	c1 e0 02             	shl    $0x2,%eax
c0102d01:	01 c8                	add    %ecx,%eax
c0102d03:	83 c0 14             	add    $0x14,%eax
c0102d06:	8b 00                	mov    (%eax),%eax
c0102d08:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102d0b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102d0e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102d11:	83 c0 ff             	add    $0xffffffff,%eax
c0102d14:	83 d2 ff             	adc    $0xffffffff,%edx
c0102d17:	89 c1                	mov    %eax,%ecx
c0102d19:	89 d3                	mov    %edx,%ebx
c0102d1b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102d1e:	89 55 80             	mov    %edx,-0x80(%ebp)
c0102d21:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d24:	89 d0                	mov    %edx,%eax
c0102d26:	c1 e0 02             	shl    $0x2,%eax
c0102d29:	01 d0                	add    %edx,%eax
c0102d2b:	c1 e0 02             	shl    $0x2,%eax
c0102d2e:	03 45 80             	add    -0x80(%ebp),%eax
c0102d31:	8b 50 10             	mov    0x10(%eax),%edx
c0102d34:	8b 40 0c             	mov    0xc(%eax),%eax
c0102d37:	ff 75 84             	pushl  -0x7c(%ebp)
c0102d3a:	53                   	push   %ebx
c0102d3b:	51                   	push   %ecx
c0102d3c:	ff 75 bc             	pushl  -0x44(%ebp)
c0102d3f:	ff 75 b8             	pushl  -0x48(%ebp)
c0102d42:	52                   	push   %edx
c0102d43:	50                   	push   %eax
c0102d44:	68 54 62 10 c0       	push   $0xc0106254
c0102d49:	e8 25 d5 ff ff       	call   c0100273 <cprintf>
c0102d4e:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102d51:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d54:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d57:	89 d0                	mov    %edx,%eax
c0102d59:	c1 e0 02             	shl    $0x2,%eax
c0102d5c:	01 d0                	add    %edx,%eax
c0102d5e:	c1 e0 02             	shl    $0x2,%eax
c0102d61:	01 c8                	add    %ecx,%eax
c0102d63:	83 c0 14             	add    $0x14,%eax
c0102d66:	8b 00                	mov    (%eax),%eax
c0102d68:	83 f8 01             	cmp    $0x1,%eax
c0102d6b:	75 36                	jne    c0102da3 <page_init+0x132>
            if (maxpa < end && begin < KMEMSIZE) {
c0102d6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d73:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102d76:	77 2b                	ja     c0102da3 <page_init+0x132>
c0102d78:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102d7b:	72 05                	jb     c0102d82 <page_init+0x111>
c0102d7d:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0102d80:	73 21                	jae    c0102da3 <page_init+0x132>
c0102d82:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102d86:	77 1b                	ja     c0102da3 <page_init+0x132>
c0102d88:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102d8c:	72 09                	jb     c0102d97 <page_init+0x126>
c0102d8e:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0102d95:	77 0c                	ja     c0102da3 <page_init+0x132>
                maxpa = end;
c0102d97:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102d9a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102d9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102da0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102da3:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0102da7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102daa:	8b 00                	mov    (%eax),%eax
c0102dac:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0102daf:	0f 8f f6 fe ff ff    	jg     c0102cab <page_init+0x3a>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102db5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102db9:	72 1d                	jb     c0102dd8 <page_init+0x167>
c0102dbb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102dbf:	77 09                	ja     c0102dca <page_init+0x159>
c0102dc1:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102dc8:	76 0e                	jbe    c0102dd8 <page_init+0x167>
        maxpa = KMEMSIZE;
c0102dca:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102dd1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102dd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ddb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102dde:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102de2:	c1 ea 0c             	shr    $0xc,%edx
c0102de5:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102dea:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0102df1:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0102df6:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102df9:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102dfc:	01 d0                	add    %edx,%eax
c0102dfe:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102e01:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102e04:	ba 00 00 00 00       	mov    $0x0,%edx
c0102e09:	f7 75 ac             	divl   -0x54(%ebp)
c0102e0c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102e0f:	29 d0                	sub    %edx,%eax
c0102e11:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    for (i = 0; i < npage; i ++) {
c0102e16:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e1d:	eb 2f                	jmp    c0102e4e <page_init+0x1dd>
        SetPageReserved(pages + i);
c0102e1f:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c0102e25:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e28:	89 d0                	mov    %edx,%eax
c0102e2a:	c1 e0 02             	shl    $0x2,%eax
c0102e2d:	01 d0                	add    %edx,%eax
c0102e2f:	c1 e0 02             	shl    $0x2,%eax
c0102e32:	01 c8                	add    %ecx,%eax
c0102e34:	83 c0 04             	add    $0x4,%eax
c0102e37:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0102e3e:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e41:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102e44:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102e47:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0102e4a:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0102e4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e51:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102e56:	39 c2                	cmp    %eax,%edx
c0102e58:	72 c5                	jb     c0102e1f <page_init+0x1ae>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102e5a:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102e60:	89 d0                	mov    %edx,%eax
c0102e62:	c1 e0 02             	shl    $0x2,%eax
c0102e65:	01 d0                	add    %edx,%eax
c0102e67:	c1 e0 02             	shl    $0x2,%eax
c0102e6a:	89 c2                	mov    %eax,%edx
c0102e6c:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102e71:	01 d0                	add    %edx,%eax
c0102e73:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0102e76:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0102e7d:	77 17                	ja     c0102e96 <page_init+0x225>
c0102e7f:	ff 75 a4             	pushl  -0x5c(%ebp)
c0102e82:	68 84 62 10 c0       	push   $0xc0106284
c0102e87:	68 dc 00 00 00       	push   $0xdc
c0102e8c:	68 a8 62 10 c0       	push   $0xc01062a8
c0102e91:	e8 43 d5 ff ff       	call   c01003d9 <__panic>
c0102e96:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102e99:	05 00 00 00 40       	add    $0x40000000,%eax
c0102e9e:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102ea1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102ea8:	e9 69 01 00 00       	jmp    c0103016 <page_init+0x3a5>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102ead:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102eb0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102eb3:	89 d0                	mov    %edx,%eax
c0102eb5:	c1 e0 02             	shl    $0x2,%eax
c0102eb8:	01 d0                	add    %edx,%eax
c0102eba:	c1 e0 02             	shl    $0x2,%eax
c0102ebd:	01 c8                	add    %ecx,%eax
c0102ebf:	8b 50 08             	mov    0x8(%eax),%edx
c0102ec2:	8b 40 04             	mov    0x4(%eax),%eax
c0102ec5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ec8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102ecb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ece:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ed1:	89 d0                	mov    %edx,%eax
c0102ed3:	c1 e0 02             	shl    $0x2,%eax
c0102ed6:	01 d0                	add    %edx,%eax
c0102ed8:	c1 e0 02             	shl    $0x2,%eax
c0102edb:	01 c8                	add    %ecx,%eax
c0102edd:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102ee0:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ee3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102ee6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102ee9:	01 c8                	add    %ecx,%eax
c0102eeb:	11 da                	adc    %ebx,%edx
c0102eed:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102ef0:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102ef3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ef6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ef9:	89 d0                	mov    %edx,%eax
c0102efb:	c1 e0 02             	shl    $0x2,%eax
c0102efe:	01 d0                	add    %edx,%eax
c0102f00:	c1 e0 02             	shl    $0x2,%eax
c0102f03:	01 c8                	add    %ecx,%eax
c0102f05:	83 c0 14             	add    $0x14,%eax
c0102f08:	8b 00                	mov    (%eax),%eax
c0102f0a:	83 f8 01             	cmp    $0x1,%eax
c0102f0d:	0f 85 ff 00 00 00    	jne    c0103012 <page_init+0x3a1>
            if (begin < freemem) {
c0102f13:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f16:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f1b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102f1e:	72 17                	jb     c0102f37 <page_init+0x2c6>
c0102f20:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102f23:	77 05                	ja     c0102f2a <page_init+0x2b9>
c0102f25:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0102f28:	76 0d                	jbe    c0102f37 <page_init+0x2c6>
                begin = freemem;
c0102f2a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f30:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102f37:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f3b:	72 1d                	jb     c0102f5a <page_init+0x2e9>
c0102f3d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f41:	77 09                	ja     c0102f4c <page_init+0x2db>
c0102f43:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102f4a:	76 0e                	jbe    c0102f5a <page_init+0x2e9>
                end = KMEMSIZE;
c0102f4c:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102f53:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102f5a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f5d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f60:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f63:	0f 87 a9 00 00 00    	ja     c0103012 <page_init+0x3a1>
c0102f69:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f6c:	72 09                	jb     c0102f77 <page_init+0x306>
c0102f6e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f71:	0f 83 9b 00 00 00    	jae    c0103012 <page_init+0x3a1>
                begin = ROUNDUP(begin, PGSIZE);
c0102f77:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0102f7e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102f81:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102f84:	01 d0                	add    %edx,%eax
c0102f86:	83 e8 01             	sub    $0x1,%eax
c0102f89:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102f8c:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f8f:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f94:	f7 75 9c             	divl   -0x64(%ebp)
c0102f97:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f9a:	29 d0                	sub    %edx,%eax
c0102f9c:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fa1:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102fa4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0102fa7:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102faa:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102fad:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102fb0:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fb5:	89 c3                	mov    %eax,%ebx
c0102fb7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0102fbd:	89 de                	mov    %ebx,%esi
c0102fbf:	89 d0                	mov    %edx,%eax
c0102fc1:	83 e0 00             	and    $0x0,%eax
c0102fc4:	89 c7                	mov    %eax,%edi
c0102fc6:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0102fc9:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0102fcc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102fcf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102fd2:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102fd5:	77 3b                	ja     c0103012 <page_init+0x3a1>
c0102fd7:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102fda:	72 05                	jb     c0102fe1 <page_init+0x370>
c0102fdc:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102fdf:	73 31                	jae    c0103012 <page_init+0x3a1>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0102fe1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102fe4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102fe7:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0102fea:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0102fed:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102ff1:	c1 ea 0c             	shr    $0xc,%edx
c0102ff4:	89 c3                	mov    %eax,%ebx
c0102ff6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102ff9:	83 ec 0c             	sub    $0xc,%esp
c0102ffc:	50                   	push   %eax
c0102ffd:	e8 de f8 ff ff       	call   c01028e0 <pa2page>
c0103002:	83 c4 10             	add    $0x10,%esp
c0103005:	83 ec 08             	sub    $0x8,%esp
c0103008:	53                   	push   %ebx
c0103009:	50                   	push   %eax
c010300a:	e8 a2 fb ff ff       	call   c0102bb1 <init_memmap>
c010300f:	83 c4 10             	add    $0x10,%esp
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0103012:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103016:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103019:	8b 00                	mov    (%eax),%eax
c010301b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010301e:	0f 8f 89 fe ff ff    	jg     c0102ead <page_init+0x23c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0103024:	90                   	nop
c0103025:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103028:	5b                   	pop    %ebx
c0103029:	5e                   	pop    %esi
c010302a:	5f                   	pop    %edi
c010302b:	5d                   	pop    %ebp
c010302c:	c3                   	ret    

c010302d <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010302d:	55                   	push   %ebp
c010302e:	89 e5                	mov    %esp,%ebp
c0103030:	83 ec 28             	sub    $0x28,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0103033:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103036:	33 45 14             	xor    0x14(%ebp),%eax
c0103039:	25 ff 0f 00 00       	and    $0xfff,%eax
c010303e:	85 c0                	test   %eax,%eax
c0103040:	74 19                	je     c010305b <boot_map_segment+0x2e>
c0103042:	68 b6 62 10 c0       	push   $0xc01062b6
c0103047:	68 cd 62 10 c0       	push   $0xc01062cd
c010304c:	68 fa 00 00 00       	push   $0xfa
c0103051:	68 a8 62 10 c0       	push   $0xc01062a8
c0103056:	e8 7e d3 ff ff       	call   c01003d9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010305b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103062:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103065:	25 ff 0f 00 00       	and    $0xfff,%eax
c010306a:	89 c2                	mov    %eax,%edx
c010306c:	8b 45 10             	mov    0x10(%ebp),%eax
c010306f:	01 c2                	add    %eax,%edx
c0103071:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103074:	01 d0                	add    %edx,%eax
c0103076:	83 e8 01             	sub    $0x1,%eax
c0103079:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010307c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010307f:	ba 00 00 00 00       	mov    $0x0,%edx
c0103084:	f7 75 f0             	divl   -0x10(%ebp)
c0103087:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010308a:	29 d0                	sub    %edx,%eax
c010308c:	c1 e8 0c             	shr    $0xc,%eax
c010308f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103092:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103095:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103098:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010309b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01030a0:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01030a3:	8b 45 14             	mov    0x14(%ebp),%eax
c01030a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01030a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01030ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01030b1:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01030b4:	eb 57                	jmp    c010310d <boot_map_segment+0xe0>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01030b6:	83 ec 04             	sub    $0x4,%esp
c01030b9:	6a 01                	push   $0x1
c01030bb:	ff 75 0c             	pushl  0xc(%ebp)
c01030be:	ff 75 08             	pushl  0x8(%ebp)
c01030c1:	e8 53 01 00 00       	call   c0103219 <get_pte>
c01030c6:	83 c4 10             	add    $0x10,%esp
c01030c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01030cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01030d0:	75 19                	jne    c01030eb <boot_map_segment+0xbe>
c01030d2:	68 e2 62 10 c0       	push   $0xc01062e2
c01030d7:	68 cd 62 10 c0       	push   $0xc01062cd
c01030dc:	68 00 01 00 00       	push   $0x100
c01030e1:	68 a8 62 10 c0       	push   $0xc01062a8
c01030e6:	e8 ee d2 ff ff       	call   c01003d9 <__panic>
        *ptep = pa | PTE_P | perm;
c01030eb:	8b 45 14             	mov    0x14(%ebp),%eax
c01030ee:	0b 45 18             	or     0x18(%ebp),%eax
c01030f1:	83 c8 01             	or     $0x1,%eax
c01030f4:	89 c2                	mov    %eax,%edx
c01030f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030f9:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01030fb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01030ff:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0103106:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c010310d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103111:	75 a3                	jne    c01030b6 <boot_map_segment+0x89>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0103113:	90                   	nop
c0103114:	c9                   	leave  
c0103115:	c3                   	ret    

c0103116 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0103116:	55                   	push   %ebp
c0103117:	89 e5                	mov    %esp,%ebp
c0103119:	83 ec 18             	sub    $0x18,%esp
    struct Page *p = alloc_page();
c010311c:	83 ec 0c             	sub    $0xc,%esp
c010311f:	6a 01                	push   $0x1
c0103121:	e8 aa fa ff ff       	call   c0102bd0 <alloc_pages>
c0103126:	83 c4 10             	add    $0x10,%esp
c0103129:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010312c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103130:	75 17                	jne    c0103149 <boot_alloc_page+0x33>
        panic("boot_alloc_page failed.\n");
c0103132:	83 ec 04             	sub    $0x4,%esp
c0103135:	68 ef 62 10 c0       	push   $0xc01062ef
c010313a:	68 0c 01 00 00       	push   $0x10c
c010313f:	68 a8 62 10 c0       	push   $0xc01062a8
c0103144:	e8 90 d2 ff ff       	call   c01003d9 <__panic>
    }
    return page2kva(p);
c0103149:	83 ec 0c             	sub    $0xc,%esp
c010314c:	ff 75 f4             	pushl  -0xc(%ebp)
c010314f:	e8 d3 f7 ff ff       	call   c0102927 <page2kva>
c0103154:	83 c4 10             	add    $0x10,%esp
}
c0103157:	c9                   	leave  
c0103158:	c3                   	ret    

c0103159 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0103159:	55                   	push   %ebp
c010315a:	89 e5                	mov    %esp,%ebp
c010315c:	83 ec 18             	sub    $0x18,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010315f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103164:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103167:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010316e:	77 17                	ja     c0103187 <pmm_init+0x2e>
c0103170:	ff 75 f4             	pushl  -0xc(%ebp)
c0103173:	68 84 62 10 c0       	push   $0xc0106284
c0103178:	68 16 01 00 00       	push   $0x116
c010317d:	68 a8 62 10 c0       	push   $0xc01062a8
c0103182:	e8 52 d2 ff ff       	call   c01003d9 <__panic>
c0103187:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010318a:	05 00 00 00 40       	add    $0x40000000,%eax
c010318f:	a3 14 af 11 c0       	mov    %eax,0xc011af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103194:	e8 e3 f9 ff ff       	call   c0102b7c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103199:	e8 d3 fa ff ff       	call   c0102c71 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010319e:	e8 9d 03 00 00       	call   c0103540 <check_alloc_page>

    check_pgdir();
c01031a3:	e8 bb 03 00 00       	call   c0103563 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01031a8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01031ad:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01031b3:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01031b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01031bb:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01031c2:	77 17                	ja     c01031db <pmm_init+0x82>
c01031c4:	ff 75 f0             	pushl  -0x10(%ebp)
c01031c7:	68 84 62 10 c0       	push   $0xc0106284
c01031cc:	68 2c 01 00 00       	push   $0x12c
c01031d1:	68 a8 62 10 c0       	push   $0xc01062a8
c01031d6:	e8 fe d1 ff ff       	call   c01003d9 <__panic>
c01031db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031de:	05 00 00 00 40       	add    $0x40000000,%eax
c01031e3:	83 c8 03             	or     $0x3,%eax
c01031e6:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01031e8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01031ed:	83 ec 0c             	sub    $0xc,%esp
c01031f0:	6a 02                	push   $0x2
c01031f2:	6a 00                	push   $0x0
c01031f4:	68 00 00 00 38       	push   $0x38000000
c01031f9:	68 00 00 00 c0       	push   $0xc0000000
c01031fe:	50                   	push   %eax
c01031ff:	e8 29 fe ff ff       	call   c010302d <boot_map_segment>
c0103204:	83 c4 20             	add    $0x20,%esp

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103207:	e8 7e f8 ff ff       	call   c0102a8a <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010320c:	e8 b8 08 00 00       	call   c0103ac9 <check_boot_pgdir>

    print_pgdir();
c0103211:	e8 ae 0c 00 00       	call   c0103ec4 <print_pgdir>

}
c0103216:	90                   	nop
c0103217:	c9                   	leave  
c0103218:	c3                   	ret    

c0103219 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103219:	55                   	push   %ebp
c010321a:	89 e5                	mov    %esp,%ebp
c010321c:	83 ec 28             	sub    $0x28,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif*/
    pde_t *pdep = &(pgdir[PDX(la)]);
c010321f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103222:	c1 e8 16             	shr    $0x16,%eax
c0103225:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010322c:	8b 45 08             	mov    0x8(%ebp),%eax
c010322f:	01 d0                	add    %edx,%eax
c0103231:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if ( !(*pdep & PTE_P)) {
c0103234:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103237:	8b 00                	mov    (%eax),%eax
c0103239:	83 e0 01             	and    $0x1,%eax
c010323c:	85 c0                	test   %eax,%eax
c010323e:	0f 85 ac 00 00 00    	jne    c01032f0 <get_pte+0xd7>
        if (create) {
c0103244:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103248:	0f 84 9b 00 00 00    	je     c01032e9 <get_pte+0xd0>
            struct Page *page_new = alloc_page();
c010324e:	83 ec 0c             	sub    $0xc,%esp
c0103251:	6a 01                	push   $0x1
c0103253:	e8 78 f9 ff ff       	call   c0102bd0 <alloc_pages>
c0103258:	83 c4 10             	add    $0x10,%esp
c010325b:	89 45 f0             	mov    %eax,-0x10(%ebp)
            if (page_new == NULL) {
c010325e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103262:	75 0a                	jne    c010326e <get_pte+0x55>
                return NULL;
c0103264:	b8 00 00 00 00       	mov    $0x0,%eax
c0103269:	e9 d3 00 00 00       	jmp    c0103341 <get_pte+0x128>
            }
            set_page_ref(page_new, 1);
c010326e:	83 ec 08             	sub    $0x8,%esp
c0103271:	6a 01                	push   $0x1
c0103273:	ff 75 f0             	pushl  -0x10(%ebp)
c0103276:	e8 51 f7 ff ff       	call   c01029cc <set_page_ref>
c010327b:	83 c4 10             	add    $0x10,%esp
            uintptr_t pa = page2pa(page_new);
c010327e:	83 ec 0c             	sub    $0xc,%esp
c0103281:	ff 75 f0             	pushl  -0x10(%ebp)
c0103284:	e8 44 f6 ff ff       	call   c01028cd <page2pa>
c0103289:	83 c4 10             	add    $0x10,%esp
c010328c:	89 45 ec             	mov    %eax,-0x14(%ebp)
            memset(KADDR(pa), 0, PGSIZE);
c010328f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103292:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103295:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103298:	c1 e8 0c             	shr    $0xc,%eax
c010329b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010329e:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01032a3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01032a6:	72 17                	jb     c01032bf <get_pte+0xa6>
c01032a8:	ff 75 e8             	pushl  -0x18(%ebp)
c01032ab:	68 e0 61 10 c0       	push   $0xc01061e0
c01032b0:	68 73 01 00 00       	push   $0x173
c01032b5:	68 a8 62 10 c0       	push   $0xc01062a8
c01032ba:	e8 1a d1 ff ff       	call   c01003d9 <__panic>
c01032bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032c2:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01032c7:	83 ec 04             	sub    $0x4,%esp
c01032ca:	68 00 10 00 00       	push   $0x1000
c01032cf:	6a 00                	push   $0x0
c01032d1:	50                   	push   %eax
c01032d2:	e8 02 20 00 00       	call   c01052d9 <memset>
c01032d7:	83 c4 10             	add    $0x10,%esp
            *pdep = pa | PTE_U | PTE_W | PTE_P;
c01032da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032dd:	83 c8 07             	or     $0x7,%eax
c01032e0:	89 c2                	mov    %eax,%edx
c01032e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032e5:	89 10                	mov    %edx,(%eax)
c01032e7:	eb 07                	jmp    c01032f0 <get_pte+0xd7>
        }
        else {
            return NULL;
c01032e9:	b8 00 00 00 00       	mov    $0x0,%eax
c01032ee:	eb 51                	jmp    c0103341 <get_pte+0x128>
        }
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];  
c01032f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032f3:	8b 00                	mov    (%eax),%eax
c01032f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01032fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103300:	c1 e8 0c             	shr    $0xc,%eax
c0103303:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103306:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010330b:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010330e:	72 17                	jb     c0103327 <get_pte+0x10e>
c0103310:	ff 75 e0             	pushl  -0x20(%ebp)
c0103313:	68 e0 61 10 c0       	push   $0xc01061e0
c0103318:	68 7a 01 00 00       	push   $0x17a
c010331d:	68 a8 62 10 c0       	push   $0xc01062a8
c0103322:	e8 b2 d0 ff ff       	call   c01003d9 <__panic>
c0103327:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010332a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010332f:	89 c2                	mov    %eax,%edx
c0103331:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103334:	c1 e8 0c             	shr    $0xc,%eax
c0103337:	25 ff 03 00 00       	and    $0x3ff,%eax
c010333c:	c1 e0 02             	shl    $0x2,%eax
c010333f:	01 d0                	add    %edx,%eax
}
c0103341:	c9                   	leave  
c0103342:	c3                   	ret    

c0103343 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0103343:	55                   	push   %ebp
c0103344:	89 e5                	mov    %esp,%ebp
c0103346:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103349:	83 ec 04             	sub    $0x4,%esp
c010334c:	6a 00                	push   $0x0
c010334e:	ff 75 0c             	pushl  0xc(%ebp)
c0103351:	ff 75 08             	pushl  0x8(%ebp)
c0103354:	e8 c0 fe ff ff       	call   c0103219 <get_pte>
c0103359:	83 c4 10             	add    $0x10,%esp
c010335c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010335f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103363:	74 08                	je     c010336d <get_page+0x2a>
        *ptep_store = ptep;
c0103365:	8b 45 10             	mov    0x10(%ebp),%eax
c0103368:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010336b:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010336d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103371:	74 1f                	je     c0103392 <get_page+0x4f>
c0103373:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103376:	8b 00                	mov    (%eax),%eax
c0103378:	83 e0 01             	and    $0x1,%eax
c010337b:	85 c0                	test   %eax,%eax
c010337d:	74 13                	je     c0103392 <get_page+0x4f>
        return pte2page(*ptep);
c010337f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103382:	8b 00                	mov    (%eax),%eax
c0103384:	83 ec 0c             	sub    $0xc,%esp
c0103387:	50                   	push   %eax
c0103388:	e8 df f5 ff ff       	call   c010296c <pte2page>
c010338d:	83 c4 10             	add    $0x10,%esp
c0103390:	eb 05                	jmp    c0103397 <get_page+0x54>
    }
    return NULL;
c0103392:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103397:	c9                   	leave  
c0103398:	c3                   	ret    

c0103399 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103399:	55                   	push   %ebp
c010339a:	89 e5                	mov    %esp,%ebp
c010339c:	83 ec 18             	sub    $0x18,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif*/
    if (*ptep & PTE_P) {
c010339f:	8b 45 10             	mov    0x10(%ebp),%eax
c01033a2:	8b 00                	mov    (%eax),%eax
c01033a4:	83 e0 01             	and    $0x1,%eax
c01033a7:	85 c0                	test   %eax,%eax
c01033a9:	74 50                	je     c01033fb <page_remove_pte+0x62>
        struct Page *page = pte2page(*ptep);
c01033ab:	8b 45 10             	mov    0x10(%ebp),%eax
c01033ae:	8b 00                	mov    (%eax),%eax
c01033b0:	83 ec 0c             	sub    $0xc,%esp
c01033b3:	50                   	push   %eax
c01033b4:	e8 b3 f5 ff ff       	call   c010296c <pte2page>
c01033b9:	83 c4 10             	add    $0x10,%esp
c01033bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if ((page_ref_dec(page)) == 0) {
c01033bf:	83 ec 0c             	sub    $0xc,%esp
c01033c2:	ff 75 f4             	pushl  -0xc(%ebp)
c01033c5:	e8 27 f6 ff ff       	call   c01029f1 <page_ref_dec>
c01033ca:	83 c4 10             	add    $0x10,%esp
c01033cd:	85 c0                	test   %eax,%eax
c01033cf:	75 10                	jne    c01033e1 <page_remove_pte+0x48>
            free_page(page);
c01033d1:	83 ec 08             	sub    $0x8,%esp
c01033d4:	6a 01                	push   $0x1
c01033d6:	ff 75 f4             	pushl  -0xc(%ebp)
c01033d9:	e8 30 f8 ff ff       	call   c0102c0e <free_pages>
c01033de:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0;
c01033e1:	8b 45 10             	mov    0x10(%ebp),%eax
c01033e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01033ea:	83 ec 08             	sub    $0x8,%esp
c01033ed:	ff 75 0c             	pushl  0xc(%ebp)
c01033f0:	ff 75 08             	pushl  0x8(%ebp)
c01033f3:	e8 f8 00 00 00       	call   c01034f0 <tlb_invalidate>
c01033f8:	83 c4 10             	add    $0x10,%esp
    }
}
c01033fb:	90                   	nop
c01033fc:	c9                   	leave  
c01033fd:	c3                   	ret    

c01033fe <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01033fe:	55                   	push   %ebp
c01033ff:	89 e5                	mov    %esp,%ebp
c0103401:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103404:	83 ec 04             	sub    $0x4,%esp
c0103407:	6a 00                	push   $0x0
c0103409:	ff 75 0c             	pushl  0xc(%ebp)
c010340c:	ff 75 08             	pushl  0x8(%ebp)
c010340f:	e8 05 fe ff ff       	call   c0103219 <get_pte>
c0103414:	83 c4 10             	add    $0x10,%esp
c0103417:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010341a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010341e:	74 14                	je     c0103434 <page_remove+0x36>
        page_remove_pte(pgdir, la, ptep);
c0103420:	83 ec 04             	sub    $0x4,%esp
c0103423:	ff 75 f4             	pushl  -0xc(%ebp)
c0103426:	ff 75 0c             	pushl  0xc(%ebp)
c0103429:	ff 75 08             	pushl  0x8(%ebp)
c010342c:	e8 68 ff ff ff       	call   c0103399 <page_remove_pte>
c0103431:	83 c4 10             	add    $0x10,%esp
    }
}
c0103434:	90                   	nop
c0103435:	c9                   	leave  
c0103436:	c3                   	ret    

c0103437 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103437:	55                   	push   %ebp
c0103438:	89 e5                	mov    %esp,%ebp
c010343a:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010343d:	83 ec 04             	sub    $0x4,%esp
c0103440:	6a 01                	push   $0x1
c0103442:	ff 75 10             	pushl  0x10(%ebp)
c0103445:	ff 75 08             	pushl  0x8(%ebp)
c0103448:	e8 cc fd ff ff       	call   c0103219 <get_pte>
c010344d:	83 c4 10             	add    $0x10,%esp
c0103450:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0103453:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103457:	75 0a                	jne    c0103463 <page_insert+0x2c>
        return -E_NO_MEM;
c0103459:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010345e:	e9 8b 00 00 00       	jmp    c01034ee <page_insert+0xb7>
    }
    page_ref_inc(page);
c0103463:	83 ec 0c             	sub    $0xc,%esp
c0103466:	ff 75 0c             	pushl  0xc(%ebp)
c0103469:	e8 6c f5 ff ff       	call   c01029da <page_ref_inc>
c010346e:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {
c0103471:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103474:	8b 00                	mov    (%eax),%eax
c0103476:	83 e0 01             	and    $0x1,%eax
c0103479:	85 c0                	test   %eax,%eax
c010347b:	74 40                	je     c01034bd <page_insert+0x86>
        struct Page *p = pte2page(*ptep);
c010347d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103480:	8b 00                	mov    (%eax),%eax
c0103482:	83 ec 0c             	sub    $0xc,%esp
c0103485:	50                   	push   %eax
c0103486:	e8 e1 f4 ff ff       	call   c010296c <pte2page>
c010348b:	83 c4 10             	add    $0x10,%esp
c010348e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0103491:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103494:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103497:	75 10                	jne    c01034a9 <page_insert+0x72>
            page_ref_dec(page);
c0103499:	83 ec 0c             	sub    $0xc,%esp
c010349c:	ff 75 0c             	pushl  0xc(%ebp)
c010349f:	e8 4d f5 ff ff       	call   c01029f1 <page_ref_dec>
c01034a4:	83 c4 10             	add    $0x10,%esp
c01034a7:	eb 14                	jmp    c01034bd <page_insert+0x86>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01034a9:	83 ec 04             	sub    $0x4,%esp
c01034ac:	ff 75 f4             	pushl  -0xc(%ebp)
c01034af:	ff 75 10             	pushl  0x10(%ebp)
c01034b2:	ff 75 08             	pushl  0x8(%ebp)
c01034b5:	e8 df fe ff ff       	call   c0103399 <page_remove_pte>
c01034ba:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01034bd:	83 ec 0c             	sub    $0xc,%esp
c01034c0:	ff 75 0c             	pushl  0xc(%ebp)
c01034c3:	e8 05 f4 ff ff       	call   c01028cd <page2pa>
c01034c8:	83 c4 10             	add    $0x10,%esp
c01034cb:	0b 45 14             	or     0x14(%ebp),%eax
c01034ce:	83 c8 01             	or     $0x1,%eax
c01034d1:	89 c2                	mov    %eax,%edx
c01034d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034d6:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01034d8:	83 ec 08             	sub    $0x8,%esp
c01034db:	ff 75 10             	pushl  0x10(%ebp)
c01034de:	ff 75 08             	pushl  0x8(%ebp)
c01034e1:	e8 0a 00 00 00       	call   c01034f0 <tlb_invalidate>
c01034e6:	83 c4 10             	add    $0x10,%esp
    return 0;
c01034e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01034ee:	c9                   	leave  
c01034ef:	c3                   	ret    

c01034f0 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01034f0:	55                   	push   %ebp
c01034f1:	89 e5                	mov    %esp,%ebp
c01034f3:	83 ec 18             	sub    $0x18,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01034f6:	0f 20 d8             	mov    %cr3,%eax
c01034f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c01034fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01034ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0103502:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103505:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010350c:	77 17                	ja     c0103525 <tlb_invalidate+0x35>
c010350e:	ff 75 f0             	pushl  -0x10(%ebp)
c0103511:	68 84 62 10 c0       	push   $0xc0106284
c0103516:	68 dc 01 00 00       	push   $0x1dc
c010351b:	68 a8 62 10 c0       	push   $0xc01062a8
c0103520:	e8 b4 ce ff ff       	call   c01003d9 <__panic>
c0103525:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103528:	05 00 00 00 40       	add    $0x40000000,%eax
c010352d:	39 c2                	cmp    %eax,%edx
c010352f:	75 0c                	jne    c010353d <tlb_invalidate+0x4d>
        invlpg((void *)la);
c0103531:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103534:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103537:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010353a:	0f 01 38             	invlpg (%eax)
    }
}
c010353d:	90                   	nop
c010353e:	c9                   	leave  
c010353f:	c3                   	ret    

c0103540 <check_alloc_page>:

static void
check_alloc_page(void) {
c0103540:	55                   	push   %ebp
c0103541:	89 e5                	mov    %esp,%ebp
c0103543:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->check();
c0103546:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c010354b:	8b 40 18             	mov    0x18(%eax),%eax
c010354e:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0103550:	83 ec 0c             	sub    $0xc,%esp
c0103553:	68 08 63 10 c0       	push   $0xc0106308
c0103558:	e8 16 cd ff ff       	call   c0100273 <cprintf>
c010355d:	83 c4 10             	add    $0x10,%esp
}
c0103560:	90                   	nop
c0103561:	c9                   	leave  
c0103562:	c3                   	ret    

c0103563 <check_pgdir>:

static void
check_pgdir(void) {
c0103563:	55                   	push   %ebp
c0103564:	89 e5                	mov    %esp,%ebp
c0103566:	83 ec 28             	sub    $0x28,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0103569:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010356e:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103573:	76 19                	jbe    c010358e <check_pgdir+0x2b>
c0103575:	68 27 63 10 c0       	push   $0xc0106327
c010357a:	68 cd 62 10 c0       	push   $0xc01062cd
c010357f:	68 e9 01 00 00       	push   $0x1e9
c0103584:	68 a8 62 10 c0       	push   $0xc01062a8
c0103589:	e8 4b ce ff ff       	call   c01003d9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010358e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103593:	85 c0                	test   %eax,%eax
c0103595:	74 0e                	je     c01035a5 <check_pgdir+0x42>
c0103597:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010359c:	25 ff 0f 00 00       	and    $0xfff,%eax
c01035a1:	85 c0                	test   %eax,%eax
c01035a3:	74 19                	je     c01035be <check_pgdir+0x5b>
c01035a5:	68 44 63 10 c0       	push   $0xc0106344
c01035aa:	68 cd 62 10 c0       	push   $0xc01062cd
c01035af:	68 ea 01 00 00       	push   $0x1ea
c01035b4:	68 a8 62 10 c0       	push   $0xc01062a8
c01035b9:	e8 1b ce ff ff       	call   c01003d9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01035be:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01035c3:	83 ec 04             	sub    $0x4,%esp
c01035c6:	6a 00                	push   $0x0
c01035c8:	6a 00                	push   $0x0
c01035ca:	50                   	push   %eax
c01035cb:	e8 73 fd ff ff       	call   c0103343 <get_page>
c01035d0:	83 c4 10             	add    $0x10,%esp
c01035d3:	85 c0                	test   %eax,%eax
c01035d5:	74 19                	je     c01035f0 <check_pgdir+0x8d>
c01035d7:	68 7c 63 10 c0       	push   $0xc010637c
c01035dc:	68 cd 62 10 c0       	push   $0xc01062cd
c01035e1:	68 eb 01 00 00       	push   $0x1eb
c01035e6:	68 a8 62 10 c0       	push   $0xc01062a8
c01035eb:	e8 e9 cd ff ff       	call   c01003d9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01035f0:	83 ec 0c             	sub    $0xc,%esp
c01035f3:	6a 01                	push   $0x1
c01035f5:	e8 d6 f5 ff ff       	call   c0102bd0 <alloc_pages>
c01035fa:	83 c4 10             	add    $0x10,%esp
c01035fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0103600:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103605:	6a 00                	push   $0x0
c0103607:	6a 00                	push   $0x0
c0103609:	ff 75 f4             	pushl  -0xc(%ebp)
c010360c:	50                   	push   %eax
c010360d:	e8 25 fe ff ff       	call   c0103437 <page_insert>
c0103612:	83 c4 10             	add    $0x10,%esp
c0103615:	85 c0                	test   %eax,%eax
c0103617:	74 19                	je     c0103632 <check_pgdir+0xcf>
c0103619:	68 a4 63 10 c0       	push   $0xc01063a4
c010361e:	68 cd 62 10 c0       	push   $0xc01062cd
c0103623:	68 ef 01 00 00       	push   $0x1ef
c0103628:	68 a8 62 10 c0       	push   $0xc01062a8
c010362d:	e8 a7 cd ff ff       	call   c01003d9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103632:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103637:	83 ec 04             	sub    $0x4,%esp
c010363a:	6a 00                	push   $0x0
c010363c:	6a 00                	push   $0x0
c010363e:	50                   	push   %eax
c010363f:	e8 d5 fb ff ff       	call   c0103219 <get_pte>
c0103644:	83 c4 10             	add    $0x10,%esp
c0103647:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010364a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010364e:	75 19                	jne    c0103669 <check_pgdir+0x106>
c0103650:	68 d0 63 10 c0       	push   $0xc01063d0
c0103655:	68 cd 62 10 c0       	push   $0xc01062cd
c010365a:	68 f2 01 00 00       	push   $0x1f2
c010365f:	68 a8 62 10 c0       	push   $0xc01062a8
c0103664:	e8 70 cd ff ff       	call   c01003d9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103669:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010366c:	8b 00                	mov    (%eax),%eax
c010366e:	83 ec 0c             	sub    $0xc,%esp
c0103671:	50                   	push   %eax
c0103672:	e8 f5 f2 ff ff       	call   c010296c <pte2page>
c0103677:	83 c4 10             	add    $0x10,%esp
c010367a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010367d:	74 19                	je     c0103698 <check_pgdir+0x135>
c010367f:	68 fd 63 10 c0       	push   $0xc01063fd
c0103684:	68 cd 62 10 c0       	push   $0xc01062cd
c0103689:	68 f3 01 00 00       	push   $0x1f3
c010368e:	68 a8 62 10 c0       	push   $0xc01062a8
c0103693:	e8 41 cd ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p1) == 1);
c0103698:	83 ec 0c             	sub    $0xc,%esp
c010369b:	ff 75 f4             	pushl  -0xc(%ebp)
c010369e:	e8 1f f3 ff ff       	call   c01029c2 <page_ref>
c01036a3:	83 c4 10             	add    $0x10,%esp
c01036a6:	83 f8 01             	cmp    $0x1,%eax
c01036a9:	74 19                	je     c01036c4 <check_pgdir+0x161>
c01036ab:	68 13 64 10 c0       	push   $0xc0106413
c01036b0:	68 cd 62 10 c0       	push   $0xc01062cd
c01036b5:	68 f4 01 00 00       	push   $0x1f4
c01036ba:	68 a8 62 10 c0       	push   $0xc01062a8
c01036bf:	e8 15 cd ff ff       	call   c01003d9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01036c4:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01036c9:	8b 00                	mov    (%eax),%eax
c01036cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01036d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01036d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036d6:	c1 e8 0c             	shr    $0xc,%eax
c01036d9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01036dc:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01036e1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01036e4:	72 17                	jb     c01036fd <check_pgdir+0x19a>
c01036e6:	ff 75 ec             	pushl  -0x14(%ebp)
c01036e9:	68 e0 61 10 c0       	push   $0xc01061e0
c01036ee:	68 f6 01 00 00       	push   $0x1f6
c01036f3:	68 a8 62 10 c0       	push   $0xc01062a8
c01036f8:	e8 dc cc ff ff       	call   c01003d9 <__panic>
c01036fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103700:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103705:	83 c0 04             	add    $0x4,%eax
c0103708:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010370b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103710:	83 ec 04             	sub    $0x4,%esp
c0103713:	6a 00                	push   $0x0
c0103715:	68 00 10 00 00       	push   $0x1000
c010371a:	50                   	push   %eax
c010371b:	e8 f9 fa ff ff       	call   c0103219 <get_pte>
c0103720:	83 c4 10             	add    $0x10,%esp
c0103723:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103726:	74 19                	je     c0103741 <check_pgdir+0x1de>
c0103728:	68 28 64 10 c0       	push   $0xc0106428
c010372d:	68 cd 62 10 c0       	push   $0xc01062cd
c0103732:	68 f7 01 00 00       	push   $0x1f7
c0103737:	68 a8 62 10 c0       	push   $0xc01062a8
c010373c:	e8 98 cc ff ff       	call   c01003d9 <__panic>

    p2 = alloc_page();
c0103741:	83 ec 0c             	sub    $0xc,%esp
c0103744:	6a 01                	push   $0x1
c0103746:	e8 85 f4 ff ff       	call   c0102bd0 <alloc_pages>
c010374b:	83 c4 10             	add    $0x10,%esp
c010374e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0103751:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103756:	6a 06                	push   $0x6
c0103758:	68 00 10 00 00       	push   $0x1000
c010375d:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103760:	50                   	push   %eax
c0103761:	e8 d1 fc ff ff       	call   c0103437 <page_insert>
c0103766:	83 c4 10             	add    $0x10,%esp
c0103769:	85 c0                	test   %eax,%eax
c010376b:	74 19                	je     c0103786 <check_pgdir+0x223>
c010376d:	68 50 64 10 c0       	push   $0xc0106450
c0103772:	68 cd 62 10 c0       	push   $0xc01062cd
c0103777:	68 fa 01 00 00       	push   $0x1fa
c010377c:	68 a8 62 10 c0       	push   $0xc01062a8
c0103781:	e8 53 cc ff ff       	call   c01003d9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103786:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010378b:	83 ec 04             	sub    $0x4,%esp
c010378e:	6a 00                	push   $0x0
c0103790:	68 00 10 00 00       	push   $0x1000
c0103795:	50                   	push   %eax
c0103796:	e8 7e fa ff ff       	call   c0103219 <get_pte>
c010379b:	83 c4 10             	add    $0x10,%esp
c010379e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01037a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01037a5:	75 19                	jne    c01037c0 <check_pgdir+0x25d>
c01037a7:	68 88 64 10 c0       	push   $0xc0106488
c01037ac:	68 cd 62 10 c0       	push   $0xc01062cd
c01037b1:	68 fb 01 00 00       	push   $0x1fb
c01037b6:	68 a8 62 10 c0       	push   $0xc01062a8
c01037bb:	e8 19 cc ff ff       	call   c01003d9 <__panic>
    assert(*ptep & PTE_U);
c01037c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037c3:	8b 00                	mov    (%eax),%eax
c01037c5:	83 e0 04             	and    $0x4,%eax
c01037c8:	85 c0                	test   %eax,%eax
c01037ca:	75 19                	jne    c01037e5 <check_pgdir+0x282>
c01037cc:	68 b8 64 10 c0       	push   $0xc01064b8
c01037d1:	68 cd 62 10 c0       	push   $0xc01062cd
c01037d6:	68 fc 01 00 00       	push   $0x1fc
c01037db:	68 a8 62 10 c0       	push   $0xc01062a8
c01037e0:	e8 f4 cb ff ff       	call   c01003d9 <__panic>
    assert(*ptep & PTE_W);
c01037e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037e8:	8b 00                	mov    (%eax),%eax
c01037ea:	83 e0 02             	and    $0x2,%eax
c01037ed:	85 c0                	test   %eax,%eax
c01037ef:	75 19                	jne    c010380a <check_pgdir+0x2a7>
c01037f1:	68 c6 64 10 c0       	push   $0xc01064c6
c01037f6:	68 cd 62 10 c0       	push   $0xc01062cd
c01037fb:	68 fd 01 00 00       	push   $0x1fd
c0103800:	68 a8 62 10 c0       	push   $0xc01062a8
c0103805:	e8 cf cb ff ff       	call   c01003d9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010380a:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010380f:	8b 00                	mov    (%eax),%eax
c0103811:	83 e0 04             	and    $0x4,%eax
c0103814:	85 c0                	test   %eax,%eax
c0103816:	75 19                	jne    c0103831 <check_pgdir+0x2ce>
c0103818:	68 d4 64 10 c0       	push   $0xc01064d4
c010381d:	68 cd 62 10 c0       	push   $0xc01062cd
c0103822:	68 fe 01 00 00       	push   $0x1fe
c0103827:	68 a8 62 10 c0       	push   $0xc01062a8
c010382c:	e8 a8 cb ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p2) == 1);
c0103831:	83 ec 0c             	sub    $0xc,%esp
c0103834:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103837:	e8 86 f1 ff ff       	call   c01029c2 <page_ref>
c010383c:	83 c4 10             	add    $0x10,%esp
c010383f:	83 f8 01             	cmp    $0x1,%eax
c0103842:	74 19                	je     c010385d <check_pgdir+0x2fa>
c0103844:	68 ea 64 10 c0       	push   $0xc01064ea
c0103849:	68 cd 62 10 c0       	push   $0xc01062cd
c010384e:	68 ff 01 00 00       	push   $0x1ff
c0103853:	68 a8 62 10 c0       	push   $0xc01062a8
c0103858:	e8 7c cb ff ff       	call   c01003d9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c010385d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103862:	6a 00                	push   $0x0
c0103864:	68 00 10 00 00       	push   $0x1000
c0103869:	ff 75 f4             	pushl  -0xc(%ebp)
c010386c:	50                   	push   %eax
c010386d:	e8 c5 fb ff ff       	call   c0103437 <page_insert>
c0103872:	83 c4 10             	add    $0x10,%esp
c0103875:	85 c0                	test   %eax,%eax
c0103877:	74 19                	je     c0103892 <check_pgdir+0x32f>
c0103879:	68 fc 64 10 c0       	push   $0xc01064fc
c010387e:	68 cd 62 10 c0       	push   $0xc01062cd
c0103883:	68 01 02 00 00       	push   $0x201
c0103888:	68 a8 62 10 c0       	push   $0xc01062a8
c010388d:	e8 47 cb ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p1) == 2);
c0103892:	83 ec 0c             	sub    $0xc,%esp
c0103895:	ff 75 f4             	pushl  -0xc(%ebp)
c0103898:	e8 25 f1 ff ff       	call   c01029c2 <page_ref>
c010389d:	83 c4 10             	add    $0x10,%esp
c01038a0:	83 f8 02             	cmp    $0x2,%eax
c01038a3:	74 19                	je     c01038be <check_pgdir+0x35b>
c01038a5:	68 28 65 10 c0       	push   $0xc0106528
c01038aa:	68 cd 62 10 c0       	push   $0xc01062cd
c01038af:	68 02 02 00 00       	push   $0x202
c01038b4:	68 a8 62 10 c0       	push   $0xc01062a8
c01038b9:	e8 1b cb ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p2) == 0);
c01038be:	83 ec 0c             	sub    $0xc,%esp
c01038c1:	ff 75 e4             	pushl  -0x1c(%ebp)
c01038c4:	e8 f9 f0 ff ff       	call   c01029c2 <page_ref>
c01038c9:	83 c4 10             	add    $0x10,%esp
c01038cc:	85 c0                	test   %eax,%eax
c01038ce:	74 19                	je     c01038e9 <check_pgdir+0x386>
c01038d0:	68 3a 65 10 c0       	push   $0xc010653a
c01038d5:	68 cd 62 10 c0       	push   $0xc01062cd
c01038da:	68 03 02 00 00       	push   $0x203
c01038df:	68 a8 62 10 c0       	push   $0xc01062a8
c01038e4:	e8 f0 ca ff ff       	call   c01003d9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01038e9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01038ee:	83 ec 04             	sub    $0x4,%esp
c01038f1:	6a 00                	push   $0x0
c01038f3:	68 00 10 00 00       	push   $0x1000
c01038f8:	50                   	push   %eax
c01038f9:	e8 1b f9 ff ff       	call   c0103219 <get_pte>
c01038fe:	83 c4 10             	add    $0x10,%esp
c0103901:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103904:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103908:	75 19                	jne    c0103923 <check_pgdir+0x3c0>
c010390a:	68 88 64 10 c0       	push   $0xc0106488
c010390f:	68 cd 62 10 c0       	push   $0xc01062cd
c0103914:	68 04 02 00 00       	push   $0x204
c0103919:	68 a8 62 10 c0       	push   $0xc01062a8
c010391e:	e8 b6 ca ff ff       	call   c01003d9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103923:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103926:	8b 00                	mov    (%eax),%eax
c0103928:	83 ec 0c             	sub    $0xc,%esp
c010392b:	50                   	push   %eax
c010392c:	e8 3b f0 ff ff       	call   c010296c <pte2page>
c0103931:	83 c4 10             	add    $0x10,%esp
c0103934:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103937:	74 19                	je     c0103952 <check_pgdir+0x3ef>
c0103939:	68 fd 63 10 c0       	push   $0xc01063fd
c010393e:	68 cd 62 10 c0       	push   $0xc01062cd
c0103943:	68 05 02 00 00       	push   $0x205
c0103948:	68 a8 62 10 c0       	push   $0xc01062a8
c010394d:	e8 87 ca ff ff       	call   c01003d9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103952:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103955:	8b 00                	mov    (%eax),%eax
c0103957:	83 e0 04             	and    $0x4,%eax
c010395a:	85 c0                	test   %eax,%eax
c010395c:	74 19                	je     c0103977 <check_pgdir+0x414>
c010395e:	68 4c 65 10 c0       	push   $0xc010654c
c0103963:	68 cd 62 10 c0       	push   $0xc01062cd
c0103968:	68 06 02 00 00       	push   $0x206
c010396d:	68 a8 62 10 c0       	push   $0xc01062a8
c0103972:	e8 62 ca ff ff       	call   c01003d9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103977:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010397c:	83 ec 08             	sub    $0x8,%esp
c010397f:	6a 00                	push   $0x0
c0103981:	50                   	push   %eax
c0103982:	e8 77 fa ff ff       	call   c01033fe <page_remove>
c0103987:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
c010398a:	83 ec 0c             	sub    $0xc,%esp
c010398d:	ff 75 f4             	pushl  -0xc(%ebp)
c0103990:	e8 2d f0 ff ff       	call   c01029c2 <page_ref>
c0103995:	83 c4 10             	add    $0x10,%esp
c0103998:	83 f8 01             	cmp    $0x1,%eax
c010399b:	74 19                	je     c01039b6 <check_pgdir+0x453>
c010399d:	68 13 64 10 c0       	push   $0xc0106413
c01039a2:	68 cd 62 10 c0       	push   $0xc01062cd
c01039a7:	68 09 02 00 00       	push   $0x209
c01039ac:	68 a8 62 10 c0       	push   $0xc01062a8
c01039b1:	e8 23 ca ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p2) == 0);
c01039b6:	83 ec 0c             	sub    $0xc,%esp
c01039b9:	ff 75 e4             	pushl  -0x1c(%ebp)
c01039bc:	e8 01 f0 ff ff       	call   c01029c2 <page_ref>
c01039c1:	83 c4 10             	add    $0x10,%esp
c01039c4:	85 c0                	test   %eax,%eax
c01039c6:	74 19                	je     c01039e1 <check_pgdir+0x47e>
c01039c8:	68 3a 65 10 c0       	push   $0xc010653a
c01039cd:	68 cd 62 10 c0       	push   $0xc01062cd
c01039d2:	68 0a 02 00 00       	push   $0x20a
c01039d7:	68 a8 62 10 c0       	push   $0xc01062a8
c01039dc:	e8 f8 c9 ff ff       	call   c01003d9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01039e1:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01039e6:	83 ec 08             	sub    $0x8,%esp
c01039e9:	68 00 10 00 00       	push   $0x1000
c01039ee:	50                   	push   %eax
c01039ef:	e8 0a fa ff ff       	call   c01033fe <page_remove>
c01039f4:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
c01039f7:	83 ec 0c             	sub    $0xc,%esp
c01039fa:	ff 75 f4             	pushl  -0xc(%ebp)
c01039fd:	e8 c0 ef ff ff       	call   c01029c2 <page_ref>
c0103a02:	83 c4 10             	add    $0x10,%esp
c0103a05:	85 c0                	test   %eax,%eax
c0103a07:	74 19                	je     c0103a22 <check_pgdir+0x4bf>
c0103a09:	68 61 65 10 c0       	push   $0xc0106561
c0103a0e:	68 cd 62 10 c0       	push   $0xc01062cd
c0103a13:	68 0d 02 00 00       	push   $0x20d
c0103a18:	68 a8 62 10 c0       	push   $0xc01062a8
c0103a1d:	e8 b7 c9 ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p2) == 0);
c0103a22:	83 ec 0c             	sub    $0xc,%esp
c0103a25:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103a28:	e8 95 ef ff ff       	call   c01029c2 <page_ref>
c0103a2d:	83 c4 10             	add    $0x10,%esp
c0103a30:	85 c0                	test   %eax,%eax
c0103a32:	74 19                	je     c0103a4d <check_pgdir+0x4ea>
c0103a34:	68 3a 65 10 c0       	push   $0xc010653a
c0103a39:	68 cd 62 10 c0       	push   $0xc01062cd
c0103a3e:	68 0e 02 00 00       	push   $0x20e
c0103a43:	68 a8 62 10 c0       	push   $0xc01062a8
c0103a48:	e8 8c c9 ff ff       	call   c01003d9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103a4d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103a52:	8b 00                	mov    (%eax),%eax
c0103a54:	83 ec 0c             	sub    $0xc,%esp
c0103a57:	50                   	push   %eax
c0103a58:	e8 49 ef ff ff       	call   c01029a6 <pde2page>
c0103a5d:	83 c4 10             	add    $0x10,%esp
c0103a60:	83 ec 0c             	sub    $0xc,%esp
c0103a63:	50                   	push   %eax
c0103a64:	e8 59 ef ff ff       	call   c01029c2 <page_ref>
c0103a69:	83 c4 10             	add    $0x10,%esp
c0103a6c:	83 f8 01             	cmp    $0x1,%eax
c0103a6f:	74 19                	je     c0103a8a <check_pgdir+0x527>
c0103a71:	68 74 65 10 c0       	push   $0xc0106574
c0103a76:	68 cd 62 10 c0       	push   $0xc01062cd
c0103a7b:	68 10 02 00 00       	push   $0x210
c0103a80:	68 a8 62 10 c0       	push   $0xc01062a8
c0103a85:	e8 4f c9 ff ff       	call   c01003d9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103a8a:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103a8f:	8b 00                	mov    (%eax),%eax
c0103a91:	83 ec 0c             	sub    $0xc,%esp
c0103a94:	50                   	push   %eax
c0103a95:	e8 0c ef ff ff       	call   c01029a6 <pde2page>
c0103a9a:	83 c4 10             	add    $0x10,%esp
c0103a9d:	83 ec 08             	sub    $0x8,%esp
c0103aa0:	6a 01                	push   $0x1
c0103aa2:	50                   	push   %eax
c0103aa3:	e8 66 f1 ff ff       	call   c0102c0e <free_pages>
c0103aa8:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0103aab:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ab0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103ab6:	83 ec 0c             	sub    $0xc,%esp
c0103ab9:	68 9b 65 10 c0       	push   $0xc010659b
c0103abe:	e8 b0 c7 ff ff       	call   c0100273 <cprintf>
c0103ac3:	83 c4 10             	add    $0x10,%esp
}
c0103ac6:	90                   	nop
c0103ac7:	c9                   	leave  
c0103ac8:	c3                   	ret    

c0103ac9 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103ac9:	55                   	push   %ebp
c0103aca:	89 e5                	mov    %esp,%ebp
c0103acc:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103acf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103ad6:	e9 a3 00 00 00       	jmp    c0103b7e <check_boot_pgdir+0xb5>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ae4:	c1 e8 0c             	shr    $0xc,%eax
c0103ae7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103aea:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103aef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103af2:	72 17                	jb     c0103b0b <check_boot_pgdir+0x42>
c0103af4:	ff 75 f0             	pushl  -0x10(%ebp)
c0103af7:	68 e0 61 10 c0       	push   $0xc01061e0
c0103afc:	68 1c 02 00 00       	push   $0x21c
c0103b01:	68 a8 62 10 c0       	push   $0xc01062a8
c0103b06:	e8 ce c8 ff ff       	call   c01003d9 <__panic>
c0103b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b0e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103b13:	89 c2                	mov    %eax,%edx
c0103b15:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b1a:	83 ec 04             	sub    $0x4,%esp
c0103b1d:	6a 00                	push   $0x0
c0103b1f:	52                   	push   %edx
c0103b20:	50                   	push   %eax
c0103b21:	e8 f3 f6 ff ff       	call   c0103219 <get_pte>
c0103b26:	83 c4 10             	add    $0x10,%esp
c0103b29:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103b2c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103b30:	75 19                	jne    c0103b4b <check_boot_pgdir+0x82>
c0103b32:	68 b8 65 10 c0       	push   $0xc01065b8
c0103b37:	68 cd 62 10 c0       	push   $0xc01062cd
c0103b3c:	68 1c 02 00 00       	push   $0x21c
c0103b41:	68 a8 62 10 c0       	push   $0xc01062a8
c0103b46:	e8 8e c8 ff ff       	call   c01003d9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103b4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b4e:	8b 00                	mov    (%eax),%eax
c0103b50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b55:	89 c2                	mov    %eax,%edx
c0103b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b5a:	39 c2                	cmp    %eax,%edx
c0103b5c:	74 19                	je     c0103b77 <check_boot_pgdir+0xae>
c0103b5e:	68 f5 65 10 c0       	push   $0xc01065f5
c0103b63:	68 cd 62 10 c0       	push   $0xc01062cd
c0103b68:	68 1d 02 00 00       	push   $0x21d
c0103b6d:	68 a8 62 10 c0       	push   $0xc01062a8
c0103b72:	e8 62 c8 ff ff       	call   c01003d9 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103b77:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103b7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b81:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103b86:	39 c2                	cmp    %eax,%edx
c0103b88:	0f 82 4d ff ff ff    	jb     c0103adb <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103b8e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b93:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103b98:	8b 00                	mov    (%eax),%eax
c0103b9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b9f:	89 c2                	mov    %eax,%edx
c0103ba1:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ba6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103ba9:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0103bb0:	77 17                	ja     c0103bc9 <check_boot_pgdir+0x100>
c0103bb2:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103bb5:	68 84 62 10 c0       	push   $0xc0106284
c0103bba:	68 20 02 00 00       	push   $0x220
c0103bbf:	68 a8 62 10 c0       	push   $0xc01062a8
c0103bc4:	e8 10 c8 ff ff       	call   c01003d9 <__panic>
c0103bc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bcc:	05 00 00 00 40       	add    $0x40000000,%eax
c0103bd1:	39 c2                	cmp    %eax,%edx
c0103bd3:	74 19                	je     c0103bee <check_boot_pgdir+0x125>
c0103bd5:	68 0c 66 10 c0       	push   $0xc010660c
c0103bda:	68 cd 62 10 c0       	push   $0xc01062cd
c0103bdf:	68 20 02 00 00       	push   $0x220
c0103be4:	68 a8 62 10 c0       	push   $0xc01062a8
c0103be9:	e8 eb c7 ff ff       	call   c01003d9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103bee:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103bf3:	8b 00                	mov    (%eax),%eax
c0103bf5:	85 c0                	test   %eax,%eax
c0103bf7:	74 19                	je     c0103c12 <check_boot_pgdir+0x149>
c0103bf9:	68 40 66 10 c0       	push   $0xc0106640
c0103bfe:	68 cd 62 10 c0       	push   $0xc01062cd
c0103c03:	68 22 02 00 00       	push   $0x222
c0103c08:	68 a8 62 10 c0       	push   $0xc01062a8
c0103c0d:	e8 c7 c7 ff ff       	call   c01003d9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103c12:	83 ec 0c             	sub    $0xc,%esp
c0103c15:	6a 01                	push   $0x1
c0103c17:	e8 b4 ef ff ff       	call   c0102bd0 <alloc_pages>
c0103c1c:	83 c4 10             	add    $0x10,%esp
c0103c1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103c22:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c27:	6a 02                	push   $0x2
c0103c29:	68 00 01 00 00       	push   $0x100
c0103c2e:	ff 75 e0             	pushl  -0x20(%ebp)
c0103c31:	50                   	push   %eax
c0103c32:	e8 00 f8 ff ff       	call   c0103437 <page_insert>
c0103c37:	83 c4 10             	add    $0x10,%esp
c0103c3a:	85 c0                	test   %eax,%eax
c0103c3c:	74 19                	je     c0103c57 <check_boot_pgdir+0x18e>
c0103c3e:	68 54 66 10 c0       	push   $0xc0106654
c0103c43:	68 cd 62 10 c0       	push   $0xc01062cd
c0103c48:	68 26 02 00 00       	push   $0x226
c0103c4d:	68 a8 62 10 c0       	push   $0xc01062a8
c0103c52:	e8 82 c7 ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p) == 1);
c0103c57:	83 ec 0c             	sub    $0xc,%esp
c0103c5a:	ff 75 e0             	pushl  -0x20(%ebp)
c0103c5d:	e8 60 ed ff ff       	call   c01029c2 <page_ref>
c0103c62:	83 c4 10             	add    $0x10,%esp
c0103c65:	83 f8 01             	cmp    $0x1,%eax
c0103c68:	74 19                	je     c0103c83 <check_boot_pgdir+0x1ba>
c0103c6a:	68 82 66 10 c0       	push   $0xc0106682
c0103c6f:	68 cd 62 10 c0       	push   $0xc01062cd
c0103c74:	68 27 02 00 00       	push   $0x227
c0103c79:	68 a8 62 10 c0       	push   $0xc01062a8
c0103c7e:	e8 56 c7 ff ff       	call   c01003d9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103c83:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c88:	6a 02                	push   $0x2
c0103c8a:	68 00 11 00 00       	push   $0x1100
c0103c8f:	ff 75 e0             	pushl  -0x20(%ebp)
c0103c92:	50                   	push   %eax
c0103c93:	e8 9f f7 ff ff       	call   c0103437 <page_insert>
c0103c98:	83 c4 10             	add    $0x10,%esp
c0103c9b:	85 c0                	test   %eax,%eax
c0103c9d:	74 19                	je     c0103cb8 <check_boot_pgdir+0x1ef>
c0103c9f:	68 94 66 10 c0       	push   $0xc0106694
c0103ca4:	68 cd 62 10 c0       	push   $0xc01062cd
c0103ca9:	68 28 02 00 00       	push   $0x228
c0103cae:	68 a8 62 10 c0       	push   $0xc01062a8
c0103cb3:	e8 21 c7 ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p) == 2);
c0103cb8:	83 ec 0c             	sub    $0xc,%esp
c0103cbb:	ff 75 e0             	pushl  -0x20(%ebp)
c0103cbe:	e8 ff ec ff ff       	call   c01029c2 <page_ref>
c0103cc3:	83 c4 10             	add    $0x10,%esp
c0103cc6:	83 f8 02             	cmp    $0x2,%eax
c0103cc9:	74 19                	je     c0103ce4 <check_boot_pgdir+0x21b>
c0103ccb:	68 cb 66 10 c0       	push   $0xc01066cb
c0103cd0:	68 cd 62 10 c0       	push   $0xc01062cd
c0103cd5:	68 29 02 00 00       	push   $0x229
c0103cda:	68 a8 62 10 c0       	push   $0xc01062a8
c0103cdf:	e8 f5 c6 ff ff       	call   c01003d9 <__panic>

    const char *str = "ucore: Hello world!!";
c0103ce4:	c7 45 dc dc 66 10 c0 	movl   $0xc01066dc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0103ceb:	83 ec 08             	sub    $0x8,%esp
c0103cee:	ff 75 dc             	pushl  -0x24(%ebp)
c0103cf1:	68 00 01 00 00       	push   $0x100
c0103cf6:	e8 05 13 00 00       	call   c0105000 <strcpy>
c0103cfb:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103cfe:	83 ec 08             	sub    $0x8,%esp
c0103d01:	68 00 11 00 00       	push   $0x1100
c0103d06:	68 00 01 00 00       	push   $0x100
c0103d0b:	e8 6a 13 00 00       	call   c010507a <strcmp>
c0103d10:	83 c4 10             	add    $0x10,%esp
c0103d13:	85 c0                	test   %eax,%eax
c0103d15:	74 19                	je     c0103d30 <check_boot_pgdir+0x267>
c0103d17:	68 f4 66 10 c0       	push   $0xc01066f4
c0103d1c:	68 cd 62 10 c0       	push   $0xc01062cd
c0103d21:	68 2d 02 00 00       	push   $0x22d
c0103d26:	68 a8 62 10 c0       	push   $0xc01062a8
c0103d2b:	e8 a9 c6 ff ff       	call   c01003d9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103d30:	83 ec 0c             	sub    $0xc,%esp
c0103d33:	ff 75 e0             	pushl  -0x20(%ebp)
c0103d36:	e8 ec eb ff ff       	call   c0102927 <page2kva>
c0103d3b:	83 c4 10             	add    $0x10,%esp
c0103d3e:	05 00 01 00 00       	add    $0x100,%eax
c0103d43:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103d46:	83 ec 0c             	sub    $0xc,%esp
c0103d49:	68 00 01 00 00       	push   $0x100
c0103d4e:	e8 55 12 00 00       	call   c0104fa8 <strlen>
c0103d53:	83 c4 10             	add    $0x10,%esp
c0103d56:	85 c0                	test   %eax,%eax
c0103d58:	74 19                	je     c0103d73 <check_boot_pgdir+0x2aa>
c0103d5a:	68 2c 67 10 c0       	push   $0xc010672c
c0103d5f:	68 cd 62 10 c0       	push   $0xc01062cd
c0103d64:	68 30 02 00 00       	push   $0x230
c0103d69:	68 a8 62 10 c0       	push   $0xc01062a8
c0103d6e:	e8 66 c6 ff ff       	call   c01003d9 <__panic>

    free_page(p);
c0103d73:	83 ec 08             	sub    $0x8,%esp
c0103d76:	6a 01                	push   $0x1
c0103d78:	ff 75 e0             	pushl  -0x20(%ebp)
c0103d7b:	e8 8e ee ff ff       	call   c0102c0e <free_pages>
c0103d80:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(boot_pgdir[0]));
c0103d83:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103d88:	8b 00                	mov    (%eax),%eax
c0103d8a:	83 ec 0c             	sub    $0xc,%esp
c0103d8d:	50                   	push   %eax
c0103d8e:	e8 13 ec ff ff       	call   c01029a6 <pde2page>
c0103d93:	83 c4 10             	add    $0x10,%esp
c0103d96:	83 ec 08             	sub    $0x8,%esp
c0103d99:	6a 01                	push   $0x1
c0103d9b:	50                   	push   %eax
c0103d9c:	e8 6d ee ff ff       	call   c0102c0e <free_pages>
c0103da1:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0103da4:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103da9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0103daf:	83 ec 0c             	sub    $0xc,%esp
c0103db2:	68 50 67 10 c0       	push   $0xc0106750
c0103db7:	e8 b7 c4 ff ff       	call   c0100273 <cprintf>
c0103dbc:	83 c4 10             	add    $0x10,%esp
}
c0103dbf:	90                   	nop
c0103dc0:	c9                   	leave  
c0103dc1:	c3                   	ret    

c0103dc2 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0103dc2:	55                   	push   %ebp
c0103dc3:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0103dc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dc8:	83 e0 04             	and    $0x4,%eax
c0103dcb:	85 c0                	test   %eax,%eax
c0103dcd:	74 07                	je     c0103dd6 <perm2str+0x14>
c0103dcf:	b8 75 00 00 00       	mov    $0x75,%eax
c0103dd4:	eb 05                	jmp    c0103ddb <perm2str+0x19>
c0103dd6:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0103ddb:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c0103de0:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0103de7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dea:	83 e0 02             	and    $0x2,%eax
c0103ded:	85 c0                	test   %eax,%eax
c0103def:	74 07                	je     c0103df8 <perm2str+0x36>
c0103df1:	b8 77 00 00 00       	mov    $0x77,%eax
c0103df6:	eb 05                	jmp    c0103dfd <perm2str+0x3b>
c0103df8:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0103dfd:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c0103e02:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c0103e09:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c0103e0e:	5d                   	pop    %ebp
c0103e0f:	c3                   	ret    

c0103e10 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0103e10:	55                   	push   %ebp
c0103e11:	89 e5                	mov    %esp,%ebp
c0103e13:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0103e16:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e19:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103e1c:	72 0e                	jb     c0103e2c <get_pgtable_items+0x1c>
        return 0;
c0103e1e:	b8 00 00 00 00       	mov    $0x0,%eax
c0103e23:	e9 9a 00 00 00       	jmp    c0103ec2 <get_pgtable_items+0xb2>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0103e28:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0103e2c:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e2f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103e32:	73 18                	jae    c0103e4c <get_pgtable_items+0x3c>
c0103e34:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103e3e:	8b 45 14             	mov    0x14(%ebp),%eax
c0103e41:	01 d0                	add    %edx,%eax
c0103e43:	8b 00                	mov    (%eax),%eax
c0103e45:	83 e0 01             	and    $0x1,%eax
c0103e48:	85 c0                	test   %eax,%eax
c0103e4a:	74 dc                	je     c0103e28 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c0103e4c:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e4f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103e52:	73 69                	jae    c0103ebd <get_pgtable_items+0xad>
        if (left_store != NULL) {
c0103e54:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0103e58:	74 08                	je     c0103e62 <get_pgtable_items+0x52>
            *left_store = start;
c0103e5a:	8b 45 18             	mov    0x18(%ebp),%eax
c0103e5d:	8b 55 10             	mov    0x10(%ebp),%edx
c0103e60:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0103e62:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e65:	8d 50 01             	lea    0x1(%eax),%edx
c0103e68:	89 55 10             	mov    %edx,0x10(%ebp)
c0103e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103e72:	8b 45 14             	mov    0x14(%ebp),%eax
c0103e75:	01 d0                	add    %edx,%eax
c0103e77:	8b 00                	mov    (%eax),%eax
c0103e79:	83 e0 07             	and    $0x7,%eax
c0103e7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103e7f:	eb 04                	jmp    c0103e85 <get_pgtable_items+0x75>
            start ++;
c0103e81:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103e85:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e88:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103e8b:	73 1d                	jae    c0103eaa <get_pgtable_items+0x9a>
c0103e8d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103e97:	8b 45 14             	mov    0x14(%ebp),%eax
c0103e9a:	01 d0                	add    %edx,%eax
c0103e9c:	8b 00                	mov    (%eax),%eax
c0103e9e:	83 e0 07             	and    $0x7,%eax
c0103ea1:	89 c2                	mov    %eax,%edx
c0103ea3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103ea6:	39 c2                	cmp    %eax,%edx
c0103ea8:	74 d7                	je     c0103e81 <get_pgtable_items+0x71>
            start ++;
        }
        if (right_store != NULL) {
c0103eaa:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0103eae:	74 08                	je     c0103eb8 <get_pgtable_items+0xa8>
            *right_store = start;
c0103eb0:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0103eb3:	8b 55 10             	mov    0x10(%ebp),%edx
c0103eb6:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0103eb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103ebb:	eb 05                	jmp    c0103ec2 <get_pgtable_items+0xb2>
    }
    return 0;
c0103ebd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103ec2:	c9                   	leave  
c0103ec3:	c3                   	ret    

c0103ec4 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0103ec4:	55                   	push   %ebp
c0103ec5:	89 e5                	mov    %esp,%ebp
c0103ec7:	57                   	push   %edi
c0103ec8:	56                   	push   %esi
c0103ec9:	53                   	push   %ebx
c0103eca:	83 ec 2c             	sub    $0x2c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0103ecd:	83 ec 0c             	sub    $0xc,%esp
c0103ed0:	68 70 67 10 c0       	push   $0xc0106770
c0103ed5:	e8 99 c3 ff ff       	call   c0100273 <cprintf>
c0103eda:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
c0103edd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0103ee4:	e9 e5 00 00 00       	jmp    c0103fce <print_pgdir+0x10a>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0103ee9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103eec:	83 ec 0c             	sub    $0xc,%esp
c0103eef:	50                   	push   %eax
c0103ef0:	e8 cd fe ff ff       	call   c0103dc2 <perm2str>
c0103ef5:	83 c4 10             	add    $0x10,%esp
c0103ef8:	89 c7                	mov    %eax,%edi
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0103efa:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103efd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f00:	29 c2                	sub    %eax,%edx
c0103f02:	89 d0                	mov    %edx,%eax
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0103f04:	c1 e0 16             	shl    $0x16,%eax
c0103f07:	89 c3                	mov    %eax,%ebx
c0103f09:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103f0c:	c1 e0 16             	shl    $0x16,%eax
c0103f0f:	89 c1                	mov    %eax,%ecx
c0103f11:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f14:	c1 e0 16             	shl    $0x16,%eax
c0103f17:	89 c2                	mov    %eax,%edx
c0103f19:	8b 75 dc             	mov    -0x24(%ebp),%esi
c0103f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f1f:	29 c6                	sub    %eax,%esi
c0103f21:	89 f0                	mov    %esi,%eax
c0103f23:	83 ec 08             	sub    $0x8,%esp
c0103f26:	57                   	push   %edi
c0103f27:	53                   	push   %ebx
c0103f28:	51                   	push   %ecx
c0103f29:	52                   	push   %edx
c0103f2a:	50                   	push   %eax
c0103f2b:	68 a1 67 10 c0       	push   $0xc01067a1
c0103f30:	e8 3e c3 ff ff       	call   c0100273 <cprintf>
c0103f35:	83 c4 20             	add    $0x20,%esp
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0103f38:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f3b:	c1 e0 0a             	shl    $0xa,%eax
c0103f3e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0103f41:	eb 4f                	jmp    c0103f92 <print_pgdir+0xce>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0103f43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f46:	83 ec 0c             	sub    $0xc,%esp
c0103f49:	50                   	push   %eax
c0103f4a:	e8 73 fe ff ff       	call   c0103dc2 <perm2str>
c0103f4f:	83 c4 10             	add    $0x10,%esp
c0103f52:	89 c7                	mov    %eax,%edi
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0103f54:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103f57:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103f5a:	29 c2                	sub    %eax,%edx
c0103f5c:	89 d0                	mov    %edx,%eax
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0103f5e:	c1 e0 0c             	shl    $0xc,%eax
c0103f61:	89 c3                	mov    %eax,%ebx
c0103f63:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f66:	c1 e0 0c             	shl    $0xc,%eax
c0103f69:	89 c1                	mov    %eax,%ecx
c0103f6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103f6e:	c1 e0 0c             	shl    $0xc,%eax
c0103f71:	89 c2                	mov    %eax,%edx
c0103f73:	8b 75 d4             	mov    -0x2c(%ebp),%esi
c0103f76:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103f79:	29 c6                	sub    %eax,%esi
c0103f7b:	89 f0                	mov    %esi,%eax
c0103f7d:	83 ec 08             	sub    $0x8,%esp
c0103f80:	57                   	push   %edi
c0103f81:	53                   	push   %ebx
c0103f82:	51                   	push   %ecx
c0103f83:	52                   	push   %edx
c0103f84:	50                   	push   %eax
c0103f85:	68 c0 67 10 c0       	push   $0xc01067c0
c0103f8a:	e8 e4 c2 ff ff       	call   c0100273 <cprintf>
c0103f8f:	83 c4 20             	add    $0x20,%esp
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0103f92:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0103f97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f9a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f9d:	89 d3                	mov    %edx,%ebx
c0103f9f:	c1 e3 0a             	shl    $0xa,%ebx
c0103fa2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103fa5:	89 d1                	mov    %edx,%ecx
c0103fa7:	c1 e1 0a             	shl    $0xa,%ecx
c0103faa:	83 ec 08             	sub    $0x8,%esp
c0103fad:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0103fb0:	52                   	push   %edx
c0103fb1:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0103fb4:	52                   	push   %edx
c0103fb5:	56                   	push   %esi
c0103fb6:	50                   	push   %eax
c0103fb7:	53                   	push   %ebx
c0103fb8:	51                   	push   %ecx
c0103fb9:	e8 52 fe ff ff       	call   c0103e10 <get_pgtable_items>
c0103fbe:	83 c4 20             	add    $0x20,%esp
c0103fc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103fc4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103fc8:	0f 85 75 ff ff ff    	jne    c0103f43 <print_pgdir+0x7f>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0103fce:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0103fd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103fd6:	83 ec 08             	sub    $0x8,%esp
c0103fd9:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0103fdc:	52                   	push   %edx
c0103fdd:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0103fe0:	52                   	push   %edx
c0103fe1:	51                   	push   %ecx
c0103fe2:	50                   	push   %eax
c0103fe3:	68 00 04 00 00       	push   $0x400
c0103fe8:	6a 00                	push   $0x0
c0103fea:	e8 21 fe ff ff       	call   c0103e10 <get_pgtable_items>
c0103fef:	83 c4 20             	add    $0x20,%esp
c0103ff2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103ff5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103ff9:	0f 85 ea fe ff ff    	jne    c0103ee9 <print_pgdir+0x25>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0103fff:	83 ec 0c             	sub    $0xc,%esp
c0104002:	68 e4 67 10 c0       	push   $0xc01067e4
c0104007:	e8 67 c2 ff ff       	call   c0100273 <cprintf>
c010400c:	83 c4 10             	add    $0x10,%esp
}
c010400f:	90                   	nop
c0104010:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0104013:	5b                   	pop    %ebx
c0104014:	5e                   	pop    %esi
c0104015:	5f                   	pop    %edi
c0104016:	5d                   	pop    %ebp
c0104017:	c3                   	ret    

c0104018 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104018:	55                   	push   %ebp
c0104019:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010401b:	8b 45 08             	mov    0x8(%ebp),%eax
c010401e:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0104024:	29 d0                	sub    %edx,%eax
c0104026:	c1 f8 02             	sar    $0x2,%eax
c0104029:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010402f:	5d                   	pop    %ebp
c0104030:	c3                   	ret    

c0104031 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104031:	55                   	push   %ebp
c0104032:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0104034:	ff 75 08             	pushl  0x8(%ebp)
c0104037:	e8 dc ff ff ff       	call   c0104018 <page2ppn>
c010403c:	83 c4 04             	add    $0x4,%esp
c010403f:	c1 e0 0c             	shl    $0xc,%eax
}
c0104042:	c9                   	leave  
c0104043:	c3                   	ret    

c0104044 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0104044:	55                   	push   %ebp
c0104045:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104047:	8b 45 08             	mov    0x8(%ebp),%eax
c010404a:	8b 00                	mov    (%eax),%eax
}
c010404c:	5d                   	pop    %ebp
c010404d:	c3                   	ret    

c010404e <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010404e:	55                   	push   %ebp
c010404f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104051:	8b 45 08             	mov    0x8(%ebp),%eax
c0104054:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104057:	89 10                	mov    %edx,(%eax)
}
c0104059:	90                   	nop
c010405a:	5d                   	pop    %ebp
c010405b:	c3                   	ret    

c010405c <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010405c:	55                   	push   %ebp
c010405d:	89 e5                	mov    %esp,%ebp
c010405f:	83 ec 10             	sub    $0x10,%esp
c0104062:	c7 45 fc 1c af 11 c0 	movl   $0xc011af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104069:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010406c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010406f:	89 50 04             	mov    %edx,0x4(%eax)
c0104072:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104075:	8b 50 04             	mov    0x4(%eax),%edx
c0104078:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010407b:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010407d:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104084:	00 00 00 
}
c0104087:	90                   	nop
c0104088:	c9                   	leave  
c0104089:	c3                   	ret    

c010408a <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010408a:	55                   	push   %ebp
c010408b:	89 e5                	mov    %esp,%ebp
c010408d:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0104090:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104094:	75 16                	jne    c01040ac <default_init_memmap+0x22>
c0104096:	68 18 68 10 c0       	push   $0xc0106818
c010409b:	68 1e 68 10 c0       	push   $0xc010681e
c01040a0:	6a 6d                	push   $0x6d
c01040a2:	68 33 68 10 c0       	push   $0xc0106833
c01040a7:	e8 2d c3 ff ff       	call   c01003d9 <__panic>
    struct Page *p = base;
c01040ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01040af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01040b2:	e9 cb 00 00 00       	jmp    c0104182 <default_init_memmap+0xf8>
        assert(PageReserved(p));
c01040b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040ba:	83 c0 04             	add    $0x4,%eax
c01040bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01040c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01040c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01040ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01040cd:	0f a3 10             	bt     %edx,(%eax)
c01040d0:	19 c0                	sbb    %eax,%eax
c01040d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return oldbit != 0;
c01040d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01040d9:	0f 95 c0             	setne  %al
c01040dc:	0f b6 c0             	movzbl %al,%eax
c01040df:	85 c0                	test   %eax,%eax
c01040e1:	75 16                	jne    c01040f9 <default_init_memmap+0x6f>
c01040e3:	68 49 68 10 c0       	push   $0xc0106849
c01040e8:	68 1e 68 10 c0       	push   $0xc010681e
c01040ed:	6a 70                	push   $0x70
c01040ef:	68 33 68 10 c0       	push   $0xc0106833
c01040f4:	e8 e0 c2 ff ff       	call   c01003d9 <__panic>
        p->property = 0;
c01040f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        SetPageProperty(p);
c0104103:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104106:	83 c0 04             	add    $0x4,%eax
c0104109:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0104110:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104113:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104116:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104119:	0f ab 10             	bts    %edx,(%eax)
        p->flags = 0;
c010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010411f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0104126:	83 ec 08             	sub    $0x8,%esp
c0104129:	6a 00                	push   $0x0
c010412b:	ff 75 f4             	pushl  -0xc(%ebp)
c010412e:	e8 1b ff ff ff       	call   c010404e <set_page_ref>
c0104133:	83 c4 10             	add    $0x10,%esp
        list_add_before(&free_list, &(p->page_link));
c0104136:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104139:	83 c0 0c             	add    $0xc,%eax
c010413c:	c7 45 f0 1c af 11 c0 	movl   $0xc011af1c,-0x10(%ebp)
c0104143:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0104146:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104149:	8b 00                	mov    (%eax),%eax
c010414b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010414e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104151:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104154:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104157:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010415a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010415d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104160:	89 10                	mov    %edx,(%eax)
c0104162:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104165:	8b 10                	mov    (%eax),%edx
c0104167:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010416a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010416d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104170:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104173:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104176:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104179:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010417c:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010417e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104182:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104185:	89 d0                	mov    %edx,%eax
c0104187:	c1 e0 02             	shl    $0x2,%eax
c010418a:	01 d0                	add    %edx,%eax
c010418c:	c1 e0 02             	shl    $0x2,%eax
c010418f:	89 c2                	mov    %eax,%edx
c0104191:	8b 45 08             	mov    0x8(%ebp),%eax
c0104194:	01 d0                	add    %edx,%eax
c0104196:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104199:	0f 85 18 ff ff ff    	jne    c01040b7 <default_init_memmap+0x2d>
        SetPageProperty(p);
        p->flags = 0;
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }
    base->property = n;
c010419f:	8b 45 08             	mov    0x8(%ebp),%eax
c01041a2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01041a5:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01041a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01041ab:	83 c0 04             	add    $0x4,%eax
c01041ae:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c01041b5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01041b8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01041bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01041be:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01041c1:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c01041c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01041ca:	01 d0                	add    %edx,%eax
c01041cc:	a3 24 af 11 c0       	mov    %eax,0xc011af24
}
c01041d1:	90                   	nop
c01041d2:	c9                   	leave  
c01041d3:	c3                   	ret    

c01041d4 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01041d4:	55                   	push   %ebp
c01041d5:	89 e5                	mov    %esp,%ebp
c01041d7:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c01041da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01041de:	75 16                	jne    c01041f6 <default_alloc_pages+0x22>
c01041e0:	68 18 68 10 c0       	push   $0xc0106818
c01041e5:	68 1e 68 10 c0       	push   $0xc010681e
c01041ea:	6a 7e                	push   $0x7e
c01041ec:	68 33 68 10 c0       	push   $0xc0106833
c01041f1:	e8 e3 c1 ff ff       	call   c01003d9 <__panic>
    if (n > nr_free) {
c01041f6:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01041fb:	3b 45 08             	cmp    0x8(%ebp),%eax
c01041fe:	73 0a                	jae    c010420a <default_alloc_pages+0x36>
        return NULL;
c0104200:	b8 00 00 00 00       	mov    $0x0,%eax
c0104205:	e9 21 01 00 00       	jmp    c010432b <default_alloc_pages+0x157>
    }
    struct Page *page = NULL;
c010420a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104211:	c7 45 f0 1c af 11 c0 	movl   $0xc011af1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104218:	eb 1c                	jmp    c0104236 <default_alloc_pages+0x62>
        struct Page *p = le2page(le, page_link);
c010421a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010421d:	83 e8 0c             	sub    $0xc,%eax
c0104220:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if (p->property >= n) {
c0104223:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104226:	8b 40 08             	mov    0x8(%eax),%eax
c0104229:	3b 45 08             	cmp    0x8(%ebp),%eax
c010422c:	72 08                	jb     c0104236 <default_alloc_pages+0x62>
            page = p;
c010422e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104231:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0104234:	eb 18                	jmp    c010424e <default_alloc_pages+0x7a>
c0104236:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104239:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010423c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010423f:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104242:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104245:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c010424c:	75 cc                	jne    c010421a <default_alloc_pages+0x46>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page == NULL) return NULL;
c010424e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104252:	75 0a                	jne    c010425e <default_alloc_pages+0x8a>
c0104254:	b8 00 00 00 00       	mov    $0x0,%eax
c0104259:	e9 cd 00 00 00       	jmp    c010432b <default_alloc_pages+0x157>
c010425e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104261:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104264:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104267:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *currle = list_next(le);
c010426a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    for (int i = 0; i < n; i++ ) {
c010426d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104274:	eb 7c                	jmp    c01042f2 <default_alloc_pages+0x11e>
c0104276:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104279:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010427c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010427f:	8b 40 04             	mov    0x4(%eax),%eax
        list_entry_t *currle = list_next(currle);
c0104282:	89 45 e8             	mov    %eax,-0x18(%ebp)
        struct Page *page_item = le2page(le, page_link);
c0104285:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104288:	83 e8 0c             	sub    $0xc,%eax
c010428b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        SetPageReserved(page_item);
c010428e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104291:	83 c0 04             	add    $0x4,%eax
c0104294:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
c010429b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010429e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01042a1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01042a4:	0f ab 10             	bts    %edx,(%eax)
        ClearPageProperty(page_item);
c01042a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01042aa:	83 c0 04             	add    $0x4,%eax
c01042ad:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c01042b4:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01042b7:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01042ba:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01042bd:	0f b3 10             	btr    %edx,(%eax)
c01042c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01042c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01042c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042c9:	8b 40 04             	mov    0x4(%eax),%eax
c01042cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01042cf:	8b 12                	mov    (%edx),%edx
c01042d1:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01042d4:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01042d7:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01042da:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01042dd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01042e0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01042e3:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01042e6:	89 10                	mov    %edx,(%eax)
        list_del(le);
        le = currle;
c01042e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
            break;
        }
    }
    if (page == NULL) return NULL;
    list_entry_t *currle = list_next(le);
    for (int i = 0; i < n; i++ ) {
c01042ee:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01042f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01042f5:	3b 45 08             	cmp    0x8(%ebp),%eax
c01042f8:	0f 82 78 ff ff ff    	jb     c0104276 <default_alloc_pages+0xa2>
        SetPageReserved(page_item);
        ClearPageProperty(page_item);
        list_del(le);
        le = currle;
    }
    if (page->property > n) {
c01042fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104301:	8b 40 08             	mov    0x8(%eax),%eax
c0104304:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104307:	76 12                	jbe    c010431b <default_alloc_pages+0x147>
        le2page(le, page_link)->property = page->property - n;
c0104309:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010430c:	8d 50 f4             	lea    -0xc(%eax),%edx
c010430f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104312:	8b 40 08             	mov    0x8(%eax),%eax
c0104315:	2b 45 08             	sub    0x8(%ebp),%eax
c0104318:	89 42 08             	mov    %eax,0x8(%edx)
    }
    nr_free -= n;
c010431b:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104320:	2b 45 08             	sub    0x8(%ebp),%eax
c0104323:	a3 24 af 11 c0       	mov    %eax,0xc011af24
    return page;
c0104328:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010432b:	c9                   	leave  
c010432c:	c3                   	ret    

c010432d <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010432d:	55                   	push   %ebp
c010432e:	89 e5                	mov    %esp,%ebp
c0104330:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
c0104336:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010433a:	75 19                	jne    c0104355 <default_free_pages+0x28>
c010433c:	68 18 68 10 c0       	push   $0xc0106818
c0104341:	68 1e 68 10 c0       	push   $0xc010681e
c0104346:	68 9e 00 00 00       	push   $0x9e
c010434b:	68 33 68 10 c0       	push   $0xc0106833
c0104350:	e8 84 c0 ff ff       	call   c01003d9 <__panic>
    struct Page *p = base;
c0104355:	8b 45 08             	mov    0x8(%ebp),%eax
c0104358:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010435b:	e9 8f 00 00 00       	jmp    c01043ef <default_free_pages+0xc2>
        assert(!PageReserved(p) && !PageProperty(p));
c0104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104363:	83 c0 04             	add    $0x4,%eax
c0104366:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
c010436d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104370:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104373:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104376:	0f a3 10             	bt     %edx,(%eax)
c0104379:	19 c0                	sbb    %eax,%eax
c010437b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
c010437e:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0104382:	0f 95 c0             	setne  %al
c0104385:	0f b6 c0             	movzbl %al,%eax
c0104388:	85 c0                	test   %eax,%eax
c010438a:	75 2c                	jne    c01043b8 <default_free_pages+0x8b>
c010438c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010438f:	83 c0 04             	add    $0x4,%eax
c0104392:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0104399:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010439c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010439f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01043a2:	0f a3 10             	bt     %edx,(%eax)
c01043a5:	19 c0                	sbb    %eax,%eax
c01043a7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01043aa:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01043ae:	0f 95 c0             	setne  %al
c01043b1:	0f b6 c0             	movzbl %al,%eax
c01043b4:	85 c0                	test   %eax,%eax
c01043b6:	74 19                	je     c01043d1 <default_free_pages+0xa4>
c01043b8:	68 5c 68 10 c0       	push   $0xc010685c
c01043bd:	68 1e 68 10 c0       	push   $0xc010681e
c01043c2:	68 a1 00 00 00       	push   $0xa1
c01043c7:	68 33 68 10 c0       	push   $0xc0106833
c01043cc:	e8 08 c0 ff ff       	call   c01003d9 <__panic>
        p->flags = 0;
c01043d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043d4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01043db:	83 ec 08             	sub    $0x8,%esp
c01043de:	6a 00                	push   $0x0
c01043e0:	ff 75 f4             	pushl  -0xc(%ebp)
c01043e3:	e8 66 fc ff ff       	call   c010404e <set_page_ref>
c01043e8:	83 c4 10             	add    $0x10,%esp

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01043eb:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01043ef:	8b 55 0c             	mov    0xc(%ebp),%edx
c01043f2:	89 d0                	mov    %edx,%eax
c01043f4:	c1 e0 02             	shl    $0x2,%eax
c01043f7:	01 d0                	add    %edx,%eax
c01043f9:	c1 e0 02             	shl    $0x2,%eax
c01043fc:	89 c2                	mov    %eax,%edx
c01043fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0104401:	01 d0                	add    %edx,%eax
c0104403:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104406:	0f 85 54 ff ff ff    	jne    c0104360 <default_free_pages+0x33>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c010440c:	8b 45 08             	mov    0x8(%ebp),%eax
c010440f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104412:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104415:	8b 45 08             	mov    0x8(%ebp),%eax
c0104418:	83 c0 04             	add    $0x4,%eax
c010441b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0104422:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104425:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104428:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010442b:	0f ab 10             	bts    %edx,(%eax)
c010442e:	c7 45 e8 1c af 11 c0 	movl   $0xc011af1c,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104435:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104438:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c010443b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010443e:	e9 08 01 00 00       	jmp    c010454b <default_free_pages+0x21e>
        p = le2page(le, page_link);
c0104443:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104446:	83 e8 0c             	sub    $0xc,%eax
c0104449:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010444c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010444f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104452:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104455:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104458:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c010445b:	8b 45 08             	mov    0x8(%ebp),%eax
c010445e:	8b 50 08             	mov    0x8(%eax),%edx
c0104461:	89 d0                	mov    %edx,%eax
c0104463:	c1 e0 02             	shl    $0x2,%eax
c0104466:	01 d0                	add    %edx,%eax
c0104468:	c1 e0 02             	shl    $0x2,%eax
c010446b:	89 c2                	mov    %eax,%edx
c010446d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104470:	01 d0                	add    %edx,%eax
c0104472:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104475:	75 5a                	jne    c01044d1 <default_free_pages+0x1a4>
            base->property += p->property;
c0104477:	8b 45 08             	mov    0x8(%ebp),%eax
c010447a:	8b 50 08             	mov    0x8(%eax),%edx
c010447d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104480:	8b 40 08             	mov    0x8(%eax),%eax
c0104483:	01 c2                	add    %eax,%edx
c0104485:	8b 45 08             	mov    0x8(%ebp),%eax
c0104488:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c010448b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010448e:	83 c0 04             	add    $0x4,%eax
c0104491:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0104498:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010449b:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010449e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01044a1:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c01044a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044a7:	83 c0 0c             	add    $0xc,%eax
c01044aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01044ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01044b0:	8b 40 04             	mov    0x4(%eax),%eax
c01044b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01044b6:	8b 12                	mov    (%edx),%edx
c01044b8:	89 55 b0             	mov    %edx,-0x50(%ebp)
c01044bb:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01044be:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01044c1:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01044c4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01044c7:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01044ca:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01044cd:	89 10                	mov    %edx,(%eax)
c01044cf:	eb 7a                	jmp    c010454b <default_free_pages+0x21e>
        }
        else if (p + p->property == base) {
c01044d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044d4:	8b 50 08             	mov    0x8(%eax),%edx
c01044d7:	89 d0                	mov    %edx,%eax
c01044d9:	c1 e0 02             	shl    $0x2,%eax
c01044dc:	01 d0                	add    %edx,%eax
c01044de:	c1 e0 02             	shl    $0x2,%eax
c01044e1:	89 c2                	mov    %eax,%edx
c01044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044e6:	01 d0                	add    %edx,%eax
c01044e8:	3b 45 08             	cmp    0x8(%ebp),%eax
c01044eb:	75 5e                	jne    c010454b <default_free_pages+0x21e>
            p->property += base->property;
c01044ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044f0:	8b 50 08             	mov    0x8(%eax),%edx
c01044f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01044f6:	8b 40 08             	mov    0x8(%eax),%eax
c01044f9:	01 c2                	add    %eax,%edx
c01044fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044fe:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0104501:	8b 45 08             	mov    0x8(%ebp),%eax
c0104504:	83 c0 04             	add    $0x4,%eax
c0104507:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c010450e:	89 45 9c             	mov    %eax,-0x64(%ebp)
c0104511:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104514:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104517:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c010451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010451d:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104523:	83 c0 0c             	add    $0xc,%eax
c0104526:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0104529:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010452c:	8b 40 04             	mov    0x4(%eax),%eax
c010452f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104532:	8b 12                	mov    (%edx),%edx
c0104534:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0104537:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010453a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010453d:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104540:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104543:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104546:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104549:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c010454b:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c0104552:	0f 85 eb fe ff ff    	jne    c0104443 <default_free_pages+0x116>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0104558:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c010455e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104561:	01 d0                	add    %edx,%eax
c0104563:	a3 24 af 11 c0       	mov    %eax,0xc011af24
    list_add(&free_list, &(base->page_link));
c0104568:	8b 45 08             	mov    0x8(%ebp),%eax
c010456b:	83 c0 0c             	add    $0xc,%eax
c010456e:	c7 45 d0 1c af 11 c0 	movl   $0xc011af1c,-0x30(%ebp)
c0104575:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104578:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010457b:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010457e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104581:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0104584:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104587:	8b 40 04             	mov    0x4(%eax),%eax
c010458a:	8b 55 90             	mov    -0x70(%ebp),%edx
c010458d:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0104590:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104593:	89 55 88             	mov    %edx,-0x78(%ebp)
c0104596:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104599:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010459c:	8b 55 8c             	mov    -0x74(%ebp),%edx
c010459f:	89 10                	mov    %edx,(%eax)
c01045a1:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01045a4:	8b 10                	mov    (%eax),%edx
c01045a6:	8b 45 88             	mov    -0x78(%ebp),%eax
c01045a9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01045ac:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01045af:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01045b2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01045b5:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01045b8:	8b 55 88             	mov    -0x78(%ebp),%edx
c01045bb:	89 10                	mov    %edx,(%eax)
}
c01045bd:	90                   	nop
c01045be:	c9                   	leave  
c01045bf:	c3                   	ret    

c01045c0 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01045c0:	55                   	push   %ebp
c01045c1:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01045c3:	a1 24 af 11 c0       	mov    0xc011af24,%eax
}
c01045c8:	5d                   	pop    %ebp
c01045c9:	c3                   	ret    

c01045ca <basic_check>:

static void
basic_check(void) {
c01045ca:	55                   	push   %ebp
c01045cb:	89 e5                	mov    %esp,%ebp
c01045cd:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01045d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01045d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045da:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01045dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01045e3:	83 ec 0c             	sub    $0xc,%esp
c01045e6:	6a 01                	push   $0x1
c01045e8:	e8 e3 e5 ff ff       	call   c0102bd0 <alloc_pages>
c01045ed:	83 c4 10             	add    $0x10,%esp
c01045f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01045f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01045f7:	75 19                	jne    c0104612 <basic_check+0x48>
c01045f9:	68 81 68 10 c0       	push   $0xc0106881
c01045fe:	68 1e 68 10 c0       	push   $0xc010681e
c0104603:	68 c4 00 00 00       	push   $0xc4
c0104608:	68 33 68 10 c0       	push   $0xc0106833
c010460d:	e8 c7 bd ff ff       	call   c01003d9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104612:	83 ec 0c             	sub    $0xc,%esp
c0104615:	6a 01                	push   $0x1
c0104617:	e8 b4 e5 ff ff       	call   c0102bd0 <alloc_pages>
c010461c:	83 c4 10             	add    $0x10,%esp
c010461f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104622:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104626:	75 19                	jne    c0104641 <basic_check+0x77>
c0104628:	68 9d 68 10 c0       	push   $0xc010689d
c010462d:	68 1e 68 10 c0       	push   $0xc010681e
c0104632:	68 c5 00 00 00       	push   $0xc5
c0104637:	68 33 68 10 c0       	push   $0xc0106833
c010463c:	e8 98 bd ff ff       	call   c01003d9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104641:	83 ec 0c             	sub    $0xc,%esp
c0104644:	6a 01                	push   $0x1
c0104646:	e8 85 e5 ff ff       	call   c0102bd0 <alloc_pages>
c010464b:	83 c4 10             	add    $0x10,%esp
c010464e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104651:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104655:	75 19                	jne    c0104670 <basic_check+0xa6>
c0104657:	68 b9 68 10 c0       	push   $0xc01068b9
c010465c:	68 1e 68 10 c0       	push   $0xc010681e
c0104661:	68 c6 00 00 00       	push   $0xc6
c0104666:	68 33 68 10 c0       	push   $0xc0106833
c010466b:	e8 69 bd ff ff       	call   c01003d9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104670:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104673:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104676:	74 10                	je     c0104688 <basic_check+0xbe>
c0104678:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010467b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010467e:	74 08                	je     c0104688 <basic_check+0xbe>
c0104680:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104683:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104686:	75 19                	jne    c01046a1 <basic_check+0xd7>
c0104688:	68 d8 68 10 c0       	push   $0xc01068d8
c010468d:	68 1e 68 10 c0       	push   $0xc010681e
c0104692:	68 c8 00 00 00       	push   $0xc8
c0104697:	68 33 68 10 c0       	push   $0xc0106833
c010469c:	e8 38 bd ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01046a1:	83 ec 0c             	sub    $0xc,%esp
c01046a4:	ff 75 ec             	pushl  -0x14(%ebp)
c01046a7:	e8 98 f9 ff ff       	call   c0104044 <page_ref>
c01046ac:	83 c4 10             	add    $0x10,%esp
c01046af:	85 c0                	test   %eax,%eax
c01046b1:	75 24                	jne    c01046d7 <basic_check+0x10d>
c01046b3:	83 ec 0c             	sub    $0xc,%esp
c01046b6:	ff 75 f0             	pushl  -0x10(%ebp)
c01046b9:	e8 86 f9 ff ff       	call   c0104044 <page_ref>
c01046be:	83 c4 10             	add    $0x10,%esp
c01046c1:	85 c0                	test   %eax,%eax
c01046c3:	75 12                	jne    c01046d7 <basic_check+0x10d>
c01046c5:	83 ec 0c             	sub    $0xc,%esp
c01046c8:	ff 75 f4             	pushl  -0xc(%ebp)
c01046cb:	e8 74 f9 ff ff       	call   c0104044 <page_ref>
c01046d0:	83 c4 10             	add    $0x10,%esp
c01046d3:	85 c0                	test   %eax,%eax
c01046d5:	74 19                	je     c01046f0 <basic_check+0x126>
c01046d7:	68 fc 68 10 c0       	push   $0xc01068fc
c01046dc:	68 1e 68 10 c0       	push   $0xc010681e
c01046e1:	68 c9 00 00 00       	push   $0xc9
c01046e6:	68 33 68 10 c0       	push   $0xc0106833
c01046eb:	e8 e9 bc ff ff       	call   c01003d9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01046f0:	83 ec 0c             	sub    $0xc,%esp
c01046f3:	ff 75 ec             	pushl  -0x14(%ebp)
c01046f6:	e8 36 f9 ff ff       	call   c0104031 <page2pa>
c01046fb:	83 c4 10             	add    $0x10,%esp
c01046fe:	89 c2                	mov    %eax,%edx
c0104700:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104705:	c1 e0 0c             	shl    $0xc,%eax
c0104708:	39 c2                	cmp    %eax,%edx
c010470a:	72 19                	jb     c0104725 <basic_check+0x15b>
c010470c:	68 38 69 10 c0       	push   $0xc0106938
c0104711:	68 1e 68 10 c0       	push   $0xc010681e
c0104716:	68 cb 00 00 00       	push   $0xcb
c010471b:	68 33 68 10 c0       	push   $0xc0106833
c0104720:	e8 b4 bc ff ff       	call   c01003d9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104725:	83 ec 0c             	sub    $0xc,%esp
c0104728:	ff 75 f0             	pushl  -0x10(%ebp)
c010472b:	e8 01 f9 ff ff       	call   c0104031 <page2pa>
c0104730:	83 c4 10             	add    $0x10,%esp
c0104733:	89 c2                	mov    %eax,%edx
c0104735:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010473a:	c1 e0 0c             	shl    $0xc,%eax
c010473d:	39 c2                	cmp    %eax,%edx
c010473f:	72 19                	jb     c010475a <basic_check+0x190>
c0104741:	68 55 69 10 c0       	push   $0xc0106955
c0104746:	68 1e 68 10 c0       	push   $0xc010681e
c010474b:	68 cc 00 00 00       	push   $0xcc
c0104750:	68 33 68 10 c0       	push   $0xc0106833
c0104755:	e8 7f bc ff ff       	call   c01003d9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c010475a:	83 ec 0c             	sub    $0xc,%esp
c010475d:	ff 75 f4             	pushl  -0xc(%ebp)
c0104760:	e8 cc f8 ff ff       	call   c0104031 <page2pa>
c0104765:	83 c4 10             	add    $0x10,%esp
c0104768:	89 c2                	mov    %eax,%edx
c010476a:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010476f:	c1 e0 0c             	shl    $0xc,%eax
c0104772:	39 c2                	cmp    %eax,%edx
c0104774:	72 19                	jb     c010478f <basic_check+0x1c5>
c0104776:	68 72 69 10 c0       	push   $0xc0106972
c010477b:	68 1e 68 10 c0       	push   $0xc010681e
c0104780:	68 cd 00 00 00       	push   $0xcd
c0104785:	68 33 68 10 c0       	push   $0xc0106833
c010478a:	e8 4a bc ff ff       	call   c01003d9 <__panic>

    list_entry_t free_list_store = free_list;
c010478f:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104794:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c010479a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010479d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01047a0:	c7 45 e4 1c af 11 c0 	movl   $0xc011af1c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01047a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01047ad:	89 50 04             	mov    %edx,0x4(%eax)
c01047b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047b3:	8b 50 04             	mov    0x4(%eax),%edx
c01047b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047b9:	89 10                	mov    %edx,(%eax)
c01047bb:	c7 45 d8 1c af 11 c0 	movl   $0xc011af1c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01047c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01047c5:	8b 40 04             	mov    0x4(%eax),%eax
c01047c8:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01047cb:	0f 94 c0             	sete   %al
c01047ce:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01047d1:	85 c0                	test   %eax,%eax
c01047d3:	75 19                	jne    c01047ee <basic_check+0x224>
c01047d5:	68 8f 69 10 c0       	push   $0xc010698f
c01047da:	68 1e 68 10 c0       	push   $0xc010681e
c01047df:	68 d1 00 00 00       	push   $0xd1
c01047e4:	68 33 68 10 c0       	push   $0xc0106833
c01047e9:	e8 eb bb ff ff       	call   c01003d9 <__panic>

    unsigned int nr_free_store = nr_free;
c01047ee:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01047f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01047f6:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c01047fd:	00 00 00 

    assert(alloc_page() == NULL);
c0104800:	83 ec 0c             	sub    $0xc,%esp
c0104803:	6a 01                	push   $0x1
c0104805:	e8 c6 e3 ff ff       	call   c0102bd0 <alloc_pages>
c010480a:	83 c4 10             	add    $0x10,%esp
c010480d:	85 c0                	test   %eax,%eax
c010480f:	74 19                	je     c010482a <basic_check+0x260>
c0104811:	68 a6 69 10 c0       	push   $0xc01069a6
c0104816:	68 1e 68 10 c0       	push   $0xc010681e
c010481b:	68 d6 00 00 00       	push   $0xd6
c0104820:	68 33 68 10 c0       	push   $0xc0106833
c0104825:	e8 af bb ff ff       	call   c01003d9 <__panic>

    free_page(p0);
c010482a:	83 ec 08             	sub    $0x8,%esp
c010482d:	6a 01                	push   $0x1
c010482f:	ff 75 ec             	pushl  -0x14(%ebp)
c0104832:	e8 d7 e3 ff ff       	call   c0102c0e <free_pages>
c0104837:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c010483a:	83 ec 08             	sub    $0x8,%esp
c010483d:	6a 01                	push   $0x1
c010483f:	ff 75 f0             	pushl  -0x10(%ebp)
c0104842:	e8 c7 e3 ff ff       	call   c0102c0e <free_pages>
c0104847:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c010484a:	83 ec 08             	sub    $0x8,%esp
c010484d:	6a 01                	push   $0x1
c010484f:	ff 75 f4             	pushl  -0xc(%ebp)
c0104852:	e8 b7 e3 ff ff       	call   c0102c0e <free_pages>
c0104857:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
c010485a:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c010485f:	83 f8 03             	cmp    $0x3,%eax
c0104862:	74 19                	je     c010487d <basic_check+0x2b3>
c0104864:	68 bb 69 10 c0       	push   $0xc01069bb
c0104869:	68 1e 68 10 c0       	push   $0xc010681e
c010486e:	68 db 00 00 00       	push   $0xdb
c0104873:	68 33 68 10 c0       	push   $0xc0106833
c0104878:	e8 5c bb ff ff       	call   c01003d9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c010487d:	83 ec 0c             	sub    $0xc,%esp
c0104880:	6a 01                	push   $0x1
c0104882:	e8 49 e3 ff ff       	call   c0102bd0 <alloc_pages>
c0104887:	83 c4 10             	add    $0x10,%esp
c010488a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010488d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104891:	75 19                	jne    c01048ac <basic_check+0x2e2>
c0104893:	68 81 68 10 c0       	push   $0xc0106881
c0104898:	68 1e 68 10 c0       	push   $0xc010681e
c010489d:	68 dd 00 00 00       	push   $0xdd
c01048a2:	68 33 68 10 c0       	push   $0xc0106833
c01048a7:	e8 2d bb ff ff       	call   c01003d9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01048ac:	83 ec 0c             	sub    $0xc,%esp
c01048af:	6a 01                	push   $0x1
c01048b1:	e8 1a e3 ff ff       	call   c0102bd0 <alloc_pages>
c01048b6:	83 c4 10             	add    $0x10,%esp
c01048b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01048c0:	75 19                	jne    c01048db <basic_check+0x311>
c01048c2:	68 9d 68 10 c0       	push   $0xc010689d
c01048c7:	68 1e 68 10 c0       	push   $0xc010681e
c01048cc:	68 de 00 00 00       	push   $0xde
c01048d1:	68 33 68 10 c0       	push   $0xc0106833
c01048d6:	e8 fe ba ff ff       	call   c01003d9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01048db:	83 ec 0c             	sub    $0xc,%esp
c01048de:	6a 01                	push   $0x1
c01048e0:	e8 eb e2 ff ff       	call   c0102bd0 <alloc_pages>
c01048e5:	83 c4 10             	add    $0x10,%esp
c01048e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048ef:	75 19                	jne    c010490a <basic_check+0x340>
c01048f1:	68 b9 68 10 c0       	push   $0xc01068b9
c01048f6:	68 1e 68 10 c0       	push   $0xc010681e
c01048fb:	68 df 00 00 00       	push   $0xdf
c0104900:	68 33 68 10 c0       	push   $0xc0106833
c0104905:	e8 cf ba ff ff       	call   c01003d9 <__panic>

    assert(alloc_page() == NULL);
c010490a:	83 ec 0c             	sub    $0xc,%esp
c010490d:	6a 01                	push   $0x1
c010490f:	e8 bc e2 ff ff       	call   c0102bd0 <alloc_pages>
c0104914:	83 c4 10             	add    $0x10,%esp
c0104917:	85 c0                	test   %eax,%eax
c0104919:	74 19                	je     c0104934 <basic_check+0x36a>
c010491b:	68 a6 69 10 c0       	push   $0xc01069a6
c0104920:	68 1e 68 10 c0       	push   $0xc010681e
c0104925:	68 e1 00 00 00       	push   $0xe1
c010492a:	68 33 68 10 c0       	push   $0xc0106833
c010492f:	e8 a5 ba ff ff       	call   c01003d9 <__panic>

    free_page(p0);
c0104934:	83 ec 08             	sub    $0x8,%esp
c0104937:	6a 01                	push   $0x1
c0104939:	ff 75 ec             	pushl  -0x14(%ebp)
c010493c:	e8 cd e2 ff ff       	call   c0102c0e <free_pages>
c0104941:	83 c4 10             	add    $0x10,%esp
c0104944:	c7 45 e8 1c af 11 c0 	movl   $0xc011af1c,-0x18(%ebp)
c010494b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010494e:	8b 40 04             	mov    0x4(%eax),%eax
c0104951:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104954:	0f 94 c0             	sete   %al
c0104957:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c010495a:	85 c0                	test   %eax,%eax
c010495c:	74 19                	je     c0104977 <basic_check+0x3ad>
c010495e:	68 c8 69 10 c0       	push   $0xc01069c8
c0104963:	68 1e 68 10 c0       	push   $0xc010681e
c0104968:	68 e4 00 00 00       	push   $0xe4
c010496d:	68 33 68 10 c0       	push   $0xc0106833
c0104972:	e8 62 ba ff ff       	call   c01003d9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104977:	83 ec 0c             	sub    $0xc,%esp
c010497a:	6a 01                	push   $0x1
c010497c:	e8 4f e2 ff ff       	call   c0102bd0 <alloc_pages>
c0104981:	83 c4 10             	add    $0x10,%esp
c0104984:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104987:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010498a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010498d:	74 19                	je     c01049a8 <basic_check+0x3de>
c010498f:	68 e0 69 10 c0       	push   $0xc01069e0
c0104994:	68 1e 68 10 c0       	push   $0xc010681e
c0104999:	68 e7 00 00 00       	push   $0xe7
c010499e:	68 33 68 10 c0       	push   $0xc0106833
c01049a3:	e8 31 ba ff ff       	call   c01003d9 <__panic>
    assert(alloc_page() == NULL);
c01049a8:	83 ec 0c             	sub    $0xc,%esp
c01049ab:	6a 01                	push   $0x1
c01049ad:	e8 1e e2 ff ff       	call   c0102bd0 <alloc_pages>
c01049b2:	83 c4 10             	add    $0x10,%esp
c01049b5:	85 c0                	test   %eax,%eax
c01049b7:	74 19                	je     c01049d2 <basic_check+0x408>
c01049b9:	68 a6 69 10 c0       	push   $0xc01069a6
c01049be:	68 1e 68 10 c0       	push   $0xc010681e
c01049c3:	68 e8 00 00 00       	push   $0xe8
c01049c8:	68 33 68 10 c0       	push   $0xc0106833
c01049cd:	e8 07 ba ff ff       	call   c01003d9 <__panic>

    assert(nr_free == 0);
c01049d2:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01049d7:	85 c0                	test   %eax,%eax
c01049d9:	74 19                	je     c01049f4 <basic_check+0x42a>
c01049db:	68 f9 69 10 c0       	push   $0xc01069f9
c01049e0:	68 1e 68 10 c0       	push   $0xc010681e
c01049e5:	68 ea 00 00 00       	push   $0xea
c01049ea:	68 33 68 10 c0       	push   $0xc0106833
c01049ef:	e8 e5 b9 ff ff       	call   c01003d9 <__panic>
    free_list = free_list_store;
c01049f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01049f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01049fa:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c01049ff:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    nr_free = nr_free_store;
c0104a05:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a08:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_page(p);
c0104a0d:	83 ec 08             	sub    $0x8,%esp
c0104a10:	6a 01                	push   $0x1
c0104a12:	ff 75 dc             	pushl  -0x24(%ebp)
c0104a15:	e8 f4 e1 ff ff       	call   c0102c0e <free_pages>
c0104a1a:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0104a1d:	83 ec 08             	sub    $0x8,%esp
c0104a20:	6a 01                	push   $0x1
c0104a22:	ff 75 f0             	pushl  -0x10(%ebp)
c0104a25:	e8 e4 e1 ff ff       	call   c0102c0e <free_pages>
c0104a2a:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0104a2d:	83 ec 08             	sub    $0x8,%esp
c0104a30:	6a 01                	push   $0x1
c0104a32:	ff 75 f4             	pushl  -0xc(%ebp)
c0104a35:	e8 d4 e1 ff ff       	call   c0102c0e <free_pages>
c0104a3a:	83 c4 10             	add    $0x10,%esp
}
c0104a3d:	90                   	nop
c0104a3e:	c9                   	leave  
c0104a3f:	c3                   	ret    

c0104a40 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104a40:	55                   	push   %ebp
c0104a41:	89 e5                	mov    %esp,%ebp
c0104a43:	81 ec 88 00 00 00    	sub    $0x88,%esp
    int count = 0, total = 0;
c0104a49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104a50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104a57:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104a5e:	eb 60                	jmp    c0104ac0 <default_check+0x80>
        struct Page *p = le2page(le, page_link);
c0104a60:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a63:	83 e8 0c             	sub    $0xc,%eax
c0104a66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0104a69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a6c:	83 c0 04             	add    $0x4,%eax
c0104a6f:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0104a76:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104a79:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104a7c:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104a7f:	0f a3 10             	bt     %edx,(%eax)
c0104a82:	19 c0                	sbb    %eax,%eax
c0104a84:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0104a87:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0104a8b:	0f 95 c0             	setne  %al
c0104a8e:	0f b6 c0             	movzbl %al,%eax
c0104a91:	85 c0                	test   %eax,%eax
c0104a93:	75 19                	jne    c0104aae <default_check+0x6e>
c0104a95:	68 06 6a 10 c0       	push   $0xc0106a06
c0104a9a:	68 1e 68 10 c0       	push   $0xc010681e
c0104a9f:	68 fb 00 00 00       	push   $0xfb
c0104aa4:	68 33 68 10 c0       	push   $0xc0106833
c0104aa9:	e8 2b b9 ff ff       	call   c01003d9 <__panic>
        count ++, total += p->property;
c0104aae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104ab2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ab5:	8b 50 08             	mov    0x8(%eax),%edx
c0104ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104abb:	01 d0                	add    %edx,%eax
c0104abd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ac0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ac3:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104ac6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ac9:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104acc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104acf:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c0104ad6:	75 88                	jne    c0104a60 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0104ad8:	e8 66 e1 ff ff       	call   c0102c43 <nr_free_pages>
c0104add:	89 c2                	mov    %eax,%edx
c0104adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ae2:	39 c2                	cmp    %eax,%edx
c0104ae4:	74 19                	je     c0104aff <default_check+0xbf>
c0104ae6:	68 16 6a 10 c0       	push   $0xc0106a16
c0104aeb:	68 1e 68 10 c0       	push   $0xc010681e
c0104af0:	68 fe 00 00 00       	push   $0xfe
c0104af5:	68 33 68 10 c0       	push   $0xc0106833
c0104afa:	e8 da b8 ff ff       	call   c01003d9 <__panic>

    basic_check();
c0104aff:	e8 c6 fa ff ff       	call   c01045ca <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104b04:	83 ec 0c             	sub    $0xc,%esp
c0104b07:	6a 05                	push   $0x5
c0104b09:	e8 c2 e0 ff ff       	call   c0102bd0 <alloc_pages>
c0104b0e:	83 c4 10             	add    $0x10,%esp
c0104b11:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c0104b14:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104b18:	75 19                	jne    c0104b33 <default_check+0xf3>
c0104b1a:	68 2f 6a 10 c0       	push   $0xc0106a2f
c0104b1f:	68 1e 68 10 c0       	push   $0xc010681e
c0104b24:	68 03 01 00 00       	push   $0x103
c0104b29:	68 33 68 10 c0       	push   $0xc0106833
c0104b2e:	e8 a6 b8 ff ff       	call   c01003d9 <__panic>
    assert(!PageProperty(p0));
c0104b33:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104b36:	83 c0 04             	add    $0x4,%eax
c0104b39:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0104b40:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104b43:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104b46:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104b49:	0f a3 10             	bt     %edx,(%eax)
c0104b4c:	19 c0                	sbb    %eax,%eax
c0104b4e:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0104b51:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0104b55:	0f 95 c0             	setne  %al
c0104b58:	0f b6 c0             	movzbl %al,%eax
c0104b5b:	85 c0                	test   %eax,%eax
c0104b5d:	74 19                	je     c0104b78 <default_check+0x138>
c0104b5f:	68 3a 6a 10 c0       	push   $0xc0106a3a
c0104b64:	68 1e 68 10 c0       	push   $0xc010681e
c0104b69:	68 04 01 00 00       	push   $0x104
c0104b6e:	68 33 68 10 c0       	push   $0xc0106833
c0104b73:	e8 61 b8 ff ff       	call   c01003d9 <__panic>

    list_entry_t free_list_store = free_list;
c0104b78:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104b7d:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c0104b83:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104b86:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104b89:	c7 45 d0 1c af 11 c0 	movl   $0xc011af1c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104b90:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b93:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104b96:	89 50 04             	mov    %edx,0x4(%eax)
c0104b99:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b9c:	8b 50 04             	mov    0x4(%eax),%edx
c0104b9f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104ba2:	89 10                	mov    %edx,(%eax)
c0104ba4:	c7 45 d8 1c af 11 c0 	movl   $0xc011af1c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104bab:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104bae:	8b 40 04             	mov    0x4(%eax),%eax
c0104bb1:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104bb4:	0f 94 c0             	sete   %al
c0104bb7:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104bba:	85 c0                	test   %eax,%eax
c0104bbc:	75 19                	jne    c0104bd7 <default_check+0x197>
c0104bbe:	68 8f 69 10 c0       	push   $0xc010698f
c0104bc3:	68 1e 68 10 c0       	push   $0xc010681e
c0104bc8:	68 08 01 00 00       	push   $0x108
c0104bcd:	68 33 68 10 c0       	push   $0xc0106833
c0104bd2:	e8 02 b8 ff ff       	call   c01003d9 <__panic>
    assert(alloc_page() == NULL);
c0104bd7:	83 ec 0c             	sub    $0xc,%esp
c0104bda:	6a 01                	push   $0x1
c0104bdc:	e8 ef df ff ff       	call   c0102bd0 <alloc_pages>
c0104be1:	83 c4 10             	add    $0x10,%esp
c0104be4:	85 c0                	test   %eax,%eax
c0104be6:	74 19                	je     c0104c01 <default_check+0x1c1>
c0104be8:	68 a6 69 10 c0       	push   $0xc01069a6
c0104bed:	68 1e 68 10 c0       	push   $0xc010681e
c0104bf2:	68 09 01 00 00       	push   $0x109
c0104bf7:	68 33 68 10 c0       	push   $0xc0106833
c0104bfc:	e8 d8 b7 ff ff       	call   c01003d9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104c01:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104c06:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c0104c09:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104c10:	00 00 00 

    free_pages(p0 + 2, 3);
c0104c13:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c16:	83 c0 28             	add    $0x28,%eax
c0104c19:	83 ec 08             	sub    $0x8,%esp
c0104c1c:	6a 03                	push   $0x3
c0104c1e:	50                   	push   %eax
c0104c1f:	e8 ea df ff ff       	call   c0102c0e <free_pages>
c0104c24:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
c0104c27:	83 ec 0c             	sub    $0xc,%esp
c0104c2a:	6a 04                	push   $0x4
c0104c2c:	e8 9f df ff ff       	call   c0102bd0 <alloc_pages>
c0104c31:	83 c4 10             	add    $0x10,%esp
c0104c34:	85 c0                	test   %eax,%eax
c0104c36:	74 19                	je     c0104c51 <default_check+0x211>
c0104c38:	68 4c 6a 10 c0       	push   $0xc0106a4c
c0104c3d:	68 1e 68 10 c0       	push   $0xc010681e
c0104c42:	68 0f 01 00 00       	push   $0x10f
c0104c47:	68 33 68 10 c0       	push   $0xc0106833
c0104c4c:	e8 88 b7 ff ff       	call   c01003d9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104c51:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c54:	83 c0 28             	add    $0x28,%eax
c0104c57:	83 c0 04             	add    $0x4,%eax
c0104c5a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0104c61:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104c64:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104c67:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104c6a:	0f a3 10             	bt     %edx,(%eax)
c0104c6d:	19 c0                	sbb    %eax,%eax
c0104c6f:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104c72:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104c76:	0f 95 c0             	setne  %al
c0104c79:	0f b6 c0             	movzbl %al,%eax
c0104c7c:	85 c0                	test   %eax,%eax
c0104c7e:	74 0e                	je     c0104c8e <default_check+0x24e>
c0104c80:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c83:	83 c0 28             	add    $0x28,%eax
c0104c86:	8b 40 08             	mov    0x8(%eax),%eax
c0104c89:	83 f8 03             	cmp    $0x3,%eax
c0104c8c:	74 19                	je     c0104ca7 <default_check+0x267>
c0104c8e:	68 64 6a 10 c0       	push   $0xc0106a64
c0104c93:	68 1e 68 10 c0       	push   $0xc010681e
c0104c98:	68 10 01 00 00       	push   $0x110
c0104c9d:	68 33 68 10 c0       	push   $0xc0106833
c0104ca2:	e8 32 b7 ff ff       	call   c01003d9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104ca7:	83 ec 0c             	sub    $0xc,%esp
c0104caa:	6a 03                	push   $0x3
c0104cac:	e8 1f df ff ff       	call   c0102bd0 <alloc_pages>
c0104cb1:	83 c4 10             	add    $0x10,%esp
c0104cb4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0104cb7:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0104cbb:	75 19                	jne    c0104cd6 <default_check+0x296>
c0104cbd:	68 90 6a 10 c0       	push   $0xc0106a90
c0104cc2:	68 1e 68 10 c0       	push   $0xc010681e
c0104cc7:	68 11 01 00 00       	push   $0x111
c0104ccc:	68 33 68 10 c0       	push   $0xc0106833
c0104cd1:	e8 03 b7 ff ff       	call   c01003d9 <__panic>
    assert(alloc_page() == NULL);
c0104cd6:	83 ec 0c             	sub    $0xc,%esp
c0104cd9:	6a 01                	push   $0x1
c0104cdb:	e8 f0 de ff ff       	call   c0102bd0 <alloc_pages>
c0104ce0:	83 c4 10             	add    $0x10,%esp
c0104ce3:	85 c0                	test   %eax,%eax
c0104ce5:	74 19                	je     c0104d00 <default_check+0x2c0>
c0104ce7:	68 a6 69 10 c0       	push   $0xc01069a6
c0104cec:	68 1e 68 10 c0       	push   $0xc010681e
c0104cf1:	68 12 01 00 00       	push   $0x112
c0104cf6:	68 33 68 10 c0       	push   $0xc0106833
c0104cfb:	e8 d9 b6 ff ff       	call   c01003d9 <__panic>
    assert(p0 + 2 == p1);
c0104d00:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d03:	83 c0 28             	add    $0x28,%eax
c0104d06:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0104d09:	74 19                	je     c0104d24 <default_check+0x2e4>
c0104d0b:	68 ae 6a 10 c0       	push   $0xc0106aae
c0104d10:	68 1e 68 10 c0       	push   $0xc010681e
c0104d15:	68 13 01 00 00       	push   $0x113
c0104d1a:	68 33 68 10 c0       	push   $0xc0106833
c0104d1f:	e8 b5 b6 ff ff       	call   c01003d9 <__panic>

    p2 = p0 + 1;
c0104d24:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d27:	83 c0 14             	add    $0x14,%eax
c0104d2a:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c0104d2d:	83 ec 08             	sub    $0x8,%esp
c0104d30:	6a 01                	push   $0x1
c0104d32:	ff 75 dc             	pushl  -0x24(%ebp)
c0104d35:	e8 d4 de ff ff       	call   c0102c0e <free_pages>
c0104d3a:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
c0104d3d:	83 ec 08             	sub    $0x8,%esp
c0104d40:	6a 03                	push   $0x3
c0104d42:	ff 75 c4             	pushl  -0x3c(%ebp)
c0104d45:	e8 c4 de ff ff       	call   c0102c0e <free_pages>
c0104d4a:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
c0104d4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d50:	83 c0 04             	add    $0x4,%eax
c0104d53:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0104d5a:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104d5d:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104d60:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104d63:	0f a3 10             	bt     %edx,(%eax)
c0104d66:	19 c0                	sbb    %eax,%eax
c0104d68:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0104d6b:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0104d6f:	0f 95 c0             	setne  %al
c0104d72:	0f b6 c0             	movzbl %al,%eax
c0104d75:	85 c0                	test   %eax,%eax
c0104d77:	74 0b                	je     c0104d84 <default_check+0x344>
c0104d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d7c:	8b 40 08             	mov    0x8(%eax),%eax
c0104d7f:	83 f8 01             	cmp    $0x1,%eax
c0104d82:	74 19                	je     c0104d9d <default_check+0x35d>
c0104d84:	68 bc 6a 10 c0       	push   $0xc0106abc
c0104d89:	68 1e 68 10 c0       	push   $0xc010681e
c0104d8e:	68 18 01 00 00       	push   $0x118
c0104d93:	68 33 68 10 c0       	push   $0xc0106833
c0104d98:	e8 3c b6 ff ff       	call   c01003d9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104d9d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104da0:	83 c0 04             	add    $0x4,%eax
c0104da3:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0104daa:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104dad:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104db0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104db3:	0f a3 10             	bt     %edx,(%eax)
c0104db6:	19 c0                	sbb    %eax,%eax
c0104db8:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c0104dbb:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c0104dbf:	0f 95 c0             	setne  %al
c0104dc2:	0f b6 c0             	movzbl %al,%eax
c0104dc5:	85 c0                	test   %eax,%eax
c0104dc7:	74 0b                	je     c0104dd4 <default_check+0x394>
c0104dc9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104dcc:	8b 40 08             	mov    0x8(%eax),%eax
c0104dcf:	83 f8 03             	cmp    $0x3,%eax
c0104dd2:	74 19                	je     c0104ded <default_check+0x3ad>
c0104dd4:	68 e4 6a 10 c0       	push   $0xc0106ae4
c0104dd9:	68 1e 68 10 c0       	push   $0xc010681e
c0104dde:	68 19 01 00 00       	push   $0x119
c0104de3:	68 33 68 10 c0       	push   $0xc0106833
c0104de8:	e8 ec b5 ff ff       	call   c01003d9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104ded:	83 ec 0c             	sub    $0xc,%esp
c0104df0:	6a 01                	push   $0x1
c0104df2:	e8 d9 dd ff ff       	call   c0102bd0 <alloc_pages>
c0104df7:	83 c4 10             	add    $0x10,%esp
c0104dfa:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104dfd:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104e00:	83 e8 14             	sub    $0x14,%eax
c0104e03:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104e06:	74 19                	je     c0104e21 <default_check+0x3e1>
c0104e08:	68 0a 6b 10 c0       	push   $0xc0106b0a
c0104e0d:	68 1e 68 10 c0       	push   $0xc010681e
c0104e12:	68 1b 01 00 00       	push   $0x11b
c0104e17:	68 33 68 10 c0       	push   $0xc0106833
c0104e1c:	e8 b8 b5 ff ff       	call   c01003d9 <__panic>
    free_page(p0);
c0104e21:	83 ec 08             	sub    $0x8,%esp
c0104e24:	6a 01                	push   $0x1
c0104e26:	ff 75 dc             	pushl  -0x24(%ebp)
c0104e29:	e8 e0 dd ff ff       	call   c0102c0e <free_pages>
c0104e2e:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104e31:	83 ec 0c             	sub    $0xc,%esp
c0104e34:	6a 02                	push   $0x2
c0104e36:	e8 95 dd ff ff       	call   c0102bd0 <alloc_pages>
c0104e3b:	83 c4 10             	add    $0x10,%esp
c0104e3e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104e41:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104e44:	83 c0 14             	add    $0x14,%eax
c0104e47:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104e4a:	74 19                	je     c0104e65 <default_check+0x425>
c0104e4c:	68 28 6b 10 c0       	push   $0xc0106b28
c0104e51:	68 1e 68 10 c0       	push   $0xc010681e
c0104e56:	68 1d 01 00 00       	push   $0x11d
c0104e5b:	68 33 68 10 c0       	push   $0xc0106833
c0104e60:	e8 74 b5 ff ff       	call   c01003d9 <__panic>

    free_pages(p0, 2);
c0104e65:	83 ec 08             	sub    $0x8,%esp
c0104e68:	6a 02                	push   $0x2
c0104e6a:	ff 75 dc             	pushl  -0x24(%ebp)
c0104e6d:	e8 9c dd ff ff       	call   c0102c0e <free_pages>
c0104e72:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0104e75:	83 ec 08             	sub    $0x8,%esp
c0104e78:	6a 01                	push   $0x1
c0104e7a:	ff 75 c0             	pushl  -0x40(%ebp)
c0104e7d:	e8 8c dd ff ff       	call   c0102c0e <free_pages>
c0104e82:	83 c4 10             	add    $0x10,%esp

    assert((p0 = alloc_pages(5)) != NULL);
c0104e85:	83 ec 0c             	sub    $0xc,%esp
c0104e88:	6a 05                	push   $0x5
c0104e8a:	e8 41 dd ff ff       	call   c0102bd0 <alloc_pages>
c0104e8f:	83 c4 10             	add    $0x10,%esp
c0104e92:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104e95:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104e99:	75 19                	jne    c0104eb4 <default_check+0x474>
c0104e9b:	68 48 6b 10 c0       	push   $0xc0106b48
c0104ea0:	68 1e 68 10 c0       	push   $0xc010681e
c0104ea5:	68 22 01 00 00       	push   $0x122
c0104eaa:	68 33 68 10 c0       	push   $0xc0106833
c0104eaf:	e8 25 b5 ff ff       	call   c01003d9 <__panic>
    assert(alloc_page() == NULL);
c0104eb4:	83 ec 0c             	sub    $0xc,%esp
c0104eb7:	6a 01                	push   $0x1
c0104eb9:	e8 12 dd ff ff       	call   c0102bd0 <alloc_pages>
c0104ebe:	83 c4 10             	add    $0x10,%esp
c0104ec1:	85 c0                	test   %eax,%eax
c0104ec3:	74 19                	je     c0104ede <default_check+0x49e>
c0104ec5:	68 a6 69 10 c0       	push   $0xc01069a6
c0104eca:	68 1e 68 10 c0       	push   $0xc010681e
c0104ecf:	68 23 01 00 00       	push   $0x123
c0104ed4:	68 33 68 10 c0       	push   $0xc0106833
c0104ed9:	e8 fb b4 ff ff       	call   c01003d9 <__panic>

    assert(nr_free == 0);
c0104ede:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104ee3:	85 c0                	test   %eax,%eax
c0104ee5:	74 19                	je     c0104f00 <default_check+0x4c0>
c0104ee7:	68 f9 69 10 c0       	push   $0xc01069f9
c0104eec:	68 1e 68 10 c0       	push   $0xc010681e
c0104ef1:	68 25 01 00 00       	push   $0x125
c0104ef6:	68 33 68 10 c0       	push   $0xc0106833
c0104efb:	e8 d9 b4 ff ff       	call   c01003d9 <__panic>
    nr_free = nr_free_store;
c0104f00:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104f03:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_list = free_list_store;
c0104f08:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104f0b:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104f0e:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c0104f13:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    free_pages(p0, 5);
c0104f19:	83 ec 08             	sub    $0x8,%esp
c0104f1c:	6a 05                	push   $0x5
c0104f1e:	ff 75 dc             	pushl  -0x24(%ebp)
c0104f21:	e8 e8 dc ff ff       	call   c0102c0e <free_pages>
c0104f26:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
c0104f29:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104f30:	eb 1d                	jmp    c0104f4f <default_check+0x50f>
        struct Page *p = le2page(le, page_link);
c0104f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f35:	83 e8 0c             	sub    $0xc,%eax
c0104f38:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c0104f3b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104f3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104f42:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104f45:	8b 40 08             	mov    0x8(%eax),%eax
c0104f48:	29 c2                	sub    %eax,%edx
c0104f4a:	89 d0                	mov    %edx,%eax
c0104f4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f52:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104f55:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104f58:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104f5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104f5e:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c0104f65:	75 cb                	jne    c0104f32 <default_check+0x4f2>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0104f67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f6b:	74 19                	je     c0104f86 <default_check+0x546>
c0104f6d:	68 66 6b 10 c0       	push   $0xc0106b66
c0104f72:	68 1e 68 10 c0       	push   $0xc010681e
c0104f77:	68 30 01 00 00       	push   $0x130
c0104f7c:	68 33 68 10 c0       	push   $0xc0106833
c0104f81:	e8 53 b4 ff ff       	call   c01003d9 <__panic>
    assert(total == 0);
c0104f86:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104f8a:	74 19                	je     c0104fa5 <default_check+0x565>
c0104f8c:	68 71 6b 10 c0       	push   $0xc0106b71
c0104f91:	68 1e 68 10 c0       	push   $0xc010681e
c0104f96:	68 31 01 00 00       	push   $0x131
c0104f9b:	68 33 68 10 c0       	push   $0xc0106833
c0104fa0:	e8 34 b4 ff ff       	call   c01003d9 <__panic>
}
c0104fa5:	90                   	nop
c0104fa6:	c9                   	leave  
c0104fa7:	c3                   	ret    

c0104fa8 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0104fa8:	55                   	push   %ebp
c0104fa9:	89 e5                	mov    %esp,%ebp
c0104fab:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0104fae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0104fb5:	eb 04                	jmp    c0104fbb <strlen+0x13>
        cnt ++;
c0104fb7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0104fbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fbe:	8d 50 01             	lea    0x1(%eax),%edx
c0104fc1:	89 55 08             	mov    %edx,0x8(%ebp)
c0104fc4:	0f b6 00             	movzbl (%eax),%eax
c0104fc7:	84 c0                	test   %al,%al
c0104fc9:	75 ec                	jne    c0104fb7 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0104fcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104fce:	c9                   	leave  
c0104fcf:	c3                   	ret    

c0104fd0 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0104fd0:	55                   	push   %ebp
c0104fd1:	89 e5                	mov    %esp,%ebp
c0104fd3:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0104fd6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0104fdd:	eb 04                	jmp    c0104fe3 <strnlen+0x13>
        cnt ++;
c0104fdf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0104fe3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104fe6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104fe9:	73 10                	jae    c0104ffb <strnlen+0x2b>
c0104feb:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fee:	8d 50 01             	lea    0x1(%eax),%edx
c0104ff1:	89 55 08             	mov    %edx,0x8(%ebp)
c0104ff4:	0f b6 00             	movzbl (%eax),%eax
c0104ff7:	84 c0                	test   %al,%al
c0104ff9:	75 e4                	jne    c0104fdf <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0104ffb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104ffe:	c9                   	leave  
c0104fff:	c3                   	ret    

c0105000 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105000:	55                   	push   %ebp
c0105001:	89 e5                	mov    %esp,%ebp
c0105003:	57                   	push   %edi
c0105004:	56                   	push   %esi
c0105005:	83 ec 20             	sub    $0x20,%esp
c0105008:	8b 45 08             	mov    0x8(%ebp),%eax
c010500b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010500e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105011:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105014:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105017:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010501a:	89 d1                	mov    %edx,%ecx
c010501c:	89 c2                	mov    %eax,%edx
c010501e:	89 ce                	mov    %ecx,%esi
c0105020:	89 d7                	mov    %edx,%edi
c0105022:	ac                   	lods   %ds:(%esi),%al
c0105023:	aa                   	stos   %al,%es:(%edi)
c0105024:	84 c0                	test   %al,%al
c0105026:	75 fa                	jne    c0105022 <strcpy+0x22>
c0105028:	89 fa                	mov    %edi,%edx
c010502a:	89 f1                	mov    %esi,%ecx
c010502c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010502f:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105032:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105035:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0105038:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105039:	83 c4 20             	add    $0x20,%esp
c010503c:	5e                   	pop    %esi
c010503d:	5f                   	pop    %edi
c010503e:	5d                   	pop    %ebp
c010503f:	c3                   	ret    

c0105040 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105040:	55                   	push   %ebp
c0105041:	89 e5                	mov    %esp,%ebp
c0105043:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105046:	8b 45 08             	mov    0x8(%ebp),%eax
c0105049:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010504c:	eb 21                	jmp    c010506f <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010504e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105051:	0f b6 10             	movzbl (%eax),%edx
c0105054:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105057:	88 10                	mov    %dl,(%eax)
c0105059:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010505c:	0f b6 00             	movzbl (%eax),%eax
c010505f:	84 c0                	test   %al,%al
c0105061:	74 04                	je     c0105067 <strncpy+0x27>
            src ++;
c0105063:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105067:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010506b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010506f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105073:	75 d9                	jne    c010504e <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105075:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105078:	c9                   	leave  
c0105079:	c3                   	ret    

c010507a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010507a:	55                   	push   %ebp
c010507b:	89 e5                	mov    %esp,%ebp
c010507d:	57                   	push   %edi
c010507e:	56                   	push   %esi
c010507f:	83 ec 20             	sub    $0x20,%esp
c0105082:	8b 45 08             	mov    0x8(%ebp),%eax
c0105085:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105088:	8b 45 0c             	mov    0xc(%ebp),%eax
c010508b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010508e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105091:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105094:	89 d1                	mov    %edx,%ecx
c0105096:	89 c2                	mov    %eax,%edx
c0105098:	89 ce                	mov    %ecx,%esi
c010509a:	89 d7                	mov    %edx,%edi
c010509c:	ac                   	lods   %ds:(%esi),%al
c010509d:	ae                   	scas   %es:(%edi),%al
c010509e:	75 08                	jne    c01050a8 <strcmp+0x2e>
c01050a0:	84 c0                	test   %al,%al
c01050a2:	75 f8                	jne    c010509c <strcmp+0x22>
c01050a4:	31 c0                	xor    %eax,%eax
c01050a6:	eb 04                	jmp    c01050ac <strcmp+0x32>
c01050a8:	19 c0                	sbb    %eax,%eax
c01050aa:	0c 01                	or     $0x1,%al
c01050ac:	89 fa                	mov    %edi,%edx
c01050ae:	89 f1                	mov    %esi,%ecx
c01050b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01050b3:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01050b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c01050b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01050bc:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01050bd:	83 c4 20             	add    $0x20,%esp
c01050c0:	5e                   	pop    %esi
c01050c1:	5f                   	pop    %edi
c01050c2:	5d                   	pop    %ebp
c01050c3:	c3                   	ret    

c01050c4 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01050c4:	55                   	push   %ebp
c01050c5:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01050c7:	eb 0c                	jmp    c01050d5 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c01050c9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01050cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01050d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01050d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01050d9:	74 1a                	je     c01050f5 <strncmp+0x31>
c01050db:	8b 45 08             	mov    0x8(%ebp),%eax
c01050de:	0f b6 00             	movzbl (%eax),%eax
c01050e1:	84 c0                	test   %al,%al
c01050e3:	74 10                	je     c01050f5 <strncmp+0x31>
c01050e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01050e8:	0f b6 10             	movzbl (%eax),%edx
c01050eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050ee:	0f b6 00             	movzbl (%eax),%eax
c01050f1:	38 c2                	cmp    %al,%dl
c01050f3:	74 d4                	je     c01050c9 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01050f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01050f9:	74 18                	je     c0105113 <strncmp+0x4f>
c01050fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01050fe:	0f b6 00             	movzbl (%eax),%eax
c0105101:	0f b6 d0             	movzbl %al,%edx
c0105104:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105107:	0f b6 00             	movzbl (%eax),%eax
c010510a:	0f b6 c0             	movzbl %al,%eax
c010510d:	29 c2                	sub    %eax,%edx
c010510f:	89 d0                	mov    %edx,%eax
c0105111:	eb 05                	jmp    c0105118 <strncmp+0x54>
c0105113:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105118:	5d                   	pop    %ebp
c0105119:	c3                   	ret    

c010511a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010511a:	55                   	push   %ebp
c010511b:	89 e5                	mov    %esp,%ebp
c010511d:	83 ec 04             	sub    $0x4,%esp
c0105120:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105123:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105126:	eb 14                	jmp    c010513c <strchr+0x22>
        if (*s == c) {
c0105128:	8b 45 08             	mov    0x8(%ebp),%eax
c010512b:	0f b6 00             	movzbl (%eax),%eax
c010512e:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105131:	75 05                	jne    c0105138 <strchr+0x1e>
            return (char *)s;
c0105133:	8b 45 08             	mov    0x8(%ebp),%eax
c0105136:	eb 13                	jmp    c010514b <strchr+0x31>
        }
        s ++;
c0105138:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010513c:	8b 45 08             	mov    0x8(%ebp),%eax
c010513f:	0f b6 00             	movzbl (%eax),%eax
c0105142:	84 c0                	test   %al,%al
c0105144:	75 e2                	jne    c0105128 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105146:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010514b:	c9                   	leave  
c010514c:	c3                   	ret    

c010514d <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010514d:	55                   	push   %ebp
c010514e:	89 e5                	mov    %esp,%ebp
c0105150:	83 ec 04             	sub    $0x4,%esp
c0105153:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105156:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105159:	eb 0f                	jmp    c010516a <strfind+0x1d>
        if (*s == c) {
c010515b:	8b 45 08             	mov    0x8(%ebp),%eax
c010515e:	0f b6 00             	movzbl (%eax),%eax
c0105161:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105164:	74 10                	je     c0105176 <strfind+0x29>
            break;
        }
        s ++;
c0105166:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010516a:	8b 45 08             	mov    0x8(%ebp),%eax
c010516d:	0f b6 00             	movzbl (%eax),%eax
c0105170:	84 c0                	test   %al,%al
c0105172:	75 e7                	jne    c010515b <strfind+0xe>
c0105174:	eb 01                	jmp    c0105177 <strfind+0x2a>
        if (*s == c) {
            break;
c0105176:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0105177:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010517a:	c9                   	leave  
c010517b:	c3                   	ret    

c010517c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010517c:	55                   	push   %ebp
c010517d:	89 e5                	mov    %esp,%ebp
c010517f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105182:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105189:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105190:	eb 04                	jmp    c0105196 <strtol+0x1a>
        s ++;
c0105192:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105196:	8b 45 08             	mov    0x8(%ebp),%eax
c0105199:	0f b6 00             	movzbl (%eax),%eax
c010519c:	3c 20                	cmp    $0x20,%al
c010519e:	74 f2                	je     c0105192 <strtol+0x16>
c01051a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01051a3:	0f b6 00             	movzbl (%eax),%eax
c01051a6:	3c 09                	cmp    $0x9,%al
c01051a8:	74 e8                	je     c0105192 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c01051aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01051ad:	0f b6 00             	movzbl (%eax),%eax
c01051b0:	3c 2b                	cmp    $0x2b,%al
c01051b2:	75 06                	jne    c01051ba <strtol+0x3e>
        s ++;
c01051b4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01051b8:	eb 15                	jmp    c01051cf <strtol+0x53>
    }
    else if (*s == '-') {
c01051ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01051bd:	0f b6 00             	movzbl (%eax),%eax
c01051c0:	3c 2d                	cmp    $0x2d,%al
c01051c2:	75 0b                	jne    c01051cf <strtol+0x53>
        s ++, neg = 1;
c01051c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01051c8:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01051cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01051d3:	74 06                	je     c01051db <strtol+0x5f>
c01051d5:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01051d9:	75 24                	jne    c01051ff <strtol+0x83>
c01051db:	8b 45 08             	mov    0x8(%ebp),%eax
c01051de:	0f b6 00             	movzbl (%eax),%eax
c01051e1:	3c 30                	cmp    $0x30,%al
c01051e3:	75 1a                	jne    c01051ff <strtol+0x83>
c01051e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01051e8:	83 c0 01             	add    $0x1,%eax
c01051eb:	0f b6 00             	movzbl (%eax),%eax
c01051ee:	3c 78                	cmp    $0x78,%al
c01051f0:	75 0d                	jne    c01051ff <strtol+0x83>
        s += 2, base = 16;
c01051f2:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01051f6:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01051fd:	eb 2a                	jmp    c0105229 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c01051ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105203:	75 17                	jne    c010521c <strtol+0xa0>
c0105205:	8b 45 08             	mov    0x8(%ebp),%eax
c0105208:	0f b6 00             	movzbl (%eax),%eax
c010520b:	3c 30                	cmp    $0x30,%al
c010520d:	75 0d                	jne    c010521c <strtol+0xa0>
        s ++, base = 8;
c010520f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105213:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010521a:	eb 0d                	jmp    c0105229 <strtol+0xad>
    }
    else if (base == 0) {
c010521c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105220:	75 07                	jne    c0105229 <strtol+0xad>
        base = 10;
c0105222:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105229:	8b 45 08             	mov    0x8(%ebp),%eax
c010522c:	0f b6 00             	movzbl (%eax),%eax
c010522f:	3c 2f                	cmp    $0x2f,%al
c0105231:	7e 1b                	jle    c010524e <strtol+0xd2>
c0105233:	8b 45 08             	mov    0x8(%ebp),%eax
c0105236:	0f b6 00             	movzbl (%eax),%eax
c0105239:	3c 39                	cmp    $0x39,%al
c010523b:	7f 11                	jg     c010524e <strtol+0xd2>
            dig = *s - '0';
c010523d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105240:	0f b6 00             	movzbl (%eax),%eax
c0105243:	0f be c0             	movsbl %al,%eax
c0105246:	83 e8 30             	sub    $0x30,%eax
c0105249:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010524c:	eb 48                	jmp    c0105296 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010524e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105251:	0f b6 00             	movzbl (%eax),%eax
c0105254:	3c 60                	cmp    $0x60,%al
c0105256:	7e 1b                	jle    c0105273 <strtol+0xf7>
c0105258:	8b 45 08             	mov    0x8(%ebp),%eax
c010525b:	0f b6 00             	movzbl (%eax),%eax
c010525e:	3c 7a                	cmp    $0x7a,%al
c0105260:	7f 11                	jg     c0105273 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105262:	8b 45 08             	mov    0x8(%ebp),%eax
c0105265:	0f b6 00             	movzbl (%eax),%eax
c0105268:	0f be c0             	movsbl %al,%eax
c010526b:	83 e8 57             	sub    $0x57,%eax
c010526e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105271:	eb 23                	jmp    c0105296 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105273:	8b 45 08             	mov    0x8(%ebp),%eax
c0105276:	0f b6 00             	movzbl (%eax),%eax
c0105279:	3c 40                	cmp    $0x40,%al
c010527b:	7e 3c                	jle    c01052b9 <strtol+0x13d>
c010527d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105280:	0f b6 00             	movzbl (%eax),%eax
c0105283:	3c 5a                	cmp    $0x5a,%al
c0105285:	7f 32                	jg     c01052b9 <strtol+0x13d>
            dig = *s - 'A' + 10;
c0105287:	8b 45 08             	mov    0x8(%ebp),%eax
c010528a:	0f b6 00             	movzbl (%eax),%eax
c010528d:	0f be c0             	movsbl %al,%eax
c0105290:	83 e8 37             	sub    $0x37,%eax
c0105293:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105296:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105299:	3b 45 10             	cmp    0x10(%ebp),%eax
c010529c:	7d 1a                	jge    c01052b8 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
c010529e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01052a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01052a5:	0f af 45 10          	imul   0x10(%ebp),%eax
c01052a9:	89 c2                	mov    %eax,%edx
c01052ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052ae:	01 d0                	add    %edx,%eax
c01052b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c01052b3:	e9 71 ff ff ff       	jmp    c0105229 <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c01052b8:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c01052b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01052bd:	74 08                	je     c01052c7 <strtol+0x14b>
        *endptr = (char *) s;
c01052bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052c2:	8b 55 08             	mov    0x8(%ebp),%edx
c01052c5:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01052c7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01052cb:	74 07                	je     c01052d4 <strtol+0x158>
c01052cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01052d0:	f7 d8                	neg    %eax
c01052d2:	eb 03                	jmp    c01052d7 <strtol+0x15b>
c01052d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01052d7:	c9                   	leave  
c01052d8:	c3                   	ret    

c01052d9 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01052d9:	55                   	push   %ebp
c01052da:	89 e5                	mov    %esp,%ebp
c01052dc:	57                   	push   %edi
c01052dd:	83 ec 24             	sub    $0x24,%esp
c01052e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052e3:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01052e6:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c01052ea:	8b 55 08             	mov    0x8(%ebp),%edx
c01052ed:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01052f0:	88 45 f7             	mov    %al,-0x9(%ebp)
c01052f3:	8b 45 10             	mov    0x10(%ebp),%eax
c01052f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01052f9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01052fc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105300:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105303:	89 d7                	mov    %edx,%edi
c0105305:	f3 aa                	rep stos %al,%es:(%edi)
c0105307:	89 fa                	mov    %edi,%edx
c0105309:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010530c:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010530f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105312:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105313:	83 c4 24             	add    $0x24,%esp
c0105316:	5f                   	pop    %edi
c0105317:	5d                   	pop    %ebp
c0105318:	c3                   	ret    

c0105319 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105319:	55                   	push   %ebp
c010531a:	89 e5                	mov    %esp,%ebp
c010531c:	57                   	push   %edi
c010531d:	56                   	push   %esi
c010531e:	53                   	push   %ebx
c010531f:	83 ec 30             	sub    $0x30,%esp
c0105322:	8b 45 08             	mov    0x8(%ebp),%eax
c0105325:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105328:	8b 45 0c             	mov    0xc(%ebp),%eax
c010532b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010532e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105331:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105334:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105337:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010533a:	73 42                	jae    c010537e <memmove+0x65>
c010533c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010533f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105342:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105345:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105348:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010534b:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010534e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105351:	c1 e8 02             	shr    $0x2,%eax
c0105354:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105356:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105359:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010535c:	89 d7                	mov    %edx,%edi
c010535e:	89 c6                	mov    %eax,%esi
c0105360:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105362:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105365:	83 e1 03             	and    $0x3,%ecx
c0105368:	74 02                	je     c010536c <memmove+0x53>
c010536a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010536c:	89 f0                	mov    %esi,%eax
c010536e:	89 fa                	mov    %edi,%edx
c0105370:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105373:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105376:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105379:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c010537c:	eb 36                	jmp    c01053b4 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010537e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105381:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105384:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105387:	01 c2                	add    %eax,%edx
c0105389:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010538c:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010538f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105392:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105395:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105398:	89 c1                	mov    %eax,%ecx
c010539a:	89 d8                	mov    %ebx,%eax
c010539c:	89 d6                	mov    %edx,%esi
c010539e:	89 c7                	mov    %eax,%edi
c01053a0:	fd                   	std    
c01053a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01053a3:	fc                   	cld    
c01053a4:	89 f8                	mov    %edi,%eax
c01053a6:	89 f2                	mov    %esi,%edx
c01053a8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01053ab:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01053ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c01053b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01053b4:	83 c4 30             	add    $0x30,%esp
c01053b7:	5b                   	pop    %ebx
c01053b8:	5e                   	pop    %esi
c01053b9:	5f                   	pop    %edi
c01053ba:	5d                   	pop    %ebp
c01053bb:	c3                   	ret    

c01053bc <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01053bc:	55                   	push   %ebp
c01053bd:	89 e5                	mov    %esp,%ebp
c01053bf:	57                   	push   %edi
c01053c0:	56                   	push   %esi
c01053c1:	83 ec 20             	sub    $0x20,%esp
c01053c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01053c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01053ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01053d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01053d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01053d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053d9:	c1 e8 02             	shr    $0x2,%eax
c01053dc:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01053de:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01053e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053e4:	89 d7                	mov    %edx,%edi
c01053e6:	89 c6                	mov    %eax,%esi
c01053e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01053ea:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01053ed:	83 e1 03             	and    $0x3,%ecx
c01053f0:	74 02                	je     c01053f4 <memcpy+0x38>
c01053f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01053f4:	89 f0                	mov    %esi,%eax
c01053f6:	89 fa                	mov    %edi,%edx
c01053f8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01053fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01053fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105401:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0105404:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105405:	83 c4 20             	add    $0x20,%esp
c0105408:	5e                   	pop    %esi
c0105409:	5f                   	pop    %edi
c010540a:	5d                   	pop    %ebp
c010540b:	c3                   	ret    

c010540c <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010540c:	55                   	push   %ebp
c010540d:	89 e5                	mov    %esp,%ebp
c010540f:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105412:	8b 45 08             	mov    0x8(%ebp),%eax
c0105415:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105418:	8b 45 0c             	mov    0xc(%ebp),%eax
c010541b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010541e:	eb 30                	jmp    c0105450 <memcmp+0x44>
        if (*s1 != *s2) {
c0105420:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105423:	0f b6 10             	movzbl (%eax),%edx
c0105426:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105429:	0f b6 00             	movzbl (%eax),%eax
c010542c:	38 c2                	cmp    %al,%dl
c010542e:	74 18                	je     c0105448 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105430:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105433:	0f b6 00             	movzbl (%eax),%eax
c0105436:	0f b6 d0             	movzbl %al,%edx
c0105439:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010543c:	0f b6 00             	movzbl (%eax),%eax
c010543f:	0f b6 c0             	movzbl %al,%eax
c0105442:	29 c2                	sub    %eax,%edx
c0105444:	89 d0                	mov    %edx,%eax
c0105446:	eb 1a                	jmp    c0105462 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105448:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010544c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105450:	8b 45 10             	mov    0x10(%ebp),%eax
c0105453:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105456:	89 55 10             	mov    %edx,0x10(%ebp)
c0105459:	85 c0                	test   %eax,%eax
c010545b:	75 c3                	jne    c0105420 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010545d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105462:	c9                   	leave  
c0105463:	c3                   	ret    

c0105464 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105464:	55                   	push   %ebp
c0105465:	89 e5                	mov    %esp,%ebp
c0105467:	83 ec 38             	sub    $0x38,%esp
c010546a:	8b 45 10             	mov    0x10(%ebp),%eax
c010546d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105470:	8b 45 14             	mov    0x14(%ebp),%eax
c0105473:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105476:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105479:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010547c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010547f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105482:	8b 45 18             	mov    0x18(%ebp),%eax
c0105485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105488:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010548b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010548e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105491:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105494:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105497:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010549a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010549e:	74 1c                	je     c01054bc <printnum+0x58>
c01054a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054a3:	ba 00 00 00 00       	mov    $0x0,%edx
c01054a8:	f7 75 e4             	divl   -0x1c(%ebp)
c01054ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01054ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054b1:	ba 00 00 00 00       	mov    $0x0,%edx
c01054b6:	f7 75 e4             	divl   -0x1c(%ebp)
c01054b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01054bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054c2:	f7 75 e4             	divl   -0x1c(%ebp)
c01054c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01054c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01054cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01054d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01054d4:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01054d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054da:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01054dd:	8b 45 18             	mov    0x18(%ebp),%eax
c01054e0:	ba 00 00 00 00       	mov    $0x0,%edx
c01054e5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01054e8:	77 41                	ja     c010552b <printnum+0xc7>
c01054ea:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01054ed:	72 05                	jb     c01054f4 <printnum+0x90>
c01054ef:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01054f2:	77 37                	ja     c010552b <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
c01054f4:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01054f7:	83 e8 01             	sub    $0x1,%eax
c01054fa:	83 ec 04             	sub    $0x4,%esp
c01054fd:	ff 75 20             	pushl  0x20(%ebp)
c0105500:	50                   	push   %eax
c0105501:	ff 75 18             	pushl  0x18(%ebp)
c0105504:	ff 75 ec             	pushl  -0x14(%ebp)
c0105507:	ff 75 e8             	pushl  -0x18(%ebp)
c010550a:	ff 75 0c             	pushl  0xc(%ebp)
c010550d:	ff 75 08             	pushl  0x8(%ebp)
c0105510:	e8 4f ff ff ff       	call   c0105464 <printnum>
c0105515:	83 c4 20             	add    $0x20,%esp
c0105518:	eb 1b                	jmp    c0105535 <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010551a:	83 ec 08             	sub    $0x8,%esp
c010551d:	ff 75 0c             	pushl  0xc(%ebp)
c0105520:	ff 75 20             	pushl  0x20(%ebp)
c0105523:	8b 45 08             	mov    0x8(%ebp),%eax
c0105526:	ff d0                	call   *%eax
c0105528:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010552b:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010552f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105533:	7f e5                	jg     c010551a <printnum+0xb6>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105535:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105538:	05 2c 6c 10 c0       	add    $0xc0106c2c,%eax
c010553d:	0f b6 00             	movzbl (%eax),%eax
c0105540:	0f be c0             	movsbl %al,%eax
c0105543:	83 ec 08             	sub    $0x8,%esp
c0105546:	ff 75 0c             	pushl  0xc(%ebp)
c0105549:	50                   	push   %eax
c010554a:	8b 45 08             	mov    0x8(%ebp),%eax
c010554d:	ff d0                	call   *%eax
c010554f:	83 c4 10             	add    $0x10,%esp
}
c0105552:	90                   	nop
c0105553:	c9                   	leave  
c0105554:	c3                   	ret    

c0105555 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105555:	55                   	push   %ebp
c0105556:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105558:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010555c:	7e 14                	jle    c0105572 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010555e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105561:	8b 00                	mov    (%eax),%eax
c0105563:	8d 48 08             	lea    0x8(%eax),%ecx
c0105566:	8b 55 08             	mov    0x8(%ebp),%edx
c0105569:	89 0a                	mov    %ecx,(%edx)
c010556b:	8b 50 04             	mov    0x4(%eax),%edx
c010556e:	8b 00                	mov    (%eax),%eax
c0105570:	eb 30                	jmp    c01055a2 <getuint+0x4d>
    }
    else if (lflag) {
c0105572:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105576:	74 16                	je     c010558e <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105578:	8b 45 08             	mov    0x8(%ebp),%eax
c010557b:	8b 00                	mov    (%eax),%eax
c010557d:	8d 48 04             	lea    0x4(%eax),%ecx
c0105580:	8b 55 08             	mov    0x8(%ebp),%edx
c0105583:	89 0a                	mov    %ecx,(%edx)
c0105585:	8b 00                	mov    (%eax),%eax
c0105587:	ba 00 00 00 00       	mov    $0x0,%edx
c010558c:	eb 14                	jmp    c01055a2 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010558e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105591:	8b 00                	mov    (%eax),%eax
c0105593:	8d 48 04             	lea    0x4(%eax),%ecx
c0105596:	8b 55 08             	mov    0x8(%ebp),%edx
c0105599:	89 0a                	mov    %ecx,(%edx)
c010559b:	8b 00                	mov    (%eax),%eax
c010559d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01055a2:	5d                   	pop    %ebp
c01055a3:	c3                   	ret    

c01055a4 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01055a4:	55                   	push   %ebp
c01055a5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01055a7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01055ab:	7e 14                	jle    c01055c1 <getint+0x1d>
        return va_arg(*ap, long long);
c01055ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01055b0:	8b 00                	mov    (%eax),%eax
c01055b2:	8d 48 08             	lea    0x8(%eax),%ecx
c01055b5:	8b 55 08             	mov    0x8(%ebp),%edx
c01055b8:	89 0a                	mov    %ecx,(%edx)
c01055ba:	8b 50 04             	mov    0x4(%eax),%edx
c01055bd:	8b 00                	mov    (%eax),%eax
c01055bf:	eb 28                	jmp    c01055e9 <getint+0x45>
    }
    else if (lflag) {
c01055c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01055c5:	74 12                	je     c01055d9 <getint+0x35>
        return va_arg(*ap, long);
c01055c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ca:	8b 00                	mov    (%eax),%eax
c01055cc:	8d 48 04             	lea    0x4(%eax),%ecx
c01055cf:	8b 55 08             	mov    0x8(%ebp),%edx
c01055d2:	89 0a                	mov    %ecx,(%edx)
c01055d4:	8b 00                	mov    (%eax),%eax
c01055d6:	99                   	cltd   
c01055d7:	eb 10                	jmp    c01055e9 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01055d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01055dc:	8b 00                	mov    (%eax),%eax
c01055de:	8d 48 04             	lea    0x4(%eax),%ecx
c01055e1:	8b 55 08             	mov    0x8(%ebp),%edx
c01055e4:	89 0a                	mov    %ecx,(%edx)
c01055e6:	8b 00                	mov    (%eax),%eax
c01055e8:	99                   	cltd   
    }
}
c01055e9:	5d                   	pop    %ebp
c01055ea:	c3                   	ret    

c01055eb <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01055eb:	55                   	push   %ebp
c01055ec:	89 e5                	mov    %esp,%ebp
c01055ee:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
c01055f1:	8d 45 14             	lea    0x14(%ebp),%eax
c01055f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01055f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055fa:	50                   	push   %eax
c01055fb:	ff 75 10             	pushl  0x10(%ebp)
c01055fe:	ff 75 0c             	pushl  0xc(%ebp)
c0105601:	ff 75 08             	pushl  0x8(%ebp)
c0105604:	e8 06 00 00 00       	call   c010560f <vprintfmt>
c0105609:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c010560c:	90                   	nop
c010560d:	c9                   	leave  
c010560e:	c3                   	ret    

c010560f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010560f:	55                   	push   %ebp
c0105610:	89 e5                	mov    %esp,%ebp
c0105612:	56                   	push   %esi
c0105613:	53                   	push   %ebx
c0105614:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105617:	eb 17                	jmp    c0105630 <vprintfmt+0x21>
            if (ch == '\0') {
c0105619:	85 db                	test   %ebx,%ebx
c010561b:	0f 84 8e 03 00 00    	je     c01059af <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
c0105621:	83 ec 08             	sub    $0x8,%esp
c0105624:	ff 75 0c             	pushl  0xc(%ebp)
c0105627:	53                   	push   %ebx
c0105628:	8b 45 08             	mov    0x8(%ebp),%eax
c010562b:	ff d0                	call   *%eax
c010562d:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105630:	8b 45 10             	mov    0x10(%ebp),%eax
c0105633:	8d 50 01             	lea    0x1(%eax),%edx
c0105636:	89 55 10             	mov    %edx,0x10(%ebp)
c0105639:	0f b6 00             	movzbl (%eax),%eax
c010563c:	0f b6 d8             	movzbl %al,%ebx
c010563f:	83 fb 25             	cmp    $0x25,%ebx
c0105642:	75 d5                	jne    c0105619 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105644:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105648:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010564f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105652:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105655:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010565c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010565f:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105662:	8b 45 10             	mov    0x10(%ebp),%eax
c0105665:	8d 50 01             	lea    0x1(%eax),%edx
c0105668:	89 55 10             	mov    %edx,0x10(%ebp)
c010566b:	0f b6 00             	movzbl (%eax),%eax
c010566e:	0f b6 d8             	movzbl %al,%ebx
c0105671:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105674:	83 f8 55             	cmp    $0x55,%eax
c0105677:	0f 87 05 03 00 00    	ja     c0105982 <vprintfmt+0x373>
c010567d:	8b 04 85 50 6c 10 c0 	mov    -0x3fef93b0(,%eax,4),%eax
c0105684:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105686:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010568a:	eb d6                	jmp    c0105662 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010568c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105690:	eb d0                	jmp    c0105662 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105692:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105699:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010569c:	89 d0                	mov    %edx,%eax
c010569e:	c1 e0 02             	shl    $0x2,%eax
c01056a1:	01 d0                	add    %edx,%eax
c01056a3:	01 c0                	add    %eax,%eax
c01056a5:	01 d8                	add    %ebx,%eax
c01056a7:	83 e8 30             	sub    $0x30,%eax
c01056aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01056ad:	8b 45 10             	mov    0x10(%ebp),%eax
c01056b0:	0f b6 00             	movzbl (%eax),%eax
c01056b3:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01056b6:	83 fb 2f             	cmp    $0x2f,%ebx
c01056b9:	7e 39                	jle    c01056f4 <vprintfmt+0xe5>
c01056bb:	83 fb 39             	cmp    $0x39,%ebx
c01056be:	7f 34                	jg     c01056f4 <vprintfmt+0xe5>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01056c0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c01056c4:	eb d3                	jmp    c0105699 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c01056c6:	8b 45 14             	mov    0x14(%ebp),%eax
c01056c9:	8d 50 04             	lea    0x4(%eax),%edx
c01056cc:	89 55 14             	mov    %edx,0x14(%ebp)
c01056cf:	8b 00                	mov    (%eax),%eax
c01056d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01056d4:	eb 1f                	jmp    c01056f5 <vprintfmt+0xe6>

        case '.':
            if (width < 0)
c01056d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056da:	79 86                	jns    c0105662 <vprintfmt+0x53>
                width = 0;
c01056dc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01056e3:	e9 7a ff ff ff       	jmp    c0105662 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c01056e8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01056ef:	e9 6e ff ff ff       	jmp    c0105662 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c01056f4:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c01056f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056f9:	0f 89 63 ff ff ff    	jns    c0105662 <vprintfmt+0x53>
                width = precision, precision = -1;
c01056ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105702:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105705:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010570c:	e9 51 ff ff ff       	jmp    c0105662 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105711:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0105715:	e9 48 ff ff ff       	jmp    c0105662 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010571a:	8b 45 14             	mov    0x14(%ebp),%eax
c010571d:	8d 50 04             	lea    0x4(%eax),%edx
c0105720:	89 55 14             	mov    %edx,0x14(%ebp)
c0105723:	8b 00                	mov    (%eax),%eax
c0105725:	83 ec 08             	sub    $0x8,%esp
c0105728:	ff 75 0c             	pushl  0xc(%ebp)
c010572b:	50                   	push   %eax
c010572c:	8b 45 08             	mov    0x8(%ebp),%eax
c010572f:	ff d0                	call   *%eax
c0105731:	83 c4 10             	add    $0x10,%esp
            break;
c0105734:	e9 71 02 00 00       	jmp    c01059aa <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105739:	8b 45 14             	mov    0x14(%ebp),%eax
c010573c:	8d 50 04             	lea    0x4(%eax),%edx
c010573f:	89 55 14             	mov    %edx,0x14(%ebp)
c0105742:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105744:	85 db                	test   %ebx,%ebx
c0105746:	79 02                	jns    c010574a <vprintfmt+0x13b>
                err = -err;
c0105748:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010574a:	83 fb 06             	cmp    $0x6,%ebx
c010574d:	7f 0b                	jg     c010575a <vprintfmt+0x14b>
c010574f:	8b 34 9d 10 6c 10 c0 	mov    -0x3fef93f0(,%ebx,4),%esi
c0105756:	85 f6                	test   %esi,%esi
c0105758:	75 19                	jne    c0105773 <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
c010575a:	53                   	push   %ebx
c010575b:	68 3d 6c 10 c0       	push   $0xc0106c3d
c0105760:	ff 75 0c             	pushl  0xc(%ebp)
c0105763:	ff 75 08             	pushl  0x8(%ebp)
c0105766:	e8 80 fe ff ff       	call   c01055eb <printfmt>
c010576b:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010576e:	e9 37 02 00 00       	jmp    c01059aa <vprintfmt+0x39b>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0105773:	56                   	push   %esi
c0105774:	68 46 6c 10 c0       	push   $0xc0106c46
c0105779:	ff 75 0c             	pushl  0xc(%ebp)
c010577c:	ff 75 08             	pushl  0x8(%ebp)
c010577f:	e8 67 fe ff ff       	call   c01055eb <printfmt>
c0105784:	83 c4 10             	add    $0x10,%esp
            }
            break;
c0105787:	e9 1e 02 00 00       	jmp    c01059aa <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010578c:	8b 45 14             	mov    0x14(%ebp),%eax
c010578f:	8d 50 04             	lea    0x4(%eax),%edx
c0105792:	89 55 14             	mov    %edx,0x14(%ebp)
c0105795:	8b 30                	mov    (%eax),%esi
c0105797:	85 f6                	test   %esi,%esi
c0105799:	75 05                	jne    c01057a0 <vprintfmt+0x191>
                p = "(null)";
c010579b:	be 49 6c 10 c0       	mov    $0xc0106c49,%esi
            }
            if (width > 0 && padc != '-') {
c01057a0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01057a4:	7e 76                	jle    c010581c <vprintfmt+0x20d>
c01057a6:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01057aa:	74 70                	je     c010581c <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01057ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057af:	83 ec 08             	sub    $0x8,%esp
c01057b2:	50                   	push   %eax
c01057b3:	56                   	push   %esi
c01057b4:	e8 17 f8 ff ff       	call   c0104fd0 <strnlen>
c01057b9:	83 c4 10             	add    $0x10,%esp
c01057bc:	89 c2                	mov    %eax,%edx
c01057be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057c1:	29 d0                	sub    %edx,%eax
c01057c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01057c6:	eb 17                	jmp    c01057df <vprintfmt+0x1d0>
                    putch(padc, putdat);
c01057c8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01057cc:	83 ec 08             	sub    $0x8,%esp
c01057cf:	ff 75 0c             	pushl  0xc(%ebp)
c01057d2:	50                   	push   %eax
c01057d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01057d6:	ff d0                	call   *%eax
c01057d8:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c01057db:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01057df:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01057e3:	7f e3                	jg     c01057c8 <vprintfmt+0x1b9>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01057e5:	eb 35                	jmp    c010581c <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
c01057e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01057eb:	74 1c                	je     c0105809 <vprintfmt+0x1fa>
c01057ed:	83 fb 1f             	cmp    $0x1f,%ebx
c01057f0:	7e 05                	jle    c01057f7 <vprintfmt+0x1e8>
c01057f2:	83 fb 7e             	cmp    $0x7e,%ebx
c01057f5:	7e 12                	jle    c0105809 <vprintfmt+0x1fa>
                    putch('?', putdat);
c01057f7:	83 ec 08             	sub    $0x8,%esp
c01057fa:	ff 75 0c             	pushl  0xc(%ebp)
c01057fd:	6a 3f                	push   $0x3f
c01057ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0105802:	ff d0                	call   *%eax
c0105804:	83 c4 10             	add    $0x10,%esp
c0105807:	eb 0f                	jmp    c0105818 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
c0105809:	83 ec 08             	sub    $0x8,%esp
c010580c:	ff 75 0c             	pushl  0xc(%ebp)
c010580f:	53                   	push   %ebx
c0105810:	8b 45 08             	mov    0x8(%ebp),%eax
c0105813:	ff d0                	call   *%eax
c0105815:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105818:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010581c:	89 f0                	mov    %esi,%eax
c010581e:	8d 70 01             	lea    0x1(%eax),%esi
c0105821:	0f b6 00             	movzbl (%eax),%eax
c0105824:	0f be d8             	movsbl %al,%ebx
c0105827:	85 db                	test   %ebx,%ebx
c0105829:	74 26                	je     c0105851 <vprintfmt+0x242>
c010582b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010582f:	78 b6                	js     c01057e7 <vprintfmt+0x1d8>
c0105831:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0105835:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105839:	79 ac                	jns    c01057e7 <vprintfmt+0x1d8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010583b:	eb 14                	jmp    c0105851 <vprintfmt+0x242>
                putch(' ', putdat);
c010583d:	83 ec 08             	sub    $0x8,%esp
c0105840:	ff 75 0c             	pushl  0xc(%ebp)
c0105843:	6a 20                	push   $0x20
c0105845:	8b 45 08             	mov    0x8(%ebp),%eax
c0105848:	ff d0                	call   *%eax
c010584a:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010584d:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105851:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105855:	7f e6                	jg     c010583d <vprintfmt+0x22e>
                putch(' ', putdat);
            }
            break;
c0105857:	e9 4e 01 00 00       	jmp    c01059aa <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010585c:	83 ec 08             	sub    $0x8,%esp
c010585f:	ff 75 e0             	pushl  -0x20(%ebp)
c0105862:	8d 45 14             	lea    0x14(%ebp),%eax
c0105865:	50                   	push   %eax
c0105866:	e8 39 fd ff ff       	call   c01055a4 <getint>
c010586b:	83 c4 10             	add    $0x10,%esp
c010586e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105871:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105874:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105877:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010587a:	85 d2                	test   %edx,%edx
c010587c:	79 23                	jns    c01058a1 <vprintfmt+0x292>
                putch('-', putdat);
c010587e:	83 ec 08             	sub    $0x8,%esp
c0105881:	ff 75 0c             	pushl  0xc(%ebp)
c0105884:	6a 2d                	push   $0x2d
c0105886:	8b 45 08             	mov    0x8(%ebp),%eax
c0105889:	ff d0                	call   *%eax
c010588b:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c010588e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105891:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105894:	f7 d8                	neg    %eax
c0105896:	83 d2 00             	adc    $0x0,%edx
c0105899:	f7 da                	neg    %edx
c010589b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010589e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01058a1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01058a8:	e9 9f 00 00 00       	jmp    c010594c <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01058ad:	83 ec 08             	sub    $0x8,%esp
c01058b0:	ff 75 e0             	pushl  -0x20(%ebp)
c01058b3:	8d 45 14             	lea    0x14(%ebp),%eax
c01058b6:	50                   	push   %eax
c01058b7:	e8 99 fc ff ff       	call   c0105555 <getuint>
c01058bc:	83 c4 10             	add    $0x10,%esp
c01058bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01058c5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01058cc:	eb 7e                	jmp    c010594c <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01058ce:	83 ec 08             	sub    $0x8,%esp
c01058d1:	ff 75 e0             	pushl  -0x20(%ebp)
c01058d4:	8d 45 14             	lea    0x14(%ebp),%eax
c01058d7:	50                   	push   %eax
c01058d8:	e8 78 fc ff ff       	call   c0105555 <getuint>
c01058dd:	83 c4 10             	add    $0x10,%esp
c01058e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058e3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c01058e6:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c01058ed:	eb 5d                	jmp    c010594c <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
c01058ef:	83 ec 08             	sub    $0x8,%esp
c01058f2:	ff 75 0c             	pushl  0xc(%ebp)
c01058f5:	6a 30                	push   $0x30
c01058f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01058fa:	ff d0                	call   *%eax
c01058fc:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c01058ff:	83 ec 08             	sub    $0x8,%esp
c0105902:	ff 75 0c             	pushl  0xc(%ebp)
c0105905:	6a 78                	push   $0x78
c0105907:	8b 45 08             	mov    0x8(%ebp),%eax
c010590a:	ff d0                	call   *%eax
c010590c:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010590f:	8b 45 14             	mov    0x14(%ebp),%eax
c0105912:	8d 50 04             	lea    0x4(%eax),%edx
c0105915:	89 55 14             	mov    %edx,0x14(%ebp)
c0105918:	8b 00                	mov    (%eax),%eax
c010591a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010591d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105924:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010592b:	eb 1f                	jmp    c010594c <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010592d:	83 ec 08             	sub    $0x8,%esp
c0105930:	ff 75 e0             	pushl  -0x20(%ebp)
c0105933:	8d 45 14             	lea    0x14(%ebp),%eax
c0105936:	50                   	push   %eax
c0105937:	e8 19 fc ff ff       	call   c0105555 <getuint>
c010593c:	83 c4 10             	add    $0x10,%esp
c010593f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105942:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105945:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010594c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105950:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105953:	83 ec 04             	sub    $0x4,%esp
c0105956:	52                   	push   %edx
c0105957:	ff 75 e8             	pushl  -0x18(%ebp)
c010595a:	50                   	push   %eax
c010595b:	ff 75 f4             	pushl  -0xc(%ebp)
c010595e:	ff 75 f0             	pushl  -0x10(%ebp)
c0105961:	ff 75 0c             	pushl  0xc(%ebp)
c0105964:	ff 75 08             	pushl  0x8(%ebp)
c0105967:	e8 f8 fa ff ff       	call   c0105464 <printnum>
c010596c:	83 c4 20             	add    $0x20,%esp
            break;
c010596f:	eb 39                	jmp    c01059aa <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105971:	83 ec 08             	sub    $0x8,%esp
c0105974:	ff 75 0c             	pushl  0xc(%ebp)
c0105977:	53                   	push   %ebx
c0105978:	8b 45 08             	mov    0x8(%ebp),%eax
c010597b:	ff d0                	call   *%eax
c010597d:	83 c4 10             	add    $0x10,%esp
            break;
c0105980:	eb 28                	jmp    c01059aa <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105982:	83 ec 08             	sub    $0x8,%esp
c0105985:	ff 75 0c             	pushl  0xc(%ebp)
c0105988:	6a 25                	push   $0x25
c010598a:	8b 45 08             	mov    0x8(%ebp),%eax
c010598d:	ff d0                	call   *%eax
c010598f:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105992:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105996:	eb 04                	jmp    c010599c <vprintfmt+0x38d>
c0105998:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010599c:	8b 45 10             	mov    0x10(%ebp),%eax
c010599f:	83 e8 01             	sub    $0x1,%eax
c01059a2:	0f b6 00             	movzbl (%eax),%eax
c01059a5:	3c 25                	cmp    $0x25,%al
c01059a7:	75 ef                	jne    c0105998 <vprintfmt+0x389>
                /* do nothing */;
            break;
c01059a9:	90                   	nop
        }
    }
c01059aa:	e9 68 fc ff ff       	jmp    c0105617 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c01059af:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c01059b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01059b3:	5b                   	pop    %ebx
c01059b4:	5e                   	pop    %esi
c01059b5:	5d                   	pop    %ebp
c01059b6:	c3                   	ret    

c01059b7 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01059b7:	55                   	push   %ebp
c01059b8:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01059ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059bd:	8b 40 08             	mov    0x8(%eax),%eax
c01059c0:	8d 50 01             	lea    0x1(%eax),%edx
c01059c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059c6:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c01059c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059cc:	8b 10                	mov    (%eax),%edx
c01059ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059d1:	8b 40 04             	mov    0x4(%eax),%eax
c01059d4:	39 c2                	cmp    %eax,%edx
c01059d6:	73 12                	jae    c01059ea <sprintputch+0x33>
        *b->buf ++ = ch;
c01059d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059db:	8b 00                	mov    (%eax),%eax
c01059dd:	8d 48 01             	lea    0x1(%eax),%ecx
c01059e0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01059e3:	89 0a                	mov    %ecx,(%edx)
c01059e5:	8b 55 08             	mov    0x8(%ebp),%edx
c01059e8:	88 10                	mov    %dl,(%eax)
    }
}
c01059ea:	90                   	nop
c01059eb:	5d                   	pop    %ebp
c01059ec:	c3                   	ret    

c01059ed <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c01059ed:	55                   	push   %ebp
c01059ee:	89 e5                	mov    %esp,%ebp
c01059f0:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01059f3:	8d 45 14             	lea    0x14(%ebp),%eax
c01059f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c01059f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059fc:	50                   	push   %eax
c01059fd:	ff 75 10             	pushl  0x10(%ebp)
c0105a00:	ff 75 0c             	pushl  0xc(%ebp)
c0105a03:	ff 75 08             	pushl  0x8(%ebp)
c0105a06:	e8 0b 00 00 00       	call   c0105a16 <vsnprintf>
c0105a0b:	83 c4 10             	add    $0x10,%esp
c0105a0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a14:	c9                   	leave  
c0105a15:	c3                   	ret    

c0105a16 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105a16:	55                   	push   %ebp
c0105a17:	89 e5                	mov    %esp,%ebp
c0105a19:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105a1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a25:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a28:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a2b:	01 d0                	add    %edx,%eax
c0105a2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a30:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105a37:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105a3b:	74 0a                	je     c0105a47 <vsnprintf+0x31>
c0105a3d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a43:	39 c2                	cmp    %eax,%edx
c0105a45:	76 07                	jbe    c0105a4e <vsnprintf+0x38>
        return -E_INVAL;
c0105a47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105a4c:	eb 20                	jmp    c0105a6e <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105a4e:	ff 75 14             	pushl  0x14(%ebp)
c0105a51:	ff 75 10             	pushl  0x10(%ebp)
c0105a54:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105a57:	50                   	push   %eax
c0105a58:	68 b7 59 10 c0       	push   $0xc01059b7
c0105a5d:	e8 ad fb ff ff       	call   c010560f <vprintfmt>
c0105a62:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c0105a65:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a68:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a6e:	c9                   	leave  
c0105a6f:	c3                   	ret    
