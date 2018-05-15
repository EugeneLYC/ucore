
bin/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 20 fd 10 00       	mov    $0x10fd20,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	83 ec 04             	sub    $0x4,%esp
  100017:	50                   	push   %eax
  100018:	6a 00                	push   $0x0
  10001a:	68 16 ea 10 00       	push   $0x10ea16
  10001f:	e8 61 2c 00 00       	call   102c85 <memset>
  100024:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
  100027:	e8 32 15 00 00       	call   10155e <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10002c:	c7 45 f4 20 34 10 00 	movl   $0x103420,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100033:	83 ec 08             	sub    $0x8,%esp
  100036:	ff 75 f4             	pushl  -0xc(%ebp)
  100039:	68 3c 34 10 00       	push   $0x10343c
  10003e:	e8 fa 01 00 00       	call   10023d <cprintf>
  100043:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
  100046:	e8 91 08 00 00       	call   1008dc <print_kerninfo>

    grade_backtrace();
  10004b:	e8 74 00 00 00       	call   1000c4 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100050:	e8 f4 28 00 00       	call   102949 <pmm_init>

    pic_init();                 // init interrupt controller
  100055:	e8 47 16 00 00       	call   1016a1 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005a:	e8 a8 17 00 00       	call   101807 <idt_init>

    clock_init();               // init clock interrupt
  10005f:	e8 df 0c 00 00       	call   100d43 <clock_init>
    intr_enable();              // enable irq interrupt
  100064:	e8 75 17 00 00       	call   1017de <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  100069:	eb fe                	jmp    100069 <kern_init+0x69>

0010006b <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  10006b:	55                   	push   %ebp
  10006c:	89 e5                	mov    %esp,%ebp
  10006e:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
  100071:	83 ec 04             	sub    $0x4,%esp
  100074:	6a 00                	push   $0x0
  100076:	6a 00                	push   $0x0
  100078:	6a 00                	push   $0x0
  10007a:	e8 b2 0c 00 00       	call   100d31 <mon_backtrace>
  10007f:	83 c4 10             	add    $0x10,%esp
}
  100082:	90                   	nop
  100083:	c9                   	leave  
  100084:	c3                   	ret    

00100085 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  100085:	55                   	push   %ebp
  100086:	89 e5                	mov    %esp,%ebp
  100088:	53                   	push   %ebx
  100089:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  10008c:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  10008f:	8b 55 0c             	mov    0xc(%ebp),%edx
  100092:	8d 5d 08             	lea    0x8(%ebp),%ebx
  100095:	8b 45 08             	mov    0x8(%ebp),%eax
  100098:	51                   	push   %ecx
  100099:	52                   	push   %edx
  10009a:	53                   	push   %ebx
  10009b:	50                   	push   %eax
  10009c:	e8 ca ff ff ff       	call   10006b <grade_backtrace2>
  1000a1:	83 c4 10             	add    $0x10,%esp
}
  1000a4:	90                   	nop
  1000a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000a8:	c9                   	leave  
  1000a9:	c3                   	ret    

001000aa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000aa:	55                   	push   %ebp
  1000ab:	89 e5                	mov    %esp,%ebp
  1000ad:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
  1000b0:	83 ec 08             	sub    $0x8,%esp
  1000b3:	ff 75 10             	pushl  0x10(%ebp)
  1000b6:	ff 75 08             	pushl  0x8(%ebp)
  1000b9:	e8 c7 ff ff ff       	call   100085 <grade_backtrace1>
  1000be:	83 c4 10             	add    $0x10,%esp
}
  1000c1:	90                   	nop
  1000c2:	c9                   	leave  
  1000c3:	c3                   	ret    

001000c4 <grade_backtrace>:

void
grade_backtrace(void) {
  1000c4:	55                   	push   %ebp
  1000c5:	89 e5                	mov    %esp,%ebp
  1000c7:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000ca:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000cf:	83 ec 04             	sub    $0x4,%esp
  1000d2:	68 00 00 ff ff       	push   $0xffff0000
  1000d7:	50                   	push   %eax
  1000d8:	6a 00                	push   $0x0
  1000da:	e8 cb ff ff ff       	call   1000aa <grade_backtrace0>
  1000df:	83 c4 10             	add    $0x10,%esp
}
  1000e2:	90                   	nop
  1000e3:	c9                   	leave  
  1000e4:	c3                   	ret    

001000e5 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  1000e5:	55                   	push   %ebp
  1000e6:	89 e5                	mov    %esp,%ebp
  1000e8:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  1000eb:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  1000ee:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  1000f1:	8c 45 f2             	mov    %es,-0xe(%ebp)
  1000f4:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  1000f7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1000fb:	0f b7 c0             	movzwl %ax,%eax
  1000fe:	83 e0 03             	and    $0x3,%eax
  100101:	89 c2                	mov    %eax,%edx
  100103:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100108:	83 ec 04             	sub    $0x4,%esp
  10010b:	52                   	push   %edx
  10010c:	50                   	push   %eax
  10010d:	68 41 34 10 00       	push   $0x103441
  100112:	e8 26 01 00 00       	call   10023d <cprintf>
  100117:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
  10011a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10011e:	0f b7 d0             	movzwl %ax,%edx
  100121:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100126:	83 ec 04             	sub    $0x4,%esp
  100129:	52                   	push   %edx
  10012a:	50                   	push   %eax
  10012b:	68 4f 34 10 00       	push   $0x10344f
  100130:	e8 08 01 00 00       	call   10023d <cprintf>
  100135:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
  100138:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  10013c:	0f b7 d0             	movzwl %ax,%edx
  10013f:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100144:	83 ec 04             	sub    $0x4,%esp
  100147:	52                   	push   %edx
  100148:	50                   	push   %eax
  100149:	68 5d 34 10 00       	push   $0x10345d
  10014e:	e8 ea 00 00 00       	call   10023d <cprintf>
  100153:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
  100156:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10015a:	0f b7 d0             	movzwl %ax,%edx
  10015d:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100162:	83 ec 04             	sub    $0x4,%esp
  100165:	52                   	push   %edx
  100166:	50                   	push   %eax
  100167:	68 6b 34 10 00       	push   $0x10346b
  10016c:	e8 cc 00 00 00       	call   10023d <cprintf>
  100171:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
  100174:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  100178:	0f b7 d0             	movzwl %ax,%edx
  10017b:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100180:	83 ec 04             	sub    $0x4,%esp
  100183:	52                   	push   %edx
  100184:	50                   	push   %eax
  100185:	68 79 34 10 00       	push   $0x103479
  10018a:	e8 ae 00 00 00       	call   10023d <cprintf>
  10018f:	83 c4 10             	add    $0x10,%esp
    round ++;
  100192:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100197:	83 c0 01             	add    $0x1,%eax
  10019a:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  10019f:	90                   	nop
  1001a0:	c9                   	leave  
  1001a1:	c3                   	ret    

001001a2 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001a2:	55                   	push   %ebp
  1001a3:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001a5:	90                   	nop
  1001a6:	5d                   	pop    %ebp
  1001a7:	c3                   	ret    

001001a8 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001a8:	55                   	push   %ebp
  1001a9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  1001ab:	90                   	nop
  1001ac:	5d                   	pop    %ebp
  1001ad:	c3                   	ret    

001001ae <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001ae:	55                   	push   %ebp
  1001af:	89 e5                	mov    %esp,%ebp
  1001b1:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
  1001b4:	e8 2c ff ff ff       	call   1000e5 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001b9:	83 ec 0c             	sub    $0xc,%esp
  1001bc:	68 88 34 10 00       	push   $0x103488
  1001c1:	e8 77 00 00 00       	call   10023d <cprintf>
  1001c6:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
  1001c9:	e8 d4 ff ff ff       	call   1001a2 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001ce:	e8 12 ff ff ff       	call   1000e5 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001d3:	83 ec 0c             	sub    $0xc,%esp
  1001d6:	68 a8 34 10 00       	push   $0x1034a8
  1001db:	e8 5d 00 00 00       	call   10023d <cprintf>
  1001e0:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
  1001e3:	e8 c0 ff ff ff       	call   1001a8 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  1001e8:	e8 f8 fe ff ff       	call   1000e5 <lab1_print_cur_status>
}
  1001ed:	90                   	nop
  1001ee:	c9                   	leave  
  1001ef:	c3                   	ret    

001001f0 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1001f0:	55                   	push   %ebp
  1001f1:	89 e5                	mov    %esp,%ebp
  1001f3:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
  1001f6:	83 ec 0c             	sub    $0xc,%esp
  1001f9:	ff 75 08             	pushl  0x8(%ebp)
  1001fc:	e8 8e 13 00 00       	call   10158f <cons_putc>
  100201:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
  100204:	8b 45 0c             	mov    0xc(%ebp),%eax
  100207:	8b 00                	mov    (%eax),%eax
  100209:	8d 50 01             	lea    0x1(%eax),%edx
  10020c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10020f:	89 10                	mov    %edx,(%eax)
}
  100211:	90                   	nop
  100212:	c9                   	leave  
  100213:	c3                   	ret    

00100214 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100214:	55                   	push   %ebp
  100215:	89 e5                	mov    %esp,%ebp
  100217:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  10021a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100221:	ff 75 0c             	pushl  0xc(%ebp)
  100224:	ff 75 08             	pushl  0x8(%ebp)
  100227:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10022a:	50                   	push   %eax
  10022b:	68 f0 01 10 00       	push   $0x1001f0
  100230:	e8 86 2d 00 00       	call   102fbb <vprintfmt>
  100235:	83 c4 10             	add    $0x10,%esp
    return cnt;
  100238:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10023b:	c9                   	leave  
  10023c:	c3                   	ret    

0010023d <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  10023d:	55                   	push   %ebp
  10023e:	89 e5                	mov    %esp,%ebp
  100240:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100243:	8d 45 0c             	lea    0xc(%ebp),%eax
  100246:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10024c:	83 ec 08             	sub    $0x8,%esp
  10024f:	50                   	push   %eax
  100250:	ff 75 08             	pushl  0x8(%ebp)
  100253:	e8 bc ff ff ff       	call   100214 <vcprintf>
  100258:	83 c4 10             	add    $0x10,%esp
  10025b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10025e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100261:	c9                   	leave  
  100262:	c3                   	ret    

00100263 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100263:	55                   	push   %ebp
  100264:	89 e5                	mov    %esp,%ebp
  100266:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
  100269:	83 ec 0c             	sub    $0xc,%esp
  10026c:	ff 75 08             	pushl  0x8(%ebp)
  10026f:	e8 1b 13 00 00       	call   10158f <cons_putc>
  100274:	83 c4 10             	add    $0x10,%esp
}
  100277:	90                   	nop
  100278:	c9                   	leave  
  100279:	c3                   	ret    

0010027a <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10027a:	55                   	push   %ebp
  10027b:	89 e5                	mov    %esp,%ebp
  10027d:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  100280:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  100287:	eb 14                	jmp    10029d <cputs+0x23>
        cputch(c, &cnt);
  100289:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  10028d:	83 ec 08             	sub    $0x8,%esp
  100290:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100293:	52                   	push   %edx
  100294:	50                   	push   %eax
  100295:	e8 56 ff ff ff       	call   1001f0 <cputch>
  10029a:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  10029d:	8b 45 08             	mov    0x8(%ebp),%eax
  1002a0:	8d 50 01             	lea    0x1(%eax),%edx
  1002a3:	89 55 08             	mov    %edx,0x8(%ebp)
  1002a6:	0f b6 00             	movzbl (%eax),%eax
  1002a9:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002ac:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1002b0:	75 d7                	jne    100289 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1002b2:	83 ec 08             	sub    $0x8,%esp
  1002b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1002b8:	50                   	push   %eax
  1002b9:	6a 0a                	push   $0xa
  1002bb:	e8 30 ff ff ff       	call   1001f0 <cputch>
  1002c0:	83 c4 10             	add    $0x10,%esp
    return cnt;
  1002c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1002c6:	c9                   	leave  
  1002c7:	c3                   	ret    

001002c8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1002c8:	55                   	push   %ebp
  1002c9:	89 e5                	mov    %esp,%ebp
  1002cb:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1002ce:	e8 ec 12 00 00       	call   1015bf <cons_getc>
  1002d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1002d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002da:	74 f2                	je     1002ce <getchar+0x6>
        /* do nothing */;
    return c;
  1002dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002df:	c9                   	leave  
  1002e0:	c3                   	ret    

001002e1 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  1002e1:	55                   	push   %ebp
  1002e2:	89 e5                	mov    %esp,%ebp
  1002e4:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
  1002e7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1002eb:	74 13                	je     100300 <readline+0x1f>
        cprintf("%s", prompt);
  1002ed:	83 ec 08             	sub    $0x8,%esp
  1002f0:	ff 75 08             	pushl  0x8(%ebp)
  1002f3:	68 c7 34 10 00       	push   $0x1034c7
  1002f8:	e8 40 ff ff ff       	call   10023d <cprintf>
  1002fd:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
  100300:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100307:	e8 bc ff ff ff       	call   1002c8 <getchar>
  10030c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10030f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100313:	79 0a                	jns    10031f <readline+0x3e>
            return NULL;
  100315:	b8 00 00 00 00       	mov    $0x0,%eax
  10031a:	e9 82 00 00 00       	jmp    1003a1 <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10031f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100323:	7e 2b                	jle    100350 <readline+0x6f>
  100325:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10032c:	7f 22                	jg     100350 <readline+0x6f>
            cputchar(c);
  10032e:	83 ec 0c             	sub    $0xc,%esp
  100331:	ff 75 f0             	pushl  -0x10(%ebp)
  100334:	e8 2a ff ff ff       	call   100263 <cputchar>
  100339:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
  10033c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10033f:	8d 50 01             	lea    0x1(%eax),%edx
  100342:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100345:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100348:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  10034e:	eb 4c                	jmp    10039c <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
  100350:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  100354:	75 1a                	jne    100370 <readline+0x8f>
  100356:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10035a:	7e 14                	jle    100370 <readline+0x8f>
            cputchar(c);
  10035c:	83 ec 0c             	sub    $0xc,%esp
  10035f:	ff 75 f0             	pushl  -0x10(%ebp)
  100362:	e8 fc fe ff ff       	call   100263 <cputchar>
  100367:	83 c4 10             	add    $0x10,%esp
            i --;
  10036a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10036e:	eb 2c                	jmp    10039c <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
  100370:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100374:	74 06                	je     10037c <readline+0x9b>
  100376:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  10037a:	75 8b                	jne    100307 <readline+0x26>
            cputchar(c);
  10037c:	83 ec 0c             	sub    $0xc,%esp
  10037f:	ff 75 f0             	pushl  -0x10(%ebp)
  100382:	e8 dc fe ff ff       	call   100263 <cputchar>
  100387:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
  10038a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10038d:	05 40 ea 10 00       	add    $0x10ea40,%eax
  100392:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  100395:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  10039a:	eb 05                	jmp    1003a1 <readline+0xc0>
        }
    }
  10039c:	e9 66 ff ff ff       	jmp    100307 <readline+0x26>
}
  1003a1:	c9                   	leave  
  1003a2:	c3                   	ret    

001003a3 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003a3:	55                   	push   %ebp
  1003a4:	89 e5                	mov    %esp,%ebp
  1003a6:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
  1003a9:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  1003ae:	85 c0                	test   %eax,%eax
  1003b0:	75 5f                	jne    100411 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
  1003b2:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  1003b9:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1003bc:	8d 45 14             	lea    0x14(%ebp),%eax
  1003bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1003c2:	83 ec 04             	sub    $0x4,%esp
  1003c5:	ff 75 0c             	pushl  0xc(%ebp)
  1003c8:	ff 75 08             	pushl  0x8(%ebp)
  1003cb:	68 ca 34 10 00       	push   $0x1034ca
  1003d0:	e8 68 fe ff ff       	call   10023d <cprintf>
  1003d5:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  1003d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003db:	83 ec 08             	sub    $0x8,%esp
  1003de:	50                   	push   %eax
  1003df:	ff 75 10             	pushl  0x10(%ebp)
  1003e2:	e8 2d fe ff ff       	call   100214 <vcprintf>
  1003e7:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  1003ea:	83 ec 0c             	sub    $0xc,%esp
  1003ed:	68 e6 34 10 00       	push   $0x1034e6
  1003f2:	e8 46 fe ff ff       	call   10023d <cprintf>
  1003f7:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
  1003fa:	83 ec 0c             	sub    $0xc,%esp
  1003fd:	68 e8 34 10 00       	push   $0x1034e8
  100402:	e8 36 fe ff ff       	call   10023d <cprintf>
  100407:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
  10040a:	e8 17 06 00 00       	call   100a26 <print_stackframe>
  10040f:	eb 01                	jmp    100412 <__panic+0x6f>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
  100411:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
  100412:	e8 ce 13 00 00       	call   1017e5 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100417:	83 ec 0c             	sub    $0xc,%esp
  10041a:	6a 00                	push   $0x0
  10041c:	e8 36 08 00 00       	call   100c57 <kmonitor>
  100421:	83 c4 10             	add    $0x10,%esp
    }
  100424:	eb f1                	jmp    100417 <__panic+0x74>

00100426 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100426:	55                   	push   %ebp
  100427:	89 e5                	mov    %esp,%ebp
  100429:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
  10042c:	8d 45 14             	lea    0x14(%ebp),%eax
  10042f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100432:	83 ec 04             	sub    $0x4,%esp
  100435:	ff 75 0c             	pushl  0xc(%ebp)
  100438:	ff 75 08             	pushl  0x8(%ebp)
  10043b:	68 fa 34 10 00       	push   $0x1034fa
  100440:	e8 f8 fd ff ff       	call   10023d <cprintf>
  100445:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  100448:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10044b:	83 ec 08             	sub    $0x8,%esp
  10044e:	50                   	push   %eax
  10044f:	ff 75 10             	pushl  0x10(%ebp)
  100452:	e8 bd fd ff ff       	call   100214 <vcprintf>
  100457:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  10045a:	83 ec 0c             	sub    $0xc,%esp
  10045d:	68 e6 34 10 00       	push   $0x1034e6
  100462:	e8 d6 fd ff ff       	call   10023d <cprintf>
  100467:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  10046a:	90                   	nop
  10046b:	c9                   	leave  
  10046c:	c3                   	ret    

0010046d <is_kernel_panic>:

bool
is_kernel_panic(void) {
  10046d:	55                   	push   %ebp
  10046e:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100470:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  100475:	5d                   	pop    %ebp
  100476:	c3                   	ret    

00100477 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100477:	55                   	push   %ebp
  100478:	89 e5                	mov    %esp,%ebp
  10047a:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  10047d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100480:	8b 00                	mov    (%eax),%eax
  100482:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100485:	8b 45 10             	mov    0x10(%ebp),%eax
  100488:	8b 00                	mov    (%eax),%eax
  10048a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10048d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100494:	e9 d2 00 00 00       	jmp    10056b <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  100499:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10049c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10049f:	01 d0                	add    %edx,%eax
  1004a1:	89 c2                	mov    %eax,%edx
  1004a3:	c1 ea 1f             	shr    $0x1f,%edx
  1004a6:	01 d0                	add    %edx,%eax
  1004a8:	d1 f8                	sar    %eax
  1004aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004b0:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004b3:	eb 04                	jmp    1004b9 <stab_binsearch+0x42>
            m --;
  1004b5:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004bc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004bf:	7c 1f                	jl     1004e0 <stab_binsearch+0x69>
  1004c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004c4:	89 d0                	mov    %edx,%eax
  1004c6:	01 c0                	add    %eax,%eax
  1004c8:	01 d0                	add    %edx,%eax
  1004ca:	c1 e0 02             	shl    $0x2,%eax
  1004cd:	89 c2                	mov    %eax,%edx
  1004cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1004d2:	01 d0                	add    %edx,%eax
  1004d4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004d8:	0f b6 c0             	movzbl %al,%eax
  1004db:	3b 45 14             	cmp    0x14(%ebp),%eax
  1004de:	75 d5                	jne    1004b5 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  1004e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004e6:	7d 0b                	jge    1004f3 <stab_binsearch+0x7c>
            l = true_m + 1;
  1004e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004eb:	83 c0 01             	add    $0x1,%eax
  1004ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  1004f1:	eb 78                	jmp    10056b <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  1004f3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  1004fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004fd:	89 d0                	mov    %edx,%eax
  1004ff:	01 c0                	add    %eax,%eax
  100501:	01 d0                	add    %edx,%eax
  100503:	c1 e0 02             	shl    $0x2,%eax
  100506:	89 c2                	mov    %eax,%edx
  100508:	8b 45 08             	mov    0x8(%ebp),%eax
  10050b:	01 d0                	add    %edx,%eax
  10050d:	8b 40 08             	mov    0x8(%eax),%eax
  100510:	3b 45 18             	cmp    0x18(%ebp),%eax
  100513:	73 13                	jae    100528 <stab_binsearch+0xb1>
            *region_left = m;
  100515:	8b 45 0c             	mov    0xc(%ebp),%eax
  100518:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10051b:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10051d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100520:	83 c0 01             	add    $0x1,%eax
  100523:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100526:	eb 43                	jmp    10056b <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  100528:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10052b:	89 d0                	mov    %edx,%eax
  10052d:	01 c0                	add    %eax,%eax
  10052f:	01 d0                	add    %edx,%eax
  100531:	c1 e0 02             	shl    $0x2,%eax
  100534:	89 c2                	mov    %eax,%edx
  100536:	8b 45 08             	mov    0x8(%ebp),%eax
  100539:	01 d0                	add    %edx,%eax
  10053b:	8b 40 08             	mov    0x8(%eax),%eax
  10053e:	3b 45 18             	cmp    0x18(%ebp),%eax
  100541:	76 16                	jbe    100559 <stab_binsearch+0xe2>
            *region_right = m - 1;
  100543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100546:	8d 50 ff             	lea    -0x1(%eax),%edx
  100549:	8b 45 10             	mov    0x10(%ebp),%eax
  10054c:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10054e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100551:	83 e8 01             	sub    $0x1,%eax
  100554:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100557:	eb 12                	jmp    10056b <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100559:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10055f:	89 10                	mov    %edx,(%eax)
            l = m;
  100561:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100564:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  100567:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  10056b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10056e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100571:	0f 8e 22 ff ff ff    	jle    100499 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  100577:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10057b:	75 0f                	jne    10058c <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  10057d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100580:	8b 00                	mov    (%eax),%eax
  100582:	8d 50 ff             	lea    -0x1(%eax),%edx
  100585:	8b 45 10             	mov    0x10(%ebp),%eax
  100588:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10058a:	eb 3f                	jmp    1005cb <stab_binsearch+0x154>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  10058c:	8b 45 10             	mov    0x10(%ebp),%eax
  10058f:	8b 00                	mov    (%eax),%eax
  100591:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100594:	eb 04                	jmp    10059a <stab_binsearch+0x123>
  100596:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  10059a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10059d:	8b 00                	mov    (%eax),%eax
  10059f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005a2:	7d 1f                	jge    1005c3 <stab_binsearch+0x14c>
  1005a4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005a7:	89 d0                	mov    %edx,%eax
  1005a9:	01 c0                	add    %eax,%eax
  1005ab:	01 d0                	add    %edx,%eax
  1005ad:	c1 e0 02             	shl    $0x2,%eax
  1005b0:	89 c2                	mov    %eax,%edx
  1005b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1005b5:	01 d0                	add    %edx,%eax
  1005b7:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005bb:	0f b6 c0             	movzbl %al,%eax
  1005be:	3b 45 14             	cmp    0x14(%ebp),%eax
  1005c1:	75 d3                	jne    100596 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  1005c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005c9:	89 10                	mov    %edx,(%eax)
    }
}
  1005cb:	90                   	nop
  1005cc:	c9                   	leave  
  1005cd:	c3                   	ret    

001005ce <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  1005ce:	55                   	push   %ebp
  1005cf:	89 e5                	mov    %esp,%ebp
  1005d1:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  1005d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d7:	c7 00 18 35 10 00    	movl   $0x103518,(%eax)
    info->eip_line = 0;
  1005dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  1005e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005ea:	c7 40 08 18 35 10 00 	movl   $0x103518,0x8(%eax)
    info->eip_fn_namelen = 9;
  1005f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f4:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  1005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fe:	8b 55 08             	mov    0x8(%ebp),%edx
  100601:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100604:	8b 45 0c             	mov    0xc(%ebp),%eax
  100607:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10060e:	c7 45 f4 4c 3d 10 00 	movl   $0x103d4c,-0xc(%ebp)
    stab_end = __STAB_END__;
  100615:	c7 45 f0 a8 b6 10 00 	movl   $0x10b6a8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10061c:	c7 45 ec a9 b6 10 00 	movl   $0x10b6a9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100623:	c7 45 e8 e6 d6 10 00 	movl   $0x10d6e6,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10062a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10062d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100630:	76 0d                	jbe    10063f <debuginfo_eip+0x71>
  100632:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100635:	83 e8 01             	sub    $0x1,%eax
  100638:	0f b6 00             	movzbl (%eax),%eax
  10063b:	84 c0                	test   %al,%al
  10063d:	74 0a                	je     100649 <debuginfo_eip+0x7b>
        return -1;
  10063f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100644:	e9 91 02 00 00       	jmp    1008da <debuginfo_eip+0x30c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100649:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100650:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100656:	29 c2                	sub    %eax,%edx
  100658:	89 d0                	mov    %edx,%eax
  10065a:	c1 f8 02             	sar    $0x2,%eax
  10065d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100663:	83 e8 01             	sub    $0x1,%eax
  100666:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  100669:	ff 75 08             	pushl  0x8(%ebp)
  10066c:	6a 64                	push   $0x64
  10066e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  100671:	50                   	push   %eax
  100672:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  100675:	50                   	push   %eax
  100676:	ff 75 f4             	pushl  -0xc(%ebp)
  100679:	e8 f9 fd ff ff       	call   100477 <stab_binsearch>
  10067e:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
  100681:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100684:	85 c0                	test   %eax,%eax
  100686:	75 0a                	jne    100692 <debuginfo_eip+0xc4>
        return -1;
  100688:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10068d:	e9 48 02 00 00       	jmp    1008da <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100695:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100698:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10069b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10069e:	ff 75 08             	pushl  0x8(%ebp)
  1006a1:	6a 24                	push   $0x24
  1006a3:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006a6:	50                   	push   %eax
  1006a7:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006aa:	50                   	push   %eax
  1006ab:	ff 75 f4             	pushl  -0xc(%ebp)
  1006ae:	e8 c4 fd ff ff       	call   100477 <stab_binsearch>
  1006b3:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
  1006b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1006b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006bc:	39 c2                	cmp    %eax,%edx
  1006be:	7f 7c                	jg     10073c <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1006c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c3:	89 c2                	mov    %eax,%edx
  1006c5:	89 d0                	mov    %edx,%eax
  1006c7:	01 c0                	add    %eax,%eax
  1006c9:	01 d0                	add    %edx,%eax
  1006cb:	c1 e0 02             	shl    $0x2,%eax
  1006ce:	89 c2                	mov    %eax,%edx
  1006d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006d3:	01 d0                	add    %edx,%eax
  1006d5:	8b 00                	mov    (%eax),%eax
  1006d7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1006da:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1006dd:	29 d1                	sub    %edx,%ecx
  1006df:	89 ca                	mov    %ecx,%edx
  1006e1:	39 d0                	cmp    %edx,%eax
  1006e3:	73 22                	jae    100707 <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  1006e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006e8:	89 c2                	mov    %eax,%edx
  1006ea:	89 d0                	mov    %edx,%eax
  1006ec:	01 c0                	add    %eax,%eax
  1006ee:	01 d0                	add    %edx,%eax
  1006f0:	c1 e0 02             	shl    $0x2,%eax
  1006f3:	89 c2                	mov    %eax,%edx
  1006f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006f8:	01 d0                	add    %edx,%eax
  1006fa:	8b 10                	mov    (%eax),%edx
  1006fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1006ff:	01 c2                	add    %eax,%edx
  100701:	8b 45 0c             	mov    0xc(%ebp),%eax
  100704:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100707:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10070a:	89 c2                	mov    %eax,%edx
  10070c:	89 d0                	mov    %edx,%eax
  10070e:	01 c0                	add    %eax,%eax
  100710:	01 d0                	add    %edx,%eax
  100712:	c1 e0 02             	shl    $0x2,%eax
  100715:	89 c2                	mov    %eax,%edx
  100717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10071a:	01 d0                	add    %edx,%eax
  10071c:	8b 50 08             	mov    0x8(%eax),%edx
  10071f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100722:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100725:	8b 45 0c             	mov    0xc(%ebp),%eax
  100728:	8b 40 10             	mov    0x10(%eax),%eax
  10072b:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10072e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100731:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100734:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100737:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10073a:	eb 15                	jmp    100751 <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  10073c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10073f:	8b 55 08             	mov    0x8(%ebp),%edx
  100742:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100745:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100748:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  10074b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10074e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  100751:	8b 45 0c             	mov    0xc(%ebp),%eax
  100754:	8b 40 08             	mov    0x8(%eax),%eax
  100757:	83 ec 08             	sub    $0x8,%esp
  10075a:	6a 3a                	push   $0x3a
  10075c:	50                   	push   %eax
  10075d:	e8 97 23 00 00       	call   102af9 <strfind>
  100762:	83 c4 10             	add    $0x10,%esp
  100765:	89 c2                	mov    %eax,%edx
  100767:	8b 45 0c             	mov    0xc(%ebp),%eax
  10076a:	8b 40 08             	mov    0x8(%eax),%eax
  10076d:	29 c2                	sub    %eax,%edx
  10076f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100772:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100775:	83 ec 0c             	sub    $0xc,%esp
  100778:	ff 75 08             	pushl  0x8(%ebp)
  10077b:	6a 44                	push   $0x44
  10077d:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100780:	50                   	push   %eax
  100781:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100784:	50                   	push   %eax
  100785:	ff 75 f4             	pushl  -0xc(%ebp)
  100788:	e8 ea fc ff ff       	call   100477 <stab_binsearch>
  10078d:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
  100790:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100793:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100796:	39 c2                	cmp    %eax,%edx
  100798:	7f 24                	jg     1007be <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
  10079a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10079d:	89 c2                	mov    %eax,%edx
  10079f:	89 d0                	mov    %edx,%eax
  1007a1:	01 c0                	add    %eax,%eax
  1007a3:	01 d0                	add    %edx,%eax
  1007a5:	c1 e0 02             	shl    $0x2,%eax
  1007a8:	89 c2                	mov    %eax,%edx
  1007aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ad:	01 d0                	add    %edx,%eax
  1007af:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  1007b3:	0f b7 d0             	movzwl %ax,%edx
  1007b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007b9:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007bc:	eb 13                	jmp    1007d1 <debuginfo_eip+0x203>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  1007be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007c3:	e9 12 01 00 00       	jmp    1008da <debuginfo_eip+0x30c>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  1007c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007cb:	83 e8 01             	sub    $0x1,%eax
  1007ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007d7:	39 c2                	cmp    %eax,%edx
  1007d9:	7c 56                	jl     100831 <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
  1007db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007de:	89 c2                	mov    %eax,%edx
  1007e0:	89 d0                	mov    %edx,%eax
  1007e2:	01 c0                	add    %eax,%eax
  1007e4:	01 d0                	add    %edx,%eax
  1007e6:	c1 e0 02             	shl    $0x2,%eax
  1007e9:	89 c2                	mov    %eax,%edx
  1007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ee:	01 d0                	add    %edx,%eax
  1007f0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007f4:	3c 84                	cmp    $0x84,%al
  1007f6:	74 39                	je     100831 <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  1007f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007fb:	89 c2                	mov    %eax,%edx
  1007fd:	89 d0                	mov    %edx,%eax
  1007ff:	01 c0                	add    %eax,%eax
  100801:	01 d0                	add    %edx,%eax
  100803:	c1 e0 02             	shl    $0x2,%eax
  100806:	89 c2                	mov    %eax,%edx
  100808:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10080b:	01 d0                	add    %edx,%eax
  10080d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100811:	3c 64                	cmp    $0x64,%al
  100813:	75 b3                	jne    1007c8 <debuginfo_eip+0x1fa>
  100815:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100818:	89 c2                	mov    %eax,%edx
  10081a:	89 d0                	mov    %edx,%eax
  10081c:	01 c0                	add    %eax,%eax
  10081e:	01 d0                	add    %edx,%eax
  100820:	c1 e0 02             	shl    $0x2,%eax
  100823:	89 c2                	mov    %eax,%edx
  100825:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100828:	01 d0                	add    %edx,%eax
  10082a:	8b 40 08             	mov    0x8(%eax),%eax
  10082d:	85 c0                	test   %eax,%eax
  10082f:	74 97                	je     1007c8 <debuginfo_eip+0x1fa>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100831:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100837:	39 c2                	cmp    %eax,%edx
  100839:	7c 46                	jl     100881 <debuginfo_eip+0x2b3>
  10083b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10083e:	89 c2                	mov    %eax,%edx
  100840:	89 d0                	mov    %edx,%eax
  100842:	01 c0                	add    %eax,%eax
  100844:	01 d0                	add    %edx,%eax
  100846:	c1 e0 02             	shl    $0x2,%eax
  100849:	89 c2                	mov    %eax,%edx
  10084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10084e:	01 d0                	add    %edx,%eax
  100850:	8b 00                	mov    (%eax),%eax
  100852:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100855:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100858:	29 d1                	sub    %edx,%ecx
  10085a:	89 ca                	mov    %ecx,%edx
  10085c:	39 d0                	cmp    %edx,%eax
  10085e:	73 21                	jae    100881 <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100860:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100863:	89 c2                	mov    %eax,%edx
  100865:	89 d0                	mov    %edx,%eax
  100867:	01 c0                	add    %eax,%eax
  100869:	01 d0                	add    %edx,%eax
  10086b:	c1 e0 02             	shl    $0x2,%eax
  10086e:	89 c2                	mov    %eax,%edx
  100870:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100873:	01 d0                	add    %edx,%eax
  100875:	8b 10                	mov    (%eax),%edx
  100877:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10087a:	01 c2                	add    %eax,%edx
  10087c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10087f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100881:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100884:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100887:	39 c2                	cmp    %eax,%edx
  100889:	7d 4a                	jge    1008d5 <debuginfo_eip+0x307>
        for (lline = lfun + 1;
  10088b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10088e:	83 c0 01             	add    $0x1,%eax
  100891:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100894:	eb 18                	jmp    1008ae <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100896:	8b 45 0c             	mov    0xc(%ebp),%eax
  100899:	8b 40 14             	mov    0x14(%eax),%eax
  10089c:	8d 50 01             	lea    0x1(%eax),%edx
  10089f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008a2:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  1008a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008a8:	83 c0 01             	add    $0x1,%eax
  1008ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  1008b4:	39 c2                	cmp    %eax,%edx
  1008b6:	7d 1d                	jge    1008d5 <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008bb:	89 c2                	mov    %eax,%edx
  1008bd:	89 d0                	mov    %edx,%eax
  1008bf:	01 c0                	add    %eax,%eax
  1008c1:	01 d0                	add    %edx,%eax
  1008c3:	c1 e0 02             	shl    $0x2,%eax
  1008c6:	89 c2                	mov    %eax,%edx
  1008c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008cb:	01 d0                	add    %edx,%eax
  1008cd:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1008d1:	3c a0                	cmp    $0xa0,%al
  1008d3:	74 c1                	je     100896 <debuginfo_eip+0x2c8>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  1008d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1008da:	c9                   	leave  
  1008db:	c3                   	ret    

001008dc <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  1008dc:	55                   	push   %ebp
  1008dd:	89 e5                	mov    %esp,%ebp
  1008df:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  1008e2:	83 ec 0c             	sub    $0xc,%esp
  1008e5:	68 22 35 10 00       	push   $0x103522
  1008ea:	e8 4e f9 ff ff       	call   10023d <cprintf>
  1008ef:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  1008f2:	83 ec 08             	sub    $0x8,%esp
  1008f5:	68 00 00 10 00       	push   $0x100000
  1008fa:	68 3b 35 10 00       	push   $0x10353b
  1008ff:	e8 39 f9 ff ff       	call   10023d <cprintf>
  100904:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
  100907:	83 ec 08             	sub    $0x8,%esp
  10090a:	68 1c 34 10 00       	push   $0x10341c
  10090f:	68 53 35 10 00       	push   $0x103553
  100914:	e8 24 f9 ff ff       	call   10023d <cprintf>
  100919:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
  10091c:	83 ec 08             	sub    $0x8,%esp
  10091f:	68 16 ea 10 00       	push   $0x10ea16
  100924:	68 6b 35 10 00       	push   $0x10356b
  100929:	e8 0f f9 ff ff       	call   10023d <cprintf>
  10092e:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
  100931:	83 ec 08             	sub    $0x8,%esp
  100934:	68 20 fd 10 00       	push   $0x10fd20
  100939:	68 83 35 10 00       	push   $0x103583
  10093e:	e8 fa f8 ff ff       	call   10023d <cprintf>
  100943:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  100946:	b8 20 fd 10 00       	mov    $0x10fd20,%eax
  10094b:	05 ff 03 00 00       	add    $0x3ff,%eax
  100950:	ba 00 00 10 00       	mov    $0x100000,%edx
  100955:	29 d0                	sub    %edx,%eax
  100957:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10095d:	85 c0                	test   %eax,%eax
  10095f:	0f 48 c2             	cmovs  %edx,%eax
  100962:	c1 f8 0a             	sar    $0xa,%eax
  100965:	83 ec 08             	sub    $0x8,%esp
  100968:	50                   	push   %eax
  100969:	68 9c 35 10 00       	push   $0x10359c
  10096e:	e8 ca f8 ff ff       	call   10023d <cprintf>
  100973:	83 c4 10             	add    $0x10,%esp
}
  100976:	90                   	nop
  100977:	c9                   	leave  
  100978:	c3                   	ret    

00100979 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100979:	55                   	push   %ebp
  10097a:	89 e5                	mov    %esp,%ebp
  10097c:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100982:	83 ec 08             	sub    $0x8,%esp
  100985:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100988:	50                   	push   %eax
  100989:	ff 75 08             	pushl  0x8(%ebp)
  10098c:	e8 3d fc ff ff       	call   1005ce <debuginfo_eip>
  100991:	83 c4 10             	add    $0x10,%esp
  100994:	85 c0                	test   %eax,%eax
  100996:	74 15                	je     1009ad <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100998:	83 ec 08             	sub    $0x8,%esp
  10099b:	ff 75 08             	pushl  0x8(%ebp)
  10099e:	68 c6 35 10 00       	push   $0x1035c6
  1009a3:	e8 95 f8 ff ff       	call   10023d <cprintf>
  1009a8:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  1009ab:	eb 65                	jmp    100a12 <print_debuginfo+0x99>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009b4:	eb 1c                	jmp    1009d2 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  1009b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1009b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009bc:	01 d0                	add    %edx,%eax
  1009be:	0f b6 00             	movzbl (%eax),%eax
  1009c1:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1009ca:	01 ca                	add    %ecx,%edx
  1009cc:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1009d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009d5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1009d8:	7f dc                	jg     1009b6 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  1009da:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  1009e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009e3:	01 d0                	add    %edx,%eax
  1009e5:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  1009e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  1009eb:	8b 55 08             	mov    0x8(%ebp),%edx
  1009ee:	89 d1                	mov    %edx,%ecx
  1009f0:	29 c1                	sub    %eax,%ecx
  1009f2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1009f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1009f8:	83 ec 0c             	sub    $0xc,%esp
  1009fb:	51                   	push   %ecx
  1009fc:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a02:	51                   	push   %ecx
  100a03:	52                   	push   %edx
  100a04:	50                   	push   %eax
  100a05:	68 e2 35 10 00       	push   $0x1035e2
  100a0a:	e8 2e f8 ff ff       	call   10023d <cprintf>
  100a0f:	83 c4 20             	add    $0x20,%esp
                fnname, eip - info.eip_fn_addr);
    }
}
  100a12:	90                   	nop
  100a13:	c9                   	leave  
  100a14:	c3                   	ret    

00100a15 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a15:	55                   	push   %ebp
  100a16:	89 e5                	mov    %esp,%ebp
  100a18:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a1b:	8b 45 04             	mov    0x4(%ebp),%eax
  100a1e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a21:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a24:	c9                   	leave  
  100a25:	c3                   	ret    

00100a26 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a26:	55                   	push   %ebp
  100a27:	89 e5                	mov    %esp,%ebp
  100a29:	53                   	push   %ebx
  100a2a:	83 ec 24             	sub    $0x24,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a2d:	89 e8                	mov    %ebp,%eax
  100a2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  100a32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
  100a35:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
  100a38:	e8 d8 ff ff ff       	call   100a15 <read_eip>
  100a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int itr = 0; itr < STACKFRAME_DEPTH && ebp != 0; itr++) {
  100a40:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a47:	e9 89 00 00 00       	jmp    100ad5 <print_stackframe+0xaf>
        cprintf("ebp = 0x%08x, eip = 0x%08x", ebp, eip);
  100a4c:	83 ec 04             	sub    $0x4,%esp
  100a4f:	ff 75 f0             	pushl  -0x10(%ebp)
  100a52:	ff 75 f4             	pushl  -0xc(%ebp)
  100a55:	68 f4 35 10 00       	push   $0x1035f4
  100a5a:	e8 de f7 ff ff       	call   10023d <cprintf>
  100a5f:	83 c4 10             	add    $0x10,%esp
        uint32_t *ptr = (uint32_t *)(ebp + 2);
  100a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a65:	83 c0 02             	add    $0x2,%eax
  100a68:	89 45 e8             	mov    %eax,-0x18(%ebp)
        cprintf("arg = 0x%08x, 0x%08x, 0x%08x, 0x%08x", *(ptr), *(ptr+1), *(ptr+2), *(ptr+3));
  100a6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a6e:	83 c0 0c             	add    $0xc,%eax
  100a71:	8b 18                	mov    (%eax),%ebx
  100a73:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a76:	83 c0 08             	add    $0x8,%eax
  100a79:	8b 08                	mov    (%eax),%ecx
  100a7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a7e:	83 c0 04             	add    $0x4,%eax
  100a81:	8b 10                	mov    (%eax),%edx
  100a83:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a86:	8b 00                	mov    (%eax),%eax
  100a88:	83 ec 0c             	sub    $0xc,%esp
  100a8b:	53                   	push   %ebx
  100a8c:	51                   	push   %ecx
  100a8d:	52                   	push   %edx
  100a8e:	50                   	push   %eax
  100a8f:	68 10 36 10 00       	push   $0x103610
  100a94:	e8 a4 f7 ff ff       	call   10023d <cprintf>
  100a99:	83 c4 20             	add    $0x20,%esp
        cprintf("\n");
  100a9c:	83 ec 0c             	sub    $0xc,%esp
  100a9f:	68 35 36 10 00       	push   $0x103635
  100aa4:	e8 94 f7 ff ff       	call   10023d <cprintf>
  100aa9:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
  100aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100aaf:	83 e8 01             	sub    $0x1,%eax
  100ab2:	83 ec 0c             	sub    $0xc,%esp
  100ab5:	50                   	push   %eax
  100ab6:	e8 be fe ff ff       	call   100979 <print_debuginfo>
  100abb:	83 c4 10             	add    $0x10,%esp

        //(3.5???)
        eip = ((uint32_t *)ebp)[1];
  100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ac1:	83 c0 04             	add    $0x4,%eax
  100ac4:	8b 00                	mov    (%eax),%eax
  100ac6:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100acc:	8b 00                	mov    (%eax),%eax
  100ace:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
    uint32_t eip = read_eip();
    for (int itr = 0; itr < STACKFRAME_DEPTH && ebp != 0; itr++) {
  100ad1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100ad5:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100ad9:	7f 0a                	jg     100ae5 <print_stackframe+0xbf>
  100adb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100adf:	0f 85 67 ff ff ff    	jne    100a4c <print_stackframe+0x26>

        //(3.5???)
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
  100ae5:	90                   	nop
  100ae6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100ae9:	c9                   	leave  
  100aea:	c3                   	ret    

00100aeb <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100aeb:	55                   	push   %ebp
  100aec:	89 e5                	mov    %esp,%ebp
  100aee:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
  100af1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100af8:	eb 0c                	jmp    100b06 <parse+0x1b>
            *buf ++ = '\0';
  100afa:	8b 45 08             	mov    0x8(%ebp),%eax
  100afd:	8d 50 01             	lea    0x1(%eax),%edx
  100b00:	89 55 08             	mov    %edx,0x8(%ebp)
  100b03:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b06:	8b 45 08             	mov    0x8(%ebp),%eax
  100b09:	0f b6 00             	movzbl (%eax),%eax
  100b0c:	84 c0                	test   %al,%al
  100b0e:	74 1e                	je     100b2e <parse+0x43>
  100b10:	8b 45 08             	mov    0x8(%ebp),%eax
  100b13:	0f b6 00             	movzbl (%eax),%eax
  100b16:	0f be c0             	movsbl %al,%eax
  100b19:	83 ec 08             	sub    $0x8,%esp
  100b1c:	50                   	push   %eax
  100b1d:	68 b8 36 10 00       	push   $0x1036b8
  100b22:	e8 9f 1f 00 00       	call   102ac6 <strchr>
  100b27:	83 c4 10             	add    $0x10,%esp
  100b2a:	85 c0                	test   %eax,%eax
  100b2c:	75 cc                	jne    100afa <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b31:	0f b6 00             	movzbl (%eax),%eax
  100b34:	84 c0                	test   %al,%al
  100b36:	74 69                	je     100ba1 <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b38:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b3c:	75 12                	jne    100b50 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b3e:	83 ec 08             	sub    $0x8,%esp
  100b41:	6a 10                	push   $0x10
  100b43:	68 bd 36 10 00       	push   $0x1036bd
  100b48:	e8 f0 f6 ff ff       	call   10023d <cprintf>
  100b4d:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
  100b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b53:	8d 50 01             	lea    0x1(%eax),%edx
  100b56:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b59:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b63:	01 c2                	add    %eax,%edx
  100b65:	8b 45 08             	mov    0x8(%ebp),%eax
  100b68:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b6a:	eb 04                	jmp    100b70 <parse+0x85>
            buf ++;
  100b6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b70:	8b 45 08             	mov    0x8(%ebp),%eax
  100b73:	0f b6 00             	movzbl (%eax),%eax
  100b76:	84 c0                	test   %al,%al
  100b78:	0f 84 7a ff ff ff    	je     100af8 <parse+0xd>
  100b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b81:	0f b6 00             	movzbl (%eax),%eax
  100b84:	0f be c0             	movsbl %al,%eax
  100b87:	83 ec 08             	sub    $0x8,%esp
  100b8a:	50                   	push   %eax
  100b8b:	68 b8 36 10 00       	push   $0x1036b8
  100b90:	e8 31 1f 00 00       	call   102ac6 <strchr>
  100b95:	83 c4 10             	add    $0x10,%esp
  100b98:	85 c0                	test   %eax,%eax
  100b9a:	74 d0                	je     100b6c <parse+0x81>
            buf ++;
        }
    }
  100b9c:	e9 57 ff ff ff       	jmp    100af8 <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
  100ba1:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100ba5:	c9                   	leave  
  100ba6:	c3                   	ret    

00100ba7 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100ba7:	55                   	push   %ebp
  100ba8:	89 e5                	mov    %esp,%ebp
  100baa:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100bad:	83 ec 08             	sub    $0x8,%esp
  100bb0:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bb3:	50                   	push   %eax
  100bb4:	ff 75 08             	pushl  0x8(%ebp)
  100bb7:	e8 2f ff ff ff       	call   100aeb <parse>
  100bbc:	83 c4 10             	add    $0x10,%esp
  100bbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100bc2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100bc6:	75 0a                	jne    100bd2 <runcmd+0x2b>
        return 0;
  100bc8:	b8 00 00 00 00       	mov    $0x0,%eax
  100bcd:	e9 83 00 00 00       	jmp    100c55 <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100bd9:	eb 59                	jmp    100c34 <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100bdb:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100bde:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100be1:	89 d0                	mov    %edx,%eax
  100be3:	01 c0                	add    %eax,%eax
  100be5:	01 d0                	add    %edx,%eax
  100be7:	c1 e0 02             	shl    $0x2,%eax
  100bea:	05 00 e0 10 00       	add    $0x10e000,%eax
  100bef:	8b 00                	mov    (%eax),%eax
  100bf1:	83 ec 08             	sub    $0x8,%esp
  100bf4:	51                   	push   %ecx
  100bf5:	50                   	push   %eax
  100bf6:	e8 2b 1e 00 00       	call   102a26 <strcmp>
  100bfb:	83 c4 10             	add    $0x10,%esp
  100bfe:	85 c0                	test   %eax,%eax
  100c00:	75 2e                	jne    100c30 <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c05:	89 d0                	mov    %edx,%eax
  100c07:	01 c0                	add    %eax,%eax
  100c09:	01 d0                	add    %edx,%eax
  100c0b:	c1 e0 02             	shl    $0x2,%eax
  100c0e:	05 08 e0 10 00       	add    $0x10e008,%eax
  100c13:	8b 10                	mov    (%eax),%edx
  100c15:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c18:	83 c0 04             	add    $0x4,%eax
  100c1b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c1e:	83 e9 01             	sub    $0x1,%ecx
  100c21:	83 ec 04             	sub    $0x4,%esp
  100c24:	ff 75 0c             	pushl  0xc(%ebp)
  100c27:	50                   	push   %eax
  100c28:	51                   	push   %ecx
  100c29:	ff d2                	call   *%edx
  100c2b:	83 c4 10             	add    $0x10,%esp
  100c2e:	eb 25                	jmp    100c55 <runcmd+0xae>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c30:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c37:	83 f8 02             	cmp    $0x2,%eax
  100c3a:	76 9f                	jbe    100bdb <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c3c:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c3f:	83 ec 08             	sub    $0x8,%esp
  100c42:	50                   	push   %eax
  100c43:	68 db 36 10 00       	push   $0x1036db
  100c48:	e8 f0 f5 ff ff       	call   10023d <cprintf>
  100c4d:	83 c4 10             	add    $0x10,%esp
    return 0;
  100c50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c55:	c9                   	leave  
  100c56:	c3                   	ret    

00100c57 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c57:	55                   	push   %ebp
  100c58:	89 e5                	mov    %esp,%ebp
  100c5a:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c5d:	83 ec 0c             	sub    $0xc,%esp
  100c60:	68 f4 36 10 00       	push   $0x1036f4
  100c65:	e8 d3 f5 ff ff       	call   10023d <cprintf>
  100c6a:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
  100c6d:	83 ec 0c             	sub    $0xc,%esp
  100c70:	68 1c 37 10 00       	push   $0x10371c
  100c75:	e8 c3 f5 ff ff       	call   10023d <cprintf>
  100c7a:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
  100c7d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c81:	74 0e                	je     100c91 <kmonitor+0x3a>
        print_trapframe(tf);
  100c83:	83 ec 0c             	sub    $0xc,%esp
  100c86:	ff 75 08             	pushl  0x8(%ebp)
  100c89:	e8 31 0d 00 00       	call   1019bf <print_trapframe>
  100c8e:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c91:	83 ec 0c             	sub    $0xc,%esp
  100c94:	68 41 37 10 00       	push   $0x103741
  100c99:	e8 43 f6 ff ff       	call   1002e1 <readline>
  100c9e:	83 c4 10             	add    $0x10,%esp
  100ca1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100ca4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100ca8:	74 e7                	je     100c91 <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
  100caa:	83 ec 08             	sub    $0x8,%esp
  100cad:	ff 75 08             	pushl  0x8(%ebp)
  100cb0:	ff 75 f4             	pushl  -0xc(%ebp)
  100cb3:	e8 ef fe ff ff       	call   100ba7 <runcmd>
  100cb8:	83 c4 10             	add    $0x10,%esp
  100cbb:	85 c0                	test   %eax,%eax
  100cbd:	78 02                	js     100cc1 <kmonitor+0x6a>
                break;
            }
        }
    }
  100cbf:	eb d0                	jmp    100c91 <kmonitor+0x3a>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
  100cc1:	90                   	nop
            }
        }
    }
}
  100cc2:	90                   	nop
  100cc3:	c9                   	leave  
  100cc4:	c3                   	ret    

00100cc5 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100cc5:	55                   	push   %ebp
  100cc6:	89 e5                	mov    %esp,%ebp
  100cc8:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100ccb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100cd2:	eb 3c                	jmp    100d10 <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100cd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100cd7:	89 d0                	mov    %edx,%eax
  100cd9:	01 c0                	add    %eax,%eax
  100cdb:	01 d0                	add    %edx,%eax
  100cdd:	c1 e0 02             	shl    $0x2,%eax
  100ce0:	05 04 e0 10 00       	add    $0x10e004,%eax
  100ce5:	8b 08                	mov    (%eax),%ecx
  100ce7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100cea:	89 d0                	mov    %edx,%eax
  100cec:	01 c0                	add    %eax,%eax
  100cee:	01 d0                	add    %edx,%eax
  100cf0:	c1 e0 02             	shl    $0x2,%eax
  100cf3:	05 00 e0 10 00       	add    $0x10e000,%eax
  100cf8:	8b 00                	mov    (%eax),%eax
  100cfa:	83 ec 04             	sub    $0x4,%esp
  100cfd:	51                   	push   %ecx
  100cfe:	50                   	push   %eax
  100cff:	68 45 37 10 00       	push   $0x103745
  100d04:	e8 34 f5 ff ff       	call   10023d <cprintf>
  100d09:	83 c4 10             	add    $0x10,%esp

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d0c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d13:	83 f8 02             	cmp    $0x2,%eax
  100d16:	76 bc                	jbe    100cd4 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100d18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d1d:	c9                   	leave  
  100d1e:	c3                   	ret    

00100d1f <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d1f:	55                   	push   %ebp
  100d20:	89 e5                	mov    %esp,%ebp
  100d22:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d25:	e8 b2 fb ff ff       	call   1008dc <print_kerninfo>
    return 0;
  100d2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d2f:	c9                   	leave  
  100d30:	c3                   	ret    

00100d31 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d31:	55                   	push   %ebp
  100d32:	89 e5                	mov    %esp,%ebp
  100d34:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d37:	e8 ea fc ff ff       	call   100a26 <print_stackframe>
    return 0;
  100d3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d41:	c9                   	leave  
  100d42:	c3                   	ret    

00100d43 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d43:	55                   	push   %ebp
  100d44:	89 e5                	mov    %esp,%ebp
  100d46:	83 ec 18             	sub    $0x18,%esp
  100d49:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d4f:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d53:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  100d57:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d5b:	ee                   	out    %al,(%dx)
  100d5c:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
  100d62:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
  100d66:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  100d6a:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
  100d6e:	ee                   	out    %al,(%dx)
  100d6f:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d75:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
  100d79:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100d7d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100d81:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100d82:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100d89:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100d8c:	83 ec 0c             	sub    $0xc,%esp
  100d8f:	68 4e 37 10 00       	push   $0x10374e
  100d94:	e8 a4 f4 ff ff       	call   10023d <cprintf>
  100d99:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
  100d9c:	83 ec 0c             	sub    $0xc,%esp
  100d9f:	6a 00                	push   $0x0
  100da1:	e8 ce 08 00 00       	call   101674 <pic_enable>
  100da6:	83 c4 10             	add    $0x10,%esp
}
  100da9:	90                   	nop
  100daa:	c9                   	leave  
  100dab:	c3                   	ret    

00100dac <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100dac:	55                   	push   %ebp
  100dad:	89 e5                	mov    %esp,%ebp
  100daf:	83 ec 10             	sub    $0x10,%esp
  100db2:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100db8:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100dbc:	89 c2                	mov    %eax,%edx
  100dbe:	ec                   	in     (%dx),%al
  100dbf:	88 45 f4             	mov    %al,-0xc(%ebp)
  100dc2:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
  100dc8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
  100dcc:	89 c2                	mov    %eax,%edx
  100dce:	ec                   	in     (%dx),%al
  100dcf:	88 45 f5             	mov    %al,-0xb(%ebp)
  100dd2:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100dd8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100ddc:	89 c2                	mov    %eax,%edx
  100dde:	ec                   	in     (%dx),%al
  100ddf:	88 45 f6             	mov    %al,-0xa(%ebp)
  100de2:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
  100de8:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
  100dec:	89 c2                	mov    %eax,%edx
  100dee:	ec                   	in     (%dx),%al
  100def:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100df2:	90                   	nop
  100df3:	c9                   	leave  
  100df4:	c3                   	ret    

00100df5 <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100df5:	55                   	push   %ebp
  100df6:	89 e5                	mov    %esp,%ebp
  100df8:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100dfb:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e02:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e05:	0f b7 00             	movzwl (%eax),%eax
  100e08:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e0f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e14:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e17:	0f b7 00             	movzwl (%eax),%eax
  100e1a:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e1e:	74 12                	je     100e32 <cga_init+0x3d>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e20:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e27:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e2e:	b4 03 
  100e30:	eb 13                	jmp    100e45 <cga_init+0x50>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e32:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e35:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e39:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e3c:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e43:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100e45:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e4c:	0f b7 c0             	movzwl %ax,%eax
  100e4f:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  100e53:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e57:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  100e5b:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
  100e5f:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100e60:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e67:	83 c0 01             	add    $0x1,%eax
  100e6a:	0f b7 c0             	movzwl %ax,%eax
  100e6d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e71:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e75:	89 c2                	mov    %eax,%edx
  100e77:	ec                   	in     (%dx),%al
  100e78:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  100e7b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  100e7f:	0f b6 c0             	movzbl %al,%eax
  100e82:	c1 e0 08             	shl    $0x8,%eax
  100e85:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100e88:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e8f:	0f b7 c0             	movzwl %ax,%eax
  100e92:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
  100e96:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e9a:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
  100e9e:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  100ea2:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100ea3:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100eaa:	83 c0 01             	add    $0x1,%eax
  100ead:	0f b7 c0             	movzwl %ax,%eax
  100eb0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100eb4:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100eb8:	89 c2                	mov    %eax,%edx
  100eba:	ec                   	in     (%dx),%al
  100ebb:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100ebe:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100ec2:	0f b6 c0             	movzbl %al,%eax
  100ec5:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100ec8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ecb:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ed3:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100ed9:	90                   	nop
  100eda:	c9                   	leave  
  100edb:	c3                   	ret    

00100edc <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100edc:	55                   	push   %ebp
  100edd:	89 e5                	mov    %esp,%ebp
  100edf:	83 ec 28             	sub    $0x28,%esp
  100ee2:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100ee8:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100eec:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  100ef0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100ef4:	ee                   	out    %al,(%dx)
  100ef5:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
  100efb:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
  100eff:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  100f03:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
  100f07:	ee                   	out    %al,(%dx)
  100f08:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
  100f0e:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
  100f12:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  100f16:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f1a:	ee                   	out    %al,(%dx)
  100f1b:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
  100f21:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100f25:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f29:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  100f2d:	ee                   	out    %al,(%dx)
  100f2e:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
  100f34:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
  100f38:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  100f3c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f40:	ee                   	out    %al,(%dx)
  100f41:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
  100f47:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  100f4b:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  100f4f:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
  100f53:	ee                   	out    %al,(%dx)
  100f54:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f5a:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
  100f5e:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  100f62:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f66:	ee                   	out    %al,(%dx)
  100f67:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f6d:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
  100f71:	89 c2                	mov    %eax,%edx
  100f73:	ec                   	in     (%dx),%al
  100f74:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
  100f77:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100f7b:	3c ff                	cmp    $0xff,%al
  100f7d:	0f 95 c0             	setne  %al
  100f80:	0f b6 c0             	movzbl %al,%eax
  100f83:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100f88:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f8e:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f92:	89 c2                	mov    %eax,%edx
  100f94:	ec                   	in     (%dx),%al
  100f95:	88 45 e2             	mov    %al,-0x1e(%ebp)
  100f98:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
  100f9e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
  100fa2:	89 c2                	mov    %eax,%edx
  100fa4:	ec                   	in     (%dx),%al
  100fa5:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fa8:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fad:	85 c0                	test   %eax,%eax
  100faf:	74 0d                	je     100fbe <serial_init+0xe2>
        pic_enable(IRQ_COM1);
  100fb1:	83 ec 0c             	sub    $0xc,%esp
  100fb4:	6a 04                	push   $0x4
  100fb6:	e8 b9 06 00 00       	call   101674 <pic_enable>
  100fbb:	83 c4 10             	add    $0x10,%esp
    }
}
  100fbe:	90                   	nop
  100fbf:	c9                   	leave  
  100fc0:	c3                   	ret    

00100fc1 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100fc1:	55                   	push   %ebp
  100fc2:	89 e5                	mov    %esp,%ebp
  100fc4:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fc7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100fce:	eb 09                	jmp    100fd9 <lpt_putc_sub+0x18>
        delay();
  100fd0:	e8 d7 fd ff ff       	call   100dac <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fd5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  100fd9:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
  100fdf:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100fe3:	89 c2                	mov    %eax,%edx
  100fe5:	ec                   	in     (%dx),%al
  100fe6:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
  100fe9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  100fed:	84 c0                	test   %al,%al
  100fef:	78 09                	js     100ffa <lpt_putc_sub+0x39>
  100ff1:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  100ff8:	7e d6                	jle    100fd0 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  100ffa:	8b 45 08             	mov    0x8(%ebp),%eax
  100ffd:	0f b6 c0             	movzbl %al,%eax
  101000:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
  101006:	88 45 f0             	mov    %al,-0x10(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101009:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  10100d:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
  101011:	ee                   	out    %al,(%dx)
  101012:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101018:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  10101c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101020:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101024:	ee                   	out    %al,(%dx)
  101025:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
  10102b:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
  10102f:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  101033:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101037:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101038:	90                   	nop
  101039:	c9                   	leave  
  10103a:	c3                   	ret    

0010103b <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  10103b:	55                   	push   %ebp
  10103c:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
  10103e:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101042:	74 0d                	je     101051 <lpt_putc+0x16>
        lpt_putc_sub(c);
  101044:	ff 75 08             	pushl  0x8(%ebp)
  101047:	e8 75 ff ff ff       	call   100fc1 <lpt_putc_sub>
  10104c:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  10104f:	eb 1e                	jmp    10106f <lpt_putc+0x34>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
  101051:	6a 08                	push   $0x8
  101053:	e8 69 ff ff ff       	call   100fc1 <lpt_putc_sub>
  101058:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
  10105b:	6a 20                	push   $0x20
  10105d:	e8 5f ff ff ff       	call   100fc1 <lpt_putc_sub>
  101062:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
  101065:	6a 08                	push   $0x8
  101067:	e8 55 ff ff ff       	call   100fc1 <lpt_putc_sub>
  10106c:	83 c4 04             	add    $0x4,%esp
    }
}
  10106f:	90                   	nop
  101070:	c9                   	leave  
  101071:	c3                   	ret    

00101072 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101072:	55                   	push   %ebp
  101073:	89 e5                	mov    %esp,%ebp
  101075:	53                   	push   %ebx
  101076:	83 ec 14             	sub    $0x14,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101079:	8b 45 08             	mov    0x8(%ebp),%eax
  10107c:	b0 00                	mov    $0x0,%al
  10107e:	85 c0                	test   %eax,%eax
  101080:	75 07                	jne    101089 <cga_putc+0x17>
        c |= 0x0700;
  101082:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101089:	8b 45 08             	mov    0x8(%ebp),%eax
  10108c:	0f b6 c0             	movzbl %al,%eax
  10108f:	83 f8 0a             	cmp    $0xa,%eax
  101092:	74 4e                	je     1010e2 <cga_putc+0x70>
  101094:	83 f8 0d             	cmp    $0xd,%eax
  101097:	74 59                	je     1010f2 <cga_putc+0x80>
  101099:	83 f8 08             	cmp    $0x8,%eax
  10109c:	0f 85 8a 00 00 00    	jne    10112c <cga_putc+0xba>
    case '\b':
        if (crt_pos > 0) {
  1010a2:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010a9:	66 85 c0             	test   %ax,%ax
  1010ac:	0f 84 a0 00 00 00    	je     101152 <cga_putc+0xe0>
            crt_pos --;
  1010b2:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010b9:	83 e8 01             	sub    $0x1,%eax
  1010bc:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010c2:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010c7:	0f b7 15 64 ee 10 00 	movzwl 0x10ee64,%edx
  1010ce:	0f b7 d2             	movzwl %dx,%edx
  1010d1:	01 d2                	add    %edx,%edx
  1010d3:	01 d0                	add    %edx,%eax
  1010d5:	8b 55 08             	mov    0x8(%ebp),%edx
  1010d8:	b2 00                	mov    $0x0,%dl
  1010da:	83 ca 20             	or     $0x20,%edx
  1010dd:	66 89 10             	mov    %dx,(%eax)
        }
        break;
  1010e0:	eb 70                	jmp    101152 <cga_putc+0xe0>
    case '\n':
        crt_pos += CRT_COLS;
  1010e2:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010e9:	83 c0 50             	add    $0x50,%eax
  1010ec:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1010f2:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  1010f9:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  101100:	0f b7 c1             	movzwl %cx,%eax
  101103:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  101109:	c1 e8 10             	shr    $0x10,%eax
  10110c:	89 c2                	mov    %eax,%edx
  10110e:	66 c1 ea 06          	shr    $0x6,%dx
  101112:	89 d0                	mov    %edx,%eax
  101114:	c1 e0 02             	shl    $0x2,%eax
  101117:	01 d0                	add    %edx,%eax
  101119:	c1 e0 04             	shl    $0x4,%eax
  10111c:	29 c1                	sub    %eax,%ecx
  10111e:	89 ca                	mov    %ecx,%edx
  101120:	89 d8                	mov    %ebx,%eax
  101122:	29 d0                	sub    %edx,%eax
  101124:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  10112a:	eb 27                	jmp    101153 <cga_putc+0xe1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10112c:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  101132:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101139:	8d 50 01             	lea    0x1(%eax),%edx
  10113c:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  101143:	0f b7 c0             	movzwl %ax,%eax
  101146:	01 c0                	add    %eax,%eax
  101148:	01 c8                	add    %ecx,%eax
  10114a:	8b 55 08             	mov    0x8(%ebp),%edx
  10114d:	66 89 10             	mov    %dx,(%eax)
        break;
  101150:	eb 01                	jmp    101153 <cga_putc+0xe1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
  101152:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101153:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10115a:	66 3d cf 07          	cmp    $0x7cf,%ax
  10115e:	76 59                	jbe    1011b9 <cga_putc+0x147>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101160:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101165:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10116b:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101170:	83 ec 04             	sub    $0x4,%esp
  101173:	68 00 0f 00 00       	push   $0xf00
  101178:	52                   	push   %edx
  101179:	50                   	push   %eax
  10117a:	e8 46 1b 00 00       	call   102cc5 <memmove>
  10117f:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101182:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101189:	eb 15                	jmp    1011a0 <cga_putc+0x12e>
            crt_buf[i] = 0x0700 | ' ';
  10118b:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101190:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101193:	01 d2                	add    %edx,%edx
  101195:	01 d0                	add    %edx,%eax
  101197:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10119c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1011a0:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011a7:	7e e2                	jle    10118b <cga_putc+0x119>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  1011a9:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011b0:	83 e8 50             	sub    $0x50,%eax
  1011b3:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011b9:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  1011c0:	0f b7 c0             	movzwl %ax,%eax
  1011c3:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  1011c7:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
  1011cb:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
  1011cf:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1011d3:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  1011d4:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011db:	66 c1 e8 08          	shr    $0x8,%ax
  1011df:	0f b6 c0             	movzbl %al,%eax
  1011e2:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  1011e9:	83 c2 01             	add    $0x1,%edx
  1011ec:	0f b7 d2             	movzwl %dx,%edx
  1011ef:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
  1011f3:	88 45 e9             	mov    %al,-0x17(%ebp)
  1011f6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1011fa:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  1011fe:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  1011ff:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  101206:	0f b7 c0             	movzwl %ax,%eax
  101209:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  10120d:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
  101211:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  101215:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101219:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10121a:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101221:	0f b6 c0             	movzbl %al,%eax
  101224:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  10122b:	83 c2 01             	add    $0x1,%edx
  10122e:	0f b7 d2             	movzwl %dx,%edx
  101231:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
  101235:	88 45 eb             	mov    %al,-0x15(%ebp)
  101238:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  10123c:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
  101240:	ee                   	out    %al,(%dx)
}
  101241:	90                   	nop
  101242:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  101245:	c9                   	leave  
  101246:	c3                   	ret    

00101247 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101247:	55                   	push   %ebp
  101248:	89 e5                	mov    %esp,%ebp
  10124a:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10124d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101254:	eb 09                	jmp    10125f <serial_putc_sub+0x18>
        delay();
  101256:	e8 51 fb ff ff       	call   100dac <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10125b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10125f:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101265:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
  101269:	89 c2                	mov    %eax,%edx
  10126b:	ec                   	in     (%dx),%al
  10126c:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  10126f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  101273:	0f b6 c0             	movzbl %al,%eax
  101276:	83 e0 20             	and    $0x20,%eax
  101279:	85 c0                	test   %eax,%eax
  10127b:	75 09                	jne    101286 <serial_putc_sub+0x3f>
  10127d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101284:	7e d0                	jle    101256 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  101286:	8b 45 08             	mov    0x8(%ebp),%eax
  101289:	0f b6 c0             	movzbl %al,%eax
  10128c:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
  101292:	88 45 f6             	mov    %al,-0xa(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101295:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
  101299:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10129d:	ee                   	out    %al,(%dx)
}
  10129e:	90                   	nop
  10129f:	c9                   	leave  
  1012a0:	c3                   	ret    

001012a1 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012a1:	55                   	push   %ebp
  1012a2:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
  1012a4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012a8:	74 0d                	je     1012b7 <serial_putc+0x16>
        serial_putc_sub(c);
  1012aa:	ff 75 08             	pushl  0x8(%ebp)
  1012ad:	e8 95 ff ff ff       	call   101247 <serial_putc_sub>
  1012b2:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1012b5:	eb 1e                	jmp    1012d5 <serial_putc+0x34>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
  1012b7:	6a 08                	push   $0x8
  1012b9:	e8 89 ff ff ff       	call   101247 <serial_putc_sub>
  1012be:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
  1012c1:	6a 20                	push   $0x20
  1012c3:	e8 7f ff ff ff       	call   101247 <serial_putc_sub>
  1012c8:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
  1012cb:	6a 08                	push   $0x8
  1012cd:	e8 75 ff ff ff       	call   101247 <serial_putc_sub>
  1012d2:	83 c4 04             	add    $0x4,%esp
    }
}
  1012d5:	90                   	nop
  1012d6:	c9                   	leave  
  1012d7:	c3                   	ret    

001012d8 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1012d8:	55                   	push   %ebp
  1012d9:	89 e5                	mov    %esp,%ebp
  1012db:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1012de:	eb 33                	jmp    101313 <cons_intr+0x3b>
        if (c != 0) {
  1012e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1012e4:	74 2d                	je     101313 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1012e6:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1012eb:	8d 50 01             	lea    0x1(%eax),%edx
  1012ee:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  1012f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1012f7:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1012fd:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101302:	3d 00 02 00 00       	cmp    $0x200,%eax
  101307:	75 0a                	jne    101313 <cons_intr+0x3b>
                cons.wpos = 0;
  101309:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  101310:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  101313:	8b 45 08             	mov    0x8(%ebp),%eax
  101316:	ff d0                	call   *%eax
  101318:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10131b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  10131f:	75 bf                	jne    1012e0 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  101321:	90                   	nop
  101322:	c9                   	leave  
  101323:	c3                   	ret    

00101324 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101324:	55                   	push   %ebp
  101325:	89 e5                	mov    %esp,%ebp
  101327:	83 ec 10             	sub    $0x10,%esp
  10132a:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101330:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
  101334:	89 c2                	mov    %eax,%edx
  101336:	ec                   	in     (%dx),%al
  101337:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  10133a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  10133e:	0f b6 c0             	movzbl %al,%eax
  101341:	83 e0 01             	and    $0x1,%eax
  101344:	85 c0                	test   %eax,%eax
  101346:	75 07                	jne    10134f <serial_proc_data+0x2b>
        return -1;
  101348:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10134d:	eb 2a                	jmp    101379 <serial_proc_data+0x55>
  10134f:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101355:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101359:	89 c2                	mov    %eax,%edx
  10135b:	ec                   	in     (%dx),%al
  10135c:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
  10135f:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101363:	0f b6 c0             	movzbl %al,%eax
  101366:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101369:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10136d:	75 07                	jne    101376 <serial_proc_data+0x52>
        c = '\b';
  10136f:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101376:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101379:	c9                   	leave  
  10137a:	c3                   	ret    

0010137b <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10137b:	55                   	push   %ebp
  10137c:	89 e5                	mov    %esp,%ebp
  10137e:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
  101381:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  101386:	85 c0                	test   %eax,%eax
  101388:	74 10                	je     10139a <serial_intr+0x1f>
        cons_intr(serial_proc_data);
  10138a:	83 ec 0c             	sub    $0xc,%esp
  10138d:	68 24 13 10 00       	push   $0x101324
  101392:	e8 41 ff ff ff       	call   1012d8 <cons_intr>
  101397:	83 c4 10             	add    $0x10,%esp
    }
}
  10139a:	90                   	nop
  10139b:	c9                   	leave  
  10139c:	c3                   	ret    

0010139d <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  10139d:	55                   	push   %ebp
  10139e:	89 e5                	mov    %esp,%ebp
  1013a0:	83 ec 18             	sub    $0x18,%esp
  1013a3:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013a9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1013ad:	89 c2                	mov    %eax,%edx
  1013af:	ec                   	in     (%dx),%al
  1013b0:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1013b3:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013b7:	0f b6 c0             	movzbl %al,%eax
  1013ba:	83 e0 01             	and    $0x1,%eax
  1013bd:	85 c0                	test   %eax,%eax
  1013bf:	75 0a                	jne    1013cb <kbd_proc_data+0x2e>
        return -1;
  1013c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013c6:	e9 5d 01 00 00       	jmp    101528 <kbd_proc_data+0x18b>
  1013cb:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013d1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1013d5:	89 c2                	mov    %eax,%edx
  1013d7:	ec                   	in     (%dx),%al
  1013d8:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
  1013db:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
  1013df:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1013e2:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1013e6:	75 17                	jne    1013ff <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  1013e8:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1013ed:	83 c8 40             	or     $0x40,%eax
  1013f0:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  1013f5:	b8 00 00 00 00       	mov    $0x0,%eax
  1013fa:	e9 29 01 00 00       	jmp    101528 <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
  1013ff:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101403:	84 c0                	test   %al,%al
  101405:	79 47                	jns    10144e <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101407:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10140c:	83 e0 40             	and    $0x40,%eax
  10140f:	85 c0                	test   %eax,%eax
  101411:	75 09                	jne    10141c <kbd_proc_data+0x7f>
  101413:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101417:	83 e0 7f             	and    $0x7f,%eax
  10141a:	eb 04                	jmp    101420 <kbd_proc_data+0x83>
  10141c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101420:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101423:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101427:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  10142e:	83 c8 40             	or     $0x40,%eax
  101431:	0f b6 c0             	movzbl %al,%eax
  101434:	f7 d0                	not    %eax
  101436:	89 c2                	mov    %eax,%edx
  101438:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10143d:	21 d0                	and    %edx,%eax
  10143f:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101444:	b8 00 00 00 00       	mov    $0x0,%eax
  101449:	e9 da 00 00 00       	jmp    101528 <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
  10144e:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101453:	83 e0 40             	and    $0x40,%eax
  101456:	85 c0                	test   %eax,%eax
  101458:	74 11                	je     10146b <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10145a:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10145e:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101463:	83 e0 bf             	and    $0xffffffbf,%eax
  101466:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  10146b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10146f:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  101476:	0f b6 d0             	movzbl %al,%edx
  101479:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10147e:	09 d0                	or     %edx,%eax
  101480:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  101485:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101489:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  101490:	0f b6 d0             	movzbl %al,%edx
  101493:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101498:	31 d0                	xor    %edx,%eax
  10149a:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  10149f:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014a4:	83 e0 03             	and    $0x3,%eax
  1014a7:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014ae:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b2:	01 d0                	add    %edx,%eax
  1014b4:	0f b6 00             	movzbl (%eax),%eax
  1014b7:	0f b6 c0             	movzbl %al,%eax
  1014ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014bd:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014c2:	83 e0 08             	and    $0x8,%eax
  1014c5:	85 c0                	test   %eax,%eax
  1014c7:	74 22                	je     1014eb <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  1014c9:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1014cd:	7e 0c                	jle    1014db <kbd_proc_data+0x13e>
  1014cf:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1014d3:	7f 06                	jg     1014db <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  1014d5:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1014d9:	eb 10                	jmp    1014eb <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  1014db:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1014df:	7e 0a                	jle    1014eb <kbd_proc_data+0x14e>
  1014e1:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1014e5:	7f 04                	jg     1014eb <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  1014e7:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1014eb:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014f0:	f7 d0                	not    %eax
  1014f2:	83 e0 06             	and    $0x6,%eax
  1014f5:	85 c0                	test   %eax,%eax
  1014f7:	75 2c                	jne    101525 <kbd_proc_data+0x188>
  1014f9:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101500:	75 23                	jne    101525 <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
  101502:	83 ec 0c             	sub    $0xc,%esp
  101505:	68 69 37 10 00       	push   $0x103769
  10150a:	e8 2e ed ff ff       	call   10023d <cprintf>
  10150f:	83 c4 10             	add    $0x10,%esp
  101512:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
  101518:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10151c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101520:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101524:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101525:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101528:	c9                   	leave  
  101529:	c3                   	ret    

0010152a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10152a:	55                   	push   %ebp
  10152b:	89 e5                	mov    %esp,%ebp
  10152d:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
  101530:	83 ec 0c             	sub    $0xc,%esp
  101533:	68 9d 13 10 00       	push   $0x10139d
  101538:	e8 9b fd ff ff       	call   1012d8 <cons_intr>
  10153d:	83 c4 10             	add    $0x10,%esp
}
  101540:	90                   	nop
  101541:	c9                   	leave  
  101542:	c3                   	ret    

00101543 <kbd_init>:

static void
kbd_init(void) {
  101543:	55                   	push   %ebp
  101544:	89 e5                	mov    %esp,%ebp
  101546:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
  101549:	e8 dc ff ff ff       	call   10152a <kbd_intr>
    pic_enable(IRQ_KBD);
  10154e:	83 ec 0c             	sub    $0xc,%esp
  101551:	6a 01                	push   $0x1
  101553:	e8 1c 01 00 00       	call   101674 <pic_enable>
  101558:	83 c4 10             	add    $0x10,%esp
}
  10155b:	90                   	nop
  10155c:	c9                   	leave  
  10155d:	c3                   	ret    

0010155e <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10155e:	55                   	push   %ebp
  10155f:	89 e5                	mov    %esp,%ebp
  101561:	83 ec 08             	sub    $0x8,%esp
    cga_init();
  101564:	e8 8c f8 ff ff       	call   100df5 <cga_init>
    serial_init();
  101569:	e8 6e f9 ff ff       	call   100edc <serial_init>
    kbd_init();
  10156e:	e8 d0 ff ff ff       	call   101543 <kbd_init>
    if (!serial_exists) {
  101573:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  101578:	85 c0                	test   %eax,%eax
  10157a:	75 10                	jne    10158c <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
  10157c:	83 ec 0c             	sub    $0xc,%esp
  10157f:	68 75 37 10 00       	push   $0x103775
  101584:	e8 b4 ec ff ff       	call   10023d <cprintf>
  101589:	83 c4 10             	add    $0x10,%esp
    }
}
  10158c:	90                   	nop
  10158d:	c9                   	leave  
  10158e:	c3                   	ret    

0010158f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10158f:	55                   	push   %ebp
  101590:	89 e5                	mov    %esp,%ebp
  101592:	83 ec 08             	sub    $0x8,%esp
    lpt_putc(c);
  101595:	ff 75 08             	pushl  0x8(%ebp)
  101598:	e8 9e fa ff ff       	call   10103b <lpt_putc>
  10159d:	83 c4 04             	add    $0x4,%esp
    cga_putc(c);
  1015a0:	83 ec 0c             	sub    $0xc,%esp
  1015a3:	ff 75 08             	pushl  0x8(%ebp)
  1015a6:	e8 c7 fa ff ff       	call   101072 <cga_putc>
  1015ab:	83 c4 10             	add    $0x10,%esp
    serial_putc(c);
  1015ae:	83 ec 0c             	sub    $0xc,%esp
  1015b1:	ff 75 08             	pushl  0x8(%ebp)
  1015b4:	e8 e8 fc ff ff       	call   1012a1 <serial_putc>
  1015b9:	83 c4 10             	add    $0x10,%esp
}
  1015bc:	90                   	nop
  1015bd:	c9                   	leave  
  1015be:	c3                   	ret    

001015bf <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015bf:	55                   	push   %ebp
  1015c0:	89 e5                	mov    %esp,%ebp
  1015c2:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015c5:	e8 b1 fd ff ff       	call   10137b <serial_intr>
    kbd_intr();
  1015ca:	e8 5b ff ff ff       	call   10152a <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015cf:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  1015d5:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1015da:	39 c2                	cmp    %eax,%edx
  1015dc:	74 36                	je     101614 <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  1015de:	a1 80 f0 10 00       	mov    0x10f080,%eax
  1015e3:	8d 50 01             	lea    0x1(%eax),%edx
  1015e6:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  1015ec:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  1015f3:	0f b6 c0             	movzbl %al,%eax
  1015f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  1015f9:	a1 80 f0 10 00       	mov    0x10f080,%eax
  1015fe:	3d 00 02 00 00       	cmp    $0x200,%eax
  101603:	75 0a                	jne    10160f <cons_getc+0x50>
            cons.rpos = 0;
  101605:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  10160c:	00 00 00 
        }
        return c;
  10160f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101612:	eb 05                	jmp    101619 <cons_getc+0x5a>
    }
    return 0;
  101614:	b8 00 00 00 00       	mov    $0x0,%eax
}
  101619:	c9                   	leave  
  10161a:	c3                   	ret    

0010161b <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  10161b:	55                   	push   %ebp
  10161c:	89 e5                	mov    %esp,%ebp
  10161e:	83 ec 14             	sub    $0x14,%esp
  101621:	8b 45 08             	mov    0x8(%ebp),%eax
  101624:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101628:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10162c:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  101632:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  101637:	85 c0                	test   %eax,%eax
  101639:	74 36                	je     101671 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  10163b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10163f:	0f b6 c0             	movzbl %al,%eax
  101642:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101648:	88 45 fa             	mov    %al,-0x6(%ebp)
  10164b:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
  10164f:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101653:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101654:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101658:	66 c1 e8 08          	shr    $0x8,%ax
  10165c:	0f b6 c0             	movzbl %al,%eax
  10165f:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  101665:	88 45 fb             	mov    %al,-0x5(%ebp)
  101668:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  10166c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
  101670:	ee                   	out    %al,(%dx)
    }
}
  101671:	90                   	nop
  101672:	c9                   	leave  
  101673:	c3                   	ret    

00101674 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101674:	55                   	push   %ebp
  101675:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
  101677:	8b 45 08             	mov    0x8(%ebp),%eax
  10167a:	ba 01 00 00 00       	mov    $0x1,%edx
  10167f:	89 c1                	mov    %eax,%ecx
  101681:	d3 e2                	shl    %cl,%edx
  101683:	89 d0                	mov    %edx,%eax
  101685:	f7 d0                	not    %eax
  101687:	89 c2                	mov    %eax,%edx
  101689:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  101690:	21 d0                	and    %edx,%eax
  101692:	0f b7 c0             	movzwl %ax,%eax
  101695:	50                   	push   %eax
  101696:	e8 80 ff ff ff       	call   10161b <pic_setmask>
  10169b:	83 c4 04             	add    $0x4,%esp
}
  10169e:	90                   	nop
  10169f:	c9                   	leave  
  1016a0:	c3                   	ret    

001016a1 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016a1:	55                   	push   %ebp
  1016a2:	89 e5                	mov    %esp,%ebp
  1016a4:	83 ec 30             	sub    $0x30,%esp
    did_init = 1;
  1016a7:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  1016ae:	00 00 00 
  1016b1:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016b7:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
  1016bb:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
  1016bf:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016c3:	ee                   	out    %al,(%dx)
  1016c4:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  1016ca:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
  1016ce:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
  1016d2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
  1016d6:	ee                   	out    %al,(%dx)
  1016d7:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
  1016dd:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
  1016e1:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
  1016e5:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016e9:	ee                   	out    %al,(%dx)
  1016ea:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
  1016f0:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
  1016f4:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1016f8:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
  1016fc:	ee                   	out    %al,(%dx)
  1016fd:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
  101703:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
  101707:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  10170b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10170f:	ee                   	out    %al,(%dx)
  101710:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
  101716:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
  10171a:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  10171e:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
  101722:	ee                   	out    %al,(%dx)
  101723:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
  101729:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
  10172d:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  101731:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101735:	ee                   	out    %al,(%dx)
  101736:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
  10173c:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
  101740:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101744:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  101748:	ee                   	out    %al,(%dx)
  101749:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10174f:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
  101753:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  101757:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10175b:	ee                   	out    %al,(%dx)
  10175c:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
  101762:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
  101766:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  10176a:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
  10176e:	ee                   	out    %al,(%dx)
  10176f:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
  101775:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
  101779:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  10177d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101781:	ee                   	out    %al,(%dx)
  101782:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
  101788:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
  10178c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101790:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  101794:	ee                   	out    %al,(%dx)
  101795:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  10179b:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
  10179f:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
  1017a3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017a7:	ee                   	out    %al,(%dx)
  1017a8:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
  1017ae:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
  1017b2:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1017b6:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
  1017ba:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017bb:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017c2:	66 83 f8 ff          	cmp    $0xffff,%ax
  1017c6:	74 13                	je     1017db <pic_init+0x13a>
        pic_setmask(irq_mask);
  1017c8:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017cf:	0f b7 c0             	movzwl %ax,%eax
  1017d2:	50                   	push   %eax
  1017d3:	e8 43 fe ff ff       	call   10161b <pic_setmask>
  1017d8:	83 c4 04             	add    $0x4,%esp
    }
}
  1017db:	90                   	nop
  1017dc:	c9                   	leave  
  1017dd:	c3                   	ret    

001017de <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1017de:	55                   	push   %ebp
  1017df:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  1017e1:	fb                   	sti    
    sti();
}
  1017e2:	90                   	nop
  1017e3:	5d                   	pop    %ebp
  1017e4:	c3                   	ret    

001017e5 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1017e5:	55                   	push   %ebp
  1017e6:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  1017e8:	fa                   	cli    
    cli();
}
  1017e9:	90                   	nop
  1017ea:	5d                   	pop    %ebp
  1017eb:	c3                   	ret    

001017ec <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1017ec:	55                   	push   %ebp
  1017ed:	89 e5                	mov    %esp,%ebp
  1017ef:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1017f2:	83 ec 08             	sub    $0x8,%esp
  1017f5:	6a 64                	push   $0x64
  1017f7:	68 a0 37 10 00       	push   $0x1037a0
  1017fc:	e8 3c ea ff ff       	call   10023d <cprintf>
  101801:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101804:	90                   	nop
  101805:	c9                   	leave  
  101806:	c3                   	ret    

00101807 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101807:	55                   	push   %ebp
  101808:	89 e5                	mov    %esp,%ebp
  10180a:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) {
  10180d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101814:	e9 c3 00 00 00       	jmp    1018dc <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  101819:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10181c:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101823:	89 c2                	mov    %eax,%edx
  101825:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101828:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  10182f:	00 
  101830:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101833:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  10183a:	00 08 00 
  10183d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101840:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  101847:	00 
  101848:	83 e2 e0             	and    $0xffffffe0,%edx
  10184b:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101852:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101855:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  10185c:	00 
  10185d:	83 e2 1f             	and    $0x1f,%edx
  101860:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101867:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10186a:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101871:	00 
  101872:	83 e2 f0             	and    $0xfffffff0,%edx
  101875:	83 ca 0e             	or     $0xe,%edx
  101878:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  10187f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101882:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101889:	00 
  10188a:	83 e2 ef             	and    $0xffffffef,%edx
  10188d:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  101894:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101897:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  10189e:	00 
  10189f:	83 e2 9f             	and    $0xffffff9f,%edx
  1018a2:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ac:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018b3:	00 
  1018b4:	83 ca 80             	or     $0xffffff80,%edx
  1018b7:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018be:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c1:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  1018c8:	c1 e8 10             	shr    $0x10,%eax
  1018cb:	89 c2                	mov    %eax,%edx
  1018cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d0:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  1018d7:	00 
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) {
  1018d8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1018dc:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  1018e3:	0f 8e 30 ff ff ff    	jle    101819 <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  1018e9:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  1018ee:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  1018f4:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  1018fb:	08 00 
  1018fd:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101904:	83 e0 e0             	and    $0xffffffe0,%eax
  101907:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10190c:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101913:	83 e0 1f             	and    $0x1f,%eax
  101916:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10191b:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101922:	83 e0 f0             	and    $0xfffffff0,%eax
  101925:	83 c8 0e             	or     $0xe,%eax
  101928:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10192d:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101934:	83 e0 ef             	and    $0xffffffef,%eax
  101937:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10193c:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101943:	83 c8 60             	or     $0x60,%eax
  101946:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10194b:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101952:	83 c8 80             	or     $0xffffff80,%eax
  101955:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10195a:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  10195f:	c1 e8 10             	shr    $0x10,%eax
  101962:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
  101968:	c7 45 f8 60 e5 10 00 	movl   $0x10e560,-0x8(%ebp)
    return ebp;
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
  10196f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101972:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
  101975:	90                   	nop
  101976:	c9                   	leave  
  101977:	c3                   	ret    

00101978 <trapname>:

static const char *
trapname(int trapno) {
  101978:	55                   	push   %ebp
  101979:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  10197b:	8b 45 08             	mov    0x8(%ebp),%eax
  10197e:	83 f8 13             	cmp    $0x13,%eax
  101981:	77 0c                	ja     10198f <trapname+0x17>
        return excnames[trapno];
  101983:	8b 45 08             	mov    0x8(%ebp),%eax
  101986:	8b 04 85 00 3b 10 00 	mov    0x103b00(,%eax,4),%eax
  10198d:	eb 18                	jmp    1019a7 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  10198f:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101993:	7e 0d                	jle    1019a2 <trapname+0x2a>
  101995:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101999:	7f 07                	jg     1019a2 <trapname+0x2a>
        return "Hardware Interrupt";
  10199b:	b8 aa 37 10 00       	mov    $0x1037aa,%eax
  1019a0:	eb 05                	jmp    1019a7 <trapname+0x2f>
    }
    return "(unknown trap)";
  1019a2:	b8 bd 37 10 00       	mov    $0x1037bd,%eax
}
  1019a7:	5d                   	pop    %ebp
  1019a8:	c3                   	ret    

001019a9 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019a9:	55                   	push   %ebp
  1019aa:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1019af:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019b3:	66 83 f8 08          	cmp    $0x8,%ax
  1019b7:	0f 94 c0             	sete   %al
  1019ba:	0f b6 c0             	movzbl %al,%eax
}
  1019bd:	5d                   	pop    %ebp
  1019be:	c3                   	ret    

001019bf <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019bf:	55                   	push   %ebp
  1019c0:	89 e5                	mov    %esp,%ebp
  1019c2:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
  1019c5:	83 ec 08             	sub    $0x8,%esp
  1019c8:	ff 75 08             	pushl  0x8(%ebp)
  1019cb:	68 fe 37 10 00       	push   $0x1037fe
  1019d0:	e8 68 e8 ff ff       	call   10023d <cprintf>
  1019d5:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
  1019d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1019db:	83 ec 0c             	sub    $0xc,%esp
  1019de:	50                   	push   %eax
  1019df:	e8 b8 01 00 00       	call   101b9c <print_regs>
  1019e4:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  1019e7:	8b 45 08             	mov    0x8(%ebp),%eax
  1019ea:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  1019ee:	0f b7 c0             	movzwl %ax,%eax
  1019f1:	83 ec 08             	sub    $0x8,%esp
  1019f4:	50                   	push   %eax
  1019f5:	68 0f 38 10 00       	push   $0x10380f
  1019fa:	e8 3e e8 ff ff       	call   10023d <cprintf>
  1019ff:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a02:	8b 45 08             	mov    0x8(%ebp),%eax
  101a05:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a09:	0f b7 c0             	movzwl %ax,%eax
  101a0c:	83 ec 08             	sub    $0x8,%esp
  101a0f:	50                   	push   %eax
  101a10:	68 22 38 10 00       	push   $0x103822
  101a15:	e8 23 e8 ff ff       	call   10023d <cprintf>
  101a1a:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a20:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a24:	0f b7 c0             	movzwl %ax,%eax
  101a27:	83 ec 08             	sub    $0x8,%esp
  101a2a:	50                   	push   %eax
  101a2b:	68 35 38 10 00       	push   $0x103835
  101a30:	e8 08 e8 ff ff       	call   10023d <cprintf>
  101a35:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a38:	8b 45 08             	mov    0x8(%ebp),%eax
  101a3b:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a3f:	0f b7 c0             	movzwl %ax,%eax
  101a42:	83 ec 08             	sub    $0x8,%esp
  101a45:	50                   	push   %eax
  101a46:	68 48 38 10 00       	push   $0x103848
  101a4b:	e8 ed e7 ff ff       	call   10023d <cprintf>
  101a50:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a53:	8b 45 08             	mov    0x8(%ebp),%eax
  101a56:	8b 40 30             	mov    0x30(%eax),%eax
  101a59:	83 ec 0c             	sub    $0xc,%esp
  101a5c:	50                   	push   %eax
  101a5d:	e8 16 ff ff ff       	call   101978 <trapname>
  101a62:	83 c4 10             	add    $0x10,%esp
  101a65:	89 c2                	mov    %eax,%edx
  101a67:	8b 45 08             	mov    0x8(%ebp),%eax
  101a6a:	8b 40 30             	mov    0x30(%eax),%eax
  101a6d:	83 ec 04             	sub    $0x4,%esp
  101a70:	52                   	push   %edx
  101a71:	50                   	push   %eax
  101a72:	68 5b 38 10 00       	push   $0x10385b
  101a77:	e8 c1 e7 ff ff       	call   10023d <cprintf>
  101a7c:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
  101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a82:	8b 40 34             	mov    0x34(%eax),%eax
  101a85:	83 ec 08             	sub    $0x8,%esp
  101a88:	50                   	push   %eax
  101a89:	68 6d 38 10 00       	push   $0x10386d
  101a8e:	e8 aa e7 ff ff       	call   10023d <cprintf>
  101a93:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101a96:	8b 45 08             	mov    0x8(%ebp),%eax
  101a99:	8b 40 38             	mov    0x38(%eax),%eax
  101a9c:	83 ec 08             	sub    $0x8,%esp
  101a9f:	50                   	push   %eax
  101aa0:	68 7c 38 10 00       	push   $0x10387c
  101aa5:	e8 93 e7 ff ff       	call   10023d <cprintf>
  101aaa:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101aad:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ab4:	0f b7 c0             	movzwl %ax,%eax
  101ab7:	83 ec 08             	sub    $0x8,%esp
  101aba:	50                   	push   %eax
  101abb:	68 8b 38 10 00       	push   $0x10388b
  101ac0:	e8 78 e7 ff ff       	call   10023d <cprintf>
  101ac5:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  101acb:	8b 40 40             	mov    0x40(%eax),%eax
  101ace:	83 ec 08             	sub    $0x8,%esp
  101ad1:	50                   	push   %eax
  101ad2:	68 9e 38 10 00       	push   $0x10389e
  101ad7:	e8 61 e7 ff ff       	call   10023d <cprintf>
  101adc:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101adf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101ae6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101aed:	eb 3f                	jmp    101b2e <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101aef:	8b 45 08             	mov    0x8(%ebp),%eax
  101af2:	8b 50 40             	mov    0x40(%eax),%edx
  101af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101af8:	21 d0                	and    %edx,%eax
  101afa:	85 c0                	test   %eax,%eax
  101afc:	74 29                	je     101b27 <print_trapframe+0x168>
  101afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b01:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b08:	85 c0                	test   %eax,%eax
  101b0a:	74 1b                	je     101b27 <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
  101b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b0f:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b16:	83 ec 08             	sub    $0x8,%esp
  101b19:	50                   	push   %eax
  101b1a:	68 ad 38 10 00       	push   $0x1038ad
  101b1f:	e8 19 e7 ff ff       	call   10023d <cprintf>
  101b24:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b27:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101b2b:	d1 65 f0             	shll   -0x10(%ebp)
  101b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b31:	83 f8 17             	cmp    $0x17,%eax
  101b34:	76 b9                	jbe    101aef <print_trapframe+0x130>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b36:	8b 45 08             	mov    0x8(%ebp),%eax
  101b39:	8b 40 40             	mov    0x40(%eax),%eax
  101b3c:	25 00 30 00 00       	and    $0x3000,%eax
  101b41:	c1 e8 0c             	shr    $0xc,%eax
  101b44:	83 ec 08             	sub    $0x8,%esp
  101b47:	50                   	push   %eax
  101b48:	68 b1 38 10 00       	push   $0x1038b1
  101b4d:	e8 eb e6 ff ff       	call   10023d <cprintf>
  101b52:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
  101b55:	83 ec 0c             	sub    $0xc,%esp
  101b58:	ff 75 08             	pushl  0x8(%ebp)
  101b5b:	e8 49 fe ff ff       	call   1019a9 <trap_in_kernel>
  101b60:	83 c4 10             	add    $0x10,%esp
  101b63:	85 c0                	test   %eax,%eax
  101b65:	75 32                	jne    101b99 <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b67:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6a:	8b 40 44             	mov    0x44(%eax),%eax
  101b6d:	83 ec 08             	sub    $0x8,%esp
  101b70:	50                   	push   %eax
  101b71:	68 ba 38 10 00       	push   $0x1038ba
  101b76:	e8 c2 e6 ff ff       	call   10023d <cprintf>
  101b7b:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b81:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101b85:	0f b7 c0             	movzwl %ax,%eax
  101b88:	83 ec 08             	sub    $0x8,%esp
  101b8b:	50                   	push   %eax
  101b8c:	68 c9 38 10 00       	push   $0x1038c9
  101b91:	e8 a7 e6 ff ff       	call   10023d <cprintf>
  101b96:	83 c4 10             	add    $0x10,%esp
    }
}
  101b99:	90                   	nop
  101b9a:	c9                   	leave  
  101b9b:	c3                   	ret    

00101b9c <print_regs>:

void
print_regs(struct pushregs *regs) {
  101b9c:	55                   	push   %ebp
  101b9d:	89 e5                	mov    %esp,%ebp
  101b9f:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba5:	8b 00                	mov    (%eax),%eax
  101ba7:	83 ec 08             	sub    $0x8,%esp
  101baa:	50                   	push   %eax
  101bab:	68 dc 38 10 00       	push   $0x1038dc
  101bb0:	e8 88 e6 ff ff       	call   10023d <cprintf>
  101bb5:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bbb:	8b 40 04             	mov    0x4(%eax),%eax
  101bbe:	83 ec 08             	sub    $0x8,%esp
  101bc1:	50                   	push   %eax
  101bc2:	68 eb 38 10 00       	push   $0x1038eb
  101bc7:	e8 71 e6 ff ff       	call   10023d <cprintf>
  101bcc:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd2:	8b 40 08             	mov    0x8(%eax),%eax
  101bd5:	83 ec 08             	sub    $0x8,%esp
  101bd8:	50                   	push   %eax
  101bd9:	68 fa 38 10 00       	push   $0x1038fa
  101bde:	e8 5a e6 ff ff       	call   10023d <cprintf>
  101be3:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101be6:	8b 45 08             	mov    0x8(%ebp),%eax
  101be9:	8b 40 0c             	mov    0xc(%eax),%eax
  101bec:	83 ec 08             	sub    $0x8,%esp
  101bef:	50                   	push   %eax
  101bf0:	68 09 39 10 00       	push   $0x103909
  101bf5:	e8 43 e6 ff ff       	call   10023d <cprintf>
  101bfa:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  101c00:	8b 40 10             	mov    0x10(%eax),%eax
  101c03:	83 ec 08             	sub    $0x8,%esp
  101c06:	50                   	push   %eax
  101c07:	68 18 39 10 00       	push   $0x103918
  101c0c:	e8 2c e6 ff ff       	call   10023d <cprintf>
  101c11:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c14:	8b 45 08             	mov    0x8(%ebp),%eax
  101c17:	8b 40 14             	mov    0x14(%eax),%eax
  101c1a:	83 ec 08             	sub    $0x8,%esp
  101c1d:	50                   	push   %eax
  101c1e:	68 27 39 10 00       	push   $0x103927
  101c23:	e8 15 e6 ff ff       	call   10023d <cprintf>
  101c28:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2e:	8b 40 18             	mov    0x18(%eax),%eax
  101c31:	83 ec 08             	sub    $0x8,%esp
  101c34:	50                   	push   %eax
  101c35:	68 36 39 10 00       	push   $0x103936
  101c3a:	e8 fe e5 ff ff       	call   10023d <cprintf>
  101c3f:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c42:	8b 45 08             	mov    0x8(%ebp),%eax
  101c45:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c48:	83 ec 08             	sub    $0x8,%esp
  101c4b:	50                   	push   %eax
  101c4c:	68 45 39 10 00       	push   $0x103945
  101c51:	e8 e7 e5 ff ff       	call   10023d <cprintf>
  101c56:	83 c4 10             	add    $0x10,%esp
}
  101c59:	90                   	nop
  101c5a:	c9                   	leave  
  101c5b:	c3                   	ret    

00101c5c <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c5c:	55                   	push   %ebp
  101c5d:	89 e5                	mov    %esp,%ebp
  101c5f:	83 ec 18             	sub    $0x18,%esp
    char c;

    switch (tf->tf_trapno) {
  101c62:	8b 45 08             	mov    0x8(%ebp),%eax
  101c65:	8b 40 30             	mov    0x30(%eax),%eax
  101c68:	83 f8 2f             	cmp    $0x2f,%eax
  101c6b:	77 1d                	ja     101c8a <trap_dispatch+0x2e>
  101c6d:	83 f8 2e             	cmp    $0x2e,%eax
  101c70:	0f 83 e9 00 00 00    	jae    101d5f <trap_dispatch+0x103>
  101c76:	83 f8 21             	cmp    $0x21,%eax
  101c79:	74 73                	je     101cee <trap_dispatch+0x92>
  101c7b:	83 f8 24             	cmp    $0x24,%eax
  101c7e:	74 4a                	je     101cca <trap_dispatch+0x6e>
  101c80:	83 f8 20             	cmp    $0x20,%eax
  101c83:	74 13                	je     101c98 <trap_dispatch+0x3c>
  101c85:	e9 9f 00 00 00       	jmp    101d29 <trap_dispatch+0xcd>
  101c8a:	83 e8 78             	sub    $0x78,%eax
  101c8d:	83 f8 01             	cmp    $0x1,%eax
  101c90:	0f 87 93 00 00 00    	ja     101d29 <trap_dispatch+0xcd>
  101c96:	eb 7a                	jmp    101d12 <trap_dispatch+0xb6>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
  101c98:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101c9d:	83 c0 01             	add    $0x1,%eax
  101ca0:	a3 08 f9 10 00       	mov    %eax,0x10f908
        if (ticks == TICK_NUM) {
  101ca5:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101caa:	83 f8 64             	cmp    $0x64,%eax
  101cad:	0f 85 af 00 00 00    	jne    101d62 <trap_dispatch+0x106>
            ticks -= TICK_NUM;
  101cb3:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101cb8:	83 e8 64             	sub    $0x64,%eax
  101cbb:	a3 08 f9 10 00       	mov    %eax,0x10f908
            print_ticks();
  101cc0:	e8 27 fb ff ff       	call   1017ec <print_ticks>
        }
        break;
  101cc5:	e9 98 00 00 00       	jmp    101d62 <trap_dispatch+0x106>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cca:	e8 f0 f8 ff ff       	call   1015bf <cons_getc>
  101ccf:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101cd2:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101cd6:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101cda:	83 ec 04             	sub    $0x4,%esp
  101cdd:	52                   	push   %edx
  101cde:	50                   	push   %eax
  101cdf:	68 54 39 10 00       	push   $0x103954
  101ce4:	e8 54 e5 ff ff       	call   10023d <cprintf>
  101ce9:	83 c4 10             	add    $0x10,%esp
        break;
  101cec:	eb 75                	jmp    101d63 <trap_dispatch+0x107>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101cee:	e8 cc f8 ff ff       	call   1015bf <cons_getc>
  101cf3:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101cf6:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101cfa:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101cfe:	83 ec 04             	sub    $0x4,%esp
  101d01:	52                   	push   %edx
  101d02:	50                   	push   %eax
  101d03:	68 66 39 10 00       	push   $0x103966
  101d08:	e8 30 e5 ff ff       	call   10023d <cprintf>
  101d0d:	83 c4 10             	add    $0x10,%esp
        break;
  101d10:	eb 51                	jmp    101d63 <trap_dispatch+0x107>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d12:	83 ec 04             	sub    $0x4,%esp
  101d15:	68 75 39 10 00       	push   $0x103975
  101d1a:	68 ad 00 00 00       	push   $0xad
  101d1f:	68 85 39 10 00       	push   $0x103985
  101d24:	e8 7a e6 ff ff       	call   1003a3 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d29:	8b 45 08             	mov    0x8(%ebp),%eax
  101d2c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d30:	0f b7 c0             	movzwl %ax,%eax
  101d33:	83 e0 03             	and    $0x3,%eax
  101d36:	85 c0                	test   %eax,%eax
  101d38:	75 29                	jne    101d63 <trap_dispatch+0x107>
            print_trapframe(tf);
  101d3a:	83 ec 0c             	sub    $0xc,%esp
  101d3d:	ff 75 08             	pushl  0x8(%ebp)
  101d40:	e8 7a fc ff ff       	call   1019bf <print_trapframe>
  101d45:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
  101d48:	83 ec 04             	sub    $0x4,%esp
  101d4b:	68 96 39 10 00       	push   $0x103996
  101d50:	68 b7 00 00 00       	push   $0xb7
  101d55:	68 85 39 10 00       	push   $0x103985
  101d5a:	e8 44 e6 ff ff       	call   1003a3 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101d5f:	90                   	nop
  101d60:	eb 01                	jmp    101d63 <trap_dispatch+0x107>
        ticks++;
        if (ticks == TICK_NUM) {
            ticks -= TICK_NUM;
            print_ticks();
        }
        break;
  101d62:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101d63:	90                   	nop
  101d64:	c9                   	leave  
  101d65:	c3                   	ret    

00101d66 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101d66:	55                   	push   %ebp
  101d67:	89 e5                	mov    %esp,%ebp
  101d69:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101d6c:	83 ec 0c             	sub    $0xc,%esp
  101d6f:	ff 75 08             	pushl  0x8(%ebp)
  101d72:	e8 e5 fe ff ff       	call   101c5c <trap_dispatch>
  101d77:	83 c4 10             	add    $0x10,%esp
}
  101d7a:	90                   	nop
  101d7b:	c9                   	leave  
  101d7c:	c3                   	ret    

00101d7d <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101d7d:	6a 00                	push   $0x0
  pushl $0
  101d7f:	6a 00                	push   $0x0
  jmp __alltraps
  101d81:	e9 69 0a 00 00       	jmp    1027ef <__alltraps>

00101d86 <vector1>:
.globl vector1
vector1:
  pushl $0
  101d86:	6a 00                	push   $0x0
  pushl $1
  101d88:	6a 01                	push   $0x1
  jmp __alltraps
  101d8a:	e9 60 0a 00 00       	jmp    1027ef <__alltraps>

00101d8f <vector2>:
.globl vector2
vector2:
  pushl $0
  101d8f:	6a 00                	push   $0x0
  pushl $2
  101d91:	6a 02                	push   $0x2
  jmp __alltraps
  101d93:	e9 57 0a 00 00       	jmp    1027ef <__alltraps>

00101d98 <vector3>:
.globl vector3
vector3:
  pushl $0
  101d98:	6a 00                	push   $0x0
  pushl $3
  101d9a:	6a 03                	push   $0x3
  jmp __alltraps
  101d9c:	e9 4e 0a 00 00       	jmp    1027ef <__alltraps>

00101da1 <vector4>:
.globl vector4
vector4:
  pushl $0
  101da1:	6a 00                	push   $0x0
  pushl $4
  101da3:	6a 04                	push   $0x4
  jmp __alltraps
  101da5:	e9 45 0a 00 00       	jmp    1027ef <__alltraps>

00101daa <vector5>:
.globl vector5
vector5:
  pushl $0
  101daa:	6a 00                	push   $0x0
  pushl $5
  101dac:	6a 05                	push   $0x5
  jmp __alltraps
  101dae:	e9 3c 0a 00 00       	jmp    1027ef <__alltraps>

00101db3 <vector6>:
.globl vector6
vector6:
  pushl $0
  101db3:	6a 00                	push   $0x0
  pushl $6
  101db5:	6a 06                	push   $0x6
  jmp __alltraps
  101db7:	e9 33 0a 00 00       	jmp    1027ef <__alltraps>

00101dbc <vector7>:
.globl vector7
vector7:
  pushl $0
  101dbc:	6a 00                	push   $0x0
  pushl $7
  101dbe:	6a 07                	push   $0x7
  jmp __alltraps
  101dc0:	e9 2a 0a 00 00       	jmp    1027ef <__alltraps>

00101dc5 <vector8>:
.globl vector8
vector8:
  pushl $8
  101dc5:	6a 08                	push   $0x8
  jmp __alltraps
  101dc7:	e9 23 0a 00 00       	jmp    1027ef <__alltraps>

00101dcc <vector9>:
.globl vector9
vector9:
  pushl $0
  101dcc:	6a 00                	push   $0x0
  pushl $9
  101dce:	6a 09                	push   $0x9
  jmp __alltraps
  101dd0:	e9 1a 0a 00 00       	jmp    1027ef <__alltraps>

00101dd5 <vector10>:
.globl vector10
vector10:
  pushl $10
  101dd5:	6a 0a                	push   $0xa
  jmp __alltraps
  101dd7:	e9 13 0a 00 00       	jmp    1027ef <__alltraps>

00101ddc <vector11>:
.globl vector11
vector11:
  pushl $11
  101ddc:	6a 0b                	push   $0xb
  jmp __alltraps
  101dde:	e9 0c 0a 00 00       	jmp    1027ef <__alltraps>

00101de3 <vector12>:
.globl vector12
vector12:
  pushl $12
  101de3:	6a 0c                	push   $0xc
  jmp __alltraps
  101de5:	e9 05 0a 00 00       	jmp    1027ef <__alltraps>

00101dea <vector13>:
.globl vector13
vector13:
  pushl $13
  101dea:	6a 0d                	push   $0xd
  jmp __alltraps
  101dec:	e9 fe 09 00 00       	jmp    1027ef <__alltraps>

00101df1 <vector14>:
.globl vector14
vector14:
  pushl $14
  101df1:	6a 0e                	push   $0xe
  jmp __alltraps
  101df3:	e9 f7 09 00 00       	jmp    1027ef <__alltraps>

00101df8 <vector15>:
.globl vector15
vector15:
  pushl $0
  101df8:	6a 00                	push   $0x0
  pushl $15
  101dfa:	6a 0f                	push   $0xf
  jmp __alltraps
  101dfc:	e9 ee 09 00 00       	jmp    1027ef <__alltraps>

00101e01 <vector16>:
.globl vector16
vector16:
  pushl $0
  101e01:	6a 00                	push   $0x0
  pushl $16
  101e03:	6a 10                	push   $0x10
  jmp __alltraps
  101e05:	e9 e5 09 00 00       	jmp    1027ef <__alltraps>

00101e0a <vector17>:
.globl vector17
vector17:
  pushl $17
  101e0a:	6a 11                	push   $0x11
  jmp __alltraps
  101e0c:	e9 de 09 00 00       	jmp    1027ef <__alltraps>

00101e11 <vector18>:
.globl vector18
vector18:
  pushl $0
  101e11:	6a 00                	push   $0x0
  pushl $18
  101e13:	6a 12                	push   $0x12
  jmp __alltraps
  101e15:	e9 d5 09 00 00       	jmp    1027ef <__alltraps>

00101e1a <vector19>:
.globl vector19
vector19:
  pushl $0
  101e1a:	6a 00                	push   $0x0
  pushl $19
  101e1c:	6a 13                	push   $0x13
  jmp __alltraps
  101e1e:	e9 cc 09 00 00       	jmp    1027ef <__alltraps>

00101e23 <vector20>:
.globl vector20
vector20:
  pushl $0
  101e23:	6a 00                	push   $0x0
  pushl $20
  101e25:	6a 14                	push   $0x14
  jmp __alltraps
  101e27:	e9 c3 09 00 00       	jmp    1027ef <__alltraps>

00101e2c <vector21>:
.globl vector21
vector21:
  pushl $0
  101e2c:	6a 00                	push   $0x0
  pushl $21
  101e2e:	6a 15                	push   $0x15
  jmp __alltraps
  101e30:	e9 ba 09 00 00       	jmp    1027ef <__alltraps>

00101e35 <vector22>:
.globl vector22
vector22:
  pushl $0
  101e35:	6a 00                	push   $0x0
  pushl $22
  101e37:	6a 16                	push   $0x16
  jmp __alltraps
  101e39:	e9 b1 09 00 00       	jmp    1027ef <__alltraps>

00101e3e <vector23>:
.globl vector23
vector23:
  pushl $0
  101e3e:	6a 00                	push   $0x0
  pushl $23
  101e40:	6a 17                	push   $0x17
  jmp __alltraps
  101e42:	e9 a8 09 00 00       	jmp    1027ef <__alltraps>

00101e47 <vector24>:
.globl vector24
vector24:
  pushl $0
  101e47:	6a 00                	push   $0x0
  pushl $24
  101e49:	6a 18                	push   $0x18
  jmp __alltraps
  101e4b:	e9 9f 09 00 00       	jmp    1027ef <__alltraps>

00101e50 <vector25>:
.globl vector25
vector25:
  pushl $0
  101e50:	6a 00                	push   $0x0
  pushl $25
  101e52:	6a 19                	push   $0x19
  jmp __alltraps
  101e54:	e9 96 09 00 00       	jmp    1027ef <__alltraps>

00101e59 <vector26>:
.globl vector26
vector26:
  pushl $0
  101e59:	6a 00                	push   $0x0
  pushl $26
  101e5b:	6a 1a                	push   $0x1a
  jmp __alltraps
  101e5d:	e9 8d 09 00 00       	jmp    1027ef <__alltraps>

00101e62 <vector27>:
.globl vector27
vector27:
  pushl $0
  101e62:	6a 00                	push   $0x0
  pushl $27
  101e64:	6a 1b                	push   $0x1b
  jmp __alltraps
  101e66:	e9 84 09 00 00       	jmp    1027ef <__alltraps>

00101e6b <vector28>:
.globl vector28
vector28:
  pushl $0
  101e6b:	6a 00                	push   $0x0
  pushl $28
  101e6d:	6a 1c                	push   $0x1c
  jmp __alltraps
  101e6f:	e9 7b 09 00 00       	jmp    1027ef <__alltraps>

00101e74 <vector29>:
.globl vector29
vector29:
  pushl $0
  101e74:	6a 00                	push   $0x0
  pushl $29
  101e76:	6a 1d                	push   $0x1d
  jmp __alltraps
  101e78:	e9 72 09 00 00       	jmp    1027ef <__alltraps>

00101e7d <vector30>:
.globl vector30
vector30:
  pushl $0
  101e7d:	6a 00                	push   $0x0
  pushl $30
  101e7f:	6a 1e                	push   $0x1e
  jmp __alltraps
  101e81:	e9 69 09 00 00       	jmp    1027ef <__alltraps>

00101e86 <vector31>:
.globl vector31
vector31:
  pushl $0
  101e86:	6a 00                	push   $0x0
  pushl $31
  101e88:	6a 1f                	push   $0x1f
  jmp __alltraps
  101e8a:	e9 60 09 00 00       	jmp    1027ef <__alltraps>

00101e8f <vector32>:
.globl vector32
vector32:
  pushl $0
  101e8f:	6a 00                	push   $0x0
  pushl $32
  101e91:	6a 20                	push   $0x20
  jmp __alltraps
  101e93:	e9 57 09 00 00       	jmp    1027ef <__alltraps>

00101e98 <vector33>:
.globl vector33
vector33:
  pushl $0
  101e98:	6a 00                	push   $0x0
  pushl $33
  101e9a:	6a 21                	push   $0x21
  jmp __alltraps
  101e9c:	e9 4e 09 00 00       	jmp    1027ef <__alltraps>

00101ea1 <vector34>:
.globl vector34
vector34:
  pushl $0
  101ea1:	6a 00                	push   $0x0
  pushl $34
  101ea3:	6a 22                	push   $0x22
  jmp __alltraps
  101ea5:	e9 45 09 00 00       	jmp    1027ef <__alltraps>

00101eaa <vector35>:
.globl vector35
vector35:
  pushl $0
  101eaa:	6a 00                	push   $0x0
  pushl $35
  101eac:	6a 23                	push   $0x23
  jmp __alltraps
  101eae:	e9 3c 09 00 00       	jmp    1027ef <__alltraps>

00101eb3 <vector36>:
.globl vector36
vector36:
  pushl $0
  101eb3:	6a 00                	push   $0x0
  pushl $36
  101eb5:	6a 24                	push   $0x24
  jmp __alltraps
  101eb7:	e9 33 09 00 00       	jmp    1027ef <__alltraps>

00101ebc <vector37>:
.globl vector37
vector37:
  pushl $0
  101ebc:	6a 00                	push   $0x0
  pushl $37
  101ebe:	6a 25                	push   $0x25
  jmp __alltraps
  101ec0:	e9 2a 09 00 00       	jmp    1027ef <__alltraps>

00101ec5 <vector38>:
.globl vector38
vector38:
  pushl $0
  101ec5:	6a 00                	push   $0x0
  pushl $38
  101ec7:	6a 26                	push   $0x26
  jmp __alltraps
  101ec9:	e9 21 09 00 00       	jmp    1027ef <__alltraps>

00101ece <vector39>:
.globl vector39
vector39:
  pushl $0
  101ece:	6a 00                	push   $0x0
  pushl $39
  101ed0:	6a 27                	push   $0x27
  jmp __alltraps
  101ed2:	e9 18 09 00 00       	jmp    1027ef <__alltraps>

00101ed7 <vector40>:
.globl vector40
vector40:
  pushl $0
  101ed7:	6a 00                	push   $0x0
  pushl $40
  101ed9:	6a 28                	push   $0x28
  jmp __alltraps
  101edb:	e9 0f 09 00 00       	jmp    1027ef <__alltraps>

00101ee0 <vector41>:
.globl vector41
vector41:
  pushl $0
  101ee0:	6a 00                	push   $0x0
  pushl $41
  101ee2:	6a 29                	push   $0x29
  jmp __alltraps
  101ee4:	e9 06 09 00 00       	jmp    1027ef <__alltraps>

00101ee9 <vector42>:
.globl vector42
vector42:
  pushl $0
  101ee9:	6a 00                	push   $0x0
  pushl $42
  101eeb:	6a 2a                	push   $0x2a
  jmp __alltraps
  101eed:	e9 fd 08 00 00       	jmp    1027ef <__alltraps>

00101ef2 <vector43>:
.globl vector43
vector43:
  pushl $0
  101ef2:	6a 00                	push   $0x0
  pushl $43
  101ef4:	6a 2b                	push   $0x2b
  jmp __alltraps
  101ef6:	e9 f4 08 00 00       	jmp    1027ef <__alltraps>

00101efb <vector44>:
.globl vector44
vector44:
  pushl $0
  101efb:	6a 00                	push   $0x0
  pushl $44
  101efd:	6a 2c                	push   $0x2c
  jmp __alltraps
  101eff:	e9 eb 08 00 00       	jmp    1027ef <__alltraps>

00101f04 <vector45>:
.globl vector45
vector45:
  pushl $0
  101f04:	6a 00                	push   $0x0
  pushl $45
  101f06:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f08:	e9 e2 08 00 00       	jmp    1027ef <__alltraps>

00101f0d <vector46>:
.globl vector46
vector46:
  pushl $0
  101f0d:	6a 00                	push   $0x0
  pushl $46
  101f0f:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f11:	e9 d9 08 00 00       	jmp    1027ef <__alltraps>

00101f16 <vector47>:
.globl vector47
vector47:
  pushl $0
  101f16:	6a 00                	push   $0x0
  pushl $47
  101f18:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f1a:	e9 d0 08 00 00       	jmp    1027ef <__alltraps>

00101f1f <vector48>:
.globl vector48
vector48:
  pushl $0
  101f1f:	6a 00                	push   $0x0
  pushl $48
  101f21:	6a 30                	push   $0x30
  jmp __alltraps
  101f23:	e9 c7 08 00 00       	jmp    1027ef <__alltraps>

00101f28 <vector49>:
.globl vector49
vector49:
  pushl $0
  101f28:	6a 00                	push   $0x0
  pushl $49
  101f2a:	6a 31                	push   $0x31
  jmp __alltraps
  101f2c:	e9 be 08 00 00       	jmp    1027ef <__alltraps>

00101f31 <vector50>:
.globl vector50
vector50:
  pushl $0
  101f31:	6a 00                	push   $0x0
  pushl $50
  101f33:	6a 32                	push   $0x32
  jmp __alltraps
  101f35:	e9 b5 08 00 00       	jmp    1027ef <__alltraps>

00101f3a <vector51>:
.globl vector51
vector51:
  pushl $0
  101f3a:	6a 00                	push   $0x0
  pushl $51
  101f3c:	6a 33                	push   $0x33
  jmp __alltraps
  101f3e:	e9 ac 08 00 00       	jmp    1027ef <__alltraps>

00101f43 <vector52>:
.globl vector52
vector52:
  pushl $0
  101f43:	6a 00                	push   $0x0
  pushl $52
  101f45:	6a 34                	push   $0x34
  jmp __alltraps
  101f47:	e9 a3 08 00 00       	jmp    1027ef <__alltraps>

00101f4c <vector53>:
.globl vector53
vector53:
  pushl $0
  101f4c:	6a 00                	push   $0x0
  pushl $53
  101f4e:	6a 35                	push   $0x35
  jmp __alltraps
  101f50:	e9 9a 08 00 00       	jmp    1027ef <__alltraps>

00101f55 <vector54>:
.globl vector54
vector54:
  pushl $0
  101f55:	6a 00                	push   $0x0
  pushl $54
  101f57:	6a 36                	push   $0x36
  jmp __alltraps
  101f59:	e9 91 08 00 00       	jmp    1027ef <__alltraps>

00101f5e <vector55>:
.globl vector55
vector55:
  pushl $0
  101f5e:	6a 00                	push   $0x0
  pushl $55
  101f60:	6a 37                	push   $0x37
  jmp __alltraps
  101f62:	e9 88 08 00 00       	jmp    1027ef <__alltraps>

00101f67 <vector56>:
.globl vector56
vector56:
  pushl $0
  101f67:	6a 00                	push   $0x0
  pushl $56
  101f69:	6a 38                	push   $0x38
  jmp __alltraps
  101f6b:	e9 7f 08 00 00       	jmp    1027ef <__alltraps>

00101f70 <vector57>:
.globl vector57
vector57:
  pushl $0
  101f70:	6a 00                	push   $0x0
  pushl $57
  101f72:	6a 39                	push   $0x39
  jmp __alltraps
  101f74:	e9 76 08 00 00       	jmp    1027ef <__alltraps>

00101f79 <vector58>:
.globl vector58
vector58:
  pushl $0
  101f79:	6a 00                	push   $0x0
  pushl $58
  101f7b:	6a 3a                	push   $0x3a
  jmp __alltraps
  101f7d:	e9 6d 08 00 00       	jmp    1027ef <__alltraps>

00101f82 <vector59>:
.globl vector59
vector59:
  pushl $0
  101f82:	6a 00                	push   $0x0
  pushl $59
  101f84:	6a 3b                	push   $0x3b
  jmp __alltraps
  101f86:	e9 64 08 00 00       	jmp    1027ef <__alltraps>

00101f8b <vector60>:
.globl vector60
vector60:
  pushl $0
  101f8b:	6a 00                	push   $0x0
  pushl $60
  101f8d:	6a 3c                	push   $0x3c
  jmp __alltraps
  101f8f:	e9 5b 08 00 00       	jmp    1027ef <__alltraps>

00101f94 <vector61>:
.globl vector61
vector61:
  pushl $0
  101f94:	6a 00                	push   $0x0
  pushl $61
  101f96:	6a 3d                	push   $0x3d
  jmp __alltraps
  101f98:	e9 52 08 00 00       	jmp    1027ef <__alltraps>

00101f9d <vector62>:
.globl vector62
vector62:
  pushl $0
  101f9d:	6a 00                	push   $0x0
  pushl $62
  101f9f:	6a 3e                	push   $0x3e
  jmp __alltraps
  101fa1:	e9 49 08 00 00       	jmp    1027ef <__alltraps>

00101fa6 <vector63>:
.globl vector63
vector63:
  pushl $0
  101fa6:	6a 00                	push   $0x0
  pushl $63
  101fa8:	6a 3f                	push   $0x3f
  jmp __alltraps
  101faa:	e9 40 08 00 00       	jmp    1027ef <__alltraps>

00101faf <vector64>:
.globl vector64
vector64:
  pushl $0
  101faf:	6a 00                	push   $0x0
  pushl $64
  101fb1:	6a 40                	push   $0x40
  jmp __alltraps
  101fb3:	e9 37 08 00 00       	jmp    1027ef <__alltraps>

00101fb8 <vector65>:
.globl vector65
vector65:
  pushl $0
  101fb8:	6a 00                	push   $0x0
  pushl $65
  101fba:	6a 41                	push   $0x41
  jmp __alltraps
  101fbc:	e9 2e 08 00 00       	jmp    1027ef <__alltraps>

00101fc1 <vector66>:
.globl vector66
vector66:
  pushl $0
  101fc1:	6a 00                	push   $0x0
  pushl $66
  101fc3:	6a 42                	push   $0x42
  jmp __alltraps
  101fc5:	e9 25 08 00 00       	jmp    1027ef <__alltraps>

00101fca <vector67>:
.globl vector67
vector67:
  pushl $0
  101fca:	6a 00                	push   $0x0
  pushl $67
  101fcc:	6a 43                	push   $0x43
  jmp __alltraps
  101fce:	e9 1c 08 00 00       	jmp    1027ef <__alltraps>

00101fd3 <vector68>:
.globl vector68
vector68:
  pushl $0
  101fd3:	6a 00                	push   $0x0
  pushl $68
  101fd5:	6a 44                	push   $0x44
  jmp __alltraps
  101fd7:	e9 13 08 00 00       	jmp    1027ef <__alltraps>

00101fdc <vector69>:
.globl vector69
vector69:
  pushl $0
  101fdc:	6a 00                	push   $0x0
  pushl $69
  101fde:	6a 45                	push   $0x45
  jmp __alltraps
  101fe0:	e9 0a 08 00 00       	jmp    1027ef <__alltraps>

00101fe5 <vector70>:
.globl vector70
vector70:
  pushl $0
  101fe5:	6a 00                	push   $0x0
  pushl $70
  101fe7:	6a 46                	push   $0x46
  jmp __alltraps
  101fe9:	e9 01 08 00 00       	jmp    1027ef <__alltraps>

00101fee <vector71>:
.globl vector71
vector71:
  pushl $0
  101fee:	6a 00                	push   $0x0
  pushl $71
  101ff0:	6a 47                	push   $0x47
  jmp __alltraps
  101ff2:	e9 f8 07 00 00       	jmp    1027ef <__alltraps>

00101ff7 <vector72>:
.globl vector72
vector72:
  pushl $0
  101ff7:	6a 00                	push   $0x0
  pushl $72
  101ff9:	6a 48                	push   $0x48
  jmp __alltraps
  101ffb:	e9 ef 07 00 00       	jmp    1027ef <__alltraps>

00102000 <vector73>:
.globl vector73
vector73:
  pushl $0
  102000:	6a 00                	push   $0x0
  pushl $73
  102002:	6a 49                	push   $0x49
  jmp __alltraps
  102004:	e9 e6 07 00 00       	jmp    1027ef <__alltraps>

00102009 <vector74>:
.globl vector74
vector74:
  pushl $0
  102009:	6a 00                	push   $0x0
  pushl $74
  10200b:	6a 4a                	push   $0x4a
  jmp __alltraps
  10200d:	e9 dd 07 00 00       	jmp    1027ef <__alltraps>

00102012 <vector75>:
.globl vector75
vector75:
  pushl $0
  102012:	6a 00                	push   $0x0
  pushl $75
  102014:	6a 4b                	push   $0x4b
  jmp __alltraps
  102016:	e9 d4 07 00 00       	jmp    1027ef <__alltraps>

0010201b <vector76>:
.globl vector76
vector76:
  pushl $0
  10201b:	6a 00                	push   $0x0
  pushl $76
  10201d:	6a 4c                	push   $0x4c
  jmp __alltraps
  10201f:	e9 cb 07 00 00       	jmp    1027ef <__alltraps>

00102024 <vector77>:
.globl vector77
vector77:
  pushl $0
  102024:	6a 00                	push   $0x0
  pushl $77
  102026:	6a 4d                	push   $0x4d
  jmp __alltraps
  102028:	e9 c2 07 00 00       	jmp    1027ef <__alltraps>

0010202d <vector78>:
.globl vector78
vector78:
  pushl $0
  10202d:	6a 00                	push   $0x0
  pushl $78
  10202f:	6a 4e                	push   $0x4e
  jmp __alltraps
  102031:	e9 b9 07 00 00       	jmp    1027ef <__alltraps>

00102036 <vector79>:
.globl vector79
vector79:
  pushl $0
  102036:	6a 00                	push   $0x0
  pushl $79
  102038:	6a 4f                	push   $0x4f
  jmp __alltraps
  10203a:	e9 b0 07 00 00       	jmp    1027ef <__alltraps>

0010203f <vector80>:
.globl vector80
vector80:
  pushl $0
  10203f:	6a 00                	push   $0x0
  pushl $80
  102041:	6a 50                	push   $0x50
  jmp __alltraps
  102043:	e9 a7 07 00 00       	jmp    1027ef <__alltraps>

00102048 <vector81>:
.globl vector81
vector81:
  pushl $0
  102048:	6a 00                	push   $0x0
  pushl $81
  10204a:	6a 51                	push   $0x51
  jmp __alltraps
  10204c:	e9 9e 07 00 00       	jmp    1027ef <__alltraps>

00102051 <vector82>:
.globl vector82
vector82:
  pushl $0
  102051:	6a 00                	push   $0x0
  pushl $82
  102053:	6a 52                	push   $0x52
  jmp __alltraps
  102055:	e9 95 07 00 00       	jmp    1027ef <__alltraps>

0010205a <vector83>:
.globl vector83
vector83:
  pushl $0
  10205a:	6a 00                	push   $0x0
  pushl $83
  10205c:	6a 53                	push   $0x53
  jmp __alltraps
  10205e:	e9 8c 07 00 00       	jmp    1027ef <__alltraps>

00102063 <vector84>:
.globl vector84
vector84:
  pushl $0
  102063:	6a 00                	push   $0x0
  pushl $84
  102065:	6a 54                	push   $0x54
  jmp __alltraps
  102067:	e9 83 07 00 00       	jmp    1027ef <__alltraps>

0010206c <vector85>:
.globl vector85
vector85:
  pushl $0
  10206c:	6a 00                	push   $0x0
  pushl $85
  10206e:	6a 55                	push   $0x55
  jmp __alltraps
  102070:	e9 7a 07 00 00       	jmp    1027ef <__alltraps>

00102075 <vector86>:
.globl vector86
vector86:
  pushl $0
  102075:	6a 00                	push   $0x0
  pushl $86
  102077:	6a 56                	push   $0x56
  jmp __alltraps
  102079:	e9 71 07 00 00       	jmp    1027ef <__alltraps>

0010207e <vector87>:
.globl vector87
vector87:
  pushl $0
  10207e:	6a 00                	push   $0x0
  pushl $87
  102080:	6a 57                	push   $0x57
  jmp __alltraps
  102082:	e9 68 07 00 00       	jmp    1027ef <__alltraps>

00102087 <vector88>:
.globl vector88
vector88:
  pushl $0
  102087:	6a 00                	push   $0x0
  pushl $88
  102089:	6a 58                	push   $0x58
  jmp __alltraps
  10208b:	e9 5f 07 00 00       	jmp    1027ef <__alltraps>

00102090 <vector89>:
.globl vector89
vector89:
  pushl $0
  102090:	6a 00                	push   $0x0
  pushl $89
  102092:	6a 59                	push   $0x59
  jmp __alltraps
  102094:	e9 56 07 00 00       	jmp    1027ef <__alltraps>

00102099 <vector90>:
.globl vector90
vector90:
  pushl $0
  102099:	6a 00                	push   $0x0
  pushl $90
  10209b:	6a 5a                	push   $0x5a
  jmp __alltraps
  10209d:	e9 4d 07 00 00       	jmp    1027ef <__alltraps>

001020a2 <vector91>:
.globl vector91
vector91:
  pushl $0
  1020a2:	6a 00                	push   $0x0
  pushl $91
  1020a4:	6a 5b                	push   $0x5b
  jmp __alltraps
  1020a6:	e9 44 07 00 00       	jmp    1027ef <__alltraps>

001020ab <vector92>:
.globl vector92
vector92:
  pushl $0
  1020ab:	6a 00                	push   $0x0
  pushl $92
  1020ad:	6a 5c                	push   $0x5c
  jmp __alltraps
  1020af:	e9 3b 07 00 00       	jmp    1027ef <__alltraps>

001020b4 <vector93>:
.globl vector93
vector93:
  pushl $0
  1020b4:	6a 00                	push   $0x0
  pushl $93
  1020b6:	6a 5d                	push   $0x5d
  jmp __alltraps
  1020b8:	e9 32 07 00 00       	jmp    1027ef <__alltraps>

001020bd <vector94>:
.globl vector94
vector94:
  pushl $0
  1020bd:	6a 00                	push   $0x0
  pushl $94
  1020bf:	6a 5e                	push   $0x5e
  jmp __alltraps
  1020c1:	e9 29 07 00 00       	jmp    1027ef <__alltraps>

001020c6 <vector95>:
.globl vector95
vector95:
  pushl $0
  1020c6:	6a 00                	push   $0x0
  pushl $95
  1020c8:	6a 5f                	push   $0x5f
  jmp __alltraps
  1020ca:	e9 20 07 00 00       	jmp    1027ef <__alltraps>

001020cf <vector96>:
.globl vector96
vector96:
  pushl $0
  1020cf:	6a 00                	push   $0x0
  pushl $96
  1020d1:	6a 60                	push   $0x60
  jmp __alltraps
  1020d3:	e9 17 07 00 00       	jmp    1027ef <__alltraps>

001020d8 <vector97>:
.globl vector97
vector97:
  pushl $0
  1020d8:	6a 00                	push   $0x0
  pushl $97
  1020da:	6a 61                	push   $0x61
  jmp __alltraps
  1020dc:	e9 0e 07 00 00       	jmp    1027ef <__alltraps>

001020e1 <vector98>:
.globl vector98
vector98:
  pushl $0
  1020e1:	6a 00                	push   $0x0
  pushl $98
  1020e3:	6a 62                	push   $0x62
  jmp __alltraps
  1020e5:	e9 05 07 00 00       	jmp    1027ef <__alltraps>

001020ea <vector99>:
.globl vector99
vector99:
  pushl $0
  1020ea:	6a 00                	push   $0x0
  pushl $99
  1020ec:	6a 63                	push   $0x63
  jmp __alltraps
  1020ee:	e9 fc 06 00 00       	jmp    1027ef <__alltraps>

001020f3 <vector100>:
.globl vector100
vector100:
  pushl $0
  1020f3:	6a 00                	push   $0x0
  pushl $100
  1020f5:	6a 64                	push   $0x64
  jmp __alltraps
  1020f7:	e9 f3 06 00 00       	jmp    1027ef <__alltraps>

001020fc <vector101>:
.globl vector101
vector101:
  pushl $0
  1020fc:	6a 00                	push   $0x0
  pushl $101
  1020fe:	6a 65                	push   $0x65
  jmp __alltraps
  102100:	e9 ea 06 00 00       	jmp    1027ef <__alltraps>

00102105 <vector102>:
.globl vector102
vector102:
  pushl $0
  102105:	6a 00                	push   $0x0
  pushl $102
  102107:	6a 66                	push   $0x66
  jmp __alltraps
  102109:	e9 e1 06 00 00       	jmp    1027ef <__alltraps>

0010210e <vector103>:
.globl vector103
vector103:
  pushl $0
  10210e:	6a 00                	push   $0x0
  pushl $103
  102110:	6a 67                	push   $0x67
  jmp __alltraps
  102112:	e9 d8 06 00 00       	jmp    1027ef <__alltraps>

00102117 <vector104>:
.globl vector104
vector104:
  pushl $0
  102117:	6a 00                	push   $0x0
  pushl $104
  102119:	6a 68                	push   $0x68
  jmp __alltraps
  10211b:	e9 cf 06 00 00       	jmp    1027ef <__alltraps>

00102120 <vector105>:
.globl vector105
vector105:
  pushl $0
  102120:	6a 00                	push   $0x0
  pushl $105
  102122:	6a 69                	push   $0x69
  jmp __alltraps
  102124:	e9 c6 06 00 00       	jmp    1027ef <__alltraps>

00102129 <vector106>:
.globl vector106
vector106:
  pushl $0
  102129:	6a 00                	push   $0x0
  pushl $106
  10212b:	6a 6a                	push   $0x6a
  jmp __alltraps
  10212d:	e9 bd 06 00 00       	jmp    1027ef <__alltraps>

00102132 <vector107>:
.globl vector107
vector107:
  pushl $0
  102132:	6a 00                	push   $0x0
  pushl $107
  102134:	6a 6b                	push   $0x6b
  jmp __alltraps
  102136:	e9 b4 06 00 00       	jmp    1027ef <__alltraps>

0010213b <vector108>:
.globl vector108
vector108:
  pushl $0
  10213b:	6a 00                	push   $0x0
  pushl $108
  10213d:	6a 6c                	push   $0x6c
  jmp __alltraps
  10213f:	e9 ab 06 00 00       	jmp    1027ef <__alltraps>

00102144 <vector109>:
.globl vector109
vector109:
  pushl $0
  102144:	6a 00                	push   $0x0
  pushl $109
  102146:	6a 6d                	push   $0x6d
  jmp __alltraps
  102148:	e9 a2 06 00 00       	jmp    1027ef <__alltraps>

0010214d <vector110>:
.globl vector110
vector110:
  pushl $0
  10214d:	6a 00                	push   $0x0
  pushl $110
  10214f:	6a 6e                	push   $0x6e
  jmp __alltraps
  102151:	e9 99 06 00 00       	jmp    1027ef <__alltraps>

00102156 <vector111>:
.globl vector111
vector111:
  pushl $0
  102156:	6a 00                	push   $0x0
  pushl $111
  102158:	6a 6f                	push   $0x6f
  jmp __alltraps
  10215a:	e9 90 06 00 00       	jmp    1027ef <__alltraps>

0010215f <vector112>:
.globl vector112
vector112:
  pushl $0
  10215f:	6a 00                	push   $0x0
  pushl $112
  102161:	6a 70                	push   $0x70
  jmp __alltraps
  102163:	e9 87 06 00 00       	jmp    1027ef <__alltraps>

00102168 <vector113>:
.globl vector113
vector113:
  pushl $0
  102168:	6a 00                	push   $0x0
  pushl $113
  10216a:	6a 71                	push   $0x71
  jmp __alltraps
  10216c:	e9 7e 06 00 00       	jmp    1027ef <__alltraps>

00102171 <vector114>:
.globl vector114
vector114:
  pushl $0
  102171:	6a 00                	push   $0x0
  pushl $114
  102173:	6a 72                	push   $0x72
  jmp __alltraps
  102175:	e9 75 06 00 00       	jmp    1027ef <__alltraps>

0010217a <vector115>:
.globl vector115
vector115:
  pushl $0
  10217a:	6a 00                	push   $0x0
  pushl $115
  10217c:	6a 73                	push   $0x73
  jmp __alltraps
  10217e:	e9 6c 06 00 00       	jmp    1027ef <__alltraps>

00102183 <vector116>:
.globl vector116
vector116:
  pushl $0
  102183:	6a 00                	push   $0x0
  pushl $116
  102185:	6a 74                	push   $0x74
  jmp __alltraps
  102187:	e9 63 06 00 00       	jmp    1027ef <__alltraps>

0010218c <vector117>:
.globl vector117
vector117:
  pushl $0
  10218c:	6a 00                	push   $0x0
  pushl $117
  10218e:	6a 75                	push   $0x75
  jmp __alltraps
  102190:	e9 5a 06 00 00       	jmp    1027ef <__alltraps>

00102195 <vector118>:
.globl vector118
vector118:
  pushl $0
  102195:	6a 00                	push   $0x0
  pushl $118
  102197:	6a 76                	push   $0x76
  jmp __alltraps
  102199:	e9 51 06 00 00       	jmp    1027ef <__alltraps>

0010219e <vector119>:
.globl vector119
vector119:
  pushl $0
  10219e:	6a 00                	push   $0x0
  pushl $119
  1021a0:	6a 77                	push   $0x77
  jmp __alltraps
  1021a2:	e9 48 06 00 00       	jmp    1027ef <__alltraps>

001021a7 <vector120>:
.globl vector120
vector120:
  pushl $0
  1021a7:	6a 00                	push   $0x0
  pushl $120
  1021a9:	6a 78                	push   $0x78
  jmp __alltraps
  1021ab:	e9 3f 06 00 00       	jmp    1027ef <__alltraps>

001021b0 <vector121>:
.globl vector121
vector121:
  pushl $0
  1021b0:	6a 00                	push   $0x0
  pushl $121
  1021b2:	6a 79                	push   $0x79
  jmp __alltraps
  1021b4:	e9 36 06 00 00       	jmp    1027ef <__alltraps>

001021b9 <vector122>:
.globl vector122
vector122:
  pushl $0
  1021b9:	6a 00                	push   $0x0
  pushl $122
  1021bb:	6a 7a                	push   $0x7a
  jmp __alltraps
  1021bd:	e9 2d 06 00 00       	jmp    1027ef <__alltraps>

001021c2 <vector123>:
.globl vector123
vector123:
  pushl $0
  1021c2:	6a 00                	push   $0x0
  pushl $123
  1021c4:	6a 7b                	push   $0x7b
  jmp __alltraps
  1021c6:	e9 24 06 00 00       	jmp    1027ef <__alltraps>

001021cb <vector124>:
.globl vector124
vector124:
  pushl $0
  1021cb:	6a 00                	push   $0x0
  pushl $124
  1021cd:	6a 7c                	push   $0x7c
  jmp __alltraps
  1021cf:	e9 1b 06 00 00       	jmp    1027ef <__alltraps>

001021d4 <vector125>:
.globl vector125
vector125:
  pushl $0
  1021d4:	6a 00                	push   $0x0
  pushl $125
  1021d6:	6a 7d                	push   $0x7d
  jmp __alltraps
  1021d8:	e9 12 06 00 00       	jmp    1027ef <__alltraps>

001021dd <vector126>:
.globl vector126
vector126:
  pushl $0
  1021dd:	6a 00                	push   $0x0
  pushl $126
  1021df:	6a 7e                	push   $0x7e
  jmp __alltraps
  1021e1:	e9 09 06 00 00       	jmp    1027ef <__alltraps>

001021e6 <vector127>:
.globl vector127
vector127:
  pushl $0
  1021e6:	6a 00                	push   $0x0
  pushl $127
  1021e8:	6a 7f                	push   $0x7f
  jmp __alltraps
  1021ea:	e9 00 06 00 00       	jmp    1027ef <__alltraps>

001021ef <vector128>:
.globl vector128
vector128:
  pushl $0
  1021ef:	6a 00                	push   $0x0
  pushl $128
  1021f1:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1021f6:	e9 f4 05 00 00       	jmp    1027ef <__alltraps>

001021fb <vector129>:
.globl vector129
vector129:
  pushl $0
  1021fb:	6a 00                	push   $0x0
  pushl $129
  1021fd:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102202:	e9 e8 05 00 00       	jmp    1027ef <__alltraps>

00102207 <vector130>:
.globl vector130
vector130:
  pushl $0
  102207:	6a 00                	push   $0x0
  pushl $130
  102209:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10220e:	e9 dc 05 00 00       	jmp    1027ef <__alltraps>

00102213 <vector131>:
.globl vector131
vector131:
  pushl $0
  102213:	6a 00                	push   $0x0
  pushl $131
  102215:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  10221a:	e9 d0 05 00 00       	jmp    1027ef <__alltraps>

0010221f <vector132>:
.globl vector132
vector132:
  pushl $0
  10221f:	6a 00                	push   $0x0
  pushl $132
  102221:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102226:	e9 c4 05 00 00       	jmp    1027ef <__alltraps>

0010222b <vector133>:
.globl vector133
vector133:
  pushl $0
  10222b:	6a 00                	push   $0x0
  pushl $133
  10222d:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102232:	e9 b8 05 00 00       	jmp    1027ef <__alltraps>

00102237 <vector134>:
.globl vector134
vector134:
  pushl $0
  102237:	6a 00                	push   $0x0
  pushl $134
  102239:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10223e:	e9 ac 05 00 00       	jmp    1027ef <__alltraps>

00102243 <vector135>:
.globl vector135
vector135:
  pushl $0
  102243:	6a 00                	push   $0x0
  pushl $135
  102245:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  10224a:	e9 a0 05 00 00       	jmp    1027ef <__alltraps>

0010224f <vector136>:
.globl vector136
vector136:
  pushl $0
  10224f:	6a 00                	push   $0x0
  pushl $136
  102251:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102256:	e9 94 05 00 00       	jmp    1027ef <__alltraps>

0010225b <vector137>:
.globl vector137
vector137:
  pushl $0
  10225b:	6a 00                	push   $0x0
  pushl $137
  10225d:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102262:	e9 88 05 00 00       	jmp    1027ef <__alltraps>

00102267 <vector138>:
.globl vector138
vector138:
  pushl $0
  102267:	6a 00                	push   $0x0
  pushl $138
  102269:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  10226e:	e9 7c 05 00 00       	jmp    1027ef <__alltraps>

00102273 <vector139>:
.globl vector139
vector139:
  pushl $0
  102273:	6a 00                	push   $0x0
  pushl $139
  102275:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10227a:	e9 70 05 00 00       	jmp    1027ef <__alltraps>

0010227f <vector140>:
.globl vector140
vector140:
  pushl $0
  10227f:	6a 00                	push   $0x0
  pushl $140
  102281:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102286:	e9 64 05 00 00       	jmp    1027ef <__alltraps>

0010228b <vector141>:
.globl vector141
vector141:
  pushl $0
  10228b:	6a 00                	push   $0x0
  pushl $141
  10228d:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102292:	e9 58 05 00 00       	jmp    1027ef <__alltraps>

00102297 <vector142>:
.globl vector142
vector142:
  pushl $0
  102297:	6a 00                	push   $0x0
  pushl $142
  102299:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  10229e:	e9 4c 05 00 00       	jmp    1027ef <__alltraps>

001022a3 <vector143>:
.globl vector143
vector143:
  pushl $0
  1022a3:	6a 00                	push   $0x0
  pushl $143
  1022a5:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1022aa:	e9 40 05 00 00       	jmp    1027ef <__alltraps>

001022af <vector144>:
.globl vector144
vector144:
  pushl $0
  1022af:	6a 00                	push   $0x0
  pushl $144
  1022b1:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1022b6:	e9 34 05 00 00       	jmp    1027ef <__alltraps>

001022bb <vector145>:
.globl vector145
vector145:
  pushl $0
  1022bb:	6a 00                	push   $0x0
  pushl $145
  1022bd:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1022c2:	e9 28 05 00 00       	jmp    1027ef <__alltraps>

001022c7 <vector146>:
.globl vector146
vector146:
  pushl $0
  1022c7:	6a 00                	push   $0x0
  pushl $146
  1022c9:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1022ce:	e9 1c 05 00 00       	jmp    1027ef <__alltraps>

001022d3 <vector147>:
.globl vector147
vector147:
  pushl $0
  1022d3:	6a 00                	push   $0x0
  pushl $147
  1022d5:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1022da:	e9 10 05 00 00       	jmp    1027ef <__alltraps>

001022df <vector148>:
.globl vector148
vector148:
  pushl $0
  1022df:	6a 00                	push   $0x0
  pushl $148
  1022e1:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1022e6:	e9 04 05 00 00       	jmp    1027ef <__alltraps>

001022eb <vector149>:
.globl vector149
vector149:
  pushl $0
  1022eb:	6a 00                	push   $0x0
  pushl $149
  1022ed:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1022f2:	e9 f8 04 00 00       	jmp    1027ef <__alltraps>

001022f7 <vector150>:
.globl vector150
vector150:
  pushl $0
  1022f7:	6a 00                	push   $0x0
  pushl $150
  1022f9:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1022fe:	e9 ec 04 00 00       	jmp    1027ef <__alltraps>

00102303 <vector151>:
.globl vector151
vector151:
  pushl $0
  102303:	6a 00                	push   $0x0
  pushl $151
  102305:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10230a:	e9 e0 04 00 00       	jmp    1027ef <__alltraps>

0010230f <vector152>:
.globl vector152
vector152:
  pushl $0
  10230f:	6a 00                	push   $0x0
  pushl $152
  102311:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102316:	e9 d4 04 00 00       	jmp    1027ef <__alltraps>

0010231b <vector153>:
.globl vector153
vector153:
  pushl $0
  10231b:	6a 00                	push   $0x0
  pushl $153
  10231d:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102322:	e9 c8 04 00 00       	jmp    1027ef <__alltraps>

00102327 <vector154>:
.globl vector154
vector154:
  pushl $0
  102327:	6a 00                	push   $0x0
  pushl $154
  102329:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10232e:	e9 bc 04 00 00       	jmp    1027ef <__alltraps>

00102333 <vector155>:
.globl vector155
vector155:
  pushl $0
  102333:	6a 00                	push   $0x0
  pushl $155
  102335:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  10233a:	e9 b0 04 00 00       	jmp    1027ef <__alltraps>

0010233f <vector156>:
.globl vector156
vector156:
  pushl $0
  10233f:	6a 00                	push   $0x0
  pushl $156
  102341:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102346:	e9 a4 04 00 00       	jmp    1027ef <__alltraps>

0010234b <vector157>:
.globl vector157
vector157:
  pushl $0
  10234b:	6a 00                	push   $0x0
  pushl $157
  10234d:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102352:	e9 98 04 00 00       	jmp    1027ef <__alltraps>

00102357 <vector158>:
.globl vector158
vector158:
  pushl $0
  102357:	6a 00                	push   $0x0
  pushl $158
  102359:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  10235e:	e9 8c 04 00 00       	jmp    1027ef <__alltraps>

00102363 <vector159>:
.globl vector159
vector159:
  pushl $0
  102363:	6a 00                	push   $0x0
  pushl $159
  102365:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10236a:	e9 80 04 00 00       	jmp    1027ef <__alltraps>

0010236f <vector160>:
.globl vector160
vector160:
  pushl $0
  10236f:	6a 00                	push   $0x0
  pushl $160
  102371:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102376:	e9 74 04 00 00       	jmp    1027ef <__alltraps>

0010237b <vector161>:
.globl vector161
vector161:
  pushl $0
  10237b:	6a 00                	push   $0x0
  pushl $161
  10237d:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102382:	e9 68 04 00 00       	jmp    1027ef <__alltraps>

00102387 <vector162>:
.globl vector162
vector162:
  pushl $0
  102387:	6a 00                	push   $0x0
  pushl $162
  102389:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  10238e:	e9 5c 04 00 00       	jmp    1027ef <__alltraps>

00102393 <vector163>:
.globl vector163
vector163:
  pushl $0
  102393:	6a 00                	push   $0x0
  pushl $163
  102395:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10239a:	e9 50 04 00 00       	jmp    1027ef <__alltraps>

0010239f <vector164>:
.globl vector164
vector164:
  pushl $0
  10239f:	6a 00                	push   $0x0
  pushl $164
  1023a1:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1023a6:	e9 44 04 00 00       	jmp    1027ef <__alltraps>

001023ab <vector165>:
.globl vector165
vector165:
  pushl $0
  1023ab:	6a 00                	push   $0x0
  pushl $165
  1023ad:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1023b2:	e9 38 04 00 00       	jmp    1027ef <__alltraps>

001023b7 <vector166>:
.globl vector166
vector166:
  pushl $0
  1023b7:	6a 00                	push   $0x0
  pushl $166
  1023b9:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1023be:	e9 2c 04 00 00       	jmp    1027ef <__alltraps>

001023c3 <vector167>:
.globl vector167
vector167:
  pushl $0
  1023c3:	6a 00                	push   $0x0
  pushl $167
  1023c5:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1023ca:	e9 20 04 00 00       	jmp    1027ef <__alltraps>

001023cf <vector168>:
.globl vector168
vector168:
  pushl $0
  1023cf:	6a 00                	push   $0x0
  pushl $168
  1023d1:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1023d6:	e9 14 04 00 00       	jmp    1027ef <__alltraps>

001023db <vector169>:
.globl vector169
vector169:
  pushl $0
  1023db:	6a 00                	push   $0x0
  pushl $169
  1023dd:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1023e2:	e9 08 04 00 00       	jmp    1027ef <__alltraps>

001023e7 <vector170>:
.globl vector170
vector170:
  pushl $0
  1023e7:	6a 00                	push   $0x0
  pushl $170
  1023e9:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1023ee:	e9 fc 03 00 00       	jmp    1027ef <__alltraps>

001023f3 <vector171>:
.globl vector171
vector171:
  pushl $0
  1023f3:	6a 00                	push   $0x0
  pushl $171
  1023f5:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1023fa:	e9 f0 03 00 00       	jmp    1027ef <__alltraps>

001023ff <vector172>:
.globl vector172
vector172:
  pushl $0
  1023ff:	6a 00                	push   $0x0
  pushl $172
  102401:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102406:	e9 e4 03 00 00       	jmp    1027ef <__alltraps>

0010240b <vector173>:
.globl vector173
vector173:
  pushl $0
  10240b:	6a 00                	push   $0x0
  pushl $173
  10240d:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102412:	e9 d8 03 00 00       	jmp    1027ef <__alltraps>

00102417 <vector174>:
.globl vector174
vector174:
  pushl $0
  102417:	6a 00                	push   $0x0
  pushl $174
  102419:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10241e:	e9 cc 03 00 00       	jmp    1027ef <__alltraps>

00102423 <vector175>:
.globl vector175
vector175:
  pushl $0
  102423:	6a 00                	push   $0x0
  pushl $175
  102425:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10242a:	e9 c0 03 00 00       	jmp    1027ef <__alltraps>

0010242f <vector176>:
.globl vector176
vector176:
  pushl $0
  10242f:	6a 00                	push   $0x0
  pushl $176
  102431:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102436:	e9 b4 03 00 00       	jmp    1027ef <__alltraps>

0010243b <vector177>:
.globl vector177
vector177:
  pushl $0
  10243b:	6a 00                	push   $0x0
  pushl $177
  10243d:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102442:	e9 a8 03 00 00       	jmp    1027ef <__alltraps>

00102447 <vector178>:
.globl vector178
vector178:
  pushl $0
  102447:	6a 00                	push   $0x0
  pushl $178
  102449:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  10244e:	e9 9c 03 00 00       	jmp    1027ef <__alltraps>

00102453 <vector179>:
.globl vector179
vector179:
  pushl $0
  102453:	6a 00                	push   $0x0
  pushl $179
  102455:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10245a:	e9 90 03 00 00       	jmp    1027ef <__alltraps>

0010245f <vector180>:
.globl vector180
vector180:
  pushl $0
  10245f:	6a 00                	push   $0x0
  pushl $180
  102461:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102466:	e9 84 03 00 00       	jmp    1027ef <__alltraps>

0010246b <vector181>:
.globl vector181
vector181:
  pushl $0
  10246b:	6a 00                	push   $0x0
  pushl $181
  10246d:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102472:	e9 78 03 00 00       	jmp    1027ef <__alltraps>

00102477 <vector182>:
.globl vector182
vector182:
  pushl $0
  102477:	6a 00                	push   $0x0
  pushl $182
  102479:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  10247e:	e9 6c 03 00 00       	jmp    1027ef <__alltraps>

00102483 <vector183>:
.globl vector183
vector183:
  pushl $0
  102483:	6a 00                	push   $0x0
  pushl $183
  102485:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10248a:	e9 60 03 00 00       	jmp    1027ef <__alltraps>

0010248f <vector184>:
.globl vector184
vector184:
  pushl $0
  10248f:	6a 00                	push   $0x0
  pushl $184
  102491:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102496:	e9 54 03 00 00       	jmp    1027ef <__alltraps>

0010249b <vector185>:
.globl vector185
vector185:
  pushl $0
  10249b:	6a 00                	push   $0x0
  pushl $185
  10249d:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1024a2:	e9 48 03 00 00       	jmp    1027ef <__alltraps>

001024a7 <vector186>:
.globl vector186
vector186:
  pushl $0
  1024a7:	6a 00                	push   $0x0
  pushl $186
  1024a9:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1024ae:	e9 3c 03 00 00       	jmp    1027ef <__alltraps>

001024b3 <vector187>:
.globl vector187
vector187:
  pushl $0
  1024b3:	6a 00                	push   $0x0
  pushl $187
  1024b5:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1024ba:	e9 30 03 00 00       	jmp    1027ef <__alltraps>

001024bf <vector188>:
.globl vector188
vector188:
  pushl $0
  1024bf:	6a 00                	push   $0x0
  pushl $188
  1024c1:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1024c6:	e9 24 03 00 00       	jmp    1027ef <__alltraps>

001024cb <vector189>:
.globl vector189
vector189:
  pushl $0
  1024cb:	6a 00                	push   $0x0
  pushl $189
  1024cd:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1024d2:	e9 18 03 00 00       	jmp    1027ef <__alltraps>

001024d7 <vector190>:
.globl vector190
vector190:
  pushl $0
  1024d7:	6a 00                	push   $0x0
  pushl $190
  1024d9:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1024de:	e9 0c 03 00 00       	jmp    1027ef <__alltraps>

001024e3 <vector191>:
.globl vector191
vector191:
  pushl $0
  1024e3:	6a 00                	push   $0x0
  pushl $191
  1024e5:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1024ea:	e9 00 03 00 00       	jmp    1027ef <__alltraps>

001024ef <vector192>:
.globl vector192
vector192:
  pushl $0
  1024ef:	6a 00                	push   $0x0
  pushl $192
  1024f1:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1024f6:	e9 f4 02 00 00       	jmp    1027ef <__alltraps>

001024fb <vector193>:
.globl vector193
vector193:
  pushl $0
  1024fb:	6a 00                	push   $0x0
  pushl $193
  1024fd:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102502:	e9 e8 02 00 00       	jmp    1027ef <__alltraps>

00102507 <vector194>:
.globl vector194
vector194:
  pushl $0
  102507:	6a 00                	push   $0x0
  pushl $194
  102509:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10250e:	e9 dc 02 00 00       	jmp    1027ef <__alltraps>

00102513 <vector195>:
.globl vector195
vector195:
  pushl $0
  102513:	6a 00                	push   $0x0
  pushl $195
  102515:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10251a:	e9 d0 02 00 00       	jmp    1027ef <__alltraps>

0010251f <vector196>:
.globl vector196
vector196:
  pushl $0
  10251f:	6a 00                	push   $0x0
  pushl $196
  102521:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102526:	e9 c4 02 00 00       	jmp    1027ef <__alltraps>

0010252b <vector197>:
.globl vector197
vector197:
  pushl $0
  10252b:	6a 00                	push   $0x0
  pushl $197
  10252d:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102532:	e9 b8 02 00 00       	jmp    1027ef <__alltraps>

00102537 <vector198>:
.globl vector198
vector198:
  pushl $0
  102537:	6a 00                	push   $0x0
  pushl $198
  102539:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10253e:	e9 ac 02 00 00       	jmp    1027ef <__alltraps>

00102543 <vector199>:
.globl vector199
vector199:
  pushl $0
  102543:	6a 00                	push   $0x0
  pushl $199
  102545:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  10254a:	e9 a0 02 00 00       	jmp    1027ef <__alltraps>

0010254f <vector200>:
.globl vector200
vector200:
  pushl $0
  10254f:	6a 00                	push   $0x0
  pushl $200
  102551:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102556:	e9 94 02 00 00       	jmp    1027ef <__alltraps>

0010255b <vector201>:
.globl vector201
vector201:
  pushl $0
  10255b:	6a 00                	push   $0x0
  pushl $201
  10255d:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102562:	e9 88 02 00 00       	jmp    1027ef <__alltraps>

00102567 <vector202>:
.globl vector202
vector202:
  pushl $0
  102567:	6a 00                	push   $0x0
  pushl $202
  102569:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  10256e:	e9 7c 02 00 00       	jmp    1027ef <__alltraps>

00102573 <vector203>:
.globl vector203
vector203:
  pushl $0
  102573:	6a 00                	push   $0x0
  pushl $203
  102575:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10257a:	e9 70 02 00 00       	jmp    1027ef <__alltraps>

0010257f <vector204>:
.globl vector204
vector204:
  pushl $0
  10257f:	6a 00                	push   $0x0
  pushl $204
  102581:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102586:	e9 64 02 00 00       	jmp    1027ef <__alltraps>

0010258b <vector205>:
.globl vector205
vector205:
  pushl $0
  10258b:	6a 00                	push   $0x0
  pushl $205
  10258d:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102592:	e9 58 02 00 00       	jmp    1027ef <__alltraps>

00102597 <vector206>:
.globl vector206
vector206:
  pushl $0
  102597:	6a 00                	push   $0x0
  pushl $206
  102599:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  10259e:	e9 4c 02 00 00       	jmp    1027ef <__alltraps>

001025a3 <vector207>:
.globl vector207
vector207:
  pushl $0
  1025a3:	6a 00                	push   $0x0
  pushl $207
  1025a5:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1025aa:	e9 40 02 00 00       	jmp    1027ef <__alltraps>

001025af <vector208>:
.globl vector208
vector208:
  pushl $0
  1025af:	6a 00                	push   $0x0
  pushl $208
  1025b1:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1025b6:	e9 34 02 00 00       	jmp    1027ef <__alltraps>

001025bb <vector209>:
.globl vector209
vector209:
  pushl $0
  1025bb:	6a 00                	push   $0x0
  pushl $209
  1025bd:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1025c2:	e9 28 02 00 00       	jmp    1027ef <__alltraps>

001025c7 <vector210>:
.globl vector210
vector210:
  pushl $0
  1025c7:	6a 00                	push   $0x0
  pushl $210
  1025c9:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1025ce:	e9 1c 02 00 00       	jmp    1027ef <__alltraps>

001025d3 <vector211>:
.globl vector211
vector211:
  pushl $0
  1025d3:	6a 00                	push   $0x0
  pushl $211
  1025d5:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1025da:	e9 10 02 00 00       	jmp    1027ef <__alltraps>

001025df <vector212>:
.globl vector212
vector212:
  pushl $0
  1025df:	6a 00                	push   $0x0
  pushl $212
  1025e1:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1025e6:	e9 04 02 00 00       	jmp    1027ef <__alltraps>

001025eb <vector213>:
.globl vector213
vector213:
  pushl $0
  1025eb:	6a 00                	push   $0x0
  pushl $213
  1025ed:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1025f2:	e9 f8 01 00 00       	jmp    1027ef <__alltraps>

001025f7 <vector214>:
.globl vector214
vector214:
  pushl $0
  1025f7:	6a 00                	push   $0x0
  pushl $214
  1025f9:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1025fe:	e9 ec 01 00 00       	jmp    1027ef <__alltraps>

00102603 <vector215>:
.globl vector215
vector215:
  pushl $0
  102603:	6a 00                	push   $0x0
  pushl $215
  102605:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10260a:	e9 e0 01 00 00       	jmp    1027ef <__alltraps>

0010260f <vector216>:
.globl vector216
vector216:
  pushl $0
  10260f:	6a 00                	push   $0x0
  pushl $216
  102611:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102616:	e9 d4 01 00 00       	jmp    1027ef <__alltraps>

0010261b <vector217>:
.globl vector217
vector217:
  pushl $0
  10261b:	6a 00                	push   $0x0
  pushl $217
  10261d:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102622:	e9 c8 01 00 00       	jmp    1027ef <__alltraps>

00102627 <vector218>:
.globl vector218
vector218:
  pushl $0
  102627:	6a 00                	push   $0x0
  pushl $218
  102629:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  10262e:	e9 bc 01 00 00       	jmp    1027ef <__alltraps>

00102633 <vector219>:
.globl vector219
vector219:
  pushl $0
  102633:	6a 00                	push   $0x0
  pushl $219
  102635:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  10263a:	e9 b0 01 00 00       	jmp    1027ef <__alltraps>

0010263f <vector220>:
.globl vector220
vector220:
  pushl $0
  10263f:	6a 00                	push   $0x0
  pushl $220
  102641:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102646:	e9 a4 01 00 00       	jmp    1027ef <__alltraps>

0010264b <vector221>:
.globl vector221
vector221:
  pushl $0
  10264b:	6a 00                	push   $0x0
  pushl $221
  10264d:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102652:	e9 98 01 00 00       	jmp    1027ef <__alltraps>

00102657 <vector222>:
.globl vector222
vector222:
  pushl $0
  102657:	6a 00                	push   $0x0
  pushl $222
  102659:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  10265e:	e9 8c 01 00 00       	jmp    1027ef <__alltraps>

00102663 <vector223>:
.globl vector223
vector223:
  pushl $0
  102663:	6a 00                	push   $0x0
  pushl $223
  102665:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10266a:	e9 80 01 00 00       	jmp    1027ef <__alltraps>

0010266f <vector224>:
.globl vector224
vector224:
  pushl $0
  10266f:	6a 00                	push   $0x0
  pushl $224
  102671:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102676:	e9 74 01 00 00       	jmp    1027ef <__alltraps>

0010267b <vector225>:
.globl vector225
vector225:
  pushl $0
  10267b:	6a 00                	push   $0x0
  pushl $225
  10267d:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102682:	e9 68 01 00 00       	jmp    1027ef <__alltraps>

00102687 <vector226>:
.globl vector226
vector226:
  pushl $0
  102687:	6a 00                	push   $0x0
  pushl $226
  102689:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  10268e:	e9 5c 01 00 00       	jmp    1027ef <__alltraps>

00102693 <vector227>:
.globl vector227
vector227:
  pushl $0
  102693:	6a 00                	push   $0x0
  pushl $227
  102695:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10269a:	e9 50 01 00 00       	jmp    1027ef <__alltraps>

0010269f <vector228>:
.globl vector228
vector228:
  pushl $0
  10269f:	6a 00                	push   $0x0
  pushl $228
  1026a1:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1026a6:	e9 44 01 00 00       	jmp    1027ef <__alltraps>

001026ab <vector229>:
.globl vector229
vector229:
  pushl $0
  1026ab:	6a 00                	push   $0x0
  pushl $229
  1026ad:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1026b2:	e9 38 01 00 00       	jmp    1027ef <__alltraps>

001026b7 <vector230>:
.globl vector230
vector230:
  pushl $0
  1026b7:	6a 00                	push   $0x0
  pushl $230
  1026b9:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1026be:	e9 2c 01 00 00       	jmp    1027ef <__alltraps>

001026c3 <vector231>:
.globl vector231
vector231:
  pushl $0
  1026c3:	6a 00                	push   $0x0
  pushl $231
  1026c5:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1026ca:	e9 20 01 00 00       	jmp    1027ef <__alltraps>

001026cf <vector232>:
.globl vector232
vector232:
  pushl $0
  1026cf:	6a 00                	push   $0x0
  pushl $232
  1026d1:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1026d6:	e9 14 01 00 00       	jmp    1027ef <__alltraps>

001026db <vector233>:
.globl vector233
vector233:
  pushl $0
  1026db:	6a 00                	push   $0x0
  pushl $233
  1026dd:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1026e2:	e9 08 01 00 00       	jmp    1027ef <__alltraps>

001026e7 <vector234>:
.globl vector234
vector234:
  pushl $0
  1026e7:	6a 00                	push   $0x0
  pushl $234
  1026e9:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1026ee:	e9 fc 00 00 00       	jmp    1027ef <__alltraps>

001026f3 <vector235>:
.globl vector235
vector235:
  pushl $0
  1026f3:	6a 00                	push   $0x0
  pushl $235
  1026f5:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1026fa:	e9 f0 00 00 00       	jmp    1027ef <__alltraps>

001026ff <vector236>:
.globl vector236
vector236:
  pushl $0
  1026ff:	6a 00                	push   $0x0
  pushl $236
  102701:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102706:	e9 e4 00 00 00       	jmp    1027ef <__alltraps>

0010270b <vector237>:
.globl vector237
vector237:
  pushl $0
  10270b:	6a 00                	push   $0x0
  pushl $237
  10270d:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102712:	e9 d8 00 00 00       	jmp    1027ef <__alltraps>

00102717 <vector238>:
.globl vector238
vector238:
  pushl $0
  102717:	6a 00                	push   $0x0
  pushl $238
  102719:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  10271e:	e9 cc 00 00 00       	jmp    1027ef <__alltraps>

00102723 <vector239>:
.globl vector239
vector239:
  pushl $0
  102723:	6a 00                	push   $0x0
  pushl $239
  102725:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  10272a:	e9 c0 00 00 00       	jmp    1027ef <__alltraps>

0010272f <vector240>:
.globl vector240
vector240:
  pushl $0
  10272f:	6a 00                	push   $0x0
  pushl $240
  102731:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102736:	e9 b4 00 00 00       	jmp    1027ef <__alltraps>

0010273b <vector241>:
.globl vector241
vector241:
  pushl $0
  10273b:	6a 00                	push   $0x0
  pushl $241
  10273d:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102742:	e9 a8 00 00 00       	jmp    1027ef <__alltraps>

00102747 <vector242>:
.globl vector242
vector242:
  pushl $0
  102747:	6a 00                	push   $0x0
  pushl $242
  102749:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  10274e:	e9 9c 00 00 00       	jmp    1027ef <__alltraps>

00102753 <vector243>:
.globl vector243
vector243:
  pushl $0
  102753:	6a 00                	push   $0x0
  pushl $243
  102755:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  10275a:	e9 90 00 00 00       	jmp    1027ef <__alltraps>

0010275f <vector244>:
.globl vector244
vector244:
  pushl $0
  10275f:	6a 00                	push   $0x0
  pushl $244
  102761:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102766:	e9 84 00 00 00       	jmp    1027ef <__alltraps>

0010276b <vector245>:
.globl vector245
vector245:
  pushl $0
  10276b:	6a 00                	push   $0x0
  pushl $245
  10276d:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102772:	e9 78 00 00 00       	jmp    1027ef <__alltraps>

00102777 <vector246>:
.globl vector246
vector246:
  pushl $0
  102777:	6a 00                	push   $0x0
  pushl $246
  102779:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  10277e:	e9 6c 00 00 00       	jmp    1027ef <__alltraps>

00102783 <vector247>:
.globl vector247
vector247:
  pushl $0
  102783:	6a 00                	push   $0x0
  pushl $247
  102785:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  10278a:	e9 60 00 00 00       	jmp    1027ef <__alltraps>

0010278f <vector248>:
.globl vector248
vector248:
  pushl $0
  10278f:	6a 00                	push   $0x0
  pushl $248
  102791:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102796:	e9 54 00 00 00       	jmp    1027ef <__alltraps>

0010279b <vector249>:
.globl vector249
vector249:
  pushl $0
  10279b:	6a 00                	push   $0x0
  pushl $249
  10279d:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1027a2:	e9 48 00 00 00       	jmp    1027ef <__alltraps>

001027a7 <vector250>:
.globl vector250
vector250:
  pushl $0
  1027a7:	6a 00                	push   $0x0
  pushl $250
  1027a9:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1027ae:	e9 3c 00 00 00       	jmp    1027ef <__alltraps>

001027b3 <vector251>:
.globl vector251
vector251:
  pushl $0
  1027b3:	6a 00                	push   $0x0
  pushl $251
  1027b5:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1027ba:	e9 30 00 00 00       	jmp    1027ef <__alltraps>

001027bf <vector252>:
.globl vector252
vector252:
  pushl $0
  1027bf:	6a 00                	push   $0x0
  pushl $252
  1027c1:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1027c6:	e9 24 00 00 00       	jmp    1027ef <__alltraps>

001027cb <vector253>:
.globl vector253
vector253:
  pushl $0
  1027cb:	6a 00                	push   $0x0
  pushl $253
  1027cd:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1027d2:	e9 18 00 00 00       	jmp    1027ef <__alltraps>

001027d7 <vector254>:
.globl vector254
vector254:
  pushl $0
  1027d7:	6a 00                	push   $0x0
  pushl $254
  1027d9:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1027de:	e9 0c 00 00 00       	jmp    1027ef <__alltraps>

001027e3 <vector255>:
.globl vector255
vector255:
  pushl $0
  1027e3:	6a 00                	push   $0x0
  pushl $255
  1027e5:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1027ea:	e9 00 00 00 00       	jmp    1027ef <__alltraps>

001027ef <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  1027ef:	1e                   	push   %ds
    pushl %es
  1027f0:	06                   	push   %es
    pushl %fs
  1027f1:	0f a0                	push   %fs
    pushl %gs
  1027f3:	0f a8                	push   %gs
    pushal
  1027f5:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  1027f6:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  1027fb:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  1027fd:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  1027ff:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102800:	e8 61 f5 ff ff       	call   101d66 <trap>

    # pop the pushed stack pointer
    popl %esp
  102805:	5c                   	pop    %esp

00102806 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102806:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102807:	0f a9                	pop    %gs
    popl %fs
  102809:	0f a1                	pop    %fs
    popl %es
  10280b:	07                   	pop    %es
    popl %ds
  10280c:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  10280d:	83 c4 08             	add    $0x8,%esp
    iret
  102810:	cf                   	iret   

00102811 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102811:	55                   	push   %ebp
  102812:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102814:	8b 45 08             	mov    0x8(%ebp),%eax
  102817:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  10281a:	b8 23 00 00 00       	mov    $0x23,%eax
  10281f:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102821:	b8 23 00 00 00       	mov    $0x23,%eax
  102826:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102828:	b8 10 00 00 00       	mov    $0x10,%eax
  10282d:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  10282f:	b8 10 00 00 00       	mov    $0x10,%eax
  102834:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102836:	b8 10 00 00 00       	mov    $0x10,%eax
  10283b:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  10283d:	ea 44 28 10 00 08 00 	ljmp   $0x8,$0x102844
}
  102844:	90                   	nop
  102845:	5d                   	pop    %ebp
  102846:	c3                   	ret    

00102847 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102847:	55                   	push   %ebp
  102848:	89 e5                	mov    %esp,%ebp
  10284a:	83 ec 10             	sub    $0x10,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  10284d:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  102852:	05 00 04 00 00       	add    $0x400,%eax
  102857:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  10285c:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  102863:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  102865:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  10286c:	68 00 
  10286e:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102873:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  102879:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  10287e:	c1 e8 10             	shr    $0x10,%eax
  102881:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  102886:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10288d:	83 e0 f0             	and    $0xfffffff0,%eax
  102890:	83 c8 09             	or     $0x9,%eax
  102893:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102898:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10289f:	83 c8 10             	or     $0x10,%eax
  1028a2:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028a7:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1028ae:	83 e0 9f             	and    $0xffffff9f,%eax
  1028b1:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028b6:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1028bd:	83 c8 80             	or     $0xffffff80,%eax
  1028c0:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028c5:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028cc:	83 e0 f0             	and    $0xfffffff0,%eax
  1028cf:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028d4:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028db:	83 e0 ef             	and    $0xffffffef,%eax
  1028de:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028e3:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028ea:	83 e0 df             	and    $0xffffffdf,%eax
  1028ed:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028f2:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028f9:	83 c8 40             	or     $0x40,%eax
  1028fc:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102901:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102908:	83 e0 7f             	and    $0x7f,%eax
  10290b:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102910:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102915:	c1 e8 18             	shr    $0x18,%eax
  102918:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  10291d:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102924:	83 e0 ef             	and    $0xffffffef,%eax
  102927:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  10292c:	68 10 ea 10 00       	push   $0x10ea10
  102931:	e8 db fe ff ff       	call   102811 <lgdt>
  102936:	83 c4 04             	add    $0x4,%esp
  102939:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  10293f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102943:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102946:	90                   	nop
  102947:	c9                   	leave  
  102948:	c3                   	ret    

00102949 <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102949:	55                   	push   %ebp
  10294a:	89 e5                	mov    %esp,%ebp
    gdt_init();
  10294c:	e8 f6 fe ff ff       	call   102847 <gdt_init>
}
  102951:	90                   	nop
  102952:	5d                   	pop    %ebp
  102953:	c3                   	ret    

00102954 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102954:	55                   	push   %ebp
  102955:	89 e5                	mov    %esp,%ebp
  102957:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10295a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102961:	eb 04                	jmp    102967 <strlen+0x13>
        cnt ++;
  102963:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  102967:	8b 45 08             	mov    0x8(%ebp),%eax
  10296a:	8d 50 01             	lea    0x1(%eax),%edx
  10296d:	89 55 08             	mov    %edx,0x8(%ebp)
  102970:	0f b6 00             	movzbl (%eax),%eax
  102973:	84 c0                	test   %al,%al
  102975:	75 ec                	jne    102963 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  102977:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10297a:	c9                   	leave  
  10297b:	c3                   	ret    

0010297c <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  10297c:	55                   	push   %ebp
  10297d:	89 e5                	mov    %esp,%ebp
  10297f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102982:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102989:	eb 04                	jmp    10298f <strnlen+0x13>
        cnt ++;
  10298b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  10298f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102992:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102995:	73 10                	jae    1029a7 <strnlen+0x2b>
  102997:	8b 45 08             	mov    0x8(%ebp),%eax
  10299a:	8d 50 01             	lea    0x1(%eax),%edx
  10299d:	89 55 08             	mov    %edx,0x8(%ebp)
  1029a0:	0f b6 00             	movzbl (%eax),%eax
  1029a3:	84 c0                	test   %al,%al
  1029a5:	75 e4                	jne    10298b <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  1029a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1029aa:	c9                   	leave  
  1029ab:	c3                   	ret    

001029ac <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1029ac:	55                   	push   %ebp
  1029ad:	89 e5                	mov    %esp,%ebp
  1029af:	57                   	push   %edi
  1029b0:	56                   	push   %esi
  1029b1:	83 ec 20             	sub    $0x20,%esp
  1029b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1029b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1029ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  1029bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1029c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1029c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029c6:	89 d1                	mov    %edx,%ecx
  1029c8:	89 c2                	mov    %eax,%edx
  1029ca:	89 ce                	mov    %ecx,%esi
  1029cc:	89 d7                	mov    %edx,%edi
  1029ce:	ac                   	lods   %ds:(%esi),%al
  1029cf:	aa                   	stos   %al,%es:(%edi)
  1029d0:	84 c0                	test   %al,%al
  1029d2:	75 fa                	jne    1029ce <strcpy+0x22>
  1029d4:	89 fa                	mov    %edi,%edx
  1029d6:	89 f1                	mov    %esi,%ecx
  1029d8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1029db:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1029de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  1029e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  1029e4:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1029e5:	83 c4 20             	add    $0x20,%esp
  1029e8:	5e                   	pop    %esi
  1029e9:	5f                   	pop    %edi
  1029ea:	5d                   	pop    %ebp
  1029eb:	c3                   	ret    

001029ec <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1029ec:	55                   	push   %ebp
  1029ed:	89 e5                	mov    %esp,%ebp
  1029ef:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1029f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1029f8:	eb 21                	jmp    102a1b <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  1029fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1029fd:	0f b6 10             	movzbl (%eax),%edx
  102a00:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102a03:	88 10                	mov    %dl,(%eax)
  102a05:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102a08:	0f b6 00             	movzbl (%eax),%eax
  102a0b:	84 c0                	test   %al,%al
  102a0d:	74 04                	je     102a13 <strncpy+0x27>
            src ++;
  102a0f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  102a13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102a17:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  102a1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102a1f:	75 d9                	jne    1029fa <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  102a21:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102a24:	c9                   	leave  
  102a25:	c3                   	ret    

00102a26 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102a26:	55                   	push   %ebp
  102a27:	89 e5                	mov    %esp,%ebp
  102a29:	57                   	push   %edi
  102a2a:	56                   	push   %esi
  102a2b:	83 ec 20             	sub    $0x20,%esp
  102a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  102a31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a37:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  102a3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a40:	89 d1                	mov    %edx,%ecx
  102a42:	89 c2                	mov    %eax,%edx
  102a44:	89 ce                	mov    %ecx,%esi
  102a46:	89 d7                	mov    %edx,%edi
  102a48:	ac                   	lods   %ds:(%esi),%al
  102a49:	ae                   	scas   %es:(%edi),%al
  102a4a:	75 08                	jne    102a54 <strcmp+0x2e>
  102a4c:	84 c0                	test   %al,%al
  102a4e:	75 f8                	jne    102a48 <strcmp+0x22>
  102a50:	31 c0                	xor    %eax,%eax
  102a52:	eb 04                	jmp    102a58 <strcmp+0x32>
  102a54:	19 c0                	sbb    %eax,%eax
  102a56:	0c 01                	or     $0x1,%al
  102a58:	89 fa                	mov    %edi,%edx
  102a5a:	89 f1                	mov    %esi,%ecx
  102a5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102a5f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102a62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            "orb $1, %%al;"
            "3:"
            : "=a" (ret), "=&S" (d0), "=&D" (d1)
            : "1" (s1), "2" (s2)
            : "memory");
    return ret;
  102a65:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  102a68:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102a69:	83 c4 20             	add    $0x20,%esp
  102a6c:	5e                   	pop    %esi
  102a6d:	5f                   	pop    %edi
  102a6e:	5d                   	pop    %ebp
  102a6f:	c3                   	ret    

00102a70 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102a70:	55                   	push   %ebp
  102a71:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102a73:	eb 0c                	jmp    102a81 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  102a75:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102a79:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102a7d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102a81:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102a85:	74 1a                	je     102aa1 <strncmp+0x31>
  102a87:	8b 45 08             	mov    0x8(%ebp),%eax
  102a8a:	0f b6 00             	movzbl (%eax),%eax
  102a8d:	84 c0                	test   %al,%al
  102a8f:	74 10                	je     102aa1 <strncmp+0x31>
  102a91:	8b 45 08             	mov    0x8(%ebp),%eax
  102a94:	0f b6 10             	movzbl (%eax),%edx
  102a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a9a:	0f b6 00             	movzbl (%eax),%eax
  102a9d:	38 c2                	cmp    %al,%dl
  102a9f:	74 d4                	je     102a75 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102aa1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102aa5:	74 18                	je     102abf <strncmp+0x4f>
  102aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  102aaa:	0f b6 00             	movzbl (%eax),%eax
  102aad:	0f b6 d0             	movzbl %al,%edx
  102ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ab3:	0f b6 00             	movzbl (%eax),%eax
  102ab6:	0f b6 c0             	movzbl %al,%eax
  102ab9:	29 c2                	sub    %eax,%edx
  102abb:	89 d0                	mov    %edx,%eax
  102abd:	eb 05                	jmp    102ac4 <strncmp+0x54>
  102abf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102ac4:	5d                   	pop    %ebp
  102ac5:	c3                   	ret    

00102ac6 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102ac6:	55                   	push   %ebp
  102ac7:	89 e5                	mov    %esp,%ebp
  102ac9:	83 ec 04             	sub    $0x4,%esp
  102acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  102acf:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102ad2:	eb 14                	jmp    102ae8 <strchr+0x22>
        if (*s == c) {
  102ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  102ad7:	0f b6 00             	movzbl (%eax),%eax
  102ada:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102add:	75 05                	jne    102ae4 <strchr+0x1e>
            return (char *)s;
  102adf:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae2:	eb 13                	jmp    102af7 <strchr+0x31>
        }
        s ++;
  102ae4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  102ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  102aeb:	0f b6 00             	movzbl (%eax),%eax
  102aee:	84 c0                	test   %al,%al
  102af0:	75 e2                	jne    102ad4 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  102af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102af7:	c9                   	leave  
  102af8:	c3                   	ret    

00102af9 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102af9:	55                   	push   %ebp
  102afa:	89 e5                	mov    %esp,%ebp
  102afc:	83 ec 04             	sub    $0x4,%esp
  102aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b02:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102b05:	eb 0f                	jmp    102b16 <strfind+0x1d>
        if (*s == c) {
  102b07:	8b 45 08             	mov    0x8(%ebp),%eax
  102b0a:	0f b6 00             	movzbl (%eax),%eax
  102b0d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102b10:	74 10                	je     102b22 <strfind+0x29>
            break;
        }
        s ++;
  102b12:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  102b16:	8b 45 08             	mov    0x8(%ebp),%eax
  102b19:	0f b6 00             	movzbl (%eax),%eax
  102b1c:	84 c0                	test   %al,%al
  102b1e:	75 e7                	jne    102b07 <strfind+0xe>
  102b20:	eb 01                	jmp    102b23 <strfind+0x2a>
        if (*s == c) {
            break;
  102b22:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  102b23:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102b26:	c9                   	leave  
  102b27:	c3                   	ret    

00102b28 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  102b28:	55                   	push   %ebp
  102b29:	89 e5                	mov    %esp,%ebp
  102b2b:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  102b2e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  102b35:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102b3c:	eb 04                	jmp    102b42 <strtol+0x1a>
        s ++;
  102b3e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102b42:	8b 45 08             	mov    0x8(%ebp),%eax
  102b45:	0f b6 00             	movzbl (%eax),%eax
  102b48:	3c 20                	cmp    $0x20,%al
  102b4a:	74 f2                	je     102b3e <strtol+0x16>
  102b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b4f:	0f b6 00             	movzbl (%eax),%eax
  102b52:	3c 09                	cmp    $0x9,%al
  102b54:	74 e8                	je     102b3e <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  102b56:	8b 45 08             	mov    0x8(%ebp),%eax
  102b59:	0f b6 00             	movzbl (%eax),%eax
  102b5c:	3c 2b                	cmp    $0x2b,%al
  102b5e:	75 06                	jne    102b66 <strtol+0x3e>
        s ++;
  102b60:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102b64:	eb 15                	jmp    102b7b <strtol+0x53>
    }
    else if (*s == '-') {
  102b66:	8b 45 08             	mov    0x8(%ebp),%eax
  102b69:	0f b6 00             	movzbl (%eax),%eax
  102b6c:	3c 2d                	cmp    $0x2d,%al
  102b6e:	75 0b                	jne    102b7b <strtol+0x53>
        s ++, neg = 1;
  102b70:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102b74:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102b7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102b7f:	74 06                	je     102b87 <strtol+0x5f>
  102b81:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102b85:	75 24                	jne    102bab <strtol+0x83>
  102b87:	8b 45 08             	mov    0x8(%ebp),%eax
  102b8a:	0f b6 00             	movzbl (%eax),%eax
  102b8d:	3c 30                	cmp    $0x30,%al
  102b8f:	75 1a                	jne    102bab <strtol+0x83>
  102b91:	8b 45 08             	mov    0x8(%ebp),%eax
  102b94:	83 c0 01             	add    $0x1,%eax
  102b97:	0f b6 00             	movzbl (%eax),%eax
  102b9a:	3c 78                	cmp    $0x78,%al
  102b9c:	75 0d                	jne    102bab <strtol+0x83>
        s += 2, base = 16;
  102b9e:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  102ba2:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102ba9:	eb 2a                	jmp    102bd5 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  102bab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102baf:	75 17                	jne    102bc8 <strtol+0xa0>
  102bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  102bb4:	0f b6 00             	movzbl (%eax),%eax
  102bb7:	3c 30                	cmp    $0x30,%al
  102bb9:	75 0d                	jne    102bc8 <strtol+0xa0>
        s ++, base = 8;
  102bbb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102bbf:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102bc6:	eb 0d                	jmp    102bd5 <strtol+0xad>
    }
    else if (base == 0) {
  102bc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102bcc:	75 07                	jne    102bd5 <strtol+0xad>
        base = 10;
  102bce:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  102bd8:	0f b6 00             	movzbl (%eax),%eax
  102bdb:	3c 2f                	cmp    $0x2f,%al
  102bdd:	7e 1b                	jle    102bfa <strtol+0xd2>
  102bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  102be2:	0f b6 00             	movzbl (%eax),%eax
  102be5:	3c 39                	cmp    $0x39,%al
  102be7:	7f 11                	jg     102bfa <strtol+0xd2>
            dig = *s - '0';
  102be9:	8b 45 08             	mov    0x8(%ebp),%eax
  102bec:	0f b6 00             	movzbl (%eax),%eax
  102bef:	0f be c0             	movsbl %al,%eax
  102bf2:	83 e8 30             	sub    $0x30,%eax
  102bf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102bf8:	eb 48                	jmp    102c42 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  102bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  102bfd:	0f b6 00             	movzbl (%eax),%eax
  102c00:	3c 60                	cmp    $0x60,%al
  102c02:	7e 1b                	jle    102c1f <strtol+0xf7>
  102c04:	8b 45 08             	mov    0x8(%ebp),%eax
  102c07:	0f b6 00             	movzbl (%eax),%eax
  102c0a:	3c 7a                	cmp    $0x7a,%al
  102c0c:	7f 11                	jg     102c1f <strtol+0xf7>
            dig = *s - 'a' + 10;
  102c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  102c11:	0f b6 00             	movzbl (%eax),%eax
  102c14:	0f be c0             	movsbl %al,%eax
  102c17:	83 e8 57             	sub    $0x57,%eax
  102c1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102c1d:	eb 23                	jmp    102c42 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  102c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  102c22:	0f b6 00             	movzbl (%eax),%eax
  102c25:	3c 40                	cmp    $0x40,%al
  102c27:	7e 3c                	jle    102c65 <strtol+0x13d>
  102c29:	8b 45 08             	mov    0x8(%ebp),%eax
  102c2c:	0f b6 00             	movzbl (%eax),%eax
  102c2f:	3c 5a                	cmp    $0x5a,%al
  102c31:	7f 32                	jg     102c65 <strtol+0x13d>
            dig = *s - 'A' + 10;
  102c33:	8b 45 08             	mov    0x8(%ebp),%eax
  102c36:	0f b6 00             	movzbl (%eax),%eax
  102c39:	0f be c0             	movsbl %al,%eax
  102c3c:	83 e8 37             	sub    $0x37,%eax
  102c3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  102c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c45:	3b 45 10             	cmp    0x10(%ebp),%eax
  102c48:	7d 1a                	jge    102c64 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
  102c4a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102c4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102c51:	0f af 45 10          	imul   0x10(%ebp),%eax
  102c55:	89 c2                	mov    %eax,%edx
  102c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c5a:	01 d0                	add    %edx,%eax
  102c5c:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  102c5f:	e9 71 ff ff ff       	jmp    102bd5 <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  102c64:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  102c65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102c69:	74 08                	je     102c73 <strtol+0x14b>
        *endptr = (char *) s;
  102c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  102c71:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  102c73:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  102c77:	74 07                	je     102c80 <strtol+0x158>
  102c79:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102c7c:	f7 d8                	neg    %eax
  102c7e:	eb 03                	jmp    102c83 <strtol+0x15b>
  102c80:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  102c83:	c9                   	leave  
  102c84:	c3                   	ret    

00102c85 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  102c85:	55                   	push   %ebp
  102c86:	89 e5                	mov    %esp,%ebp
  102c88:	57                   	push   %edi
  102c89:	83 ec 24             	sub    $0x24,%esp
  102c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c8f:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  102c92:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  102c96:	8b 55 08             	mov    0x8(%ebp),%edx
  102c99:	89 55 f8             	mov    %edx,-0x8(%ebp)
  102c9c:	88 45 f7             	mov    %al,-0x9(%ebp)
  102c9f:	8b 45 10             	mov    0x10(%ebp),%eax
  102ca2:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  102ca5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  102ca8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  102cac:	8b 55 f8             	mov    -0x8(%ebp),%edx
  102caf:	89 d7                	mov    %edx,%edi
  102cb1:	f3 aa                	rep stos %al,%es:(%edi)
  102cb3:	89 fa                	mov    %edi,%edx
  102cb5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102cb8:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  102cbb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102cbe:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  102cbf:	83 c4 24             	add    $0x24,%esp
  102cc2:	5f                   	pop    %edi
  102cc3:	5d                   	pop    %ebp
  102cc4:	c3                   	ret    

00102cc5 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  102cc5:	55                   	push   %ebp
  102cc6:	89 e5                	mov    %esp,%ebp
  102cc8:	57                   	push   %edi
  102cc9:	56                   	push   %esi
  102cca:	53                   	push   %ebx
  102ccb:	83 ec 30             	sub    $0x30,%esp
  102cce:	8b 45 08             	mov    0x8(%ebp),%eax
  102cd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102cda:	8b 45 10             	mov    0x10(%ebp),%eax
  102cdd:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  102ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ce3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102ce6:	73 42                	jae    102d2a <memmove+0x65>
  102ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ceb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102cee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102cf1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102cf4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102cf7:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102cfa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102cfd:	c1 e8 02             	shr    $0x2,%eax
  102d00:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  102d02:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d05:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d08:	89 d7                	mov    %edx,%edi
  102d0a:	89 c6                	mov    %eax,%esi
  102d0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102d0e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  102d11:	83 e1 03             	and    $0x3,%ecx
  102d14:	74 02                	je     102d18 <memmove+0x53>
  102d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102d18:	89 f0                	mov    %esi,%eax
  102d1a:	89 fa                	mov    %edi,%edx
  102d1c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  102d1f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102d22:	89 45 d0             	mov    %eax,-0x30(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  102d25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  102d28:	eb 36                	jmp    102d60 <memmove+0x9b>
    asm volatile (
            "std;"
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  102d2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d2d:	8d 50 ff             	lea    -0x1(%eax),%edx
  102d30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d33:	01 c2                	add    %eax,%edx
  102d35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d38:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d3e:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  102d41:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d44:	89 c1                	mov    %eax,%ecx
  102d46:	89 d8                	mov    %ebx,%eax
  102d48:	89 d6                	mov    %edx,%esi
  102d4a:	89 c7                	mov    %eax,%edi
  102d4c:	fd                   	std    
  102d4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102d4f:	fc                   	cld    
  102d50:	89 f8                	mov    %edi,%eax
  102d52:	89 f2                	mov    %esi,%edx
  102d54:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  102d57:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102d5a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
            : "memory");
    return dst;
  102d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  102d60:	83 c4 30             	add    $0x30,%esp
  102d63:	5b                   	pop    %ebx
  102d64:	5e                   	pop    %esi
  102d65:	5f                   	pop    %edi
  102d66:	5d                   	pop    %ebp
  102d67:	c3                   	ret    

00102d68 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  102d68:	55                   	push   %ebp
  102d69:	89 e5                	mov    %esp,%ebp
  102d6b:	57                   	push   %edi
  102d6c:	56                   	push   %esi
  102d6d:	83 ec 20             	sub    $0x20,%esp
  102d70:	8b 45 08             	mov    0x8(%ebp),%eax
  102d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102d7c:	8b 45 10             	mov    0x10(%ebp),%eax
  102d7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d85:	c1 e8 02             	shr    $0x2,%eax
  102d88:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  102d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d90:	89 d7                	mov    %edx,%edi
  102d92:	89 c6                	mov    %eax,%esi
  102d94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102d96:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  102d99:	83 e1 03             	and    $0x3,%ecx
  102d9c:	74 02                	je     102da0 <memcpy+0x38>
  102d9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102da0:	89 f0                	mov    %esi,%eax
  102da2:	89 fa                	mov    %edi,%edx
  102da4:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102da7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  102daa:	89 45 e0             	mov    %eax,-0x20(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  102dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  102db0:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  102db1:	83 c4 20             	add    $0x20,%esp
  102db4:	5e                   	pop    %esi
  102db5:	5f                   	pop    %edi
  102db6:	5d                   	pop    %ebp
  102db7:	c3                   	ret    

00102db8 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  102db8:	55                   	push   %ebp
  102db9:	89 e5                	mov    %esp,%ebp
  102dbb:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  102dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  102dc1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  102dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dc7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  102dca:	eb 30                	jmp    102dfc <memcmp+0x44>
        if (*s1 != *s2) {
  102dcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102dcf:	0f b6 10             	movzbl (%eax),%edx
  102dd2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102dd5:	0f b6 00             	movzbl (%eax),%eax
  102dd8:	38 c2                	cmp    %al,%dl
  102dda:	74 18                	je     102df4 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  102ddc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ddf:	0f b6 00             	movzbl (%eax),%eax
  102de2:	0f b6 d0             	movzbl %al,%edx
  102de5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102de8:	0f b6 00             	movzbl (%eax),%eax
  102deb:	0f b6 c0             	movzbl %al,%eax
  102dee:	29 c2                	sub    %eax,%edx
  102df0:	89 d0                	mov    %edx,%eax
  102df2:	eb 1a                	jmp    102e0e <memcmp+0x56>
        }
        s1 ++, s2 ++;
  102df4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102df8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  102dfc:	8b 45 10             	mov    0x10(%ebp),%eax
  102dff:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e02:	89 55 10             	mov    %edx,0x10(%ebp)
  102e05:	85 c0                	test   %eax,%eax
  102e07:	75 c3                	jne    102dcc <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  102e09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102e0e:	c9                   	leave  
  102e0f:	c3                   	ret    

00102e10 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102e10:	55                   	push   %ebp
  102e11:	89 e5                	mov    %esp,%ebp
  102e13:	83 ec 38             	sub    $0x38,%esp
  102e16:	8b 45 10             	mov    0x10(%ebp),%eax
  102e19:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102e1c:	8b 45 14             	mov    0x14(%ebp),%eax
  102e1f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102e22:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102e25:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e28:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102e2b:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102e2e:	8b 45 18             	mov    0x18(%ebp),%eax
  102e31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102e34:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e37:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102e3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102e3d:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102e46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102e4a:	74 1c                	je     102e68 <printnum+0x58>
  102e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e4f:	ba 00 00 00 00       	mov    $0x0,%edx
  102e54:	f7 75 e4             	divl   -0x1c(%ebp)
  102e57:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e5d:	ba 00 00 00 00       	mov    $0x0,%edx
  102e62:	f7 75 e4             	divl   -0x1c(%ebp)
  102e65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e68:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e6e:	f7 75 e4             	divl   -0x1c(%ebp)
  102e71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102e74:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102e77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e7a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102e7d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102e80:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102e83:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102e86:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102e89:	8b 45 18             	mov    0x18(%ebp),%eax
  102e8c:	ba 00 00 00 00       	mov    $0x0,%edx
  102e91:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102e94:	77 41                	ja     102ed7 <printnum+0xc7>
  102e96:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102e99:	72 05                	jb     102ea0 <printnum+0x90>
  102e9b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102e9e:	77 37                	ja     102ed7 <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
  102ea0:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102ea3:	83 e8 01             	sub    $0x1,%eax
  102ea6:	83 ec 04             	sub    $0x4,%esp
  102ea9:	ff 75 20             	pushl  0x20(%ebp)
  102eac:	50                   	push   %eax
  102ead:	ff 75 18             	pushl  0x18(%ebp)
  102eb0:	ff 75 ec             	pushl  -0x14(%ebp)
  102eb3:	ff 75 e8             	pushl  -0x18(%ebp)
  102eb6:	ff 75 0c             	pushl  0xc(%ebp)
  102eb9:	ff 75 08             	pushl  0x8(%ebp)
  102ebc:	e8 4f ff ff ff       	call   102e10 <printnum>
  102ec1:	83 c4 20             	add    $0x20,%esp
  102ec4:	eb 1b                	jmp    102ee1 <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102ec6:	83 ec 08             	sub    $0x8,%esp
  102ec9:	ff 75 0c             	pushl  0xc(%ebp)
  102ecc:	ff 75 20             	pushl  0x20(%ebp)
  102ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  102ed2:	ff d0                	call   *%eax
  102ed4:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  102ed7:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  102edb:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102edf:	7f e5                	jg     102ec6 <printnum+0xb6>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102ee1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102ee4:	05 d0 3b 10 00       	add    $0x103bd0,%eax
  102ee9:	0f b6 00             	movzbl (%eax),%eax
  102eec:	0f be c0             	movsbl %al,%eax
  102eef:	83 ec 08             	sub    $0x8,%esp
  102ef2:	ff 75 0c             	pushl  0xc(%ebp)
  102ef5:	50                   	push   %eax
  102ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  102ef9:	ff d0                	call   *%eax
  102efb:	83 c4 10             	add    $0x10,%esp
}
  102efe:	90                   	nop
  102eff:	c9                   	leave  
  102f00:	c3                   	ret    

00102f01 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102f01:	55                   	push   %ebp
  102f02:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102f04:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102f08:	7e 14                	jle    102f1e <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  102f0d:	8b 00                	mov    (%eax),%eax
  102f0f:	8d 48 08             	lea    0x8(%eax),%ecx
  102f12:	8b 55 08             	mov    0x8(%ebp),%edx
  102f15:	89 0a                	mov    %ecx,(%edx)
  102f17:	8b 50 04             	mov    0x4(%eax),%edx
  102f1a:	8b 00                	mov    (%eax),%eax
  102f1c:	eb 30                	jmp    102f4e <getuint+0x4d>
    }
    else if (lflag) {
  102f1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102f22:	74 16                	je     102f3a <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102f24:	8b 45 08             	mov    0x8(%ebp),%eax
  102f27:	8b 00                	mov    (%eax),%eax
  102f29:	8d 48 04             	lea    0x4(%eax),%ecx
  102f2c:	8b 55 08             	mov    0x8(%ebp),%edx
  102f2f:	89 0a                	mov    %ecx,(%edx)
  102f31:	8b 00                	mov    (%eax),%eax
  102f33:	ba 00 00 00 00       	mov    $0x0,%edx
  102f38:	eb 14                	jmp    102f4e <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102f3a:	8b 45 08             	mov    0x8(%ebp),%eax
  102f3d:	8b 00                	mov    (%eax),%eax
  102f3f:	8d 48 04             	lea    0x4(%eax),%ecx
  102f42:	8b 55 08             	mov    0x8(%ebp),%edx
  102f45:	89 0a                	mov    %ecx,(%edx)
  102f47:	8b 00                	mov    (%eax),%eax
  102f49:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102f4e:	5d                   	pop    %ebp
  102f4f:	c3                   	ret    

00102f50 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102f50:	55                   	push   %ebp
  102f51:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102f53:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102f57:	7e 14                	jle    102f6d <getint+0x1d>
        return va_arg(*ap, long long);
  102f59:	8b 45 08             	mov    0x8(%ebp),%eax
  102f5c:	8b 00                	mov    (%eax),%eax
  102f5e:	8d 48 08             	lea    0x8(%eax),%ecx
  102f61:	8b 55 08             	mov    0x8(%ebp),%edx
  102f64:	89 0a                	mov    %ecx,(%edx)
  102f66:	8b 50 04             	mov    0x4(%eax),%edx
  102f69:	8b 00                	mov    (%eax),%eax
  102f6b:	eb 28                	jmp    102f95 <getint+0x45>
    }
    else if (lflag) {
  102f6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102f71:	74 12                	je     102f85 <getint+0x35>
        return va_arg(*ap, long);
  102f73:	8b 45 08             	mov    0x8(%ebp),%eax
  102f76:	8b 00                	mov    (%eax),%eax
  102f78:	8d 48 04             	lea    0x4(%eax),%ecx
  102f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  102f7e:	89 0a                	mov    %ecx,(%edx)
  102f80:	8b 00                	mov    (%eax),%eax
  102f82:	99                   	cltd   
  102f83:	eb 10                	jmp    102f95 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102f85:	8b 45 08             	mov    0x8(%ebp),%eax
  102f88:	8b 00                	mov    (%eax),%eax
  102f8a:	8d 48 04             	lea    0x4(%eax),%ecx
  102f8d:	8b 55 08             	mov    0x8(%ebp),%edx
  102f90:	89 0a                	mov    %ecx,(%edx)
  102f92:	8b 00                	mov    (%eax),%eax
  102f94:	99                   	cltd   
    }
}
  102f95:	5d                   	pop    %ebp
  102f96:	c3                   	ret    

00102f97 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102f97:	55                   	push   %ebp
  102f98:	89 e5                	mov    %esp,%ebp
  102f9a:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  102f9d:	8d 45 14             	lea    0x14(%ebp),%eax
  102fa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fa6:	50                   	push   %eax
  102fa7:	ff 75 10             	pushl  0x10(%ebp)
  102faa:	ff 75 0c             	pushl  0xc(%ebp)
  102fad:	ff 75 08             	pushl  0x8(%ebp)
  102fb0:	e8 06 00 00 00       	call   102fbb <vprintfmt>
  102fb5:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  102fb8:	90                   	nop
  102fb9:	c9                   	leave  
  102fba:	c3                   	ret    

00102fbb <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102fbb:	55                   	push   %ebp
  102fbc:	89 e5                	mov    %esp,%ebp
  102fbe:	56                   	push   %esi
  102fbf:	53                   	push   %ebx
  102fc0:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102fc3:	eb 17                	jmp    102fdc <vprintfmt+0x21>
            if (ch == '\0') {
  102fc5:	85 db                	test   %ebx,%ebx
  102fc7:	0f 84 8e 03 00 00    	je     10335b <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
  102fcd:	83 ec 08             	sub    $0x8,%esp
  102fd0:	ff 75 0c             	pushl  0xc(%ebp)
  102fd3:	53                   	push   %ebx
  102fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  102fd7:	ff d0                	call   *%eax
  102fd9:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102fdc:	8b 45 10             	mov    0x10(%ebp),%eax
  102fdf:	8d 50 01             	lea    0x1(%eax),%edx
  102fe2:	89 55 10             	mov    %edx,0x10(%ebp)
  102fe5:	0f b6 00             	movzbl (%eax),%eax
  102fe8:	0f b6 d8             	movzbl %al,%ebx
  102feb:	83 fb 25             	cmp    $0x25,%ebx
  102fee:	75 d5                	jne    102fc5 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  102ff0:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  102ff4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  102ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102ffe:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  103001:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103008:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10300b:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  10300e:	8b 45 10             	mov    0x10(%ebp),%eax
  103011:	8d 50 01             	lea    0x1(%eax),%edx
  103014:	89 55 10             	mov    %edx,0x10(%ebp)
  103017:	0f b6 00             	movzbl (%eax),%eax
  10301a:	0f b6 d8             	movzbl %al,%ebx
  10301d:	8d 43 dd             	lea    -0x23(%ebx),%eax
  103020:	83 f8 55             	cmp    $0x55,%eax
  103023:	0f 87 05 03 00 00    	ja     10332e <vprintfmt+0x373>
  103029:	8b 04 85 f4 3b 10 00 	mov    0x103bf4(,%eax,4),%eax
  103030:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  103032:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  103036:	eb d6                	jmp    10300e <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  103038:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10303c:	eb d0                	jmp    10300e <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10303e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  103045:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103048:	89 d0                	mov    %edx,%eax
  10304a:	c1 e0 02             	shl    $0x2,%eax
  10304d:	01 d0                	add    %edx,%eax
  10304f:	01 c0                	add    %eax,%eax
  103051:	01 d8                	add    %ebx,%eax
  103053:	83 e8 30             	sub    $0x30,%eax
  103056:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  103059:	8b 45 10             	mov    0x10(%ebp),%eax
  10305c:	0f b6 00             	movzbl (%eax),%eax
  10305f:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  103062:	83 fb 2f             	cmp    $0x2f,%ebx
  103065:	7e 39                	jle    1030a0 <vprintfmt+0xe5>
  103067:	83 fb 39             	cmp    $0x39,%ebx
  10306a:	7f 34                	jg     1030a0 <vprintfmt+0xe5>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10306c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  103070:	eb d3                	jmp    103045 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  103072:	8b 45 14             	mov    0x14(%ebp),%eax
  103075:	8d 50 04             	lea    0x4(%eax),%edx
  103078:	89 55 14             	mov    %edx,0x14(%ebp)
  10307b:	8b 00                	mov    (%eax),%eax
  10307d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  103080:	eb 1f                	jmp    1030a1 <vprintfmt+0xe6>

        case '.':
            if (width < 0)
  103082:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103086:	79 86                	jns    10300e <vprintfmt+0x53>
                width = 0;
  103088:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  10308f:	e9 7a ff ff ff       	jmp    10300e <vprintfmt+0x53>

        case '#':
            altflag = 1;
  103094:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  10309b:	e9 6e ff ff ff       	jmp    10300e <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  1030a0:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  1030a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1030a5:	0f 89 63 ff ff ff    	jns    10300e <vprintfmt+0x53>
                width = precision, precision = -1;
  1030ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1030ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1030b1:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1030b8:	e9 51 ff ff ff       	jmp    10300e <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1030bd:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  1030c1:	e9 48 ff ff ff       	jmp    10300e <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1030c6:	8b 45 14             	mov    0x14(%ebp),%eax
  1030c9:	8d 50 04             	lea    0x4(%eax),%edx
  1030cc:	89 55 14             	mov    %edx,0x14(%ebp)
  1030cf:	8b 00                	mov    (%eax),%eax
  1030d1:	83 ec 08             	sub    $0x8,%esp
  1030d4:	ff 75 0c             	pushl  0xc(%ebp)
  1030d7:	50                   	push   %eax
  1030d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1030db:	ff d0                	call   *%eax
  1030dd:	83 c4 10             	add    $0x10,%esp
            break;
  1030e0:	e9 71 02 00 00       	jmp    103356 <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1030e5:	8b 45 14             	mov    0x14(%ebp),%eax
  1030e8:	8d 50 04             	lea    0x4(%eax),%edx
  1030eb:	89 55 14             	mov    %edx,0x14(%ebp)
  1030ee:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1030f0:	85 db                	test   %ebx,%ebx
  1030f2:	79 02                	jns    1030f6 <vprintfmt+0x13b>
                err = -err;
  1030f4:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1030f6:	83 fb 06             	cmp    $0x6,%ebx
  1030f9:	7f 0b                	jg     103106 <vprintfmt+0x14b>
  1030fb:	8b 34 9d b4 3b 10 00 	mov    0x103bb4(,%ebx,4),%esi
  103102:	85 f6                	test   %esi,%esi
  103104:	75 19                	jne    10311f <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
  103106:	53                   	push   %ebx
  103107:	68 e1 3b 10 00       	push   $0x103be1
  10310c:	ff 75 0c             	pushl  0xc(%ebp)
  10310f:	ff 75 08             	pushl  0x8(%ebp)
  103112:	e8 80 fe ff ff       	call   102f97 <printfmt>
  103117:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10311a:	e9 37 02 00 00       	jmp    103356 <vprintfmt+0x39b>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  10311f:	56                   	push   %esi
  103120:	68 ea 3b 10 00       	push   $0x103bea
  103125:	ff 75 0c             	pushl  0xc(%ebp)
  103128:	ff 75 08             	pushl  0x8(%ebp)
  10312b:	e8 67 fe ff ff       	call   102f97 <printfmt>
  103130:	83 c4 10             	add    $0x10,%esp
            }
            break;
  103133:	e9 1e 02 00 00       	jmp    103356 <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  103138:	8b 45 14             	mov    0x14(%ebp),%eax
  10313b:	8d 50 04             	lea    0x4(%eax),%edx
  10313e:	89 55 14             	mov    %edx,0x14(%ebp)
  103141:	8b 30                	mov    (%eax),%esi
  103143:	85 f6                	test   %esi,%esi
  103145:	75 05                	jne    10314c <vprintfmt+0x191>
                p = "(null)";
  103147:	be ed 3b 10 00       	mov    $0x103bed,%esi
            }
            if (width > 0 && padc != '-') {
  10314c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103150:	7e 76                	jle    1031c8 <vprintfmt+0x20d>
  103152:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  103156:	74 70                	je     1031c8 <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
  103158:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10315b:	83 ec 08             	sub    $0x8,%esp
  10315e:	50                   	push   %eax
  10315f:	56                   	push   %esi
  103160:	e8 17 f8 ff ff       	call   10297c <strnlen>
  103165:	83 c4 10             	add    $0x10,%esp
  103168:	89 c2                	mov    %eax,%edx
  10316a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10316d:	29 d0                	sub    %edx,%eax
  10316f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103172:	eb 17                	jmp    10318b <vprintfmt+0x1d0>
                    putch(padc, putdat);
  103174:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  103178:	83 ec 08             	sub    $0x8,%esp
  10317b:	ff 75 0c             	pushl  0xc(%ebp)
  10317e:	50                   	push   %eax
  10317f:	8b 45 08             	mov    0x8(%ebp),%eax
  103182:	ff d0                	call   *%eax
  103184:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  103187:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  10318b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10318f:	7f e3                	jg     103174 <vprintfmt+0x1b9>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  103191:	eb 35                	jmp    1031c8 <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
  103193:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103197:	74 1c                	je     1031b5 <vprintfmt+0x1fa>
  103199:	83 fb 1f             	cmp    $0x1f,%ebx
  10319c:	7e 05                	jle    1031a3 <vprintfmt+0x1e8>
  10319e:	83 fb 7e             	cmp    $0x7e,%ebx
  1031a1:	7e 12                	jle    1031b5 <vprintfmt+0x1fa>
                    putch('?', putdat);
  1031a3:	83 ec 08             	sub    $0x8,%esp
  1031a6:	ff 75 0c             	pushl  0xc(%ebp)
  1031a9:	6a 3f                	push   $0x3f
  1031ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1031ae:	ff d0                	call   *%eax
  1031b0:	83 c4 10             	add    $0x10,%esp
  1031b3:	eb 0f                	jmp    1031c4 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
  1031b5:	83 ec 08             	sub    $0x8,%esp
  1031b8:	ff 75 0c             	pushl  0xc(%ebp)
  1031bb:	53                   	push   %ebx
  1031bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1031bf:	ff d0                	call   *%eax
  1031c1:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1031c4:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1031c8:	89 f0                	mov    %esi,%eax
  1031ca:	8d 70 01             	lea    0x1(%eax),%esi
  1031cd:	0f b6 00             	movzbl (%eax),%eax
  1031d0:	0f be d8             	movsbl %al,%ebx
  1031d3:	85 db                	test   %ebx,%ebx
  1031d5:	74 26                	je     1031fd <vprintfmt+0x242>
  1031d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1031db:	78 b6                	js     103193 <vprintfmt+0x1d8>
  1031dd:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  1031e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1031e5:	79 ac                	jns    103193 <vprintfmt+0x1d8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  1031e7:	eb 14                	jmp    1031fd <vprintfmt+0x242>
                putch(' ', putdat);
  1031e9:	83 ec 08             	sub    $0x8,%esp
  1031ec:	ff 75 0c             	pushl  0xc(%ebp)
  1031ef:	6a 20                	push   $0x20
  1031f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1031f4:	ff d0                	call   *%eax
  1031f6:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  1031f9:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1031fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103201:	7f e6                	jg     1031e9 <vprintfmt+0x22e>
                putch(' ', putdat);
            }
            break;
  103203:	e9 4e 01 00 00       	jmp    103356 <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  103208:	83 ec 08             	sub    $0x8,%esp
  10320b:	ff 75 e0             	pushl  -0x20(%ebp)
  10320e:	8d 45 14             	lea    0x14(%ebp),%eax
  103211:	50                   	push   %eax
  103212:	e8 39 fd ff ff       	call   102f50 <getint>
  103217:	83 c4 10             	add    $0x10,%esp
  10321a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10321d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  103220:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103223:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103226:	85 d2                	test   %edx,%edx
  103228:	79 23                	jns    10324d <vprintfmt+0x292>
                putch('-', putdat);
  10322a:	83 ec 08             	sub    $0x8,%esp
  10322d:	ff 75 0c             	pushl  0xc(%ebp)
  103230:	6a 2d                	push   $0x2d
  103232:	8b 45 08             	mov    0x8(%ebp),%eax
  103235:	ff d0                	call   *%eax
  103237:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
  10323a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10323d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103240:	f7 d8                	neg    %eax
  103242:	83 d2 00             	adc    $0x0,%edx
  103245:	f7 da                	neg    %edx
  103247:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10324a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  10324d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103254:	e9 9f 00 00 00       	jmp    1032f8 <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  103259:	83 ec 08             	sub    $0x8,%esp
  10325c:	ff 75 e0             	pushl  -0x20(%ebp)
  10325f:	8d 45 14             	lea    0x14(%ebp),%eax
  103262:	50                   	push   %eax
  103263:	e8 99 fc ff ff       	call   102f01 <getuint>
  103268:	83 c4 10             	add    $0x10,%esp
  10326b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10326e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  103271:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103278:	eb 7e                	jmp    1032f8 <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  10327a:	83 ec 08             	sub    $0x8,%esp
  10327d:	ff 75 e0             	pushl  -0x20(%ebp)
  103280:	8d 45 14             	lea    0x14(%ebp),%eax
  103283:	50                   	push   %eax
  103284:	e8 78 fc ff ff       	call   102f01 <getuint>
  103289:	83 c4 10             	add    $0x10,%esp
  10328c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10328f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  103292:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  103299:	eb 5d                	jmp    1032f8 <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
  10329b:	83 ec 08             	sub    $0x8,%esp
  10329e:	ff 75 0c             	pushl  0xc(%ebp)
  1032a1:	6a 30                	push   $0x30
  1032a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1032a6:	ff d0                	call   *%eax
  1032a8:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
  1032ab:	83 ec 08             	sub    $0x8,%esp
  1032ae:	ff 75 0c             	pushl  0xc(%ebp)
  1032b1:	6a 78                	push   $0x78
  1032b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1032b6:	ff d0                	call   *%eax
  1032b8:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  1032bb:	8b 45 14             	mov    0x14(%ebp),%eax
  1032be:	8d 50 04             	lea    0x4(%eax),%edx
  1032c1:	89 55 14             	mov    %edx,0x14(%ebp)
  1032c4:	8b 00                	mov    (%eax),%eax
  1032c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1032c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1032d0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1032d7:	eb 1f                	jmp    1032f8 <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1032d9:	83 ec 08             	sub    $0x8,%esp
  1032dc:	ff 75 e0             	pushl  -0x20(%ebp)
  1032df:	8d 45 14             	lea    0x14(%ebp),%eax
  1032e2:	50                   	push   %eax
  1032e3:	e8 19 fc ff ff       	call   102f01 <getuint>
  1032e8:	83 c4 10             	add    $0x10,%esp
  1032eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1032ee:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  1032f1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  1032f8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  1032fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032ff:	83 ec 04             	sub    $0x4,%esp
  103302:	52                   	push   %edx
  103303:	ff 75 e8             	pushl  -0x18(%ebp)
  103306:	50                   	push   %eax
  103307:	ff 75 f4             	pushl  -0xc(%ebp)
  10330a:	ff 75 f0             	pushl  -0x10(%ebp)
  10330d:	ff 75 0c             	pushl  0xc(%ebp)
  103310:	ff 75 08             	pushl  0x8(%ebp)
  103313:	e8 f8 fa ff ff       	call   102e10 <printnum>
  103318:	83 c4 20             	add    $0x20,%esp
            break;
  10331b:	eb 39                	jmp    103356 <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  10331d:	83 ec 08             	sub    $0x8,%esp
  103320:	ff 75 0c             	pushl  0xc(%ebp)
  103323:	53                   	push   %ebx
  103324:	8b 45 08             	mov    0x8(%ebp),%eax
  103327:	ff d0                	call   *%eax
  103329:	83 c4 10             	add    $0x10,%esp
            break;
  10332c:	eb 28                	jmp    103356 <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  10332e:	83 ec 08             	sub    $0x8,%esp
  103331:	ff 75 0c             	pushl  0xc(%ebp)
  103334:	6a 25                	push   $0x25
  103336:	8b 45 08             	mov    0x8(%ebp),%eax
  103339:	ff d0                	call   *%eax
  10333b:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
  10333e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103342:	eb 04                	jmp    103348 <vprintfmt+0x38d>
  103344:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103348:	8b 45 10             	mov    0x10(%ebp),%eax
  10334b:	83 e8 01             	sub    $0x1,%eax
  10334e:	0f b6 00             	movzbl (%eax),%eax
  103351:	3c 25                	cmp    $0x25,%al
  103353:	75 ef                	jne    103344 <vprintfmt+0x389>
                /* do nothing */;
            break;
  103355:	90                   	nop
        }
    }
  103356:	e9 68 fc ff ff       	jmp    102fc3 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  10335b:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  10335c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  10335f:	5b                   	pop    %ebx
  103360:	5e                   	pop    %esi
  103361:	5d                   	pop    %ebp
  103362:	c3                   	ret    

00103363 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  103363:	55                   	push   %ebp
  103364:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  103366:	8b 45 0c             	mov    0xc(%ebp),%eax
  103369:	8b 40 08             	mov    0x8(%eax),%eax
  10336c:	8d 50 01             	lea    0x1(%eax),%edx
  10336f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103372:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  103375:	8b 45 0c             	mov    0xc(%ebp),%eax
  103378:	8b 10                	mov    (%eax),%edx
  10337a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10337d:	8b 40 04             	mov    0x4(%eax),%eax
  103380:	39 c2                	cmp    %eax,%edx
  103382:	73 12                	jae    103396 <sprintputch+0x33>
        *b->buf ++ = ch;
  103384:	8b 45 0c             	mov    0xc(%ebp),%eax
  103387:	8b 00                	mov    (%eax),%eax
  103389:	8d 48 01             	lea    0x1(%eax),%ecx
  10338c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10338f:	89 0a                	mov    %ecx,(%edx)
  103391:	8b 55 08             	mov    0x8(%ebp),%edx
  103394:	88 10                	mov    %dl,(%eax)
    }
}
  103396:	90                   	nop
  103397:	5d                   	pop    %ebp
  103398:	c3                   	ret    

00103399 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  103399:	55                   	push   %ebp
  10339a:	89 e5                	mov    %esp,%ebp
  10339c:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10339f:	8d 45 14             	lea    0x14(%ebp),%eax
  1033a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  1033a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033a8:	50                   	push   %eax
  1033a9:	ff 75 10             	pushl  0x10(%ebp)
  1033ac:	ff 75 0c             	pushl  0xc(%ebp)
  1033af:	ff 75 08             	pushl  0x8(%ebp)
  1033b2:	e8 0b 00 00 00       	call   1033c2 <vsnprintf>
  1033b7:	83 c4 10             	add    $0x10,%esp
  1033ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1033bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1033c0:	c9                   	leave  
  1033c1:	c3                   	ret    

001033c2 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  1033c2:	55                   	push   %ebp
  1033c3:	89 e5                	mov    %esp,%ebp
  1033c5:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  1033c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1033cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1033ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033d1:	8d 50 ff             	lea    -0x1(%eax),%edx
  1033d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1033d7:	01 d0                	add    %edx,%eax
  1033d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1033e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1033e7:	74 0a                	je     1033f3 <vsnprintf+0x31>
  1033e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1033ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033ef:	39 c2                	cmp    %eax,%edx
  1033f1:	76 07                	jbe    1033fa <vsnprintf+0x38>
        return -E_INVAL;
  1033f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1033f8:	eb 20                	jmp    10341a <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1033fa:	ff 75 14             	pushl  0x14(%ebp)
  1033fd:	ff 75 10             	pushl  0x10(%ebp)
  103400:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103403:	50                   	push   %eax
  103404:	68 63 33 10 00       	push   $0x103363
  103409:	e8 ad fb ff ff       	call   102fbb <vprintfmt>
  10340e:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
  103411:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103414:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  103417:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10341a:	c9                   	leave  
  10341b:	c3                   	ret    
