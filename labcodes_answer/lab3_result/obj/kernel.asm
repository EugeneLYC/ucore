
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 00 12 00       	mov    $0x120000,%eax
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
c0100020:	a3 00 00 12 c0       	mov    %eax,0xc0120000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 f0 11 c0       	mov    $0xc011f000,%esp
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

static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba fc 30 12 c0       	mov    $0xc01230fc,%edx
c0100041:	b8 00 20 12 c0       	mov    $0xc0122000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	83 ec 04             	sub    $0x4,%esp
c010004d:	50                   	push   %eax
c010004e:	6a 00                	push   $0x0
c0100050:	68 00 20 12 c0       	push   $0xc0122000
c0100055:	e8 8d 7a 00 00       	call   c0107ae7 <memset>
c010005a:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
c010005d:	e8 b1 1d 00 00       	call   c0101e13 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100062:	c7 45 f4 60 83 10 c0 	movl   $0xc0108360,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100069:	83 ec 08             	sub    $0x8,%esp
c010006c:	ff 75 f4             	pushl  -0xc(%ebp)
c010006f:	68 7c 83 10 c0       	push   $0xc010837c
c0100074:	e8 09 02 00 00       	call   c0100282 <cprintf>
c0100079:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c010007c:	e8 a0 08 00 00       	call   c0100921 <print_kerninfo>

    grade_backtrace();
c0100081:	e8 83 00 00 00       	call   c0100109 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100086:	e8 58 65 00 00       	call   c01065e3 <pmm_init>

    pic_init();                 // init interrupt controller
c010008b:	e8 f5 1e 00 00       	call   c0101f85 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100090:	e8 56 20 00 00       	call   c01020eb <idt_init>

    vmm_init();                 // init virtual memory management
c0100095:	e8 ea 34 00 00       	call   c0103584 <vmm_init>

    ide_init();                 // init ide devices
c010009a:	e8 43 0d 00 00       	call   c0100de2 <ide_init>
    swap_init();                // init swap
c010009f:	e8 55 42 00 00       	call   c01042f9 <swap_init>

    clock_init();               // init clock interrupt
c01000a4:	e8 11 15 00 00       	call   c01015ba <clock_init>
    intr_enable();              // enable irq interrupt
c01000a9:	e8 14 20 00 00       	call   c01020c2 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000ae:	eb fe                	jmp    c01000ae <kern_init+0x78>

c01000b0 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b0:	55                   	push   %ebp
c01000b1:	89 e5                	mov    %esp,%ebp
c01000b3:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
c01000b6:	83 ec 04             	sub    $0x4,%esp
c01000b9:	6a 00                	push   $0x0
c01000bb:	6a 00                	push   $0x0
c01000bd:	6a 00                	push   $0x0
c01000bf:	e8 b2 0c 00 00       	call   c0100d76 <mon_backtrace>
c01000c4:	83 c4 10             	add    $0x10,%esp
}
c01000c7:	90                   	nop
c01000c8:	c9                   	leave  
c01000c9:	c3                   	ret    

c01000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ca:	55                   	push   %ebp
c01000cb:	89 e5                	mov    %esp,%ebp
c01000cd:	53                   	push   %ebx
c01000ce:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d7:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000da:	8b 45 08             	mov    0x8(%ebp),%eax
c01000dd:	51                   	push   %ecx
c01000de:	52                   	push   %edx
c01000df:	53                   	push   %ebx
c01000e0:	50                   	push   %eax
c01000e1:	e8 ca ff ff ff       	call   c01000b0 <grade_backtrace2>
c01000e6:	83 c4 10             	add    $0x10,%esp
}
c01000e9:	90                   	nop
c01000ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000ed:	c9                   	leave  
c01000ee:	c3                   	ret    

c01000ef <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000ef:	55                   	push   %ebp
c01000f0:	89 e5                	mov    %esp,%ebp
c01000f2:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
c01000f5:	83 ec 08             	sub    $0x8,%esp
c01000f8:	ff 75 10             	pushl  0x10(%ebp)
c01000fb:	ff 75 08             	pushl  0x8(%ebp)
c01000fe:	e8 c7 ff ff ff       	call   c01000ca <grade_backtrace1>
c0100103:	83 c4 10             	add    $0x10,%esp
}
c0100106:	90                   	nop
c0100107:	c9                   	leave  
c0100108:	c3                   	ret    

c0100109 <grade_backtrace>:

void
grade_backtrace(void) {
c0100109:	55                   	push   %ebp
c010010a:	89 e5                	mov    %esp,%ebp
c010010c:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010010f:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100114:	83 ec 04             	sub    $0x4,%esp
c0100117:	68 00 00 ff ff       	push   $0xffff0000
c010011c:	50                   	push   %eax
c010011d:	6a 00                	push   $0x0
c010011f:	e8 cb ff ff ff       	call   c01000ef <grade_backtrace0>
c0100124:	83 c4 10             	add    $0x10,%esp
}
c0100127:	90                   	nop
c0100128:	c9                   	leave  
c0100129:	c3                   	ret    

c010012a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010012a:	55                   	push   %ebp
c010012b:	89 e5                	mov    %esp,%ebp
c010012d:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100130:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100133:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100136:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100139:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010013c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100140:	0f b7 c0             	movzwl %ax,%eax
c0100143:	83 e0 03             	and    $0x3,%eax
c0100146:	89 c2                	mov    %eax,%edx
c0100148:	a1 00 20 12 c0       	mov    0xc0122000,%eax
c010014d:	83 ec 04             	sub    $0x4,%esp
c0100150:	52                   	push   %edx
c0100151:	50                   	push   %eax
c0100152:	68 81 83 10 c0       	push   $0xc0108381
c0100157:	e8 26 01 00 00       	call   c0100282 <cprintf>
c010015c:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
c010015f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100163:	0f b7 d0             	movzwl %ax,%edx
c0100166:	a1 00 20 12 c0       	mov    0xc0122000,%eax
c010016b:	83 ec 04             	sub    $0x4,%esp
c010016e:	52                   	push   %edx
c010016f:	50                   	push   %eax
c0100170:	68 8f 83 10 c0       	push   $0xc010838f
c0100175:	e8 08 01 00 00       	call   c0100282 <cprintf>
c010017a:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
c010017d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100181:	0f b7 d0             	movzwl %ax,%edx
c0100184:	a1 00 20 12 c0       	mov    0xc0122000,%eax
c0100189:	83 ec 04             	sub    $0x4,%esp
c010018c:	52                   	push   %edx
c010018d:	50                   	push   %eax
c010018e:	68 9d 83 10 c0       	push   $0xc010839d
c0100193:	e8 ea 00 00 00       	call   c0100282 <cprintf>
c0100198:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
c010019b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010019f:	0f b7 d0             	movzwl %ax,%edx
c01001a2:	a1 00 20 12 c0       	mov    0xc0122000,%eax
c01001a7:	83 ec 04             	sub    $0x4,%esp
c01001aa:	52                   	push   %edx
c01001ab:	50                   	push   %eax
c01001ac:	68 ab 83 10 c0       	push   $0xc01083ab
c01001b1:	e8 cc 00 00 00       	call   c0100282 <cprintf>
c01001b6:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
c01001b9:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001bd:	0f b7 d0             	movzwl %ax,%edx
c01001c0:	a1 00 20 12 c0       	mov    0xc0122000,%eax
c01001c5:	83 ec 04             	sub    $0x4,%esp
c01001c8:	52                   	push   %edx
c01001c9:	50                   	push   %eax
c01001ca:	68 b9 83 10 c0       	push   $0xc01083b9
c01001cf:	e8 ae 00 00 00       	call   c0100282 <cprintf>
c01001d4:	83 c4 10             	add    $0x10,%esp
    round ++;
c01001d7:	a1 00 20 12 c0       	mov    0xc0122000,%eax
c01001dc:	83 c0 01             	add    $0x1,%eax
c01001df:	a3 00 20 12 c0       	mov    %eax,0xc0122000
}
c01001e4:	90                   	nop
c01001e5:	c9                   	leave  
c01001e6:	c3                   	ret    

c01001e7 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001e7:	55                   	push   %ebp
c01001e8:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001ea:	90                   	nop
c01001eb:	5d                   	pop    %ebp
c01001ec:	c3                   	ret    

c01001ed <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001ed:	55                   	push   %ebp
c01001ee:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c01001f0:	90                   	nop
c01001f1:	5d                   	pop    %ebp
c01001f2:	c3                   	ret    

c01001f3 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c01001f3:	55                   	push   %ebp
c01001f4:	89 e5                	mov    %esp,%ebp
c01001f6:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
c01001f9:	e8 2c ff ff ff       	call   c010012a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c01001fe:	83 ec 0c             	sub    $0xc,%esp
c0100201:	68 c8 83 10 c0       	push   $0xc01083c8
c0100206:	e8 77 00 00 00       	call   c0100282 <cprintf>
c010020b:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
c010020e:	e8 d4 ff ff ff       	call   c01001e7 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100213:	e8 12 ff ff ff       	call   c010012a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100218:	83 ec 0c             	sub    $0xc,%esp
c010021b:	68 e8 83 10 c0       	push   $0xc01083e8
c0100220:	e8 5d 00 00 00       	call   c0100282 <cprintf>
c0100225:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
c0100228:	e8 c0 ff ff ff       	call   c01001ed <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010022d:	e8 f8 fe ff ff       	call   c010012a <lab1_print_cur_status>
}
c0100232:	90                   	nop
c0100233:	c9                   	leave  
c0100234:	c3                   	ret    

c0100235 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100235:	55                   	push   %ebp
c0100236:	89 e5                	mov    %esp,%ebp
c0100238:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c010023b:	83 ec 0c             	sub    $0xc,%esp
c010023e:	ff 75 08             	pushl  0x8(%ebp)
c0100241:	e8 fe 1b 00 00       	call   c0101e44 <cons_putc>
c0100246:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c0100249:	8b 45 0c             	mov    0xc(%ebp),%eax
c010024c:	8b 00                	mov    (%eax),%eax
c010024e:	8d 50 01             	lea    0x1(%eax),%edx
c0100251:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100254:	89 10                	mov    %edx,(%eax)
}
c0100256:	90                   	nop
c0100257:	c9                   	leave  
c0100258:	c3                   	ret    

c0100259 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100259:	55                   	push   %ebp
c010025a:	89 e5                	mov    %esp,%ebp
c010025c:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c010025f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100266:	ff 75 0c             	pushl  0xc(%ebp)
c0100269:	ff 75 08             	pushl  0x8(%ebp)
c010026c:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010026f:	50                   	push   %eax
c0100270:	68 35 02 10 c0       	push   $0xc0100235
c0100275:	e8 a3 7b 00 00       	call   c0107e1d <vprintfmt>
c010027a:	83 c4 10             	add    $0x10,%esp
    return cnt;
c010027d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100280:	c9                   	leave  
c0100281:	c3                   	ret    

c0100282 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100282:	55                   	push   %ebp
c0100283:	89 e5                	mov    %esp,%ebp
c0100285:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100288:	8d 45 0c             	lea    0xc(%ebp),%eax
c010028b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010028e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100291:	83 ec 08             	sub    $0x8,%esp
c0100294:	50                   	push   %eax
c0100295:	ff 75 08             	pushl  0x8(%ebp)
c0100298:	e8 bc ff ff ff       	call   c0100259 <vcprintf>
c010029d:	83 c4 10             	add    $0x10,%esp
c01002a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002a6:	c9                   	leave  
c01002a7:	c3                   	ret    

c01002a8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002a8:	55                   	push   %ebp
c01002a9:	89 e5                	mov    %esp,%ebp
c01002ab:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c01002ae:	83 ec 0c             	sub    $0xc,%esp
c01002b1:	ff 75 08             	pushl  0x8(%ebp)
c01002b4:	e8 8b 1b 00 00       	call   c0101e44 <cons_putc>
c01002b9:	83 c4 10             	add    $0x10,%esp
}
c01002bc:	90                   	nop
c01002bd:	c9                   	leave  
c01002be:	c3                   	ret    

c01002bf <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002bf:	55                   	push   %ebp
c01002c0:	89 e5                	mov    %esp,%ebp
c01002c2:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c01002c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002cc:	eb 14                	jmp    c01002e2 <cputs+0x23>
        cputch(c, &cnt);
c01002ce:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002d2:	83 ec 08             	sub    $0x8,%esp
c01002d5:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002d8:	52                   	push   %edx
c01002d9:	50                   	push   %eax
c01002da:	e8 56 ff ff ff       	call   c0100235 <cputch>
c01002df:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01002e5:	8d 50 01             	lea    0x1(%eax),%edx
c01002e8:	89 55 08             	mov    %edx,0x8(%ebp)
c01002eb:	0f b6 00             	movzbl (%eax),%eax
c01002ee:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002f1:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01002f5:	75 d7                	jne    c01002ce <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01002f7:	83 ec 08             	sub    $0x8,%esp
c01002fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01002fd:	50                   	push   %eax
c01002fe:	6a 0a                	push   $0xa
c0100300:	e8 30 ff ff ff       	call   c0100235 <cputch>
c0100305:	83 c4 10             	add    $0x10,%esp
    return cnt;
c0100308:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010030b:	c9                   	leave  
c010030c:	c3                   	ret    

c010030d <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010030d:	55                   	push   %ebp
c010030e:	89 e5                	mov    %esp,%ebp
c0100310:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100313:	e8 75 1b 00 00       	call   c0101e8d <cons_getc>
c0100318:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010031b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010031f:	74 f2                	je     c0100313 <getchar+0x6>
        /* do nothing */;
    return c;
c0100321:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100324:	c9                   	leave  
c0100325:	c3                   	ret    

c0100326 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100326:	55                   	push   %ebp
c0100327:	89 e5                	mov    %esp,%ebp
c0100329:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
c010032c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100330:	74 13                	je     c0100345 <readline+0x1f>
        cprintf("%s", prompt);
c0100332:	83 ec 08             	sub    $0x8,%esp
c0100335:	ff 75 08             	pushl  0x8(%ebp)
c0100338:	68 07 84 10 c0       	push   $0xc0108407
c010033d:	e8 40 ff ff ff       	call   c0100282 <cprintf>
c0100342:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
c0100345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010034c:	e8 bc ff ff ff       	call   c010030d <getchar>
c0100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100354:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100358:	79 0a                	jns    c0100364 <readline+0x3e>
            return NULL;
c010035a:	b8 00 00 00 00       	mov    $0x0,%eax
c010035f:	e9 82 00 00 00       	jmp    c01003e6 <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100364:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100368:	7e 2b                	jle    c0100395 <readline+0x6f>
c010036a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100371:	7f 22                	jg     c0100395 <readline+0x6f>
            cputchar(c);
c0100373:	83 ec 0c             	sub    $0xc,%esp
c0100376:	ff 75 f0             	pushl  -0x10(%ebp)
c0100379:	e8 2a ff ff ff       	call   c01002a8 <cputchar>
c010037e:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c0100381:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100384:	8d 50 01             	lea    0x1(%eax),%edx
c0100387:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010038a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010038d:	88 90 20 20 12 c0    	mov    %dl,-0x3feddfe0(%eax)
c0100393:	eb 4c                	jmp    c01003e1 <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
c0100395:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c0100399:	75 1a                	jne    c01003b5 <readline+0x8f>
c010039b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010039f:	7e 14                	jle    c01003b5 <readline+0x8f>
            cputchar(c);
c01003a1:	83 ec 0c             	sub    $0xc,%esp
c01003a4:	ff 75 f0             	pushl  -0x10(%ebp)
c01003a7:	e8 fc fe ff ff       	call   c01002a8 <cputchar>
c01003ac:	83 c4 10             	add    $0x10,%esp
            i --;
c01003af:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01003b3:	eb 2c                	jmp    c01003e1 <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
c01003b5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003b9:	74 06                	je     c01003c1 <readline+0x9b>
c01003bb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003bf:	75 8b                	jne    c010034c <readline+0x26>
            cputchar(c);
c01003c1:	83 ec 0c             	sub    $0xc,%esp
c01003c4:	ff 75 f0             	pushl  -0x10(%ebp)
c01003c7:	e8 dc fe ff ff       	call   c01002a8 <cputchar>
c01003cc:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c01003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d2:	05 20 20 12 c0       	add    $0xc0122020,%eax
c01003d7:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003da:	b8 20 20 12 c0       	mov    $0xc0122020,%eax
c01003df:	eb 05                	jmp    c01003e6 <readline+0xc0>
        }
    }
c01003e1:	e9 66 ff ff ff       	jmp    c010034c <readline+0x26>
}
c01003e6:	c9                   	leave  
c01003e7:	c3                   	ret    

c01003e8 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003e8:	55                   	push   %ebp
c01003e9:	89 e5                	mov    %esp,%ebp
c01003eb:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
c01003ee:	a1 20 24 12 c0       	mov    0xc0122420,%eax
c01003f3:	85 c0                	test   %eax,%eax
c01003f5:	75 5f                	jne    c0100456 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c01003f7:	c7 05 20 24 12 c0 01 	movl   $0x1,0xc0122420
c01003fe:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100401:	8d 45 14             	lea    0x14(%ebp),%eax
c0100404:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100407:	83 ec 04             	sub    $0x4,%esp
c010040a:	ff 75 0c             	pushl  0xc(%ebp)
c010040d:	ff 75 08             	pushl  0x8(%ebp)
c0100410:	68 0a 84 10 c0       	push   $0xc010840a
c0100415:	e8 68 fe ff ff       	call   c0100282 <cprintf>
c010041a:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010041d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100420:	83 ec 08             	sub    $0x8,%esp
c0100423:	50                   	push   %eax
c0100424:	ff 75 10             	pushl  0x10(%ebp)
c0100427:	e8 2d fe ff ff       	call   c0100259 <vcprintf>
c010042c:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c010042f:	83 ec 0c             	sub    $0xc,%esp
c0100432:	68 26 84 10 c0       	push   $0xc0108426
c0100437:	e8 46 fe ff ff       	call   c0100282 <cprintf>
c010043c:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
c010043f:	83 ec 0c             	sub    $0xc,%esp
c0100442:	68 28 84 10 c0       	push   $0xc0108428
c0100447:	e8 36 fe ff ff       	call   c0100282 <cprintf>
c010044c:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
c010044f:	e8 17 06 00 00       	call   c0100a6b <print_stackframe>
c0100454:	eb 01                	jmp    c0100457 <__panic+0x6f>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c0100456:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100457:	e8 6d 1c 00 00       	call   c01020c9 <intr_disable>
    while (1) {
        kmonitor(NULL);
c010045c:	83 ec 0c             	sub    $0xc,%esp
c010045f:	6a 00                	push   $0x0
c0100461:	e8 36 08 00 00       	call   c0100c9c <kmonitor>
c0100466:	83 c4 10             	add    $0x10,%esp
    }
c0100469:	eb f1                	jmp    c010045c <__panic+0x74>

c010046b <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c010046b:	55                   	push   %ebp
c010046c:	89 e5                	mov    %esp,%ebp
c010046e:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
c0100471:	8d 45 14             	lea    0x14(%ebp),%eax
c0100474:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100477:	83 ec 04             	sub    $0x4,%esp
c010047a:	ff 75 0c             	pushl  0xc(%ebp)
c010047d:	ff 75 08             	pushl  0x8(%ebp)
c0100480:	68 3a 84 10 c0       	push   $0xc010843a
c0100485:	e8 f8 fd ff ff       	call   c0100282 <cprintf>
c010048a:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100490:	83 ec 08             	sub    $0x8,%esp
c0100493:	50                   	push   %eax
c0100494:	ff 75 10             	pushl  0x10(%ebp)
c0100497:	e8 bd fd ff ff       	call   c0100259 <vcprintf>
c010049c:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c010049f:	83 ec 0c             	sub    $0xc,%esp
c01004a2:	68 26 84 10 c0       	push   $0xc0108426
c01004a7:	e8 d6 fd ff ff       	call   c0100282 <cprintf>
c01004ac:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c01004af:	90                   	nop
c01004b0:	c9                   	leave  
c01004b1:	c3                   	ret    

c01004b2 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004b2:	55                   	push   %ebp
c01004b3:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004b5:	a1 20 24 12 c0       	mov    0xc0122420,%eax
}
c01004ba:	5d                   	pop    %ebp
c01004bb:	c3                   	ret    

c01004bc <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004bc:	55                   	push   %ebp
c01004bd:	89 e5                	mov    %esp,%ebp
c01004bf:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c5:	8b 00                	mov    (%eax),%eax
c01004c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01004cd:	8b 00                	mov    (%eax),%eax
c01004cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004d9:	e9 d2 00 00 00       	jmp    c01005b0 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01004de:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004e4:	01 d0                	add    %edx,%eax
c01004e6:	89 c2                	mov    %eax,%edx
c01004e8:	c1 ea 1f             	shr    $0x1f,%edx
c01004eb:	01 d0                	add    %edx,%eax
c01004ed:	d1 f8                	sar    %eax
c01004ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004f5:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004f8:	eb 04                	jmp    c01004fe <stab_binsearch+0x42>
            m --;
c01004fa:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100501:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100504:	7c 1f                	jl     c0100525 <stab_binsearch+0x69>
c0100506:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100509:	89 d0                	mov    %edx,%eax
c010050b:	01 c0                	add    %eax,%eax
c010050d:	01 d0                	add    %edx,%eax
c010050f:	c1 e0 02             	shl    $0x2,%eax
c0100512:	89 c2                	mov    %eax,%edx
c0100514:	8b 45 08             	mov    0x8(%ebp),%eax
c0100517:	01 d0                	add    %edx,%eax
c0100519:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010051d:	0f b6 c0             	movzbl %al,%eax
c0100520:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100523:	75 d5                	jne    c01004fa <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100525:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100528:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010052b:	7d 0b                	jge    c0100538 <stab_binsearch+0x7c>
            l = true_m + 1;
c010052d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100530:	83 c0 01             	add    $0x1,%eax
c0100533:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100536:	eb 78                	jmp    c01005b0 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100538:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010053f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100542:	89 d0                	mov    %edx,%eax
c0100544:	01 c0                	add    %eax,%eax
c0100546:	01 d0                	add    %edx,%eax
c0100548:	c1 e0 02             	shl    $0x2,%eax
c010054b:	89 c2                	mov    %eax,%edx
c010054d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100550:	01 d0                	add    %edx,%eax
c0100552:	8b 40 08             	mov    0x8(%eax),%eax
c0100555:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100558:	73 13                	jae    c010056d <stab_binsearch+0xb1>
            *region_left = m;
c010055a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100560:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100562:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100565:	83 c0 01             	add    $0x1,%eax
c0100568:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010056b:	eb 43                	jmp    c01005b0 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010056d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100570:	89 d0                	mov    %edx,%eax
c0100572:	01 c0                	add    %eax,%eax
c0100574:	01 d0                	add    %edx,%eax
c0100576:	c1 e0 02             	shl    $0x2,%eax
c0100579:	89 c2                	mov    %eax,%edx
c010057b:	8b 45 08             	mov    0x8(%ebp),%eax
c010057e:	01 d0                	add    %edx,%eax
c0100580:	8b 40 08             	mov    0x8(%eax),%eax
c0100583:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100586:	76 16                	jbe    c010059e <stab_binsearch+0xe2>
            *region_right = m - 1;
c0100588:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010058b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010058e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100591:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100593:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100596:	83 e8 01             	sub    $0x1,%eax
c0100599:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010059c:	eb 12                	jmp    c01005b0 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c010059e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005a4:	89 10                	mov    %edx,(%eax)
            l = m;
c01005a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005ac:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005b3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005b6:	0f 8e 22 ff ff ff    	jle    c01004de <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005c0:	75 0f                	jne    c01005d1 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01005c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c5:	8b 00                	mov    (%eax),%eax
c01005c7:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01005cd:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005cf:	eb 3f                	jmp    c0100610 <stab_binsearch+0x154>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005d1:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d4:	8b 00                	mov    (%eax),%eax
c01005d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005d9:	eb 04                	jmp    c01005df <stab_binsearch+0x123>
c01005db:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01005df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005e2:	8b 00                	mov    (%eax),%eax
c01005e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005e7:	7d 1f                	jge    c0100608 <stab_binsearch+0x14c>
c01005e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005ec:	89 d0                	mov    %edx,%eax
c01005ee:	01 c0                	add    %eax,%eax
c01005f0:	01 d0                	add    %edx,%eax
c01005f2:	c1 e0 02             	shl    $0x2,%eax
c01005f5:	89 c2                	mov    %eax,%edx
c01005f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01005fa:	01 d0                	add    %edx,%eax
c01005fc:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100600:	0f b6 c0             	movzbl %al,%eax
c0100603:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100606:	75 d3                	jne    c01005db <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100608:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010060e:	89 10                	mov    %edx,(%eax)
    }
}
c0100610:	90                   	nop
c0100611:	c9                   	leave  
c0100612:	c3                   	ret    

c0100613 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100613:	55                   	push   %ebp
c0100614:	89 e5                	mov    %esp,%ebp
c0100616:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100619:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061c:	c7 00 58 84 10 c0    	movl   $0xc0108458,(%eax)
    info->eip_line = 0;
c0100622:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100625:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010062c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062f:	c7 40 08 58 84 10 c0 	movl   $0xc0108458,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100636:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100639:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100640:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100643:	8b 55 08             	mov    0x8(%ebp),%edx
c0100646:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100649:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100653:	c7 45 f4 60 a3 10 c0 	movl   $0xc010a360,-0xc(%ebp)
    stab_end = __STAB_END__;
c010065a:	c7 45 f0 d4 94 11 c0 	movl   $0xc01194d4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100661:	c7 45 ec d5 94 11 c0 	movl   $0xc01194d5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100668:	c7 45 e8 ba cd 11 c0 	movl   $0xc011cdba,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010066f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100672:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100675:	76 0d                	jbe    c0100684 <debuginfo_eip+0x71>
c0100677:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067a:	83 e8 01             	sub    $0x1,%eax
c010067d:	0f b6 00             	movzbl (%eax),%eax
c0100680:	84 c0                	test   %al,%al
c0100682:	74 0a                	je     c010068e <debuginfo_eip+0x7b>
        return -1;
c0100684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100689:	e9 91 02 00 00       	jmp    c010091f <debuginfo_eip+0x30c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010068e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100695:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100698:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069b:	29 c2                	sub    %eax,%edx
c010069d:	89 d0                	mov    %edx,%eax
c010069f:	c1 f8 02             	sar    $0x2,%eax
c01006a2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006a8:	83 e8 01             	sub    $0x1,%eax
c01006ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006ae:	ff 75 08             	pushl  0x8(%ebp)
c01006b1:	6a 64                	push   $0x64
c01006b3:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006b6:	50                   	push   %eax
c01006b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006ba:	50                   	push   %eax
c01006bb:	ff 75 f4             	pushl  -0xc(%ebp)
c01006be:	e8 f9 fd ff ff       	call   c01004bc <stab_binsearch>
c01006c3:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
c01006c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006c9:	85 c0                	test   %eax,%eax
c01006cb:	75 0a                	jne    c01006d7 <debuginfo_eip+0xc4>
        return -1;
c01006cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d2:	e9 48 02 00 00       	jmp    c010091f <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006da:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006e3:	ff 75 08             	pushl  0x8(%ebp)
c01006e6:	6a 24                	push   $0x24
c01006e8:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006eb:	50                   	push   %eax
c01006ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006ef:	50                   	push   %eax
c01006f0:	ff 75 f4             	pushl  -0xc(%ebp)
c01006f3:	e8 c4 fd ff ff       	call   c01004bc <stab_binsearch>
c01006f8:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
c01006fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01006fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100701:	39 c2                	cmp    %eax,%edx
c0100703:	7f 7c                	jg     c0100781 <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100705:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100708:	89 c2                	mov    %eax,%edx
c010070a:	89 d0                	mov    %edx,%eax
c010070c:	01 c0                	add    %eax,%eax
c010070e:	01 d0                	add    %edx,%eax
c0100710:	c1 e0 02             	shl    $0x2,%eax
c0100713:	89 c2                	mov    %eax,%edx
c0100715:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100718:	01 d0                	add    %edx,%eax
c010071a:	8b 00                	mov    (%eax),%eax
c010071c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010071f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100722:	29 d1                	sub    %edx,%ecx
c0100724:	89 ca                	mov    %ecx,%edx
c0100726:	39 d0                	cmp    %edx,%eax
c0100728:	73 22                	jae    c010074c <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010072a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010072d:	89 c2                	mov    %eax,%edx
c010072f:	89 d0                	mov    %edx,%eax
c0100731:	01 c0                	add    %eax,%eax
c0100733:	01 d0                	add    %edx,%eax
c0100735:	c1 e0 02             	shl    $0x2,%eax
c0100738:	89 c2                	mov    %eax,%edx
c010073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010073d:	01 d0                	add    %edx,%eax
c010073f:	8b 10                	mov    (%eax),%edx
c0100741:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100744:	01 c2                	add    %eax,%edx
c0100746:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100749:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010074c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010074f:	89 c2                	mov    %eax,%edx
c0100751:	89 d0                	mov    %edx,%eax
c0100753:	01 c0                	add    %eax,%eax
c0100755:	01 d0                	add    %edx,%eax
c0100757:	c1 e0 02             	shl    $0x2,%eax
c010075a:	89 c2                	mov    %eax,%edx
c010075c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075f:	01 d0                	add    %edx,%eax
c0100761:	8b 50 08             	mov    0x8(%eax),%edx
c0100764:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100767:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c010076a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010076d:	8b 40 10             	mov    0x10(%eax),%eax
c0100770:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100773:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100776:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100779:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010077c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010077f:	eb 15                	jmp    c0100796 <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100781:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100784:	8b 55 08             	mov    0x8(%ebp),%edx
c0100787:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c010078a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010078d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0100790:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100793:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0100796:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100799:	8b 40 08             	mov    0x8(%eax),%eax
c010079c:	83 ec 08             	sub    $0x8,%esp
c010079f:	6a 3a                	push   $0x3a
c01007a1:	50                   	push   %eax
c01007a2:	e8 b4 71 00 00       	call   c010795b <strfind>
c01007a7:	83 c4 10             	add    $0x10,%esp
c01007aa:	89 c2                	mov    %eax,%edx
c01007ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007af:	8b 40 08             	mov    0x8(%eax),%eax
c01007b2:	29 c2                	sub    %eax,%edx
c01007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b7:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007ba:	83 ec 0c             	sub    $0xc,%esp
c01007bd:	ff 75 08             	pushl  0x8(%ebp)
c01007c0:	6a 44                	push   $0x44
c01007c2:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007c5:	50                   	push   %eax
c01007c6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007c9:	50                   	push   %eax
c01007ca:	ff 75 f4             	pushl  -0xc(%ebp)
c01007cd:	e8 ea fc ff ff       	call   c01004bc <stab_binsearch>
c01007d2:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c01007d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007db:	39 c2                	cmp    %eax,%edx
c01007dd:	7f 24                	jg     c0100803 <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
c01007df:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007e2:	89 c2                	mov    %eax,%edx
c01007e4:	89 d0                	mov    %edx,%eax
c01007e6:	01 c0                	add    %eax,%eax
c01007e8:	01 d0                	add    %edx,%eax
c01007ea:	c1 e0 02             	shl    $0x2,%eax
c01007ed:	89 c2                	mov    %eax,%edx
c01007ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f2:	01 d0                	add    %edx,%eax
c01007f4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c01007f8:	0f b7 d0             	movzwl %ax,%edx
c01007fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007fe:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100801:	eb 13                	jmp    c0100816 <debuginfo_eip+0x203>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100803:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100808:	e9 12 01 00 00       	jmp    c010091f <debuginfo_eip+0x30c>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010080d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100810:	83 e8 01             	sub    $0x1,%eax
c0100813:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100816:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010081c:	39 c2                	cmp    %eax,%edx
c010081e:	7c 56                	jl     c0100876 <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
c0100820:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100823:	89 c2                	mov    %eax,%edx
c0100825:	89 d0                	mov    %edx,%eax
c0100827:	01 c0                	add    %eax,%eax
c0100829:	01 d0                	add    %edx,%eax
c010082b:	c1 e0 02             	shl    $0x2,%eax
c010082e:	89 c2                	mov    %eax,%edx
c0100830:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100833:	01 d0                	add    %edx,%eax
c0100835:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100839:	3c 84                	cmp    $0x84,%al
c010083b:	74 39                	je     c0100876 <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010083d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100840:	89 c2                	mov    %eax,%edx
c0100842:	89 d0                	mov    %edx,%eax
c0100844:	01 c0                	add    %eax,%eax
c0100846:	01 d0                	add    %edx,%eax
c0100848:	c1 e0 02             	shl    $0x2,%eax
c010084b:	89 c2                	mov    %eax,%edx
c010084d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100850:	01 d0                	add    %edx,%eax
c0100852:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100856:	3c 64                	cmp    $0x64,%al
c0100858:	75 b3                	jne    c010080d <debuginfo_eip+0x1fa>
c010085a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085d:	89 c2                	mov    %eax,%edx
c010085f:	89 d0                	mov    %edx,%eax
c0100861:	01 c0                	add    %eax,%eax
c0100863:	01 d0                	add    %edx,%eax
c0100865:	c1 e0 02             	shl    $0x2,%eax
c0100868:	89 c2                	mov    %eax,%edx
c010086a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086d:	01 d0                	add    %edx,%eax
c010086f:	8b 40 08             	mov    0x8(%eax),%eax
c0100872:	85 c0                	test   %eax,%eax
c0100874:	74 97                	je     c010080d <debuginfo_eip+0x1fa>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100876:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100879:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010087c:	39 c2                	cmp    %eax,%edx
c010087e:	7c 46                	jl     c01008c6 <debuginfo_eip+0x2b3>
c0100880:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100883:	89 c2                	mov    %eax,%edx
c0100885:	89 d0                	mov    %edx,%eax
c0100887:	01 c0                	add    %eax,%eax
c0100889:	01 d0                	add    %edx,%eax
c010088b:	c1 e0 02             	shl    $0x2,%eax
c010088e:	89 c2                	mov    %eax,%edx
c0100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100893:	01 d0                	add    %edx,%eax
c0100895:	8b 00                	mov    (%eax),%eax
c0100897:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010089a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010089d:	29 d1                	sub    %edx,%ecx
c010089f:	89 ca                	mov    %ecx,%edx
c01008a1:	39 d0                	cmp    %edx,%eax
c01008a3:	73 21                	jae    c01008c6 <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008a8:	89 c2                	mov    %eax,%edx
c01008aa:	89 d0                	mov    %edx,%eax
c01008ac:	01 c0                	add    %eax,%eax
c01008ae:	01 d0                	add    %edx,%eax
c01008b0:	c1 e0 02             	shl    $0x2,%eax
c01008b3:	89 c2                	mov    %eax,%edx
c01008b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008b8:	01 d0                	add    %edx,%eax
c01008ba:	8b 10                	mov    (%eax),%edx
c01008bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008bf:	01 c2                	add    %eax,%edx
c01008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008c4:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008cc:	39 c2                	cmp    %eax,%edx
c01008ce:	7d 4a                	jge    c010091a <debuginfo_eip+0x307>
        for (lline = lfun + 1;
c01008d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008d3:	83 c0 01             	add    $0x1,%eax
c01008d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008d9:	eb 18                	jmp    c01008f3 <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008de:	8b 40 14             	mov    0x14(%eax),%eax
c01008e1:	8d 50 01             	lea    0x1(%eax),%edx
c01008e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008e7:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c01008ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008ed:	83 c0 01             	add    $0x1,%eax
c01008f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c01008f9:	39 c2                	cmp    %eax,%edx
c01008fb:	7d 1d                	jge    c010091a <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100900:	89 c2                	mov    %eax,%edx
c0100902:	89 d0                	mov    %edx,%eax
c0100904:	01 c0                	add    %eax,%eax
c0100906:	01 d0                	add    %edx,%eax
c0100908:	c1 e0 02             	shl    $0x2,%eax
c010090b:	89 c2                	mov    %eax,%edx
c010090d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100910:	01 d0                	add    %edx,%eax
c0100912:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100916:	3c a0                	cmp    $0xa0,%al
c0100918:	74 c1                	je     c01008db <debuginfo_eip+0x2c8>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c010091a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010091f:	c9                   	leave  
c0100920:	c3                   	ret    

c0100921 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100921:	55                   	push   %ebp
c0100922:	89 e5                	mov    %esp,%ebp
c0100924:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100927:	83 ec 0c             	sub    $0xc,%esp
c010092a:	68 62 84 10 c0       	push   $0xc0108462
c010092f:	e8 4e f9 ff ff       	call   c0100282 <cprintf>
c0100934:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100937:	83 ec 08             	sub    $0x8,%esp
c010093a:	68 36 00 10 c0       	push   $0xc0100036
c010093f:	68 7b 84 10 c0       	push   $0xc010847b
c0100944:	e8 39 f9 ff ff       	call   c0100282 <cprintf>
c0100949:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c010094c:	83 ec 08             	sub    $0x8,%esp
c010094f:	68 56 83 10 c0       	push   $0xc0108356
c0100954:	68 93 84 10 c0       	push   $0xc0108493
c0100959:	e8 24 f9 ff ff       	call   c0100282 <cprintf>
c010095e:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100961:	83 ec 08             	sub    $0x8,%esp
c0100964:	68 00 20 12 c0       	push   $0xc0122000
c0100969:	68 ab 84 10 c0       	push   $0xc01084ab
c010096e:	e8 0f f9 ff ff       	call   c0100282 <cprintf>
c0100973:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c0100976:	83 ec 08             	sub    $0x8,%esp
c0100979:	68 fc 30 12 c0       	push   $0xc01230fc
c010097e:	68 c3 84 10 c0       	push   $0xc01084c3
c0100983:	e8 fa f8 ff ff       	call   c0100282 <cprintf>
c0100988:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010098b:	b8 fc 30 12 c0       	mov    $0xc01230fc,%eax
c0100990:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100995:	ba 36 00 10 c0       	mov    $0xc0100036,%edx
c010099a:	29 d0                	sub    %edx,%eax
c010099c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009a2:	85 c0                	test   %eax,%eax
c01009a4:	0f 48 c2             	cmovs  %edx,%eax
c01009a7:	c1 f8 0a             	sar    $0xa,%eax
c01009aa:	83 ec 08             	sub    $0x8,%esp
c01009ad:	50                   	push   %eax
c01009ae:	68 dc 84 10 c0       	push   $0xc01084dc
c01009b3:	e8 ca f8 ff ff       	call   c0100282 <cprintf>
c01009b8:	83 c4 10             	add    $0x10,%esp
}
c01009bb:	90                   	nop
c01009bc:	c9                   	leave  
c01009bd:	c3                   	ret    

c01009be <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009be:	55                   	push   %ebp
c01009bf:	89 e5                	mov    %esp,%ebp
c01009c1:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009c7:	83 ec 08             	sub    $0x8,%esp
c01009ca:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009cd:	50                   	push   %eax
c01009ce:	ff 75 08             	pushl  0x8(%ebp)
c01009d1:	e8 3d fc ff ff       	call   c0100613 <debuginfo_eip>
c01009d6:	83 c4 10             	add    $0x10,%esp
c01009d9:	85 c0                	test   %eax,%eax
c01009db:	74 15                	je     c01009f2 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009dd:	83 ec 08             	sub    $0x8,%esp
c01009e0:	ff 75 08             	pushl  0x8(%ebp)
c01009e3:	68 06 85 10 c0       	push   $0xc0108506
c01009e8:	e8 95 f8 ff ff       	call   c0100282 <cprintf>
c01009ed:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c01009f0:	eb 65                	jmp    c0100a57 <print_debuginfo+0x99>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01009f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01009f9:	eb 1c                	jmp    c0100a17 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c01009fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01009fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a01:	01 d0                	add    %edx,%eax
c0100a03:	0f b6 00             	movzbl (%eax),%eax
c0100a06:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a0f:	01 ca                	add    %ecx,%edx
c0100a11:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a17:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a1a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a1d:	7f dc                	jg     c01009fb <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a1f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a28:	01 d0                	add    %edx,%eax
c0100a2a:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a30:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a33:	89 d1                	mov    %edx,%ecx
c0100a35:	29 c1                	sub    %eax,%ecx
c0100a37:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a3a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a3d:	83 ec 0c             	sub    $0xc,%esp
c0100a40:	51                   	push   %ecx
c0100a41:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a47:	51                   	push   %ecx
c0100a48:	52                   	push   %edx
c0100a49:	50                   	push   %eax
c0100a4a:	68 22 85 10 c0       	push   $0xc0108522
c0100a4f:	e8 2e f8 ff ff       	call   c0100282 <cprintf>
c0100a54:	83 c4 20             	add    $0x20,%esp
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a57:	90                   	nop
c0100a58:	c9                   	leave  
c0100a59:	c3                   	ret    

c0100a5a <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a5a:	55                   	push   %ebp
c0100a5b:	89 e5                	mov    %esp,%ebp
c0100a5d:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a60:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a63:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a66:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a69:	c9                   	leave  
c0100a6a:	c3                   	ret    

c0100a6b <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a6b:	55                   	push   %ebp
c0100a6c:	89 e5                	mov    %esp,%ebp
c0100a6e:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a71:	89 e8                	mov    %ebp,%eax
c0100a73:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a76:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100a79:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a7c:	e8 d9 ff ff ff       	call   c0100a5a <read_eip>
c0100a81:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a84:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100a8b:	e9 8d 00 00 00       	jmp    c0100b1d <print_stackframe+0xb2>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100a90:	83 ec 04             	sub    $0x4,%esp
c0100a93:	ff 75 f0             	pushl  -0x10(%ebp)
c0100a96:	ff 75 f4             	pushl  -0xc(%ebp)
c0100a99:	68 34 85 10 c0       	push   $0xc0108534
c0100a9e:	e8 df f7 ff ff       	call   c0100282 <cprintf>
c0100aa3:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
c0100aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aa9:	83 c0 08             	add    $0x8,%eax
c0100aac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100aaf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100ab6:	eb 26                	jmp    c0100ade <print_stackframe+0x73>
            cprintf("0x%08x ", args[j]);
c0100ab8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100abb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100ac5:	01 d0                	add    %edx,%eax
c0100ac7:	8b 00                	mov    (%eax),%eax
c0100ac9:	83 ec 08             	sub    $0x8,%esp
c0100acc:	50                   	push   %eax
c0100acd:	68 50 85 10 c0       	push   $0xc0108550
c0100ad2:	e8 ab f7 ff ff       	call   c0100282 <cprintf>
c0100ad7:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0100ada:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100ade:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100ae2:	7e d4                	jle    c0100ab8 <print_stackframe+0x4d>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0100ae4:	83 ec 0c             	sub    $0xc,%esp
c0100ae7:	68 58 85 10 c0       	push   $0xc0108558
c0100aec:	e8 91 f7 ff ff       	call   c0100282 <cprintf>
c0100af1:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
c0100af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100af7:	83 e8 01             	sub    $0x1,%eax
c0100afa:	83 ec 0c             	sub    $0xc,%esp
c0100afd:	50                   	push   %eax
c0100afe:	e8 bb fe ff ff       	call   c01009be <print_debuginfo>
c0100b03:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
c0100b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b09:	83 c0 04             	add    $0x4,%eax
c0100b0c:	8b 00                	mov    (%eax),%eax
c0100b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b14:	8b 00                	mov    (%eax),%eax
c0100b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100b19:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b21:	74 0a                	je     c0100b2d <print_stackframe+0xc2>
c0100b23:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b27:	0f 8e 63 ff ff ff    	jle    c0100a90 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100b2d:	90                   	nop
c0100b2e:	c9                   	leave  
c0100b2f:	c3                   	ret    

c0100b30 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b30:	55                   	push   %ebp
c0100b31:	89 e5                	mov    %esp,%ebp
c0100b33:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
c0100b36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b3d:	eb 0c                	jmp    c0100b4b <parse+0x1b>
            *buf ++ = '\0';
c0100b3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b42:	8d 50 01             	lea    0x1(%eax),%edx
c0100b45:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b48:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4e:	0f b6 00             	movzbl (%eax),%eax
c0100b51:	84 c0                	test   %al,%al
c0100b53:	74 1e                	je     c0100b73 <parse+0x43>
c0100b55:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b58:	0f b6 00             	movzbl (%eax),%eax
c0100b5b:	0f be c0             	movsbl %al,%eax
c0100b5e:	83 ec 08             	sub    $0x8,%esp
c0100b61:	50                   	push   %eax
c0100b62:	68 dc 85 10 c0       	push   $0xc01085dc
c0100b67:	e8 bc 6d 00 00       	call   c0107928 <strchr>
c0100b6c:	83 c4 10             	add    $0x10,%esp
c0100b6f:	85 c0                	test   %eax,%eax
c0100b71:	75 cc                	jne    c0100b3f <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100b73:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b76:	0f b6 00             	movzbl (%eax),%eax
c0100b79:	84 c0                	test   %al,%al
c0100b7b:	74 69                	je     c0100be6 <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b7d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b81:	75 12                	jne    c0100b95 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b83:	83 ec 08             	sub    $0x8,%esp
c0100b86:	6a 10                	push   $0x10
c0100b88:	68 e1 85 10 c0       	push   $0xc01085e1
c0100b8d:	e8 f0 f6 ff ff       	call   c0100282 <cprintf>
c0100b92:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0100b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b98:	8d 50 01             	lea    0x1(%eax),%edx
c0100b9b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ba8:	01 c2                	add    %eax,%edx
c0100baa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bad:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100baf:	eb 04                	jmp    c0100bb5 <parse+0x85>
            buf ++;
c0100bb1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb8:	0f b6 00             	movzbl (%eax),%eax
c0100bbb:	84 c0                	test   %al,%al
c0100bbd:	0f 84 7a ff ff ff    	je     c0100b3d <parse+0xd>
c0100bc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc6:	0f b6 00             	movzbl (%eax),%eax
c0100bc9:	0f be c0             	movsbl %al,%eax
c0100bcc:	83 ec 08             	sub    $0x8,%esp
c0100bcf:	50                   	push   %eax
c0100bd0:	68 dc 85 10 c0       	push   $0xc01085dc
c0100bd5:	e8 4e 6d 00 00       	call   c0107928 <strchr>
c0100bda:	83 c4 10             	add    $0x10,%esp
c0100bdd:	85 c0                	test   %eax,%eax
c0100bdf:	74 d0                	je     c0100bb1 <parse+0x81>
            buf ++;
        }
    }
c0100be1:	e9 57 ff ff ff       	jmp    c0100b3d <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100be6:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100bea:	c9                   	leave  
c0100beb:	c3                   	ret    

c0100bec <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100bec:	55                   	push   %ebp
c0100bed:	89 e5                	mov    %esp,%ebp
c0100bef:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100bf2:	83 ec 08             	sub    $0x8,%esp
c0100bf5:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bf8:	50                   	push   %eax
c0100bf9:	ff 75 08             	pushl  0x8(%ebp)
c0100bfc:	e8 2f ff ff ff       	call   c0100b30 <parse>
c0100c01:	83 c4 10             	add    $0x10,%esp
c0100c04:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c0b:	75 0a                	jne    c0100c17 <runcmd+0x2b>
        return 0;
c0100c0d:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c12:	e9 83 00 00 00       	jmp    c0100c9a <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c1e:	eb 59                	jmp    c0100c79 <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c20:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c23:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c26:	89 d0                	mov    %edx,%eax
c0100c28:	01 c0                	add    %eax,%eax
c0100c2a:	01 d0                	add    %edx,%eax
c0100c2c:	c1 e0 02             	shl    $0x2,%eax
c0100c2f:	05 00 f0 11 c0       	add    $0xc011f000,%eax
c0100c34:	8b 00                	mov    (%eax),%eax
c0100c36:	83 ec 08             	sub    $0x8,%esp
c0100c39:	51                   	push   %ecx
c0100c3a:	50                   	push   %eax
c0100c3b:	e8 48 6c 00 00       	call   c0107888 <strcmp>
c0100c40:	83 c4 10             	add    $0x10,%esp
c0100c43:	85 c0                	test   %eax,%eax
c0100c45:	75 2e                	jne    c0100c75 <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c47:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c4a:	89 d0                	mov    %edx,%eax
c0100c4c:	01 c0                	add    %eax,%eax
c0100c4e:	01 d0                	add    %edx,%eax
c0100c50:	c1 e0 02             	shl    $0x2,%eax
c0100c53:	05 08 f0 11 c0       	add    $0xc011f008,%eax
c0100c58:	8b 10                	mov    (%eax),%edx
c0100c5a:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c5d:	83 c0 04             	add    $0x4,%eax
c0100c60:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c63:	83 e9 01             	sub    $0x1,%ecx
c0100c66:	83 ec 04             	sub    $0x4,%esp
c0100c69:	ff 75 0c             	pushl  0xc(%ebp)
c0100c6c:	50                   	push   %eax
c0100c6d:	51                   	push   %ecx
c0100c6e:	ff d2                	call   *%edx
c0100c70:	83 c4 10             	add    $0x10,%esp
c0100c73:	eb 25                	jmp    c0100c9a <runcmd+0xae>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c75:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c7c:	83 f8 02             	cmp    $0x2,%eax
c0100c7f:	76 9f                	jbe    c0100c20 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c81:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c84:	83 ec 08             	sub    $0x8,%esp
c0100c87:	50                   	push   %eax
c0100c88:	68 ff 85 10 c0       	push   $0xc01085ff
c0100c8d:	e8 f0 f5 ff ff       	call   c0100282 <cprintf>
c0100c92:	83 c4 10             	add    $0x10,%esp
    return 0;
c0100c95:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c9a:	c9                   	leave  
c0100c9b:	c3                   	ret    

c0100c9c <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c9c:	55                   	push   %ebp
c0100c9d:	89 e5                	mov    %esp,%ebp
c0100c9f:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100ca2:	83 ec 0c             	sub    $0xc,%esp
c0100ca5:	68 18 86 10 c0       	push   $0xc0108618
c0100caa:	e8 d3 f5 ff ff       	call   c0100282 <cprintf>
c0100caf:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c0100cb2:	83 ec 0c             	sub    $0xc,%esp
c0100cb5:	68 40 86 10 c0       	push   $0xc0108640
c0100cba:	e8 c3 f5 ff ff       	call   c0100282 <cprintf>
c0100cbf:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
c0100cc2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cc6:	74 0e                	je     c0100cd6 <kmonitor+0x3a>
        print_trapframe(tf);
c0100cc8:	83 ec 0c             	sub    $0xc,%esp
c0100ccb:	ff 75 08             	pushl  0x8(%ebp)
c0100cce:	e8 52 15 00 00       	call   c0102225 <print_trapframe>
c0100cd3:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cd6:	83 ec 0c             	sub    $0xc,%esp
c0100cd9:	68 65 86 10 c0       	push   $0xc0108665
c0100cde:	e8 43 f6 ff ff       	call   c0100326 <readline>
c0100ce3:	83 c4 10             	add    $0x10,%esp
c0100ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ce9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100ced:	74 e7                	je     c0100cd6 <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
c0100cef:	83 ec 08             	sub    $0x8,%esp
c0100cf2:	ff 75 08             	pushl  0x8(%ebp)
c0100cf5:	ff 75 f4             	pushl  -0xc(%ebp)
c0100cf8:	e8 ef fe ff ff       	call   c0100bec <runcmd>
c0100cfd:	83 c4 10             	add    $0x10,%esp
c0100d00:	85 c0                	test   %eax,%eax
c0100d02:	78 02                	js     c0100d06 <kmonitor+0x6a>
                break;
            }
        }
    }
c0100d04:	eb d0                	jmp    c0100cd6 <kmonitor+0x3a>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100d06:	90                   	nop
            }
        }
    }
}
c0100d07:	90                   	nop
c0100d08:	c9                   	leave  
c0100d09:	c3                   	ret    

c0100d0a <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d0a:	55                   	push   %ebp
c0100d0b:	89 e5                	mov    %esp,%ebp
c0100d0d:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d17:	eb 3c                	jmp    c0100d55 <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d19:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d1c:	89 d0                	mov    %edx,%eax
c0100d1e:	01 c0                	add    %eax,%eax
c0100d20:	01 d0                	add    %edx,%eax
c0100d22:	c1 e0 02             	shl    $0x2,%eax
c0100d25:	05 04 f0 11 c0       	add    $0xc011f004,%eax
c0100d2a:	8b 08                	mov    (%eax),%ecx
c0100d2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d2f:	89 d0                	mov    %edx,%eax
c0100d31:	01 c0                	add    %eax,%eax
c0100d33:	01 d0                	add    %edx,%eax
c0100d35:	c1 e0 02             	shl    $0x2,%eax
c0100d38:	05 00 f0 11 c0       	add    $0xc011f000,%eax
c0100d3d:	8b 00                	mov    (%eax),%eax
c0100d3f:	83 ec 04             	sub    $0x4,%esp
c0100d42:	51                   	push   %ecx
c0100d43:	50                   	push   %eax
c0100d44:	68 69 86 10 c0       	push   $0xc0108669
c0100d49:	e8 34 f5 ff ff       	call   c0100282 <cprintf>
c0100d4e:	83 c4 10             	add    $0x10,%esp

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d51:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d58:	83 f8 02             	cmp    $0x2,%eax
c0100d5b:	76 bc                	jbe    c0100d19 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100d5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d62:	c9                   	leave  
c0100d63:	c3                   	ret    

c0100d64 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d64:	55                   	push   %ebp
c0100d65:	89 e5                	mov    %esp,%ebp
c0100d67:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d6a:	e8 b2 fb ff ff       	call   c0100921 <print_kerninfo>
    return 0;
c0100d6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d74:	c9                   	leave  
c0100d75:	c3                   	ret    

c0100d76 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d76:	55                   	push   %ebp
c0100d77:	89 e5                	mov    %esp,%ebp
c0100d79:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d7c:	e8 ea fc ff ff       	call   c0100a6b <print_stackframe>
    return 0;
c0100d81:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d86:	c9                   	leave  
c0100d87:	c3                   	ret    

c0100d88 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100d88:	55                   	push   %ebp
c0100d89:	89 e5                	mov    %esp,%ebp
c0100d8b:	83 ec 14             	sub    $0x14,%esp
c0100d8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d91:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100d95:	90                   	nop
c0100d96:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0100d9a:	83 c0 07             	add    $0x7,%eax
c0100d9d:	0f b7 c0             	movzwl %ax,%eax
c0100da0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100da4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100da8:	89 c2                	mov    %eax,%edx
c0100daa:	ec                   	in     (%dx),%al
c0100dab:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100dae:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100db2:	0f b6 c0             	movzbl %al,%eax
c0100db5:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100db8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dbb:	25 80 00 00 00       	and    $0x80,%eax
c0100dc0:	85 c0                	test   %eax,%eax
c0100dc2:	75 d2                	jne    c0100d96 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100dc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100dc8:	74 11                	je     c0100ddb <ide_wait_ready+0x53>
c0100dca:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dcd:	83 e0 21             	and    $0x21,%eax
c0100dd0:	85 c0                	test   %eax,%eax
c0100dd2:	74 07                	je     c0100ddb <ide_wait_ready+0x53>
        return -1;
c0100dd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100dd9:	eb 05                	jmp    c0100de0 <ide_wait_ready+0x58>
    }
    return 0;
c0100ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100de0:	c9                   	leave  
c0100de1:	c3                   	ret    

c0100de2 <ide_init>:

void
ide_init(void) {
c0100de2:	55                   	push   %ebp
c0100de3:	89 e5                	mov    %esp,%ebp
c0100de5:	57                   	push   %edi
c0100de6:	53                   	push   %ebx
c0100de7:	81 ec 40 02 00 00    	sub    $0x240,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100ded:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100df3:	e9 c1 02 00 00       	jmp    c01010b9 <ide_init+0x2d7>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100df8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100dfc:	c1 e0 03             	shl    $0x3,%eax
c0100dff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100e06:	29 c2                	sub    %eax,%edx
c0100e08:	89 d0                	mov    %edx,%eax
c0100e0a:	05 40 24 12 c0       	add    $0xc0122440,%eax
c0100e0f:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100e12:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e16:	66 d1 e8             	shr    %ax
c0100e19:	0f b7 c0             	movzwl %ax,%eax
c0100e1c:	0f b7 04 85 74 86 10 	movzwl -0x3fef798c(,%eax,4),%eax
c0100e23:	c0 
c0100e24:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100e28:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e2c:	6a 00                	push   $0x0
c0100e2e:	50                   	push   %eax
c0100e2f:	e8 54 ff ff ff       	call   c0100d88 <ide_wait_ready>
c0100e34:	83 c4 08             	add    $0x8,%esp

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100e37:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e3b:	83 e0 01             	and    $0x1,%eax
c0100e3e:	c1 e0 04             	shl    $0x4,%eax
c0100e41:	83 c8 e0             	or     $0xffffffe0,%eax
c0100e44:	0f b6 c0             	movzbl %al,%eax
c0100e47:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e4b:	83 c2 06             	add    $0x6,%edx
c0100e4e:	0f b7 d2             	movzwl %dx,%edx
c0100e51:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0100e55:	88 45 c7             	mov    %al,-0x39(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e58:	0f b6 45 c7          	movzbl -0x39(%ebp),%eax
c0100e5c:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100e60:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e61:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e65:	6a 00                	push   $0x0
c0100e67:	50                   	push   %eax
c0100e68:	e8 1b ff ff ff       	call   c0100d88 <ide_wait_ready>
c0100e6d:	83 c4 08             	add    $0x8,%esp

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100e70:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e74:	83 c0 07             	add    $0x7,%eax
c0100e77:	0f b7 c0             	movzwl %ax,%eax
c0100e7a:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
c0100e7e:	c6 45 c8 ec          	movb   $0xec,-0x38(%ebp)
c0100e82:	0f b6 45 c8          	movzbl -0x38(%ebp),%eax
c0100e86:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c0100e8a:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e8b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e8f:	6a 00                	push   $0x0
c0100e91:	50                   	push   %eax
c0100e92:	e8 f1 fe ff ff       	call   c0100d88 <ide_wait_ready>
c0100e97:	83 c4 08             	add    $0x8,%esp

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100e9a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e9e:	83 c0 07             	add    $0x7,%eax
c0100ea1:	0f b7 c0             	movzwl %ax,%eax
c0100ea4:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ea8:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0100eac:	89 c2                	mov    %eax,%edx
c0100eae:	ec                   	in     (%dx),%al
c0100eaf:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0100eb2:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100eb6:	84 c0                	test   %al,%al
c0100eb8:	0f 84 ef 01 00 00    	je     c01010ad <ide_init+0x2cb>
c0100ebe:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ec2:	6a 01                	push   $0x1
c0100ec4:	50                   	push   %eax
c0100ec5:	e8 be fe ff ff       	call   c0100d88 <ide_wait_ready>
c0100eca:	83 c4 08             	add    $0x8,%esp
c0100ecd:	85 c0                	test   %eax,%eax
c0100ecf:	0f 85 d8 01 00 00    	jne    c01010ad <ide_init+0x2cb>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100ed5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ed9:	c1 e0 03             	shl    $0x3,%eax
c0100edc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100ee3:	29 c2                	sub    %eax,%edx
c0100ee5:	89 d0                	mov    %edx,%eax
c0100ee7:	05 40 24 12 c0       	add    $0xc0122440,%eax
c0100eec:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100eef:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ef3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0100ef6:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100efc:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100eff:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0100f06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100f09:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100f0c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100f0f:	89 cb                	mov    %ecx,%ebx
c0100f11:	89 df                	mov    %ebx,%edi
c0100f13:	89 c1                	mov    %eax,%ecx
c0100f15:	fc                   	cld    
c0100f16:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100f18:	89 c8                	mov    %ecx,%eax
c0100f1a:	89 fb                	mov    %edi,%ebx
c0100f1c:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100f1f:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0100f22:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f28:	89 45 dc             	mov    %eax,-0x24(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100f2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f2e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100f34:	89 45 d8             	mov    %eax,-0x28(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100f37:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100f3a:	25 00 00 00 04       	and    $0x4000000,%eax
c0100f3f:	85 c0                	test   %eax,%eax
c0100f41:	74 0e                	je     c0100f51 <ide_init+0x16f>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100f43:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f46:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100f4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100f4f:	eb 09                	jmp    c0100f5a <ide_init+0x178>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100f51:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f54:	8b 40 78             	mov    0x78(%eax),%eax
c0100f57:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100f5a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f5e:	c1 e0 03             	shl    $0x3,%eax
c0100f61:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f68:	29 c2                	sub    %eax,%edx
c0100f6a:	89 d0                	mov    %edx,%eax
c0100f6c:	8d 90 44 24 12 c0    	lea    -0x3feddbbc(%eax),%edx
c0100f72:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100f75:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0100f77:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f7b:	c1 e0 03             	shl    $0x3,%eax
c0100f7e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f85:	29 c2                	sub    %eax,%edx
c0100f87:	89 d0                	mov    %edx,%eax
c0100f89:	8d 90 48 24 12 c0    	lea    -0x3feddbb8(%eax),%edx
c0100f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100f92:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100f94:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f97:	83 c0 62             	add    $0x62,%eax
c0100f9a:	0f b7 00             	movzwl (%eax),%eax
c0100f9d:	0f b7 c0             	movzwl %ax,%eax
c0100fa0:	25 00 02 00 00       	and    $0x200,%eax
c0100fa5:	85 c0                	test   %eax,%eax
c0100fa7:	75 16                	jne    c0100fbf <ide_init+0x1dd>
c0100fa9:	68 7c 86 10 c0       	push   $0xc010867c
c0100fae:	68 bf 86 10 c0       	push   $0xc01086bf
c0100fb3:	6a 7d                	push   $0x7d
c0100fb5:	68 d4 86 10 c0       	push   $0xc01086d4
c0100fba:	e8 29 f4 ff ff       	call   c01003e8 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0100fbf:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fc3:	89 c2                	mov    %eax,%edx
c0100fc5:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c0100fcc:	89 c2                	mov    %eax,%edx
c0100fce:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c0100fd5:	29 d0                	sub    %edx,%eax
c0100fd7:	05 40 24 12 c0       	add    $0xc0122440,%eax
c0100fdc:	83 c0 0c             	add    $0xc,%eax
c0100fdf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100fe2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100fe5:	83 c0 36             	add    $0x36,%eax
c0100fe8:	89 45 d0             	mov    %eax,-0x30(%ebp)
        unsigned int i, length = 40;
c0100feb:	c7 45 cc 28 00 00 00 	movl   $0x28,-0x34(%ebp)
        for (i = 0; i < length; i += 2) {
c0100ff2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100ff9:	eb 34                	jmp    c010102f <ide_init+0x24d>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0100ffb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100ffe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101001:	01 c2                	add    %eax,%edx
c0101003:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101006:	8d 48 01             	lea    0x1(%eax),%ecx
c0101009:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010100c:	01 c8                	add    %ecx,%eax
c010100e:	0f b6 00             	movzbl (%eax),%eax
c0101011:	88 02                	mov    %al,(%edx)
c0101013:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101016:	8d 50 01             	lea    0x1(%eax),%edx
c0101019:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010101c:	01 c2                	add    %eax,%edx
c010101e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0101021:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101024:	01 c8                	add    %ecx,%eax
c0101026:	0f b6 00             	movzbl (%eax),%eax
c0101029:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c010102b:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c010102f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101032:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c0101035:	72 c4                	jb     c0100ffb <ide_init+0x219>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0101037:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010103a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010103d:	01 d0                	add    %edx,%eax
c010103f:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101042:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101045:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101048:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010104b:	85 c0                	test   %eax,%eax
c010104d:	74 0f                	je     c010105e <ide_init+0x27c>
c010104f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101052:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101055:	01 d0                	add    %edx,%eax
c0101057:	0f b6 00             	movzbl (%eax),%eax
c010105a:	3c 20                	cmp    $0x20,%al
c010105c:	74 d9                	je     c0101037 <ide_init+0x255>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c010105e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101062:	89 c2                	mov    %eax,%edx
c0101064:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c010106b:	89 c2                	mov    %eax,%edx
c010106d:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c0101074:	29 d0                	sub    %edx,%eax
c0101076:	05 40 24 12 c0       	add    $0xc0122440,%eax
c010107b:	8d 48 0c             	lea    0xc(%eax),%ecx
c010107e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101082:	c1 e0 03             	shl    $0x3,%eax
c0101085:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010108c:	29 c2                	sub    %eax,%edx
c010108e:	89 d0                	mov    %edx,%eax
c0101090:	05 48 24 12 c0       	add    $0xc0122448,%eax
c0101095:	8b 10                	mov    (%eax),%edx
c0101097:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010109b:	51                   	push   %ecx
c010109c:	52                   	push   %edx
c010109d:	50                   	push   %eax
c010109e:	68 e6 86 10 c0       	push   $0xc01086e6
c01010a3:	e8 da f1 ff ff       	call   c0100282 <cprintf>
c01010a8:	83 c4 10             	add    $0x10,%esp
c01010ab:	eb 01                	jmp    c01010ae <ide_init+0x2cc>
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
        ide_wait_ready(iobase, 0);

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
            continue ;
c01010ad:	90                   	nop

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01010ae:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010b2:	83 c0 01             	add    $0x1,%eax
c01010b5:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01010b9:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c01010be:	0f 86 34 fd ff ff    	jbe    c0100df8 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c01010c4:	83 ec 0c             	sub    $0xc,%esp
c01010c7:	6a 0e                	push   $0xe
c01010c9:	e8 8a 0e 00 00       	call   c0101f58 <pic_enable>
c01010ce:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_IDE2);
c01010d1:	83 ec 0c             	sub    $0xc,%esp
c01010d4:	6a 0f                	push   $0xf
c01010d6:	e8 7d 0e 00 00       	call   c0101f58 <pic_enable>
c01010db:	83 c4 10             	add    $0x10,%esp
}
c01010de:	90                   	nop
c01010df:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01010e2:	5b                   	pop    %ebx
c01010e3:	5f                   	pop    %edi
c01010e4:	5d                   	pop    %ebp
c01010e5:	c3                   	ret    

c01010e6 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c01010e6:	55                   	push   %ebp
c01010e7:	89 e5                	mov    %esp,%ebp
c01010e9:	83 ec 04             	sub    $0x4,%esp
c01010ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01010ef:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c01010f3:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c01010f8:	77 25                	ja     c010111f <ide_device_valid+0x39>
c01010fa:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01010fe:	c1 e0 03             	shl    $0x3,%eax
c0101101:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101108:	29 c2                	sub    %eax,%edx
c010110a:	89 d0                	mov    %edx,%eax
c010110c:	05 40 24 12 c0       	add    $0xc0122440,%eax
c0101111:	0f b6 00             	movzbl (%eax),%eax
c0101114:	84 c0                	test   %al,%al
c0101116:	74 07                	je     c010111f <ide_device_valid+0x39>
c0101118:	b8 01 00 00 00       	mov    $0x1,%eax
c010111d:	eb 05                	jmp    c0101124 <ide_device_valid+0x3e>
c010111f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101124:	c9                   	leave  
c0101125:	c3                   	ret    

c0101126 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101126:	55                   	push   %ebp
c0101127:	89 e5                	mov    %esp,%ebp
c0101129:	83 ec 04             	sub    $0x4,%esp
c010112c:	8b 45 08             	mov    0x8(%ebp),%eax
c010112f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101133:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101137:	50                   	push   %eax
c0101138:	e8 a9 ff ff ff       	call   c01010e6 <ide_device_valid>
c010113d:	83 c4 04             	add    $0x4,%esp
c0101140:	85 c0                	test   %eax,%eax
c0101142:	74 1b                	je     c010115f <ide_device_size+0x39>
        return ide_devices[ideno].size;
c0101144:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101148:	c1 e0 03             	shl    $0x3,%eax
c010114b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101152:	29 c2                	sub    %eax,%edx
c0101154:	89 d0                	mov    %edx,%eax
c0101156:	05 48 24 12 c0       	add    $0xc0122448,%eax
c010115b:	8b 00                	mov    (%eax),%eax
c010115d:	eb 05                	jmp    c0101164 <ide_device_size+0x3e>
    }
    return 0;
c010115f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101164:	c9                   	leave  
c0101165:	c3                   	ret    

c0101166 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101166:	55                   	push   %ebp
c0101167:	89 e5                	mov    %esp,%ebp
c0101169:	57                   	push   %edi
c010116a:	53                   	push   %ebx
c010116b:	83 ec 40             	sub    $0x40,%esp
c010116e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101171:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101175:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c010117c:	77 25                	ja     c01011a3 <ide_read_secs+0x3d>
c010117e:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101183:	77 1e                	ja     c01011a3 <ide_read_secs+0x3d>
c0101185:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101189:	c1 e0 03             	shl    $0x3,%eax
c010118c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101193:	29 c2                	sub    %eax,%edx
c0101195:	89 d0                	mov    %edx,%eax
c0101197:	05 40 24 12 c0       	add    $0xc0122440,%eax
c010119c:	0f b6 00             	movzbl (%eax),%eax
c010119f:	84 c0                	test   %al,%al
c01011a1:	75 19                	jne    c01011bc <ide_read_secs+0x56>
c01011a3:	68 04 87 10 c0       	push   $0xc0108704
c01011a8:	68 bf 86 10 c0       	push   $0xc01086bf
c01011ad:	68 9f 00 00 00       	push   $0x9f
c01011b2:	68 d4 86 10 c0       	push   $0xc01086d4
c01011b7:	e8 2c f2 ff ff       	call   c01003e8 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01011bc:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01011c3:	77 0f                	ja     c01011d4 <ide_read_secs+0x6e>
c01011c5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01011c8:	8b 45 14             	mov    0x14(%ebp),%eax
c01011cb:	01 d0                	add    %edx,%eax
c01011cd:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01011d2:	76 19                	jbe    c01011ed <ide_read_secs+0x87>
c01011d4:	68 2c 87 10 c0       	push   $0xc010872c
c01011d9:	68 bf 86 10 c0       	push   $0xc01086bf
c01011de:	68 a0 00 00 00       	push   $0xa0
c01011e3:	68 d4 86 10 c0       	push   $0xc01086d4
c01011e8:	e8 fb f1 ff ff       	call   c01003e8 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c01011ed:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011f1:	66 d1 e8             	shr    %ax
c01011f4:	0f b7 c0             	movzwl %ax,%eax
c01011f7:	0f b7 04 85 74 86 10 	movzwl -0x3fef798c(,%eax,4),%eax
c01011fe:	c0 
c01011ff:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101203:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101207:	66 d1 e8             	shr    %ax
c010120a:	0f b7 c0             	movzwl %ax,%eax
c010120d:	0f b7 04 85 76 86 10 	movzwl -0x3fef798a(,%eax,4),%eax
c0101214:	c0 
c0101215:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101219:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010121d:	83 ec 08             	sub    $0x8,%esp
c0101220:	6a 00                	push   $0x0
c0101222:	50                   	push   %eax
c0101223:	e8 60 fb ff ff       	call   c0100d88 <ide_wait_ready>
c0101228:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010122b:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010122f:	83 c0 02             	add    $0x2,%eax
c0101232:	0f b7 c0             	movzwl %ax,%eax
c0101235:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101239:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010123d:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101241:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101245:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101246:	8b 45 14             	mov    0x14(%ebp),%eax
c0101249:	0f b6 c0             	movzbl %al,%eax
c010124c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101250:	83 c2 02             	add    $0x2,%edx
c0101253:	0f b7 d2             	movzwl %dx,%edx
c0101256:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c010125a:	88 45 d8             	mov    %al,-0x28(%ebp)
c010125d:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101261:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101265:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101266:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101269:	0f b6 c0             	movzbl %al,%eax
c010126c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101270:	83 c2 03             	add    $0x3,%edx
c0101273:	0f b7 d2             	movzwl %dx,%edx
c0101276:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c010127a:	88 45 d9             	mov    %al,-0x27(%ebp)
c010127d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101281:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101285:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101286:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101289:	c1 e8 08             	shr    $0x8,%eax
c010128c:	0f b6 c0             	movzbl %al,%eax
c010128f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101293:	83 c2 04             	add    $0x4,%edx
c0101296:	0f b7 d2             	movzwl %dx,%edx
c0101299:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c010129d:	88 45 da             	mov    %al,-0x26(%ebp)
c01012a0:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01012a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c01012a8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01012a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012ac:	c1 e8 10             	shr    $0x10,%eax
c01012af:	0f b6 c0             	movzbl %al,%eax
c01012b2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012b6:	83 c2 05             	add    $0x5,%edx
c01012b9:	0f b7 d2             	movzwl %dx,%edx
c01012bc:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01012c0:	88 45 db             	mov    %al,-0x25(%ebp)
c01012c3:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01012c7:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01012cb:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01012cc:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01012d0:	83 e0 01             	and    $0x1,%eax
c01012d3:	c1 e0 04             	shl    $0x4,%eax
c01012d6:	89 c2                	mov    %eax,%edx
c01012d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012db:	c1 e8 18             	shr    $0x18,%eax
c01012de:	83 e0 0f             	and    $0xf,%eax
c01012e1:	09 d0                	or     %edx,%eax
c01012e3:	83 c8 e0             	or     $0xffffffe0,%eax
c01012e6:	0f b6 c0             	movzbl %al,%eax
c01012e9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012ed:	83 c2 06             	add    $0x6,%edx
c01012f0:	0f b7 d2             	movzwl %dx,%edx
c01012f3:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c01012f7:	88 45 dc             	mov    %al,-0x24(%ebp)
c01012fa:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c01012fe:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c0101302:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101303:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101307:	83 c0 07             	add    $0x7,%eax
c010130a:	0f b7 c0             	movzwl %ax,%eax
c010130d:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c0101311:	c6 45 dd 20          	movb   $0x20,-0x23(%ebp)
c0101315:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101319:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010131d:	ee                   	out    %al,(%dx)

    int ret = 0;
c010131e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101325:	eb 56                	jmp    c010137d <ide_read_secs+0x217>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101327:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010132b:	83 ec 08             	sub    $0x8,%esp
c010132e:	6a 01                	push   $0x1
c0101330:	50                   	push   %eax
c0101331:	e8 52 fa ff ff       	call   c0100d88 <ide_wait_ready>
c0101336:	83 c4 10             	add    $0x10,%esp
c0101339:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010133c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101340:	75 43                	jne    c0101385 <ide_read_secs+0x21f>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101342:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101346:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0101349:	8b 45 10             	mov    0x10(%ebp),%eax
c010134c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010134f:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101356:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101359:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c010135c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010135f:	89 cb                	mov    %ecx,%ebx
c0101361:	89 df                	mov    %ebx,%edi
c0101363:	89 c1                	mov    %eax,%ecx
c0101365:	fc                   	cld    
c0101366:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101368:	89 c8                	mov    %ecx,%eax
c010136a:	89 fb                	mov    %edi,%ebx
c010136c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c010136f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101372:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101376:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c010137d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101381:	75 a4                	jne    c0101327 <ide_read_secs+0x1c1>
c0101383:	eb 01                	jmp    c0101386 <ide_read_secs+0x220>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c0101385:	90                   	nop
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101386:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101389:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010138c:	5b                   	pop    %ebx
c010138d:	5f                   	pop    %edi
c010138e:	5d                   	pop    %ebp
c010138f:	c3                   	ret    

c0101390 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101390:	55                   	push   %ebp
c0101391:	89 e5                	mov    %esp,%ebp
c0101393:	56                   	push   %esi
c0101394:	53                   	push   %ebx
c0101395:	83 ec 40             	sub    $0x40,%esp
c0101398:	8b 45 08             	mov    0x8(%ebp),%eax
c010139b:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c010139f:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01013a6:	77 25                	ja     c01013cd <ide_write_secs+0x3d>
c01013a8:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c01013ad:	77 1e                	ja     c01013cd <ide_write_secs+0x3d>
c01013af:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01013b3:	c1 e0 03             	shl    $0x3,%eax
c01013b6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01013bd:	29 c2                	sub    %eax,%edx
c01013bf:	89 d0                	mov    %edx,%eax
c01013c1:	05 40 24 12 c0       	add    $0xc0122440,%eax
c01013c6:	0f b6 00             	movzbl (%eax),%eax
c01013c9:	84 c0                	test   %al,%al
c01013cb:	75 19                	jne    c01013e6 <ide_write_secs+0x56>
c01013cd:	68 04 87 10 c0       	push   $0xc0108704
c01013d2:	68 bf 86 10 c0       	push   $0xc01086bf
c01013d7:	68 bc 00 00 00       	push   $0xbc
c01013dc:	68 d4 86 10 c0       	push   $0xc01086d4
c01013e1:	e8 02 f0 ff ff       	call   c01003e8 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01013e6:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01013ed:	77 0f                	ja     c01013fe <ide_write_secs+0x6e>
c01013ef:	8b 55 0c             	mov    0xc(%ebp),%edx
c01013f2:	8b 45 14             	mov    0x14(%ebp),%eax
c01013f5:	01 d0                	add    %edx,%eax
c01013f7:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01013fc:	76 19                	jbe    c0101417 <ide_write_secs+0x87>
c01013fe:	68 2c 87 10 c0       	push   $0xc010872c
c0101403:	68 bf 86 10 c0       	push   $0xc01086bf
c0101408:	68 bd 00 00 00       	push   $0xbd
c010140d:	68 d4 86 10 c0       	push   $0xc01086d4
c0101412:	e8 d1 ef ff ff       	call   c01003e8 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101417:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010141b:	66 d1 e8             	shr    %ax
c010141e:	0f b7 c0             	movzwl %ax,%eax
c0101421:	0f b7 04 85 74 86 10 	movzwl -0x3fef798c(,%eax,4),%eax
c0101428:	c0 
c0101429:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010142d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101431:	66 d1 e8             	shr    %ax
c0101434:	0f b7 c0             	movzwl %ax,%eax
c0101437:	0f b7 04 85 76 86 10 	movzwl -0x3fef798a(,%eax,4),%eax
c010143e:	c0 
c010143f:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101443:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101447:	83 ec 08             	sub    $0x8,%esp
c010144a:	6a 00                	push   $0x0
c010144c:	50                   	push   %eax
c010144d:	e8 36 f9 ff ff       	call   c0100d88 <ide_wait_ready>
c0101452:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101455:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101459:	83 c0 02             	add    $0x2,%eax
c010145c:	0f b7 c0             	movzwl %ax,%eax
c010145f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101463:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101467:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c010146b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010146f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101470:	8b 45 14             	mov    0x14(%ebp),%eax
c0101473:	0f b6 c0             	movzbl %al,%eax
c0101476:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010147a:	83 c2 02             	add    $0x2,%edx
c010147d:	0f b7 d2             	movzwl %dx,%edx
c0101480:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c0101484:	88 45 d8             	mov    %al,-0x28(%ebp)
c0101487:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c010148b:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c010148f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101490:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101493:	0f b6 c0             	movzbl %al,%eax
c0101496:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010149a:	83 c2 03             	add    $0x3,%edx
c010149d:	0f b7 d2             	movzwl %dx,%edx
c01014a0:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01014a4:	88 45 d9             	mov    %al,-0x27(%ebp)
c01014a7:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01014ab:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01014af:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01014b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014b3:	c1 e8 08             	shr    $0x8,%eax
c01014b6:	0f b6 c0             	movzbl %al,%eax
c01014b9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014bd:	83 c2 04             	add    $0x4,%edx
c01014c0:	0f b7 d2             	movzwl %dx,%edx
c01014c3:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c01014c7:	88 45 da             	mov    %al,-0x26(%ebp)
c01014ca:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01014ce:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c01014d2:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01014d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014d6:	c1 e8 10             	shr    $0x10,%eax
c01014d9:	0f b6 c0             	movzbl %al,%eax
c01014dc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014e0:	83 c2 05             	add    $0x5,%edx
c01014e3:	0f b7 d2             	movzwl %dx,%edx
c01014e6:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01014ea:	88 45 db             	mov    %al,-0x25(%ebp)
c01014ed:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01014f1:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01014f5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01014f6:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01014fa:	83 e0 01             	and    $0x1,%eax
c01014fd:	c1 e0 04             	shl    $0x4,%eax
c0101500:	89 c2                	mov    %eax,%edx
c0101502:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101505:	c1 e8 18             	shr    $0x18,%eax
c0101508:	83 e0 0f             	and    $0xf,%eax
c010150b:	09 d0                	or     %edx,%eax
c010150d:	83 c8 e0             	or     $0xffffffe0,%eax
c0101510:	0f b6 c0             	movzbl %al,%eax
c0101513:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101517:	83 c2 06             	add    $0x6,%edx
c010151a:	0f b7 d2             	movzwl %dx,%edx
c010151d:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c0101521:	88 45 dc             	mov    %al,-0x24(%ebp)
c0101524:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101528:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c010152c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c010152d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101531:	83 c0 07             	add    $0x7,%eax
c0101534:	0f b7 c0             	movzwl %ax,%eax
c0101537:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c010153b:	c6 45 dd 30          	movb   $0x30,-0x23(%ebp)
c010153f:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101543:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101547:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101548:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010154f:	eb 56                	jmp    c01015a7 <ide_write_secs+0x217>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101551:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101555:	83 ec 08             	sub    $0x8,%esp
c0101558:	6a 01                	push   $0x1
c010155a:	50                   	push   %eax
c010155b:	e8 28 f8 ff ff       	call   c0100d88 <ide_wait_ready>
c0101560:	83 c4 10             	add    $0x10,%esp
c0101563:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101566:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010156a:	75 43                	jne    c01015af <ide_write_secs+0x21f>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c010156c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101570:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0101573:	8b 45 10             	mov    0x10(%ebp),%eax
c0101576:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101579:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0101580:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101583:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0101586:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0101589:	89 cb                	mov    %ecx,%ebx
c010158b:	89 de                	mov    %ebx,%esi
c010158d:	89 c1                	mov    %eax,%ecx
c010158f:	fc                   	cld    
c0101590:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101592:	89 c8                	mov    %ecx,%eax
c0101594:	89 f3                	mov    %esi,%ebx
c0101596:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c0101599:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010159c:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01015a0:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01015a7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01015ab:	75 a4                	jne    c0101551 <ide_write_secs+0x1c1>
c01015ad:	eb 01                	jmp    c01015b0 <ide_write_secs+0x220>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01015af:	90                   	nop
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01015b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01015b6:	5b                   	pop    %ebx
c01015b7:	5e                   	pop    %esi
c01015b8:	5d                   	pop    %ebp
c01015b9:	c3                   	ret    

c01015ba <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c01015ba:	55                   	push   %ebp
c01015bb:	89 e5                	mov    %esp,%ebp
c01015bd:	83 ec 18             	sub    $0x18,%esp
c01015c0:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c01015c6:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ca:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c01015ce:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01015d2:	ee                   	out    %al,(%dx)
c01015d3:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c01015d9:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c01015dd:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c01015e1:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c01015e5:	ee                   	out    %al,(%dx)
c01015e6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c01015ec:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c01015f0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01015f4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01015f8:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c01015f9:	c7 05 0c 30 12 c0 00 	movl   $0x0,0xc012300c
c0101600:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0101603:	83 ec 0c             	sub    $0xc,%esp
c0101606:	68 66 87 10 c0       	push   $0xc0108766
c010160b:	e8 72 ec ff ff       	call   c0100282 <cprintf>
c0101610:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c0101613:	83 ec 0c             	sub    $0xc,%esp
c0101616:	6a 00                	push   $0x0
c0101618:	e8 3b 09 00 00       	call   c0101f58 <pic_enable>
c010161d:	83 c4 10             	add    $0x10,%esp
}
c0101620:	90                   	nop
c0101621:	c9                   	leave  
c0101622:	c3                   	ret    

c0101623 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0101623:	55                   	push   %ebp
c0101624:	89 e5                	mov    %esp,%ebp
c0101626:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0101629:	9c                   	pushf  
c010162a:	58                   	pop    %eax
c010162b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010162e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0101631:	25 00 02 00 00       	and    $0x200,%eax
c0101636:	85 c0                	test   %eax,%eax
c0101638:	74 0c                	je     c0101646 <__intr_save+0x23>
        intr_disable();
c010163a:	e8 8a 0a 00 00       	call   c01020c9 <intr_disable>
        return 1;
c010163f:	b8 01 00 00 00       	mov    $0x1,%eax
c0101644:	eb 05                	jmp    c010164b <__intr_save+0x28>
    }
    return 0;
c0101646:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010164b:	c9                   	leave  
c010164c:	c3                   	ret    

c010164d <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010164d:	55                   	push   %ebp
c010164e:	89 e5                	mov    %esp,%ebp
c0101650:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0101653:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0101657:	74 05                	je     c010165e <__intr_restore+0x11>
        intr_enable();
c0101659:	e8 64 0a 00 00       	call   c01020c2 <intr_enable>
    }
}
c010165e:	90                   	nop
c010165f:	c9                   	leave  
c0101660:	c3                   	ret    

c0101661 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0101661:	55                   	push   %ebp
c0101662:	89 e5                	mov    %esp,%ebp
c0101664:	83 ec 10             	sub    $0x10,%esp
c0101667:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010166d:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0101671:	89 c2                	mov    %eax,%edx
c0101673:	ec                   	in     (%dx),%al
c0101674:	88 45 f4             	mov    %al,-0xc(%ebp)
c0101677:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c010167d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101681:	89 c2                	mov    %eax,%edx
c0101683:	ec                   	in     (%dx),%al
c0101684:	88 45 f5             	mov    %al,-0xb(%ebp)
c0101687:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c010168d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101691:	89 c2                	mov    %eax,%edx
c0101693:	ec                   	in     (%dx),%al
c0101694:	88 45 f6             	mov    %al,-0xa(%ebp)
c0101697:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c010169d:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c01016a1:	89 c2                	mov    %eax,%edx
c01016a3:	ec                   	in     (%dx),%al
c01016a4:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c01016a7:	90                   	nop
c01016a8:	c9                   	leave  
c01016a9:	c3                   	ret    

c01016aa <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c01016aa:	55                   	push   %ebp
c01016ab:	89 e5                	mov    %esp,%ebp
c01016ad:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c01016b0:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c01016b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016ba:	0f b7 00             	movzwl (%eax),%eax
c01016bd:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c01016c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016c4:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c01016c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016cc:	0f b7 00             	movzwl (%eax),%eax
c01016cf:	66 3d 5a a5          	cmp    $0xa55a,%ax
c01016d3:	74 12                	je     c01016e7 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c01016d5:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c01016dc:	66 c7 05 26 25 12 c0 	movw   $0x3b4,0xc0122526
c01016e3:	b4 03 
c01016e5:	eb 13                	jmp    c01016fa <cga_init+0x50>
    } else {
        *cp = was;
c01016e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016ea:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01016ee:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c01016f1:	66 c7 05 26 25 12 c0 	movw   $0x3d4,0xc0122526
c01016f8:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c01016fa:	0f b7 05 26 25 12 c0 	movzwl 0xc0122526,%eax
c0101701:	0f b7 c0             	movzwl %ax,%eax
c0101704:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0101708:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010170c:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101710:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0101714:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101715:	0f b7 05 26 25 12 c0 	movzwl 0xc0122526,%eax
c010171c:	83 c0 01             	add    $0x1,%eax
c010171f:	0f b7 c0             	movzwl %ax,%eax
c0101722:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101726:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010172a:	89 c2                	mov    %eax,%edx
c010172c:	ec                   	in     (%dx),%al
c010172d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101730:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0101734:	0f b6 c0             	movzbl %al,%eax
c0101737:	c1 e0 08             	shl    $0x8,%eax
c010173a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c010173d:	0f b7 05 26 25 12 c0 	movzwl 0xc0122526,%eax
c0101744:	0f b7 c0             	movzwl %ax,%eax
c0101747:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c010174b:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010174f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0101753:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0101757:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0101758:	0f b7 05 26 25 12 c0 	movzwl 0xc0122526,%eax
c010175f:	83 c0 01             	add    $0x1,%eax
c0101762:	0f b7 c0             	movzwl %ax,%eax
c0101765:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101769:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c010176d:	89 c2                	mov    %eax,%edx
c010176f:	ec                   	in     (%dx),%al
c0101770:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101773:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101777:	0f b6 c0             	movzbl %al,%eax
c010177a:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c010177d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101780:	a3 20 25 12 c0       	mov    %eax,0xc0122520
    crt_pos = pos;
c0101785:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101788:	66 a3 24 25 12 c0    	mov    %ax,0xc0122524
}
c010178e:	90                   	nop
c010178f:	c9                   	leave  
c0101790:	c3                   	ret    

c0101791 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0101791:	55                   	push   %ebp
c0101792:	89 e5                	mov    %esp,%ebp
c0101794:	83 ec 28             	sub    $0x28,%esp
c0101797:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c010179d:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017a1:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01017a5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017a9:	ee                   	out    %al,(%dx)
c01017aa:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c01017b0:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c01017b4:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01017b8:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c01017bc:	ee                   	out    %al,(%dx)
c01017bd:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c01017c3:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c01017c7:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c01017cb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017cf:	ee                   	out    %al,(%dx)
c01017d0:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c01017d6:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c01017da:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017de:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c01017e2:	ee                   	out    %al,(%dx)
c01017e3:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c01017e9:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c01017ed:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c01017f1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017f5:	ee                   	out    %al,(%dx)
c01017f6:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c01017fc:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0101800:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0101804:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0101808:	ee                   	out    %al,(%dx)
c0101809:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010180f:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0101813:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101817:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010181b:	ee                   	out    %al,(%dx)
c010181c:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101822:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
c0101826:	89 c2                	mov    %eax,%edx
c0101828:	ec                   	in     (%dx),%al
c0101829:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c010182c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101830:	3c ff                	cmp    $0xff,%al
c0101832:	0f 95 c0             	setne  %al
c0101835:	0f b6 c0             	movzbl %al,%eax
c0101838:	a3 28 25 12 c0       	mov    %eax,0xc0122528
c010183d:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101843:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101847:	89 c2                	mov    %eax,%edx
c0101849:	ec                   	in     (%dx),%al
c010184a:	88 45 e2             	mov    %al,-0x1e(%ebp)
c010184d:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c0101853:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
c0101857:	89 c2                	mov    %eax,%edx
c0101859:	ec                   	in     (%dx),%al
c010185a:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010185d:	a1 28 25 12 c0       	mov    0xc0122528,%eax
c0101862:	85 c0                	test   %eax,%eax
c0101864:	74 0d                	je     c0101873 <serial_init+0xe2>
        pic_enable(IRQ_COM1);
c0101866:	83 ec 0c             	sub    $0xc,%esp
c0101869:	6a 04                	push   $0x4
c010186b:	e8 e8 06 00 00       	call   c0101f58 <pic_enable>
c0101870:	83 c4 10             	add    $0x10,%esp
    }
}
c0101873:	90                   	nop
c0101874:	c9                   	leave  
c0101875:	c3                   	ret    

c0101876 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101876:	55                   	push   %ebp
c0101877:	89 e5                	mov    %esp,%ebp
c0101879:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010187c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101883:	eb 09                	jmp    c010188e <lpt_putc_sub+0x18>
        delay();
c0101885:	e8 d7 fd ff ff       	call   c0101661 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010188a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010188e:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c0101894:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0101898:	89 c2                	mov    %eax,%edx
c010189a:	ec                   	in     (%dx),%al
c010189b:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c010189e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01018a2:	84 c0                	test   %al,%al
c01018a4:	78 09                	js     c01018af <lpt_putc_sub+0x39>
c01018a6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01018ad:	7e d6                	jle    c0101885 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01018af:	8b 45 08             	mov    0x8(%ebp),%eax
c01018b2:	0f b6 c0             	movzbl %al,%eax
c01018b5:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c01018bb:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018be:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c01018c2:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c01018c6:	ee                   	out    %al,(%dx)
c01018c7:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01018cd:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01018d1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01018d5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018d9:	ee                   	out    %al,(%dx)
c01018da:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c01018e0:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c01018e4:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c01018e8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01018ec:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01018ed:	90                   	nop
c01018ee:	c9                   	leave  
c01018ef:	c3                   	ret    

c01018f0 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01018f0:	55                   	push   %ebp
c01018f1:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c01018f3:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01018f7:	74 0d                	je     c0101906 <lpt_putc+0x16>
        lpt_putc_sub(c);
c01018f9:	ff 75 08             	pushl  0x8(%ebp)
c01018fc:	e8 75 ff ff ff       	call   c0101876 <lpt_putc_sub>
c0101901:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101904:	eb 1e                	jmp    c0101924 <lpt_putc+0x34>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c0101906:	6a 08                	push   $0x8
c0101908:	e8 69 ff ff ff       	call   c0101876 <lpt_putc_sub>
c010190d:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
c0101910:	6a 20                	push   $0x20
c0101912:	e8 5f ff ff ff       	call   c0101876 <lpt_putc_sub>
c0101917:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
c010191a:	6a 08                	push   $0x8
c010191c:	e8 55 ff ff ff       	call   c0101876 <lpt_putc_sub>
c0101921:	83 c4 04             	add    $0x4,%esp
    }
}
c0101924:	90                   	nop
c0101925:	c9                   	leave  
c0101926:	c3                   	ret    

c0101927 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101927:	55                   	push   %ebp
c0101928:	89 e5                	mov    %esp,%ebp
c010192a:	53                   	push   %ebx
c010192b:	83 ec 14             	sub    $0x14,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010192e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101931:	b0 00                	mov    $0x0,%al
c0101933:	85 c0                	test   %eax,%eax
c0101935:	75 07                	jne    c010193e <cga_putc+0x17>
        c |= 0x0700;
c0101937:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010193e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101941:	0f b6 c0             	movzbl %al,%eax
c0101944:	83 f8 0a             	cmp    $0xa,%eax
c0101947:	74 4e                	je     c0101997 <cga_putc+0x70>
c0101949:	83 f8 0d             	cmp    $0xd,%eax
c010194c:	74 59                	je     c01019a7 <cga_putc+0x80>
c010194e:	83 f8 08             	cmp    $0x8,%eax
c0101951:	0f 85 8a 00 00 00    	jne    c01019e1 <cga_putc+0xba>
    case '\b':
        if (crt_pos > 0) {
c0101957:	0f b7 05 24 25 12 c0 	movzwl 0xc0122524,%eax
c010195e:	66 85 c0             	test   %ax,%ax
c0101961:	0f 84 a0 00 00 00    	je     c0101a07 <cga_putc+0xe0>
            crt_pos --;
c0101967:	0f b7 05 24 25 12 c0 	movzwl 0xc0122524,%eax
c010196e:	83 e8 01             	sub    $0x1,%eax
c0101971:	66 a3 24 25 12 c0    	mov    %ax,0xc0122524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101977:	a1 20 25 12 c0       	mov    0xc0122520,%eax
c010197c:	0f b7 15 24 25 12 c0 	movzwl 0xc0122524,%edx
c0101983:	0f b7 d2             	movzwl %dx,%edx
c0101986:	01 d2                	add    %edx,%edx
c0101988:	01 d0                	add    %edx,%eax
c010198a:	8b 55 08             	mov    0x8(%ebp),%edx
c010198d:	b2 00                	mov    $0x0,%dl
c010198f:	83 ca 20             	or     $0x20,%edx
c0101992:	66 89 10             	mov    %dx,(%eax)
        }
        break;
c0101995:	eb 70                	jmp    c0101a07 <cga_putc+0xe0>
    case '\n':
        crt_pos += CRT_COLS;
c0101997:	0f b7 05 24 25 12 c0 	movzwl 0xc0122524,%eax
c010199e:	83 c0 50             	add    $0x50,%eax
c01019a1:	66 a3 24 25 12 c0    	mov    %ax,0xc0122524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01019a7:	0f b7 1d 24 25 12 c0 	movzwl 0xc0122524,%ebx
c01019ae:	0f b7 0d 24 25 12 c0 	movzwl 0xc0122524,%ecx
c01019b5:	0f b7 c1             	movzwl %cx,%eax
c01019b8:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01019be:	c1 e8 10             	shr    $0x10,%eax
c01019c1:	89 c2                	mov    %eax,%edx
c01019c3:	66 c1 ea 06          	shr    $0x6,%dx
c01019c7:	89 d0                	mov    %edx,%eax
c01019c9:	c1 e0 02             	shl    $0x2,%eax
c01019cc:	01 d0                	add    %edx,%eax
c01019ce:	c1 e0 04             	shl    $0x4,%eax
c01019d1:	29 c1                	sub    %eax,%ecx
c01019d3:	89 ca                	mov    %ecx,%edx
c01019d5:	89 d8                	mov    %ebx,%eax
c01019d7:	29 d0                	sub    %edx,%eax
c01019d9:	66 a3 24 25 12 c0    	mov    %ax,0xc0122524
        break;
c01019df:	eb 27                	jmp    c0101a08 <cga_putc+0xe1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01019e1:	8b 0d 20 25 12 c0    	mov    0xc0122520,%ecx
c01019e7:	0f b7 05 24 25 12 c0 	movzwl 0xc0122524,%eax
c01019ee:	8d 50 01             	lea    0x1(%eax),%edx
c01019f1:	66 89 15 24 25 12 c0 	mov    %dx,0xc0122524
c01019f8:	0f b7 c0             	movzwl %ax,%eax
c01019fb:	01 c0                	add    %eax,%eax
c01019fd:	01 c8                	add    %ecx,%eax
c01019ff:	8b 55 08             	mov    0x8(%ebp),%edx
c0101a02:	66 89 10             	mov    %dx,(%eax)
        break;
c0101a05:	eb 01                	jmp    c0101a08 <cga_putc+0xe1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c0101a07:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101a08:	0f b7 05 24 25 12 c0 	movzwl 0xc0122524,%eax
c0101a0f:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101a13:	76 59                	jbe    c0101a6e <cga_putc+0x147>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101a15:	a1 20 25 12 c0       	mov    0xc0122520,%eax
c0101a1a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101a20:	a1 20 25 12 c0       	mov    0xc0122520,%eax
c0101a25:	83 ec 04             	sub    $0x4,%esp
c0101a28:	68 00 0f 00 00       	push   $0xf00
c0101a2d:	52                   	push   %edx
c0101a2e:	50                   	push   %eax
c0101a2f:	e8 f3 60 00 00       	call   c0107b27 <memmove>
c0101a34:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a37:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101a3e:	eb 15                	jmp    c0101a55 <cga_putc+0x12e>
            crt_buf[i] = 0x0700 | ' ';
c0101a40:	a1 20 25 12 c0       	mov    0xc0122520,%eax
c0101a45:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101a48:	01 d2                	add    %edx,%edx
c0101a4a:	01 d0                	add    %edx,%eax
c0101a4c:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a51:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101a55:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101a5c:	7e e2                	jle    c0101a40 <cga_putc+0x119>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101a5e:	0f b7 05 24 25 12 c0 	movzwl 0xc0122524,%eax
c0101a65:	83 e8 50             	sub    $0x50,%eax
c0101a68:	66 a3 24 25 12 c0    	mov    %ax,0xc0122524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101a6e:	0f b7 05 26 25 12 c0 	movzwl 0xc0122526,%eax
c0101a75:	0f b7 c0             	movzwl %ax,%eax
c0101a78:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101a7c:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c0101a80:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c0101a84:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101a88:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101a89:	0f b7 05 24 25 12 c0 	movzwl 0xc0122524,%eax
c0101a90:	66 c1 e8 08          	shr    $0x8,%ax
c0101a94:	0f b6 c0             	movzbl %al,%eax
c0101a97:	0f b7 15 26 25 12 c0 	movzwl 0xc0122526,%edx
c0101a9e:	83 c2 01             	add    $0x1,%edx
c0101aa1:	0f b7 d2             	movzwl %dx,%edx
c0101aa4:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0101aa8:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101aab:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101aaf:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0101ab3:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101ab4:	0f b7 05 26 25 12 c0 	movzwl 0xc0122526,%eax
c0101abb:	0f b7 c0             	movzwl %ax,%eax
c0101abe:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101ac2:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c0101ac6:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101aca:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101ace:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101acf:	0f b7 05 24 25 12 c0 	movzwl 0xc0122524,%eax
c0101ad6:	0f b6 c0             	movzbl %al,%eax
c0101ad9:	0f b7 15 26 25 12 c0 	movzwl 0xc0122526,%edx
c0101ae0:	83 c2 01             	add    $0x1,%edx
c0101ae3:	0f b7 d2             	movzwl %dx,%edx
c0101ae6:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c0101aea:	88 45 eb             	mov    %al,-0x15(%ebp)
c0101aed:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0101af1:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0101af5:	ee                   	out    %al,(%dx)
}
c0101af6:	90                   	nop
c0101af7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101afa:	c9                   	leave  
c0101afb:	c3                   	ret    

c0101afc <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101afc:	55                   	push   %ebp
c0101afd:	89 e5                	mov    %esp,%ebp
c0101aff:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b02:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101b09:	eb 09                	jmp    c0101b14 <serial_putc_sub+0x18>
        delay();
c0101b0b:	e8 51 fb ff ff       	call   c0101661 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b10:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101b14:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b1a:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0101b1e:	89 c2                	mov    %eax,%edx
c0101b20:	ec                   	in     (%dx),%al
c0101b21:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101b24:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0101b28:	0f b6 c0             	movzbl %al,%eax
c0101b2b:	83 e0 20             	and    $0x20,%eax
c0101b2e:	85 c0                	test   %eax,%eax
c0101b30:	75 09                	jne    c0101b3b <serial_putc_sub+0x3f>
c0101b32:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101b39:	7e d0                	jle    c0101b0b <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101b3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b3e:	0f b6 c0             	movzbl %al,%eax
c0101b41:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0101b47:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101b4a:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0101b4e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101b52:	ee                   	out    %al,(%dx)
}
c0101b53:	90                   	nop
c0101b54:	c9                   	leave  
c0101b55:	c3                   	ret    

c0101b56 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101b56:	55                   	push   %ebp
c0101b57:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0101b59:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101b5d:	74 0d                	je     c0101b6c <serial_putc+0x16>
        serial_putc_sub(c);
c0101b5f:	ff 75 08             	pushl  0x8(%ebp)
c0101b62:	e8 95 ff ff ff       	call   c0101afc <serial_putc_sub>
c0101b67:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101b6a:	eb 1e                	jmp    c0101b8a <serial_putc+0x34>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0101b6c:	6a 08                	push   $0x8
c0101b6e:	e8 89 ff ff ff       	call   c0101afc <serial_putc_sub>
c0101b73:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
c0101b76:	6a 20                	push   $0x20
c0101b78:	e8 7f ff ff ff       	call   c0101afc <serial_putc_sub>
c0101b7d:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
c0101b80:	6a 08                	push   $0x8
c0101b82:	e8 75 ff ff ff       	call   c0101afc <serial_putc_sub>
c0101b87:	83 c4 04             	add    $0x4,%esp
    }
}
c0101b8a:	90                   	nop
c0101b8b:	c9                   	leave  
c0101b8c:	c3                   	ret    

c0101b8d <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101b8d:	55                   	push   %ebp
c0101b8e:	89 e5                	mov    %esp,%ebp
c0101b90:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101b93:	eb 33                	jmp    c0101bc8 <cons_intr+0x3b>
        if (c != 0) {
c0101b95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101b99:	74 2d                	je     c0101bc8 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101b9b:	a1 44 27 12 c0       	mov    0xc0122744,%eax
c0101ba0:	8d 50 01             	lea    0x1(%eax),%edx
c0101ba3:	89 15 44 27 12 c0    	mov    %edx,0xc0122744
c0101ba9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101bac:	88 90 40 25 12 c0    	mov    %dl,-0x3feddac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101bb2:	a1 44 27 12 c0       	mov    0xc0122744,%eax
c0101bb7:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101bbc:	75 0a                	jne    c0101bc8 <cons_intr+0x3b>
                cons.wpos = 0;
c0101bbe:	c7 05 44 27 12 c0 00 	movl   $0x0,0xc0122744
c0101bc5:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bcb:	ff d0                	call   *%eax
c0101bcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101bd0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101bd4:	75 bf                	jne    c0101b95 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101bd6:	90                   	nop
c0101bd7:	c9                   	leave  
c0101bd8:	c3                   	ret    

c0101bd9 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101bd9:	55                   	push   %ebp
c0101bda:	89 e5                	mov    %esp,%ebp
c0101bdc:	83 ec 10             	sub    $0x10,%esp
c0101bdf:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101be5:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0101be9:	89 c2                	mov    %eax,%edx
c0101beb:	ec                   	in     (%dx),%al
c0101bec:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101bef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101bf3:	0f b6 c0             	movzbl %al,%eax
c0101bf6:	83 e0 01             	and    $0x1,%eax
c0101bf9:	85 c0                	test   %eax,%eax
c0101bfb:	75 07                	jne    c0101c04 <serial_proc_data+0x2b>
        return -1;
c0101bfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c02:	eb 2a                	jmp    c0101c2e <serial_proc_data+0x55>
c0101c04:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c0a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c0e:	89 c2                	mov    %eax,%edx
c0101c10:	ec                   	in     (%dx),%al
c0101c11:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c0101c14:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101c18:	0f b6 c0             	movzbl %al,%eax
c0101c1b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101c1e:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101c22:	75 07                	jne    c0101c2b <serial_proc_data+0x52>
        c = '\b';
c0101c24:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101c2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101c2e:	c9                   	leave  
c0101c2f:	c3                   	ret    

c0101c30 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101c30:	55                   	push   %ebp
c0101c31:	89 e5                	mov    %esp,%ebp
c0101c33:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
c0101c36:	a1 28 25 12 c0       	mov    0xc0122528,%eax
c0101c3b:	85 c0                	test   %eax,%eax
c0101c3d:	74 10                	je     c0101c4f <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c0101c3f:	83 ec 0c             	sub    $0xc,%esp
c0101c42:	68 d9 1b 10 c0       	push   $0xc0101bd9
c0101c47:	e8 41 ff ff ff       	call   c0101b8d <cons_intr>
c0101c4c:	83 c4 10             	add    $0x10,%esp
    }
}
c0101c4f:	90                   	nop
c0101c50:	c9                   	leave  
c0101c51:	c3                   	ret    

c0101c52 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101c52:	55                   	push   %ebp
c0101c53:	89 e5                	mov    %esp,%ebp
c0101c55:	83 ec 18             	sub    $0x18,%esp
c0101c58:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c5e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101c62:	89 c2                	mov    %eax,%edx
c0101c64:	ec                   	in     (%dx),%al
c0101c65:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101c68:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101c6c:	0f b6 c0             	movzbl %al,%eax
c0101c6f:	83 e0 01             	and    $0x1,%eax
c0101c72:	85 c0                	test   %eax,%eax
c0101c74:	75 0a                	jne    c0101c80 <kbd_proc_data+0x2e>
        return -1;
c0101c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c7b:	e9 5d 01 00 00       	jmp    c0101ddd <kbd_proc_data+0x18b>
c0101c80:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c86:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101c8a:	89 c2                	mov    %eax,%edx
c0101c8c:	ec                   	in     (%dx),%al
c0101c8d:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0101c90:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101c94:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101c97:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101c9b:	75 17                	jne    c0101cb4 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101c9d:	a1 48 27 12 c0       	mov    0xc0122748,%eax
c0101ca2:	83 c8 40             	or     $0x40,%eax
c0101ca5:	a3 48 27 12 c0       	mov    %eax,0xc0122748
        return 0;
c0101caa:	b8 00 00 00 00       	mov    $0x0,%eax
c0101caf:	e9 29 01 00 00       	jmp    c0101ddd <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
c0101cb4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101cb8:	84 c0                	test   %al,%al
c0101cba:	79 47                	jns    c0101d03 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101cbc:	a1 48 27 12 c0       	mov    0xc0122748,%eax
c0101cc1:	83 e0 40             	and    $0x40,%eax
c0101cc4:	85 c0                	test   %eax,%eax
c0101cc6:	75 09                	jne    c0101cd1 <kbd_proc_data+0x7f>
c0101cc8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101ccc:	83 e0 7f             	and    $0x7f,%eax
c0101ccf:	eb 04                	jmp    c0101cd5 <kbd_proc_data+0x83>
c0101cd1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101cd5:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101cd8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101cdc:	0f b6 80 40 f0 11 c0 	movzbl -0x3fee0fc0(%eax),%eax
c0101ce3:	83 c8 40             	or     $0x40,%eax
c0101ce6:	0f b6 c0             	movzbl %al,%eax
c0101ce9:	f7 d0                	not    %eax
c0101ceb:	89 c2                	mov    %eax,%edx
c0101ced:	a1 48 27 12 c0       	mov    0xc0122748,%eax
c0101cf2:	21 d0                	and    %edx,%eax
c0101cf4:	a3 48 27 12 c0       	mov    %eax,0xc0122748
        return 0;
c0101cf9:	b8 00 00 00 00       	mov    $0x0,%eax
c0101cfe:	e9 da 00 00 00       	jmp    c0101ddd <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
c0101d03:	a1 48 27 12 c0       	mov    0xc0122748,%eax
c0101d08:	83 e0 40             	and    $0x40,%eax
c0101d0b:	85 c0                	test   %eax,%eax
c0101d0d:	74 11                	je     c0101d20 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101d0f:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101d13:	a1 48 27 12 c0       	mov    0xc0122748,%eax
c0101d18:	83 e0 bf             	and    $0xffffffbf,%eax
c0101d1b:	a3 48 27 12 c0       	mov    %eax,0xc0122748
    }

    shift |= shiftcode[data];
c0101d20:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d24:	0f b6 80 40 f0 11 c0 	movzbl -0x3fee0fc0(%eax),%eax
c0101d2b:	0f b6 d0             	movzbl %al,%edx
c0101d2e:	a1 48 27 12 c0       	mov    0xc0122748,%eax
c0101d33:	09 d0                	or     %edx,%eax
c0101d35:	a3 48 27 12 c0       	mov    %eax,0xc0122748
    shift ^= togglecode[data];
c0101d3a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d3e:	0f b6 80 40 f1 11 c0 	movzbl -0x3fee0ec0(%eax),%eax
c0101d45:	0f b6 d0             	movzbl %al,%edx
c0101d48:	a1 48 27 12 c0       	mov    0xc0122748,%eax
c0101d4d:	31 d0                	xor    %edx,%eax
c0101d4f:	a3 48 27 12 c0       	mov    %eax,0xc0122748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101d54:	a1 48 27 12 c0       	mov    0xc0122748,%eax
c0101d59:	83 e0 03             	and    $0x3,%eax
c0101d5c:	8b 14 85 40 f5 11 c0 	mov    -0x3fee0ac0(,%eax,4),%edx
c0101d63:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d67:	01 d0                	add    %edx,%eax
c0101d69:	0f b6 00             	movzbl (%eax),%eax
c0101d6c:	0f b6 c0             	movzbl %al,%eax
c0101d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101d72:	a1 48 27 12 c0       	mov    0xc0122748,%eax
c0101d77:	83 e0 08             	and    $0x8,%eax
c0101d7a:	85 c0                	test   %eax,%eax
c0101d7c:	74 22                	je     c0101da0 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101d7e:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101d82:	7e 0c                	jle    c0101d90 <kbd_proc_data+0x13e>
c0101d84:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101d88:	7f 06                	jg     c0101d90 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101d8a:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101d8e:	eb 10                	jmp    c0101da0 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101d90:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101d94:	7e 0a                	jle    c0101da0 <kbd_proc_data+0x14e>
c0101d96:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101d9a:	7f 04                	jg     c0101da0 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101d9c:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101da0:	a1 48 27 12 c0       	mov    0xc0122748,%eax
c0101da5:	f7 d0                	not    %eax
c0101da7:	83 e0 06             	and    $0x6,%eax
c0101daa:	85 c0                	test   %eax,%eax
c0101dac:	75 2c                	jne    c0101dda <kbd_proc_data+0x188>
c0101dae:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101db5:	75 23                	jne    c0101dda <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
c0101db7:	83 ec 0c             	sub    $0xc,%esp
c0101dba:	68 81 87 10 c0       	push   $0xc0108781
c0101dbf:	e8 be e4 ff ff       	call   c0100282 <cprintf>
c0101dc4:	83 c4 10             	add    $0x10,%esp
c0101dc7:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c0101dcd:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101dd1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101dd5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101dd9:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101ddd:	c9                   	leave  
c0101dde:	c3                   	ret    

c0101ddf <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101ddf:	55                   	push   %ebp
c0101de0:	89 e5                	mov    %esp,%ebp
c0101de2:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
c0101de5:	83 ec 0c             	sub    $0xc,%esp
c0101de8:	68 52 1c 10 c0       	push   $0xc0101c52
c0101ded:	e8 9b fd ff ff       	call   c0101b8d <cons_intr>
c0101df2:	83 c4 10             	add    $0x10,%esp
}
c0101df5:	90                   	nop
c0101df6:	c9                   	leave  
c0101df7:	c3                   	ret    

c0101df8 <kbd_init>:

static void
kbd_init(void) {
c0101df8:	55                   	push   %ebp
c0101df9:	89 e5                	mov    %esp,%ebp
c0101dfb:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
c0101dfe:	e8 dc ff ff ff       	call   c0101ddf <kbd_intr>
    pic_enable(IRQ_KBD);
c0101e03:	83 ec 0c             	sub    $0xc,%esp
c0101e06:	6a 01                	push   $0x1
c0101e08:	e8 4b 01 00 00       	call   c0101f58 <pic_enable>
c0101e0d:	83 c4 10             	add    $0x10,%esp
}
c0101e10:	90                   	nop
c0101e11:	c9                   	leave  
c0101e12:	c3                   	ret    

c0101e13 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101e13:	55                   	push   %ebp
c0101e14:	89 e5                	mov    %esp,%ebp
c0101e16:	83 ec 08             	sub    $0x8,%esp
    cga_init();
c0101e19:	e8 8c f8 ff ff       	call   c01016aa <cga_init>
    serial_init();
c0101e1e:	e8 6e f9 ff ff       	call   c0101791 <serial_init>
    kbd_init();
c0101e23:	e8 d0 ff ff ff       	call   c0101df8 <kbd_init>
    if (!serial_exists) {
c0101e28:	a1 28 25 12 c0       	mov    0xc0122528,%eax
c0101e2d:	85 c0                	test   %eax,%eax
c0101e2f:	75 10                	jne    c0101e41 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c0101e31:	83 ec 0c             	sub    $0xc,%esp
c0101e34:	68 8d 87 10 c0       	push   $0xc010878d
c0101e39:	e8 44 e4 ff ff       	call   c0100282 <cprintf>
c0101e3e:	83 c4 10             	add    $0x10,%esp
    }
}
c0101e41:	90                   	nop
c0101e42:	c9                   	leave  
c0101e43:	c3                   	ret    

c0101e44 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101e44:	55                   	push   %ebp
c0101e45:	89 e5                	mov    %esp,%ebp
c0101e47:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101e4a:	e8 d4 f7 ff ff       	call   c0101623 <__intr_save>
c0101e4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101e52:	83 ec 0c             	sub    $0xc,%esp
c0101e55:	ff 75 08             	pushl  0x8(%ebp)
c0101e58:	e8 93 fa ff ff       	call   c01018f0 <lpt_putc>
c0101e5d:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
c0101e60:	83 ec 0c             	sub    $0xc,%esp
c0101e63:	ff 75 08             	pushl  0x8(%ebp)
c0101e66:	e8 bc fa ff ff       	call   c0101927 <cga_putc>
c0101e6b:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
c0101e6e:	83 ec 0c             	sub    $0xc,%esp
c0101e71:	ff 75 08             	pushl  0x8(%ebp)
c0101e74:	e8 dd fc ff ff       	call   c0101b56 <serial_putc>
c0101e79:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c0101e7c:	83 ec 0c             	sub    $0xc,%esp
c0101e7f:	ff 75 f4             	pushl  -0xc(%ebp)
c0101e82:	e8 c6 f7 ff ff       	call   c010164d <__intr_restore>
c0101e87:	83 c4 10             	add    $0x10,%esp
}
c0101e8a:	90                   	nop
c0101e8b:	c9                   	leave  
c0101e8c:	c3                   	ret    

c0101e8d <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101e8d:	55                   	push   %ebp
c0101e8e:	89 e5                	mov    %esp,%ebp
c0101e90:	83 ec 18             	sub    $0x18,%esp
    int c = 0;
c0101e93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101e9a:	e8 84 f7 ff ff       	call   c0101623 <__intr_save>
c0101e9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101ea2:	e8 89 fd ff ff       	call   c0101c30 <serial_intr>
        kbd_intr();
c0101ea7:	e8 33 ff ff ff       	call   c0101ddf <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101eac:	8b 15 40 27 12 c0    	mov    0xc0122740,%edx
c0101eb2:	a1 44 27 12 c0       	mov    0xc0122744,%eax
c0101eb7:	39 c2                	cmp    %eax,%edx
c0101eb9:	74 31                	je     c0101eec <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101ebb:	a1 40 27 12 c0       	mov    0xc0122740,%eax
c0101ec0:	8d 50 01             	lea    0x1(%eax),%edx
c0101ec3:	89 15 40 27 12 c0    	mov    %edx,0xc0122740
c0101ec9:	0f b6 80 40 25 12 c0 	movzbl -0x3feddac0(%eax),%eax
c0101ed0:	0f b6 c0             	movzbl %al,%eax
c0101ed3:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101ed6:	a1 40 27 12 c0       	mov    0xc0122740,%eax
c0101edb:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101ee0:	75 0a                	jne    c0101eec <cons_getc+0x5f>
                cons.rpos = 0;
c0101ee2:	c7 05 40 27 12 c0 00 	movl   $0x0,0xc0122740
c0101ee9:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101eec:	83 ec 0c             	sub    $0xc,%esp
c0101eef:	ff 75 f0             	pushl  -0x10(%ebp)
c0101ef2:	e8 56 f7 ff ff       	call   c010164d <__intr_restore>
c0101ef7:	83 c4 10             	add    $0x10,%esp
    return c;
c0101efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101efd:	c9                   	leave  
c0101efe:	c3                   	ret    

c0101eff <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101eff:	55                   	push   %ebp
c0101f00:	89 e5                	mov    %esp,%ebp
c0101f02:	83 ec 14             	sub    $0x14,%esp
c0101f05:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f08:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f0c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f10:	66 a3 50 f5 11 c0    	mov    %ax,0xc011f550
    if (did_init) {
c0101f16:	a1 4c 27 12 c0       	mov    0xc012274c,%eax
c0101f1b:	85 c0                	test   %eax,%eax
c0101f1d:	74 36                	je     c0101f55 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101f1f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f23:	0f b6 c0             	movzbl %al,%eax
c0101f26:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f2c:	88 45 fa             	mov    %al,-0x6(%ebp)
c0101f2f:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c0101f33:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f37:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f38:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f3c:	66 c1 e8 08          	shr    $0x8,%ax
c0101f40:	0f b6 c0             	movzbl %al,%eax
c0101f43:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101f49:	88 45 fb             	mov    %al,-0x5(%ebp)
c0101f4c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c0101f50:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101f54:	ee                   	out    %al,(%dx)
    }
}
c0101f55:	90                   	nop
c0101f56:	c9                   	leave  
c0101f57:	c3                   	ret    

c0101f58 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101f58:	55                   	push   %ebp
c0101f59:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
c0101f5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f5e:	ba 01 00 00 00       	mov    $0x1,%edx
c0101f63:	89 c1                	mov    %eax,%ecx
c0101f65:	d3 e2                	shl    %cl,%edx
c0101f67:	89 d0                	mov    %edx,%eax
c0101f69:	f7 d0                	not    %eax
c0101f6b:	89 c2                	mov    %eax,%edx
c0101f6d:	0f b7 05 50 f5 11 c0 	movzwl 0xc011f550,%eax
c0101f74:	21 d0                	and    %edx,%eax
c0101f76:	0f b7 c0             	movzwl %ax,%eax
c0101f79:	50                   	push   %eax
c0101f7a:	e8 80 ff ff ff       	call   c0101eff <pic_setmask>
c0101f7f:	83 c4 04             	add    $0x4,%esp
}
c0101f82:	90                   	nop
c0101f83:	c9                   	leave  
c0101f84:	c3                   	ret    

c0101f85 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101f85:	55                   	push   %ebp
c0101f86:	89 e5                	mov    %esp,%ebp
c0101f88:	83 ec 30             	sub    $0x30,%esp
    did_init = 1;
c0101f8b:	c7 05 4c 27 12 c0 01 	movl   $0x1,0xc012274c
c0101f92:	00 00 00 
c0101f95:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f9b:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c0101f9f:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c0101fa3:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101fa7:	ee                   	out    %al,(%dx)
c0101fa8:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101fae:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c0101fb2:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101fb6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101fba:	ee                   	out    %al,(%dx)
c0101fbb:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c0101fc1:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c0101fc5:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101fc9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101fcd:	ee                   	out    %al,(%dx)
c0101fce:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c0101fd4:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0101fd8:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101fdc:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0101fe0:	ee                   	out    %al,(%dx)
c0101fe1:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c0101fe7:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c0101feb:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0101fef:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101ff3:	ee                   	out    %al,(%dx)
c0101ff4:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c0101ffa:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c0101ffe:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0102002:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0102006:	ee                   	out    %al,(%dx)
c0102007:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c010200d:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c0102011:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0102015:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102019:	ee                   	out    %al,(%dx)
c010201a:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c0102020:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c0102024:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102028:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c010202c:	ee                   	out    %al,(%dx)
c010202d:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102033:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c0102037:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c010203b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010203f:	ee                   	out    %al,(%dx)
c0102040:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c0102046:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c010204a:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c010204e:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0102052:	ee                   	out    %al,(%dx)
c0102053:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c0102059:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c010205d:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0102061:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102065:	ee                   	out    %al,(%dx)
c0102066:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c010206c:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c0102070:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102074:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0102078:	ee                   	out    %al,(%dx)
c0102079:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c010207f:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c0102083:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c0102087:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010208b:	ee                   	out    %al,(%dx)
c010208c:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c0102092:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c0102096:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c010209a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c010209e:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010209f:	0f b7 05 50 f5 11 c0 	movzwl 0xc011f550,%eax
c01020a6:	66 83 f8 ff          	cmp    $0xffff,%ax
c01020aa:	74 13                	je     c01020bf <pic_init+0x13a>
        pic_setmask(irq_mask);
c01020ac:	0f b7 05 50 f5 11 c0 	movzwl 0xc011f550,%eax
c01020b3:	0f b7 c0             	movzwl %ax,%eax
c01020b6:	50                   	push   %eax
c01020b7:	e8 43 fe ff ff       	call   c0101eff <pic_setmask>
c01020bc:	83 c4 04             	add    $0x4,%esp
    }
}
c01020bf:	90                   	nop
c01020c0:	c9                   	leave  
c01020c1:	c3                   	ret    

c01020c2 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01020c2:	55                   	push   %ebp
c01020c3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01020c5:	fb                   	sti    
    sti();
}
c01020c6:	90                   	nop
c01020c7:	5d                   	pop    %ebp
c01020c8:	c3                   	ret    

c01020c9 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01020c9:	55                   	push   %ebp
c01020ca:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01020cc:	fa                   	cli    
    cli();
}
c01020cd:	90                   	nop
c01020ce:	5d                   	pop    %ebp
c01020cf:	c3                   	ret    

c01020d0 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01020d0:	55                   	push   %ebp
c01020d1:	89 e5                	mov    %esp,%ebp
c01020d3:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01020d6:	83 ec 08             	sub    $0x8,%esp
c01020d9:	6a 64                	push   $0x64
c01020db:	68 c0 87 10 c0       	push   $0xc01087c0
c01020e0:	e8 9d e1 ff ff       	call   c0100282 <cprintf>
c01020e5:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01020e8:	90                   	nop
c01020e9:	c9                   	leave  
c01020ea:	c3                   	ret    

c01020eb <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01020eb:	55                   	push   %ebp
c01020ec:	89 e5                	mov    %esp,%ebp
c01020ee:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01020f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01020f8:	e9 c3 00 00 00       	jmp    c01021c0 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01020fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102100:	8b 04 85 e0 f5 11 c0 	mov    -0x3fee0a20(,%eax,4),%eax
c0102107:	89 c2                	mov    %eax,%edx
c0102109:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010210c:	66 89 14 c5 60 27 12 	mov    %dx,-0x3fedd8a0(,%eax,8)
c0102113:	c0 
c0102114:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102117:	66 c7 04 c5 62 27 12 	movw   $0x8,-0x3fedd89e(,%eax,8)
c010211e:	c0 08 00 
c0102121:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102124:	0f b6 14 c5 64 27 12 	movzbl -0x3fedd89c(,%eax,8),%edx
c010212b:	c0 
c010212c:	83 e2 e0             	and    $0xffffffe0,%edx
c010212f:	88 14 c5 64 27 12 c0 	mov    %dl,-0x3fedd89c(,%eax,8)
c0102136:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102139:	0f b6 14 c5 64 27 12 	movzbl -0x3fedd89c(,%eax,8),%edx
c0102140:	c0 
c0102141:	83 e2 1f             	and    $0x1f,%edx
c0102144:	88 14 c5 64 27 12 c0 	mov    %dl,-0x3fedd89c(,%eax,8)
c010214b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010214e:	0f b6 14 c5 65 27 12 	movzbl -0x3fedd89b(,%eax,8),%edx
c0102155:	c0 
c0102156:	83 e2 f0             	and    $0xfffffff0,%edx
c0102159:	83 ca 0e             	or     $0xe,%edx
c010215c:	88 14 c5 65 27 12 c0 	mov    %dl,-0x3fedd89b(,%eax,8)
c0102163:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102166:	0f b6 14 c5 65 27 12 	movzbl -0x3fedd89b(,%eax,8),%edx
c010216d:	c0 
c010216e:	83 e2 ef             	and    $0xffffffef,%edx
c0102171:	88 14 c5 65 27 12 c0 	mov    %dl,-0x3fedd89b(,%eax,8)
c0102178:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010217b:	0f b6 14 c5 65 27 12 	movzbl -0x3fedd89b(,%eax,8),%edx
c0102182:	c0 
c0102183:	83 e2 9f             	and    $0xffffff9f,%edx
c0102186:	88 14 c5 65 27 12 c0 	mov    %dl,-0x3fedd89b(,%eax,8)
c010218d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102190:	0f b6 14 c5 65 27 12 	movzbl -0x3fedd89b(,%eax,8),%edx
c0102197:	c0 
c0102198:	83 ca 80             	or     $0xffffff80,%edx
c010219b:	88 14 c5 65 27 12 c0 	mov    %dl,-0x3fedd89b(,%eax,8)
c01021a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021a5:	8b 04 85 e0 f5 11 c0 	mov    -0x3fee0a20(,%eax,4),%eax
c01021ac:	c1 e8 10             	shr    $0x10,%eax
c01021af:	89 c2                	mov    %eax,%edx
c01021b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021b4:	66 89 14 c5 66 27 12 	mov    %dx,-0x3fedd89a(,%eax,8)
c01021bb:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01021bc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01021c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021c3:	3d ff 00 00 00       	cmp    $0xff,%eax
c01021c8:	0f 86 2f ff ff ff    	jbe    c01020fd <idt_init+0x12>
c01021ce:	c7 45 f8 60 f5 11 c0 	movl   $0xc011f560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01021d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01021d8:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c01021db:	90                   	nop
c01021dc:	c9                   	leave  
c01021dd:	c3                   	ret    

c01021de <trapname>:

static const char *
trapname(int trapno) {
c01021de:	55                   	push   %ebp
c01021df:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01021e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01021e4:	83 f8 13             	cmp    $0x13,%eax
c01021e7:	77 0c                	ja     c01021f5 <trapname+0x17>
        return excnames[trapno];
c01021e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01021ec:	8b 04 85 a0 8b 10 c0 	mov    -0x3fef7460(,%eax,4),%eax
c01021f3:	eb 18                	jmp    c010220d <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01021f5:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01021f9:	7e 0d                	jle    c0102208 <trapname+0x2a>
c01021fb:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01021ff:	7f 07                	jg     c0102208 <trapname+0x2a>
        return "Hardware Interrupt";
c0102201:	b8 ca 87 10 c0       	mov    $0xc01087ca,%eax
c0102206:	eb 05                	jmp    c010220d <trapname+0x2f>
    }
    return "(unknown trap)";
c0102208:	b8 dd 87 10 c0       	mov    $0xc01087dd,%eax
}
c010220d:	5d                   	pop    %ebp
c010220e:	c3                   	ret    

c010220f <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c010220f:	55                   	push   %ebp
c0102210:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0102212:	8b 45 08             	mov    0x8(%ebp),%eax
c0102215:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102219:	66 83 f8 08          	cmp    $0x8,%ax
c010221d:	0f 94 c0             	sete   %al
c0102220:	0f b6 c0             	movzbl %al,%eax
}
c0102223:	5d                   	pop    %ebp
c0102224:	c3                   	ret    

c0102225 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0102225:	55                   	push   %ebp
c0102226:	89 e5                	mov    %esp,%ebp
c0102228:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
c010222b:	83 ec 08             	sub    $0x8,%esp
c010222e:	ff 75 08             	pushl  0x8(%ebp)
c0102231:	68 1e 88 10 c0       	push   $0xc010881e
c0102236:	e8 47 e0 ff ff       	call   c0100282 <cprintf>
c010223b:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
c010223e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102241:	83 ec 0c             	sub    $0xc,%esp
c0102244:	50                   	push   %eax
c0102245:	e8 b8 01 00 00       	call   c0102402 <print_regs>
c010224a:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c010224d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102250:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0102254:	0f b7 c0             	movzwl %ax,%eax
c0102257:	83 ec 08             	sub    $0x8,%esp
c010225a:	50                   	push   %eax
c010225b:	68 2f 88 10 c0       	push   $0xc010882f
c0102260:	e8 1d e0 ff ff       	call   c0100282 <cprintf>
c0102265:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102268:	8b 45 08             	mov    0x8(%ebp),%eax
c010226b:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c010226f:	0f b7 c0             	movzwl %ax,%eax
c0102272:	83 ec 08             	sub    $0x8,%esp
c0102275:	50                   	push   %eax
c0102276:	68 42 88 10 c0       	push   $0xc0108842
c010227b:	e8 02 e0 ff ff       	call   c0100282 <cprintf>
c0102280:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102283:	8b 45 08             	mov    0x8(%ebp),%eax
c0102286:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010228a:	0f b7 c0             	movzwl %ax,%eax
c010228d:	83 ec 08             	sub    $0x8,%esp
c0102290:	50                   	push   %eax
c0102291:	68 55 88 10 c0       	push   $0xc0108855
c0102296:	e8 e7 df ff ff       	call   c0100282 <cprintf>
c010229b:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010229e:	8b 45 08             	mov    0x8(%ebp),%eax
c01022a1:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c01022a5:	0f b7 c0             	movzwl %ax,%eax
c01022a8:	83 ec 08             	sub    $0x8,%esp
c01022ab:	50                   	push   %eax
c01022ac:	68 68 88 10 c0       	push   $0xc0108868
c01022b1:	e8 cc df ff ff       	call   c0100282 <cprintf>
c01022b6:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01022b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01022bc:	8b 40 30             	mov    0x30(%eax),%eax
c01022bf:	83 ec 0c             	sub    $0xc,%esp
c01022c2:	50                   	push   %eax
c01022c3:	e8 16 ff ff ff       	call   c01021de <trapname>
c01022c8:	83 c4 10             	add    $0x10,%esp
c01022cb:	89 c2                	mov    %eax,%edx
c01022cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01022d0:	8b 40 30             	mov    0x30(%eax),%eax
c01022d3:	83 ec 04             	sub    $0x4,%esp
c01022d6:	52                   	push   %edx
c01022d7:	50                   	push   %eax
c01022d8:	68 7b 88 10 c0       	push   $0xc010887b
c01022dd:	e8 a0 df ff ff       	call   c0100282 <cprintf>
c01022e2:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
c01022e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01022e8:	8b 40 34             	mov    0x34(%eax),%eax
c01022eb:	83 ec 08             	sub    $0x8,%esp
c01022ee:	50                   	push   %eax
c01022ef:	68 8d 88 10 c0       	push   $0xc010888d
c01022f4:	e8 89 df ff ff       	call   c0100282 <cprintf>
c01022f9:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01022fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01022ff:	8b 40 38             	mov    0x38(%eax),%eax
c0102302:	83 ec 08             	sub    $0x8,%esp
c0102305:	50                   	push   %eax
c0102306:	68 9c 88 10 c0       	push   $0xc010889c
c010230b:	e8 72 df ff ff       	call   c0100282 <cprintf>
c0102310:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0102313:	8b 45 08             	mov    0x8(%ebp),%eax
c0102316:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010231a:	0f b7 c0             	movzwl %ax,%eax
c010231d:	83 ec 08             	sub    $0x8,%esp
c0102320:	50                   	push   %eax
c0102321:	68 ab 88 10 c0       	push   $0xc01088ab
c0102326:	e8 57 df ff ff       	call   c0100282 <cprintf>
c010232b:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c010232e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102331:	8b 40 40             	mov    0x40(%eax),%eax
c0102334:	83 ec 08             	sub    $0x8,%esp
c0102337:	50                   	push   %eax
c0102338:	68 be 88 10 c0       	push   $0xc01088be
c010233d:	e8 40 df ff ff       	call   c0100282 <cprintf>
c0102342:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010234c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102353:	eb 3f                	jmp    c0102394 <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102355:	8b 45 08             	mov    0x8(%ebp),%eax
c0102358:	8b 50 40             	mov    0x40(%eax),%edx
c010235b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010235e:	21 d0                	and    %edx,%eax
c0102360:	85 c0                	test   %eax,%eax
c0102362:	74 29                	je     c010238d <print_trapframe+0x168>
c0102364:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102367:	8b 04 85 80 f5 11 c0 	mov    -0x3fee0a80(,%eax,4),%eax
c010236e:	85 c0                	test   %eax,%eax
c0102370:	74 1b                	je     c010238d <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
c0102372:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102375:	8b 04 85 80 f5 11 c0 	mov    -0x3fee0a80(,%eax,4),%eax
c010237c:	83 ec 08             	sub    $0x8,%esp
c010237f:	50                   	push   %eax
c0102380:	68 cd 88 10 c0       	push   $0xc01088cd
c0102385:	e8 f8 de ff ff       	call   c0100282 <cprintf>
c010238a:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010238d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102391:	d1 65 f0             	shll   -0x10(%ebp)
c0102394:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102397:	83 f8 17             	cmp    $0x17,%eax
c010239a:	76 b9                	jbe    c0102355 <print_trapframe+0x130>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010239c:	8b 45 08             	mov    0x8(%ebp),%eax
c010239f:	8b 40 40             	mov    0x40(%eax),%eax
c01023a2:	25 00 30 00 00       	and    $0x3000,%eax
c01023a7:	c1 e8 0c             	shr    $0xc,%eax
c01023aa:	83 ec 08             	sub    $0x8,%esp
c01023ad:	50                   	push   %eax
c01023ae:	68 d1 88 10 c0       	push   $0xc01088d1
c01023b3:	e8 ca de ff ff       	call   c0100282 <cprintf>
c01023b8:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
c01023bb:	83 ec 0c             	sub    $0xc,%esp
c01023be:	ff 75 08             	pushl  0x8(%ebp)
c01023c1:	e8 49 fe ff ff       	call   c010220f <trap_in_kernel>
c01023c6:	83 c4 10             	add    $0x10,%esp
c01023c9:	85 c0                	test   %eax,%eax
c01023cb:	75 32                	jne    c01023ff <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01023cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d0:	8b 40 44             	mov    0x44(%eax),%eax
c01023d3:	83 ec 08             	sub    $0x8,%esp
c01023d6:	50                   	push   %eax
c01023d7:	68 da 88 10 c0       	push   $0xc01088da
c01023dc:	e8 a1 de ff ff       	call   c0100282 <cprintf>
c01023e1:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01023e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e7:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01023eb:	0f b7 c0             	movzwl %ax,%eax
c01023ee:	83 ec 08             	sub    $0x8,%esp
c01023f1:	50                   	push   %eax
c01023f2:	68 e9 88 10 c0       	push   $0xc01088e9
c01023f7:	e8 86 de ff ff       	call   c0100282 <cprintf>
c01023fc:	83 c4 10             	add    $0x10,%esp
    }
}
c01023ff:	90                   	nop
c0102400:	c9                   	leave  
c0102401:	c3                   	ret    

c0102402 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102402:	55                   	push   %ebp
c0102403:	89 e5                	mov    %esp,%ebp
c0102405:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102408:	8b 45 08             	mov    0x8(%ebp),%eax
c010240b:	8b 00                	mov    (%eax),%eax
c010240d:	83 ec 08             	sub    $0x8,%esp
c0102410:	50                   	push   %eax
c0102411:	68 fc 88 10 c0       	push   $0xc01088fc
c0102416:	e8 67 de ff ff       	call   c0100282 <cprintf>
c010241b:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010241e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102421:	8b 40 04             	mov    0x4(%eax),%eax
c0102424:	83 ec 08             	sub    $0x8,%esp
c0102427:	50                   	push   %eax
c0102428:	68 0b 89 10 c0       	push   $0xc010890b
c010242d:	e8 50 de ff ff       	call   c0100282 <cprintf>
c0102432:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102435:	8b 45 08             	mov    0x8(%ebp),%eax
c0102438:	8b 40 08             	mov    0x8(%eax),%eax
c010243b:	83 ec 08             	sub    $0x8,%esp
c010243e:	50                   	push   %eax
c010243f:	68 1a 89 10 c0       	push   $0xc010891a
c0102444:	e8 39 de ff ff       	call   c0100282 <cprintf>
c0102449:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c010244c:	8b 45 08             	mov    0x8(%ebp),%eax
c010244f:	8b 40 0c             	mov    0xc(%eax),%eax
c0102452:	83 ec 08             	sub    $0x8,%esp
c0102455:	50                   	push   %eax
c0102456:	68 29 89 10 c0       	push   $0xc0108929
c010245b:	e8 22 de ff ff       	call   c0100282 <cprintf>
c0102460:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102463:	8b 45 08             	mov    0x8(%ebp),%eax
c0102466:	8b 40 10             	mov    0x10(%eax),%eax
c0102469:	83 ec 08             	sub    $0x8,%esp
c010246c:	50                   	push   %eax
c010246d:	68 38 89 10 c0       	push   $0xc0108938
c0102472:	e8 0b de ff ff       	call   c0100282 <cprintf>
c0102477:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010247a:	8b 45 08             	mov    0x8(%ebp),%eax
c010247d:	8b 40 14             	mov    0x14(%eax),%eax
c0102480:	83 ec 08             	sub    $0x8,%esp
c0102483:	50                   	push   %eax
c0102484:	68 47 89 10 c0       	push   $0xc0108947
c0102489:	e8 f4 dd ff ff       	call   c0100282 <cprintf>
c010248e:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102491:	8b 45 08             	mov    0x8(%ebp),%eax
c0102494:	8b 40 18             	mov    0x18(%eax),%eax
c0102497:	83 ec 08             	sub    $0x8,%esp
c010249a:	50                   	push   %eax
c010249b:	68 56 89 10 c0       	push   $0xc0108956
c01024a0:	e8 dd dd ff ff       	call   c0100282 <cprintf>
c01024a5:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c01024a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ab:	8b 40 1c             	mov    0x1c(%eax),%eax
c01024ae:	83 ec 08             	sub    $0x8,%esp
c01024b1:	50                   	push   %eax
c01024b2:	68 65 89 10 c0       	push   $0xc0108965
c01024b7:	e8 c6 dd ff ff       	call   c0100282 <cprintf>
c01024bc:	83 c4 10             	add    $0x10,%esp
}
c01024bf:	90                   	nop
c01024c0:	c9                   	leave  
c01024c1:	c3                   	ret    

c01024c2 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c01024c2:	55                   	push   %ebp
c01024c3:	89 e5                	mov    %esp,%ebp
c01024c5:	53                   	push   %ebx
c01024c6:	83 ec 14             	sub    $0x14,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c01024c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01024cc:	8b 40 34             	mov    0x34(%eax),%eax
c01024cf:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01024d2:	85 c0                	test   %eax,%eax
c01024d4:	74 07                	je     c01024dd <print_pgfault+0x1b>
c01024d6:	bb 74 89 10 c0       	mov    $0xc0108974,%ebx
c01024db:	eb 05                	jmp    c01024e2 <print_pgfault+0x20>
c01024dd:	bb 85 89 10 c0       	mov    $0xc0108985,%ebx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c01024e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e5:	8b 40 34             	mov    0x34(%eax),%eax
c01024e8:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01024eb:	85 c0                	test   %eax,%eax
c01024ed:	74 07                	je     c01024f6 <print_pgfault+0x34>
c01024ef:	b9 57 00 00 00       	mov    $0x57,%ecx
c01024f4:	eb 05                	jmp    c01024fb <print_pgfault+0x39>
c01024f6:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c01024fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01024fe:	8b 40 34             	mov    0x34(%eax),%eax
c0102501:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102504:	85 c0                	test   %eax,%eax
c0102506:	74 07                	je     c010250f <print_pgfault+0x4d>
c0102508:	ba 55 00 00 00       	mov    $0x55,%edx
c010250d:	eb 05                	jmp    c0102514 <print_pgfault+0x52>
c010250f:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102514:	0f 20 d0             	mov    %cr2,%eax
c0102517:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010251a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010251d:	83 ec 0c             	sub    $0xc,%esp
c0102520:	53                   	push   %ebx
c0102521:	51                   	push   %ecx
c0102522:	52                   	push   %edx
c0102523:	50                   	push   %eax
c0102524:	68 94 89 10 c0       	push   $0xc0108994
c0102529:	e8 54 dd ff ff       	call   c0100282 <cprintf>
c010252e:	83 c4 20             	add    $0x20,%esp
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c0102531:	90                   	nop
c0102532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102535:	c9                   	leave  
c0102536:	c3                   	ret    

c0102537 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c0102537:	55                   	push   %ebp
c0102538:	89 e5                	mov    %esp,%ebp
c010253a:	83 ec 18             	sub    $0x18,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c010253d:	83 ec 0c             	sub    $0xc,%esp
c0102540:	ff 75 08             	pushl  0x8(%ebp)
c0102543:	e8 7a ff ff ff       	call   c01024c2 <print_pgfault>
c0102548:	83 c4 10             	add    $0x10,%esp
    if (check_mm_struct != NULL) {
c010254b:	a1 10 30 12 c0       	mov    0xc0123010,%eax
c0102550:	85 c0                	test   %eax,%eax
c0102552:	74 24                	je     c0102578 <pgfault_handler+0x41>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102554:	0f 20 d0             	mov    %cr2,%eax
c0102557:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010255a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c010255d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102560:	8b 50 34             	mov    0x34(%eax),%edx
c0102563:	a1 10 30 12 c0       	mov    0xc0123010,%eax
c0102568:	83 ec 04             	sub    $0x4,%esp
c010256b:	51                   	push   %ecx
c010256c:	52                   	push   %edx
c010256d:	50                   	push   %eax
c010256e:	e8 92 16 00 00       	call   c0103c05 <do_pgfault>
c0102573:	83 c4 10             	add    $0x10,%esp
c0102576:	eb 17                	jmp    c010258f <pgfault_handler+0x58>
    }
    panic("unhandled page fault.\n");
c0102578:	83 ec 04             	sub    $0x4,%esp
c010257b:	68 b7 89 10 c0       	push   $0xc01089b7
c0102580:	68 a5 00 00 00       	push   $0xa5
c0102585:	68 ce 89 10 c0       	push   $0xc01089ce
c010258a:	e8 59 de ff ff       	call   c01003e8 <__panic>
}
c010258f:	c9                   	leave  
c0102590:	c3                   	ret    

c0102591 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0102591:	55                   	push   %ebp
c0102592:	89 e5                	mov    %esp,%ebp
c0102594:	83 ec 18             	sub    $0x18,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102597:	8b 45 08             	mov    0x8(%ebp),%eax
c010259a:	8b 40 30             	mov    0x30(%eax),%eax
c010259d:	83 f8 24             	cmp    $0x24,%eax
c01025a0:	0f 84 ba 00 00 00    	je     c0102660 <trap_dispatch+0xcf>
c01025a6:	83 f8 24             	cmp    $0x24,%eax
c01025a9:	77 18                	ja     c01025c3 <trap_dispatch+0x32>
c01025ab:	83 f8 20             	cmp    $0x20,%eax
c01025ae:	74 76                	je     c0102626 <trap_dispatch+0x95>
c01025b0:	83 f8 21             	cmp    $0x21,%eax
c01025b3:	0f 84 cb 00 00 00    	je     c0102684 <trap_dispatch+0xf3>
c01025b9:	83 f8 0e             	cmp    $0xe,%eax
c01025bc:	74 28                	je     c01025e6 <trap_dispatch+0x55>
c01025be:	e9 fc 00 00 00       	jmp    c01026bf <trap_dispatch+0x12e>
c01025c3:	83 f8 2e             	cmp    $0x2e,%eax
c01025c6:	0f 82 f3 00 00 00    	jb     c01026bf <trap_dispatch+0x12e>
c01025cc:	83 f8 2f             	cmp    $0x2f,%eax
c01025cf:	0f 86 20 01 00 00    	jbe    c01026f5 <trap_dispatch+0x164>
c01025d5:	83 e8 78             	sub    $0x78,%eax
c01025d8:	83 f8 01             	cmp    $0x1,%eax
c01025db:	0f 87 de 00 00 00    	ja     c01026bf <trap_dispatch+0x12e>
c01025e1:	e9 c2 00 00 00       	jmp    c01026a8 <trap_dispatch+0x117>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01025e6:	83 ec 0c             	sub    $0xc,%esp
c01025e9:	ff 75 08             	pushl  0x8(%ebp)
c01025ec:	e8 46 ff ff ff       	call   c0102537 <pgfault_handler>
c01025f1:	83 c4 10             	add    $0x10,%esp
c01025f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01025f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01025fb:	0f 84 f7 00 00 00    	je     c01026f8 <trap_dispatch+0x167>
            print_trapframe(tf);
c0102601:	83 ec 0c             	sub    $0xc,%esp
c0102604:	ff 75 08             	pushl  0x8(%ebp)
c0102607:	e8 19 fc ff ff       	call   c0102225 <print_trapframe>
c010260c:	83 c4 10             	add    $0x10,%esp
            panic("handle pgfault failed. %e\n", ret);
c010260f:	ff 75 f4             	pushl  -0xc(%ebp)
c0102612:	68 df 89 10 c0       	push   $0xc01089df
c0102617:	68 b5 00 00 00       	push   $0xb5
c010261c:	68 ce 89 10 c0       	push   $0xc01089ce
c0102621:	e8 c2 dd ff ff       	call   c01003e8 <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0102626:	a1 0c 30 12 c0       	mov    0xc012300c,%eax
c010262b:	83 c0 01             	add    $0x1,%eax
c010262e:	a3 0c 30 12 c0       	mov    %eax,0xc012300c
        if (ticks % TICK_NUM == 0) {
c0102633:	8b 0d 0c 30 12 c0    	mov    0xc012300c,%ecx
c0102639:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c010263e:	89 c8                	mov    %ecx,%eax
c0102640:	f7 e2                	mul    %edx
c0102642:	89 d0                	mov    %edx,%eax
c0102644:	c1 e8 05             	shr    $0x5,%eax
c0102647:	6b c0 64             	imul   $0x64,%eax,%eax
c010264a:	29 c1                	sub    %eax,%ecx
c010264c:	89 c8                	mov    %ecx,%eax
c010264e:	85 c0                	test   %eax,%eax
c0102650:	0f 85 a5 00 00 00    	jne    c01026fb <trap_dispatch+0x16a>
            print_ticks();
c0102656:	e8 75 fa ff ff       	call   c01020d0 <print_ticks>
        }
        break;
c010265b:	e9 9b 00 00 00       	jmp    c01026fb <trap_dispatch+0x16a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102660:	e8 28 f8 ff ff       	call   c0101e8d <cons_getc>
c0102665:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102668:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c010266c:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102670:	83 ec 04             	sub    $0x4,%esp
c0102673:	52                   	push   %edx
c0102674:	50                   	push   %eax
c0102675:	68 fa 89 10 c0       	push   $0xc01089fa
c010267a:	e8 03 dc ff ff       	call   c0100282 <cprintf>
c010267f:	83 c4 10             	add    $0x10,%esp
        break;
c0102682:	eb 78                	jmp    c01026fc <trap_dispatch+0x16b>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102684:	e8 04 f8 ff ff       	call   c0101e8d <cons_getc>
c0102689:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c010268c:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102690:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102694:	83 ec 04             	sub    $0x4,%esp
c0102697:	52                   	push   %edx
c0102698:	50                   	push   %eax
c0102699:	68 0c 8a 10 c0       	push   $0xc0108a0c
c010269e:	e8 df db ff ff       	call   c0100282 <cprintf>
c01026a3:	83 c4 10             	add    $0x10,%esp
        break;
c01026a6:	eb 54                	jmp    c01026fc <trap_dispatch+0x16b>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c01026a8:	83 ec 04             	sub    $0x4,%esp
c01026ab:	68 1b 8a 10 c0       	push   $0xc0108a1b
c01026b0:	68 d3 00 00 00       	push   $0xd3
c01026b5:	68 ce 89 10 c0       	push   $0xc01089ce
c01026ba:	e8 29 dd ff ff       	call   c01003e8 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c01026bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01026c2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01026c6:	0f b7 c0             	movzwl %ax,%eax
c01026c9:	83 e0 03             	and    $0x3,%eax
c01026cc:	85 c0                	test   %eax,%eax
c01026ce:	75 2c                	jne    c01026fc <trap_dispatch+0x16b>
            print_trapframe(tf);
c01026d0:	83 ec 0c             	sub    $0xc,%esp
c01026d3:	ff 75 08             	pushl  0x8(%ebp)
c01026d6:	e8 4a fb ff ff       	call   c0102225 <print_trapframe>
c01026db:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
c01026de:	83 ec 04             	sub    $0x4,%esp
c01026e1:	68 2b 8a 10 c0       	push   $0xc0108a2b
c01026e6:	68 dd 00 00 00       	push   $0xdd
c01026eb:	68 ce 89 10 c0       	push   $0xc01089ce
c01026f0:	e8 f3 dc ff ff       	call   c01003e8 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c01026f5:	90                   	nop
c01026f6:	eb 04                	jmp    c01026fc <trap_dispatch+0x16b>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
c01026f8:	90                   	nop
c01026f9:	eb 01                	jmp    c01026fc <trap_dispatch+0x16b>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
c01026fb:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c01026fc:	90                   	nop
c01026fd:	c9                   	leave  
c01026fe:	c3                   	ret    

c01026ff <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01026ff:	55                   	push   %ebp
c0102700:	89 e5                	mov    %esp,%ebp
c0102702:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0102705:	83 ec 0c             	sub    $0xc,%esp
c0102708:	ff 75 08             	pushl  0x8(%ebp)
c010270b:	e8 81 fe ff ff       	call   c0102591 <trap_dispatch>
c0102710:	83 c4 10             	add    $0x10,%esp
}
c0102713:	90                   	nop
c0102714:	c9                   	leave  
c0102715:	c3                   	ret    

c0102716 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102716:	6a 00                	push   $0x0
  pushl $0
c0102718:	6a 00                	push   $0x0
  jmp __alltraps
c010271a:	e9 67 0a 00 00       	jmp    c0103186 <__alltraps>

c010271f <vector1>:
.globl vector1
vector1:
  pushl $0
c010271f:	6a 00                	push   $0x0
  pushl $1
c0102721:	6a 01                	push   $0x1
  jmp __alltraps
c0102723:	e9 5e 0a 00 00       	jmp    c0103186 <__alltraps>

c0102728 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102728:	6a 00                	push   $0x0
  pushl $2
c010272a:	6a 02                	push   $0x2
  jmp __alltraps
c010272c:	e9 55 0a 00 00       	jmp    c0103186 <__alltraps>

c0102731 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102731:	6a 00                	push   $0x0
  pushl $3
c0102733:	6a 03                	push   $0x3
  jmp __alltraps
c0102735:	e9 4c 0a 00 00       	jmp    c0103186 <__alltraps>

c010273a <vector4>:
.globl vector4
vector4:
  pushl $0
c010273a:	6a 00                	push   $0x0
  pushl $4
c010273c:	6a 04                	push   $0x4
  jmp __alltraps
c010273e:	e9 43 0a 00 00       	jmp    c0103186 <__alltraps>

c0102743 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102743:	6a 00                	push   $0x0
  pushl $5
c0102745:	6a 05                	push   $0x5
  jmp __alltraps
c0102747:	e9 3a 0a 00 00       	jmp    c0103186 <__alltraps>

c010274c <vector6>:
.globl vector6
vector6:
  pushl $0
c010274c:	6a 00                	push   $0x0
  pushl $6
c010274e:	6a 06                	push   $0x6
  jmp __alltraps
c0102750:	e9 31 0a 00 00       	jmp    c0103186 <__alltraps>

c0102755 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102755:	6a 00                	push   $0x0
  pushl $7
c0102757:	6a 07                	push   $0x7
  jmp __alltraps
c0102759:	e9 28 0a 00 00       	jmp    c0103186 <__alltraps>

c010275e <vector8>:
.globl vector8
vector8:
  pushl $8
c010275e:	6a 08                	push   $0x8
  jmp __alltraps
c0102760:	e9 21 0a 00 00       	jmp    c0103186 <__alltraps>

c0102765 <vector9>:
.globl vector9
vector9:
  pushl $9
c0102765:	6a 09                	push   $0x9
  jmp __alltraps
c0102767:	e9 1a 0a 00 00       	jmp    c0103186 <__alltraps>

c010276c <vector10>:
.globl vector10
vector10:
  pushl $10
c010276c:	6a 0a                	push   $0xa
  jmp __alltraps
c010276e:	e9 13 0a 00 00       	jmp    c0103186 <__alltraps>

c0102773 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102773:	6a 0b                	push   $0xb
  jmp __alltraps
c0102775:	e9 0c 0a 00 00       	jmp    c0103186 <__alltraps>

c010277a <vector12>:
.globl vector12
vector12:
  pushl $12
c010277a:	6a 0c                	push   $0xc
  jmp __alltraps
c010277c:	e9 05 0a 00 00       	jmp    c0103186 <__alltraps>

c0102781 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102781:	6a 0d                	push   $0xd
  jmp __alltraps
c0102783:	e9 fe 09 00 00       	jmp    c0103186 <__alltraps>

c0102788 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102788:	6a 0e                	push   $0xe
  jmp __alltraps
c010278a:	e9 f7 09 00 00       	jmp    c0103186 <__alltraps>

c010278f <vector15>:
.globl vector15
vector15:
  pushl $0
c010278f:	6a 00                	push   $0x0
  pushl $15
c0102791:	6a 0f                	push   $0xf
  jmp __alltraps
c0102793:	e9 ee 09 00 00       	jmp    c0103186 <__alltraps>

c0102798 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102798:	6a 00                	push   $0x0
  pushl $16
c010279a:	6a 10                	push   $0x10
  jmp __alltraps
c010279c:	e9 e5 09 00 00       	jmp    c0103186 <__alltraps>

c01027a1 <vector17>:
.globl vector17
vector17:
  pushl $17
c01027a1:	6a 11                	push   $0x11
  jmp __alltraps
c01027a3:	e9 de 09 00 00       	jmp    c0103186 <__alltraps>

c01027a8 <vector18>:
.globl vector18
vector18:
  pushl $0
c01027a8:	6a 00                	push   $0x0
  pushl $18
c01027aa:	6a 12                	push   $0x12
  jmp __alltraps
c01027ac:	e9 d5 09 00 00       	jmp    c0103186 <__alltraps>

c01027b1 <vector19>:
.globl vector19
vector19:
  pushl $0
c01027b1:	6a 00                	push   $0x0
  pushl $19
c01027b3:	6a 13                	push   $0x13
  jmp __alltraps
c01027b5:	e9 cc 09 00 00       	jmp    c0103186 <__alltraps>

c01027ba <vector20>:
.globl vector20
vector20:
  pushl $0
c01027ba:	6a 00                	push   $0x0
  pushl $20
c01027bc:	6a 14                	push   $0x14
  jmp __alltraps
c01027be:	e9 c3 09 00 00       	jmp    c0103186 <__alltraps>

c01027c3 <vector21>:
.globl vector21
vector21:
  pushl $0
c01027c3:	6a 00                	push   $0x0
  pushl $21
c01027c5:	6a 15                	push   $0x15
  jmp __alltraps
c01027c7:	e9 ba 09 00 00       	jmp    c0103186 <__alltraps>

c01027cc <vector22>:
.globl vector22
vector22:
  pushl $0
c01027cc:	6a 00                	push   $0x0
  pushl $22
c01027ce:	6a 16                	push   $0x16
  jmp __alltraps
c01027d0:	e9 b1 09 00 00       	jmp    c0103186 <__alltraps>

c01027d5 <vector23>:
.globl vector23
vector23:
  pushl $0
c01027d5:	6a 00                	push   $0x0
  pushl $23
c01027d7:	6a 17                	push   $0x17
  jmp __alltraps
c01027d9:	e9 a8 09 00 00       	jmp    c0103186 <__alltraps>

c01027de <vector24>:
.globl vector24
vector24:
  pushl $0
c01027de:	6a 00                	push   $0x0
  pushl $24
c01027e0:	6a 18                	push   $0x18
  jmp __alltraps
c01027e2:	e9 9f 09 00 00       	jmp    c0103186 <__alltraps>

c01027e7 <vector25>:
.globl vector25
vector25:
  pushl $0
c01027e7:	6a 00                	push   $0x0
  pushl $25
c01027e9:	6a 19                	push   $0x19
  jmp __alltraps
c01027eb:	e9 96 09 00 00       	jmp    c0103186 <__alltraps>

c01027f0 <vector26>:
.globl vector26
vector26:
  pushl $0
c01027f0:	6a 00                	push   $0x0
  pushl $26
c01027f2:	6a 1a                	push   $0x1a
  jmp __alltraps
c01027f4:	e9 8d 09 00 00       	jmp    c0103186 <__alltraps>

c01027f9 <vector27>:
.globl vector27
vector27:
  pushl $0
c01027f9:	6a 00                	push   $0x0
  pushl $27
c01027fb:	6a 1b                	push   $0x1b
  jmp __alltraps
c01027fd:	e9 84 09 00 00       	jmp    c0103186 <__alltraps>

c0102802 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102802:	6a 00                	push   $0x0
  pushl $28
c0102804:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102806:	e9 7b 09 00 00       	jmp    c0103186 <__alltraps>

c010280b <vector29>:
.globl vector29
vector29:
  pushl $0
c010280b:	6a 00                	push   $0x0
  pushl $29
c010280d:	6a 1d                	push   $0x1d
  jmp __alltraps
c010280f:	e9 72 09 00 00       	jmp    c0103186 <__alltraps>

c0102814 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102814:	6a 00                	push   $0x0
  pushl $30
c0102816:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102818:	e9 69 09 00 00       	jmp    c0103186 <__alltraps>

c010281d <vector31>:
.globl vector31
vector31:
  pushl $0
c010281d:	6a 00                	push   $0x0
  pushl $31
c010281f:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102821:	e9 60 09 00 00       	jmp    c0103186 <__alltraps>

c0102826 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102826:	6a 00                	push   $0x0
  pushl $32
c0102828:	6a 20                	push   $0x20
  jmp __alltraps
c010282a:	e9 57 09 00 00       	jmp    c0103186 <__alltraps>

c010282f <vector33>:
.globl vector33
vector33:
  pushl $0
c010282f:	6a 00                	push   $0x0
  pushl $33
c0102831:	6a 21                	push   $0x21
  jmp __alltraps
c0102833:	e9 4e 09 00 00       	jmp    c0103186 <__alltraps>

c0102838 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102838:	6a 00                	push   $0x0
  pushl $34
c010283a:	6a 22                	push   $0x22
  jmp __alltraps
c010283c:	e9 45 09 00 00       	jmp    c0103186 <__alltraps>

c0102841 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102841:	6a 00                	push   $0x0
  pushl $35
c0102843:	6a 23                	push   $0x23
  jmp __alltraps
c0102845:	e9 3c 09 00 00       	jmp    c0103186 <__alltraps>

c010284a <vector36>:
.globl vector36
vector36:
  pushl $0
c010284a:	6a 00                	push   $0x0
  pushl $36
c010284c:	6a 24                	push   $0x24
  jmp __alltraps
c010284e:	e9 33 09 00 00       	jmp    c0103186 <__alltraps>

c0102853 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102853:	6a 00                	push   $0x0
  pushl $37
c0102855:	6a 25                	push   $0x25
  jmp __alltraps
c0102857:	e9 2a 09 00 00       	jmp    c0103186 <__alltraps>

c010285c <vector38>:
.globl vector38
vector38:
  pushl $0
c010285c:	6a 00                	push   $0x0
  pushl $38
c010285e:	6a 26                	push   $0x26
  jmp __alltraps
c0102860:	e9 21 09 00 00       	jmp    c0103186 <__alltraps>

c0102865 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102865:	6a 00                	push   $0x0
  pushl $39
c0102867:	6a 27                	push   $0x27
  jmp __alltraps
c0102869:	e9 18 09 00 00       	jmp    c0103186 <__alltraps>

c010286e <vector40>:
.globl vector40
vector40:
  pushl $0
c010286e:	6a 00                	push   $0x0
  pushl $40
c0102870:	6a 28                	push   $0x28
  jmp __alltraps
c0102872:	e9 0f 09 00 00       	jmp    c0103186 <__alltraps>

c0102877 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102877:	6a 00                	push   $0x0
  pushl $41
c0102879:	6a 29                	push   $0x29
  jmp __alltraps
c010287b:	e9 06 09 00 00       	jmp    c0103186 <__alltraps>

c0102880 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102880:	6a 00                	push   $0x0
  pushl $42
c0102882:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102884:	e9 fd 08 00 00       	jmp    c0103186 <__alltraps>

c0102889 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102889:	6a 00                	push   $0x0
  pushl $43
c010288b:	6a 2b                	push   $0x2b
  jmp __alltraps
c010288d:	e9 f4 08 00 00       	jmp    c0103186 <__alltraps>

c0102892 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102892:	6a 00                	push   $0x0
  pushl $44
c0102894:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102896:	e9 eb 08 00 00       	jmp    c0103186 <__alltraps>

c010289b <vector45>:
.globl vector45
vector45:
  pushl $0
c010289b:	6a 00                	push   $0x0
  pushl $45
c010289d:	6a 2d                	push   $0x2d
  jmp __alltraps
c010289f:	e9 e2 08 00 00       	jmp    c0103186 <__alltraps>

c01028a4 <vector46>:
.globl vector46
vector46:
  pushl $0
c01028a4:	6a 00                	push   $0x0
  pushl $46
c01028a6:	6a 2e                	push   $0x2e
  jmp __alltraps
c01028a8:	e9 d9 08 00 00       	jmp    c0103186 <__alltraps>

c01028ad <vector47>:
.globl vector47
vector47:
  pushl $0
c01028ad:	6a 00                	push   $0x0
  pushl $47
c01028af:	6a 2f                	push   $0x2f
  jmp __alltraps
c01028b1:	e9 d0 08 00 00       	jmp    c0103186 <__alltraps>

c01028b6 <vector48>:
.globl vector48
vector48:
  pushl $0
c01028b6:	6a 00                	push   $0x0
  pushl $48
c01028b8:	6a 30                	push   $0x30
  jmp __alltraps
c01028ba:	e9 c7 08 00 00       	jmp    c0103186 <__alltraps>

c01028bf <vector49>:
.globl vector49
vector49:
  pushl $0
c01028bf:	6a 00                	push   $0x0
  pushl $49
c01028c1:	6a 31                	push   $0x31
  jmp __alltraps
c01028c3:	e9 be 08 00 00       	jmp    c0103186 <__alltraps>

c01028c8 <vector50>:
.globl vector50
vector50:
  pushl $0
c01028c8:	6a 00                	push   $0x0
  pushl $50
c01028ca:	6a 32                	push   $0x32
  jmp __alltraps
c01028cc:	e9 b5 08 00 00       	jmp    c0103186 <__alltraps>

c01028d1 <vector51>:
.globl vector51
vector51:
  pushl $0
c01028d1:	6a 00                	push   $0x0
  pushl $51
c01028d3:	6a 33                	push   $0x33
  jmp __alltraps
c01028d5:	e9 ac 08 00 00       	jmp    c0103186 <__alltraps>

c01028da <vector52>:
.globl vector52
vector52:
  pushl $0
c01028da:	6a 00                	push   $0x0
  pushl $52
c01028dc:	6a 34                	push   $0x34
  jmp __alltraps
c01028de:	e9 a3 08 00 00       	jmp    c0103186 <__alltraps>

c01028e3 <vector53>:
.globl vector53
vector53:
  pushl $0
c01028e3:	6a 00                	push   $0x0
  pushl $53
c01028e5:	6a 35                	push   $0x35
  jmp __alltraps
c01028e7:	e9 9a 08 00 00       	jmp    c0103186 <__alltraps>

c01028ec <vector54>:
.globl vector54
vector54:
  pushl $0
c01028ec:	6a 00                	push   $0x0
  pushl $54
c01028ee:	6a 36                	push   $0x36
  jmp __alltraps
c01028f0:	e9 91 08 00 00       	jmp    c0103186 <__alltraps>

c01028f5 <vector55>:
.globl vector55
vector55:
  pushl $0
c01028f5:	6a 00                	push   $0x0
  pushl $55
c01028f7:	6a 37                	push   $0x37
  jmp __alltraps
c01028f9:	e9 88 08 00 00       	jmp    c0103186 <__alltraps>

c01028fe <vector56>:
.globl vector56
vector56:
  pushl $0
c01028fe:	6a 00                	push   $0x0
  pushl $56
c0102900:	6a 38                	push   $0x38
  jmp __alltraps
c0102902:	e9 7f 08 00 00       	jmp    c0103186 <__alltraps>

c0102907 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102907:	6a 00                	push   $0x0
  pushl $57
c0102909:	6a 39                	push   $0x39
  jmp __alltraps
c010290b:	e9 76 08 00 00       	jmp    c0103186 <__alltraps>

c0102910 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102910:	6a 00                	push   $0x0
  pushl $58
c0102912:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102914:	e9 6d 08 00 00       	jmp    c0103186 <__alltraps>

c0102919 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102919:	6a 00                	push   $0x0
  pushl $59
c010291b:	6a 3b                	push   $0x3b
  jmp __alltraps
c010291d:	e9 64 08 00 00       	jmp    c0103186 <__alltraps>

c0102922 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102922:	6a 00                	push   $0x0
  pushl $60
c0102924:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102926:	e9 5b 08 00 00       	jmp    c0103186 <__alltraps>

c010292b <vector61>:
.globl vector61
vector61:
  pushl $0
c010292b:	6a 00                	push   $0x0
  pushl $61
c010292d:	6a 3d                	push   $0x3d
  jmp __alltraps
c010292f:	e9 52 08 00 00       	jmp    c0103186 <__alltraps>

c0102934 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102934:	6a 00                	push   $0x0
  pushl $62
c0102936:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102938:	e9 49 08 00 00       	jmp    c0103186 <__alltraps>

c010293d <vector63>:
.globl vector63
vector63:
  pushl $0
c010293d:	6a 00                	push   $0x0
  pushl $63
c010293f:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102941:	e9 40 08 00 00       	jmp    c0103186 <__alltraps>

c0102946 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102946:	6a 00                	push   $0x0
  pushl $64
c0102948:	6a 40                	push   $0x40
  jmp __alltraps
c010294a:	e9 37 08 00 00       	jmp    c0103186 <__alltraps>

c010294f <vector65>:
.globl vector65
vector65:
  pushl $0
c010294f:	6a 00                	push   $0x0
  pushl $65
c0102951:	6a 41                	push   $0x41
  jmp __alltraps
c0102953:	e9 2e 08 00 00       	jmp    c0103186 <__alltraps>

c0102958 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102958:	6a 00                	push   $0x0
  pushl $66
c010295a:	6a 42                	push   $0x42
  jmp __alltraps
c010295c:	e9 25 08 00 00       	jmp    c0103186 <__alltraps>

c0102961 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102961:	6a 00                	push   $0x0
  pushl $67
c0102963:	6a 43                	push   $0x43
  jmp __alltraps
c0102965:	e9 1c 08 00 00       	jmp    c0103186 <__alltraps>

c010296a <vector68>:
.globl vector68
vector68:
  pushl $0
c010296a:	6a 00                	push   $0x0
  pushl $68
c010296c:	6a 44                	push   $0x44
  jmp __alltraps
c010296e:	e9 13 08 00 00       	jmp    c0103186 <__alltraps>

c0102973 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102973:	6a 00                	push   $0x0
  pushl $69
c0102975:	6a 45                	push   $0x45
  jmp __alltraps
c0102977:	e9 0a 08 00 00       	jmp    c0103186 <__alltraps>

c010297c <vector70>:
.globl vector70
vector70:
  pushl $0
c010297c:	6a 00                	push   $0x0
  pushl $70
c010297e:	6a 46                	push   $0x46
  jmp __alltraps
c0102980:	e9 01 08 00 00       	jmp    c0103186 <__alltraps>

c0102985 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102985:	6a 00                	push   $0x0
  pushl $71
c0102987:	6a 47                	push   $0x47
  jmp __alltraps
c0102989:	e9 f8 07 00 00       	jmp    c0103186 <__alltraps>

c010298e <vector72>:
.globl vector72
vector72:
  pushl $0
c010298e:	6a 00                	push   $0x0
  pushl $72
c0102990:	6a 48                	push   $0x48
  jmp __alltraps
c0102992:	e9 ef 07 00 00       	jmp    c0103186 <__alltraps>

c0102997 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102997:	6a 00                	push   $0x0
  pushl $73
c0102999:	6a 49                	push   $0x49
  jmp __alltraps
c010299b:	e9 e6 07 00 00       	jmp    c0103186 <__alltraps>

c01029a0 <vector74>:
.globl vector74
vector74:
  pushl $0
c01029a0:	6a 00                	push   $0x0
  pushl $74
c01029a2:	6a 4a                	push   $0x4a
  jmp __alltraps
c01029a4:	e9 dd 07 00 00       	jmp    c0103186 <__alltraps>

c01029a9 <vector75>:
.globl vector75
vector75:
  pushl $0
c01029a9:	6a 00                	push   $0x0
  pushl $75
c01029ab:	6a 4b                	push   $0x4b
  jmp __alltraps
c01029ad:	e9 d4 07 00 00       	jmp    c0103186 <__alltraps>

c01029b2 <vector76>:
.globl vector76
vector76:
  pushl $0
c01029b2:	6a 00                	push   $0x0
  pushl $76
c01029b4:	6a 4c                	push   $0x4c
  jmp __alltraps
c01029b6:	e9 cb 07 00 00       	jmp    c0103186 <__alltraps>

c01029bb <vector77>:
.globl vector77
vector77:
  pushl $0
c01029bb:	6a 00                	push   $0x0
  pushl $77
c01029bd:	6a 4d                	push   $0x4d
  jmp __alltraps
c01029bf:	e9 c2 07 00 00       	jmp    c0103186 <__alltraps>

c01029c4 <vector78>:
.globl vector78
vector78:
  pushl $0
c01029c4:	6a 00                	push   $0x0
  pushl $78
c01029c6:	6a 4e                	push   $0x4e
  jmp __alltraps
c01029c8:	e9 b9 07 00 00       	jmp    c0103186 <__alltraps>

c01029cd <vector79>:
.globl vector79
vector79:
  pushl $0
c01029cd:	6a 00                	push   $0x0
  pushl $79
c01029cf:	6a 4f                	push   $0x4f
  jmp __alltraps
c01029d1:	e9 b0 07 00 00       	jmp    c0103186 <__alltraps>

c01029d6 <vector80>:
.globl vector80
vector80:
  pushl $0
c01029d6:	6a 00                	push   $0x0
  pushl $80
c01029d8:	6a 50                	push   $0x50
  jmp __alltraps
c01029da:	e9 a7 07 00 00       	jmp    c0103186 <__alltraps>

c01029df <vector81>:
.globl vector81
vector81:
  pushl $0
c01029df:	6a 00                	push   $0x0
  pushl $81
c01029e1:	6a 51                	push   $0x51
  jmp __alltraps
c01029e3:	e9 9e 07 00 00       	jmp    c0103186 <__alltraps>

c01029e8 <vector82>:
.globl vector82
vector82:
  pushl $0
c01029e8:	6a 00                	push   $0x0
  pushl $82
c01029ea:	6a 52                	push   $0x52
  jmp __alltraps
c01029ec:	e9 95 07 00 00       	jmp    c0103186 <__alltraps>

c01029f1 <vector83>:
.globl vector83
vector83:
  pushl $0
c01029f1:	6a 00                	push   $0x0
  pushl $83
c01029f3:	6a 53                	push   $0x53
  jmp __alltraps
c01029f5:	e9 8c 07 00 00       	jmp    c0103186 <__alltraps>

c01029fa <vector84>:
.globl vector84
vector84:
  pushl $0
c01029fa:	6a 00                	push   $0x0
  pushl $84
c01029fc:	6a 54                	push   $0x54
  jmp __alltraps
c01029fe:	e9 83 07 00 00       	jmp    c0103186 <__alltraps>

c0102a03 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102a03:	6a 00                	push   $0x0
  pushl $85
c0102a05:	6a 55                	push   $0x55
  jmp __alltraps
c0102a07:	e9 7a 07 00 00       	jmp    c0103186 <__alltraps>

c0102a0c <vector86>:
.globl vector86
vector86:
  pushl $0
c0102a0c:	6a 00                	push   $0x0
  pushl $86
c0102a0e:	6a 56                	push   $0x56
  jmp __alltraps
c0102a10:	e9 71 07 00 00       	jmp    c0103186 <__alltraps>

c0102a15 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102a15:	6a 00                	push   $0x0
  pushl $87
c0102a17:	6a 57                	push   $0x57
  jmp __alltraps
c0102a19:	e9 68 07 00 00       	jmp    c0103186 <__alltraps>

c0102a1e <vector88>:
.globl vector88
vector88:
  pushl $0
c0102a1e:	6a 00                	push   $0x0
  pushl $88
c0102a20:	6a 58                	push   $0x58
  jmp __alltraps
c0102a22:	e9 5f 07 00 00       	jmp    c0103186 <__alltraps>

c0102a27 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102a27:	6a 00                	push   $0x0
  pushl $89
c0102a29:	6a 59                	push   $0x59
  jmp __alltraps
c0102a2b:	e9 56 07 00 00       	jmp    c0103186 <__alltraps>

c0102a30 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102a30:	6a 00                	push   $0x0
  pushl $90
c0102a32:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102a34:	e9 4d 07 00 00       	jmp    c0103186 <__alltraps>

c0102a39 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102a39:	6a 00                	push   $0x0
  pushl $91
c0102a3b:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102a3d:	e9 44 07 00 00       	jmp    c0103186 <__alltraps>

c0102a42 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102a42:	6a 00                	push   $0x0
  pushl $92
c0102a44:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102a46:	e9 3b 07 00 00       	jmp    c0103186 <__alltraps>

c0102a4b <vector93>:
.globl vector93
vector93:
  pushl $0
c0102a4b:	6a 00                	push   $0x0
  pushl $93
c0102a4d:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102a4f:	e9 32 07 00 00       	jmp    c0103186 <__alltraps>

c0102a54 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102a54:	6a 00                	push   $0x0
  pushl $94
c0102a56:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102a58:	e9 29 07 00 00       	jmp    c0103186 <__alltraps>

c0102a5d <vector95>:
.globl vector95
vector95:
  pushl $0
c0102a5d:	6a 00                	push   $0x0
  pushl $95
c0102a5f:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102a61:	e9 20 07 00 00       	jmp    c0103186 <__alltraps>

c0102a66 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102a66:	6a 00                	push   $0x0
  pushl $96
c0102a68:	6a 60                	push   $0x60
  jmp __alltraps
c0102a6a:	e9 17 07 00 00       	jmp    c0103186 <__alltraps>

c0102a6f <vector97>:
.globl vector97
vector97:
  pushl $0
c0102a6f:	6a 00                	push   $0x0
  pushl $97
c0102a71:	6a 61                	push   $0x61
  jmp __alltraps
c0102a73:	e9 0e 07 00 00       	jmp    c0103186 <__alltraps>

c0102a78 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102a78:	6a 00                	push   $0x0
  pushl $98
c0102a7a:	6a 62                	push   $0x62
  jmp __alltraps
c0102a7c:	e9 05 07 00 00       	jmp    c0103186 <__alltraps>

c0102a81 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102a81:	6a 00                	push   $0x0
  pushl $99
c0102a83:	6a 63                	push   $0x63
  jmp __alltraps
c0102a85:	e9 fc 06 00 00       	jmp    c0103186 <__alltraps>

c0102a8a <vector100>:
.globl vector100
vector100:
  pushl $0
c0102a8a:	6a 00                	push   $0x0
  pushl $100
c0102a8c:	6a 64                	push   $0x64
  jmp __alltraps
c0102a8e:	e9 f3 06 00 00       	jmp    c0103186 <__alltraps>

c0102a93 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102a93:	6a 00                	push   $0x0
  pushl $101
c0102a95:	6a 65                	push   $0x65
  jmp __alltraps
c0102a97:	e9 ea 06 00 00       	jmp    c0103186 <__alltraps>

c0102a9c <vector102>:
.globl vector102
vector102:
  pushl $0
c0102a9c:	6a 00                	push   $0x0
  pushl $102
c0102a9e:	6a 66                	push   $0x66
  jmp __alltraps
c0102aa0:	e9 e1 06 00 00       	jmp    c0103186 <__alltraps>

c0102aa5 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102aa5:	6a 00                	push   $0x0
  pushl $103
c0102aa7:	6a 67                	push   $0x67
  jmp __alltraps
c0102aa9:	e9 d8 06 00 00       	jmp    c0103186 <__alltraps>

c0102aae <vector104>:
.globl vector104
vector104:
  pushl $0
c0102aae:	6a 00                	push   $0x0
  pushl $104
c0102ab0:	6a 68                	push   $0x68
  jmp __alltraps
c0102ab2:	e9 cf 06 00 00       	jmp    c0103186 <__alltraps>

c0102ab7 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102ab7:	6a 00                	push   $0x0
  pushl $105
c0102ab9:	6a 69                	push   $0x69
  jmp __alltraps
c0102abb:	e9 c6 06 00 00       	jmp    c0103186 <__alltraps>

c0102ac0 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102ac0:	6a 00                	push   $0x0
  pushl $106
c0102ac2:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102ac4:	e9 bd 06 00 00       	jmp    c0103186 <__alltraps>

c0102ac9 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102ac9:	6a 00                	push   $0x0
  pushl $107
c0102acb:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102acd:	e9 b4 06 00 00       	jmp    c0103186 <__alltraps>

c0102ad2 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102ad2:	6a 00                	push   $0x0
  pushl $108
c0102ad4:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102ad6:	e9 ab 06 00 00       	jmp    c0103186 <__alltraps>

c0102adb <vector109>:
.globl vector109
vector109:
  pushl $0
c0102adb:	6a 00                	push   $0x0
  pushl $109
c0102add:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102adf:	e9 a2 06 00 00       	jmp    c0103186 <__alltraps>

c0102ae4 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102ae4:	6a 00                	push   $0x0
  pushl $110
c0102ae6:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102ae8:	e9 99 06 00 00       	jmp    c0103186 <__alltraps>

c0102aed <vector111>:
.globl vector111
vector111:
  pushl $0
c0102aed:	6a 00                	push   $0x0
  pushl $111
c0102aef:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102af1:	e9 90 06 00 00       	jmp    c0103186 <__alltraps>

c0102af6 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102af6:	6a 00                	push   $0x0
  pushl $112
c0102af8:	6a 70                	push   $0x70
  jmp __alltraps
c0102afa:	e9 87 06 00 00       	jmp    c0103186 <__alltraps>

c0102aff <vector113>:
.globl vector113
vector113:
  pushl $0
c0102aff:	6a 00                	push   $0x0
  pushl $113
c0102b01:	6a 71                	push   $0x71
  jmp __alltraps
c0102b03:	e9 7e 06 00 00       	jmp    c0103186 <__alltraps>

c0102b08 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102b08:	6a 00                	push   $0x0
  pushl $114
c0102b0a:	6a 72                	push   $0x72
  jmp __alltraps
c0102b0c:	e9 75 06 00 00       	jmp    c0103186 <__alltraps>

c0102b11 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102b11:	6a 00                	push   $0x0
  pushl $115
c0102b13:	6a 73                	push   $0x73
  jmp __alltraps
c0102b15:	e9 6c 06 00 00       	jmp    c0103186 <__alltraps>

c0102b1a <vector116>:
.globl vector116
vector116:
  pushl $0
c0102b1a:	6a 00                	push   $0x0
  pushl $116
c0102b1c:	6a 74                	push   $0x74
  jmp __alltraps
c0102b1e:	e9 63 06 00 00       	jmp    c0103186 <__alltraps>

c0102b23 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102b23:	6a 00                	push   $0x0
  pushl $117
c0102b25:	6a 75                	push   $0x75
  jmp __alltraps
c0102b27:	e9 5a 06 00 00       	jmp    c0103186 <__alltraps>

c0102b2c <vector118>:
.globl vector118
vector118:
  pushl $0
c0102b2c:	6a 00                	push   $0x0
  pushl $118
c0102b2e:	6a 76                	push   $0x76
  jmp __alltraps
c0102b30:	e9 51 06 00 00       	jmp    c0103186 <__alltraps>

c0102b35 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102b35:	6a 00                	push   $0x0
  pushl $119
c0102b37:	6a 77                	push   $0x77
  jmp __alltraps
c0102b39:	e9 48 06 00 00       	jmp    c0103186 <__alltraps>

c0102b3e <vector120>:
.globl vector120
vector120:
  pushl $0
c0102b3e:	6a 00                	push   $0x0
  pushl $120
c0102b40:	6a 78                	push   $0x78
  jmp __alltraps
c0102b42:	e9 3f 06 00 00       	jmp    c0103186 <__alltraps>

c0102b47 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102b47:	6a 00                	push   $0x0
  pushl $121
c0102b49:	6a 79                	push   $0x79
  jmp __alltraps
c0102b4b:	e9 36 06 00 00       	jmp    c0103186 <__alltraps>

c0102b50 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102b50:	6a 00                	push   $0x0
  pushl $122
c0102b52:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102b54:	e9 2d 06 00 00       	jmp    c0103186 <__alltraps>

c0102b59 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102b59:	6a 00                	push   $0x0
  pushl $123
c0102b5b:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102b5d:	e9 24 06 00 00       	jmp    c0103186 <__alltraps>

c0102b62 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102b62:	6a 00                	push   $0x0
  pushl $124
c0102b64:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102b66:	e9 1b 06 00 00       	jmp    c0103186 <__alltraps>

c0102b6b <vector125>:
.globl vector125
vector125:
  pushl $0
c0102b6b:	6a 00                	push   $0x0
  pushl $125
c0102b6d:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102b6f:	e9 12 06 00 00       	jmp    c0103186 <__alltraps>

c0102b74 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102b74:	6a 00                	push   $0x0
  pushl $126
c0102b76:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102b78:	e9 09 06 00 00       	jmp    c0103186 <__alltraps>

c0102b7d <vector127>:
.globl vector127
vector127:
  pushl $0
c0102b7d:	6a 00                	push   $0x0
  pushl $127
c0102b7f:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102b81:	e9 00 06 00 00       	jmp    c0103186 <__alltraps>

c0102b86 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102b86:	6a 00                	push   $0x0
  pushl $128
c0102b88:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102b8d:	e9 f4 05 00 00       	jmp    c0103186 <__alltraps>

c0102b92 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102b92:	6a 00                	push   $0x0
  pushl $129
c0102b94:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102b99:	e9 e8 05 00 00       	jmp    c0103186 <__alltraps>

c0102b9e <vector130>:
.globl vector130
vector130:
  pushl $0
c0102b9e:	6a 00                	push   $0x0
  pushl $130
c0102ba0:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102ba5:	e9 dc 05 00 00       	jmp    c0103186 <__alltraps>

c0102baa <vector131>:
.globl vector131
vector131:
  pushl $0
c0102baa:	6a 00                	push   $0x0
  pushl $131
c0102bac:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102bb1:	e9 d0 05 00 00       	jmp    c0103186 <__alltraps>

c0102bb6 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102bb6:	6a 00                	push   $0x0
  pushl $132
c0102bb8:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102bbd:	e9 c4 05 00 00       	jmp    c0103186 <__alltraps>

c0102bc2 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102bc2:	6a 00                	push   $0x0
  pushl $133
c0102bc4:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102bc9:	e9 b8 05 00 00       	jmp    c0103186 <__alltraps>

c0102bce <vector134>:
.globl vector134
vector134:
  pushl $0
c0102bce:	6a 00                	push   $0x0
  pushl $134
c0102bd0:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102bd5:	e9 ac 05 00 00       	jmp    c0103186 <__alltraps>

c0102bda <vector135>:
.globl vector135
vector135:
  pushl $0
c0102bda:	6a 00                	push   $0x0
  pushl $135
c0102bdc:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102be1:	e9 a0 05 00 00       	jmp    c0103186 <__alltraps>

c0102be6 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102be6:	6a 00                	push   $0x0
  pushl $136
c0102be8:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102bed:	e9 94 05 00 00       	jmp    c0103186 <__alltraps>

c0102bf2 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102bf2:	6a 00                	push   $0x0
  pushl $137
c0102bf4:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102bf9:	e9 88 05 00 00       	jmp    c0103186 <__alltraps>

c0102bfe <vector138>:
.globl vector138
vector138:
  pushl $0
c0102bfe:	6a 00                	push   $0x0
  pushl $138
c0102c00:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102c05:	e9 7c 05 00 00       	jmp    c0103186 <__alltraps>

c0102c0a <vector139>:
.globl vector139
vector139:
  pushl $0
c0102c0a:	6a 00                	push   $0x0
  pushl $139
c0102c0c:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102c11:	e9 70 05 00 00       	jmp    c0103186 <__alltraps>

c0102c16 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102c16:	6a 00                	push   $0x0
  pushl $140
c0102c18:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102c1d:	e9 64 05 00 00       	jmp    c0103186 <__alltraps>

c0102c22 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102c22:	6a 00                	push   $0x0
  pushl $141
c0102c24:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102c29:	e9 58 05 00 00       	jmp    c0103186 <__alltraps>

c0102c2e <vector142>:
.globl vector142
vector142:
  pushl $0
c0102c2e:	6a 00                	push   $0x0
  pushl $142
c0102c30:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102c35:	e9 4c 05 00 00       	jmp    c0103186 <__alltraps>

c0102c3a <vector143>:
.globl vector143
vector143:
  pushl $0
c0102c3a:	6a 00                	push   $0x0
  pushl $143
c0102c3c:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102c41:	e9 40 05 00 00       	jmp    c0103186 <__alltraps>

c0102c46 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102c46:	6a 00                	push   $0x0
  pushl $144
c0102c48:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102c4d:	e9 34 05 00 00       	jmp    c0103186 <__alltraps>

c0102c52 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102c52:	6a 00                	push   $0x0
  pushl $145
c0102c54:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102c59:	e9 28 05 00 00       	jmp    c0103186 <__alltraps>

c0102c5e <vector146>:
.globl vector146
vector146:
  pushl $0
c0102c5e:	6a 00                	push   $0x0
  pushl $146
c0102c60:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102c65:	e9 1c 05 00 00       	jmp    c0103186 <__alltraps>

c0102c6a <vector147>:
.globl vector147
vector147:
  pushl $0
c0102c6a:	6a 00                	push   $0x0
  pushl $147
c0102c6c:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102c71:	e9 10 05 00 00       	jmp    c0103186 <__alltraps>

c0102c76 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102c76:	6a 00                	push   $0x0
  pushl $148
c0102c78:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102c7d:	e9 04 05 00 00       	jmp    c0103186 <__alltraps>

c0102c82 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102c82:	6a 00                	push   $0x0
  pushl $149
c0102c84:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102c89:	e9 f8 04 00 00       	jmp    c0103186 <__alltraps>

c0102c8e <vector150>:
.globl vector150
vector150:
  pushl $0
c0102c8e:	6a 00                	push   $0x0
  pushl $150
c0102c90:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102c95:	e9 ec 04 00 00       	jmp    c0103186 <__alltraps>

c0102c9a <vector151>:
.globl vector151
vector151:
  pushl $0
c0102c9a:	6a 00                	push   $0x0
  pushl $151
c0102c9c:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102ca1:	e9 e0 04 00 00       	jmp    c0103186 <__alltraps>

c0102ca6 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102ca6:	6a 00                	push   $0x0
  pushl $152
c0102ca8:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102cad:	e9 d4 04 00 00       	jmp    c0103186 <__alltraps>

c0102cb2 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102cb2:	6a 00                	push   $0x0
  pushl $153
c0102cb4:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102cb9:	e9 c8 04 00 00       	jmp    c0103186 <__alltraps>

c0102cbe <vector154>:
.globl vector154
vector154:
  pushl $0
c0102cbe:	6a 00                	push   $0x0
  pushl $154
c0102cc0:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102cc5:	e9 bc 04 00 00       	jmp    c0103186 <__alltraps>

c0102cca <vector155>:
.globl vector155
vector155:
  pushl $0
c0102cca:	6a 00                	push   $0x0
  pushl $155
c0102ccc:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102cd1:	e9 b0 04 00 00       	jmp    c0103186 <__alltraps>

c0102cd6 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102cd6:	6a 00                	push   $0x0
  pushl $156
c0102cd8:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102cdd:	e9 a4 04 00 00       	jmp    c0103186 <__alltraps>

c0102ce2 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102ce2:	6a 00                	push   $0x0
  pushl $157
c0102ce4:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102ce9:	e9 98 04 00 00       	jmp    c0103186 <__alltraps>

c0102cee <vector158>:
.globl vector158
vector158:
  pushl $0
c0102cee:	6a 00                	push   $0x0
  pushl $158
c0102cf0:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102cf5:	e9 8c 04 00 00       	jmp    c0103186 <__alltraps>

c0102cfa <vector159>:
.globl vector159
vector159:
  pushl $0
c0102cfa:	6a 00                	push   $0x0
  pushl $159
c0102cfc:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102d01:	e9 80 04 00 00       	jmp    c0103186 <__alltraps>

c0102d06 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102d06:	6a 00                	push   $0x0
  pushl $160
c0102d08:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102d0d:	e9 74 04 00 00       	jmp    c0103186 <__alltraps>

c0102d12 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102d12:	6a 00                	push   $0x0
  pushl $161
c0102d14:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102d19:	e9 68 04 00 00       	jmp    c0103186 <__alltraps>

c0102d1e <vector162>:
.globl vector162
vector162:
  pushl $0
c0102d1e:	6a 00                	push   $0x0
  pushl $162
c0102d20:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102d25:	e9 5c 04 00 00       	jmp    c0103186 <__alltraps>

c0102d2a <vector163>:
.globl vector163
vector163:
  pushl $0
c0102d2a:	6a 00                	push   $0x0
  pushl $163
c0102d2c:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102d31:	e9 50 04 00 00       	jmp    c0103186 <__alltraps>

c0102d36 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102d36:	6a 00                	push   $0x0
  pushl $164
c0102d38:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102d3d:	e9 44 04 00 00       	jmp    c0103186 <__alltraps>

c0102d42 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102d42:	6a 00                	push   $0x0
  pushl $165
c0102d44:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102d49:	e9 38 04 00 00       	jmp    c0103186 <__alltraps>

c0102d4e <vector166>:
.globl vector166
vector166:
  pushl $0
c0102d4e:	6a 00                	push   $0x0
  pushl $166
c0102d50:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102d55:	e9 2c 04 00 00       	jmp    c0103186 <__alltraps>

c0102d5a <vector167>:
.globl vector167
vector167:
  pushl $0
c0102d5a:	6a 00                	push   $0x0
  pushl $167
c0102d5c:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102d61:	e9 20 04 00 00       	jmp    c0103186 <__alltraps>

c0102d66 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102d66:	6a 00                	push   $0x0
  pushl $168
c0102d68:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102d6d:	e9 14 04 00 00       	jmp    c0103186 <__alltraps>

c0102d72 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102d72:	6a 00                	push   $0x0
  pushl $169
c0102d74:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102d79:	e9 08 04 00 00       	jmp    c0103186 <__alltraps>

c0102d7e <vector170>:
.globl vector170
vector170:
  pushl $0
c0102d7e:	6a 00                	push   $0x0
  pushl $170
c0102d80:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102d85:	e9 fc 03 00 00       	jmp    c0103186 <__alltraps>

c0102d8a <vector171>:
.globl vector171
vector171:
  pushl $0
c0102d8a:	6a 00                	push   $0x0
  pushl $171
c0102d8c:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102d91:	e9 f0 03 00 00       	jmp    c0103186 <__alltraps>

c0102d96 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102d96:	6a 00                	push   $0x0
  pushl $172
c0102d98:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102d9d:	e9 e4 03 00 00       	jmp    c0103186 <__alltraps>

c0102da2 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102da2:	6a 00                	push   $0x0
  pushl $173
c0102da4:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102da9:	e9 d8 03 00 00       	jmp    c0103186 <__alltraps>

c0102dae <vector174>:
.globl vector174
vector174:
  pushl $0
c0102dae:	6a 00                	push   $0x0
  pushl $174
c0102db0:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102db5:	e9 cc 03 00 00       	jmp    c0103186 <__alltraps>

c0102dba <vector175>:
.globl vector175
vector175:
  pushl $0
c0102dba:	6a 00                	push   $0x0
  pushl $175
c0102dbc:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102dc1:	e9 c0 03 00 00       	jmp    c0103186 <__alltraps>

c0102dc6 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102dc6:	6a 00                	push   $0x0
  pushl $176
c0102dc8:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102dcd:	e9 b4 03 00 00       	jmp    c0103186 <__alltraps>

c0102dd2 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102dd2:	6a 00                	push   $0x0
  pushl $177
c0102dd4:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102dd9:	e9 a8 03 00 00       	jmp    c0103186 <__alltraps>

c0102dde <vector178>:
.globl vector178
vector178:
  pushl $0
c0102dde:	6a 00                	push   $0x0
  pushl $178
c0102de0:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102de5:	e9 9c 03 00 00       	jmp    c0103186 <__alltraps>

c0102dea <vector179>:
.globl vector179
vector179:
  pushl $0
c0102dea:	6a 00                	push   $0x0
  pushl $179
c0102dec:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102df1:	e9 90 03 00 00       	jmp    c0103186 <__alltraps>

c0102df6 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102df6:	6a 00                	push   $0x0
  pushl $180
c0102df8:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102dfd:	e9 84 03 00 00       	jmp    c0103186 <__alltraps>

c0102e02 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102e02:	6a 00                	push   $0x0
  pushl $181
c0102e04:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102e09:	e9 78 03 00 00       	jmp    c0103186 <__alltraps>

c0102e0e <vector182>:
.globl vector182
vector182:
  pushl $0
c0102e0e:	6a 00                	push   $0x0
  pushl $182
c0102e10:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102e15:	e9 6c 03 00 00       	jmp    c0103186 <__alltraps>

c0102e1a <vector183>:
.globl vector183
vector183:
  pushl $0
c0102e1a:	6a 00                	push   $0x0
  pushl $183
c0102e1c:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102e21:	e9 60 03 00 00       	jmp    c0103186 <__alltraps>

c0102e26 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102e26:	6a 00                	push   $0x0
  pushl $184
c0102e28:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102e2d:	e9 54 03 00 00       	jmp    c0103186 <__alltraps>

c0102e32 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102e32:	6a 00                	push   $0x0
  pushl $185
c0102e34:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102e39:	e9 48 03 00 00       	jmp    c0103186 <__alltraps>

c0102e3e <vector186>:
.globl vector186
vector186:
  pushl $0
c0102e3e:	6a 00                	push   $0x0
  pushl $186
c0102e40:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102e45:	e9 3c 03 00 00       	jmp    c0103186 <__alltraps>

c0102e4a <vector187>:
.globl vector187
vector187:
  pushl $0
c0102e4a:	6a 00                	push   $0x0
  pushl $187
c0102e4c:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102e51:	e9 30 03 00 00       	jmp    c0103186 <__alltraps>

c0102e56 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102e56:	6a 00                	push   $0x0
  pushl $188
c0102e58:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102e5d:	e9 24 03 00 00       	jmp    c0103186 <__alltraps>

c0102e62 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102e62:	6a 00                	push   $0x0
  pushl $189
c0102e64:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102e69:	e9 18 03 00 00       	jmp    c0103186 <__alltraps>

c0102e6e <vector190>:
.globl vector190
vector190:
  pushl $0
c0102e6e:	6a 00                	push   $0x0
  pushl $190
c0102e70:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102e75:	e9 0c 03 00 00       	jmp    c0103186 <__alltraps>

c0102e7a <vector191>:
.globl vector191
vector191:
  pushl $0
c0102e7a:	6a 00                	push   $0x0
  pushl $191
c0102e7c:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102e81:	e9 00 03 00 00       	jmp    c0103186 <__alltraps>

c0102e86 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102e86:	6a 00                	push   $0x0
  pushl $192
c0102e88:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102e8d:	e9 f4 02 00 00       	jmp    c0103186 <__alltraps>

c0102e92 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102e92:	6a 00                	push   $0x0
  pushl $193
c0102e94:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102e99:	e9 e8 02 00 00       	jmp    c0103186 <__alltraps>

c0102e9e <vector194>:
.globl vector194
vector194:
  pushl $0
c0102e9e:	6a 00                	push   $0x0
  pushl $194
c0102ea0:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102ea5:	e9 dc 02 00 00       	jmp    c0103186 <__alltraps>

c0102eaa <vector195>:
.globl vector195
vector195:
  pushl $0
c0102eaa:	6a 00                	push   $0x0
  pushl $195
c0102eac:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102eb1:	e9 d0 02 00 00       	jmp    c0103186 <__alltraps>

c0102eb6 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102eb6:	6a 00                	push   $0x0
  pushl $196
c0102eb8:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102ebd:	e9 c4 02 00 00       	jmp    c0103186 <__alltraps>

c0102ec2 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102ec2:	6a 00                	push   $0x0
  pushl $197
c0102ec4:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102ec9:	e9 b8 02 00 00       	jmp    c0103186 <__alltraps>

c0102ece <vector198>:
.globl vector198
vector198:
  pushl $0
c0102ece:	6a 00                	push   $0x0
  pushl $198
c0102ed0:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102ed5:	e9 ac 02 00 00       	jmp    c0103186 <__alltraps>

c0102eda <vector199>:
.globl vector199
vector199:
  pushl $0
c0102eda:	6a 00                	push   $0x0
  pushl $199
c0102edc:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102ee1:	e9 a0 02 00 00       	jmp    c0103186 <__alltraps>

c0102ee6 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102ee6:	6a 00                	push   $0x0
  pushl $200
c0102ee8:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102eed:	e9 94 02 00 00       	jmp    c0103186 <__alltraps>

c0102ef2 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102ef2:	6a 00                	push   $0x0
  pushl $201
c0102ef4:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102ef9:	e9 88 02 00 00       	jmp    c0103186 <__alltraps>

c0102efe <vector202>:
.globl vector202
vector202:
  pushl $0
c0102efe:	6a 00                	push   $0x0
  pushl $202
c0102f00:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102f05:	e9 7c 02 00 00       	jmp    c0103186 <__alltraps>

c0102f0a <vector203>:
.globl vector203
vector203:
  pushl $0
c0102f0a:	6a 00                	push   $0x0
  pushl $203
c0102f0c:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102f11:	e9 70 02 00 00       	jmp    c0103186 <__alltraps>

c0102f16 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102f16:	6a 00                	push   $0x0
  pushl $204
c0102f18:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102f1d:	e9 64 02 00 00       	jmp    c0103186 <__alltraps>

c0102f22 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102f22:	6a 00                	push   $0x0
  pushl $205
c0102f24:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102f29:	e9 58 02 00 00       	jmp    c0103186 <__alltraps>

c0102f2e <vector206>:
.globl vector206
vector206:
  pushl $0
c0102f2e:	6a 00                	push   $0x0
  pushl $206
c0102f30:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102f35:	e9 4c 02 00 00       	jmp    c0103186 <__alltraps>

c0102f3a <vector207>:
.globl vector207
vector207:
  pushl $0
c0102f3a:	6a 00                	push   $0x0
  pushl $207
c0102f3c:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102f41:	e9 40 02 00 00       	jmp    c0103186 <__alltraps>

c0102f46 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102f46:	6a 00                	push   $0x0
  pushl $208
c0102f48:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102f4d:	e9 34 02 00 00       	jmp    c0103186 <__alltraps>

c0102f52 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102f52:	6a 00                	push   $0x0
  pushl $209
c0102f54:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102f59:	e9 28 02 00 00       	jmp    c0103186 <__alltraps>

c0102f5e <vector210>:
.globl vector210
vector210:
  pushl $0
c0102f5e:	6a 00                	push   $0x0
  pushl $210
c0102f60:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102f65:	e9 1c 02 00 00       	jmp    c0103186 <__alltraps>

c0102f6a <vector211>:
.globl vector211
vector211:
  pushl $0
c0102f6a:	6a 00                	push   $0x0
  pushl $211
c0102f6c:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102f71:	e9 10 02 00 00       	jmp    c0103186 <__alltraps>

c0102f76 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102f76:	6a 00                	push   $0x0
  pushl $212
c0102f78:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102f7d:	e9 04 02 00 00       	jmp    c0103186 <__alltraps>

c0102f82 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102f82:	6a 00                	push   $0x0
  pushl $213
c0102f84:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102f89:	e9 f8 01 00 00       	jmp    c0103186 <__alltraps>

c0102f8e <vector214>:
.globl vector214
vector214:
  pushl $0
c0102f8e:	6a 00                	push   $0x0
  pushl $214
c0102f90:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102f95:	e9 ec 01 00 00       	jmp    c0103186 <__alltraps>

c0102f9a <vector215>:
.globl vector215
vector215:
  pushl $0
c0102f9a:	6a 00                	push   $0x0
  pushl $215
c0102f9c:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102fa1:	e9 e0 01 00 00       	jmp    c0103186 <__alltraps>

c0102fa6 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102fa6:	6a 00                	push   $0x0
  pushl $216
c0102fa8:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102fad:	e9 d4 01 00 00       	jmp    c0103186 <__alltraps>

c0102fb2 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102fb2:	6a 00                	push   $0x0
  pushl $217
c0102fb4:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102fb9:	e9 c8 01 00 00       	jmp    c0103186 <__alltraps>

c0102fbe <vector218>:
.globl vector218
vector218:
  pushl $0
c0102fbe:	6a 00                	push   $0x0
  pushl $218
c0102fc0:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102fc5:	e9 bc 01 00 00       	jmp    c0103186 <__alltraps>

c0102fca <vector219>:
.globl vector219
vector219:
  pushl $0
c0102fca:	6a 00                	push   $0x0
  pushl $219
c0102fcc:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102fd1:	e9 b0 01 00 00       	jmp    c0103186 <__alltraps>

c0102fd6 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102fd6:	6a 00                	push   $0x0
  pushl $220
c0102fd8:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102fdd:	e9 a4 01 00 00       	jmp    c0103186 <__alltraps>

c0102fe2 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102fe2:	6a 00                	push   $0x0
  pushl $221
c0102fe4:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102fe9:	e9 98 01 00 00       	jmp    c0103186 <__alltraps>

c0102fee <vector222>:
.globl vector222
vector222:
  pushl $0
c0102fee:	6a 00                	push   $0x0
  pushl $222
c0102ff0:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102ff5:	e9 8c 01 00 00       	jmp    c0103186 <__alltraps>

c0102ffa <vector223>:
.globl vector223
vector223:
  pushl $0
c0102ffa:	6a 00                	push   $0x0
  pushl $223
c0102ffc:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103001:	e9 80 01 00 00       	jmp    c0103186 <__alltraps>

c0103006 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103006:	6a 00                	push   $0x0
  pushl $224
c0103008:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010300d:	e9 74 01 00 00       	jmp    c0103186 <__alltraps>

c0103012 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103012:	6a 00                	push   $0x0
  pushl $225
c0103014:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103019:	e9 68 01 00 00       	jmp    c0103186 <__alltraps>

c010301e <vector226>:
.globl vector226
vector226:
  pushl $0
c010301e:	6a 00                	push   $0x0
  pushl $226
c0103020:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0103025:	e9 5c 01 00 00       	jmp    c0103186 <__alltraps>

c010302a <vector227>:
.globl vector227
vector227:
  pushl $0
c010302a:	6a 00                	push   $0x0
  pushl $227
c010302c:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103031:	e9 50 01 00 00       	jmp    c0103186 <__alltraps>

c0103036 <vector228>:
.globl vector228
vector228:
  pushl $0
c0103036:	6a 00                	push   $0x0
  pushl $228
c0103038:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010303d:	e9 44 01 00 00       	jmp    c0103186 <__alltraps>

c0103042 <vector229>:
.globl vector229
vector229:
  pushl $0
c0103042:	6a 00                	push   $0x0
  pushl $229
c0103044:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0103049:	e9 38 01 00 00       	jmp    c0103186 <__alltraps>

c010304e <vector230>:
.globl vector230
vector230:
  pushl $0
c010304e:	6a 00                	push   $0x0
  pushl $230
c0103050:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0103055:	e9 2c 01 00 00       	jmp    c0103186 <__alltraps>

c010305a <vector231>:
.globl vector231
vector231:
  pushl $0
c010305a:	6a 00                	push   $0x0
  pushl $231
c010305c:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0103061:	e9 20 01 00 00       	jmp    c0103186 <__alltraps>

c0103066 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103066:	6a 00                	push   $0x0
  pushl $232
c0103068:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010306d:	e9 14 01 00 00       	jmp    c0103186 <__alltraps>

c0103072 <vector233>:
.globl vector233
vector233:
  pushl $0
c0103072:	6a 00                	push   $0x0
  pushl $233
c0103074:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103079:	e9 08 01 00 00       	jmp    c0103186 <__alltraps>

c010307e <vector234>:
.globl vector234
vector234:
  pushl $0
c010307e:	6a 00                	push   $0x0
  pushl $234
c0103080:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0103085:	e9 fc 00 00 00       	jmp    c0103186 <__alltraps>

c010308a <vector235>:
.globl vector235
vector235:
  pushl $0
c010308a:	6a 00                	push   $0x0
  pushl $235
c010308c:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103091:	e9 f0 00 00 00       	jmp    c0103186 <__alltraps>

c0103096 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103096:	6a 00                	push   $0x0
  pushl $236
c0103098:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010309d:	e9 e4 00 00 00       	jmp    c0103186 <__alltraps>

c01030a2 <vector237>:
.globl vector237
vector237:
  pushl $0
c01030a2:	6a 00                	push   $0x0
  pushl $237
c01030a4:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01030a9:	e9 d8 00 00 00       	jmp    c0103186 <__alltraps>

c01030ae <vector238>:
.globl vector238
vector238:
  pushl $0
c01030ae:	6a 00                	push   $0x0
  pushl $238
c01030b0:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01030b5:	e9 cc 00 00 00       	jmp    c0103186 <__alltraps>

c01030ba <vector239>:
.globl vector239
vector239:
  pushl $0
c01030ba:	6a 00                	push   $0x0
  pushl $239
c01030bc:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01030c1:	e9 c0 00 00 00       	jmp    c0103186 <__alltraps>

c01030c6 <vector240>:
.globl vector240
vector240:
  pushl $0
c01030c6:	6a 00                	push   $0x0
  pushl $240
c01030c8:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01030cd:	e9 b4 00 00 00       	jmp    c0103186 <__alltraps>

c01030d2 <vector241>:
.globl vector241
vector241:
  pushl $0
c01030d2:	6a 00                	push   $0x0
  pushl $241
c01030d4:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01030d9:	e9 a8 00 00 00       	jmp    c0103186 <__alltraps>

c01030de <vector242>:
.globl vector242
vector242:
  pushl $0
c01030de:	6a 00                	push   $0x0
  pushl $242
c01030e0:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01030e5:	e9 9c 00 00 00       	jmp    c0103186 <__alltraps>

c01030ea <vector243>:
.globl vector243
vector243:
  pushl $0
c01030ea:	6a 00                	push   $0x0
  pushl $243
c01030ec:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01030f1:	e9 90 00 00 00       	jmp    c0103186 <__alltraps>

c01030f6 <vector244>:
.globl vector244
vector244:
  pushl $0
c01030f6:	6a 00                	push   $0x0
  pushl $244
c01030f8:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01030fd:	e9 84 00 00 00       	jmp    c0103186 <__alltraps>

c0103102 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103102:	6a 00                	push   $0x0
  pushl $245
c0103104:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103109:	e9 78 00 00 00       	jmp    c0103186 <__alltraps>

c010310e <vector246>:
.globl vector246
vector246:
  pushl $0
c010310e:	6a 00                	push   $0x0
  pushl $246
c0103110:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103115:	e9 6c 00 00 00       	jmp    c0103186 <__alltraps>

c010311a <vector247>:
.globl vector247
vector247:
  pushl $0
c010311a:	6a 00                	push   $0x0
  pushl $247
c010311c:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103121:	e9 60 00 00 00       	jmp    c0103186 <__alltraps>

c0103126 <vector248>:
.globl vector248
vector248:
  pushl $0
c0103126:	6a 00                	push   $0x0
  pushl $248
c0103128:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010312d:	e9 54 00 00 00       	jmp    c0103186 <__alltraps>

c0103132 <vector249>:
.globl vector249
vector249:
  pushl $0
c0103132:	6a 00                	push   $0x0
  pushl $249
c0103134:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103139:	e9 48 00 00 00       	jmp    c0103186 <__alltraps>

c010313e <vector250>:
.globl vector250
vector250:
  pushl $0
c010313e:	6a 00                	push   $0x0
  pushl $250
c0103140:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0103145:	e9 3c 00 00 00       	jmp    c0103186 <__alltraps>

c010314a <vector251>:
.globl vector251
vector251:
  pushl $0
c010314a:	6a 00                	push   $0x0
  pushl $251
c010314c:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0103151:	e9 30 00 00 00       	jmp    c0103186 <__alltraps>

c0103156 <vector252>:
.globl vector252
vector252:
  pushl $0
c0103156:	6a 00                	push   $0x0
  pushl $252
c0103158:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010315d:	e9 24 00 00 00       	jmp    c0103186 <__alltraps>

c0103162 <vector253>:
.globl vector253
vector253:
  pushl $0
c0103162:	6a 00                	push   $0x0
  pushl $253
c0103164:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103169:	e9 18 00 00 00       	jmp    c0103186 <__alltraps>

c010316e <vector254>:
.globl vector254
vector254:
  pushl $0
c010316e:	6a 00                	push   $0x0
  pushl $254
c0103170:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0103175:	e9 0c 00 00 00       	jmp    c0103186 <__alltraps>

c010317a <vector255>:
.globl vector255
vector255:
  pushl $0
c010317a:	6a 00                	push   $0x0
  pushl $255
c010317c:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0103181:	e9 00 00 00 00       	jmp    c0103186 <__alltraps>

c0103186 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0103186:	1e                   	push   %ds
    pushl %es
c0103187:	06                   	push   %es
    pushl %fs
c0103188:	0f a0                	push   %fs
    pushl %gs
c010318a:	0f a8                	push   %gs
    pushal
c010318c:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c010318d:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0103192:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0103194:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0103196:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0103197:	e8 63 f5 ff ff       	call   c01026ff <trap>

    # pop the pushed stack pointer
    popl %esp
c010319c:	5c                   	pop    %esp

c010319d <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c010319d:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c010319e:	0f a9                	pop    %gs
    popl %fs
c01031a0:	0f a1                	pop    %fs
    popl %es
c01031a2:	07                   	pop    %es
    popl %ds
c01031a3:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01031a4:	83 c4 08             	add    $0x8,%esp
    iret
c01031a7:	cf                   	iret   

c01031a8 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c01031a8:	55                   	push   %ebp
c01031a9:	89 e5                	mov    %esp,%ebp
c01031ab:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c01031ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01031b1:	c1 e8 0c             	shr    $0xc,%eax
c01031b4:	89 c2                	mov    %eax,%edx
c01031b6:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c01031bb:	39 c2                	cmp    %eax,%edx
c01031bd:	72 14                	jb     c01031d3 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c01031bf:	83 ec 04             	sub    $0x4,%esp
c01031c2:	68 f0 8b 10 c0       	push   $0xc0108bf0
c01031c7:	6a 5b                	push   $0x5b
c01031c9:	68 0f 8c 10 c0       	push   $0xc0108c0f
c01031ce:	e8 15 d2 ff ff       	call   c01003e8 <__panic>
    }
    return &pages[PPN(pa)];
c01031d3:	a1 f8 30 12 c0       	mov    0xc01230f8,%eax
c01031d8:	8b 55 08             	mov    0x8(%ebp),%edx
c01031db:	c1 ea 0c             	shr    $0xc,%edx
c01031de:	c1 e2 05             	shl    $0x5,%edx
c01031e1:	01 d0                	add    %edx,%eax
}
c01031e3:	c9                   	leave  
c01031e4:	c3                   	ret    

c01031e5 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c01031e5:	55                   	push   %ebp
c01031e6:	89 e5                	mov    %esp,%ebp
c01031e8:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c01031eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01031ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01031f3:	83 ec 0c             	sub    $0xc,%esp
c01031f6:	50                   	push   %eax
c01031f7:	e8 ac ff ff ff       	call   c01031a8 <pa2page>
c01031fc:	83 c4 10             	add    $0x10,%esp
}
c01031ff:	c9                   	leave  
c0103200:	c3                   	ret    

c0103201 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0103201:	55                   	push   %ebp
c0103202:	89 e5                	mov    %esp,%ebp
c0103204:	83 ec 18             	sub    $0x18,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0103207:	83 ec 0c             	sub    $0xc,%esp
c010320a:	6a 18                	push   $0x18
c010320c:	e8 2c 43 00 00       	call   c010753d <kmalloc>
c0103211:	83 c4 10             	add    $0x10,%esp
c0103214:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0103217:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010321b:	74 5b                	je     c0103278 <mm_create+0x77>
        list_init(&(mm->mmap_list));
c010321d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103220:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103223:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103226:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103229:	89 50 04             	mov    %edx,0x4(%eax)
c010322c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010322f:	8b 50 04             	mov    0x4(%eax),%edx
c0103232:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103235:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0103237:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010323a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0103241:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103244:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c010324b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010324e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0103255:	a1 68 2f 12 c0       	mov    0xc0122f68,%eax
c010325a:	85 c0                	test   %eax,%eax
c010325c:	74 10                	je     c010326e <mm_create+0x6d>
c010325e:	83 ec 0c             	sub    $0xc,%esp
c0103261:	ff 75 f4             	pushl  -0xc(%ebp)
c0103264:	e8 13 11 00 00       	call   c010437c <swap_init_mm>
c0103269:	83 c4 10             	add    $0x10,%esp
c010326c:	eb 0a                	jmp    c0103278 <mm_create+0x77>
        else mm->sm_priv = NULL;
c010326e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103271:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0103278:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010327b:	c9                   	leave  
c010327c:	c3                   	ret    

c010327d <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c010327d:	55                   	push   %ebp
c010327e:	89 e5                	mov    %esp,%ebp
c0103280:	83 ec 18             	sub    $0x18,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0103283:	83 ec 0c             	sub    $0xc,%esp
c0103286:	6a 18                	push   $0x18
c0103288:	e8 b0 42 00 00       	call   c010753d <kmalloc>
c010328d:	83 c4 10             	add    $0x10,%esp
c0103290:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0103293:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103297:	74 1b                	je     c01032b4 <vma_create+0x37>
        vma->vm_start = vm_start;
c0103299:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010329c:	8b 55 08             	mov    0x8(%ebp),%edx
c010329f:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c01032a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032a5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01032a8:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c01032ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032ae:	8b 55 10             	mov    0x10(%ebp),%edx
c01032b1:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c01032b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01032b7:	c9                   	leave  
c01032b8:	c3                   	ret    

c01032b9 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c01032b9:	55                   	push   %ebp
c01032ba:	89 e5                	mov    %esp,%ebp
c01032bc:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c01032bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c01032c6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01032ca:	0f 84 95 00 00 00    	je     c0103365 <find_vma+0xac>
        vma = mm->mmap_cache;
c01032d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01032d3:	8b 40 08             	mov    0x8(%eax),%eax
c01032d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c01032d9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01032dd:	74 16                	je     c01032f5 <find_vma+0x3c>
c01032df:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01032e2:	8b 40 04             	mov    0x4(%eax),%eax
c01032e5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01032e8:	77 0b                	ja     c01032f5 <find_vma+0x3c>
c01032ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01032ed:	8b 40 08             	mov    0x8(%eax),%eax
c01032f0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01032f3:	77 61                	ja     c0103356 <find_vma+0x9d>
                bool found = 0;
c01032f5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c01032fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103302:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103305:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0103308:	eb 28                	jmp    c0103332 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c010330a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010330d:	83 e8 10             	sub    $0x10,%eax
c0103310:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0103313:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103316:	8b 40 04             	mov    0x4(%eax),%eax
c0103319:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010331c:	77 14                	ja     c0103332 <find_vma+0x79>
c010331e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103321:	8b 40 08             	mov    0x8(%eax),%eax
c0103324:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103327:	76 09                	jbe    c0103332 <find_vma+0x79>
                        found = 1;
c0103329:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0103330:	eb 17                	jmp    c0103349 <find_vma+0x90>
c0103332:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103335:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103338:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010333b:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c010333e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103341:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103344:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103347:	75 c1                	jne    c010330a <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c0103349:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c010334d:	75 07                	jne    c0103356 <find_vma+0x9d>
                    vma = NULL;
c010334f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0103356:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010335a:	74 09                	je     c0103365 <find_vma+0xac>
            mm->mmap_cache = vma;
c010335c:	8b 45 08             	mov    0x8(%ebp),%eax
c010335f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103362:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0103365:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0103368:	c9                   	leave  
c0103369:	c3                   	ret    

c010336a <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c010336a:	55                   	push   %ebp
c010336b:	89 e5                	mov    %esp,%ebp
c010336d:	83 ec 08             	sub    $0x8,%esp
    assert(prev->vm_start < prev->vm_end);
c0103370:	8b 45 08             	mov    0x8(%ebp),%eax
c0103373:	8b 50 04             	mov    0x4(%eax),%edx
c0103376:	8b 45 08             	mov    0x8(%ebp),%eax
c0103379:	8b 40 08             	mov    0x8(%eax),%eax
c010337c:	39 c2                	cmp    %eax,%edx
c010337e:	72 16                	jb     c0103396 <check_vma_overlap+0x2c>
c0103380:	68 1d 8c 10 c0       	push   $0xc0108c1d
c0103385:	68 3b 8c 10 c0       	push   $0xc0108c3b
c010338a:	6a 67                	push   $0x67
c010338c:	68 50 8c 10 c0       	push   $0xc0108c50
c0103391:	e8 52 d0 ff ff       	call   c01003e8 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0103396:	8b 45 08             	mov    0x8(%ebp),%eax
c0103399:	8b 50 08             	mov    0x8(%eax),%edx
c010339c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010339f:	8b 40 04             	mov    0x4(%eax),%eax
c01033a2:	39 c2                	cmp    %eax,%edx
c01033a4:	76 16                	jbe    c01033bc <check_vma_overlap+0x52>
c01033a6:	68 60 8c 10 c0       	push   $0xc0108c60
c01033ab:	68 3b 8c 10 c0       	push   $0xc0108c3b
c01033b0:	6a 68                	push   $0x68
c01033b2:	68 50 8c 10 c0       	push   $0xc0108c50
c01033b7:	e8 2c d0 ff ff       	call   c01003e8 <__panic>
    assert(next->vm_start < next->vm_end);
c01033bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033bf:	8b 50 04             	mov    0x4(%eax),%edx
c01033c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033c5:	8b 40 08             	mov    0x8(%eax),%eax
c01033c8:	39 c2                	cmp    %eax,%edx
c01033ca:	72 16                	jb     c01033e2 <check_vma_overlap+0x78>
c01033cc:	68 7f 8c 10 c0       	push   $0xc0108c7f
c01033d1:	68 3b 8c 10 c0       	push   $0xc0108c3b
c01033d6:	6a 69                	push   $0x69
c01033d8:	68 50 8c 10 c0       	push   $0xc0108c50
c01033dd:	e8 06 d0 ff ff       	call   c01003e8 <__panic>
}
c01033e2:	90                   	nop
c01033e3:	c9                   	leave  
c01033e4:	c3                   	ret    

c01033e5 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c01033e5:	55                   	push   %ebp
c01033e6:	89 e5                	mov    %esp,%ebp
c01033e8:	83 ec 38             	sub    $0x38,%esp
    assert(vma->vm_start < vma->vm_end);
c01033eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033ee:	8b 50 04             	mov    0x4(%eax),%edx
c01033f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033f4:	8b 40 08             	mov    0x8(%eax),%eax
c01033f7:	39 c2                	cmp    %eax,%edx
c01033f9:	72 16                	jb     c0103411 <insert_vma_struct+0x2c>
c01033fb:	68 9d 8c 10 c0       	push   $0xc0108c9d
c0103400:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103405:	6a 70                	push   $0x70
c0103407:	68 50 8c 10 c0       	push   $0xc0108c50
c010340c:	e8 d7 cf ff ff       	call   c01003e8 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0103411:	8b 45 08             	mov    0x8(%ebp),%eax
c0103414:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0103417:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010341a:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c010341d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103420:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0103423:	eb 1f                	jmp    c0103444 <insert_vma_struct+0x5f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0103425:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103428:	83 e8 10             	sub    $0x10,%eax
c010342b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c010342e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103431:	8b 50 04             	mov    0x4(%eax),%edx
c0103434:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103437:	8b 40 04             	mov    0x4(%eax),%eax
c010343a:	39 c2                	cmp    %eax,%edx
c010343c:	77 1f                	ja     c010345d <insert_vma_struct+0x78>
                break;
            }
            le_prev = le;
c010343e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103441:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103444:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103447:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010344a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010344d:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c0103450:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103453:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103456:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103459:	75 ca                	jne    c0103425 <insert_vma_struct+0x40>
c010345b:	eb 01                	jmp    c010345e <insert_vma_struct+0x79>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
                break;
c010345d:	90                   	nop
c010345e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103461:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103464:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103467:	8b 40 04             	mov    0x4(%eax),%eax
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c010346a:	89 45 dc             	mov    %eax,-0x24(%ebp)

    /* check overlap */
    if (le_prev != list) {
c010346d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103470:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103473:	74 15                	je     c010348a <insert_vma_struct+0xa5>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0103475:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103478:	83 e8 10             	sub    $0x10,%eax
c010347b:	83 ec 08             	sub    $0x8,%esp
c010347e:	ff 75 0c             	pushl  0xc(%ebp)
c0103481:	50                   	push   %eax
c0103482:	e8 e3 fe ff ff       	call   c010336a <check_vma_overlap>
c0103487:	83 c4 10             	add    $0x10,%esp
    }
    if (le_next != list) {
c010348a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010348d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103490:	74 15                	je     c01034a7 <insert_vma_struct+0xc2>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0103492:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103495:	83 e8 10             	sub    $0x10,%eax
c0103498:	83 ec 08             	sub    $0x8,%esp
c010349b:	50                   	push   %eax
c010349c:	ff 75 0c             	pushl  0xc(%ebp)
c010349f:	e8 c6 fe ff ff       	call   c010336a <check_vma_overlap>
c01034a4:	83 c4 10             	add    $0x10,%esp
    }

    vma->vm_mm = mm;
c01034a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034aa:	8b 55 08             	mov    0x8(%ebp),%edx
c01034ad:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c01034af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034b2:	8d 50 10             	lea    0x10(%eax),%edx
c01034b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01034bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01034be:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01034c1:	8b 40 04             	mov    0x4(%eax),%eax
c01034c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01034c7:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01034ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01034cd:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01034d0:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01034d3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01034d6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01034d9:	89 10                	mov    %edx,(%eax)
c01034db:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01034de:	8b 10                	mov    (%eax),%edx
c01034e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034e3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01034e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01034e9:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01034ec:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01034ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01034f2:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01034f5:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c01034f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01034fa:	8b 40 10             	mov    0x10(%eax),%eax
c01034fd:	8d 50 01             	lea    0x1(%eax),%edx
c0103500:	8b 45 08             	mov    0x8(%ebp),%eax
c0103503:	89 50 10             	mov    %edx,0x10(%eax)
}
c0103506:	90                   	nop
c0103507:	c9                   	leave  
c0103508:	c3                   	ret    

c0103509 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0103509:	55                   	push   %ebp
c010350a:	89 e5                	mov    %esp,%ebp
c010350c:	83 ec 28             	sub    $0x28,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c010350f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103512:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0103515:	eb 3c                	jmp    c0103553 <mm_destroy+0x4a>
c0103517:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010351a:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010351d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103520:	8b 40 04             	mov    0x4(%eax),%eax
c0103523:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0103526:	8b 12                	mov    (%edx),%edx
c0103528:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010352b:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010352e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103531:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103534:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103537:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010353a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010353d:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c010353f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103542:	83 e8 10             	sub    $0x10,%eax
c0103545:	83 ec 08             	sub    $0x8,%esp
c0103548:	6a 18                	push   $0x18
c010354a:	50                   	push   %eax
c010354b:	e8 7e 40 00 00       	call   c01075ce <kfree>
c0103550:	83 c4 10             	add    $0x10,%esp
c0103553:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103556:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103559:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010355c:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c010355f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103562:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103565:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103568:	75 ad                	jne    c0103517 <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c010356a:	83 ec 08             	sub    $0x8,%esp
c010356d:	6a 18                	push   $0x18
c010356f:	ff 75 08             	pushl  0x8(%ebp)
c0103572:	e8 57 40 00 00       	call   c01075ce <kfree>
c0103577:	83 c4 10             	add    $0x10,%esp
    mm=NULL;
c010357a:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0103581:	90                   	nop
c0103582:	c9                   	leave  
c0103583:	c3                   	ret    

c0103584 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0103584:	55                   	push   %ebp
c0103585:	89 e5                	mov    %esp,%ebp
c0103587:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c010358a:	e8 03 00 00 00       	call   c0103592 <check_vmm>
}
c010358f:	90                   	nop
c0103590:	c9                   	leave  
c0103591:	c3                   	ret    

c0103592 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0103592:	55                   	push   %ebp
c0103593:	89 e5                	mov    %esp,%ebp
c0103595:	83 ec 18             	sub    $0x18,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103598:	e8 40 2b 00 00       	call   c01060dd <nr_free_pages>
c010359d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01035a0:	e8 3b 00 00 00       	call   c01035e0 <check_vma_struct>
    check_pgfault();
c01035a5:	e8 56 04 00 00       	call   c0103a00 <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c01035aa:	e8 2e 2b 00 00       	call   c01060dd <nr_free_pages>
c01035af:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01035b2:	74 19                	je     c01035cd <check_vmm+0x3b>
c01035b4:	68 bc 8c 10 c0       	push   $0xc0108cbc
c01035b9:	68 3b 8c 10 c0       	push   $0xc0108c3b
c01035be:	68 a9 00 00 00       	push   $0xa9
c01035c3:	68 50 8c 10 c0       	push   $0xc0108c50
c01035c8:	e8 1b ce ff ff       	call   c01003e8 <__panic>

    cprintf("check_vmm() succeeded.\n");
c01035cd:	83 ec 0c             	sub    $0xc,%esp
c01035d0:	68 e3 8c 10 c0       	push   $0xc0108ce3
c01035d5:	e8 a8 cc ff ff       	call   c0100282 <cprintf>
c01035da:	83 c4 10             	add    $0x10,%esp
}
c01035dd:	90                   	nop
c01035de:	c9                   	leave  
c01035df:	c3                   	ret    

c01035e0 <check_vma_struct>:

static void
check_vma_struct(void) {
c01035e0:	55                   	push   %ebp
c01035e1:	89 e5                	mov    %esp,%ebp
c01035e3:	83 ec 58             	sub    $0x58,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01035e6:	e8 f2 2a 00 00       	call   c01060dd <nr_free_pages>
c01035eb:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01035ee:	e8 0e fc ff ff       	call   c0103201 <mm_create>
c01035f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01035f6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01035fa:	75 19                	jne    c0103615 <check_vma_struct+0x35>
c01035fc:	68 fb 8c 10 c0       	push   $0xc0108cfb
c0103601:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103606:	68 b3 00 00 00       	push   $0xb3
c010360b:	68 50 8c 10 c0       	push   $0xc0108c50
c0103610:	e8 d3 cd ff ff       	call   c01003e8 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0103615:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c010361c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010361f:	89 d0                	mov    %edx,%eax
c0103621:	c1 e0 02             	shl    $0x2,%eax
c0103624:	01 d0                	add    %edx,%eax
c0103626:	01 c0                	add    %eax,%eax
c0103628:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c010362b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010362e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103631:	eb 5f                	jmp    c0103692 <check_vma_struct+0xb2>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103633:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103636:	89 d0                	mov    %edx,%eax
c0103638:	c1 e0 02             	shl    $0x2,%eax
c010363b:	01 d0                	add    %edx,%eax
c010363d:	83 c0 02             	add    $0x2,%eax
c0103640:	89 c1                	mov    %eax,%ecx
c0103642:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103645:	89 d0                	mov    %edx,%eax
c0103647:	c1 e0 02             	shl    $0x2,%eax
c010364a:	01 d0                	add    %edx,%eax
c010364c:	83 ec 04             	sub    $0x4,%esp
c010364f:	6a 00                	push   $0x0
c0103651:	51                   	push   %ecx
c0103652:	50                   	push   %eax
c0103653:	e8 25 fc ff ff       	call   c010327d <vma_create>
c0103658:	83 c4 10             	add    $0x10,%esp
c010365b:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c010365e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103662:	75 19                	jne    c010367d <check_vma_struct+0x9d>
c0103664:	68 06 8d 10 c0       	push   $0xc0108d06
c0103669:	68 3b 8c 10 c0       	push   $0xc0108c3b
c010366e:	68 ba 00 00 00       	push   $0xba
c0103673:	68 50 8c 10 c0       	push   $0xc0108c50
c0103678:	e8 6b cd ff ff       	call   c01003e8 <__panic>
        insert_vma_struct(mm, vma);
c010367d:	83 ec 08             	sub    $0x8,%esp
c0103680:	ff 75 dc             	pushl  -0x24(%ebp)
c0103683:	ff 75 e8             	pushl  -0x18(%ebp)
c0103686:	e8 5a fd ff ff       	call   c01033e5 <insert_vma_struct>
c010368b:	83 c4 10             	add    $0x10,%esp
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c010368e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0103692:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103696:	7f 9b                	jg     c0103633 <check_vma_struct+0x53>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103698:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010369b:	83 c0 01             	add    $0x1,%eax
c010369e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01036a1:	eb 5f                	jmp    c0103702 <check_vma_struct+0x122>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01036a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01036a6:	89 d0                	mov    %edx,%eax
c01036a8:	c1 e0 02             	shl    $0x2,%eax
c01036ab:	01 d0                	add    %edx,%eax
c01036ad:	83 c0 02             	add    $0x2,%eax
c01036b0:	89 c1                	mov    %eax,%ecx
c01036b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01036b5:	89 d0                	mov    %edx,%eax
c01036b7:	c1 e0 02             	shl    $0x2,%eax
c01036ba:	01 d0                	add    %edx,%eax
c01036bc:	83 ec 04             	sub    $0x4,%esp
c01036bf:	6a 00                	push   $0x0
c01036c1:	51                   	push   %ecx
c01036c2:	50                   	push   %eax
c01036c3:	e8 b5 fb ff ff       	call   c010327d <vma_create>
c01036c8:	83 c4 10             	add    $0x10,%esp
c01036cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c01036ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01036d2:	75 19                	jne    c01036ed <check_vma_struct+0x10d>
c01036d4:	68 06 8d 10 c0       	push   $0xc0108d06
c01036d9:	68 3b 8c 10 c0       	push   $0xc0108c3b
c01036de:	68 c0 00 00 00       	push   $0xc0
c01036e3:	68 50 8c 10 c0       	push   $0xc0108c50
c01036e8:	e8 fb cc ff ff       	call   c01003e8 <__panic>
        insert_vma_struct(mm, vma);
c01036ed:	83 ec 08             	sub    $0x8,%esp
c01036f0:	ff 75 d8             	pushl  -0x28(%ebp)
c01036f3:	ff 75 e8             	pushl  -0x18(%ebp)
c01036f6:	e8 ea fc ff ff       	call   c01033e5 <insert_vma_struct>
c01036fb:	83 c4 10             	add    $0x10,%esp
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01036fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103702:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103705:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103708:	7e 99                	jle    c01036a3 <check_vma_struct+0xc3>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c010370a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010370d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103710:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103713:	8b 40 04             	mov    0x4(%eax),%eax
c0103716:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0103719:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0103720:	e9 81 00 00 00       	jmp    c01037a6 <check_vma_struct+0x1c6>
        assert(le != &(mm->mmap_list));
c0103725:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103728:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010372b:	75 19                	jne    c0103746 <check_vma_struct+0x166>
c010372d:	68 12 8d 10 c0       	push   $0xc0108d12
c0103732:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103737:	68 c7 00 00 00       	push   $0xc7
c010373c:	68 50 8c 10 c0       	push   $0xc0108c50
c0103741:	e8 a2 cc ff ff       	call   c01003e8 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0103746:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103749:	83 e8 10             	sub    $0x10,%eax
c010374c:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c010374f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103752:	8b 48 04             	mov    0x4(%eax),%ecx
c0103755:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103758:	89 d0                	mov    %edx,%eax
c010375a:	c1 e0 02             	shl    $0x2,%eax
c010375d:	01 d0                	add    %edx,%eax
c010375f:	39 c1                	cmp    %eax,%ecx
c0103761:	75 17                	jne    c010377a <check_vma_struct+0x19a>
c0103763:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103766:	8b 48 08             	mov    0x8(%eax),%ecx
c0103769:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010376c:	89 d0                	mov    %edx,%eax
c010376e:	c1 e0 02             	shl    $0x2,%eax
c0103771:	01 d0                	add    %edx,%eax
c0103773:	83 c0 02             	add    $0x2,%eax
c0103776:	39 c1                	cmp    %eax,%ecx
c0103778:	74 19                	je     c0103793 <check_vma_struct+0x1b3>
c010377a:	68 2c 8d 10 c0       	push   $0xc0108d2c
c010377f:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103784:	68 c9 00 00 00       	push   $0xc9
c0103789:	68 50 8c 10 c0       	push   $0xc0108c50
c010378e:	e8 55 cc ff ff       	call   c01003e8 <__panic>
c0103793:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103796:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0103799:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010379c:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010379f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c01037a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01037a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037a9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01037ac:	0f 8e 73 ff ff ff    	jle    c0103725 <check_vma_struct+0x145>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01037b2:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01037b9:	e9 80 01 00 00       	jmp    c010393e <check_vma_struct+0x35e>
        struct vma_struct *vma1 = find_vma(mm, i);
c01037be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037c1:	83 ec 08             	sub    $0x8,%esp
c01037c4:	50                   	push   %eax
c01037c5:	ff 75 e8             	pushl  -0x18(%ebp)
c01037c8:	e8 ec fa ff ff       	call   c01032b9 <find_vma>
c01037cd:	83 c4 10             	add    $0x10,%esp
c01037d0:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma1 != NULL);
c01037d3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01037d7:	75 19                	jne    c01037f2 <check_vma_struct+0x212>
c01037d9:	68 61 8d 10 c0       	push   $0xc0108d61
c01037de:	68 3b 8c 10 c0       	push   $0xc0108c3b
c01037e3:	68 cf 00 00 00       	push   $0xcf
c01037e8:	68 50 8c 10 c0       	push   $0xc0108c50
c01037ed:	e8 f6 cb ff ff       	call   c01003e8 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c01037f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037f5:	83 c0 01             	add    $0x1,%eax
c01037f8:	83 ec 08             	sub    $0x8,%esp
c01037fb:	50                   	push   %eax
c01037fc:	ff 75 e8             	pushl  -0x18(%ebp)
c01037ff:	e8 b5 fa ff ff       	call   c01032b9 <find_vma>
c0103804:	83 c4 10             	add    $0x10,%esp
c0103807:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma2 != NULL);
c010380a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010380e:	75 19                	jne    c0103829 <check_vma_struct+0x249>
c0103810:	68 6e 8d 10 c0       	push   $0xc0108d6e
c0103815:	68 3b 8c 10 c0       	push   $0xc0108c3b
c010381a:	68 d1 00 00 00       	push   $0xd1
c010381f:	68 50 8c 10 c0       	push   $0xc0108c50
c0103824:	e8 bf cb ff ff       	call   c01003e8 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0103829:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010382c:	83 c0 02             	add    $0x2,%eax
c010382f:	83 ec 08             	sub    $0x8,%esp
c0103832:	50                   	push   %eax
c0103833:	ff 75 e8             	pushl  -0x18(%ebp)
c0103836:	e8 7e fa ff ff       	call   c01032b9 <find_vma>
c010383b:	83 c4 10             	add    $0x10,%esp
c010383e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma3 == NULL);
c0103841:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0103845:	74 19                	je     c0103860 <check_vma_struct+0x280>
c0103847:	68 7b 8d 10 c0       	push   $0xc0108d7b
c010384c:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103851:	68 d3 00 00 00       	push   $0xd3
c0103856:	68 50 8c 10 c0       	push   $0xc0108c50
c010385b:	e8 88 cb ff ff       	call   c01003e8 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0103860:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103863:	83 c0 03             	add    $0x3,%eax
c0103866:	83 ec 08             	sub    $0x8,%esp
c0103869:	50                   	push   %eax
c010386a:	ff 75 e8             	pushl  -0x18(%ebp)
c010386d:	e8 47 fa ff ff       	call   c01032b9 <find_vma>
c0103872:	83 c4 10             	add    $0x10,%esp
c0103875:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma4 == NULL);
c0103878:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c010387c:	74 19                	je     c0103897 <check_vma_struct+0x2b7>
c010387e:	68 88 8d 10 c0       	push   $0xc0108d88
c0103883:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103888:	68 d5 00 00 00       	push   $0xd5
c010388d:	68 50 8c 10 c0       	push   $0xc0108c50
c0103892:	e8 51 cb ff ff       	call   c01003e8 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0103897:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010389a:	83 c0 04             	add    $0x4,%eax
c010389d:	83 ec 08             	sub    $0x8,%esp
c01038a0:	50                   	push   %eax
c01038a1:	ff 75 e8             	pushl  -0x18(%ebp)
c01038a4:	e8 10 fa ff ff       	call   c01032b9 <find_vma>
c01038a9:	83 c4 10             	add    $0x10,%esp
c01038ac:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma5 == NULL);
c01038af:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01038b3:	74 19                	je     c01038ce <check_vma_struct+0x2ee>
c01038b5:	68 95 8d 10 c0       	push   $0xc0108d95
c01038ba:	68 3b 8c 10 c0       	push   $0xc0108c3b
c01038bf:	68 d7 00 00 00       	push   $0xd7
c01038c4:	68 50 8c 10 c0       	push   $0xc0108c50
c01038c9:	e8 1a cb ff ff       	call   c01003e8 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01038ce:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01038d1:	8b 50 04             	mov    0x4(%eax),%edx
c01038d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038d7:	39 c2                	cmp    %eax,%edx
c01038d9:	75 10                	jne    c01038eb <check_vma_struct+0x30b>
c01038db:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01038de:	8b 40 08             	mov    0x8(%eax),%eax
c01038e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01038e4:	83 c2 02             	add    $0x2,%edx
c01038e7:	39 d0                	cmp    %edx,%eax
c01038e9:	74 19                	je     c0103904 <check_vma_struct+0x324>
c01038eb:	68 a4 8d 10 c0       	push   $0xc0108da4
c01038f0:	68 3b 8c 10 c0       	push   $0xc0108c3b
c01038f5:	68 d9 00 00 00       	push   $0xd9
c01038fa:	68 50 8c 10 c0       	push   $0xc0108c50
c01038ff:	e8 e4 ca ff ff       	call   c01003e8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0103904:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103907:	8b 50 04             	mov    0x4(%eax),%edx
c010390a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010390d:	39 c2                	cmp    %eax,%edx
c010390f:	75 10                	jne    c0103921 <check_vma_struct+0x341>
c0103911:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103914:	8b 40 08             	mov    0x8(%eax),%eax
c0103917:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010391a:	83 c2 02             	add    $0x2,%edx
c010391d:	39 d0                	cmp    %edx,%eax
c010391f:	74 19                	je     c010393a <check_vma_struct+0x35a>
c0103921:	68 d4 8d 10 c0       	push   $0xc0108dd4
c0103926:	68 3b 8c 10 c0       	push   $0xc0108c3b
c010392b:	68 da 00 00 00       	push   $0xda
c0103930:	68 50 8c 10 c0       	push   $0xc0108c50
c0103935:	e8 ae ca ff ff       	call   c01003e8 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c010393a:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c010393e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103941:	89 d0                	mov    %edx,%eax
c0103943:	c1 e0 02             	shl    $0x2,%eax
c0103946:	01 d0                	add    %edx,%eax
c0103948:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010394b:	0f 8d 6d fe ff ff    	jge    c01037be <check_vma_struct+0x1de>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0103951:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0103958:	eb 5c                	jmp    c01039b6 <check_vma_struct+0x3d6>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c010395a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010395d:	83 ec 08             	sub    $0x8,%esp
c0103960:	50                   	push   %eax
c0103961:	ff 75 e8             	pushl  -0x18(%ebp)
c0103964:	e8 50 f9 ff ff       	call   c01032b9 <find_vma>
c0103969:	83 c4 10             	add    $0x10,%esp
c010396c:	89 45 b8             	mov    %eax,-0x48(%ebp)
        if (vma_below_5 != NULL ) {
c010396f:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103973:	74 1e                	je     c0103993 <check_vma_struct+0x3b3>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0103975:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103978:	8b 50 08             	mov    0x8(%eax),%edx
c010397b:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010397e:	8b 40 04             	mov    0x4(%eax),%eax
c0103981:	52                   	push   %edx
c0103982:	50                   	push   %eax
c0103983:	ff 75 f4             	pushl  -0xc(%ebp)
c0103986:	68 04 8e 10 c0       	push   $0xc0108e04
c010398b:	e8 f2 c8 ff ff       	call   c0100282 <cprintf>
c0103990:	83 c4 10             	add    $0x10,%esp
        }
        assert(vma_below_5 == NULL);
c0103993:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103997:	74 19                	je     c01039b2 <check_vma_struct+0x3d2>
c0103999:	68 29 8e 10 c0       	push   $0xc0108e29
c010399e:	68 3b 8c 10 c0       	push   $0xc0108c3b
c01039a3:	68 e2 00 00 00       	push   $0xe2
c01039a8:	68 50 8c 10 c0       	push   $0xc0108c50
c01039ad:	e8 36 ca ff ff       	call   c01003e8 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c01039b2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01039b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01039ba:	79 9e                	jns    c010395a <check_vma_struct+0x37a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c01039bc:	83 ec 0c             	sub    $0xc,%esp
c01039bf:	ff 75 e8             	pushl  -0x18(%ebp)
c01039c2:	e8 42 fb ff ff       	call   c0103509 <mm_destroy>
c01039c7:	83 c4 10             	add    $0x10,%esp

    assert(nr_free_pages_store == nr_free_pages());
c01039ca:	e8 0e 27 00 00       	call   c01060dd <nr_free_pages>
c01039cf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01039d2:	74 19                	je     c01039ed <check_vma_struct+0x40d>
c01039d4:	68 bc 8c 10 c0       	push   $0xc0108cbc
c01039d9:	68 3b 8c 10 c0       	push   $0xc0108c3b
c01039de:	68 e7 00 00 00       	push   $0xe7
c01039e3:	68 50 8c 10 c0       	push   $0xc0108c50
c01039e8:	e8 fb c9 ff ff       	call   c01003e8 <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c01039ed:	83 ec 0c             	sub    $0xc,%esp
c01039f0:	68 40 8e 10 c0       	push   $0xc0108e40
c01039f5:	e8 88 c8 ff ff       	call   c0100282 <cprintf>
c01039fa:	83 c4 10             	add    $0x10,%esp
}
c01039fd:	90                   	nop
c01039fe:	c9                   	leave  
c01039ff:	c3                   	ret    

c0103a00 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0103a00:	55                   	push   %ebp
c0103a01:	89 e5                	mov    %esp,%ebp
c0103a03:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103a06:	e8 d2 26 00 00       	call   c01060dd <nr_free_pages>
c0103a0b:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0103a0e:	e8 ee f7 ff ff       	call   c0103201 <mm_create>
c0103a13:	a3 10 30 12 c0       	mov    %eax,0xc0123010
    assert(check_mm_struct != NULL);
c0103a18:	a1 10 30 12 c0       	mov    0xc0123010,%eax
c0103a1d:	85 c0                	test   %eax,%eax
c0103a1f:	75 19                	jne    c0103a3a <check_pgfault+0x3a>
c0103a21:	68 5f 8e 10 c0       	push   $0xc0108e5f
c0103a26:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103a2b:	68 f4 00 00 00       	push   $0xf4
c0103a30:	68 50 8c 10 c0       	push   $0xc0108c50
c0103a35:	e8 ae c9 ff ff       	call   c01003e8 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0103a3a:	a1 10 30 12 c0       	mov    0xc0123010,%eax
c0103a3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0103a42:	8b 15 00 fa 11 c0    	mov    0xc011fa00,%edx
c0103a48:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a4b:	89 50 0c             	mov    %edx,0xc(%eax)
c0103a4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a51:	8b 40 0c             	mov    0xc(%eax),%eax
c0103a54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0103a57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a5a:	8b 00                	mov    (%eax),%eax
c0103a5c:	85 c0                	test   %eax,%eax
c0103a5e:	74 19                	je     c0103a79 <check_pgfault+0x79>
c0103a60:	68 77 8e 10 c0       	push   $0xc0108e77
c0103a65:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103a6a:	68 f8 00 00 00       	push   $0xf8
c0103a6f:	68 50 8c 10 c0       	push   $0xc0108c50
c0103a74:	e8 6f c9 ff ff       	call   c01003e8 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0103a79:	83 ec 04             	sub    $0x4,%esp
c0103a7c:	6a 02                	push   $0x2
c0103a7e:	68 00 00 40 00       	push   $0x400000
c0103a83:	6a 00                	push   $0x0
c0103a85:	e8 f3 f7 ff ff       	call   c010327d <vma_create>
c0103a8a:	83 c4 10             	add    $0x10,%esp
c0103a8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0103a90:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103a94:	75 19                	jne    c0103aaf <check_pgfault+0xaf>
c0103a96:	68 06 8d 10 c0       	push   $0xc0108d06
c0103a9b:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103aa0:	68 fb 00 00 00       	push   $0xfb
c0103aa5:	68 50 8c 10 c0       	push   $0xc0108c50
c0103aaa:	e8 39 c9 ff ff       	call   c01003e8 <__panic>

    insert_vma_struct(mm, vma);
c0103aaf:	83 ec 08             	sub    $0x8,%esp
c0103ab2:	ff 75 e0             	pushl  -0x20(%ebp)
c0103ab5:	ff 75 e8             	pushl  -0x18(%ebp)
c0103ab8:	e8 28 f9 ff ff       	call   c01033e5 <insert_vma_struct>
c0103abd:	83 c4 10             	add    $0x10,%esp

    uintptr_t addr = 0x100;
c0103ac0:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0103ac7:	83 ec 08             	sub    $0x8,%esp
c0103aca:	ff 75 dc             	pushl  -0x24(%ebp)
c0103acd:	ff 75 e8             	pushl  -0x18(%ebp)
c0103ad0:	e8 e4 f7 ff ff       	call   c01032b9 <find_vma>
c0103ad5:	83 c4 10             	add    $0x10,%esp
c0103ad8:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103adb:	74 19                	je     c0103af6 <check_pgfault+0xf6>
c0103add:	68 85 8e 10 c0       	push   $0xc0108e85
c0103ae2:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103ae7:	68 00 01 00 00       	push   $0x100
c0103aec:	68 50 8c 10 c0       	push   $0xc0108c50
c0103af1:	e8 f2 c8 ff ff       	call   c01003e8 <__panic>

    int i, sum = 0;
c0103af6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103afd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103b04:	eb 19                	jmp    c0103b1f <check_pgfault+0x11f>
        *(char *)(addr + i) = i;
c0103b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b09:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b0c:	01 d0                	add    %edx,%eax
c0103b0e:	89 c2                	mov    %eax,%edx
c0103b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b13:	88 02                	mov    %al,(%edx)
        sum += i;
c0103b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b18:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0103b1b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103b1f:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103b23:	7e e1                	jle    c0103b06 <check_pgfault+0x106>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0103b25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103b2c:	eb 15                	jmp    c0103b43 <check_pgfault+0x143>
        sum -= *(char *)(addr + i);
c0103b2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b31:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b34:	01 d0                	add    %edx,%eax
c0103b36:	0f b6 00             	movzbl (%eax),%eax
c0103b39:	0f be c0             	movsbl %al,%eax
c0103b3c:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0103b3f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103b43:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103b47:	7e e5                	jle    c0103b2e <check_pgfault+0x12e>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0103b49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103b4d:	74 19                	je     c0103b68 <check_pgfault+0x168>
c0103b4f:	68 9f 8e 10 c0       	push   $0xc0108e9f
c0103b54:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103b59:	68 0a 01 00 00       	push   $0x10a
c0103b5e:	68 50 8c 10 c0       	push   $0xc0108c50
c0103b63:	e8 80 c8 ff ff       	call   c01003e8 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0103b68:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103b6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103b71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b76:	83 ec 08             	sub    $0x8,%esp
c0103b79:	50                   	push   %eax
c0103b7a:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103b7d:	e8 f9 2c 00 00       	call   c010687b <page_remove>
c0103b82:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(pgdir[0]));
c0103b85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b88:	8b 00                	mov    (%eax),%eax
c0103b8a:	83 ec 0c             	sub    $0xc,%esp
c0103b8d:	50                   	push   %eax
c0103b8e:	e8 52 f6 ff ff       	call   c01031e5 <pde2page>
c0103b93:	83 c4 10             	add    $0x10,%esp
c0103b96:	83 ec 08             	sub    $0x8,%esp
c0103b99:	6a 01                	push   $0x1
c0103b9b:	50                   	push   %eax
c0103b9c:	e8 07 25 00 00       	call   c01060a8 <free_pages>
c0103ba1:	83 c4 10             	add    $0x10,%esp
    pgdir[0] = 0;
c0103ba4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ba7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0103bad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103bb0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0103bb7:	83 ec 0c             	sub    $0xc,%esp
c0103bba:	ff 75 e8             	pushl  -0x18(%ebp)
c0103bbd:	e8 47 f9 ff ff       	call   c0103509 <mm_destroy>
c0103bc2:	83 c4 10             	add    $0x10,%esp
    check_mm_struct = NULL;
c0103bc5:	c7 05 10 30 12 c0 00 	movl   $0x0,0xc0123010
c0103bcc:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0103bcf:	e8 09 25 00 00       	call   c01060dd <nr_free_pages>
c0103bd4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103bd7:	74 19                	je     c0103bf2 <check_pgfault+0x1f2>
c0103bd9:	68 bc 8c 10 c0       	push   $0xc0108cbc
c0103bde:	68 3b 8c 10 c0       	push   $0xc0108c3b
c0103be3:	68 14 01 00 00       	push   $0x114
c0103be8:	68 50 8c 10 c0       	push   $0xc0108c50
c0103bed:	e8 f6 c7 ff ff       	call   c01003e8 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0103bf2:	83 ec 0c             	sub    $0xc,%esp
c0103bf5:	68 a8 8e 10 c0       	push   $0xc0108ea8
c0103bfa:	e8 83 c6 ff ff       	call   c0100282 <cprintf>
c0103bff:	83 c4 10             	add    $0x10,%esp
}
c0103c02:	90                   	nop
c0103c03:	c9                   	leave  
c0103c04:	c3                   	ret    

c0103c05 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0103c05:	55                   	push   %ebp
c0103c06:	89 e5                	mov    %esp,%ebp
c0103c08:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_INVAL;
c0103c0b:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0103c12:	ff 75 10             	pushl  0x10(%ebp)
c0103c15:	ff 75 08             	pushl  0x8(%ebp)
c0103c18:	e8 9c f6 ff ff       	call   c01032b9 <find_vma>
c0103c1d:	83 c4 08             	add    $0x8,%esp
c0103c20:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0103c23:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0103c28:	83 c0 01             	add    $0x1,%eax
c0103c2b:	a3 64 2f 12 c0       	mov    %eax,0xc0122f64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0103c30:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103c34:	74 0b                	je     c0103c41 <do_pgfault+0x3c>
c0103c36:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c39:	8b 40 04             	mov    0x4(%eax),%eax
c0103c3c:	3b 45 10             	cmp    0x10(%ebp),%eax
c0103c3f:	76 18                	jbe    c0103c59 <do_pgfault+0x54>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0103c41:	83 ec 08             	sub    $0x8,%esp
c0103c44:	ff 75 10             	pushl  0x10(%ebp)
c0103c47:	68 c4 8e 10 c0       	push   $0xc0108ec4
c0103c4c:	e8 31 c6 ff ff       	call   c0100282 <cprintf>
c0103c51:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0103c54:	e9 aa 01 00 00       	jmp    c0103e03 <do_pgfault+0x1fe>
    }
    //check the error_code
    switch (error_code & 3) {
c0103c59:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103c5c:	83 e0 03             	and    $0x3,%eax
c0103c5f:	85 c0                	test   %eax,%eax
c0103c61:	74 3c                	je     c0103c9f <do_pgfault+0x9a>
c0103c63:	83 f8 01             	cmp    $0x1,%eax
c0103c66:	74 22                	je     c0103c8a <do_pgfault+0x85>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0103c68:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c6b:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c6e:	83 e0 02             	and    $0x2,%eax
c0103c71:	85 c0                	test   %eax,%eax
c0103c73:	75 4c                	jne    c0103cc1 <do_pgfault+0xbc>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0103c75:	83 ec 0c             	sub    $0xc,%esp
c0103c78:	68 f4 8e 10 c0       	push   $0xc0108ef4
c0103c7d:	e8 00 c6 ff ff       	call   c0100282 <cprintf>
c0103c82:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103c85:	e9 79 01 00 00       	jmp    c0103e03 <do_pgfault+0x1fe>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0103c8a:	83 ec 0c             	sub    $0xc,%esp
c0103c8d:	68 54 8f 10 c0       	push   $0xc0108f54
c0103c92:	e8 eb c5 ff ff       	call   c0100282 <cprintf>
c0103c97:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0103c9a:	e9 64 01 00 00       	jmp    c0103e03 <do_pgfault+0x1fe>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0103c9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ca2:	8b 40 0c             	mov    0xc(%eax),%eax
c0103ca5:	83 e0 05             	and    $0x5,%eax
c0103ca8:	85 c0                	test   %eax,%eax
c0103caa:	75 16                	jne    c0103cc2 <do_pgfault+0xbd>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0103cac:	83 ec 0c             	sub    $0xc,%esp
c0103caf:	68 8c 8f 10 c0       	push   $0xc0108f8c
c0103cb4:	e8 c9 c5 ff ff       	call   c0100282 <cprintf>
c0103cb9:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103cbc:	e9 42 01 00 00       	jmp    c0103e03 <do_pgfault+0x1fe>
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
c0103cc1:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0103cc2:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0103cc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ccc:	8b 40 0c             	mov    0xc(%eax),%eax
c0103ccf:	83 e0 02             	and    $0x2,%eax
c0103cd2:	85 c0                	test   %eax,%eax
c0103cd4:	74 04                	je     c0103cda <do_pgfault+0xd5>
        perm |= PTE_W;
c0103cd6:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0103cda:	8b 45 10             	mov    0x10(%ebp),%eax
c0103cdd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103ce0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ce3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ce8:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0103ceb:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0103cf2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0103cf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cfc:	8b 40 0c             	mov    0xc(%eax),%eax
c0103cff:	83 ec 04             	sub    $0x4,%esp
c0103d02:	6a 01                	push   $0x1
c0103d04:	ff 75 10             	pushl  0x10(%ebp)
c0103d07:	50                   	push   %eax
c0103d08:	e8 96 29 00 00       	call   c01066a3 <get_pte>
c0103d0d:	83 c4 10             	add    $0x10,%esp
c0103d10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103d13:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103d17:	75 15                	jne    c0103d2e <do_pgfault+0x129>
        cprintf("get_pte in do_pgfault failed\n");
c0103d19:	83 ec 0c             	sub    $0xc,%esp
c0103d1c:	68 ef 8f 10 c0       	push   $0xc0108fef
c0103d21:	e8 5c c5 ff ff       	call   c0100282 <cprintf>
c0103d26:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0103d29:	e9 d5 00 00 00       	jmp    c0103e03 <do_pgfault+0x1fe>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c0103d2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d31:	8b 00                	mov    (%eax),%eax
c0103d33:	85 c0                	test   %eax,%eax
c0103d35:	75 35                	jne    c0103d6c <do_pgfault+0x167>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0103d37:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d3a:	8b 40 0c             	mov    0xc(%eax),%eax
c0103d3d:	83 ec 04             	sub    $0x4,%esp
c0103d40:	ff 75 f0             	pushl  -0x10(%ebp)
c0103d43:	ff 75 10             	pushl  0x10(%ebp)
c0103d46:	50                   	push   %eax
c0103d47:	e8 71 2c 00 00       	call   c01069bd <pgdir_alloc_page>
c0103d4c:	83 c4 10             	add    $0x10,%esp
c0103d4f:	85 c0                	test   %eax,%eax
c0103d51:	0f 85 a5 00 00 00    	jne    c0103dfc <do_pgfault+0x1f7>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0103d57:	83 ec 0c             	sub    $0xc,%esp
c0103d5a:	68 10 90 10 c0       	push   $0xc0109010
c0103d5f:	e8 1e c5 ff ff       	call   c0100282 <cprintf>
c0103d64:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103d67:	e9 97 00 00 00       	jmp    c0103e03 <do_pgfault+0x1fe>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c0103d6c:	a1 68 2f 12 c0       	mov    0xc0122f68,%eax
c0103d71:	85 c0                	test   %eax,%eax
c0103d73:	74 6f                	je     c0103de4 <do_pgfault+0x1df>
            struct Page *page=NULL;
c0103d75:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0103d7c:	83 ec 04             	sub    $0x4,%esp
c0103d7f:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0103d82:	50                   	push   %eax
c0103d83:	ff 75 10             	pushl  0x10(%ebp)
c0103d86:	ff 75 08             	pushl  0x8(%ebp)
c0103d89:	e8 b4 07 00 00       	call   c0104542 <swap_in>
c0103d8e:	83 c4 10             	add    $0x10,%esp
c0103d91:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d98:	74 12                	je     c0103dac <do_pgfault+0x1a7>
                cprintf("swap_in in do_pgfault failed\n");
c0103d9a:	83 ec 0c             	sub    $0xc,%esp
c0103d9d:	68 37 90 10 c0       	push   $0xc0109037
c0103da2:	e8 db c4 ff ff       	call   c0100282 <cprintf>
c0103da7:	83 c4 10             	add    $0x10,%esp
c0103daa:	eb 57                	jmp    c0103e03 <do_pgfault+0x1fe>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0103dac:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103daf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103db2:	8b 40 0c             	mov    0xc(%eax),%eax
c0103db5:	ff 75 f0             	pushl  -0x10(%ebp)
c0103db8:	ff 75 10             	pushl  0x10(%ebp)
c0103dbb:	52                   	push   %edx
c0103dbc:	50                   	push   %eax
c0103dbd:	e8 f2 2a 00 00       	call   c01068b4 <page_insert>
c0103dc2:	83 c4 10             	add    $0x10,%esp
            swap_map_swappable(mm, addr, page, 1);
c0103dc5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103dc8:	6a 01                	push   $0x1
c0103dca:	50                   	push   %eax
c0103dcb:	ff 75 10             	pushl  0x10(%ebp)
c0103dce:	ff 75 08             	pushl  0x8(%ebp)
c0103dd1:	e8 dc 05 00 00       	call   c01043b2 <swap_map_swappable>
c0103dd6:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr = addr;
c0103dd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ddc:	8b 55 10             	mov    0x10(%ebp),%edx
c0103ddf:	89 50 1c             	mov    %edx,0x1c(%eax)
c0103de2:	eb 18                	jmp    c0103dfc <do_pgfault+0x1f7>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0103de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103de7:	8b 00                	mov    (%eax),%eax
c0103de9:	83 ec 08             	sub    $0x8,%esp
c0103dec:	50                   	push   %eax
c0103ded:	68 58 90 10 c0       	push   $0xc0109058
c0103df2:	e8 8b c4 ff ff       	call   c0100282 <cprintf>
c0103df7:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103dfa:	eb 07                	jmp    c0103e03 <do_pgfault+0x1fe>
        }
   }
   ret = 0;
c0103dfc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0103e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103e06:	c9                   	leave  
c0103e07:	c3                   	ret    

c0103e08 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0103e08:	55                   	push   %ebp
c0103e09:	89 e5                	mov    %esp,%ebp
c0103e0b:	83 ec 10             	sub    $0x10,%esp
c0103e0e:	c7 45 fc 14 30 12 c0 	movl   $0xc0123014,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103e15:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103e18:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103e1b:	89 50 04             	mov    %edx,0x4(%eax)
c0103e1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103e21:	8b 50 04             	mov    0x4(%eax),%edx
c0103e24:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103e27:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0103e29:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e2c:	c7 40 14 14 30 12 c0 	movl   $0xc0123014,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0103e33:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103e38:	c9                   	leave  
c0103e39:	c3                   	ret    

c0103e3a <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0103e3a:	55                   	push   %ebp
c0103e3b:	89 e5                	mov    %esp,%ebp
c0103e3d:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0103e40:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e43:	8b 40 14             	mov    0x14(%eax),%eax
c0103e46:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0103e49:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e4c:	83 c0 14             	add    $0x14,%eax
c0103e4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0103e52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103e56:	74 06                	je     c0103e5e <_fifo_map_swappable+0x24>
c0103e58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e5c:	75 16                	jne    c0103e74 <_fifo_map_swappable+0x3a>
c0103e5e:	68 80 90 10 c0       	push   $0xc0109080
c0103e63:	68 9e 90 10 c0       	push   $0xc010909e
c0103e68:	6a 32                	push   $0x32
c0103e6a:	68 b3 90 10 c0       	push   $0xc01090b3
c0103e6f:	e8 74 c5 ff ff       	call   c01003e8 <__panic>
c0103e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e77:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e7d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103e80:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e86:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e89:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103e8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e8f:	8b 40 04             	mov    0x4(%eax),%eax
c0103e92:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103e95:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0103e98:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103e9b:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0103e9e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103ea1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103ea4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ea7:	89 10                	mov    %edx,(%eax)
c0103ea9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103eac:	8b 10                	mov    (%eax),%edx
c0103eae:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103eb1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103eb4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103eb7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103eba:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103ebd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ec0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103ec3:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0103ec5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103eca:	c9                   	leave  
c0103ecb:	c3                   	ret    

c0103ecc <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0103ecc:	55                   	push   %ebp
c0103ecd:	89 e5                	mov    %esp,%ebp
c0103ecf:	83 ec 28             	sub    $0x28,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0103ed2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ed5:	8b 40 14             	mov    0x14(%eax),%eax
c0103ed8:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0103edb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103edf:	75 16                	jne    c0103ef7 <_fifo_swap_out_victim+0x2b>
c0103ee1:	68 c7 90 10 c0       	push   $0xc01090c7
c0103ee6:	68 9e 90 10 c0       	push   $0xc010909e
c0103eeb:	6a 41                	push   $0x41
c0103eed:	68 b3 90 10 c0       	push   $0xc01090b3
c0103ef2:	e8 f1 c4 ff ff       	call   c01003e8 <__panic>
     assert(in_tick==0);
c0103ef7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103efb:	74 16                	je     c0103f13 <_fifo_swap_out_victim+0x47>
c0103efd:	68 d4 90 10 c0       	push   $0xc01090d4
c0103f02:	68 9e 90 10 c0       	push   $0xc010909e
c0103f07:	6a 42                	push   $0x42
c0103f09:	68 b3 90 10 c0       	push   $0xc01090b3
c0103f0e:	e8 d5 c4 ff ff       	call   c01003e8 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     /* Select the tail */
     list_entry_t *le = head->prev;
c0103f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f16:	8b 00                	mov    (%eax),%eax
c0103f18:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0103f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f1e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103f21:	75 16                	jne    c0103f39 <_fifo_swap_out_victim+0x6d>
c0103f23:	68 df 90 10 c0       	push   $0xc01090df
c0103f28:	68 9e 90 10 c0       	push   $0xc010909e
c0103f2d:	6a 49                	push   $0x49
c0103f2f:	68 b3 90 10 c0       	push   $0xc01090b3
c0103f34:	e8 af c4 ff ff       	call   c01003e8 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0103f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f3c:	83 e8 14             	sub    $0x14,%eax
c0103f3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f45:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103f48:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f4b:	8b 40 04             	mov    0x4(%eax),%eax
c0103f4e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0103f51:	8b 12                	mov    (%edx),%edx
c0103f53:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0103f56:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103f59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f5c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f5f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103f62:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f65:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103f68:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0103f6a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103f6e:	75 16                	jne    c0103f86 <_fifo_swap_out_victim+0xba>
c0103f70:	68 e8 90 10 c0       	push   $0xc01090e8
c0103f75:	68 9e 90 10 c0       	push   $0xc010909e
c0103f7a:	6a 4c                	push   $0x4c
c0103f7c:	68 b3 90 10 c0       	push   $0xc01090b3
c0103f81:	e8 62 c4 ff ff       	call   c01003e8 <__panic>
     *ptr_page = p;
c0103f86:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103f89:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103f8c:	89 10                	mov    %edx,(%eax)
     return 0;
c0103f8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103f93:	c9                   	leave  
c0103f94:	c3                   	ret    

c0103f95 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0103f95:	55                   	push   %ebp
c0103f96:	89 e5                	mov    %esp,%ebp
c0103f98:	83 ec 08             	sub    $0x8,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0103f9b:	83 ec 0c             	sub    $0xc,%esp
c0103f9e:	68 f4 90 10 c0       	push   $0xc01090f4
c0103fa3:	e8 da c2 ff ff       	call   c0100282 <cprintf>
c0103fa8:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c0103fab:	b8 00 30 00 00       	mov    $0x3000,%eax
c0103fb0:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0103fb3:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0103fb8:	83 f8 04             	cmp    $0x4,%eax
c0103fbb:	74 16                	je     c0103fd3 <_fifo_check_swap+0x3e>
c0103fbd:	68 1a 91 10 c0       	push   $0xc010911a
c0103fc2:	68 9e 90 10 c0       	push   $0xc010909e
c0103fc7:	6a 55                	push   $0x55
c0103fc9:	68 b3 90 10 c0       	push   $0xc01090b3
c0103fce:	e8 15 c4 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0103fd3:	83 ec 0c             	sub    $0xc,%esp
c0103fd6:	68 2c 91 10 c0       	push   $0xc010912c
c0103fdb:	e8 a2 c2 ff ff       	call   c0100282 <cprintf>
c0103fe0:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c0103fe3:	b8 00 10 00 00       	mov    $0x1000,%eax
c0103fe8:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0103feb:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0103ff0:	83 f8 04             	cmp    $0x4,%eax
c0103ff3:	74 16                	je     c010400b <_fifo_check_swap+0x76>
c0103ff5:	68 1a 91 10 c0       	push   $0xc010911a
c0103ffa:	68 9e 90 10 c0       	push   $0xc010909e
c0103fff:	6a 58                	push   $0x58
c0104001:	68 b3 90 10 c0       	push   $0xc01090b3
c0104006:	e8 dd c3 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c010400b:	83 ec 0c             	sub    $0xc,%esp
c010400e:	68 54 91 10 c0       	push   $0xc0109154
c0104013:	e8 6a c2 ff ff       	call   c0100282 <cprintf>
c0104018:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c010401b:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104020:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0104023:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104028:	83 f8 04             	cmp    $0x4,%eax
c010402b:	74 16                	je     c0104043 <_fifo_check_swap+0xae>
c010402d:	68 1a 91 10 c0       	push   $0xc010911a
c0104032:	68 9e 90 10 c0       	push   $0xc010909e
c0104037:	6a 5b                	push   $0x5b
c0104039:	68 b3 90 10 c0       	push   $0xc01090b3
c010403e:	e8 a5 c3 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104043:	83 ec 0c             	sub    $0xc,%esp
c0104046:	68 7c 91 10 c0       	push   $0xc010917c
c010404b:	e8 32 c2 ff ff       	call   c0100282 <cprintf>
c0104050:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0104053:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104058:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c010405b:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104060:	83 f8 04             	cmp    $0x4,%eax
c0104063:	74 16                	je     c010407b <_fifo_check_swap+0xe6>
c0104065:	68 1a 91 10 c0       	push   $0xc010911a
c010406a:	68 9e 90 10 c0       	push   $0xc010909e
c010406f:	6a 5e                	push   $0x5e
c0104071:	68 b3 90 10 c0       	push   $0xc01090b3
c0104076:	e8 6d c3 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c010407b:	83 ec 0c             	sub    $0xc,%esp
c010407e:	68 a4 91 10 c0       	push   $0xc01091a4
c0104083:	e8 fa c1 ff ff       	call   c0100282 <cprintf>
c0104088:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c010408b:	b8 00 50 00 00       	mov    $0x5000,%eax
c0104090:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0104093:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104098:	83 f8 05             	cmp    $0x5,%eax
c010409b:	74 16                	je     c01040b3 <_fifo_check_swap+0x11e>
c010409d:	68 ca 91 10 c0       	push   $0xc01091ca
c01040a2:	68 9e 90 10 c0       	push   $0xc010909e
c01040a7:	6a 61                	push   $0x61
c01040a9:	68 b3 90 10 c0       	push   $0xc01090b3
c01040ae:	e8 35 c3 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01040b3:	83 ec 0c             	sub    $0xc,%esp
c01040b6:	68 7c 91 10 c0       	push   $0xc010917c
c01040bb:	e8 c2 c1 ff ff       	call   c0100282 <cprintf>
c01040c0:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c01040c3:	b8 00 20 00 00       	mov    $0x2000,%eax
c01040c8:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c01040cb:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c01040d0:	83 f8 05             	cmp    $0x5,%eax
c01040d3:	74 16                	je     c01040eb <_fifo_check_swap+0x156>
c01040d5:	68 ca 91 10 c0       	push   $0xc01091ca
c01040da:	68 9e 90 10 c0       	push   $0xc010909e
c01040df:	6a 64                	push   $0x64
c01040e1:	68 b3 90 10 c0       	push   $0xc01090b3
c01040e6:	e8 fd c2 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01040eb:	83 ec 0c             	sub    $0xc,%esp
c01040ee:	68 2c 91 10 c0       	push   $0xc010912c
c01040f3:	e8 8a c1 ff ff       	call   c0100282 <cprintf>
c01040f8:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c01040fb:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104100:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0104103:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104108:	83 f8 06             	cmp    $0x6,%eax
c010410b:	74 16                	je     c0104123 <_fifo_check_swap+0x18e>
c010410d:	68 d9 91 10 c0       	push   $0xc01091d9
c0104112:	68 9e 90 10 c0       	push   $0xc010909e
c0104117:	6a 67                	push   $0x67
c0104119:	68 b3 90 10 c0       	push   $0xc01090b3
c010411e:	e8 c5 c2 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104123:	83 ec 0c             	sub    $0xc,%esp
c0104126:	68 7c 91 10 c0       	push   $0xc010917c
c010412b:	e8 52 c1 ff ff       	call   c0100282 <cprintf>
c0104130:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0104133:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104138:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c010413b:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104140:	83 f8 07             	cmp    $0x7,%eax
c0104143:	74 16                	je     c010415b <_fifo_check_swap+0x1c6>
c0104145:	68 e8 91 10 c0       	push   $0xc01091e8
c010414a:	68 9e 90 10 c0       	push   $0xc010909e
c010414f:	6a 6a                	push   $0x6a
c0104151:	68 b3 90 10 c0       	push   $0xc01090b3
c0104156:	e8 8d c2 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c010415b:	83 ec 0c             	sub    $0xc,%esp
c010415e:	68 f4 90 10 c0       	push   $0xc01090f4
c0104163:	e8 1a c1 ff ff       	call   c0100282 <cprintf>
c0104168:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c010416b:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104170:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0104173:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104178:	83 f8 08             	cmp    $0x8,%eax
c010417b:	74 16                	je     c0104193 <_fifo_check_swap+0x1fe>
c010417d:	68 f7 91 10 c0       	push   $0xc01091f7
c0104182:	68 9e 90 10 c0       	push   $0xc010909e
c0104187:	6a 6d                	push   $0x6d
c0104189:	68 b3 90 10 c0       	push   $0xc01090b3
c010418e:	e8 55 c2 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0104193:	83 ec 0c             	sub    $0xc,%esp
c0104196:	68 54 91 10 c0       	push   $0xc0109154
c010419b:	e8 e2 c0 ff ff       	call   c0100282 <cprintf>
c01041a0:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c01041a3:	b8 00 40 00 00       	mov    $0x4000,%eax
c01041a8:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c01041ab:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c01041b0:	83 f8 09             	cmp    $0x9,%eax
c01041b3:	74 16                	je     c01041cb <_fifo_check_swap+0x236>
c01041b5:	68 06 92 10 c0       	push   $0xc0109206
c01041ba:	68 9e 90 10 c0       	push   $0xc010909e
c01041bf:	6a 70                	push   $0x70
c01041c1:	68 b3 90 10 c0       	push   $0xc01090b3
c01041c6:	e8 1d c2 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01041cb:	83 ec 0c             	sub    $0xc,%esp
c01041ce:	68 a4 91 10 c0       	push   $0xc01091a4
c01041d3:	e8 aa c0 ff ff       	call   c0100282 <cprintf>
c01041d8:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c01041db:	b8 00 50 00 00       	mov    $0x5000,%eax
c01041e0:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c01041e3:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c01041e8:	83 f8 0a             	cmp    $0xa,%eax
c01041eb:	74 16                	je     c0104203 <_fifo_check_swap+0x26e>
c01041ed:	68 15 92 10 c0       	push   $0xc0109215
c01041f2:	68 9e 90 10 c0       	push   $0xc010909e
c01041f7:	6a 73                	push   $0x73
c01041f9:	68 b3 90 10 c0       	push   $0xc01090b3
c01041fe:	e8 e5 c1 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104203:	83 ec 0c             	sub    $0xc,%esp
c0104206:	68 2c 91 10 c0       	push   $0xc010912c
c010420b:	e8 72 c0 ff ff       	call   c0100282 <cprintf>
c0104210:	83 c4 10             	add    $0x10,%esp
    assert(*(unsigned char *)0x1000 == 0x0a);
c0104213:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104218:	0f b6 00             	movzbl (%eax),%eax
c010421b:	3c 0a                	cmp    $0xa,%al
c010421d:	74 16                	je     c0104235 <_fifo_check_swap+0x2a0>
c010421f:	68 28 92 10 c0       	push   $0xc0109228
c0104224:	68 9e 90 10 c0       	push   $0xc010909e
c0104229:	6a 75                	push   $0x75
c010422b:	68 b3 90 10 c0       	push   $0xc01090b3
c0104230:	e8 b3 c1 ff ff       	call   c01003e8 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0104235:	b8 00 10 00 00       	mov    $0x1000,%eax
c010423a:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c010423d:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104242:	83 f8 0b             	cmp    $0xb,%eax
c0104245:	74 16                	je     c010425d <_fifo_check_swap+0x2c8>
c0104247:	68 49 92 10 c0       	push   $0xc0109249
c010424c:	68 9e 90 10 c0       	push   $0xc010909e
c0104251:	6a 77                	push   $0x77
c0104253:	68 b3 90 10 c0       	push   $0xc01090b3
c0104258:	e8 8b c1 ff ff       	call   c01003e8 <__panic>
    return 0;
c010425d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104262:	c9                   	leave  
c0104263:	c3                   	ret    

c0104264 <_fifo_init>:


static int
_fifo_init(void)
{
c0104264:	55                   	push   %ebp
c0104265:	89 e5                	mov    %esp,%ebp
    return 0;
c0104267:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010426c:	5d                   	pop    %ebp
c010426d:	c3                   	ret    

c010426e <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010426e:	55                   	push   %ebp
c010426f:	89 e5                	mov    %esp,%ebp
    return 0;
c0104271:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104276:	5d                   	pop    %ebp
c0104277:	c3                   	ret    

c0104278 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0104278:	55                   	push   %ebp
c0104279:	89 e5                	mov    %esp,%ebp
c010427b:	b8 00 00 00 00       	mov    $0x0,%eax
c0104280:	5d                   	pop    %ebp
c0104281:	c3                   	ret    

c0104282 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0104282:	55                   	push   %ebp
c0104283:	89 e5                	mov    %esp,%ebp
c0104285:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0104288:	8b 45 08             	mov    0x8(%ebp),%eax
c010428b:	c1 e8 0c             	shr    $0xc,%eax
c010428e:	89 c2                	mov    %eax,%edx
c0104290:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c0104295:	39 c2                	cmp    %eax,%edx
c0104297:	72 14                	jb     c01042ad <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0104299:	83 ec 04             	sub    $0x4,%esp
c010429c:	68 6c 92 10 c0       	push   $0xc010926c
c01042a1:	6a 5b                	push   $0x5b
c01042a3:	68 8b 92 10 c0       	push   $0xc010928b
c01042a8:	e8 3b c1 ff ff       	call   c01003e8 <__panic>
    }
    return &pages[PPN(pa)];
c01042ad:	a1 f8 30 12 c0       	mov    0xc01230f8,%eax
c01042b2:	8b 55 08             	mov    0x8(%ebp),%edx
c01042b5:	c1 ea 0c             	shr    $0xc,%edx
c01042b8:	c1 e2 05             	shl    $0x5,%edx
c01042bb:	01 d0                	add    %edx,%eax
}
c01042bd:	c9                   	leave  
c01042be:	c3                   	ret    

c01042bf <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01042bf:	55                   	push   %ebp
c01042c0:	89 e5                	mov    %esp,%ebp
c01042c2:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c01042c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01042c8:	83 e0 01             	and    $0x1,%eax
c01042cb:	85 c0                	test   %eax,%eax
c01042cd:	75 14                	jne    c01042e3 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c01042cf:	83 ec 04             	sub    $0x4,%esp
c01042d2:	68 9c 92 10 c0       	push   $0xc010929c
c01042d7:	6a 6d                	push   $0x6d
c01042d9:	68 8b 92 10 c0       	push   $0xc010928b
c01042de:	e8 05 c1 ff ff       	call   c01003e8 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01042e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01042e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01042eb:	83 ec 0c             	sub    $0xc,%esp
c01042ee:	50                   	push   %eax
c01042ef:	e8 8e ff ff ff       	call   c0104282 <pa2page>
c01042f4:	83 c4 10             	add    $0x10,%esp
}
c01042f7:	c9                   	leave  
c01042f8:	c3                   	ret    

c01042f9 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01042f9:	55                   	push   %ebp
c01042fa:	89 e5                	mov    %esp,%ebp
c01042fc:	83 ec 18             	sub    $0x18,%esp
     swapfs_init();
c01042ff:	e8 bd 33 00 00       	call   c01076c1 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0104304:	a1 bc 30 12 c0       	mov    0xc01230bc,%eax
c0104309:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c010430e:	76 0c                	jbe    c010431c <swap_init+0x23>
c0104310:	a1 bc 30 12 c0       	mov    0xc01230bc,%eax
c0104315:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c010431a:	76 17                	jbe    c0104333 <swap_init+0x3a>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c010431c:	a1 bc 30 12 c0       	mov    0xc01230bc,%eax
c0104321:	50                   	push   %eax
c0104322:	68 bd 92 10 c0       	push   $0xc01092bd
c0104327:	6a 25                	push   $0x25
c0104329:	68 d8 92 10 c0       	push   $0xc01092d8
c010432e:	e8 b5 c0 ff ff       	call   c01003e8 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0104333:	c7 05 70 2f 12 c0 e0 	movl   $0xc011f9e0,0xc0122f70
c010433a:	f9 11 c0 
     int r = sm->init();
c010433d:	a1 70 2f 12 c0       	mov    0xc0122f70,%eax
c0104342:	8b 40 04             	mov    0x4(%eax),%eax
c0104345:	ff d0                	call   *%eax
c0104347:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c010434a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010434e:	75 27                	jne    c0104377 <swap_init+0x7e>
     {
          swap_init_ok = 1;
c0104350:	c7 05 68 2f 12 c0 01 	movl   $0x1,0xc0122f68
c0104357:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c010435a:	a1 70 2f 12 c0       	mov    0xc0122f70,%eax
c010435f:	8b 00                	mov    (%eax),%eax
c0104361:	83 ec 08             	sub    $0x8,%esp
c0104364:	50                   	push   %eax
c0104365:	68 e7 92 10 c0       	push   $0xc01092e7
c010436a:	e8 13 bf ff ff       	call   c0100282 <cprintf>
c010436f:	83 c4 10             	add    $0x10,%esp
          check_swap();
c0104372:	e8 f7 03 00 00       	call   c010476e <check_swap>
     }

     return r;
c0104377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010437a:	c9                   	leave  
c010437b:	c3                   	ret    

c010437c <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c010437c:	55                   	push   %ebp
c010437d:	89 e5                	mov    %esp,%ebp
c010437f:	83 ec 08             	sub    $0x8,%esp
     return sm->init_mm(mm);
c0104382:	a1 70 2f 12 c0       	mov    0xc0122f70,%eax
c0104387:	8b 40 08             	mov    0x8(%eax),%eax
c010438a:	83 ec 0c             	sub    $0xc,%esp
c010438d:	ff 75 08             	pushl  0x8(%ebp)
c0104390:	ff d0                	call   *%eax
c0104392:	83 c4 10             	add    $0x10,%esp
}
c0104395:	c9                   	leave  
c0104396:	c3                   	ret    

c0104397 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0104397:	55                   	push   %ebp
c0104398:	89 e5                	mov    %esp,%ebp
c010439a:	83 ec 08             	sub    $0x8,%esp
     return sm->tick_event(mm);
c010439d:	a1 70 2f 12 c0       	mov    0xc0122f70,%eax
c01043a2:	8b 40 0c             	mov    0xc(%eax),%eax
c01043a5:	83 ec 0c             	sub    $0xc,%esp
c01043a8:	ff 75 08             	pushl  0x8(%ebp)
c01043ab:	ff d0                	call   *%eax
c01043ad:	83 c4 10             	add    $0x10,%esp
}
c01043b0:	c9                   	leave  
c01043b1:	c3                   	ret    

c01043b2 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01043b2:	55                   	push   %ebp
c01043b3:	89 e5                	mov    %esp,%ebp
c01043b5:	83 ec 08             	sub    $0x8,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01043b8:	a1 70 2f 12 c0       	mov    0xc0122f70,%eax
c01043bd:	8b 40 10             	mov    0x10(%eax),%eax
c01043c0:	ff 75 14             	pushl  0x14(%ebp)
c01043c3:	ff 75 10             	pushl  0x10(%ebp)
c01043c6:	ff 75 0c             	pushl  0xc(%ebp)
c01043c9:	ff 75 08             	pushl  0x8(%ebp)
c01043cc:	ff d0                	call   *%eax
c01043ce:	83 c4 10             	add    $0x10,%esp
}
c01043d1:	c9                   	leave  
c01043d2:	c3                   	ret    

c01043d3 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01043d3:	55                   	push   %ebp
c01043d4:	89 e5                	mov    %esp,%ebp
c01043d6:	83 ec 08             	sub    $0x8,%esp
     return sm->set_unswappable(mm, addr);
c01043d9:	a1 70 2f 12 c0       	mov    0xc0122f70,%eax
c01043de:	8b 40 14             	mov    0x14(%eax),%eax
c01043e1:	83 ec 08             	sub    $0x8,%esp
c01043e4:	ff 75 0c             	pushl  0xc(%ebp)
c01043e7:	ff 75 08             	pushl  0x8(%ebp)
c01043ea:	ff d0                	call   *%eax
c01043ec:	83 c4 10             	add    $0x10,%esp
}
c01043ef:	c9                   	leave  
c01043f0:	c3                   	ret    

c01043f1 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01043f1:	55                   	push   %ebp
c01043f2:	89 e5                	mov    %esp,%ebp
c01043f4:	83 ec 28             	sub    $0x28,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01043f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01043fe:	e9 2e 01 00 00       	jmp    c0104531 <swap_out+0x140>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0104403:	a1 70 2f 12 c0       	mov    0xc0122f70,%eax
c0104408:	8b 40 18             	mov    0x18(%eax),%eax
c010440b:	83 ec 04             	sub    $0x4,%esp
c010440e:	ff 75 10             	pushl  0x10(%ebp)
c0104411:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0104414:	52                   	push   %edx
c0104415:	ff 75 08             	pushl  0x8(%ebp)
c0104418:	ff d0                	call   *%eax
c010441a:	83 c4 10             	add    $0x10,%esp
c010441d:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0104420:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104424:	74 18                	je     c010443e <swap_out+0x4d>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0104426:	83 ec 08             	sub    $0x8,%esp
c0104429:	ff 75 f4             	pushl  -0xc(%ebp)
c010442c:	68 fc 92 10 c0       	push   $0xc01092fc
c0104431:	e8 4c be ff ff       	call   c0100282 <cprintf>
c0104436:	83 c4 10             	add    $0x10,%esp
c0104439:	e9 ff 00 00 00       	jmp    c010453d <swap_out+0x14c>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c010443e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104441:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104444:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0104447:	8b 45 08             	mov    0x8(%ebp),%eax
c010444a:	8b 40 0c             	mov    0xc(%eax),%eax
c010444d:	83 ec 04             	sub    $0x4,%esp
c0104450:	6a 00                	push   $0x0
c0104452:	ff 75 ec             	pushl  -0x14(%ebp)
c0104455:	50                   	push   %eax
c0104456:	e8 48 22 00 00       	call   c01066a3 <get_pte>
c010445b:	83 c4 10             	add    $0x10,%esp
c010445e:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0104461:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104464:	8b 00                	mov    (%eax),%eax
c0104466:	83 e0 01             	and    $0x1,%eax
c0104469:	85 c0                	test   %eax,%eax
c010446b:	75 16                	jne    c0104483 <swap_out+0x92>
c010446d:	68 29 93 10 c0       	push   $0xc0109329
c0104472:	68 3e 93 10 c0       	push   $0xc010933e
c0104477:	6a 65                	push   $0x65
c0104479:	68 d8 92 10 c0       	push   $0xc01092d8
c010447e:	e8 65 bf ff ff       	call   c01003e8 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0104483:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104486:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104489:	8b 52 1c             	mov    0x1c(%edx),%edx
c010448c:	c1 ea 0c             	shr    $0xc,%edx
c010448f:	83 c2 01             	add    $0x1,%edx
c0104492:	c1 e2 08             	shl    $0x8,%edx
c0104495:	83 ec 08             	sub    $0x8,%esp
c0104498:	50                   	push   %eax
c0104499:	52                   	push   %edx
c010449a:	e8 be 32 00 00       	call   c010775d <swapfs_write>
c010449f:	83 c4 10             	add    $0x10,%esp
c01044a2:	85 c0                	test   %eax,%eax
c01044a4:	74 2b                	je     c01044d1 <swap_out+0xe0>
                    cprintf("SWAP: failed to save\n");
c01044a6:	83 ec 0c             	sub    $0xc,%esp
c01044a9:	68 53 93 10 c0       	push   $0xc0109353
c01044ae:	e8 cf bd ff ff       	call   c0100282 <cprintf>
c01044b3:	83 c4 10             	add    $0x10,%esp
                    sm->map_swappable(mm, v, page, 0);
c01044b6:	a1 70 2f 12 c0       	mov    0xc0122f70,%eax
c01044bb:	8b 40 10             	mov    0x10(%eax),%eax
c01044be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01044c1:	6a 00                	push   $0x0
c01044c3:	52                   	push   %edx
c01044c4:	ff 75 ec             	pushl  -0x14(%ebp)
c01044c7:	ff 75 08             	pushl  0x8(%ebp)
c01044ca:	ff d0                	call   *%eax
c01044cc:	83 c4 10             	add    $0x10,%esp
c01044cf:	eb 5c                	jmp    c010452d <swap_out+0x13c>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01044d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044d4:	8b 40 1c             	mov    0x1c(%eax),%eax
c01044d7:	c1 e8 0c             	shr    $0xc,%eax
c01044da:	83 c0 01             	add    $0x1,%eax
c01044dd:	50                   	push   %eax
c01044de:	ff 75 ec             	pushl  -0x14(%ebp)
c01044e1:	ff 75 f4             	pushl  -0xc(%ebp)
c01044e4:	68 6c 93 10 c0       	push   $0xc010936c
c01044e9:	e8 94 bd ff ff       	call   c0100282 <cprintf>
c01044ee:	83 c4 10             	add    $0x10,%esp
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c01044f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044f4:	8b 40 1c             	mov    0x1c(%eax),%eax
c01044f7:	c1 e8 0c             	shr    $0xc,%eax
c01044fa:	83 c0 01             	add    $0x1,%eax
c01044fd:	c1 e0 08             	shl    $0x8,%eax
c0104500:	89 c2                	mov    %eax,%edx
c0104502:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104505:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0104507:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010450a:	83 ec 08             	sub    $0x8,%esp
c010450d:	6a 01                	push   $0x1
c010450f:	50                   	push   %eax
c0104510:	e8 93 1b 00 00       	call   c01060a8 <free_pages>
c0104515:	83 c4 10             	add    $0x10,%esp
          }
          
          tlb_invalidate(mm->pgdir, v);
c0104518:	8b 45 08             	mov    0x8(%ebp),%eax
c010451b:	8b 40 0c             	mov    0xc(%eax),%eax
c010451e:	83 ec 08             	sub    $0x8,%esp
c0104521:	ff 75 ec             	pushl  -0x14(%ebp)
c0104524:	50                   	push   %eax
c0104525:	e8 43 24 00 00       	call   c010696d <tlb_invalidate>
c010452a:	83 c4 10             	add    $0x10,%esp

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c010452d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104531:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104534:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104537:	0f 85 c6 fe ff ff    	jne    c0104403 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c010453d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104540:	c9                   	leave  
c0104541:	c3                   	ret    

c0104542 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0104542:	55                   	push   %ebp
c0104543:	89 e5                	mov    %esp,%ebp
c0104545:	83 ec 18             	sub    $0x18,%esp
     struct Page *result = alloc_page();
c0104548:	83 ec 0c             	sub    $0xc,%esp
c010454b:	6a 01                	push   $0x1
c010454d:	e8 ea 1a 00 00       	call   c010603c <alloc_pages>
c0104552:	83 c4 10             	add    $0x10,%esp
c0104555:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0104558:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010455c:	75 16                	jne    c0104574 <swap_in+0x32>
c010455e:	68 ac 93 10 c0       	push   $0xc01093ac
c0104563:	68 3e 93 10 c0       	push   $0xc010933e
c0104568:	6a 7b                	push   $0x7b
c010456a:	68 d8 92 10 c0       	push   $0xc01092d8
c010456f:	e8 74 be ff ff       	call   c01003e8 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0104574:	8b 45 08             	mov    0x8(%ebp),%eax
c0104577:	8b 40 0c             	mov    0xc(%eax),%eax
c010457a:	83 ec 04             	sub    $0x4,%esp
c010457d:	6a 00                	push   $0x0
c010457f:	ff 75 0c             	pushl  0xc(%ebp)
c0104582:	50                   	push   %eax
c0104583:	e8 1b 21 00 00       	call   c01066a3 <get_pte>
c0104588:	83 c4 10             	add    $0x10,%esp
c010458b:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c010458e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104591:	8b 00                	mov    (%eax),%eax
c0104593:	83 ec 08             	sub    $0x8,%esp
c0104596:	ff 75 f4             	pushl  -0xc(%ebp)
c0104599:	50                   	push   %eax
c010459a:	e8 65 31 00 00       	call   c0107704 <swapfs_read>
c010459f:	83 c4 10             	add    $0x10,%esp
c01045a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01045a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01045a9:	74 1f                	je     c01045ca <swap_in+0x88>
     {
        assert(r!=0);
c01045ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01045af:	75 19                	jne    c01045ca <swap_in+0x88>
c01045b1:	68 b9 93 10 c0       	push   $0xc01093b9
c01045b6:	68 3e 93 10 c0       	push   $0xc010933e
c01045bb:	68 83 00 00 00       	push   $0x83
c01045c0:	68 d8 92 10 c0       	push   $0xc01092d8
c01045c5:	e8 1e be ff ff       	call   c01003e8 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c01045ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045cd:	8b 00                	mov    (%eax),%eax
c01045cf:	c1 e8 08             	shr    $0x8,%eax
c01045d2:	83 ec 04             	sub    $0x4,%esp
c01045d5:	ff 75 0c             	pushl  0xc(%ebp)
c01045d8:	50                   	push   %eax
c01045d9:	68 c0 93 10 c0       	push   $0xc01093c0
c01045de:	e8 9f bc ff ff       	call   c0100282 <cprintf>
c01045e3:	83 c4 10             	add    $0x10,%esp
     *ptr_result=result;
c01045e6:	8b 45 10             	mov    0x10(%ebp),%eax
c01045e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01045ec:	89 10                	mov    %edx,(%eax)
     return 0;
c01045ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01045f3:	c9                   	leave  
c01045f4:	c3                   	ret    

c01045f5 <check_content_set>:



static inline void
check_content_set(void)
{
c01045f5:	55                   	push   %ebp
c01045f6:	89 e5                	mov    %esp,%ebp
c01045f8:	83 ec 08             	sub    $0x8,%esp
     *(unsigned char *)0x1000 = 0x0a;
c01045fb:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104600:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0104603:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104608:	83 f8 01             	cmp    $0x1,%eax
c010460b:	74 19                	je     c0104626 <check_content_set+0x31>
c010460d:	68 fe 93 10 c0       	push   $0xc01093fe
c0104612:	68 3e 93 10 c0       	push   $0xc010933e
c0104617:	68 90 00 00 00       	push   $0x90
c010461c:	68 d8 92 10 c0       	push   $0xc01092d8
c0104621:	e8 c2 bd ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0104626:	b8 10 10 00 00       	mov    $0x1010,%eax
c010462b:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c010462e:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104633:	83 f8 01             	cmp    $0x1,%eax
c0104636:	74 19                	je     c0104651 <check_content_set+0x5c>
c0104638:	68 fe 93 10 c0       	push   $0xc01093fe
c010463d:	68 3e 93 10 c0       	push   $0xc010933e
c0104642:	68 92 00 00 00       	push   $0x92
c0104647:	68 d8 92 10 c0       	push   $0xc01092d8
c010464c:	e8 97 bd ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0104651:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104656:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104659:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c010465e:	83 f8 02             	cmp    $0x2,%eax
c0104661:	74 19                	je     c010467c <check_content_set+0x87>
c0104663:	68 0d 94 10 c0       	push   $0xc010940d
c0104668:	68 3e 93 10 c0       	push   $0xc010933e
c010466d:	68 94 00 00 00       	push   $0x94
c0104672:	68 d8 92 10 c0       	push   $0xc01092d8
c0104677:	e8 6c bd ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c010467c:	b8 10 20 00 00       	mov    $0x2010,%eax
c0104681:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104684:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104689:	83 f8 02             	cmp    $0x2,%eax
c010468c:	74 19                	je     c01046a7 <check_content_set+0xb2>
c010468e:	68 0d 94 10 c0       	push   $0xc010940d
c0104693:	68 3e 93 10 c0       	push   $0xc010933e
c0104698:	68 96 00 00 00       	push   $0x96
c010469d:	68 d8 92 10 c0       	push   $0xc01092d8
c01046a2:	e8 41 bd ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c01046a7:	b8 00 30 00 00       	mov    $0x3000,%eax
c01046ac:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01046af:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c01046b4:	83 f8 03             	cmp    $0x3,%eax
c01046b7:	74 19                	je     c01046d2 <check_content_set+0xdd>
c01046b9:	68 1c 94 10 c0       	push   $0xc010941c
c01046be:	68 3e 93 10 c0       	push   $0xc010933e
c01046c3:	68 98 00 00 00       	push   $0x98
c01046c8:	68 d8 92 10 c0       	push   $0xc01092d8
c01046cd:	e8 16 bd ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c01046d2:	b8 10 30 00 00       	mov    $0x3010,%eax
c01046d7:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01046da:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c01046df:	83 f8 03             	cmp    $0x3,%eax
c01046e2:	74 19                	je     c01046fd <check_content_set+0x108>
c01046e4:	68 1c 94 10 c0       	push   $0xc010941c
c01046e9:	68 3e 93 10 c0       	push   $0xc010933e
c01046ee:	68 9a 00 00 00       	push   $0x9a
c01046f3:	68 d8 92 10 c0       	push   $0xc01092d8
c01046f8:	e8 eb bc ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c01046fd:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104702:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104705:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c010470a:	83 f8 04             	cmp    $0x4,%eax
c010470d:	74 19                	je     c0104728 <check_content_set+0x133>
c010470f:	68 2b 94 10 c0       	push   $0xc010942b
c0104714:	68 3e 93 10 c0       	push   $0xc010933e
c0104719:	68 9c 00 00 00       	push   $0x9c
c010471e:	68 d8 92 10 c0       	push   $0xc01092d8
c0104723:	e8 c0 bc ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0104728:	b8 10 40 00 00       	mov    $0x4010,%eax
c010472d:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104730:	a1 64 2f 12 c0       	mov    0xc0122f64,%eax
c0104735:	83 f8 04             	cmp    $0x4,%eax
c0104738:	74 19                	je     c0104753 <check_content_set+0x15e>
c010473a:	68 2b 94 10 c0       	push   $0xc010942b
c010473f:	68 3e 93 10 c0       	push   $0xc010933e
c0104744:	68 9e 00 00 00       	push   $0x9e
c0104749:	68 d8 92 10 c0       	push   $0xc01092d8
c010474e:	e8 95 bc ff ff       	call   c01003e8 <__panic>
}
c0104753:	90                   	nop
c0104754:	c9                   	leave  
c0104755:	c3                   	ret    

c0104756 <check_content_access>:

static inline int
check_content_access(void)
{
c0104756:	55                   	push   %ebp
c0104757:	89 e5                	mov    %esp,%ebp
c0104759:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c010475c:	a1 70 2f 12 c0       	mov    0xc0122f70,%eax
c0104761:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104764:	ff d0                	call   *%eax
c0104766:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0104769:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010476c:	c9                   	leave  
c010476d:	c3                   	ret    

c010476e <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c010476e:	55                   	push   %ebp
c010476f:	89 e5                	mov    %esp,%ebp
c0104771:	83 ec 68             	sub    $0x68,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0104774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010477b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0104782:	c7 45 e8 e4 30 12 c0 	movl   $0xc01230e4,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104789:	eb 60                	jmp    c01047eb <check_swap+0x7d>
        struct Page *p = le2page(le, page_link);
c010478b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010478e:	83 e8 0c             	sub    $0xc,%eax
c0104791:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(PageProperty(p));
c0104794:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104797:	83 c0 04             	add    $0x4,%eax
c010479a:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c01047a1:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01047a4:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01047a7:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01047aa:	0f a3 10             	bt     %edx,(%eax)
c01047ad:	19 c0                	sbb    %eax,%eax
c01047af:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c01047b2:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c01047b6:	0f 95 c0             	setne  %al
c01047b9:	0f b6 c0             	movzbl %al,%eax
c01047bc:	85 c0                	test   %eax,%eax
c01047be:	75 19                	jne    c01047d9 <check_swap+0x6b>
c01047c0:	68 3a 94 10 c0       	push   $0xc010943a
c01047c5:	68 3e 93 10 c0       	push   $0xc010933e
c01047ca:	68 b9 00 00 00       	push   $0xb9
c01047cf:	68 d8 92 10 c0       	push   $0xc01092d8
c01047d4:	e8 0f bc ff ff       	call   c01003e8 <__panic>
        count ++, total += p->property;
c01047d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01047dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01047e0:	8b 50 08             	mov    0x8(%eax),%edx
c01047e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047e6:	01 d0                	add    %edx,%eax
c01047e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01047ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01047f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01047f4:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01047f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01047fa:	81 7d e8 e4 30 12 c0 	cmpl   $0xc01230e4,-0x18(%ebp)
c0104801:	75 88                	jne    c010478b <check_swap+0x1d>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c0104803:	e8 d5 18 00 00       	call   c01060dd <nr_free_pages>
c0104808:	89 c2                	mov    %eax,%edx
c010480a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010480d:	39 c2                	cmp    %eax,%edx
c010480f:	74 19                	je     c010482a <check_swap+0xbc>
c0104811:	68 4a 94 10 c0       	push   $0xc010944a
c0104816:	68 3e 93 10 c0       	push   $0xc010933e
c010481b:	68 bc 00 00 00       	push   $0xbc
c0104820:	68 d8 92 10 c0       	push   $0xc01092d8
c0104825:	e8 be bb ff ff       	call   c01003e8 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c010482a:	83 ec 04             	sub    $0x4,%esp
c010482d:	ff 75 f0             	pushl  -0x10(%ebp)
c0104830:	ff 75 f4             	pushl  -0xc(%ebp)
c0104833:	68 64 94 10 c0       	push   $0xc0109464
c0104838:	e8 45 ba ff ff       	call   c0100282 <cprintf>
c010483d:	83 c4 10             	add    $0x10,%esp
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0104840:	e8 bc e9 ff ff       	call   c0103201 <mm_create>
c0104845:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(mm != NULL);
c0104848:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010484c:	75 19                	jne    c0104867 <check_swap+0xf9>
c010484e:	68 8a 94 10 c0       	push   $0xc010948a
c0104853:	68 3e 93 10 c0       	push   $0xc010933e
c0104858:	68 c1 00 00 00       	push   $0xc1
c010485d:	68 d8 92 10 c0       	push   $0xc01092d8
c0104862:	e8 81 bb ff ff       	call   c01003e8 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0104867:	a1 10 30 12 c0       	mov    0xc0123010,%eax
c010486c:	85 c0                	test   %eax,%eax
c010486e:	74 19                	je     c0104889 <check_swap+0x11b>
c0104870:	68 95 94 10 c0       	push   $0xc0109495
c0104875:	68 3e 93 10 c0       	push   $0xc010933e
c010487a:	68 c4 00 00 00       	push   $0xc4
c010487f:	68 d8 92 10 c0       	push   $0xc01092d8
c0104884:	e8 5f bb ff ff       	call   c01003e8 <__panic>

     check_mm_struct = mm;
c0104889:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010488c:	a3 10 30 12 c0       	mov    %eax,0xc0123010

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104891:	8b 15 00 fa 11 c0    	mov    0xc011fa00,%edx
c0104897:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010489a:	89 50 0c             	mov    %edx,0xc(%eax)
c010489d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01048a0:	8b 40 0c             	mov    0xc(%eax),%eax
c01048a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(pgdir[0] == 0);
c01048a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01048a9:	8b 00                	mov    (%eax),%eax
c01048ab:	85 c0                	test   %eax,%eax
c01048ad:	74 19                	je     c01048c8 <check_swap+0x15a>
c01048af:	68 ad 94 10 c0       	push   $0xc01094ad
c01048b4:	68 3e 93 10 c0       	push   $0xc010933e
c01048b9:	68 c9 00 00 00       	push   $0xc9
c01048be:	68 d8 92 10 c0       	push   $0xc01092d8
c01048c3:	e8 20 bb ff ff       	call   c01003e8 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01048c8:	83 ec 04             	sub    $0x4,%esp
c01048cb:	6a 03                	push   $0x3
c01048cd:	68 00 60 00 00       	push   $0x6000
c01048d2:	68 00 10 00 00       	push   $0x1000
c01048d7:	e8 a1 e9 ff ff       	call   c010327d <vma_create>
c01048dc:	83 c4 10             	add    $0x10,%esp
c01048df:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(vma != NULL);
c01048e2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01048e6:	75 19                	jne    c0104901 <check_swap+0x193>
c01048e8:	68 bb 94 10 c0       	push   $0xc01094bb
c01048ed:	68 3e 93 10 c0       	push   $0xc010933e
c01048f2:	68 cc 00 00 00       	push   $0xcc
c01048f7:	68 d8 92 10 c0       	push   $0xc01092d8
c01048fc:	e8 e7 ba ff ff       	call   c01003e8 <__panic>

     insert_vma_struct(mm, vma);
c0104901:	83 ec 08             	sub    $0x8,%esp
c0104904:	ff 75 d0             	pushl  -0x30(%ebp)
c0104907:	ff 75 d8             	pushl  -0x28(%ebp)
c010490a:	e8 d6 ea ff ff       	call   c01033e5 <insert_vma_struct>
c010490f:	83 c4 10             	add    $0x10,%esp

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0104912:	83 ec 0c             	sub    $0xc,%esp
c0104915:	68 c8 94 10 c0       	push   $0xc01094c8
c010491a:	e8 63 b9 ff ff       	call   c0100282 <cprintf>
c010491f:	83 c4 10             	add    $0x10,%esp
     pte_t *temp_ptep=NULL;
c0104922:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0104929:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010492c:	8b 40 0c             	mov    0xc(%eax),%eax
c010492f:	83 ec 04             	sub    $0x4,%esp
c0104932:	6a 01                	push   $0x1
c0104934:	68 00 10 00 00       	push   $0x1000
c0104939:	50                   	push   %eax
c010493a:	e8 64 1d 00 00       	call   c01066a3 <get_pte>
c010493f:	83 c4 10             	add    $0x10,%esp
c0104942:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(temp_ptep!= NULL);
c0104945:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104949:	75 19                	jne    c0104964 <check_swap+0x1f6>
c010494b:	68 fc 94 10 c0       	push   $0xc01094fc
c0104950:	68 3e 93 10 c0       	push   $0xc010933e
c0104955:	68 d4 00 00 00       	push   $0xd4
c010495a:	68 d8 92 10 c0       	push   $0xc01092d8
c010495f:	e8 84 ba ff ff       	call   c01003e8 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0104964:	83 ec 0c             	sub    $0xc,%esp
c0104967:	68 10 95 10 c0       	push   $0xc0109510
c010496c:	e8 11 b9 ff ff       	call   c0100282 <cprintf>
c0104971:	83 c4 10             	add    $0x10,%esp
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104974:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010497b:	e9 90 00 00 00       	jmp    c0104a10 <check_swap+0x2a2>
          check_rp[i] = alloc_page();
c0104980:	83 ec 0c             	sub    $0xc,%esp
c0104983:	6a 01                	push   $0x1
c0104985:	e8 b2 16 00 00       	call   c010603c <alloc_pages>
c010498a:	83 c4 10             	add    $0x10,%esp
c010498d:	89 c2                	mov    %eax,%edx
c010498f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104992:	89 14 85 20 30 12 c0 	mov    %edx,-0x3fedcfe0(,%eax,4)
          assert(check_rp[i] != NULL );
c0104999:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010499c:	8b 04 85 20 30 12 c0 	mov    -0x3fedcfe0(,%eax,4),%eax
c01049a3:	85 c0                	test   %eax,%eax
c01049a5:	75 19                	jne    c01049c0 <check_swap+0x252>
c01049a7:	68 34 95 10 c0       	push   $0xc0109534
c01049ac:	68 3e 93 10 c0       	push   $0xc010933e
c01049b1:	68 d9 00 00 00       	push   $0xd9
c01049b6:	68 d8 92 10 c0       	push   $0xc01092d8
c01049bb:	e8 28 ba ff ff       	call   c01003e8 <__panic>
          assert(!PageProperty(check_rp[i]));
c01049c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049c3:	8b 04 85 20 30 12 c0 	mov    -0x3fedcfe0(,%eax,4),%eax
c01049ca:	83 c0 04             	add    $0x4,%eax
c01049cd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01049d4:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01049d7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01049da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01049dd:	0f a3 10             	bt     %edx,(%eax)
c01049e0:	19 c0                	sbb    %eax,%eax
c01049e2:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c01049e5:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c01049e9:	0f 95 c0             	setne  %al
c01049ec:	0f b6 c0             	movzbl %al,%eax
c01049ef:	85 c0                	test   %eax,%eax
c01049f1:	74 19                	je     c0104a0c <check_swap+0x29e>
c01049f3:	68 48 95 10 c0       	push   $0xc0109548
c01049f8:	68 3e 93 10 c0       	push   $0xc010933e
c01049fd:	68 da 00 00 00       	push   $0xda
c0104a02:	68 d8 92 10 c0       	push   $0xc01092d8
c0104a07:	e8 dc b9 ff ff       	call   c01003e8 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104a0c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104a10:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104a14:	0f 8e 66 ff ff ff    	jle    c0104980 <check_swap+0x212>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c0104a1a:	a1 e4 30 12 c0       	mov    0xc01230e4,%eax
c0104a1f:	8b 15 e8 30 12 c0    	mov    0xc01230e8,%edx
c0104a25:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104a28:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0104a2b:	c7 45 c0 e4 30 12 c0 	movl   $0xc01230e4,-0x40(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104a32:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104a35:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104a38:	89 50 04             	mov    %edx,0x4(%eax)
c0104a3b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104a3e:	8b 50 04             	mov    0x4(%eax),%edx
c0104a41:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104a44:	89 10                	mov    %edx,(%eax)
c0104a46:	c7 45 c8 e4 30 12 c0 	movl   $0xc01230e4,-0x38(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104a4d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104a50:	8b 40 04             	mov    0x4(%eax),%eax
c0104a53:	39 45 c8             	cmp    %eax,-0x38(%ebp)
c0104a56:	0f 94 c0             	sete   %al
c0104a59:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0104a5c:	85 c0                	test   %eax,%eax
c0104a5e:	75 19                	jne    c0104a79 <check_swap+0x30b>
c0104a60:	68 63 95 10 c0       	push   $0xc0109563
c0104a65:	68 3e 93 10 c0       	push   $0xc010933e
c0104a6a:	68 de 00 00 00       	push   $0xde
c0104a6f:	68 d8 92 10 c0       	push   $0xc01092d8
c0104a74:	e8 6f b9 ff ff       	call   c01003e8 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0104a79:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
c0104a7e:	89 45 bc             	mov    %eax,-0x44(%ebp)
     nr_free = 0;
c0104a81:	c7 05 ec 30 12 c0 00 	movl   $0x0,0xc01230ec
c0104a88:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104a8b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104a92:	eb 1c                	jmp    c0104ab0 <check_swap+0x342>
        free_pages(check_rp[i],1);
c0104a94:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a97:	8b 04 85 20 30 12 c0 	mov    -0x3fedcfe0(,%eax,4),%eax
c0104a9e:	83 ec 08             	sub    $0x8,%esp
c0104aa1:	6a 01                	push   $0x1
c0104aa3:	50                   	push   %eax
c0104aa4:	e8 ff 15 00 00       	call   c01060a8 <free_pages>
c0104aa9:	83 c4 10             	add    $0x10,%esp
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104aac:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104ab0:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104ab4:	7e de                	jle    c0104a94 <check_swap+0x326>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0104ab6:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
c0104abb:	83 f8 04             	cmp    $0x4,%eax
c0104abe:	74 19                	je     c0104ad9 <check_swap+0x36b>
c0104ac0:	68 7c 95 10 c0       	push   $0xc010957c
c0104ac5:	68 3e 93 10 c0       	push   $0xc010933e
c0104aca:	68 e7 00 00 00       	push   $0xe7
c0104acf:	68 d8 92 10 c0       	push   $0xc01092d8
c0104ad4:	e8 0f b9 ff ff       	call   c01003e8 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0104ad9:	83 ec 0c             	sub    $0xc,%esp
c0104adc:	68 a0 95 10 c0       	push   $0xc01095a0
c0104ae1:	e8 9c b7 ff ff       	call   c0100282 <cprintf>
c0104ae6:	83 c4 10             	add    $0x10,%esp
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0104ae9:	c7 05 64 2f 12 c0 00 	movl   $0x0,0xc0122f64
c0104af0:	00 00 00 
     
     check_content_set();
c0104af3:	e8 fd fa ff ff       	call   c01045f5 <check_content_set>
     assert( nr_free == 0);         
c0104af8:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
c0104afd:	85 c0                	test   %eax,%eax
c0104aff:	74 19                	je     c0104b1a <check_swap+0x3ac>
c0104b01:	68 c7 95 10 c0       	push   $0xc01095c7
c0104b06:	68 3e 93 10 c0       	push   $0xc010933e
c0104b0b:	68 f0 00 00 00       	push   $0xf0
c0104b10:	68 d8 92 10 c0       	push   $0xc01092d8
c0104b15:	e8 ce b8 ff ff       	call   c01003e8 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0104b1a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104b21:	eb 26                	jmp    c0104b49 <check_swap+0x3db>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0104b23:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b26:	c7 04 85 40 30 12 c0 	movl   $0xffffffff,-0x3fedcfc0(,%eax,4)
c0104b2d:	ff ff ff ff 
c0104b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b34:	8b 14 85 40 30 12 c0 	mov    -0x3fedcfc0(,%eax,4),%edx
c0104b3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b3e:	89 14 85 80 30 12 c0 	mov    %edx,-0x3fedcf80(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0104b45:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104b49:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0104b4d:	7e d4                	jle    c0104b23 <check_swap+0x3b5>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104b4f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104b56:	e9 cc 00 00 00       	jmp    c0104c27 <check_swap+0x4b9>
         check_ptep[i]=0;
c0104b5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b5e:	c7 04 85 d4 30 12 c0 	movl   $0x0,-0x3fedcf2c(,%eax,4)
c0104b65:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0104b69:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b6c:	83 c0 01             	add    $0x1,%eax
c0104b6f:	c1 e0 0c             	shl    $0xc,%eax
c0104b72:	83 ec 04             	sub    $0x4,%esp
c0104b75:	6a 00                	push   $0x0
c0104b77:	50                   	push   %eax
c0104b78:	ff 75 d4             	pushl  -0x2c(%ebp)
c0104b7b:	e8 23 1b 00 00       	call   c01066a3 <get_pte>
c0104b80:	83 c4 10             	add    $0x10,%esp
c0104b83:	89 c2                	mov    %eax,%edx
c0104b85:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b88:	89 14 85 d4 30 12 c0 	mov    %edx,-0x3fedcf2c(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0104b8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b92:	8b 04 85 d4 30 12 c0 	mov    -0x3fedcf2c(,%eax,4),%eax
c0104b99:	85 c0                	test   %eax,%eax
c0104b9b:	75 19                	jne    c0104bb6 <check_swap+0x448>
c0104b9d:	68 d4 95 10 c0       	push   $0xc01095d4
c0104ba2:	68 3e 93 10 c0       	push   $0xc010933e
c0104ba7:	68 f8 00 00 00       	push   $0xf8
c0104bac:	68 d8 92 10 c0       	push   $0xc01092d8
c0104bb1:	e8 32 b8 ff ff       	call   c01003e8 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0104bb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bb9:	8b 04 85 d4 30 12 c0 	mov    -0x3fedcf2c(,%eax,4),%eax
c0104bc0:	8b 00                	mov    (%eax),%eax
c0104bc2:	83 ec 0c             	sub    $0xc,%esp
c0104bc5:	50                   	push   %eax
c0104bc6:	e8 f4 f6 ff ff       	call   c01042bf <pte2page>
c0104bcb:	83 c4 10             	add    $0x10,%esp
c0104bce:	89 c2                	mov    %eax,%edx
c0104bd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bd3:	8b 04 85 20 30 12 c0 	mov    -0x3fedcfe0(,%eax,4),%eax
c0104bda:	39 c2                	cmp    %eax,%edx
c0104bdc:	74 19                	je     c0104bf7 <check_swap+0x489>
c0104bde:	68 ec 95 10 c0       	push   $0xc01095ec
c0104be3:	68 3e 93 10 c0       	push   $0xc010933e
c0104be8:	68 f9 00 00 00       	push   $0xf9
c0104bed:	68 d8 92 10 c0       	push   $0xc01092d8
c0104bf2:	e8 f1 b7 ff ff       	call   c01003e8 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0104bf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bfa:	8b 04 85 d4 30 12 c0 	mov    -0x3fedcf2c(,%eax,4),%eax
c0104c01:	8b 00                	mov    (%eax),%eax
c0104c03:	83 e0 01             	and    $0x1,%eax
c0104c06:	85 c0                	test   %eax,%eax
c0104c08:	75 19                	jne    c0104c23 <check_swap+0x4b5>
c0104c0a:	68 14 96 10 c0       	push   $0xc0109614
c0104c0f:	68 3e 93 10 c0       	push   $0xc010933e
c0104c14:	68 fa 00 00 00       	push   $0xfa
c0104c19:	68 d8 92 10 c0       	push   $0xc01092d8
c0104c1e:	e8 c5 b7 ff ff       	call   c01003e8 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104c23:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104c27:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104c2b:	0f 8e 2a ff ff ff    	jle    c0104b5b <check_swap+0x3ed>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0104c31:	83 ec 0c             	sub    $0xc,%esp
c0104c34:	68 30 96 10 c0       	push   $0xc0109630
c0104c39:	e8 44 b6 ff ff       	call   c0100282 <cprintf>
c0104c3e:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0104c41:	e8 10 fb ff ff       	call   c0104756 <check_content_access>
c0104c46:	89 45 b8             	mov    %eax,-0x48(%ebp)
     assert(ret==0);
c0104c49:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104c4d:	74 19                	je     c0104c68 <check_swap+0x4fa>
c0104c4f:	68 56 96 10 c0       	push   $0xc0109656
c0104c54:	68 3e 93 10 c0       	push   $0xc010933e
c0104c59:	68 ff 00 00 00       	push   $0xff
c0104c5e:	68 d8 92 10 c0       	push   $0xc01092d8
c0104c63:	e8 80 b7 ff ff       	call   c01003e8 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104c68:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104c6f:	eb 1c                	jmp    c0104c8d <check_swap+0x51f>
         free_pages(check_rp[i],1);
c0104c71:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c74:	8b 04 85 20 30 12 c0 	mov    -0x3fedcfe0(,%eax,4),%eax
c0104c7b:	83 ec 08             	sub    $0x8,%esp
c0104c7e:	6a 01                	push   $0x1
c0104c80:	50                   	push   %eax
c0104c81:	e8 22 14 00 00       	call   c01060a8 <free_pages>
c0104c86:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104c89:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104c8d:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104c91:	7e de                	jle    c0104c71 <check_swap+0x503>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0104c93:	83 ec 0c             	sub    $0xc,%esp
c0104c96:	ff 75 d8             	pushl  -0x28(%ebp)
c0104c99:	e8 6b e8 ff ff       	call   c0103509 <mm_destroy>
c0104c9e:	83 c4 10             	add    $0x10,%esp
         
     nr_free = nr_free_store;
c0104ca1:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104ca4:	a3 ec 30 12 c0       	mov    %eax,0xc01230ec
     free_list = free_list_store;
c0104ca9:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104cac:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104caf:	a3 e4 30 12 c0       	mov    %eax,0xc01230e4
c0104cb4:	89 15 e8 30 12 c0    	mov    %edx,0xc01230e8

     
     le = &free_list;
c0104cba:	c7 45 e8 e4 30 12 c0 	movl   $0xc01230e4,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104cc1:	eb 1d                	jmp    c0104ce0 <check_swap+0x572>
         struct Page *p = le2page(le, page_link);
c0104cc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104cc6:	83 e8 0c             	sub    $0xc,%eax
c0104cc9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
         count --, total -= p->property;
c0104ccc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104cd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104cd3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104cd6:	8b 40 08             	mov    0x8(%eax),%eax
c0104cd9:	29 c2                	sub    %eax,%edx
c0104cdb:	89 d0                	mov    %edx,%eax
c0104cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ce0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ce3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104ce6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104ce9:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0104cec:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104cef:	81 7d e8 e4 30 12 c0 	cmpl   $0xc01230e4,-0x18(%ebp)
c0104cf6:	75 cb                	jne    c0104cc3 <check_swap+0x555>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0104cf8:	83 ec 04             	sub    $0x4,%esp
c0104cfb:	ff 75 f0             	pushl  -0x10(%ebp)
c0104cfe:	ff 75 f4             	pushl  -0xc(%ebp)
c0104d01:	68 5d 96 10 c0       	push   $0xc010965d
c0104d06:	e8 77 b5 ff ff       	call   c0100282 <cprintf>
c0104d0b:	83 c4 10             	add    $0x10,%esp
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0104d0e:	83 ec 0c             	sub    $0xc,%esp
c0104d11:	68 77 96 10 c0       	push   $0xc0109677
c0104d16:	e8 67 b5 ff ff       	call   c0100282 <cprintf>
c0104d1b:	83 c4 10             	add    $0x10,%esp
}
c0104d1e:	90                   	nop
c0104d1f:	c9                   	leave  
c0104d20:	c3                   	ret    

c0104d21 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104d21:	55                   	push   %ebp
c0104d22:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104d24:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d27:	8b 15 f8 30 12 c0    	mov    0xc01230f8,%edx
c0104d2d:	29 d0                	sub    %edx,%eax
c0104d2f:	c1 f8 05             	sar    $0x5,%eax
}
c0104d32:	5d                   	pop    %ebp
c0104d33:	c3                   	ret    

c0104d34 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104d34:	55                   	push   %ebp
c0104d35:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0104d37:	ff 75 08             	pushl  0x8(%ebp)
c0104d3a:	e8 e2 ff ff ff       	call   c0104d21 <page2ppn>
c0104d3f:	83 c4 04             	add    $0x4,%esp
c0104d42:	c1 e0 0c             	shl    $0xc,%eax
}
c0104d45:	c9                   	leave  
c0104d46:	c3                   	ret    

c0104d47 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0104d47:	55                   	push   %ebp
c0104d48:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104d4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d4d:	8b 00                	mov    (%eax),%eax
}
c0104d4f:	5d                   	pop    %ebp
c0104d50:	c3                   	ret    

c0104d51 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0104d51:	55                   	push   %ebp
c0104d52:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104d54:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d57:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104d5a:	89 10                	mov    %edx,(%eax)
}
c0104d5c:	90                   	nop
c0104d5d:	5d                   	pop    %ebp
c0104d5e:	c3                   	ret    

c0104d5f <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0104d5f:	55                   	push   %ebp
c0104d60:	89 e5                	mov    %esp,%ebp
c0104d62:	83 ec 10             	sub    $0x10,%esp
c0104d65:	c7 45 fc e4 30 12 c0 	movl   $0xc01230e4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104d6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104d6f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104d72:	89 50 04             	mov    %edx,0x4(%eax)
c0104d75:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104d78:	8b 50 04             	mov    0x4(%eax),%edx
c0104d7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104d7e:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0104d80:	c7 05 ec 30 12 c0 00 	movl   $0x0,0xc01230ec
c0104d87:	00 00 00 
}
c0104d8a:	90                   	nop
c0104d8b:	c9                   	leave  
c0104d8c:	c3                   	ret    

c0104d8d <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0104d8d:	55                   	push   %ebp
c0104d8e:	89 e5                	mov    %esp,%ebp
c0104d90:	83 ec 38             	sub    $0x38,%esp
    assert(n > 0);
c0104d93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104d97:	75 16                	jne    c0104daf <default_init_memmap+0x22>
c0104d99:	68 90 96 10 c0       	push   $0xc0109690
c0104d9e:	68 96 96 10 c0       	push   $0xc0109696
c0104da3:	6a 6d                	push   $0x6d
c0104da5:	68 ab 96 10 c0       	push   $0xc01096ab
c0104daa:	e8 39 b6 ff ff       	call   c01003e8 <__panic>
    struct Page *p = base;
c0104daf:	8b 45 08             	mov    0x8(%ebp),%eax
c0104db2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104db5:	eb 6c                	jmp    c0104e23 <default_init_memmap+0x96>
        assert(PageReserved(p));
c0104db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dba:	83 c0 04             	add    $0x4,%eax
c0104dbd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104dc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104dc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104dca:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104dcd:	0f a3 10             	bt     %edx,(%eax)
c0104dd0:	19 c0                	sbb    %eax,%eax
c0104dd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0104dd5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104dd9:	0f 95 c0             	setne  %al
c0104ddc:	0f b6 c0             	movzbl %al,%eax
c0104ddf:	85 c0                	test   %eax,%eax
c0104de1:	75 16                	jne    c0104df9 <default_init_memmap+0x6c>
c0104de3:	68 c1 96 10 c0       	push   $0xc01096c1
c0104de8:	68 96 96 10 c0       	push   $0xc0109696
c0104ded:	6a 70                	push   $0x70
c0104def:	68 ab 96 10 c0       	push   $0xc01096ab
c0104df4:	e8 ef b5 ff ff       	call   c01003e8 <__panic>
        p->flags = p->property = 0;
c0104df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dfc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0104e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e06:	8b 50 08             	mov    0x8(%eax),%edx
c0104e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e0c:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0104e0f:	83 ec 08             	sub    $0x8,%esp
c0104e12:	6a 00                	push   $0x0
c0104e14:	ff 75 f4             	pushl  -0xc(%ebp)
c0104e17:	e8 35 ff ff ff       	call   c0104d51 <set_page_ref>
c0104e1c:	83 c4 10             	add    $0x10,%esp

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0104e1f:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0104e23:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e26:	c1 e0 05             	shl    $0x5,%eax
c0104e29:	89 c2                	mov    %eax,%edx
c0104e2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e2e:	01 d0                	add    %edx,%eax
c0104e30:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104e33:	75 82                	jne    c0104db7 <default_init_memmap+0x2a>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0104e35:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e38:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104e3b:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104e3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e41:	83 c0 04             	add    $0x4,%eax
c0104e44:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0104e4b:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104e4e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104e51:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104e54:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0104e57:	8b 15 ec 30 12 c0    	mov    0xc01230ec,%edx
c0104e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e60:	01 d0                	add    %edx,%eax
c0104e62:	a3 ec 30 12 c0       	mov    %eax,0xc01230ec
    list_add_before(&free_list, &(base->page_link));
c0104e67:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e6a:	83 c0 0c             	add    $0xc,%eax
c0104e6d:	c7 45 f0 e4 30 12 c0 	movl   $0xc01230e4,-0x10(%ebp)
c0104e74:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0104e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e7a:	8b 00                	mov    (%eax),%eax
c0104e7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104e7f:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0104e82:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0104e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e88:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104e8b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104e8e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104e91:	89 10                	mov    %edx,(%eax)
c0104e93:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104e96:	8b 10                	mov    (%eax),%edx
c0104e98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104e9b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104e9e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104ea1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104ea4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104ea7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104eaa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104ead:	89 10                	mov    %edx,(%eax)
}
c0104eaf:	90                   	nop
c0104eb0:	c9                   	leave  
c0104eb1:	c3                   	ret    

c0104eb2 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0104eb2:	55                   	push   %ebp
c0104eb3:	89 e5                	mov    %esp,%ebp
c0104eb5:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0104eb8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104ebc:	75 16                	jne    c0104ed4 <default_alloc_pages+0x22>
c0104ebe:	68 90 96 10 c0       	push   $0xc0109690
c0104ec3:	68 96 96 10 c0       	push   $0xc0109696
c0104ec8:	6a 7c                	push   $0x7c
c0104eca:	68 ab 96 10 c0       	push   $0xc01096ab
c0104ecf:	e8 14 b5 ff ff       	call   c01003e8 <__panic>
    if (n > nr_free) {
c0104ed4:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
c0104ed9:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104edc:	73 0a                	jae    c0104ee8 <default_alloc_pages+0x36>
        return NULL;
c0104ede:	b8 00 00 00 00       	mov    $0x0,%eax
c0104ee3:	e9 36 01 00 00       	jmp    c010501e <default_alloc_pages+0x16c>
    }
    struct Page *page = NULL;
c0104ee8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104eef:	c7 45 f0 e4 30 12 c0 	movl   $0xc01230e4,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0104ef6:	eb 1c                	jmp    c0104f14 <default_alloc_pages+0x62>
        struct Page *p = le2page(le, page_link);
c0104ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104efb:	83 e8 0c             	sub    $0xc,%eax
c0104efe:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c0104f01:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f04:	8b 40 08             	mov    0x8(%eax),%eax
c0104f07:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104f0a:	72 08                	jb     c0104f14 <default_alloc_pages+0x62>
            page = p;
c0104f0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0104f12:	eb 18                	jmp    c0104f2c <default_alloc_pages+0x7a>
c0104f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f17:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104f1a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104f1d:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0104f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f23:	81 7d f0 e4 30 12 c0 	cmpl   $0xc01230e4,-0x10(%ebp)
c0104f2a:	75 cc                	jne    c0104ef8 <default_alloc_pages+0x46>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0104f2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f30:	0f 84 e5 00 00 00    	je     c010501b <default_alloc_pages+0x169>
        if (page->property > n) {
c0104f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f39:	8b 40 08             	mov    0x8(%eax),%eax
c0104f3c:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104f3f:	0f 86 85 00 00 00    	jbe    c0104fca <default_alloc_pages+0x118>
            struct Page *p = page + n;
c0104f45:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f48:	c1 e0 05             	shl    $0x5,%eax
c0104f4b:	89 c2                	mov    %eax,%edx
c0104f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f50:	01 d0                	add    %edx,%eax
c0104f52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c0104f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f58:	8b 40 08             	mov    0x8(%eax),%eax
c0104f5b:	2b 45 08             	sub    0x8(%ebp),%eax
c0104f5e:	89 c2                	mov    %eax,%edx
c0104f60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f63:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0104f66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f69:	83 c0 04             	add    $0x4,%eax
c0104f6c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0104f73:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0104f76:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104f79:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104f7c:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0104f7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f82:	83 c0 0c             	add    $0xc,%eax
c0104f85:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104f88:	83 c2 0c             	add    $0xc,%edx
c0104f8b:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0104f8e:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0104f91:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f94:	8b 40 04             	mov    0x4(%eax),%eax
c0104f97:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104f9a:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104f9d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104fa0:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0104fa3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104fa6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104fa9:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104fac:	89 10                	mov    %edx,(%eax)
c0104fae:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104fb1:	8b 10                	mov    (%eax),%edx
c0104fb3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104fb6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104fb9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104fbc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104fbf:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104fc2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104fc5:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104fc8:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c0104fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fcd:	83 c0 0c             	add    $0xc,%eax
c0104fd0:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0104fd3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104fd6:	8b 40 04             	mov    0x4(%eax),%eax
c0104fd9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104fdc:	8b 12                	mov    (%edx),%edx
c0104fde:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0104fe1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104fe4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104fe7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104fea:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104fed:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104ff0:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104ff3:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0104ff5:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
c0104ffa:	2b 45 08             	sub    0x8(%ebp),%eax
c0104ffd:	a3 ec 30 12 c0       	mov    %eax,0xc01230ec
        ClearPageProperty(page);
c0105002:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105005:	83 c0 04             	add    $0x4,%eax
c0105008:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c010500f:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105012:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105015:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105018:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c010501b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010501e:	c9                   	leave  
c010501f:	c3                   	ret    

c0105020 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0105020:	55                   	push   %ebp
c0105021:	89 e5                	mov    %esp,%ebp
c0105023:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
c0105029:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010502d:	75 19                	jne    c0105048 <default_free_pages+0x28>
c010502f:	68 90 96 10 c0       	push   $0xc0109690
c0105034:	68 96 96 10 c0       	push   $0xc0109696
c0105039:	68 9a 00 00 00       	push   $0x9a
c010503e:	68 ab 96 10 c0       	push   $0xc01096ab
c0105043:	e8 a0 b3 ff ff       	call   c01003e8 <__panic>
    struct Page *p = base;
c0105048:	8b 45 08             	mov    0x8(%ebp),%eax
c010504b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010504e:	e9 8f 00 00 00       	jmp    c01050e2 <default_free_pages+0xc2>
        assert(!PageReserved(p) && !PageProperty(p));
c0105053:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105056:	83 c0 04             	add    $0x4,%eax
c0105059:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c0105060:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105063:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105066:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105069:	0f a3 10             	bt     %edx,(%eax)
c010506c:	19 c0                	sbb    %eax,%eax
c010506e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0105071:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0105075:	0f 95 c0             	setne  %al
c0105078:	0f b6 c0             	movzbl %al,%eax
c010507b:	85 c0                	test   %eax,%eax
c010507d:	75 2c                	jne    c01050ab <default_free_pages+0x8b>
c010507f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105082:	83 c0 04             	add    $0x4,%eax
c0105085:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c010508c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010508f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105092:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105095:	0f a3 10             	bt     %edx,(%eax)
c0105098:	19 c0                	sbb    %eax,%eax
c010509a:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c010509d:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c01050a1:	0f 95 c0             	setne  %al
c01050a4:	0f b6 c0             	movzbl %al,%eax
c01050a7:	85 c0                	test   %eax,%eax
c01050a9:	74 19                	je     c01050c4 <default_free_pages+0xa4>
c01050ab:	68 d4 96 10 c0       	push   $0xc01096d4
c01050b0:	68 96 96 10 c0       	push   $0xc0109696
c01050b5:	68 9d 00 00 00       	push   $0x9d
c01050ba:	68 ab 96 10 c0       	push   $0xc01096ab
c01050bf:	e8 24 b3 ff ff       	call   c01003e8 <__panic>
        p->flags = 0;
c01050c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050c7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01050ce:	83 ec 08             	sub    $0x8,%esp
c01050d1:	6a 00                	push   $0x0
c01050d3:	ff 75 f4             	pushl  -0xc(%ebp)
c01050d6:	e8 76 fc ff ff       	call   c0104d51 <set_page_ref>
c01050db:	83 c4 10             	add    $0x10,%esp

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01050de:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01050e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050e5:	c1 e0 05             	shl    $0x5,%eax
c01050e8:	89 c2                	mov    %eax,%edx
c01050ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01050ed:	01 d0                	add    %edx,%eax
c01050ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01050f2:	0f 85 5b ff ff ff    	jne    c0105053 <default_free_pages+0x33>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01050f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01050fb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01050fe:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0105101:	8b 45 08             	mov    0x8(%ebp),%eax
c0105104:	83 c0 04             	add    $0x4,%eax
c0105107:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c010510e:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105111:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105114:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105117:	0f ab 10             	bts    %edx,(%eax)
c010511a:	c7 45 e8 e4 30 12 c0 	movl   $0xc01230e4,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105121:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105124:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0105127:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010512a:	e9 fa 00 00 00       	jmp    c0105229 <default_free_pages+0x209>
        p = le2page(le, page_link);
c010512f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105132:	83 e8 0c             	sub    $0xc,%eax
c0105135:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105138:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010513b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010513e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105141:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0105144:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0105147:	8b 45 08             	mov    0x8(%ebp),%eax
c010514a:	8b 40 08             	mov    0x8(%eax),%eax
c010514d:	c1 e0 05             	shl    $0x5,%eax
c0105150:	89 c2                	mov    %eax,%edx
c0105152:	8b 45 08             	mov    0x8(%ebp),%eax
c0105155:	01 d0                	add    %edx,%eax
c0105157:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010515a:	75 5a                	jne    c01051b6 <default_free_pages+0x196>
            base->property += p->property;
c010515c:	8b 45 08             	mov    0x8(%ebp),%eax
c010515f:	8b 50 08             	mov    0x8(%eax),%edx
c0105162:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105165:	8b 40 08             	mov    0x8(%eax),%eax
c0105168:	01 c2                	add    %eax,%edx
c010516a:	8b 45 08             	mov    0x8(%ebp),%eax
c010516d:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0105170:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105173:	83 c0 04             	add    $0x4,%eax
c0105176:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c010517d:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105180:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0105183:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105186:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0105189:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010518c:	83 c0 0c             	add    $0xc,%eax
c010518f:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0105192:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105195:	8b 40 04             	mov    0x4(%eax),%eax
c0105198:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010519b:	8b 12                	mov    (%edx),%edx
c010519d:	89 55 a8             	mov    %edx,-0x58(%ebp)
c01051a0:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01051a3:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01051a6:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01051a9:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01051ac:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01051af:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01051b2:	89 10                	mov    %edx,(%eax)
c01051b4:	eb 73                	jmp    c0105229 <default_free_pages+0x209>
        }
        else if (p + p->property == base) {
c01051b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051b9:	8b 40 08             	mov    0x8(%eax),%eax
c01051bc:	c1 e0 05             	shl    $0x5,%eax
c01051bf:	89 c2                	mov    %eax,%edx
c01051c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051c4:	01 d0                	add    %edx,%eax
c01051c6:	3b 45 08             	cmp    0x8(%ebp),%eax
c01051c9:	75 5e                	jne    c0105229 <default_free_pages+0x209>
            p->property += base->property;
c01051cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051ce:	8b 50 08             	mov    0x8(%eax),%edx
c01051d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01051d4:	8b 40 08             	mov    0x8(%eax),%eax
c01051d7:	01 c2                	add    %eax,%edx
c01051d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051dc:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c01051df:	8b 45 08             	mov    0x8(%ebp),%eax
c01051e2:	83 c0 04             	add    $0x4,%eax
c01051e5:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c01051ec:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01051ef:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01051f2:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01051f5:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c01051f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051fb:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c01051fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105201:	83 c0 0c             	add    $0xc,%eax
c0105204:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0105207:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010520a:	8b 40 04             	mov    0x4(%eax),%eax
c010520d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105210:	8b 12                	mov    (%edx),%edx
c0105212:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0105215:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0105218:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010521b:	8b 55 98             	mov    -0x68(%ebp),%edx
c010521e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105221:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105224:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105227:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0105229:	81 7d f0 e4 30 12 c0 	cmpl   $0xc01230e4,-0x10(%ebp)
c0105230:	0f 85 f9 fe ff ff    	jne    c010512f <default_free_pages+0x10f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0105236:	8b 15 ec 30 12 c0    	mov    0xc01230ec,%edx
c010523c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010523f:	01 d0                	add    %edx,%eax
c0105241:	a3 ec 30 12 c0       	mov    %eax,0xc01230ec
c0105246:	c7 45 d0 e4 30 12 c0 	movl   $0xc01230e4,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010524d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105250:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0105253:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0105256:	eb 5b                	jmp    c01052b3 <default_free_pages+0x293>
        p = le2page(le, page_link);
c0105258:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010525b:	83 e8 0c             	sub    $0xc,%eax
c010525e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0105261:	8b 45 08             	mov    0x8(%ebp),%eax
c0105264:	8b 40 08             	mov    0x8(%eax),%eax
c0105267:	c1 e0 05             	shl    $0x5,%eax
c010526a:	89 c2                	mov    %eax,%edx
c010526c:	8b 45 08             	mov    0x8(%ebp),%eax
c010526f:	01 d0                	add    %edx,%eax
c0105271:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105274:	77 2e                	ja     c01052a4 <default_free_pages+0x284>
            assert(base + base->property != p);
c0105276:	8b 45 08             	mov    0x8(%ebp),%eax
c0105279:	8b 40 08             	mov    0x8(%eax),%eax
c010527c:	c1 e0 05             	shl    $0x5,%eax
c010527f:	89 c2                	mov    %eax,%edx
c0105281:	8b 45 08             	mov    0x8(%ebp),%eax
c0105284:	01 d0                	add    %edx,%eax
c0105286:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105289:	75 33                	jne    c01052be <default_free_pages+0x29e>
c010528b:	68 f9 96 10 c0       	push   $0xc01096f9
c0105290:	68 96 96 10 c0       	push   $0xc0109696
c0105295:	68 b9 00 00 00       	push   $0xb9
c010529a:	68 ab 96 10 c0       	push   $0xc01096ab
c010529f:	e8 44 b1 ff ff       	call   c01003e8 <__panic>
c01052a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052a7:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01052aa:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01052ad:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c01052b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c01052b3:	81 7d f0 e4 30 12 c0 	cmpl   $0xc01230e4,-0x10(%ebp)
c01052ba:	75 9c                	jne    c0105258 <default_free_pages+0x238>
c01052bc:	eb 01                	jmp    c01052bf <default_free_pages+0x29f>
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
c01052be:	90                   	nop
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c01052bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01052c2:	8d 50 0c             	lea    0xc(%eax),%edx
c01052c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052c8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01052cb:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01052ce:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01052d1:	8b 00                	mov    (%eax),%eax
c01052d3:	8b 55 90             	mov    -0x70(%ebp),%edx
c01052d6:	89 55 8c             	mov    %edx,-0x74(%ebp)
c01052d9:	89 45 88             	mov    %eax,-0x78(%ebp)
c01052dc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01052df:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01052e2:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01052e5:	8b 55 8c             	mov    -0x74(%ebp),%edx
c01052e8:	89 10                	mov    %edx,(%eax)
c01052ea:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01052ed:	8b 10                	mov    (%eax),%edx
c01052ef:	8b 45 88             	mov    -0x78(%ebp),%eax
c01052f2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01052f5:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01052f8:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01052fb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01052fe:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105301:	8b 55 88             	mov    -0x78(%ebp),%edx
c0105304:	89 10                	mov    %edx,(%eax)
}
c0105306:	90                   	nop
c0105307:	c9                   	leave  
c0105308:	c3                   	ret    

c0105309 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0105309:	55                   	push   %ebp
c010530a:	89 e5                	mov    %esp,%ebp
    return nr_free;
c010530c:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
}
c0105311:	5d                   	pop    %ebp
c0105312:	c3                   	ret    

c0105313 <basic_check>:

static void
basic_check(void) {
c0105313:	55                   	push   %ebp
c0105314:	89 e5                	mov    %esp,%ebp
c0105316:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0105319:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105320:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105323:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105326:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105329:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c010532c:	83 ec 0c             	sub    $0xc,%esp
c010532f:	6a 01                	push   $0x1
c0105331:	e8 06 0d 00 00       	call   c010603c <alloc_pages>
c0105336:	83 c4 10             	add    $0x10,%esp
c0105339:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010533c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105340:	75 19                	jne    c010535b <basic_check+0x48>
c0105342:	68 14 97 10 c0       	push   $0xc0109714
c0105347:	68 96 96 10 c0       	push   $0xc0109696
c010534c:	68 ca 00 00 00       	push   $0xca
c0105351:	68 ab 96 10 c0       	push   $0xc01096ab
c0105356:	e8 8d b0 ff ff       	call   c01003e8 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010535b:	83 ec 0c             	sub    $0xc,%esp
c010535e:	6a 01                	push   $0x1
c0105360:	e8 d7 0c 00 00       	call   c010603c <alloc_pages>
c0105365:	83 c4 10             	add    $0x10,%esp
c0105368:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010536b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010536f:	75 19                	jne    c010538a <basic_check+0x77>
c0105371:	68 30 97 10 c0       	push   $0xc0109730
c0105376:	68 96 96 10 c0       	push   $0xc0109696
c010537b:	68 cb 00 00 00       	push   $0xcb
c0105380:	68 ab 96 10 c0       	push   $0xc01096ab
c0105385:	e8 5e b0 ff ff       	call   c01003e8 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010538a:	83 ec 0c             	sub    $0xc,%esp
c010538d:	6a 01                	push   $0x1
c010538f:	e8 a8 0c 00 00       	call   c010603c <alloc_pages>
c0105394:	83 c4 10             	add    $0x10,%esp
c0105397:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010539a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010539e:	75 19                	jne    c01053b9 <basic_check+0xa6>
c01053a0:	68 4c 97 10 c0       	push   $0xc010974c
c01053a5:	68 96 96 10 c0       	push   $0xc0109696
c01053aa:	68 cc 00 00 00       	push   $0xcc
c01053af:	68 ab 96 10 c0       	push   $0xc01096ab
c01053b4:	e8 2f b0 ff ff       	call   c01003e8 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01053b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053bc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01053bf:	74 10                	je     c01053d1 <basic_check+0xbe>
c01053c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053c4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01053c7:	74 08                	je     c01053d1 <basic_check+0xbe>
c01053c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053cc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01053cf:	75 19                	jne    c01053ea <basic_check+0xd7>
c01053d1:	68 68 97 10 c0       	push   $0xc0109768
c01053d6:	68 96 96 10 c0       	push   $0xc0109696
c01053db:	68 ce 00 00 00       	push   $0xce
c01053e0:	68 ab 96 10 c0       	push   $0xc01096ab
c01053e5:	e8 fe af ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01053ea:	83 ec 0c             	sub    $0xc,%esp
c01053ed:	ff 75 ec             	pushl  -0x14(%ebp)
c01053f0:	e8 52 f9 ff ff       	call   c0104d47 <page_ref>
c01053f5:	83 c4 10             	add    $0x10,%esp
c01053f8:	85 c0                	test   %eax,%eax
c01053fa:	75 24                	jne    c0105420 <basic_check+0x10d>
c01053fc:	83 ec 0c             	sub    $0xc,%esp
c01053ff:	ff 75 f0             	pushl  -0x10(%ebp)
c0105402:	e8 40 f9 ff ff       	call   c0104d47 <page_ref>
c0105407:	83 c4 10             	add    $0x10,%esp
c010540a:	85 c0                	test   %eax,%eax
c010540c:	75 12                	jne    c0105420 <basic_check+0x10d>
c010540e:	83 ec 0c             	sub    $0xc,%esp
c0105411:	ff 75 f4             	pushl  -0xc(%ebp)
c0105414:	e8 2e f9 ff ff       	call   c0104d47 <page_ref>
c0105419:	83 c4 10             	add    $0x10,%esp
c010541c:	85 c0                	test   %eax,%eax
c010541e:	74 19                	je     c0105439 <basic_check+0x126>
c0105420:	68 8c 97 10 c0       	push   $0xc010978c
c0105425:	68 96 96 10 c0       	push   $0xc0109696
c010542a:	68 cf 00 00 00       	push   $0xcf
c010542f:	68 ab 96 10 c0       	push   $0xc01096ab
c0105434:	e8 af af ff ff       	call   c01003e8 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0105439:	83 ec 0c             	sub    $0xc,%esp
c010543c:	ff 75 ec             	pushl  -0x14(%ebp)
c010543f:	e8 f0 f8 ff ff       	call   c0104d34 <page2pa>
c0105444:	83 c4 10             	add    $0x10,%esp
c0105447:	89 c2                	mov    %eax,%edx
c0105449:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c010544e:	c1 e0 0c             	shl    $0xc,%eax
c0105451:	39 c2                	cmp    %eax,%edx
c0105453:	72 19                	jb     c010546e <basic_check+0x15b>
c0105455:	68 c8 97 10 c0       	push   $0xc01097c8
c010545a:	68 96 96 10 c0       	push   $0xc0109696
c010545f:	68 d1 00 00 00       	push   $0xd1
c0105464:	68 ab 96 10 c0       	push   $0xc01096ab
c0105469:	e8 7a af ff ff       	call   c01003e8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010546e:	83 ec 0c             	sub    $0xc,%esp
c0105471:	ff 75 f0             	pushl  -0x10(%ebp)
c0105474:	e8 bb f8 ff ff       	call   c0104d34 <page2pa>
c0105479:	83 c4 10             	add    $0x10,%esp
c010547c:	89 c2                	mov    %eax,%edx
c010547e:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c0105483:	c1 e0 0c             	shl    $0xc,%eax
c0105486:	39 c2                	cmp    %eax,%edx
c0105488:	72 19                	jb     c01054a3 <basic_check+0x190>
c010548a:	68 e5 97 10 c0       	push   $0xc01097e5
c010548f:	68 96 96 10 c0       	push   $0xc0109696
c0105494:	68 d2 00 00 00       	push   $0xd2
c0105499:	68 ab 96 10 c0       	push   $0xc01096ab
c010549e:	e8 45 af ff ff       	call   c01003e8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01054a3:	83 ec 0c             	sub    $0xc,%esp
c01054a6:	ff 75 f4             	pushl  -0xc(%ebp)
c01054a9:	e8 86 f8 ff ff       	call   c0104d34 <page2pa>
c01054ae:	83 c4 10             	add    $0x10,%esp
c01054b1:	89 c2                	mov    %eax,%edx
c01054b3:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c01054b8:	c1 e0 0c             	shl    $0xc,%eax
c01054bb:	39 c2                	cmp    %eax,%edx
c01054bd:	72 19                	jb     c01054d8 <basic_check+0x1c5>
c01054bf:	68 02 98 10 c0       	push   $0xc0109802
c01054c4:	68 96 96 10 c0       	push   $0xc0109696
c01054c9:	68 d3 00 00 00       	push   $0xd3
c01054ce:	68 ab 96 10 c0       	push   $0xc01096ab
c01054d3:	e8 10 af ff ff       	call   c01003e8 <__panic>

    list_entry_t free_list_store = free_list;
c01054d8:	a1 e4 30 12 c0       	mov    0xc01230e4,%eax
c01054dd:	8b 15 e8 30 12 c0    	mov    0xc01230e8,%edx
c01054e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01054e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01054e9:	c7 45 e4 e4 30 12 c0 	movl   $0xc01230e4,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01054f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01054f6:	89 50 04             	mov    %edx,0x4(%eax)
c01054f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054fc:	8b 50 04             	mov    0x4(%eax),%edx
c01054ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105502:	89 10                	mov    %edx,(%eax)
c0105504:	c7 45 d8 e4 30 12 c0 	movl   $0xc01230e4,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010550b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010550e:	8b 40 04             	mov    0x4(%eax),%eax
c0105511:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105514:	0f 94 c0             	sete   %al
c0105517:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010551a:	85 c0                	test   %eax,%eax
c010551c:	75 19                	jne    c0105537 <basic_check+0x224>
c010551e:	68 1f 98 10 c0       	push   $0xc010981f
c0105523:	68 96 96 10 c0       	push   $0xc0109696
c0105528:	68 d7 00 00 00       	push   $0xd7
c010552d:	68 ab 96 10 c0       	push   $0xc01096ab
c0105532:	e8 b1 ae ff ff       	call   c01003e8 <__panic>

    unsigned int nr_free_store = nr_free;
c0105537:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
c010553c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c010553f:	c7 05 ec 30 12 c0 00 	movl   $0x0,0xc01230ec
c0105546:	00 00 00 

    assert(alloc_page() == NULL);
c0105549:	83 ec 0c             	sub    $0xc,%esp
c010554c:	6a 01                	push   $0x1
c010554e:	e8 e9 0a 00 00       	call   c010603c <alloc_pages>
c0105553:	83 c4 10             	add    $0x10,%esp
c0105556:	85 c0                	test   %eax,%eax
c0105558:	74 19                	je     c0105573 <basic_check+0x260>
c010555a:	68 36 98 10 c0       	push   $0xc0109836
c010555f:	68 96 96 10 c0       	push   $0xc0109696
c0105564:	68 dc 00 00 00       	push   $0xdc
c0105569:	68 ab 96 10 c0       	push   $0xc01096ab
c010556e:	e8 75 ae ff ff       	call   c01003e8 <__panic>

    free_page(p0);
c0105573:	83 ec 08             	sub    $0x8,%esp
c0105576:	6a 01                	push   $0x1
c0105578:	ff 75 ec             	pushl  -0x14(%ebp)
c010557b:	e8 28 0b 00 00       	call   c01060a8 <free_pages>
c0105580:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0105583:	83 ec 08             	sub    $0x8,%esp
c0105586:	6a 01                	push   $0x1
c0105588:	ff 75 f0             	pushl  -0x10(%ebp)
c010558b:	e8 18 0b 00 00       	call   c01060a8 <free_pages>
c0105590:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0105593:	83 ec 08             	sub    $0x8,%esp
c0105596:	6a 01                	push   $0x1
c0105598:	ff 75 f4             	pushl  -0xc(%ebp)
c010559b:	e8 08 0b 00 00       	call   c01060a8 <free_pages>
c01055a0:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
c01055a3:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
c01055a8:	83 f8 03             	cmp    $0x3,%eax
c01055ab:	74 19                	je     c01055c6 <basic_check+0x2b3>
c01055ad:	68 4b 98 10 c0       	push   $0xc010984b
c01055b2:	68 96 96 10 c0       	push   $0xc0109696
c01055b7:	68 e1 00 00 00       	push   $0xe1
c01055bc:	68 ab 96 10 c0       	push   $0xc01096ab
c01055c1:	e8 22 ae ff ff       	call   c01003e8 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01055c6:	83 ec 0c             	sub    $0xc,%esp
c01055c9:	6a 01                	push   $0x1
c01055cb:	e8 6c 0a 00 00       	call   c010603c <alloc_pages>
c01055d0:	83 c4 10             	add    $0x10,%esp
c01055d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01055d6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01055da:	75 19                	jne    c01055f5 <basic_check+0x2e2>
c01055dc:	68 14 97 10 c0       	push   $0xc0109714
c01055e1:	68 96 96 10 c0       	push   $0xc0109696
c01055e6:	68 e3 00 00 00       	push   $0xe3
c01055eb:	68 ab 96 10 c0       	push   $0xc01096ab
c01055f0:	e8 f3 ad ff ff       	call   c01003e8 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01055f5:	83 ec 0c             	sub    $0xc,%esp
c01055f8:	6a 01                	push   $0x1
c01055fa:	e8 3d 0a 00 00       	call   c010603c <alloc_pages>
c01055ff:	83 c4 10             	add    $0x10,%esp
c0105602:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105605:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105609:	75 19                	jne    c0105624 <basic_check+0x311>
c010560b:	68 30 97 10 c0       	push   $0xc0109730
c0105610:	68 96 96 10 c0       	push   $0xc0109696
c0105615:	68 e4 00 00 00       	push   $0xe4
c010561a:	68 ab 96 10 c0       	push   $0xc01096ab
c010561f:	e8 c4 ad ff ff       	call   c01003e8 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105624:	83 ec 0c             	sub    $0xc,%esp
c0105627:	6a 01                	push   $0x1
c0105629:	e8 0e 0a 00 00       	call   c010603c <alloc_pages>
c010562e:	83 c4 10             	add    $0x10,%esp
c0105631:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105634:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105638:	75 19                	jne    c0105653 <basic_check+0x340>
c010563a:	68 4c 97 10 c0       	push   $0xc010974c
c010563f:	68 96 96 10 c0       	push   $0xc0109696
c0105644:	68 e5 00 00 00       	push   $0xe5
c0105649:	68 ab 96 10 c0       	push   $0xc01096ab
c010564e:	e8 95 ad ff ff       	call   c01003e8 <__panic>

    assert(alloc_page() == NULL);
c0105653:	83 ec 0c             	sub    $0xc,%esp
c0105656:	6a 01                	push   $0x1
c0105658:	e8 df 09 00 00       	call   c010603c <alloc_pages>
c010565d:	83 c4 10             	add    $0x10,%esp
c0105660:	85 c0                	test   %eax,%eax
c0105662:	74 19                	je     c010567d <basic_check+0x36a>
c0105664:	68 36 98 10 c0       	push   $0xc0109836
c0105669:	68 96 96 10 c0       	push   $0xc0109696
c010566e:	68 e7 00 00 00       	push   $0xe7
c0105673:	68 ab 96 10 c0       	push   $0xc01096ab
c0105678:	e8 6b ad ff ff       	call   c01003e8 <__panic>

    free_page(p0);
c010567d:	83 ec 08             	sub    $0x8,%esp
c0105680:	6a 01                	push   $0x1
c0105682:	ff 75 ec             	pushl  -0x14(%ebp)
c0105685:	e8 1e 0a 00 00       	call   c01060a8 <free_pages>
c010568a:	83 c4 10             	add    $0x10,%esp
c010568d:	c7 45 e8 e4 30 12 c0 	movl   $0xc01230e4,-0x18(%ebp)
c0105694:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105697:	8b 40 04             	mov    0x4(%eax),%eax
c010569a:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010569d:	0f 94 c0             	sete   %al
c01056a0:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01056a3:	85 c0                	test   %eax,%eax
c01056a5:	74 19                	je     c01056c0 <basic_check+0x3ad>
c01056a7:	68 58 98 10 c0       	push   $0xc0109858
c01056ac:	68 96 96 10 c0       	push   $0xc0109696
c01056b1:	68 ea 00 00 00       	push   $0xea
c01056b6:	68 ab 96 10 c0       	push   $0xc01096ab
c01056bb:	e8 28 ad ff ff       	call   c01003e8 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01056c0:	83 ec 0c             	sub    $0xc,%esp
c01056c3:	6a 01                	push   $0x1
c01056c5:	e8 72 09 00 00       	call   c010603c <alloc_pages>
c01056ca:	83 c4 10             	add    $0x10,%esp
c01056cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01056d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056d3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01056d6:	74 19                	je     c01056f1 <basic_check+0x3de>
c01056d8:	68 70 98 10 c0       	push   $0xc0109870
c01056dd:	68 96 96 10 c0       	push   $0xc0109696
c01056e2:	68 ed 00 00 00       	push   $0xed
c01056e7:	68 ab 96 10 c0       	push   $0xc01096ab
c01056ec:	e8 f7 ac ff ff       	call   c01003e8 <__panic>
    assert(alloc_page() == NULL);
c01056f1:	83 ec 0c             	sub    $0xc,%esp
c01056f4:	6a 01                	push   $0x1
c01056f6:	e8 41 09 00 00       	call   c010603c <alloc_pages>
c01056fb:	83 c4 10             	add    $0x10,%esp
c01056fe:	85 c0                	test   %eax,%eax
c0105700:	74 19                	je     c010571b <basic_check+0x408>
c0105702:	68 36 98 10 c0       	push   $0xc0109836
c0105707:	68 96 96 10 c0       	push   $0xc0109696
c010570c:	68 ee 00 00 00       	push   $0xee
c0105711:	68 ab 96 10 c0       	push   $0xc01096ab
c0105716:	e8 cd ac ff ff       	call   c01003e8 <__panic>

    assert(nr_free == 0);
c010571b:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
c0105720:	85 c0                	test   %eax,%eax
c0105722:	74 19                	je     c010573d <basic_check+0x42a>
c0105724:	68 89 98 10 c0       	push   $0xc0109889
c0105729:	68 96 96 10 c0       	push   $0xc0109696
c010572e:	68 f0 00 00 00       	push   $0xf0
c0105733:	68 ab 96 10 c0       	push   $0xc01096ab
c0105738:	e8 ab ac ff ff       	call   c01003e8 <__panic>
    free_list = free_list_store;
c010573d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105740:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105743:	a3 e4 30 12 c0       	mov    %eax,0xc01230e4
c0105748:	89 15 e8 30 12 c0    	mov    %edx,0xc01230e8
    nr_free = nr_free_store;
c010574e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105751:	a3 ec 30 12 c0       	mov    %eax,0xc01230ec

    free_page(p);
c0105756:	83 ec 08             	sub    $0x8,%esp
c0105759:	6a 01                	push   $0x1
c010575b:	ff 75 dc             	pushl  -0x24(%ebp)
c010575e:	e8 45 09 00 00       	call   c01060a8 <free_pages>
c0105763:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0105766:	83 ec 08             	sub    $0x8,%esp
c0105769:	6a 01                	push   $0x1
c010576b:	ff 75 f0             	pushl  -0x10(%ebp)
c010576e:	e8 35 09 00 00       	call   c01060a8 <free_pages>
c0105773:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0105776:	83 ec 08             	sub    $0x8,%esp
c0105779:	6a 01                	push   $0x1
c010577b:	ff 75 f4             	pushl  -0xc(%ebp)
c010577e:	e8 25 09 00 00       	call   c01060a8 <free_pages>
c0105783:	83 c4 10             	add    $0x10,%esp
}
c0105786:	90                   	nop
c0105787:	c9                   	leave  
c0105788:	c3                   	ret    

c0105789 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0105789:	55                   	push   %ebp
c010578a:	89 e5                	mov    %esp,%ebp
c010578c:	81 ec 88 00 00 00    	sub    $0x88,%esp
    int count = 0, total = 0;
c0105792:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105799:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01057a0:	c7 45 ec e4 30 12 c0 	movl   $0xc01230e4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01057a7:	eb 60                	jmp    c0105809 <default_check+0x80>
        struct Page *p = le2page(le, page_link);
c01057a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057ac:	83 e8 0c             	sub    $0xc,%eax
c01057af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c01057b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057b5:	83 c0 04             	add    $0x4,%eax
c01057b8:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c01057bf:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01057c2:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01057c5:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01057c8:	0f a3 10             	bt     %edx,(%eax)
c01057cb:	19 c0                	sbb    %eax,%eax
c01057cd:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c01057d0:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c01057d4:	0f 95 c0             	setne  %al
c01057d7:	0f b6 c0             	movzbl %al,%eax
c01057da:	85 c0                	test   %eax,%eax
c01057dc:	75 19                	jne    c01057f7 <default_check+0x6e>
c01057de:	68 96 98 10 c0       	push   $0xc0109896
c01057e3:	68 96 96 10 c0       	push   $0xc0109696
c01057e8:	68 01 01 00 00       	push   $0x101
c01057ed:	68 ab 96 10 c0       	push   $0xc01096ab
c01057f2:	e8 f1 ab ff ff       	call   c01003e8 <__panic>
        count ++, total += p->property;
c01057f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01057fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057fe:	8b 50 08             	mov    0x8(%eax),%edx
c0105801:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105804:	01 d0                	add    %edx,%eax
c0105806:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105809:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010580c:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010580f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105812:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105815:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105818:	81 7d ec e4 30 12 c0 	cmpl   $0xc01230e4,-0x14(%ebp)
c010581f:	75 88                	jne    c01057a9 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0105821:	e8 b7 08 00 00       	call   c01060dd <nr_free_pages>
c0105826:	89 c2                	mov    %eax,%edx
c0105828:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010582b:	39 c2                	cmp    %eax,%edx
c010582d:	74 19                	je     c0105848 <default_check+0xbf>
c010582f:	68 a6 98 10 c0       	push   $0xc01098a6
c0105834:	68 96 96 10 c0       	push   $0xc0109696
c0105839:	68 04 01 00 00       	push   $0x104
c010583e:	68 ab 96 10 c0       	push   $0xc01096ab
c0105843:	e8 a0 ab ff ff       	call   c01003e8 <__panic>

    basic_check();
c0105848:	e8 c6 fa ff ff       	call   c0105313 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010584d:	83 ec 0c             	sub    $0xc,%esp
c0105850:	6a 05                	push   $0x5
c0105852:	e8 e5 07 00 00       	call   c010603c <alloc_pages>
c0105857:	83 c4 10             	add    $0x10,%esp
c010585a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c010585d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105861:	75 19                	jne    c010587c <default_check+0xf3>
c0105863:	68 bf 98 10 c0       	push   $0xc01098bf
c0105868:	68 96 96 10 c0       	push   $0xc0109696
c010586d:	68 09 01 00 00       	push   $0x109
c0105872:	68 ab 96 10 c0       	push   $0xc01096ab
c0105877:	e8 6c ab ff ff       	call   c01003e8 <__panic>
    assert(!PageProperty(p0));
c010587c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010587f:	83 c0 04             	add    $0x4,%eax
c0105882:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0105889:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010588c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010588f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105892:	0f a3 10             	bt     %edx,(%eax)
c0105895:	19 c0                	sbb    %eax,%eax
c0105897:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c010589a:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c010589e:	0f 95 c0             	setne  %al
c01058a1:	0f b6 c0             	movzbl %al,%eax
c01058a4:	85 c0                	test   %eax,%eax
c01058a6:	74 19                	je     c01058c1 <default_check+0x138>
c01058a8:	68 ca 98 10 c0       	push   $0xc01098ca
c01058ad:	68 96 96 10 c0       	push   $0xc0109696
c01058b2:	68 0a 01 00 00       	push   $0x10a
c01058b7:	68 ab 96 10 c0       	push   $0xc01096ab
c01058bc:	e8 27 ab ff ff       	call   c01003e8 <__panic>

    list_entry_t free_list_store = free_list;
c01058c1:	a1 e4 30 12 c0       	mov    0xc01230e4,%eax
c01058c6:	8b 15 e8 30 12 c0    	mov    0xc01230e8,%edx
c01058cc:	89 45 80             	mov    %eax,-0x80(%ebp)
c01058cf:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01058d2:	c7 45 d0 e4 30 12 c0 	movl   $0xc01230e4,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01058d9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01058dc:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01058df:	89 50 04             	mov    %edx,0x4(%eax)
c01058e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01058e5:	8b 50 04             	mov    0x4(%eax),%edx
c01058e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01058eb:	89 10                	mov    %edx,(%eax)
c01058ed:	c7 45 d8 e4 30 12 c0 	movl   $0xc01230e4,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01058f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01058f7:	8b 40 04             	mov    0x4(%eax),%eax
c01058fa:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01058fd:	0f 94 c0             	sete   %al
c0105900:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105903:	85 c0                	test   %eax,%eax
c0105905:	75 19                	jne    c0105920 <default_check+0x197>
c0105907:	68 1f 98 10 c0       	push   $0xc010981f
c010590c:	68 96 96 10 c0       	push   $0xc0109696
c0105911:	68 0e 01 00 00       	push   $0x10e
c0105916:	68 ab 96 10 c0       	push   $0xc01096ab
c010591b:	e8 c8 aa ff ff       	call   c01003e8 <__panic>
    assert(alloc_page() == NULL);
c0105920:	83 ec 0c             	sub    $0xc,%esp
c0105923:	6a 01                	push   $0x1
c0105925:	e8 12 07 00 00       	call   c010603c <alloc_pages>
c010592a:	83 c4 10             	add    $0x10,%esp
c010592d:	85 c0                	test   %eax,%eax
c010592f:	74 19                	je     c010594a <default_check+0x1c1>
c0105931:	68 36 98 10 c0       	push   $0xc0109836
c0105936:	68 96 96 10 c0       	push   $0xc0109696
c010593b:	68 0f 01 00 00       	push   $0x10f
c0105940:	68 ab 96 10 c0       	push   $0xc01096ab
c0105945:	e8 9e aa ff ff       	call   c01003e8 <__panic>

    unsigned int nr_free_store = nr_free;
c010594a:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
c010594f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c0105952:	c7 05 ec 30 12 c0 00 	movl   $0x0,0xc01230ec
c0105959:	00 00 00 

    free_pages(p0 + 2, 3);
c010595c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010595f:	83 c0 40             	add    $0x40,%eax
c0105962:	83 ec 08             	sub    $0x8,%esp
c0105965:	6a 03                	push   $0x3
c0105967:	50                   	push   %eax
c0105968:	e8 3b 07 00 00       	call   c01060a8 <free_pages>
c010596d:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
c0105970:	83 ec 0c             	sub    $0xc,%esp
c0105973:	6a 04                	push   $0x4
c0105975:	e8 c2 06 00 00       	call   c010603c <alloc_pages>
c010597a:	83 c4 10             	add    $0x10,%esp
c010597d:	85 c0                	test   %eax,%eax
c010597f:	74 19                	je     c010599a <default_check+0x211>
c0105981:	68 dc 98 10 c0       	push   $0xc01098dc
c0105986:	68 96 96 10 c0       	push   $0xc0109696
c010598b:	68 15 01 00 00       	push   $0x115
c0105990:	68 ab 96 10 c0       	push   $0xc01096ab
c0105995:	e8 4e aa ff ff       	call   c01003e8 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010599a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010599d:	83 c0 40             	add    $0x40,%eax
c01059a0:	83 c0 04             	add    $0x4,%eax
c01059a3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01059aa:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01059ad:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01059b0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01059b3:	0f a3 10             	bt     %edx,(%eax)
c01059b6:	19 c0                	sbb    %eax,%eax
c01059b8:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01059bb:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01059bf:	0f 95 c0             	setne  %al
c01059c2:	0f b6 c0             	movzbl %al,%eax
c01059c5:	85 c0                	test   %eax,%eax
c01059c7:	74 0e                	je     c01059d7 <default_check+0x24e>
c01059c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01059cc:	83 c0 40             	add    $0x40,%eax
c01059cf:	8b 40 08             	mov    0x8(%eax),%eax
c01059d2:	83 f8 03             	cmp    $0x3,%eax
c01059d5:	74 19                	je     c01059f0 <default_check+0x267>
c01059d7:	68 f4 98 10 c0       	push   $0xc01098f4
c01059dc:	68 96 96 10 c0       	push   $0xc0109696
c01059e1:	68 16 01 00 00       	push   $0x116
c01059e6:	68 ab 96 10 c0       	push   $0xc01096ab
c01059eb:	e8 f8 a9 ff ff       	call   c01003e8 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01059f0:	83 ec 0c             	sub    $0xc,%esp
c01059f3:	6a 03                	push   $0x3
c01059f5:	e8 42 06 00 00       	call   c010603c <alloc_pages>
c01059fa:	83 c4 10             	add    $0x10,%esp
c01059fd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0105a00:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0105a04:	75 19                	jne    c0105a1f <default_check+0x296>
c0105a06:	68 20 99 10 c0       	push   $0xc0109920
c0105a0b:	68 96 96 10 c0       	push   $0xc0109696
c0105a10:	68 17 01 00 00       	push   $0x117
c0105a15:	68 ab 96 10 c0       	push   $0xc01096ab
c0105a1a:	e8 c9 a9 ff ff       	call   c01003e8 <__panic>
    assert(alloc_page() == NULL);
c0105a1f:	83 ec 0c             	sub    $0xc,%esp
c0105a22:	6a 01                	push   $0x1
c0105a24:	e8 13 06 00 00       	call   c010603c <alloc_pages>
c0105a29:	83 c4 10             	add    $0x10,%esp
c0105a2c:	85 c0                	test   %eax,%eax
c0105a2e:	74 19                	je     c0105a49 <default_check+0x2c0>
c0105a30:	68 36 98 10 c0       	push   $0xc0109836
c0105a35:	68 96 96 10 c0       	push   $0xc0109696
c0105a3a:	68 18 01 00 00       	push   $0x118
c0105a3f:	68 ab 96 10 c0       	push   $0xc01096ab
c0105a44:	e8 9f a9 ff ff       	call   c01003e8 <__panic>
    assert(p0 + 2 == p1);
c0105a49:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105a4c:	83 c0 40             	add    $0x40,%eax
c0105a4f:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0105a52:	74 19                	je     c0105a6d <default_check+0x2e4>
c0105a54:	68 3e 99 10 c0       	push   $0xc010993e
c0105a59:	68 96 96 10 c0       	push   $0xc0109696
c0105a5e:	68 19 01 00 00       	push   $0x119
c0105a63:	68 ab 96 10 c0       	push   $0xc01096ab
c0105a68:	e8 7b a9 ff ff       	call   c01003e8 <__panic>

    p2 = p0 + 1;
c0105a6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105a70:	83 c0 20             	add    $0x20,%eax
c0105a73:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c0105a76:	83 ec 08             	sub    $0x8,%esp
c0105a79:	6a 01                	push   $0x1
c0105a7b:	ff 75 dc             	pushl  -0x24(%ebp)
c0105a7e:	e8 25 06 00 00       	call   c01060a8 <free_pages>
c0105a83:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
c0105a86:	83 ec 08             	sub    $0x8,%esp
c0105a89:	6a 03                	push   $0x3
c0105a8b:	ff 75 c4             	pushl  -0x3c(%ebp)
c0105a8e:	e8 15 06 00 00       	call   c01060a8 <free_pages>
c0105a93:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
c0105a96:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105a99:	83 c0 04             	add    $0x4,%eax
c0105a9c:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0105aa3:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105aa6:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0105aa9:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105aac:	0f a3 10             	bt     %edx,(%eax)
c0105aaf:	19 c0                	sbb    %eax,%eax
c0105ab1:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0105ab4:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0105ab8:	0f 95 c0             	setne  %al
c0105abb:	0f b6 c0             	movzbl %al,%eax
c0105abe:	85 c0                	test   %eax,%eax
c0105ac0:	74 0b                	je     c0105acd <default_check+0x344>
c0105ac2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ac5:	8b 40 08             	mov    0x8(%eax),%eax
c0105ac8:	83 f8 01             	cmp    $0x1,%eax
c0105acb:	74 19                	je     c0105ae6 <default_check+0x35d>
c0105acd:	68 4c 99 10 c0       	push   $0xc010994c
c0105ad2:	68 96 96 10 c0       	push   $0xc0109696
c0105ad7:	68 1e 01 00 00       	push   $0x11e
c0105adc:	68 ab 96 10 c0       	push   $0xc01096ab
c0105ae1:	e8 02 a9 ff ff       	call   c01003e8 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105ae6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105ae9:	83 c0 04             	add    $0x4,%eax
c0105aec:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0105af3:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105af6:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105af9:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105afc:	0f a3 10             	bt     %edx,(%eax)
c0105aff:	19 c0                	sbb    %eax,%eax
c0105b01:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c0105b04:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c0105b08:	0f 95 c0             	setne  %al
c0105b0b:	0f b6 c0             	movzbl %al,%eax
c0105b0e:	85 c0                	test   %eax,%eax
c0105b10:	74 0b                	je     c0105b1d <default_check+0x394>
c0105b12:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105b15:	8b 40 08             	mov    0x8(%eax),%eax
c0105b18:	83 f8 03             	cmp    $0x3,%eax
c0105b1b:	74 19                	je     c0105b36 <default_check+0x3ad>
c0105b1d:	68 74 99 10 c0       	push   $0xc0109974
c0105b22:	68 96 96 10 c0       	push   $0xc0109696
c0105b27:	68 1f 01 00 00       	push   $0x11f
c0105b2c:	68 ab 96 10 c0       	push   $0xc01096ab
c0105b31:	e8 b2 a8 ff ff       	call   c01003e8 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0105b36:	83 ec 0c             	sub    $0xc,%esp
c0105b39:	6a 01                	push   $0x1
c0105b3b:	e8 fc 04 00 00       	call   c010603c <alloc_pages>
c0105b40:	83 c4 10             	add    $0x10,%esp
c0105b43:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105b46:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105b49:	83 e8 20             	sub    $0x20,%eax
c0105b4c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105b4f:	74 19                	je     c0105b6a <default_check+0x3e1>
c0105b51:	68 9a 99 10 c0       	push   $0xc010999a
c0105b56:	68 96 96 10 c0       	push   $0xc0109696
c0105b5b:	68 21 01 00 00       	push   $0x121
c0105b60:	68 ab 96 10 c0       	push   $0xc01096ab
c0105b65:	e8 7e a8 ff ff       	call   c01003e8 <__panic>
    free_page(p0);
c0105b6a:	83 ec 08             	sub    $0x8,%esp
c0105b6d:	6a 01                	push   $0x1
c0105b6f:	ff 75 dc             	pushl  -0x24(%ebp)
c0105b72:	e8 31 05 00 00       	call   c01060a8 <free_pages>
c0105b77:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0105b7a:	83 ec 0c             	sub    $0xc,%esp
c0105b7d:	6a 02                	push   $0x2
c0105b7f:	e8 b8 04 00 00       	call   c010603c <alloc_pages>
c0105b84:	83 c4 10             	add    $0x10,%esp
c0105b87:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105b8a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105b8d:	83 c0 20             	add    $0x20,%eax
c0105b90:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105b93:	74 19                	je     c0105bae <default_check+0x425>
c0105b95:	68 b8 99 10 c0       	push   $0xc01099b8
c0105b9a:	68 96 96 10 c0       	push   $0xc0109696
c0105b9f:	68 23 01 00 00       	push   $0x123
c0105ba4:	68 ab 96 10 c0       	push   $0xc01096ab
c0105ba9:	e8 3a a8 ff ff       	call   c01003e8 <__panic>

    free_pages(p0, 2);
c0105bae:	83 ec 08             	sub    $0x8,%esp
c0105bb1:	6a 02                	push   $0x2
c0105bb3:	ff 75 dc             	pushl  -0x24(%ebp)
c0105bb6:	e8 ed 04 00 00       	call   c01060a8 <free_pages>
c0105bbb:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0105bbe:	83 ec 08             	sub    $0x8,%esp
c0105bc1:	6a 01                	push   $0x1
c0105bc3:	ff 75 c0             	pushl  -0x40(%ebp)
c0105bc6:	e8 dd 04 00 00       	call   c01060a8 <free_pages>
c0105bcb:	83 c4 10             	add    $0x10,%esp

    assert((p0 = alloc_pages(5)) != NULL);
c0105bce:	83 ec 0c             	sub    $0xc,%esp
c0105bd1:	6a 05                	push   $0x5
c0105bd3:	e8 64 04 00 00       	call   c010603c <alloc_pages>
c0105bd8:	83 c4 10             	add    $0x10,%esp
c0105bdb:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105bde:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105be2:	75 19                	jne    c0105bfd <default_check+0x474>
c0105be4:	68 d8 99 10 c0       	push   $0xc01099d8
c0105be9:	68 96 96 10 c0       	push   $0xc0109696
c0105bee:	68 28 01 00 00       	push   $0x128
c0105bf3:	68 ab 96 10 c0       	push   $0xc01096ab
c0105bf8:	e8 eb a7 ff ff       	call   c01003e8 <__panic>
    assert(alloc_page() == NULL);
c0105bfd:	83 ec 0c             	sub    $0xc,%esp
c0105c00:	6a 01                	push   $0x1
c0105c02:	e8 35 04 00 00       	call   c010603c <alloc_pages>
c0105c07:	83 c4 10             	add    $0x10,%esp
c0105c0a:	85 c0                	test   %eax,%eax
c0105c0c:	74 19                	je     c0105c27 <default_check+0x49e>
c0105c0e:	68 36 98 10 c0       	push   $0xc0109836
c0105c13:	68 96 96 10 c0       	push   $0xc0109696
c0105c18:	68 29 01 00 00       	push   $0x129
c0105c1d:	68 ab 96 10 c0       	push   $0xc01096ab
c0105c22:	e8 c1 a7 ff ff       	call   c01003e8 <__panic>

    assert(nr_free == 0);
c0105c27:	a1 ec 30 12 c0       	mov    0xc01230ec,%eax
c0105c2c:	85 c0                	test   %eax,%eax
c0105c2e:	74 19                	je     c0105c49 <default_check+0x4c0>
c0105c30:	68 89 98 10 c0       	push   $0xc0109889
c0105c35:	68 96 96 10 c0       	push   $0xc0109696
c0105c3a:	68 2b 01 00 00       	push   $0x12b
c0105c3f:	68 ab 96 10 c0       	push   $0xc01096ab
c0105c44:	e8 9f a7 ff ff       	call   c01003e8 <__panic>
    nr_free = nr_free_store;
c0105c49:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105c4c:	a3 ec 30 12 c0       	mov    %eax,0xc01230ec

    free_list = free_list_store;
c0105c51:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105c54:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105c57:	a3 e4 30 12 c0       	mov    %eax,0xc01230e4
c0105c5c:	89 15 e8 30 12 c0    	mov    %edx,0xc01230e8
    free_pages(p0, 5);
c0105c62:	83 ec 08             	sub    $0x8,%esp
c0105c65:	6a 05                	push   $0x5
c0105c67:	ff 75 dc             	pushl  -0x24(%ebp)
c0105c6a:	e8 39 04 00 00       	call   c01060a8 <free_pages>
c0105c6f:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
c0105c72:	c7 45 ec e4 30 12 c0 	movl   $0xc01230e4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105c79:	eb 1d                	jmp    c0105c98 <default_check+0x50f>
        struct Page *p = le2page(le, page_link);
c0105c7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c7e:	83 e8 0c             	sub    $0xc,%eax
c0105c81:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c0105c84:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105c88:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105c8b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105c8e:	8b 40 08             	mov    0x8(%eax),%eax
c0105c91:	29 c2                	sub    %eax,%edx
c0105c93:	89 d0                	mov    %edx,%eax
c0105c95:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c9b:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105c9e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105ca1:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105ca4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ca7:	81 7d ec e4 30 12 c0 	cmpl   $0xc01230e4,-0x14(%ebp)
c0105cae:	75 cb                	jne    c0105c7b <default_check+0x4f2>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0105cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105cb4:	74 19                	je     c0105ccf <default_check+0x546>
c0105cb6:	68 f6 99 10 c0       	push   $0xc01099f6
c0105cbb:	68 96 96 10 c0       	push   $0xc0109696
c0105cc0:	68 36 01 00 00       	push   $0x136
c0105cc5:	68 ab 96 10 c0       	push   $0xc01096ab
c0105cca:	e8 19 a7 ff ff       	call   c01003e8 <__panic>
    assert(total == 0);
c0105ccf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105cd3:	74 19                	je     c0105cee <default_check+0x565>
c0105cd5:	68 01 9a 10 c0       	push   $0xc0109a01
c0105cda:	68 96 96 10 c0       	push   $0xc0109696
c0105cdf:	68 37 01 00 00       	push   $0x137
c0105ce4:	68 ab 96 10 c0       	push   $0xc01096ab
c0105ce9:	e8 fa a6 ff ff       	call   c01003e8 <__panic>
}
c0105cee:	90                   	nop
c0105cef:	c9                   	leave  
c0105cf0:	c3                   	ret    

c0105cf1 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0105cf1:	55                   	push   %ebp
c0105cf2:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0105cf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cf7:	8b 15 f8 30 12 c0    	mov    0xc01230f8,%edx
c0105cfd:	29 d0                	sub    %edx,%eax
c0105cff:	c1 f8 05             	sar    $0x5,%eax
}
c0105d02:	5d                   	pop    %ebp
c0105d03:	c3                   	ret    

c0105d04 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0105d04:	55                   	push   %ebp
c0105d05:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0105d07:	ff 75 08             	pushl  0x8(%ebp)
c0105d0a:	e8 e2 ff ff ff       	call   c0105cf1 <page2ppn>
c0105d0f:	83 c4 04             	add    $0x4,%esp
c0105d12:	c1 e0 0c             	shl    $0xc,%eax
}
c0105d15:	c9                   	leave  
c0105d16:	c3                   	ret    

c0105d17 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0105d17:	55                   	push   %ebp
c0105d18:	89 e5                	mov    %esp,%ebp
c0105d1a:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0105d1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d20:	c1 e8 0c             	shr    $0xc,%eax
c0105d23:	89 c2                	mov    %eax,%edx
c0105d25:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c0105d2a:	39 c2                	cmp    %eax,%edx
c0105d2c:	72 14                	jb     c0105d42 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0105d2e:	83 ec 04             	sub    $0x4,%esp
c0105d31:	68 3c 9a 10 c0       	push   $0xc0109a3c
c0105d36:	6a 5b                	push   $0x5b
c0105d38:	68 5b 9a 10 c0       	push   $0xc0109a5b
c0105d3d:	e8 a6 a6 ff ff       	call   c01003e8 <__panic>
    }
    return &pages[PPN(pa)];
c0105d42:	a1 f8 30 12 c0       	mov    0xc01230f8,%eax
c0105d47:	8b 55 08             	mov    0x8(%ebp),%edx
c0105d4a:	c1 ea 0c             	shr    $0xc,%edx
c0105d4d:	c1 e2 05             	shl    $0x5,%edx
c0105d50:	01 d0                	add    %edx,%eax
}
c0105d52:	c9                   	leave  
c0105d53:	c3                   	ret    

c0105d54 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0105d54:	55                   	push   %ebp
c0105d55:	89 e5                	mov    %esp,%ebp
c0105d57:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0105d5a:	ff 75 08             	pushl  0x8(%ebp)
c0105d5d:	e8 a2 ff ff ff       	call   c0105d04 <page2pa>
c0105d62:	83 c4 04             	add    $0x4,%esp
c0105d65:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d6b:	c1 e8 0c             	shr    $0xc,%eax
c0105d6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d71:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c0105d76:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105d79:	72 14                	jb     c0105d8f <page2kva+0x3b>
c0105d7b:	ff 75 f4             	pushl  -0xc(%ebp)
c0105d7e:	68 6c 9a 10 c0       	push   $0xc0109a6c
c0105d83:	6a 62                	push   $0x62
c0105d85:	68 5b 9a 10 c0       	push   $0xc0109a5b
c0105d8a:	e8 59 a6 ff ff       	call   c01003e8 <__panic>
c0105d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d92:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0105d97:	c9                   	leave  
c0105d98:	c3                   	ret    

c0105d99 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0105d99:	55                   	push   %ebp
c0105d9a:	89 e5                	mov    %esp,%ebp
c0105d9c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c0105d9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105da5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105dac:	77 14                	ja     c0105dc2 <kva2page+0x29>
c0105dae:	ff 75 f4             	pushl  -0xc(%ebp)
c0105db1:	68 90 9a 10 c0       	push   $0xc0109a90
c0105db6:	6a 67                	push   $0x67
c0105db8:	68 5b 9a 10 c0       	push   $0xc0109a5b
c0105dbd:	e8 26 a6 ff ff       	call   c01003e8 <__panic>
c0105dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dc5:	05 00 00 00 40       	add    $0x40000000,%eax
c0105dca:	83 ec 0c             	sub    $0xc,%esp
c0105dcd:	50                   	push   %eax
c0105dce:	e8 44 ff ff ff       	call   c0105d17 <pa2page>
c0105dd3:	83 c4 10             	add    $0x10,%esp
}
c0105dd6:	c9                   	leave  
c0105dd7:	c3                   	ret    

c0105dd8 <pte2page>:

static inline struct Page *
pte2page(pte_t pte) {
c0105dd8:	55                   	push   %ebp
c0105dd9:	89 e5                	mov    %esp,%ebp
c0105ddb:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c0105dde:	8b 45 08             	mov    0x8(%ebp),%eax
c0105de1:	83 e0 01             	and    $0x1,%eax
c0105de4:	85 c0                	test   %eax,%eax
c0105de6:	75 14                	jne    c0105dfc <pte2page+0x24>
        panic("pte2page called with invalid pte");
c0105de8:	83 ec 04             	sub    $0x4,%esp
c0105deb:	68 b4 9a 10 c0       	push   $0xc0109ab4
c0105df0:	6a 6d                	push   $0x6d
c0105df2:	68 5b 9a 10 c0       	push   $0xc0109a5b
c0105df7:	e8 ec a5 ff ff       	call   c01003e8 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0105dfc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105e04:	83 ec 0c             	sub    $0xc,%esp
c0105e07:	50                   	push   %eax
c0105e08:	e8 0a ff ff ff       	call   c0105d17 <pa2page>
c0105e0d:	83 c4 10             	add    $0x10,%esp
}
c0105e10:	c9                   	leave  
c0105e11:	c3                   	ret    

c0105e12 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0105e12:	55                   	push   %ebp
c0105e13:	89 e5                	mov    %esp,%ebp
c0105e15:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c0105e18:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105e20:	83 ec 0c             	sub    $0xc,%esp
c0105e23:	50                   	push   %eax
c0105e24:	e8 ee fe ff ff       	call   c0105d17 <pa2page>
c0105e29:	83 c4 10             	add    $0x10,%esp
}
c0105e2c:	c9                   	leave  
c0105e2d:	c3                   	ret    

c0105e2e <page_ref>:

static inline int
page_ref(struct Page *page) {
c0105e2e:	55                   	push   %ebp
c0105e2f:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0105e31:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e34:	8b 00                	mov    (%eax),%eax
}
c0105e36:	5d                   	pop    %ebp
c0105e37:	c3                   	ret    

c0105e38 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0105e38:	55                   	push   %ebp
c0105e39:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0105e3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105e41:	89 10                	mov    %edx,(%eax)
}
c0105e43:	90                   	nop
c0105e44:	5d                   	pop    %ebp
c0105e45:	c3                   	ret    

c0105e46 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0105e46:	55                   	push   %ebp
c0105e47:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0105e49:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e4c:	8b 00                	mov    (%eax),%eax
c0105e4e:	8d 50 01             	lea    0x1(%eax),%edx
c0105e51:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e54:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0105e56:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e59:	8b 00                	mov    (%eax),%eax
}
c0105e5b:	5d                   	pop    %ebp
c0105e5c:	c3                   	ret    

c0105e5d <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0105e5d:	55                   	push   %ebp
c0105e5e:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0105e60:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e63:	8b 00                	mov    (%eax),%eax
c0105e65:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e68:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e6b:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0105e6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e70:	8b 00                	mov    (%eax),%eax
}
c0105e72:	5d                   	pop    %ebp
c0105e73:	c3                   	ret    

c0105e74 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0105e74:	55                   	push   %ebp
c0105e75:	89 e5                	mov    %esp,%ebp
c0105e77:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0105e7a:	9c                   	pushf  
c0105e7b:	58                   	pop    %eax
c0105e7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0105e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0105e82:	25 00 02 00 00       	and    $0x200,%eax
c0105e87:	85 c0                	test   %eax,%eax
c0105e89:	74 0c                	je     c0105e97 <__intr_save+0x23>
        intr_disable();
c0105e8b:	e8 39 c2 ff ff       	call   c01020c9 <intr_disable>
        return 1;
c0105e90:	b8 01 00 00 00       	mov    $0x1,%eax
c0105e95:	eb 05                	jmp    c0105e9c <__intr_save+0x28>
    }
    return 0;
c0105e97:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105e9c:	c9                   	leave  
c0105e9d:	c3                   	ret    

c0105e9e <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0105e9e:	55                   	push   %ebp
c0105e9f:	89 e5                	mov    %esp,%ebp
c0105ea1:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0105ea4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105ea8:	74 05                	je     c0105eaf <__intr_restore+0x11>
        intr_enable();
c0105eaa:	e8 13 c2 ff ff       	call   c01020c2 <intr_enable>
    }
}
c0105eaf:	90                   	nop
c0105eb0:	c9                   	leave  
c0105eb1:	c3                   	ret    

c0105eb2 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0105eb2:	55                   	push   %ebp
c0105eb3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0105eb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eb8:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0105ebb:	b8 23 00 00 00       	mov    $0x23,%eax
c0105ec0:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0105ec2:	b8 23 00 00 00       	mov    $0x23,%eax
c0105ec7:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0105ec9:	b8 10 00 00 00       	mov    $0x10,%eax
c0105ece:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0105ed0:	b8 10 00 00 00       	mov    $0x10,%eax
c0105ed5:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0105ed7:	b8 10 00 00 00       	mov    $0x10,%eax
c0105edc:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0105ede:	ea e5 5e 10 c0 08 00 	ljmp   $0x8,$0xc0105ee5
}
c0105ee5:	90                   	nop
c0105ee6:	5d                   	pop    %ebp
c0105ee7:	c3                   	ret    

c0105ee8 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0105ee8:	55                   	push   %ebp
c0105ee9:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0105eeb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eee:	a3 a4 2f 12 c0       	mov    %eax,0xc0122fa4
}
c0105ef3:	90                   	nop
c0105ef4:	5d                   	pop    %ebp
c0105ef5:	c3                   	ret    

c0105ef6 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0105ef6:	55                   	push   %ebp
c0105ef7:	89 e5                	mov    %esp,%ebp
c0105ef9:	83 ec 10             	sub    $0x10,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0105efc:	b8 00 f0 11 c0       	mov    $0xc011f000,%eax
c0105f01:	50                   	push   %eax
c0105f02:	e8 e1 ff ff ff       	call   c0105ee8 <load_esp0>
c0105f07:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
c0105f0a:	66 c7 05 a8 2f 12 c0 	movw   $0x10,0xc0122fa8
c0105f11:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0105f13:	66 c7 05 48 fa 11 c0 	movw   $0x68,0xc011fa48
c0105f1a:	68 00 
c0105f1c:	b8 a0 2f 12 c0       	mov    $0xc0122fa0,%eax
c0105f21:	66 a3 4a fa 11 c0    	mov    %ax,0xc011fa4a
c0105f27:	b8 a0 2f 12 c0       	mov    $0xc0122fa0,%eax
c0105f2c:	c1 e8 10             	shr    $0x10,%eax
c0105f2f:	a2 4c fa 11 c0       	mov    %al,0xc011fa4c
c0105f34:	0f b6 05 4d fa 11 c0 	movzbl 0xc011fa4d,%eax
c0105f3b:	83 e0 f0             	and    $0xfffffff0,%eax
c0105f3e:	83 c8 09             	or     $0x9,%eax
c0105f41:	a2 4d fa 11 c0       	mov    %al,0xc011fa4d
c0105f46:	0f b6 05 4d fa 11 c0 	movzbl 0xc011fa4d,%eax
c0105f4d:	83 e0 ef             	and    $0xffffffef,%eax
c0105f50:	a2 4d fa 11 c0       	mov    %al,0xc011fa4d
c0105f55:	0f b6 05 4d fa 11 c0 	movzbl 0xc011fa4d,%eax
c0105f5c:	83 e0 9f             	and    $0xffffff9f,%eax
c0105f5f:	a2 4d fa 11 c0       	mov    %al,0xc011fa4d
c0105f64:	0f b6 05 4d fa 11 c0 	movzbl 0xc011fa4d,%eax
c0105f6b:	83 c8 80             	or     $0xffffff80,%eax
c0105f6e:	a2 4d fa 11 c0       	mov    %al,0xc011fa4d
c0105f73:	0f b6 05 4e fa 11 c0 	movzbl 0xc011fa4e,%eax
c0105f7a:	83 e0 f0             	and    $0xfffffff0,%eax
c0105f7d:	a2 4e fa 11 c0       	mov    %al,0xc011fa4e
c0105f82:	0f b6 05 4e fa 11 c0 	movzbl 0xc011fa4e,%eax
c0105f89:	83 e0 ef             	and    $0xffffffef,%eax
c0105f8c:	a2 4e fa 11 c0       	mov    %al,0xc011fa4e
c0105f91:	0f b6 05 4e fa 11 c0 	movzbl 0xc011fa4e,%eax
c0105f98:	83 e0 df             	and    $0xffffffdf,%eax
c0105f9b:	a2 4e fa 11 c0       	mov    %al,0xc011fa4e
c0105fa0:	0f b6 05 4e fa 11 c0 	movzbl 0xc011fa4e,%eax
c0105fa7:	83 c8 40             	or     $0x40,%eax
c0105faa:	a2 4e fa 11 c0       	mov    %al,0xc011fa4e
c0105faf:	0f b6 05 4e fa 11 c0 	movzbl 0xc011fa4e,%eax
c0105fb6:	83 e0 7f             	and    $0x7f,%eax
c0105fb9:	a2 4e fa 11 c0       	mov    %al,0xc011fa4e
c0105fbe:	b8 a0 2f 12 c0       	mov    $0xc0122fa0,%eax
c0105fc3:	c1 e8 18             	shr    $0x18,%eax
c0105fc6:	a2 4f fa 11 c0       	mov    %al,0xc011fa4f

    // reload all segment registers
    lgdt(&gdt_pd);
c0105fcb:	68 50 fa 11 c0       	push   $0xc011fa50
c0105fd0:	e8 dd fe ff ff       	call   c0105eb2 <lgdt>
c0105fd5:	83 c4 04             	add    $0x4,%esp
c0105fd8:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0105fde:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0105fe2:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0105fe5:	90                   	nop
c0105fe6:	c9                   	leave  
c0105fe7:	c3                   	ret    

c0105fe8 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0105fe8:	55                   	push   %ebp
c0105fe9:	89 e5                	mov    %esp,%ebp
c0105feb:	83 ec 08             	sub    $0x8,%esp
    pmm_manager = &default_pmm_manager;
c0105fee:	c7 05 f0 30 12 c0 20 	movl   $0xc0109a20,0xc01230f0
c0105ff5:	9a 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0105ff8:	a1 f0 30 12 c0       	mov    0xc01230f0,%eax
c0105ffd:	8b 00                	mov    (%eax),%eax
c0105fff:	83 ec 08             	sub    $0x8,%esp
c0106002:	50                   	push   %eax
c0106003:	68 e0 9a 10 c0       	push   $0xc0109ae0
c0106008:	e8 75 a2 ff ff       	call   c0100282 <cprintf>
c010600d:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
c0106010:	a1 f0 30 12 c0       	mov    0xc01230f0,%eax
c0106015:	8b 40 04             	mov    0x4(%eax),%eax
c0106018:	ff d0                	call   *%eax
}
c010601a:	90                   	nop
c010601b:	c9                   	leave  
c010601c:	c3                   	ret    

c010601d <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c010601d:	55                   	push   %ebp
c010601e:	89 e5                	mov    %esp,%ebp
c0106020:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->init_memmap(base, n);
c0106023:	a1 f0 30 12 c0       	mov    0xc01230f0,%eax
c0106028:	8b 40 08             	mov    0x8(%eax),%eax
c010602b:	83 ec 08             	sub    $0x8,%esp
c010602e:	ff 75 0c             	pushl  0xc(%ebp)
c0106031:	ff 75 08             	pushl  0x8(%ebp)
c0106034:	ff d0                	call   *%eax
c0106036:	83 c4 10             	add    $0x10,%esp
}
c0106039:	90                   	nop
c010603a:	c9                   	leave  
c010603b:	c3                   	ret    

c010603c <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010603c:	55                   	push   %ebp
c010603d:	89 e5                	mov    %esp,%ebp
c010603f:	83 ec 18             	sub    $0x18,%esp
    struct Page *page=NULL;
c0106042:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0106049:	e8 26 fe ff ff       	call   c0105e74 <__intr_save>
c010604e:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0106051:	a1 f0 30 12 c0       	mov    0xc01230f0,%eax
c0106056:	8b 40 0c             	mov    0xc(%eax),%eax
c0106059:	83 ec 0c             	sub    $0xc,%esp
c010605c:	ff 75 08             	pushl  0x8(%ebp)
c010605f:	ff d0                	call   *%eax
c0106061:	83 c4 10             	add    $0x10,%esp
c0106064:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0106067:	83 ec 0c             	sub    $0xc,%esp
c010606a:	ff 75 f0             	pushl  -0x10(%ebp)
c010606d:	e8 2c fe ff ff       	call   c0105e9e <__intr_restore>
c0106072:	83 c4 10             	add    $0x10,%esp

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0106075:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106079:	75 28                	jne    c01060a3 <alloc_pages+0x67>
c010607b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c010607f:	77 22                	ja     c01060a3 <alloc_pages+0x67>
c0106081:	a1 68 2f 12 c0       	mov    0xc0122f68,%eax
c0106086:	85 c0                	test   %eax,%eax
c0106088:	74 19                	je     c01060a3 <alloc_pages+0x67>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c010608a:	8b 55 08             	mov    0x8(%ebp),%edx
c010608d:	a1 10 30 12 c0       	mov    0xc0123010,%eax
c0106092:	83 ec 04             	sub    $0x4,%esp
c0106095:	6a 00                	push   $0x0
c0106097:	52                   	push   %edx
c0106098:	50                   	push   %eax
c0106099:	e8 53 e3 ff ff       	call   c01043f1 <swap_out>
c010609e:	83 c4 10             	add    $0x10,%esp
    }
c01060a1:	eb a6                	jmp    c0106049 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01060a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01060a6:	c9                   	leave  
c01060a7:	c3                   	ret    

c01060a8 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01060a8:	55                   	push   %ebp
c01060a9:	89 e5                	mov    %esp,%ebp
c01060ab:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01060ae:	e8 c1 fd ff ff       	call   c0105e74 <__intr_save>
c01060b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01060b6:	a1 f0 30 12 c0       	mov    0xc01230f0,%eax
c01060bb:	8b 40 10             	mov    0x10(%eax),%eax
c01060be:	83 ec 08             	sub    $0x8,%esp
c01060c1:	ff 75 0c             	pushl  0xc(%ebp)
c01060c4:	ff 75 08             	pushl  0x8(%ebp)
c01060c7:	ff d0                	call   *%eax
c01060c9:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c01060cc:	83 ec 0c             	sub    $0xc,%esp
c01060cf:	ff 75 f4             	pushl  -0xc(%ebp)
c01060d2:	e8 c7 fd ff ff       	call   c0105e9e <__intr_restore>
c01060d7:	83 c4 10             	add    $0x10,%esp
}
c01060da:	90                   	nop
c01060db:	c9                   	leave  
c01060dc:	c3                   	ret    

c01060dd <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01060dd:	55                   	push   %ebp
c01060de:	89 e5                	mov    %esp,%ebp
c01060e0:	83 ec 18             	sub    $0x18,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01060e3:	e8 8c fd ff ff       	call   c0105e74 <__intr_save>
c01060e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01060eb:	a1 f0 30 12 c0       	mov    0xc01230f0,%eax
c01060f0:	8b 40 14             	mov    0x14(%eax),%eax
c01060f3:	ff d0                	call   *%eax
c01060f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01060f8:	83 ec 0c             	sub    $0xc,%esp
c01060fb:	ff 75 f4             	pushl  -0xc(%ebp)
c01060fe:	e8 9b fd ff ff       	call   c0105e9e <__intr_restore>
c0106103:	83 c4 10             	add    $0x10,%esp
    return ret;
c0106106:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0106109:	c9                   	leave  
c010610a:	c3                   	ret    

c010610b <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010610b:	55                   	push   %ebp
c010610c:	89 e5                	mov    %esp,%ebp
c010610e:	57                   	push   %edi
c010610f:	56                   	push   %esi
c0106110:	53                   	push   %ebx
c0106111:	83 ec 7c             	sub    $0x7c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0106114:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010611b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0106122:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0106129:	83 ec 0c             	sub    $0xc,%esp
c010612c:	68 f7 9a 10 c0       	push   $0xc0109af7
c0106131:	e8 4c a1 ff ff       	call   c0100282 <cprintf>
c0106136:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106139:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106140:	e9 fc 00 00 00       	jmp    c0106241 <page_init+0x136>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106145:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106148:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010614b:	89 d0                	mov    %edx,%eax
c010614d:	c1 e0 02             	shl    $0x2,%eax
c0106150:	01 d0                	add    %edx,%eax
c0106152:	c1 e0 02             	shl    $0x2,%eax
c0106155:	01 c8                	add    %ecx,%eax
c0106157:	8b 50 08             	mov    0x8(%eax),%edx
c010615a:	8b 40 04             	mov    0x4(%eax),%eax
c010615d:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106160:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0106163:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106166:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106169:	89 d0                	mov    %edx,%eax
c010616b:	c1 e0 02             	shl    $0x2,%eax
c010616e:	01 d0                	add    %edx,%eax
c0106170:	c1 e0 02             	shl    $0x2,%eax
c0106173:	01 c8                	add    %ecx,%eax
c0106175:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106178:	8b 58 10             	mov    0x10(%eax),%ebx
c010617b:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010617e:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106181:	01 c8                	add    %ecx,%eax
c0106183:	11 da                	adc    %ebx,%edx
c0106185:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0106188:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c010618b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010618e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106191:	89 d0                	mov    %edx,%eax
c0106193:	c1 e0 02             	shl    $0x2,%eax
c0106196:	01 d0                	add    %edx,%eax
c0106198:	c1 e0 02             	shl    $0x2,%eax
c010619b:	01 c8                	add    %ecx,%eax
c010619d:	83 c0 14             	add    $0x14,%eax
c01061a0:	8b 00                	mov    (%eax),%eax
c01061a2:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01061a5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01061a8:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01061ab:	83 c0 ff             	add    $0xffffffff,%eax
c01061ae:	83 d2 ff             	adc    $0xffffffff,%edx
c01061b1:	89 c1                	mov    %eax,%ecx
c01061b3:	89 d3                	mov    %edx,%ebx
c01061b5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01061b8:	89 55 80             	mov    %edx,-0x80(%ebp)
c01061bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01061be:	89 d0                	mov    %edx,%eax
c01061c0:	c1 e0 02             	shl    $0x2,%eax
c01061c3:	01 d0                	add    %edx,%eax
c01061c5:	c1 e0 02             	shl    $0x2,%eax
c01061c8:	03 45 80             	add    -0x80(%ebp),%eax
c01061cb:	8b 50 10             	mov    0x10(%eax),%edx
c01061ce:	8b 40 0c             	mov    0xc(%eax),%eax
c01061d1:	ff 75 84             	pushl  -0x7c(%ebp)
c01061d4:	53                   	push   %ebx
c01061d5:	51                   	push   %ecx
c01061d6:	ff 75 bc             	pushl  -0x44(%ebp)
c01061d9:	ff 75 b8             	pushl  -0x48(%ebp)
c01061dc:	52                   	push   %edx
c01061dd:	50                   	push   %eax
c01061de:	68 04 9b 10 c0       	push   $0xc0109b04
c01061e3:	e8 9a a0 ff ff       	call   c0100282 <cprintf>
c01061e8:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01061eb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01061ee:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01061f1:	89 d0                	mov    %edx,%eax
c01061f3:	c1 e0 02             	shl    $0x2,%eax
c01061f6:	01 d0                	add    %edx,%eax
c01061f8:	c1 e0 02             	shl    $0x2,%eax
c01061fb:	01 c8                	add    %ecx,%eax
c01061fd:	83 c0 14             	add    $0x14,%eax
c0106200:	8b 00                	mov    (%eax),%eax
c0106202:	83 f8 01             	cmp    $0x1,%eax
c0106205:	75 36                	jne    c010623d <page_init+0x132>
            if (maxpa < end && begin < KMEMSIZE) {
c0106207:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010620a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010620d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106210:	77 2b                	ja     c010623d <page_init+0x132>
c0106212:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106215:	72 05                	jb     c010621c <page_init+0x111>
c0106217:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c010621a:	73 21                	jae    c010623d <page_init+0x132>
c010621c:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106220:	77 1b                	ja     c010623d <page_init+0x132>
c0106222:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106226:	72 09                	jb     c0106231 <page_init+0x126>
c0106228:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c010622f:	77 0c                	ja     c010623d <page_init+0x132>
                maxpa = end;
c0106231:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106234:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106237:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010623a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c010623d:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0106241:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106244:	8b 00                	mov    (%eax),%eax
c0106246:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106249:	0f 8f f6 fe ff ff    	jg     c0106145 <page_init+0x3a>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010624f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106253:	72 1d                	jb     c0106272 <page_init+0x167>
c0106255:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106259:	77 09                	ja     c0106264 <page_init+0x159>
c010625b:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0106262:	76 0e                	jbe    c0106272 <page_init+0x167>
        maxpa = KMEMSIZE;
c0106264:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010626b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0106272:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106275:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106278:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010627c:	c1 ea 0c             	shr    $0xc,%edx
c010627f:	a3 80 2f 12 c0       	mov    %eax,0xc0122f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0106284:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c010628b:	b8 fc 30 12 c0       	mov    $0xc01230fc,%eax
c0106290:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106293:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106296:	01 d0                	add    %edx,%eax
c0106298:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010629b:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010629e:	ba 00 00 00 00       	mov    $0x0,%edx
c01062a3:	f7 75 ac             	divl   -0x54(%ebp)
c01062a6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01062a9:	29 d0                	sub    %edx,%eax
c01062ab:	a3 f8 30 12 c0       	mov    %eax,0xc01230f8

    for (i = 0; i < npage; i ++) {
c01062b0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01062b7:	eb 27                	jmp    c01062e0 <page_init+0x1d5>
        SetPageReserved(pages + i);
c01062b9:	a1 f8 30 12 c0       	mov    0xc01230f8,%eax
c01062be:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01062c1:	c1 e2 05             	shl    $0x5,%edx
c01062c4:	01 d0                	add    %edx,%eax
c01062c6:	83 c0 04             	add    $0x4,%eax
c01062c9:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c01062d0:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01062d3:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01062d6:	8b 55 90             	mov    -0x70(%ebp),%edx
c01062d9:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c01062dc:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01062e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01062e3:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c01062e8:	39 c2                	cmp    %eax,%edx
c01062ea:	72 cd                	jb     c01062b9 <page_init+0x1ae>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01062ec:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c01062f1:	c1 e0 05             	shl    $0x5,%eax
c01062f4:	89 c2                	mov    %eax,%edx
c01062f6:	a1 f8 30 12 c0       	mov    0xc01230f8,%eax
c01062fb:	01 d0                	add    %edx,%eax
c01062fd:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0106300:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0106307:	77 17                	ja     c0106320 <page_init+0x215>
c0106309:	ff 75 a4             	pushl  -0x5c(%ebp)
c010630c:	68 90 9a 10 c0       	push   $0xc0109a90
c0106311:	68 e9 00 00 00       	push   $0xe9
c0106316:	68 34 9b 10 c0       	push   $0xc0109b34
c010631b:	e8 c8 a0 ff ff       	call   c01003e8 <__panic>
c0106320:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106323:	05 00 00 00 40       	add    $0x40000000,%eax
c0106328:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010632b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106332:	e9 69 01 00 00       	jmp    c01064a0 <page_init+0x395>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106337:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010633a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010633d:	89 d0                	mov    %edx,%eax
c010633f:	c1 e0 02             	shl    $0x2,%eax
c0106342:	01 d0                	add    %edx,%eax
c0106344:	c1 e0 02             	shl    $0x2,%eax
c0106347:	01 c8                	add    %ecx,%eax
c0106349:	8b 50 08             	mov    0x8(%eax),%edx
c010634c:	8b 40 04             	mov    0x4(%eax),%eax
c010634f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106352:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106355:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106358:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010635b:	89 d0                	mov    %edx,%eax
c010635d:	c1 e0 02             	shl    $0x2,%eax
c0106360:	01 d0                	add    %edx,%eax
c0106362:	c1 e0 02             	shl    $0x2,%eax
c0106365:	01 c8                	add    %ecx,%eax
c0106367:	8b 48 0c             	mov    0xc(%eax),%ecx
c010636a:	8b 58 10             	mov    0x10(%eax),%ebx
c010636d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106370:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106373:	01 c8                	add    %ecx,%eax
c0106375:	11 da                	adc    %ebx,%edx
c0106377:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010637a:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010637d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106380:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106383:	89 d0                	mov    %edx,%eax
c0106385:	c1 e0 02             	shl    $0x2,%eax
c0106388:	01 d0                	add    %edx,%eax
c010638a:	c1 e0 02             	shl    $0x2,%eax
c010638d:	01 c8                	add    %ecx,%eax
c010638f:	83 c0 14             	add    $0x14,%eax
c0106392:	8b 00                	mov    (%eax),%eax
c0106394:	83 f8 01             	cmp    $0x1,%eax
c0106397:	0f 85 ff 00 00 00    	jne    c010649c <page_init+0x391>
            if (begin < freemem) {
c010639d:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01063a0:	ba 00 00 00 00       	mov    $0x0,%edx
c01063a5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01063a8:	72 17                	jb     c01063c1 <page_init+0x2b6>
c01063aa:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01063ad:	77 05                	ja     c01063b4 <page_init+0x2a9>
c01063af:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01063b2:	76 0d                	jbe    c01063c1 <page_init+0x2b6>
                begin = freemem;
c01063b4:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01063b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01063ba:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01063c1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01063c5:	72 1d                	jb     c01063e4 <page_init+0x2d9>
c01063c7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01063cb:	77 09                	ja     c01063d6 <page_init+0x2cb>
c01063cd:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01063d4:	76 0e                	jbe    c01063e4 <page_init+0x2d9>
                end = KMEMSIZE;
c01063d6:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01063dd:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01063e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01063e7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01063ea:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01063ed:	0f 87 a9 00 00 00    	ja     c010649c <page_init+0x391>
c01063f3:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01063f6:	72 09                	jb     c0106401 <page_init+0x2f6>
c01063f8:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01063fb:	0f 83 9b 00 00 00    	jae    c010649c <page_init+0x391>
                begin = ROUNDUP(begin, PGSIZE);
c0106401:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0106408:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010640b:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010640e:	01 d0                	add    %edx,%eax
c0106410:	83 e8 01             	sub    $0x1,%eax
c0106413:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106416:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106419:	ba 00 00 00 00       	mov    $0x0,%edx
c010641e:	f7 75 9c             	divl   -0x64(%ebp)
c0106421:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106424:	29 d0                	sub    %edx,%eax
c0106426:	ba 00 00 00 00       	mov    $0x0,%edx
c010642b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010642e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0106431:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106434:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0106437:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010643a:	ba 00 00 00 00       	mov    $0x0,%edx
c010643f:	89 c3                	mov    %eax,%ebx
c0106441:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0106447:	89 de                	mov    %ebx,%esi
c0106449:	89 d0                	mov    %edx,%eax
c010644b:	83 e0 00             	and    $0x0,%eax
c010644e:	89 c7                	mov    %eax,%edi
c0106450:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0106453:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0106456:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106459:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010645c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010645f:	77 3b                	ja     c010649c <page_init+0x391>
c0106461:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106464:	72 05                	jb     c010646b <page_init+0x360>
c0106466:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0106469:	73 31                	jae    c010649c <page_init+0x391>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010646b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010646e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106471:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0106474:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0106477:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010647b:	c1 ea 0c             	shr    $0xc,%edx
c010647e:	89 c3                	mov    %eax,%ebx
c0106480:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106483:	83 ec 0c             	sub    $0xc,%esp
c0106486:	50                   	push   %eax
c0106487:	e8 8b f8 ff ff       	call   c0105d17 <pa2page>
c010648c:	83 c4 10             	add    $0x10,%esp
c010648f:	83 ec 08             	sub    $0x8,%esp
c0106492:	53                   	push   %ebx
c0106493:	50                   	push   %eax
c0106494:	e8 84 fb ff ff       	call   c010601d <init_memmap>
c0106499:	83 c4 10             	add    $0x10,%esp
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c010649c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01064a0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01064a3:	8b 00                	mov    (%eax),%eax
c01064a5:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01064a8:	0f 8f 89 fe ff ff    	jg     c0106337 <page_init+0x22c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01064ae:	90                   	nop
c01064af:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01064b2:	5b                   	pop    %ebx
c01064b3:	5e                   	pop    %esi
c01064b4:	5f                   	pop    %edi
c01064b5:	5d                   	pop    %ebp
c01064b6:	c3                   	ret    

c01064b7 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01064b7:	55                   	push   %ebp
c01064b8:	89 e5                	mov    %esp,%ebp
c01064ba:	83 ec 28             	sub    $0x28,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01064bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064c0:	33 45 14             	xor    0x14(%ebp),%eax
c01064c3:	25 ff 0f 00 00       	and    $0xfff,%eax
c01064c8:	85 c0                	test   %eax,%eax
c01064ca:	74 19                	je     c01064e5 <boot_map_segment+0x2e>
c01064cc:	68 42 9b 10 c0       	push   $0xc0109b42
c01064d1:	68 59 9b 10 c0       	push   $0xc0109b59
c01064d6:	68 07 01 00 00       	push   $0x107
c01064db:	68 34 9b 10 c0       	push   $0xc0109b34
c01064e0:	e8 03 9f ff ff       	call   c01003e8 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01064e5:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01064ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064ef:	25 ff 0f 00 00       	and    $0xfff,%eax
c01064f4:	89 c2                	mov    %eax,%edx
c01064f6:	8b 45 10             	mov    0x10(%ebp),%eax
c01064f9:	01 c2                	add    %eax,%edx
c01064fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064fe:	01 d0                	add    %edx,%eax
c0106500:	83 e8 01             	sub    $0x1,%eax
c0106503:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106506:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106509:	ba 00 00 00 00       	mov    $0x0,%edx
c010650e:	f7 75 f0             	divl   -0x10(%ebp)
c0106511:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106514:	29 d0                	sub    %edx,%eax
c0106516:	c1 e8 0c             	shr    $0xc,%eax
c0106519:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010651c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010651f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106522:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106525:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010652a:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010652d:	8b 45 14             	mov    0x14(%ebp),%eax
c0106530:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106533:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106536:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010653b:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010653e:	eb 57                	jmp    c0106597 <boot_map_segment+0xe0>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0106540:	83 ec 04             	sub    $0x4,%esp
c0106543:	6a 01                	push   $0x1
c0106545:	ff 75 0c             	pushl  0xc(%ebp)
c0106548:	ff 75 08             	pushl  0x8(%ebp)
c010654b:	e8 53 01 00 00       	call   c01066a3 <get_pte>
c0106550:	83 c4 10             	add    $0x10,%esp
c0106553:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0106556:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010655a:	75 19                	jne    c0106575 <boot_map_segment+0xbe>
c010655c:	68 6e 9b 10 c0       	push   $0xc0109b6e
c0106561:	68 59 9b 10 c0       	push   $0xc0109b59
c0106566:	68 0d 01 00 00       	push   $0x10d
c010656b:	68 34 9b 10 c0       	push   $0xc0109b34
c0106570:	e8 73 9e ff ff       	call   c01003e8 <__panic>
        *ptep = pa | PTE_P | perm;
c0106575:	8b 45 14             	mov    0x14(%ebp),%eax
c0106578:	0b 45 18             	or     0x18(%ebp),%eax
c010657b:	83 c8 01             	or     $0x1,%eax
c010657e:	89 c2                	mov    %eax,%edx
c0106580:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106583:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106585:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0106589:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0106590:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0106597:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010659b:	75 a3                	jne    c0106540 <boot_map_segment+0x89>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c010659d:	90                   	nop
c010659e:	c9                   	leave  
c010659f:	c3                   	ret    

c01065a0 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01065a0:	55                   	push   %ebp
c01065a1:	89 e5                	mov    %esp,%ebp
c01065a3:	83 ec 18             	sub    $0x18,%esp
    struct Page *p = alloc_page();
c01065a6:	83 ec 0c             	sub    $0xc,%esp
c01065a9:	6a 01                	push   $0x1
c01065ab:	e8 8c fa ff ff       	call   c010603c <alloc_pages>
c01065b0:	83 c4 10             	add    $0x10,%esp
c01065b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01065b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01065ba:	75 17                	jne    c01065d3 <boot_alloc_page+0x33>
        panic("boot_alloc_page failed.\n");
c01065bc:	83 ec 04             	sub    $0x4,%esp
c01065bf:	68 7b 9b 10 c0       	push   $0xc0109b7b
c01065c4:	68 19 01 00 00       	push   $0x119
c01065c9:	68 34 9b 10 c0       	push   $0xc0109b34
c01065ce:	e8 15 9e ff ff       	call   c01003e8 <__panic>
    }
    return page2kva(p);
c01065d3:	83 ec 0c             	sub    $0xc,%esp
c01065d6:	ff 75 f4             	pushl  -0xc(%ebp)
c01065d9:	e8 76 f7 ff ff       	call   c0105d54 <page2kva>
c01065de:	83 c4 10             	add    $0x10,%esp
}
c01065e1:	c9                   	leave  
c01065e2:	c3                   	ret    

c01065e3 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01065e3:	55                   	push   %ebp
c01065e4:	89 e5                	mov    %esp,%ebp
c01065e6:	83 ec 18             	sub    $0x18,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01065e9:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c01065ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01065f1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01065f8:	77 17                	ja     c0106611 <pmm_init+0x2e>
c01065fa:	ff 75 f4             	pushl  -0xc(%ebp)
c01065fd:	68 90 9a 10 c0       	push   $0xc0109a90
c0106602:	68 23 01 00 00       	push   $0x123
c0106607:	68 34 9b 10 c0       	push   $0xc0109b34
c010660c:	e8 d7 9d ff ff       	call   c01003e8 <__panic>
c0106611:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106614:	05 00 00 00 40       	add    $0x40000000,%eax
c0106619:	a3 f4 30 12 c0       	mov    %eax,0xc01230f4
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010661e:	e8 c5 f9 ff ff       	call   c0105fe8 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0106623:	e8 e3 fa ff ff       	call   c010610b <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0106628:	e8 38 04 00 00       	call   c0106a65 <check_alloc_page>

    check_pgdir();
c010662d:	e8 56 04 00 00       	call   c0106a88 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0106632:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106637:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c010663d:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106642:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106645:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010664c:	77 17                	ja     c0106665 <pmm_init+0x82>
c010664e:	ff 75 f0             	pushl  -0x10(%ebp)
c0106651:	68 90 9a 10 c0       	push   $0xc0109a90
c0106656:	68 39 01 00 00       	push   $0x139
c010665b:	68 34 9b 10 c0       	push   $0xc0109b34
c0106660:	e8 83 9d ff ff       	call   c01003e8 <__panic>
c0106665:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106668:	05 00 00 00 40       	add    $0x40000000,%eax
c010666d:	83 c8 03             	or     $0x3,%eax
c0106670:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0106672:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106677:	83 ec 0c             	sub    $0xc,%esp
c010667a:	6a 02                	push   $0x2
c010667c:	6a 00                	push   $0x0
c010667e:	68 00 00 00 38       	push   $0x38000000
c0106683:	68 00 00 00 c0       	push   $0xc0000000
c0106688:	50                   	push   %eax
c0106689:	e8 29 fe ff ff       	call   c01064b7 <boot_map_segment>
c010668e:	83 c4 20             	add    $0x20,%esp

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0106691:	e8 60 f8 ff ff       	call   c0105ef6 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0106696:	e8 53 09 00 00       	call   c0106fee <check_boot_pgdir>

    print_pgdir();
c010669b:	e8 49 0d 00 00       	call   c01073e9 <print_pgdir>

}
c01066a0:	90                   	nop
c01066a1:	c9                   	leave  
c01066a2:	c3                   	ret    

c01066a3 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01066a3:	55                   	push   %ebp
c01066a4:	89 e5                	mov    %esp,%ebp
c01066a6:	83 ec 28             	sub    $0x28,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c01066a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01066ac:	c1 e8 16             	shr    $0x16,%eax
c01066af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01066b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01066b9:	01 d0                	add    %edx,%eax
c01066bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01066be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066c1:	8b 00                	mov    (%eax),%eax
c01066c3:	83 e0 01             	and    $0x1,%eax
c01066c6:	85 c0                	test   %eax,%eax
c01066c8:	0f 85 9f 00 00 00    	jne    c010676d <get_pte+0xca>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01066ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01066d2:	74 16                	je     c01066ea <get_pte+0x47>
c01066d4:	83 ec 0c             	sub    $0xc,%esp
c01066d7:	6a 01                	push   $0x1
c01066d9:	e8 5e f9 ff ff       	call   c010603c <alloc_pages>
c01066de:	83 c4 10             	add    $0x10,%esp
c01066e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01066e8:	75 0a                	jne    c01066f4 <get_pte+0x51>
            return NULL;
c01066ea:	b8 00 00 00 00       	mov    $0x0,%eax
c01066ef:	e9 ca 00 00 00       	jmp    c01067be <get_pte+0x11b>
        }
        set_page_ref(page, 1);
c01066f4:	83 ec 08             	sub    $0x8,%esp
c01066f7:	6a 01                	push   $0x1
c01066f9:	ff 75 f0             	pushl  -0x10(%ebp)
c01066fc:	e8 37 f7 ff ff       	call   c0105e38 <set_page_ref>
c0106701:	83 c4 10             	add    $0x10,%esp
        uintptr_t pa = page2pa(page);
c0106704:	83 ec 0c             	sub    $0xc,%esp
c0106707:	ff 75 f0             	pushl  -0x10(%ebp)
c010670a:	e8 f5 f5 ff ff       	call   c0105d04 <page2pa>
c010670f:	83 c4 10             	add    $0x10,%esp
c0106712:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0106715:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106718:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010671b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010671e:	c1 e8 0c             	shr    $0xc,%eax
c0106721:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106724:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c0106729:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010672c:	72 17                	jb     c0106745 <get_pte+0xa2>
c010672e:	ff 75 e8             	pushl  -0x18(%ebp)
c0106731:	68 6c 9a 10 c0       	push   $0xc0109a6c
c0106736:	68 7f 01 00 00       	push   $0x17f
c010673b:	68 34 9b 10 c0       	push   $0xc0109b34
c0106740:	e8 a3 9c ff ff       	call   c01003e8 <__panic>
c0106745:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106748:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010674d:	83 ec 04             	sub    $0x4,%esp
c0106750:	68 00 10 00 00       	push   $0x1000
c0106755:	6a 00                	push   $0x0
c0106757:	50                   	push   %eax
c0106758:	e8 8a 13 00 00       	call   c0107ae7 <memset>
c010675d:	83 c4 10             	add    $0x10,%esp
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0106760:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106763:	83 c8 07             	or     $0x7,%eax
c0106766:	89 c2                	mov    %eax,%edx
c0106768:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010676b:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010676d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106770:	8b 00                	mov    (%eax),%eax
c0106772:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106777:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010677a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010677d:	c1 e8 0c             	shr    $0xc,%eax
c0106780:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106783:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c0106788:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010678b:	72 17                	jb     c01067a4 <get_pte+0x101>
c010678d:	ff 75 e0             	pushl  -0x20(%ebp)
c0106790:	68 6c 9a 10 c0       	push   $0xc0109a6c
c0106795:	68 82 01 00 00       	push   $0x182
c010679a:	68 34 9b 10 c0       	push   $0xc0109b34
c010679f:	e8 44 9c ff ff       	call   c01003e8 <__panic>
c01067a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01067a7:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01067ac:	89 c2                	mov    %eax,%edx
c01067ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01067b1:	c1 e8 0c             	shr    $0xc,%eax
c01067b4:	25 ff 03 00 00       	and    $0x3ff,%eax
c01067b9:	c1 e0 02             	shl    $0x2,%eax
c01067bc:	01 d0                	add    %edx,%eax
}
c01067be:	c9                   	leave  
c01067bf:	c3                   	ret    

c01067c0 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01067c0:	55                   	push   %ebp
c01067c1:	89 e5                	mov    %esp,%ebp
c01067c3:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01067c6:	83 ec 04             	sub    $0x4,%esp
c01067c9:	6a 00                	push   $0x0
c01067cb:	ff 75 0c             	pushl  0xc(%ebp)
c01067ce:	ff 75 08             	pushl  0x8(%ebp)
c01067d1:	e8 cd fe ff ff       	call   c01066a3 <get_pte>
c01067d6:	83 c4 10             	add    $0x10,%esp
c01067d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01067dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01067e0:	74 08                	je     c01067ea <get_page+0x2a>
        *ptep_store = ptep;
c01067e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01067e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01067e8:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01067ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01067ee:	74 1f                	je     c010680f <get_page+0x4f>
c01067f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067f3:	8b 00                	mov    (%eax),%eax
c01067f5:	83 e0 01             	and    $0x1,%eax
c01067f8:	85 c0                	test   %eax,%eax
c01067fa:	74 13                	je     c010680f <get_page+0x4f>
        return pte2page(*ptep);
c01067fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067ff:	8b 00                	mov    (%eax),%eax
c0106801:	83 ec 0c             	sub    $0xc,%esp
c0106804:	50                   	push   %eax
c0106805:	e8 ce f5 ff ff       	call   c0105dd8 <pte2page>
c010680a:	83 c4 10             	add    $0x10,%esp
c010680d:	eb 05                	jmp    c0106814 <get_page+0x54>
    }
    return NULL;
c010680f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106814:	c9                   	leave  
c0106815:	c3                   	ret    

c0106816 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0106816:	55                   	push   %ebp
c0106817:	89 e5                	mov    %esp,%ebp
c0106819:	83 ec 18             	sub    $0x18,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010681c:	8b 45 10             	mov    0x10(%ebp),%eax
c010681f:	8b 00                	mov    (%eax),%eax
c0106821:	83 e0 01             	and    $0x1,%eax
c0106824:	85 c0                	test   %eax,%eax
c0106826:	74 50                	je     c0106878 <page_remove_pte+0x62>
        struct Page *page = pte2page(*ptep);
c0106828:	8b 45 10             	mov    0x10(%ebp),%eax
c010682b:	8b 00                	mov    (%eax),%eax
c010682d:	83 ec 0c             	sub    $0xc,%esp
c0106830:	50                   	push   %eax
c0106831:	e8 a2 f5 ff ff       	call   c0105dd8 <pte2page>
c0106836:	83 c4 10             	add    $0x10,%esp
c0106839:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c010683c:	83 ec 0c             	sub    $0xc,%esp
c010683f:	ff 75 f4             	pushl  -0xc(%ebp)
c0106842:	e8 16 f6 ff ff       	call   c0105e5d <page_ref_dec>
c0106847:	83 c4 10             	add    $0x10,%esp
c010684a:	85 c0                	test   %eax,%eax
c010684c:	75 10                	jne    c010685e <page_remove_pte+0x48>
            free_page(page);
c010684e:	83 ec 08             	sub    $0x8,%esp
c0106851:	6a 01                	push   $0x1
c0106853:	ff 75 f4             	pushl  -0xc(%ebp)
c0106856:	e8 4d f8 ff ff       	call   c01060a8 <free_pages>
c010685b:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0;
c010685e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106861:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0106867:	83 ec 08             	sub    $0x8,%esp
c010686a:	ff 75 0c             	pushl  0xc(%ebp)
c010686d:	ff 75 08             	pushl  0x8(%ebp)
c0106870:	e8 f8 00 00 00       	call   c010696d <tlb_invalidate>
c0106875:	83 c4 10             	add    $0x10,%esp
    }
}
c0106878:	90                   	nop
c0106879:	c9                   	leave  
c010687a:	c3                   	ret    

c010687b <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010687b:	55                   	push   %ebp
c010687c:	89 e5                	mov    %esp,%ebp
c010687e:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106881:	83 ec 04             	sub    $0x4,%esp
c0106884:	6a 00                	push   $0x0
c0106886:	ff 75 0c             	pushl  0xc(%ebp)
c0106889:	ff 75 08             	pushl  0x8(%ebp)
c010688c:	e8 12 fe ff ff       	call   c01066a3 <get_pte>
c0106891:	83 c4 10             	add    $0x10,%esp
c0106894:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0106897:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010689b:	74 14                	je     c01068b1 <page_remove+0x36>
        page_remove_pte(pgdir, la, ptep);
c010689d:	83 ec 04             	sub    $0x4,%esp
c01068a0:	ff 75 f4             	pushl  -0xc(%ebp)
c01068a3:	ff 75 0c             	pushl  0xc(%ebp)
c01068a6:	ff 75 08             	pushl  0x8(%ebp)
c01068a9:	e8 68 ff ff ff       	call   c0106816 <page_remove_pte>
c01068ae:	83 c4 10             	add    $0x10,%esp
    }
}
c01068b1:	90                   	nop
c01068b2:	c9                   	leave  
c01068b3:	c3                   	ret    

c01068b4 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01068b4:	55                   	push   %ebp
c01068b5:	89 e5                	mov    %esp,%ebp
c01068b7:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01068ba:	83 ec 04             	sub    $0x4,%esp
c01068bd:	6a 01                	push   $0x1
c01068bf:	ff 75 10             	pushl  0x10(%ebp)
c01068c2:	ff 75 08             	pushl  0x8(%ebp)
c01068c5:	e8 d9 fd ff ff       	call   c01066a3 <get_pte>
c01068ca:	83 c4 10             	add    $0x10,%esp
c01068cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01068d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01068d4:	75 0a                	jne    c01068e0 <page_insert+0x2c>
        return -E_NO_MEM;
c01068d6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01068db:	e9 8b 00 00 00       	jmp    c010696b <page_insert+0xb7>
    }
    page_ref_inc(page);
c01068e0:	83 ec 0c             	sub    $0xc,%esp
c01068e3:	ff 75 0c             	pushl  0xc(%ebp)
c01068e6:	e8 5b f5 ff ff       	call   c0105e46 <page_ref_inc>
c01068eb:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {
c01068ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068f1:	8b 00                	mov    (%eax),%eax
c01068f3:	83 e0 01             	and    $0x1,%eax
c01068f6:	85 c0                	test   %eax,%eax
c01068f8:	74 40                	je     c010693a <page_insert+0x86>
        struct Page *p = pte2page(*ptep);
c01068fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068fd:	8b 00                	mov    (%eax),%eax
c01068ff:	83 ec 0c             	sub    $0xc,%esp
c0106902:	50                   	push   %eax
c0106903:	e8 d0 f4 ff ff       	call   c0105dd8 <pte2page>
c0106908:	83 c4 10             	add    $0x10,%esp
c010690b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010690e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106911:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106914:	75 10                	jne    c0106926 <page_insert+0x72>
            page_ref_dec(page);
c0106916:	83 ec 0c             	sub    $0xc,%esp
c0106919:	ff 75 0c             	pushl  0xc(%ebp)
c010691c:	e8 3c f5 ff ff       	call   c0105e5d <page_ref_dec>
c0106921:	83 c4 10             	add    $0x10,%esp
c0106924:	eb 14                	jmp    c010693a <page_insert+0x86>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0106926:	83 ec 04             	sub    $0x4,%esp
c0106929:	ff 75 f4             	pushl  -0xc(%ebp)
c010692c:	ff 75 10             	pushl  0x10(%ebp)
c010692f:	ff 75 08             	pushl  0x8(%ebp)
c0106932:	e8 df fe ff ff       	call   c0106816 <page_remove_pte>
c0106937:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010693a:	83 ec 0c             	sub    $0xc,%esp
c010693d:	ff 75 0c             	pushl  0xc(%ebp)
c0106940:	e8 bf f3 ff ff       	call   c0105d04 <page2pa>
c0106945:	83 c4 10             	add    $0x10,%esp
c0106948:	0b 45 14             	or     0x14(%ebp),%eax
c010694b:	83 c8 01             	or     $0x1,%eax
c010694e:	89 c2                	mov    %eax,%edx
c0106950:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106953:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0106955:	83 ec 08             	sub    $0x8,%esp
c0106958:	ff 75 10             	pushl  0x10(%ebp)
c010695b:	ff 75 08             	pushl  0x8(%ebp)
c010695e:	e8 0a 00 00 00       	call   c010696d <tlb_invalidate>
c0106963:	83 c4 10             	add    $0x10,%esp
    return 0;
c0106966:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010696b:	c9                   	leave  
c010696c:	c3                   	ret    

c010696d <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010696d:	55                   	push   %ebp
c010696e:	89 e5                	mov    %esp,%ebp
c0106970:	83 ec 18             	sub    $0x18,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0106973:	0f 20 d8             	mov    %cr3,%eax
c0106976:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c0106979:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c010697c:	8b 45 08             	mov    0x8(%ebp),%eax
c010697f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106982:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0106989:	77 17                	ja     c01069a2 <tlb_invalidate+0x35>
c010698b:	ff 75 f0             	pushl  -0x10(%ebp)
c010698e:	68 90 9a 10 c0       	push   $0xc0109a90
c0106993:	68 e4 01 00 00       	push   $0x1e4
c0106998:	68 34 9b 10 c0       	push   $0xc0109b34
c010699d:	e8 46 9a ff ff       	call   c01003e8 <__panic>
c01069a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069a5:	05 00 00 00 40       	add    $0x40000000,%eax
c01069aa:	39 c2                	cmp    %eax,%edx
c01069ac:	75 0c                	jne    c01069ba <tlb_invalidate+0x4d>
        invlpg((void *)la);
c01069ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01069b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069b7:	0f 01 38             	invlpg (%eax)
    }
}
c01069ba:	90                   	nop
c01069bb:	c9                   	leave  
c01069bc:	c3                   	ret    

c01069bd <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01069bd:	55                   	push   %ebp
c01069be:	89 e5                	mov    %esp,%ebp
c01069c0:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_page();
c01069c3:	83 ec 0c             	sub    $0xc,%esp
c01069c6:	6a 01                	push   $0x1
c01069c8:	e8 6f f6 ff ff       	call   c010603c <alloc_pages>
c01069cd:	83 c4 10             	add    $0x10,%esp
c01069d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01069d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01069d7:	0f 84 83 00 00 00    	je     c0106a60 <pgdir_alloc_page+0xa3>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01069dd:	ff 75 10             	pushl  0x10(%ebp)
c01069e0:	ff 75 0c             	pushl  0xc(%ebp)
c01069e3:	ff 75 f4             	pushl  -0xc(%ebp)
c01069e6:	ff 75 08             	pushl  0x8(%ebp)
c01069e9:	e8 c6 fe ff ff       	call   c01068b4 <page_insert>
c01069ee:	83 c4 10             	add    $0x10,%esp
c01069f1:	85 c0                	test   %eax,%eax
c01069f3:	74 17                	je     c0106a0c <pgdir_alloc_page+0x4f>
            free_page(page);
c01069f5:	83 ec 08             	sub    $0x8,%esp
c01069f8:	6a 01                	push   $0x1
c01069fa:	ff 75 f4             	pushl  -0xc(%ebp)
c01069fd:	e8 a6 f6 ff ff       	call   c01060a8 <free_pages>
c0106a02:	83 c4 10             	add    $0x10,%esp
            return NULL;
c0106a05:	b8 00 00 00 00       	mov    $0x0,%eax
c0106a0a:	eb 57                	jmp    c0106a63 <pgdir_alloc_page+0xa6>
        }
        if (swap_init_ok){
c0106a0c:	a1 68 2f 12 c0       	mov    0xc0122f68,%eax
c0106a11:	85 c0                	test   %eax,%eax
c0106a13:	74 4b                	je     c0106a60 <pgdir_alloc_page+0xa3>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0106a15:	a1 10 30 12 c0       	mov    0xc0123010,%eax
c0106a1a:	6a 00                	push   $0x0
c0106a1c:	ff 75 f4             	pushl  -0xc(%ebp)
c0106a1f:	ff 75 0c             	pushl  0xc(%ebp)
c0106a22:	50                   	push   %eax
c0106a23:	e8 8a d9 ff ff       	call   c01043b2 <swap_map_swappable>
c0106a28:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr=la;
c0106a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106a31:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0106a34:	83 ec 0c             	sub    $0xc,%esp
c0106a37:	ff 75 f4             	pushl  -0xc(%ebp)
c0106a3a:	e8 ef f3 ff ff       	call   c0105e2e <page_ref>
c0106a3f:	83 c4 10             	add    $0x10,%esp
c0106a42:	83 f8 01             	cmp    $0x1,%eax
c0106a45:	74 19                	je     c0106a60 <pgdir_alloc_page+0xa3>
c0106a47:	68 94 9b 10 c0       	push   $0xc0109b94
c0106a4c:	68 59 9b 10 c0       	push   $0xc0109b59
c0106a51:	68 f7 01 00 00       	push   $0x1f7
c0106a56:	68 34 9b 10 c0       	push   $0xc0109b34
c0106a5b:	e8 88 99 ff ff       	call   c01003e8 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0106a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106a63:	c9                   	leave  
c0106a64:	c3                   	ret    

c0106a65 <check_alloc_page>:

static void
check_alloc_page(void) {
c0106a65:	55                   	push   %ebp
c0106a66:	89 e5                	mov    %esp,%ebp
c0106a68:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->check();
c0106a6b:	a1 f0 30 12 c0       	mov    0xc01230f0,%eax
c0106a70:	8b 40 18             	mov    0x18(%eax),%eax
c0106a73:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0106a75:	83 ec 0c             	sub    $0xc,%esp
c0106a78:	68 a8 9b 10 c0       	push   $0xc0109ba8
c0106a7d:	e8 00 98 ff ff       	call   c0100282 <cprintf>
c0106a82:	83 c4 10             	add    $0x10,%esp
}
c0106a85:	90                   	nop
c0106a86:	c9                   	leave  
c0106a87:	c3                   	ret    

c0106a88 <check_pgdir>:

static void
check_pgdir(void) {
c0106a88:	55                   	push   %ebp
c0106a89:	89 e5                	mov    %esp,%ebp
c0106a8b:	83 ec 28             	sub    $0x28,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0106a8e:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c0106a93:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0106a98:	76 19                	jbe    c0106ab3 <check_pgdir+0x2b>
c0106a9a:	68 c7 9b 10 c0       	push   $0xc0109bc7
c0106a9f:	68 59 9b 10 c0       	push   $0xc0109b59
c0106aa4:	68 08 02 00 00       	push   $0x208
c0106aa9:	68 34 9b 10 c0       	push   $0xc0109b34
c0106aae:	e8 35 99 ff ff       	call   c01003e8 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0106ab3:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106ab8:	85 c0                	test   %eax,%eax
c0106aba:	74 0e                	je     c0106aca <check_pgdir+0x42>
c0106abc:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106ac1:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106ac6:	85 c0                	test   %eax,%eax
c0106ac8:	74 19                	je     c0106ae3 <check_pgdir+0x5b>
c0106aca:	68 e4 9b 10 c0       	push   $0xc0109be4
c0106acf:	68 59 9b 10 c0       	push   $0xc0109b59
c0106ad4:	68 09 02 00 00       	push   $0x209
c0106ad9:	68 34 9b 10 c0       	push   $0xc0109b34
c0106ade:	e8 05 99 ff ff       	call   c01003e8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0106ae3:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106ae8:	83 ec 04             	sub    $0x4,%esp
c0106aeb:	6a 00                	push   $0x0
c0106aed:	6a 00                	push   $0x0
c0106aef:	50                   	push   %eax
c0106af0:	e8 cb fc ff ff       	call   c01067c0 <get_page>
c0106af5:	83 c4 10             	add    $0x10,%esp
c0106af8:	85 c0                	test   %eax,%eax
c0106afa:	74 19                	je     c0106b15 <check_pgdir+0x8d>
c0106afc:	68 1c 9c 10 c0       	push   $0xc0109c1c
c0106b01:	68 59 9b 10 c0       	push   $0xc0109b59
c0106b06:	68 0a 02 00 00       	push   $0x20a
c0106b0b:	68 34 9b 10 c0       	push   $0xc0109b34
c0106b10:	e8 d3 98 ff ff       	call   c01003e8 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0106b15:	83 ec 0c             	sub    $0xc,%esp
c0106b18:	6a 01                	push   $0x1
c0106b1a:	e8 1d f5 ff ff       	call   c010603c <alloc_pages>
c0106b1f:	83 c4 10             	add    $0x10,%esp
c0106b22:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0106b25:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106b2a:	6a 00                	push   $0x0
c0106b2c:	6a 00                	push   $0x0
c0106b2e:	ff 75 f4             	pushl  -0xc(%ebp)
c0106b31:	50                   	push   %eax
c0106b32:	e8 7d fd ff ff       	call   c01068b4 <page_insert>
c0106b37:	83 c4 10             	add    $0x10,%esp
c0106b3a:	85 c0                	test   %eax,%eax
c0106b3c:	74 19                	je     c0106b57 <check_pgdir+0xcf>
c0106b3e:	68 44 9c 10 c0       	push   $0xc0109c44
c0106b43:	68 59 9b 10 c0       	push   $0xc0109b59
c0106b48:	68 0e 02 00 00       	push   $0x20e
c0106b4d:	68 34 9b 10 c0       	push   $0xc0109b34
c0106b52:	e8 91 98 ff ff       	call   c01003e8 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0106b57:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106b5c:	83 ec 04             	sub    $0x4,%esp
c0106b5f:	6a 00                	push   $0x0
c0106b61:	6a 00                	push   $0x0
c0106b63:	50                   	push   %eax
c0106b64:	e8 3a fb ff ff       	call   c01066a3 <get_pte>
c0106b69:	83 c4 10             	add    $0x10,%esp
c0106b6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106b73:	75 19                	jne    c0106b8e <check_pgdir+0x106>
c0106b75:	68 70 9c 10 c0       	push   $0xc0109c70
c0106b7a:	68 59 9b 10 c0       	push   $0xc0109b59
c0106b7f:	68 11 02 00 00       	push   $0x211
c0106b84:	68 34 9b 10 c0       	push   $0xc0109b34
c0106b89:	e8 5a 98 ff ff       	call   c01003e8 <__panic>
    assert(pte2page(*ptep) == p1);
c0106b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b91:	8b 00                	mov    (%eax),%eax
c0106b93:	83 ec 0c             	sub    $0xc,%esp
c0106b96:	50                   	push   %eax
c0106b97:	e8 3c f2 ff ff       	call   c0105dd8 <pte2page>
c0106b9c:	83 c4 10             	add    $0x10,%esp
c0106b9f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106ba2:	74 19                	je     c0106bbd <check_pgdir+0x135>
c0106ba4:	68 9d 9c 10 c0       	push   $0xc0109c9d
c0106ba9:	68 59 9b 10 c0       	push   $0xc0109b59
c0106bae:	68 12 02 00 00       	push   $0x212
c0106bb3:	68 34 9b 10 c0       	push   $0xc0109b34
c0106bb8:	e8 2b 98 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p1) == 1);
c0106bbd:	83 ec 0c             	sub    $0xc,%esp
c0106bc0:	ff 75 f4             	pushl  -0xc(%ebp)
c0106bc3:	e8 66 f2 ff ff       	call   c0105e2e <page_ref>
c0106bc8:	83 c4 10             	add    $0x10,%esp
c0106bcb:	83 f8 01             	cmp    $0x1,%eax
c0106bce:	74 19                	je     c0106be9 <check_pgdir+0x161>
c0106bd0:	68 b3 9c 10 c0       	push   $0xc0109cb3
c0106bd5:	68 59 9b 10 c0       	push   $0xc0109b59
c0106bda:	68 13 02 00 00       	push   $0x213
c0106bdf:	68 34 9b 10 c0       	push   $0xc0109b34
c0106be4:	e8 ff 97 ff ff       	call   c01003e8 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0106be9:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106bee:	8b 00                	mov    (%eax),%eax
c0106bf0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106bf5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106bf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bfb:	c1 e8 0c             	shr    $0xc,%eax
c0106bfe:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106c01:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c0106c06:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106c09:	72 17                	jb     c0106c22 <check_pgdir+0x19a>
c0106c0b:	ff 75 ec             	pushl  -0x14(%ebp)
c0106c0e:	68 6c 9a 10 c0       	push   $0xc0109a6c
c0106c13:	68 15 02 00 00       	push   $0x215
c0106c18:	68 34 9b 10 c0       	push   $0xc0109b34
c0106c1d:	e8 c6 97 ff ff       	call   c01003e8 <__panic>
c0106c22:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c25:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106c2a:	83 c0 04             	add    $0x4,%eax
c0106c2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0106c30:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106c35:	83 ec 04             	sub    $0x4,%esp
c0106c38:	6a 00                	push   $0x0
c0106c3a:	68 00 10 00 00       	push   $0x1000
c0106c3f:	50                   	push   %eax
c0106c40:	e8 5e fa ff ff       	call   c01066a3 <get_pte>
c0106c45:	83 c4 10             	add    $0x10,%esp
c0106c48:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106c4b:	74 19                	je     c0106c66 <check_pgdir+0x1de>
c0106c4d:	68 c8 9c 10 c0       	push   $0xc0109cc8
c0106c52:	68 59 9b 10 c0       	push   $0xc0109b59
c0106c57:	68 16 02 00 00       	push   $0x216
c0106c5c:	68 34 9b 10 c0       	push   $0xc0109b34
c0106c61:	e8 82 97 ff ff       	call   c01003e8 <__panic>

    p2 = alloc_page();
c0106c66:	83 ec 0c             	sub    $0xc,%esp
c0106c69:	6a 01                	push   $0x1
c0106c6b:	e8 cc f3 ff ff       	call   c010603c <alloc_pages>
c0106c70:	83 c4 10             	add    $0x10,%esp
c0106c73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0106c76:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106c7b:	6a 06                	push   $0x6
c0106c7d:	68 00 10 00 00       	push   $0x1000
c0106c82:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106c85:	50                   	push   %eax
c0106c86:	e8 29 fc ff ff       	call   c01068b4 <page_insert>
c0106c8b:	83 c4 10             	add    $0x10,%esp
c0106c8e:	85 c0                	test   %eax,%eax
c0106c90:	74 19                	je     c0106cab <check_pgdir+0x223>
c0106c92:	68 f0 9c 10 c0       	push   $0xc0109cf0
c0106c97:	68 59 9b 10 c0       	push   $0xc0109b59
c0106c9c:	68 19 02 00 00       	push   $0x219
c0106ca1:	68 34 9b 10 c0       	push   $0xc0109b34
c0106ca6:	e8 3d 97 ff ff       	call   c01003e8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0106cab:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106cb0:	83 ec 04             	sub    $0x4,%esp
c0106cb3:	6a 00                	push   $0x0
c0106cb5:	68 00 10 00 00       	push   $0x1000
c0106cba:	50                   	push   %eax
c0106cbb:	e8 e3 f9 ff ff       	call   c01066a3 <get_pte>
c0106cc0:	83 c4 10             	add    $0x10,%esp
c0106cc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106cc6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106cca:	75 19                	jne    c0106ce5 <check_pgdir+0x25d>
c0106ccc:	68 28 9d 10 c0       	push   $0xc0109d28
c0106cd1:	68 59 9b 10 c0       	push   $0xc0109b59
c0106cd6:	68 1a 02 00 00       	push   $0x21a
c0106cdb:	68 34 9b 10 c0       	push   $0xc0109b34
c0106ce0:	e8 03 97 ff ff       	call   c01003e8 <__panic>
    assert(*ptep & PTE_U);
c0106ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ce8:	8b 00                	mov    (%eax),%eax
c0106cea:	83 e0 04             	and    $0x4,%eax
c0106ced:	85 c0                	test   %eax,%eax
c0106cef:	75 19                	jne    c0106d0a <check_pgdir+0x282>
c0106cf1:	68 58 9d 10 c0       	push   $0xc0109d58
c0106cf6:	68 59 9b 10 c0       	push   $0xc0109b59
c0106cfb:	68 1b 02 00 00       	push   $0x21b
c0106d00:	68 34 9b 10 c0       	push   $0xc0109b34
c0106d05:	e8 de 96 ff ff       	call   c01003e8 <__panic>
    assert(*ptep & PTE_W);
c0106d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d0d:	8b 00                	mov    (%eax),%eax
c0106d0f:	83 e0 02             	and    $0x2,%eax
c0106d12:	85 c0                	test   %eax,%eax
c0106d14:	75 19                	jne    c0106d2f <check_pgdir+0x2a7>
c0106d16:	68 66 9d 10 c0       	push   $0xc0109d66
c0106d1b:	68 59 9b 10 c0       	push   $0xc0109b59
c0106d20:	68 1c 02 00 00       	push   $0x21c
c0106d25:	68 34 9b 10 c0       	push   $0xc0109b34
c0106d2a:	e8 b9 96 ff ff       	call   c01003e8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0106d2f:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106d34:	8b 00                	mov    (%eax),%eax
c0106d36:	83 e0 04             	and    $0x4,%eax
c0106d39:	85 c0                	test   %eax,%eax
c0106d3b:	75 19                	jne    c0106d56 <check_pgdir+0x2ce>
c0106d3d:	68 74 9d 10 c0       	push   $0xc0109d74
c0106d42:	68 59 9b 10 c0       	push   $0xc0109b59
c0106d47:	68 1d 02 00 00       	push   $0x21d
c0106d4c:	68 34 9b 10 c0       	push   $0xc0109b34
c0106d51:	e8 92 96 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p2) == 1);
c0106d56:	83 ec 0c             	sub    $0xc,%esp
c0106d59:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106d5c:	e8 cd f0 ff ff       	call   c0105e2e <page_ref>
c0106d61:	83 c4 10             	add    $0x10,%esp
c0106d64:	83 f8 01             	cmp    $0x1,%eax
c0106d67:	74 19                	je     c0106d82 <check_pgdir+0x2fa>
c0106d69:	68 8a 9d 10 c0       	push   $0xc0109d8a
c0106d6e:	68 59 9b 10 c0       	push   $0xc0109b59
c0106d73:	68 1e 02 00 00       	push   $0x21e
c0106d78:	68 34 9b 10 c0       	push   $0xc0109b34
c0106d7d:	e8 66 96 ff ff       	call   c01003e8 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0106d82:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106d87:	6a 00                	push   $0x0
c0106d89:	68 00 10 00 00       	push   $0x1000
c0106d8e:	ff 75 f4             	pushl  -0xc(%ebp)
c0106d91:	50                   	push   %eax
c0106d92:	e8 1d fb ff ff       	call   c01068b4 <page_insert>
c0106d97:	83 c4 10             	add    $0x10,%esp
c0106d9a:	85 c0                	test   %eax,%eax
c0106d9c:	74 19                	je     c0106db7 <check_pgdir+0x32f>
c0106d9e:	68 9c 9d 10 c0       	push   $0xc0109d9c
c0106da3:	68 59 9b 10 c0       	push   $0xc0109b59
c0106da8:	68 20 02 00 00       	push   $0x220
c0106dad:	68 34 9b 10 c0       	push   $0xc0109b34
c0106db2:	e8 31 96 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p1) == 2);
c0106db7:	83 ec 0c             	sub    $0xc,%esp
c0106dba:	ff 75 f4             	pushl  -0xc(%ebp)
c0106dbd:	e8 6c f0 ff ff       	call   c0105e2e <page_ref>
c0106dc2:	83 c4 10             	add    $0x10,%esp
c0106dc5:	83 f8 02             	cmp    $0x2,%eax
c0106dc8:	74 19                	je     c0106de3 <check_pgdir+0x35b>
c0106dca:	68 c8 9d 10 c0       	push   $0xc0109dc8
c0106dcf:	68 59 9b 10 c0       	push   $0xc0109b59
c0106dd4:	68 21 02 00 00       	push   $0x221
c0106dd9:	68 34 9b 10 c0       	push   $0xc0109b34
c0106dde:	e8 05 96 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p2) == 0);
c0106de3:	83 ec 0c             	sub    $0xc,%esp
c0106de6:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106de9:	e8 40 f0 ff ff       	call   c0105e2e <page_ref>
c0106dee:	83 c4 10             	add    $0x10,%esp
c0106df1:	85 c0                	test   %eax,%eax
c0106df3:	74 19                	je     c0106e0e <check_pgdir+0x386>
c0106df5:	68 da 9d 10 c0       	push   $0xc0109dda
c0106dfa:	68 59 9b 10 c0       	push   $0xc0109b59
c0106dff:	68 22 02 00 00       	push   $0x222
c0106e04:	68 34 9b 10 c0       	push   $0xc0109b34
c0106e09:	e8 da 95 ff ff       	call   c01003e8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0106e0e:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106e13:	83 ec 04             	sub    $0x4,%esp
c0106e16:	6a 00                	push   $0x0
c0106e18:	68 00 10 00 00       	push   $0x1000
c0106e1d:	50                   	push   %eax
c0106e1e:	e8 80 f8 ff ff       	call   c01066a3 <get_pte>
c0106e23:	83 c4 10             	add    $0x10,%esp
c0106e26:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106e29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106e2d:	75 19                	jne    c0106e48 <check_pgdir+0x3c0>
c0106e2f:	68 28 9d 10 c0       	push   $0xc0109d28
c0106e34:	68 59 9b 10 c0       	push   $0xc0109b59
c0106e39:	68 23 02 00 00       	push   $0x223
c0106e3e:	68 34 9b 10 c0       	push   $0xc0109b34
c0106e43:	e8 a0 95 ff ff       	call   c01003e8 <__panic>
    assert(pte2page(*ptep) == p1);
c0106e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e4b:	8b 00                	mov    (%eax),%eax
c0106e4d:	83 ec 0c             	sub    $0xc,%esp
c0106e50:	50                   	push   %eax
c0106e51:	e8 82 ef ff ff       	call   c0105dd8 <pte2page>
c0106e56:	83 c4 10             	add    $0x10,%esp
c0106e59:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106e5c:	74 19                	je     c0106e77 <check_pgdir+0x3ef>
c0106e5e:	68 9d 9c 10 c0       	push   $0xc0109c9d
c0106e63:	68 59 9b 10 c0       	push   $0xc0109b59
c0106e68:	68 24 02 00 00       	push   $0x224
c0106e6d:	68 34 9b 10 c0       	push   $0xc0109b34
c0106e72:	e8 71 95 ff ff       	call   c01003e8 <__panic>
    assert((*ptep & PTE_U) == 0);
c0106e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e7a:	8b 00                	mov    (%eax),%eax
c0106e7c:	83 e0 04             	and    $0x4,%eax
c0106e7f:	85 c0                	test   %eax,%eax
c0106e81:	74 19                	je     c0106e9c <check_pgdir+0x414>
c0106e83:	68 ec 9d 10 c0       	push   $0xc0109dec
c0106e88:	68 59 9b 10 c0       	push   $0xc0109b59
c0106e8d:	68 25 02 00 00       	push   $0x225
c0106e92:	68 34 9b 10 c0       	push   $0xc0109b34
c0106e97:	e8 4c 95 ff ff       	call   c01003e8 <__panic>

    page_remove(boot_pgdir, 0x0);
c0106e9c:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106ea1:	83 ec 08             	sub    $0x8,%esp
c0106ea4:	6a 00                	push   $0x0
c0106ea6:	50                   	push   %eax
c0106ea7:	e8 cf f9 ff ff       	call   c010687b <page_remove>
c0106eac:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
c0106eaf:	83 ec 0c             	sub    $0xc,%esp
c0106eb2:	ff 75 f4             	pushl  -0xc(%ebp)
c0106eb5:	e8 74 ef ff ff       	call   c0105e2e <page_ref>
c0106eba:	83 c4 10             	add    $0x10,%esp
c0106ebd:	83 f8 01             	cmp    $0x1,%eax
c0106ec0:	74 19                	je     c0106edb <check_pgdir+0x453>
c0106ec2:	68 b3 9c 10 c0       	push   $0xc0109cb3
c0106ec7:	68 59 9b 10 c0       	push   $0xc0109b59
c0106ecc:	68 28 02 00 00       	push   $0x228
c0106ed1:	68 34 9b 10 c0       	push   $0xc0109b34
c0106ed6:	e8 0d 95 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p2) == 0);
c0106edb:	83 ec 0c             	sub    $0xc,%esp
c0106ede:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106ee1:	e8 48 ef ff ff       	call   c0105e2e <page_ref>
c0106ee6:	83 c4 10             	add    $0x10,%esp
c0106ee9:	85 c0                	test   %eax,%eax
c0106eeb:	74 19                	je     c0106f06 <check_pgdir+0x47e>
c0106eed:	68 da 9d 10 c0       	push   $0xc0109dda
c0106ef2:	68 59 9b 10 c0       	push   $0xc0109b59
c0106ef7:	68 29 02 00 00       	push   $0x229
c0106efc:	68 34 9b 10 c0       	push   $0xc0109b34
c0106f01:	e8 e2 94 ff ff       	call   c01003e8 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0106f06:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106f0b:	83 ec 08             	sub    $0x8,%esp
c0106f0e:	68 00 10 00 00       	push   $0x1000
c0106f13:	50                   	push   %eax
c0106f14:	e8 62 f9 ff ff       	call   c010687b <page_remove>
c0106f19:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
c0106f1c:	83 ec 0c             	sub    $0xc,%esp
c0106f1f:	ff 75 f4             	pushl  -0xc(%ebp)
c0106f22:	e8 07 ef ff ff       	call   c0105e2e <page_ref>
c0106f27:	83 c4 10             	add    $0x10,%esp
c0106f2a:	85 c0                	test   %eax,%eax
c0106f2c:	74 19                	je     c0106f47 <check_pgdir+0x4bf>
c0106f2e:	68 01 9e 10 c0       	push   $0xc0109e01
c0106f33:	68 59 9b 10 c0       	push   $0xc0109b59
c0106f38:	68 2c 02 00 00       	push   $0x22c
c0106f3d:	68 34 9b 10 c0       	push   $0xc0109b34
c0106f42:	e8 a1 94 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p2) == 0);
c0106f47:	83 ec 0c             	sub    $0xc,%esp
c0106f4a:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106f4d:	e8 dc ee ff ff       	call   c0105e2e <page_ref>
c0106f52:	83 c4 10             	add    $0x10,%esp
c0106f55:	85 c0                	test   %eax,%eax
c0106f57:	74 19                	je     c0106f72 <check_pgdir+0x4ea>
c0106f59:	68 da 9d 10 c0       	push   $0xc0109dda
c0106f5e:	68 59 9b 10 c0       	push   $0xc0109b59
c0106f63:	68 2d 02 00 00       	push   $0x22d
c0106f68:	68 34 9b 10 c0       	push   $0xc0109b34
c0106f6d:	e8 76 94 ff ff       	call   c01003e8 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0106f72:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106f77:	8b 00                	mov    (%eax),%eax
c0106f79:	83 ec 0c             	sub    $0xc,%esp
c0106f7c:	50                   	push   %eax
c0106f7d:	e8 90 ee ff ff       	call   c0105e12 <pde2page>
c0106f82:	83 c4 10             	add    $0x10,%esp
c0106f85:	83 ec 0c             	sub    $0xc,%esp
c0106f88:	50                   	push   %eax
c0106f89:	e8 a0 ee ff ff       	call   c0105e2e <page_ref>
c0106f8e:	83 c4 10             	add    $0x10,%esp
c0106f91:	83 f8 01             	cmp    $0x1,%eax
c0106f94:	74 19                	je     c0106faf <check_pgdir+0x527>
c0106f96:	68 14 9e 10 c0       	push   $0xc0109e14
c0106f9b:	68 59 9b 10 c0       	push   $0xc0109b59
c0106fa0:	68 2f 02 00 00       	push   $0x22f
c0106fa5:	68 34 9b 10 c0       	push   $0xc0109b34
c0106faa:	e8 39 94 ff ff       	call   c01003e8 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0106faf:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106fb4:	8b 00                	mov    (%eax),%eax
c0106fb6:	83 ec 0c             	sub    $0xc,%esp
c0106fb9:	50                   	push   %eax
c0106fba:	e8 53 ee ff ff       	call   c0105e12 <pde2page>
c0106fbf:	83 c4 10             	add    $0x10,%esp
c0106fc2:	83 ec 08             	sub    $0x8,%esp
c0106fc5:	6a 01                	push   $0x1
c0106fc7:	50                   	push   %eax
c0106fc8:	e8 db f0 ff ff       	call   c01060a8 <free_pages>
c0106fcd:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0106fd0:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0106fd5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0106fdb:	83 ec 0c             	sub    $0xc,%esp
c0106fde:	68 3b 9e 10 c0       	push   $0xc0109e3b
c0106fe3:	e8 9a 92 ff ff       	call   c0100282 <cprintf>
c0106fe8:	83 c4 10             	add    $0x10,%esp
}
c0106feb:	90                   	nop
c0106fec:	c9                   	leave  
c0106fed:	c3                   	ret    

c0106fee <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0106fee:	55                   	push   %ebp
c0106fef:	89 e5                	mov    %esp,%ebp
c0106ff1:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0106ff4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106ffb:	e9 a3 00 00 00       	jmp    c01070a3 <check_boot_pgdir+0xb5>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0107000:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107003:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107006:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107009:	c1 e8 0c             	shr    $0xc,%eax
c010700c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010700f:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c0107014:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107017:	72 17                	jb     c0107030 <check_boot_pgdir+0x42>
c0107019:	ff 75 f0             	pushl  -0x10(%ebp)
c010701c:	68 6c 9a 10 c0       	push   $0xc0109a6c
c0107021:	68 3b 02 00 00       	push   $0x23b
c0107026:	68 34 9b 10 c0       	push   $0xc0109b34
c010702b:	e8 b8 93 ff ff       	call   c01003e8 <__panic>
c0107030:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107033:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107038:	89 c2                	mov    %eax,%edx
c010703a:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c010703f:	83 ec 04             	sub    $0x4,%esp
c0107042:	6a 00                	push   $0x0
c0107044:	52                   	push   %edx
c0107045:	50                   	push   %eax
c0107046:	e8 58 f6 ff ff       	call   c01066a3 <get_pte>
c010704b:	83 c4 10             	add    $0x10,%esp
c010704e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107051:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107055:	75 19                	jne    c0107070 <check_boot_pgdir+0x82>
c0107057:	68 58 9e 10 c0       	push   $0xc0109e58
c010705c:	68 59 9b 10 c0       	push   $0xc0109b59
c0107061:	68 3b 02 00 00       	push   $0x23b
c0107066:	68 34 9b 10 c0       	push   $0xc0109b34
c010706b:	e8 78 93 ff ff       	call   c01003e8 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0107070:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107073:	8b 00                	mov    (%eax),%eax
c0107075:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010707a:	89 c2                	mov    %eax,%edx
c010707c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010707f:	39 c2                	cmp    %eax,%edx
c0107081:	74 19                	je     c010709c <check_boot_pgdir+0xae>
c0107083:	68 95 9e 10 c0       	push   $0xc0109e95
c0107088:	68 59 9b 10 c0       	push   $0xc0109b59
c010708d:	68 3c 02 00 00       	push   $0x23c
c0107092:	68 34 9b 10 c0       	push   $0xc0109b34
c0107097:	e8 4c 93 ff ff       	call   c01003e8 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c010709c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01070a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01070a6:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c01070ab:	39 c2                	cmp    %eax,%edx
c01070ad:	0f 82 4d ff ff ff    	jb     c0107000 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01070b3:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c01070b8:	05 ac 0f 00 00       	add    $0xfac,%eax
c01070bd:	8b 00                	mov    (%eax),%eax
c01070bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01070c4:	89 c2                	mov    %eax,%edx
c01070c6:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c01070cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01070ce:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c01070d5:	77 17                	ja     c01070ee <check_boot_pgdir+0x100>
c01070d7:	ff 75 e4             	pushl  -0x1c(%ebp)
c01070da:	68 90 9a 10 c0       	push   $0xc0109a90
c01070df:	68 3f 02 00 00       	push   $0x23f
c01070e4:	68 34 9b 10 c0       	push   $0xc0109b34
c01070e9:	e8 fa 92 ff ff       	call   c01003e8 <__panic>
c01070ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01070f1:	05 00 00 00 40       	add    $0x40000000,%eax
c01070f6:	39 c2                	cmp    %eax,%edx
c01070f8:	74 19                	je     c0107113 <check_boot_pgdir+0x125>
c01070fa:	68 ac 9e 10 c0       	push   $0xc0109eac
c01070ff:	68 59 9b 10 c0       	push   $0xc0109b59
c0107104:	68 3f 02 00 00       	push   $0x23f
c0107109:	68 34 9b 10 c0       	push   $0xc0109b34
c010710e:	e8 d5 92 ff ff       	call   c01003e8 <__panic>

    assert(boot_pgdir[0] == 0);
c0107113:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c0107118:	8b 00                	mov    (%eax),%eax
c010711a:	85 c0                	test   %eax,%eax
c010711c:	74 19                	je     c0107137 <check_boot_pgdir+0x149>
c010711e:	68 e0 9e 10 c0       	push   $0xc0109ee0
c0107123:	68 59 9b 10 c0       	push   $0xc0109b59
c0107128:	68 41 02 00 00       	push   $0x241
c010712d:	68 34 9b 10 c0       	push   $0xc0109b34
c0107132:	e8 b1 92 ff ff       	call   c01003e8 <__panic>

    struct Page *p;
    p = alloc_page();
c0107137:	83 ec 0c             	sub    $0xc,%esp
c010713a:	6a 01                	push   $0x1
c010713c:	e8 fb ee ff ff       	call   c010603c <alloc_pages>
c0107141:	83 c4 10             	add    $0x10,%esp
c0107144:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0107147:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c010714c:	6a 02                	push   $0x2
c010714e:	68 00 01 00 00       	push   $0x100
c0107153:	ff 75 e0             	pushl  -0x20(%ebp)
c0107156:	50                   	push   %eax
c0107157:	e8 58 f7 ff ff       	call   c01068b4 <page_insert>
c010715c:	83 c4 10             	add    $0x10,%esp
c010715f:	85 c0                	test   %eax,%eax
c0107161:	74 19                	je     c010717c <check_boot_pgdir+0x18e>
c0107163:	68 f4 9e 10 c0       	push   $0xc0109ef4
c0107168:	68 59 9b 10 c0       	push   $0xc0109b59
c010716d:	68 45 02 00 00       	push   $0x245
c0107172:	68 34 9b 10 c0       	push   $0xc0109b34
c0107177:	e8 6c 92 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p) == 1);
c010717c:	83 ec 0c             	sub    $0xc,%esp
c010717f:	ff 75 e0             	pushl  -0x20(%ebp)
c0107182:	e8 a7 ec ff ff       	call   c0105e2e <page_ref>
c0107187:	83 c4 10             	add    $0x10,%esp
c010718a:	83 f8 01             	cmp    $0x1,%eax
c010718d:	74 19                	je     c01071a8 <check_boot_pgdir+0x1ba>
c010718f:	68 22 9f 10 c0       	push   $0xc0109f22
c0107194:	68 59 9b 10 c0       	push   $0xc0109b59
c0107199:	68 46 02 00 00       	push   $0x246
c010719e:	68 34 9b 10 c0       	push   $0xc0109b34
c01071a3:	e8 40 92 ff ff       	call   c01003e8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01071a8:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c01071ad:	6a 02                	push   $0x2
c01071af:	68 00 11 00 00       	push   $0x1100
c01071b4:	ff 75 e0             	pushl  -0x20(%ebp)
c01071b7:	50                   	push   %eax
c01071b8:	e8 f7 f6 ff ff       	call   c01068b4 <page_insert>
c01071bd:	83 c4 10             	add    $0x10,%esp
c01071c0:	85 c0                	test   %eax,%eax
c01071c2:	74 19                	je     c01071dd <check_boot_pgdir+0x1ef>
c01071c4:	68 34 9f 10 c0       	push   $0xc0109f34
c01071c9:	68 59 9b 10 c0       	push   $0xc0109b59
c01071ce:	68 47 02 00 00       	push   $0x247
c01071d3:	68 34 9b 10 c0       	push   $0xc0109b34
c01071d8:	e8 0b 92 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p) == 2);
c01071dd:	83 ec 0c             	sub    $0xc,%esp
c01071e0:	ff 75 e0             	pushl  -0x20(%ebp)
c01071e3:	e8 46 ec ff ff       	call   c0105e2e <page_ref>
c01071e8:	83 c4 10             	add    $0x10,%esp
c01071eb:	83 f8 02             	cmp    $0x2,%eax
c01071ee:	74 19                	je     c0107209 <check_boot_pgdir+0x21b>
c01071f0:	68 6b 9f 10 c0       	push   $0xc0109f6b
c01071f5:	68 59 9b 10 c0       	push   $0xc0109b59
c01071fa:	68 48 02 00 00       	push   $0x248
c01071ff:	68 34 9b 10 c0       	push   $0xc0109b34
c0107204:	e8 df 91 ff ff       	call   c01003e8 <__panic>

    const char *str = "ucore: Hello world!!";
c0107209:	c7 45 dc 7c 9f 10 c0 	movl   $0xc0109f7c,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0107210:	83 ec 08             	sub    $0x8,%esp
c0107213:	ff 75 dc             	pushl  -0x24(%ebp)
c0107216:	68 00 01 00 00       	push   $0x100
c010721b:	e8 ee 05 00 00       	call   c010780e <strcpy>
c0107220:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0107223:	83 ec 08             	sub    $0x8,%esp
c0107226:	68 00 11 00 00       	push   $0x1100
c010722b:	68 00 01 00 00       	push   $0x100
c0107230:	e8 53 06 00 00       	call   c0107888 <strcmp>
c0107235:	83 c4 10             	add    $0x10,%esp
c0107238:	85 c0                	test   %eax,%eax
c010723a:	74 19                	je     c0107255 <check_boot_pgdir+0x267>
c010723c:	68 94 9f 10 c0       	push   $0xc0109f94
c0107241:	68 59 9b 10 c0       	push   $0xc0109b59
c0107246:	68 4c 02 00 00       	push   $0x24c
c010724b:	68 34 9b 10 c0       	push   $0xc0109b34
c0107250:	e8 93 91 ff ff       	call   c01003e8 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0107255:	83 ec 0c             	sub    $0xc,%esp
c0107258:	ff 75 e0             	pushl  -0x20(%ebp)
c010725b:	e8 f4 ea ff ff       	call   c0105d54 <page2kva>
c0107260:	83 c4 10             	add    $0x10,%esp
c0107263:	05 00 01 00 00       	add    $0x100,%eax
c0107268:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010726b:	83 ec 0c             	sub    $0xc,%esp
c010726e:	68 00 01 00 00       	push   $0x100
c0107273:	e8 3e 05 00 00       	call   c01077b6 <strlen>
c0107278:	83 c4 10             	add    $0x10,%esp
c010727b:	85 c0                	test   %eax,%eax
c010727d:	74 19                	je     c0107298 <check_boot_pgdir+0x2aa>
c010727f:	68 cc 9f 10 c0       	push   $0xc0109fcc
c0107284:	68 59 9b 10 c0       	push   $0xc0109b59
c0107289:	68 4f 02 00 00       	push   $0x24f
c010728e:	68 34 9b 10 c0       	push   $0xc0109b34
c0107293:	e8 50 91 ff ff       	call   c01003e8 <__panic>

    free_page(p);
c0107298:	83 ec 08             	sub    $0x8,%esp
c010729b:	6a 01                	push   $0x1
c010729d:	ff 75 e0             	pushl  -0x20(%ebp)
c01072a0:	e8 03 ee ff ff       	call   c01060a8 <free_pages>
c01072a5:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(boot_pgdir[0]));
c01072a8:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c01072ad:	8b 00                	mov    (%eax),%eax
c01072af:	83 ec 0c             	sub    $0xc,%esp
c01072b2:	50                   	push   %eax
c01072b3:	e8 5a eb ff ff       	call   c0105e12 <pde2page>
c01072b8:	83 c4 10             	add    $0x10,%esp
c01072bb:	83 ec 08             	sub    $0x8,%esp
c01072be:	6a 01                	push   $0x1
c01072c0:	50                   	push   %eax
c01072c1:	e8 e2 ed ff ff       	call   c01060a8 <free_pages>
c01072c6:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c01072c9:	a1 00 fa 11 c0       	mov    0xc011fa00,%eax
c01072ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01072d4:	83 ec 0c             	sub    $0xc,%esp
c01072d7:	68 f0 9f 10 c0       	push   $0xc0109ff0
c01072dc:	e8 a1 8f ff ff       	call   c0100282 <cprintf>
c01072e1:	83 c4 10             	add    $0x10,%esp
}
c01072e4:	90                   	nop
c01072e5:	c9                   	leave  
c01072e6:	c3                   	ret    

c01072e7 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c01072e7:	55                   	push   %ebp
c01072e8:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01072ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01072ed:	83 e0 04             	and    $0x4,%eax
c01072f0:	85 c0                	test   %eax,%eax
c01072f2:	74 07                	je     c01072fb <perm2str+0x14>
c01072f4:	b8 75 00 00 00       	mov    $0x75,%eax
c01072f9:	eb 05                	jmp    c0107300 <perm2str+0x19>
c01072fb:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0107300:	a2 08 30 12 c0       	mov    %al,0xc0123008
    str[1] = 'r';
c0107305:	c6 05 09 30 12 c0 72 	movb   $0x72,0xc0123009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010730c:	8b 45 08             	mov    0x8(%ebp),%eax
c010730f:	83 e0 02             	and    $0x2,%eax
c0107312:	85 c0                	test   %eax,%eax
c0107314:	74 07                	je     c010731d <perm2str+0x36>
c0107316:	b8 77 00 00 00       	mov    $0x77,%eax
c010731b:	eb 05                	jmp    c0107322 <perm2str+0x3b>
c010731d:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0107322:	a2 0a 30 12 c0       	mov    %al,0xc012300a
    str[3] = '\0';
c0107327:	c6 05 0b 30 12 c0 00 	movb   $0x0,0xc012300b
    return str;
c010732e:	b8 08 30 12 c0       	mov    $0xc0123008,%eax
}
c0107333:	5d                   	pop    %ebp
c0107334:	c3                   	ret    

c0107335 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0107335:	55                   	push   %ebp
c0107336:	89 e5                	mov    %esp,%ebp
c0107338:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010733b:	8b 45 10             	mov    0x10(%ebp),%eax
c010733e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107341:	72 0e                	jb     c0107351 <get_pgtable_items+0x1c>
        return 0;
c0107343:	b8 00 00 00 00       	mov    $0x0,%eax
c0107348:	e9 9a 00 00 00       	jmp    c01073e7 <get_pgtable_items+0xb2>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c010734d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0107351:	8b 45 10             	mov    0x10(%ebp),%eax
c0107354:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107357:	73 18                	jae    c0107371 <get_pgtable_items+0x3c>
c0107359:	8b 45 10             	mov    0x10(%ebp),%eax
c010735c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107363:	8b 45 14             	mov    0x14(%ebp),%eax
c0107366:	01 d0                	add    %edx,%eax
c0107368:	8b 00                	mov    (%eax),%eax
c010736a:	83 e0 01             	and    $0x1,%eax
c010736d:	85 c0                	test   %eax,%eax
c010736f:	74 dc                	je     c010734d <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c0107371:	8b 45 10             	mov    0x10(%ebp),%eax
c0107374:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107377:	73 69                	jae    c01073e2 <get_pgtable_items+0xad>
        if (left_store != NULL) {
c0107379:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010737d:	74 08                	je     c0107387 <get_pgtable_items+0x52>
            *left_store = start;
c010737f:	8b 45 18             	mov    0x18(%ebp),%eax
c0107382:	8b 55 10             	mov    0x10(%ebp),%edx
c0107385:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0107387:	8b 45 10             	mov    0x10(%ebp),%eax
c010738a:	8d 50 01             	lea    0x1(%eax),%edx
c010738d:	89 55 10             	mov    %edx,0x10(%ebp)
c0107390:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107397:	8b 45 14             	mov    0x14(%ebp),%eax
c010739a:	01 d0                	add    %edx,%eax
c010739c:	8b 00                	mov    (%eax),%eax
c010739e:	83 e0 07             	and    $0x7,%eax
c01073a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01073a4:	eb 04                	jmp    c01073aa <get_pgtable_items+0x75>
            start ++;
c01073a6:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c01073aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01073ad:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01073b0:	73 1d                	jae    c01073cf <get_pgtable_items+0x9a>
c01073b2:	8b 45 10             	mov    0x10(%ebp),%eax
c01073b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01073bc:	8b 45 14             	mov    0x14(%ebp),%eax
c01073bf:	01 d0                	add    %edx,%eax
c01073c1:	8b 00                	mov    (%eax),%eax
c01073c3:	83 e0 07             	and    $0x7,%eax
c01073c6:	89 c2                	mov    %eax,%edx
c01073c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01073cb:	39 c2                	cmp    %eax,%edx
c01073cd:	74 d7                	je     c01073a6 <get_pgtable_items+0x71>
            start ++;
        }
        if (right_store != NULL) {
c01073cf:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01073d3:	74 08                	je     c01073dd <get_pgtable_items+0xa8>
            *right_store = start;
c01073d5:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01073d8:	8b 55 10             	mov    0x10(%ebp),%edx
c01073db:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01073dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01073e0:	eb 05                	jmp    c01073e7 <get_pgtable_items+0xb2>
    }
    return 0;
c01073e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01073e7:	c9                   	leave  
c01073e8:	c3                   	ret    

c01073e9 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01073e9:	55                   	push   %ebp
c01073ea:	89 e5                	mov    %esp,%ebp
c01073ec:	57                   	push   %edi
c01073ed:	56                   	push   %esi
c01073ee:	53                   	push   %ebx
c01073ef:	83 ec 2c             	sub    $0x2c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01073f2:	83 ec 0c             	sub    $0xc,%esp
c01073f5:	68 10 a0 10 c0       	push   $0xc010a010
c01073fa:	e8 83 8e ff ff       	call   c0100282 <cprintf>
c01073ff:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
c0107402:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107409:	e9 e5 00 00 00       	jmp    c01074f3 <print_pgdir+0x10a>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010740e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107411:	83 ec 0c             	sub    $0xc,%esp
c0107414:	50                   	push   %eax
c0107415:	e8 cd fe ff ff       	call   c01072e7 <perm2str>
c010741a:	83 c4 10             	add    $0x10,%esp
c010741d:	89 c7                	mov    %eax,%edi
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c010741f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107422:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107425:	29 c2                	sub    %eax,%edx
c0107427:	89 d0                	mov    %edx,%eax
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107429:	c1 e0 16             	shl    $0x16,%eax
c010742c:	89 c3                	mov    %eax,%ebx
c010742e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107431:	c1 e0 16             	shl    $0x16,%eax
c0107434:	89 c1                	mov    %eax,%ecx
c0107436:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107439:	c1 e0 16             	shl    $0x16,%eax
c010743c:	89 c2                	mov    %eax,%edx
c010743e:	8b 75 dc             	mov    -0x24(%ebp),%esi
c0107441:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107444:	29 c6                	sub    %eax,%esi
c0107446:	89 f0                	mov    %esi,%eax
c0107448:	83 ec 08             	sub    $0x8,%esp
c010744b:	57                   	push   %edi
c010744c:	53                   	push   %ebx
c010744d:	51                   	push   %ecx
c010744e:	52                   	push   %edx
c010744f:	50                   	push   %eax
c0107450:	68 41 a0 10 c0       	push   $0xc010a041
c0107455:	e8 28 8e ff ff       	call   c0100282 <cprintf>
c010745a:	83 c4 20             	add    $0x20,%esp
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c010745d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107460:	c1 e0 0a             	shl    $0xa,%eax
c0107463:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107466:	eb 4f                	jmp    c01074b7 <print_pgdir+0xce>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107468:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010746b:	83 ec 0c             	sub    $0xc,%esp
c010746e:	50                   	push   %eax
c010746f:	e8 73 fe ff ff       	call   c01072e7 <perm2str>
c0107474:	83 c4 10             	add    $0x10,%esp
c0107477:	89 c7                	mov    %eax,%edi
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0107479:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010747c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010747f:	29 c2                	sub    %eax,%edx
c0107481:	89 d0                	mov    %edx,%eax
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107483:	c1 e0 0c             	shl    $0xc,%eax
c0107486:	89 c3                	mov    %eax,%ebx
c0107488:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010748b:	c1 e0 0c             	shl    $0xc,%eax
c010748e:	89 c1                	mov    %eax,%ecx
c0107490:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107493:	c1 e0 0c             	shl    $0xc,%eax
c0107496:	89 c2                	mov    %eax,%edx
c0107498:	8b 75 d4             	mov    -0x2c(%ebp),%esi
c010749b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010749e:	29 c6                	sub    %eax,%esi
c01074a0:	89 f0                	mov    %esi,%eax
c01074a2:	83 ec 08             	sub    $0x8,%esp
c01074a5:	57                   	push   %edi
c01074a6:	53                   	push   %ebx
c01074a7:	51                   	push   %ecx
c01074a8:	52                   	push   %edx
c01074a9:	50                   	push   %eax
c01074aa:	68 60 a0 10 c0       	push   $0xc010a060
c01074af:	e8 ce 8d ff ff       	call   c0100282 <cprintf>
c01074b4:	83 c4 20             	add    $0x20,%esp
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01074b7:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01074bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01074bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01074c2:	89 d3                	mov    %edx,%ebx
c01074c4:	c1 e3 0a             	shl    $0xa,%ebx
c01074c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01074ca:	89 d1                	mov    %edx,%ecx
c01074cc:	c1 e1 0a             	shl    $0xa,%ecx
c01074cf:	83 ec 08             	sub    $0x8,%esp
c01074d2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01074d5:	52                   	push   %edx
c01074d6:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01074d9:	52                   	push   %edx
c01074da:	56                   	push   %esi
c01074db:	50                   	push   %eax
c01074dc:	53                   	push   %ebx
c01074dd:	51                   	push   %ecx
c01074de:	e8 52 fe ff ff       	call   c0107335 <get_pgtable_items>
c01074e3:	83 c4 20             	add    $0x20,%esp
c01074e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01074e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01074ed:	0f 85 75 ff ff ff    	jne    c0107468 <print_pgdir+0x7f>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01074f3:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01074f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01074fb:	83 ec 08             	sub    $0x8,%esp
c01074fe:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0107501:	52                   	push   %edx
c0107502:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0107505:	52                   	push   %edx
c0107506:	51                   	push   %ecx
c0107507:	50                   	push   %eax
c0107508:	68 00 04 00 00       	push   $0x400
c010750d:	6a 00                	push   $0x0
c010750f:	e8 21 fe ff ff       	call   c0107335 <get_pgtable_items>
c0107514:	83 c4 20             	add    $0x20,%esp
c0107517:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010751a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010751e:	0f 85 ea fe ff ff    	jne    c010740e <print_pgdir+0x25>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0107524:	83 ec 0c             	sub    $0xc,%esp
c0107527:	68 84 a0 10 c0       	push   $0xc010a084
c010752c:	e8 51 8d ff ff       	call   c0100282 <cprintf>
c0107531:	83 c4 10             	add    $0x10,%esp
}
c0107534:	90                   	nop
c0107535:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0107538:	5b                   	pop    %ebx
c0107539:	5e                   	pop    %esi
c010753a:	5f                   	pop    %edi
c010753b:	5d                   	pop    %ebp
c010753c:	c3                   	ret    

c010753d <kmalloc>:

void *
kmalloc(size_t n) {
c010753d:	55                   	push   %ebp
c010753e:	89 e5                	mov    %esp,%ebp
c0107540:	83 ec 18             	sub    $0x18,%esp
    void * ptr=NULL;
c0107543:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c010754a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c0107551:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107555:	74 09                	je     c0107560 <kmalloc+0x23>
c0107557:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c010755e:	76 19                	jbe    c0107579 <kmalloc+0x3c>
c0107560:	68 b5 a0 10 c0       	push   $0xc010a0b5
c0107565:	68 59 9b 10 c0       	push   $0xc0109b59
c010756a:	68 9b 02 00 00       	push   $0x29b
c010756f:	68 34 9b 10 c0       	push   $0xc0109b34
c0107574:	e8 6f 8e ff ff       	call   c01003e8 <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0107579:	8b 45 08             	mov    0x8(%ebp),%eax
c010757c:	05 ff 0f 00 00       	add    $0xfff,%eax
c0107581:	c1 e8 0c             	shr    $0xc,%eax
c0107584:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c0107587:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010758a:	83 ec 0c             	sub    $0xc,%esp
c010758d:	50                   	push   %eax
c010758e:	e8 a9 ea ff ff       	call   c010603c <alloc_pages>
c0107593:	83 c4 10             	add    $0x10,%esp
c0107596:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c0107599:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010759d:	75 19                	jne    c01075b8 <kmalloc+0x7b>
c010759f:	68 cc a0 10 c0       	push   $0xc010a0cc
c01075a4:	68 59 9b 10 c0       	push   $0xc0109b59
c01075a9:	68 9e 02 00 00       	push   $0x29e
c01075ae:	68 34 9b 10 c0       	push   $0xc0109b34
c01075b3:	e8 30 8e ff ff       	call   c01003e8 <__panic>
    ptr=page2kva(base);
c01075b8:	83 ec 0c             	sub    $0xc,%esp
c01075bb:	ff 75 f0             	pushl  -0x10(%ebp)
c01075be:	e8 91 e7 ff ff       	call   c0105d54 <page2kva>
c01075c3:	83 c4 10             	add    $0x10,%esp
c01075c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c01075c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01075cc:	c9                   	leave  
c01075cd:	c3                   	ret    

c01075ce <kfree>:

void 
kfree(void *ptr, size_t n) {
c01075ce:	55                   	push   %ebp
c01075cf:	89 e5                	mov    %esp,%ebp
c01075d1:	83 ec 18             	sub    $0x18,%esp
    assert(n > 0 && n < 1024*0124);
c01075d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01075d8:	74 09                	je     c01075e3 <kfree+0x15>
c01075da:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c01075e1:	76 19                	jbe    c01075fc <kfree+0x2e>
c01075e3:	68 b5 a0 10 c0       	push   $0xc010a0b5
c01075e8:	68 59 9b 10 c0       	push   $0xc0109b59
c01075ed:	68 a5 02 00 00       	push   $0x2a5
c01075f2:	68 34 9b 10 c0       	push   $0xc0109b34
c01075f7:	e8 ec 8d ff ff       	call   c01003e8 <__panic>
    assert(ptr != NULL);
c01075fc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107600:	75 19                	jne    c010761b <kfree+0x4d>
c0107602:	68 d9 a0 10 c0       	push   $0xc010a0d9
c0107607:	68 59 9b 10 c0       	push   $0xc0109b59
c010760c:	68 a6 02 00 00       	push   $0x2a6
c0107611:	68 34 9b 10 c0       	push   $0xc0109b34
c0107616:	e8 cd 8d ff ff       	call   c01003e8 <__panic>
    struct Page *base=NULL;
c010761b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0107622:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107625:	05 ff 0f 00 00       	add    $0xfff,%eax
c010762a:	c1 e8 0c             	shr    $0xc,%eax
c010762d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0107630:	83 ec 0c             	sub    $0xc,%esp
c0107633:	ff 75 08             	pushl  0x8(%ebp)
c0107636:	e8 5e e7 ff ff       	call   c0105d99 <kva2page>
c010763b:	83 c4 10             	add    $0x10,%esp
c010763e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0107641:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107644:	83 ec 08             	sub    $0x8,%esp
c0107647:	50                   	push   %eax
c0107648:	ff 75 f4             	pushl  -0xc(%ebp)
c010764b:	e8 58 ea ff ff       	call   c01060a8 <free_pages>
c0107650:	83 c4 10             	add    $0x10,%esp
}
c0107653:	90                   	nop
c0107654:	c9                   	leave  
c0107655:	c3                   	ret    

c0107656 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0107656:	55                   	push   %ebp
c0107657:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107659:	8b 45 08             	mov    0x8(%ebp),%eax
c010765c:	8b 15 f8 30 12 c0    	mov    0xc01230f8,%edx
c0107662:	29 d0                	sub    %edx,%eax
c0107664:	c1 f8 05             	sar    $0x5,%eax
}
c0107667:	5d                   	pop    %ebp
c0107668:	c3                   	ret    

c0107669 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0107669:	55                   	push   %ebp
c010766a:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c010766c:	ff 75 08             	pushl  0x8(%ebp)
c010766f:	e8 e2 ff ff ff       	call   c0107656 <page2ppn>
c0107674:	83 c4 04             	add    $0x4,%esp
c0107677:	c1 e0 0c             	shl    $0xc,%eax
}
c010767a:	c9                   	leave  
c010767b:	c3                   	ret    

c010767c <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c010767c:	55                   	push   %ebp
c010767d:	89 e5                	mov    %esp,%ebp
c010767f:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0107682:	ff 75 08             	pushl  0x8(%ebp)
c0107685:	e8 df ff ff ff       	call   c0107669 <page2pa>
c010768a:	83 c4 04             	add    $0x4,%esp
c010768d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107690:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107693:	c1 e8 0c             	shr    $0xc,%eax
c0107696:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107699:	a1 80 2f 12 c0       	mov    0xc0122f80,%eax
c010769e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01076a1:	72 14                	jb     c01076b7 <page2kva+0x3b>
c01076a3:	ff 75 f4             	pushl  -0xc(%ebp)
c01076a6:	68 e8 a0 10 c0       	push   $0xc010a0e8
c01076ab:	6a 62                	push   $0x62
c01076ad:	68 0b a1 10 c0       	push   $0xc010a10b
c01076b2:	e8 31 8d ff ff       	call   c01003e8 <__panic>
c01076b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076ba:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01076bf:	c9                   	leave  
c01076c0:	c3                   	ret    

c01076c1 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01076c1:	55                   	push   %ebp
c01076c2:	89 e5                	mov    %esp,%ebp
c01076c4:	83 ec 08             	sub    $0x8,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01076c7:	83 ec 0c             	sub    $0xc,%esp
c01076ca:	6a 01                	push   $0x1
c01076cc:	e8 15 9a ff ff       	call   c01010e6 <ide_device_valid>
c01076d1:	83 c4 10             	add    $0x10,%esp
c01076d4:	85 c0                	test   %eax,%eax
c01076d6:	75 14                	jne    c01076ec <swapfs_init+0x2b>
        panic("swap fs isn't available.\n");
c01076d8:	83 ec 04             	sub    $0x4,%esp
c01076db:	68 19 a1 10 c0       	push   $0xc010a119
c01076e0:	6a 0d                	push   $0xd
c01076e2:	68 33 a1 10 c0       	push   $0xc010a133
c01076e7:	e8 fc 8c ff ff       	call   c01003e8 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01076ec:	83 ec 0c             	sub    $0xc,%esp
c01076ef:	6a 01                	push   $0x1
c01076f1:	e8 30 9a ff ff       	call   c0101126 <ide_device_size>
c01076f6:	83 c4 10             	add    $0x10,%esp
c01076f9:	c1 e8 03             	shr    $0x3,%eax
c01076fc:	a3 bc 30 12 c0       	mov    %eax,0xc01230bc
}
c0107701:	90                   	nop
c0107702:	c9                   	leave  
c0107703:	c3                   	ret    

c0107704 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0107704:	55                   	push   %ebp
c0107705:	89 e5                	mov    %esp,%ebp
c0107707:	83 ec 18             	sub    $0x18,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010770a:	83 ec 0c             	sub    $0xc,%esp
c010770d:	ff 75 0c             	pushl  0xc(%ebp)
c0107710:	e8 67 ff ff ff       	call   c010767c <page2kva>
c0107715:	83 c4 10             	add    $0x10,%esp
c0107718:	89 c2                	mov    %eax,%edx
c010771a:	8b 45 08             	mov    0x8(%ebp),%eax
c010771d:	c1 e8 08             	shr    $0x8,%eax
c0107720:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107723:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107727:	74 0a                	je     c0107733 <swapfs_read+0x2f>
c0107729:	a1 bc 30 12 c0       	mov    0xc01230bc,%eax
c010772e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107731:	72 14                	jb     c0107747 <swapfs_read+0x43>
c0107733:	ff 75 08             	pushl  0x8(%ebp)
c0107736:	68 44 a1 10 c0       	push   $0xc010a144
c010773b:	6a 14                	push   $0x14
c010773d:	68 33 a1 10 c0       	push   $0xc010a133
c0107742:	e8 a1 8c ff ff       	call   c01003e8 <__panic>
c0107747:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010774a:	c1 e0 03             	shl    $0x3,%eax
c010774d:	6a 08                	push   $0x8
c010774f:	52                   	push   %edx
c0107750:	50                   	push   %eax
c0107751:	6a 01                	push   $0x1
c0107753:	e8 0e 9a ff ff       	call   c0101166 <ide_read_secs>
c0107758:	83 c4 10             	add    $0x10,%esp
}
c010775b:	c9                   	leave  
c010775c:	c3                   	ret    

c010775d <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c010775d:	55                   	push   %ebp
c010775e:	89 e5                	mov    %esp,%ebp
c0107760:	83 ec 18             	sub    $0x18,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107763:	83 ec 0c             	sub    $0xc,%esp
c0107766:	ff 75 0c             	pushl  0xc(%ebp)
c0107769:	e8 0e ff ff ff       	call   c010767c <page2kva>
c010776e:	83 c4 10             	add    $0x10,%esp
c0107771:	89 c2                	mov    %eax,%edx
c0107773:	8b 45 08             	mov    0x8(%ebp),%eax
c0107776:	c1 e8 08             	shr    $0x8,%eax
c0107779:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010777c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107780:	74 0a                	je     c010778c <swapfs_write+0x2f>
c0107782:	a1 bc 30 12 c0       	mov    0xc01230bc,%eax
c0107787:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010778a:	72 14                	jb     c01077a0 <swapfs_write+0x43>
c010778c:	ff 75 08             	pushl  0x8(%ebp)
c010778f:	68 44 a1 10 c0       	push   $0xc010a144
c0107794:	6a 19                	push   $0x19
c0107796:	68 33 a1 10 c0       	push   $0xc010a133
c010779b:	e8 48 8c ff ff       	call   c01003e8 <__panic>
c01077a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077a3:	c1 e0 03             	shl    $0x3,%eax
c01077a6:	6a 08                	push   $0x8
c01077a8:	52                   	push   %edx
c01077a9:	50                   	push   %eax
c01077aa:	6a 01                	push   $0x1
c01077ac:	e8 df 9b ff ff       	call   c0101390 <ide_write_secs>
c01077b1:	83 c4 10             	add    $0x10,%esp
}
c01077b4:	c9                   	leave  
c01077b5:	c3                   	ret    

c01077b6 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01077b6:	55                   	push   %ebp
c01077b7:	89 e5                	mov    %esp,%ebp
c01077b9:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01077bc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01077c3:	eb 04                	jmp    c01077c9 <strlen+0x13>
        cnt ++;
c01077c5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c01077c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01077cc:	8d 50 01             	lea    0x1(%eax),%edx
c01077cf:	89 55 08             	mov    %edx,0x8(%ebp)
c01077d2:	0f b6 00             	movzbl (%eax),%eax
c01077d5:	84 c0                	test   %al,%al
c01077d7:	75 ec                	jne    c01077c5 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c01077d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01077dc:	c9                   	leave  
c01077dd:	c3                   	ret    

c01077de <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01077de:	55                   	push   %ebp
c01077df:	89 e5                	mov    %esp,%ebp
c01077e1:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01077e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01077eb:	eb 04                	jmp    c01077f1 <strnlen+0x13>
        cnt ++;
c01077ed:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c01077f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01077f4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01077f7:	73 10                	jae    c0107809 <strnlen+0x2b>
c01077f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01077fc:	8d 50 01             	lea    0x1(%eax),%edx
c01077ff:	89 55 08             	mov    %edx,0x8(%ebp)
c0107802:	0f b6 00             	movzbl (%eax),%eax
c0107805:	84 c0                	test   %al,%al
c0107807:	75 e4                	jne    c01077ed <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0107809:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010780c:	c9                   	leave  
c010780d:	c3                   	ret    

c010780e <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010780e:	55                   	push   %ebp
c010780f:	89 e5                	mov    %esp,%ebp
c0107811:	57                   	push   %edi
c0107812:	56                   	push   %esi
c0107813:	83 ec 20             	sub    $0x20,%esp
c0107816:	8b 45 08             	mov    0x8(%ebp),%eax
c0107819:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010781c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010781f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0107822:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107825:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107828:	89 d1                	mov    %edx,%ecx
c010782a:	89 c2                	mov    %eax,%edx
c010782c:	89 ce                	mov    %ecx,%esi
c010782e:	89 d7                	mov    %edx,%edi
c0107830:	ac                   	lods   %ds:(%esi),%al
c0107831:	aa                   	stos   %al,%es:(%edi)
c0107832:	84 c0                	test   %al,%al
c0107834:	75 fa                	jne    c0107830 <strcpy+0x22>
c0107836:	89 fa                	mov    %edi,%edx
c0107838:	89 f1                	mov    %esi,%ecx
c010783a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010783d:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107840:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0107843:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0107846:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0107847:	83 c4 20             	add    $0x20,%esp
c010784a:	5e                   	pop    %esi
c010784b:	5f                   	pop    %edi
c010784c:	5d                   	pop    %ebp
c010784d:	c3                   	ret    

c010784e <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010784e:	55                   	push   %ebp
c010784f:	89 e5                	mov    %esp,%ebp
c0107851:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0107854:	8b 45 08             	mov    0x8(%ebp),%eax
c0107857:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010785a:	eb 21                	jmp    c010787d <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010785c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010785f:	0f b6 10             	movzbl (%eax),%edx
c0107862:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107865:	88 10                	mov    %dl,(%eax)
c0107867:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010786a:	0f b6 00             	movzbl (%eax),%eax
c010786d:	84 c0                	test   %al,%al
c010786f:	74 04                	je     c0107875 <strncpy+0x27>
            src ++;
c0107871:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0107875:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0107879:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010787d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107881:	75 d9                	jne    c010785c <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0107883:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0107886:	c9                   	leave  
c0107887:	c3                   	ret    

c0107888 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0107888:	55                   	push   %ebp
c0107889:	89 e5                	mov    %esp,%ebp
c010788b:	57                   	push   %edi
c010788c:	56                   	push   %esi
c010788d:	83 ec 20             	sub    $0x20,%esp
c0107890:	8b 45 08             	mov    0x8(%ebp),%eax
c0107893:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107896:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107899:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010789c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010789f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078a2:	89 d1                	mov    %edx,%ecx
c01078a4:	89 c2                	mov    %eax,%edx
c01078a6:	89 ce                	mov    %ecx,%esi
c01078a8:	89 d7                	mov    %edx,%edi
c01078aa:	ac                   	lods   %ds:(%esi),%al
c01078ab:	ae                   	scas   %es:(%edi),%al
c01078ac:	75 08                	jne    c01078b6 <strcmp+0x2e>
c01078ae:	84 c0                	test   %al,%al
c01078b0:	75 f8                	jne    c01078aa <strcmp+0x22>
c01078b2:	31 c0                	xor    %eax,%eax
c01078b4:	eb 04                	jmp    c01078ba <strcmp+0x32>
c01078b6:	19 c0                	sbb    %eax,%eax
c01078b8:	0c 01                	or     $0x1,%al
c01078ba:	89 fa                	mov    %edi,%edx
c01078bc:	89 f1                	mov    %esi,%ecx
c01078be:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01078c1:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01078c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c01078c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01078ca:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01078cb:	83 c4 20             	add    $0x20,%esp
c01078ce:	5e                   	pop    %esi
c01078cf:	5f                   	pop    %edi
c01078d0:	5d                   	pop    %ebp
c01078d1:	c3                   	ret    

c01078d2 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01078d2:	55                   	push   %ebp
c01078d3:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01078d5:	eb 0c                	jmp    c01078e3 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c01078d7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01078db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01078df:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01078e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01078e7:	74 1a                	je     c0107903 <strncmp+0x31>
c01078e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01078ec:	0f b6 00             	movzbl (%eax),%eax
c01078ef:	84 c0                	test   %al,%al
c01078f1:	74 10                	je     c0107903 <strncmp+0x31>
c01078f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01078f6:	0f b6 10             	movzbl (%eax),%edx
c01078f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01078fc:	0f b6 00             	movzbl (%eax),%eax
c01078ff:	38 c2                	cmp    %al,%dl
c0107901:	74 d4                	je     c01078d7 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0107903:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107907:	74 18                	je     c0107921 <strncmp+0x4f>
c0107909:	8b 45 08             	mov    0x8(%ebp),%eax
c010790c:	0f b6 00             	movzbl (%eax),%eax
c010790f:	0f b6 d0             	movzbl %al,%edx
c0107912:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107915:	0f b6 00             	movzbl (%eax),%eax
c0107918:	0f b6 c0             	movzbl %al,%eax
c010791b:	29 c2                	sub    %eax,%edx
c010791d:	89 d0                	mov    %edx,%eax
c010791f:	eb 05                	jmp    c0107926 <strncmp+0x54>
c0107921:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107926:	5d                   	pop    %ebp
c0107927:	c3                   	ret    

c0107928 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0107928:	55                   	push   %ebp
c0107929:	89 e5                	mov    %esp,%ebp
c010792b:	83 ec 04             	sub    $0x4,%esp
c010792e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107931:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0107934:	eb 14                	jmp    c010794a <strchr+0x22>
        if (*s == c) {
c0107936:	8b 45 08             	mov    0x8(%ebp),%eax
c0107939:	0f b6 00             	movzbl (%eax),%eax
c010793c:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010793f:	75 05                	jne    c0107946 <strchr+0x1e>
            return (char *)s;
c0107941:	8b 45 08             	mov    0x8(%ebp),%eax
c0107944:	eb 13                	jmp    c0107959 <strchr+0x31>
        }
        s ++;
c0107946:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010794a:	8b 45 08             	mov    0x8(%ebp),%eax
c010794d:	0f b6 00             	movzbl (%eax),%eax
c0107950:	84 c0                	test   %al,%al
c0107952:	75 e2                	jne    c0107936 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0107954:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107959:	c9                   	leave  
c010795a:	c3                   	ret    

c010795b <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010795b:	55                   	push   %ebp
c010795c:	89 e5                	mov    %esp,%ebp
c010795e:	83 ec 04             	sub    $0x4,%esp
c0107961:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107964:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0107967:	eb 0f                	jmp    c0107978 <strfind+0x1d>
        if (*s == c) {
c0107969:	8b 45 08             	mov    0x8(%ebp),%eax
c010796c:	0f b6 00             	movzbl (%eax),%eax
c010796f:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0107972:	74 10                	je     c0107984 <strfind+0x29>
            break;
        }
        s ++;
c0107974:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0107978:	8b 45 08             	mov    0x8(%ebp),%eax
c010797b:	0f b6 00             	movzbl (%eax),%eax
c010797e:	84 c0                	test   %al,%al
c0107980:	75 e7                	jne    c0107969 <strfind+0xe>
c0107982:	eb 01                	jmp    c0107985 <strfind+0x2a>
        if (*s == c) {
            break;
c0107984:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0107985:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0107988:	c9                   	leave  
c0107989:	c3                   	ret    

c010798a <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010798a:	55                   	push   %ebp
c010798b:	89 e5                	mov    %esp,%ebp
c010798d:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0107990:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0107997:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010799e:	eb 04                	jmp    c01079a4 <strtol+0x1a>
        s ++;
c01079a0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01079a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01079a7:	0f b6 00             	movzbl (%eax),%eax
c01079aa:	3c 20                	cmp    $0x20,%al
c01079ac:	74 f2                	je     c01079a0 <strtol+0x16>
c01079ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01079b1:	0f b6 00             	movzbl (%eax),%eax
c01079b4:	3c 09                	cmp    $0x9,%al
c01079b6:	74 e8                	je     c01079a0 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c01079b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01079bb:	0f b6 00             	movzbl (%eax),%eax
c01079be:	3c 2b                	cmp    $0x2b,%al
c01079c0:	75 06                	jne    c01079c8 <strtol+0x3e>
        s ++;
c01079c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01079c6:	eb 15                	jmp    c01079dd <strtol+0x53>
    }
    else if (*s == '-') {
c01079c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01079cb:	0f b6 00             	movzbl (%eax),%eax
c01079ce:	3c 2d                	cmp    $0x2d,%al
c01079d0:	75 0b                	jne    c01079dd <strtol+0x53>
        s ++, neg = 1;
c01079d2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01079d6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01079dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01079e1:	74 06                	je     c01079e9 <strtol+0x5f>
c01079e3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01079e7:	75 24                	jne    c0107a0d <strtol+0x83>
c01079e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01079ec:	0f b6 00             	movzbl (%eax),%eax
c01079ef:	3c 30                	cmp    $0x30,%al
c01079f1:	75 1a                	jne    c0107a0d <strtol+0x83>
c01079f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01079f6:	83 c0 01             	add    $0x1,%eax
c01079f9:	0f b6 00             	movzbl (%eax),%eax
c01079fc:	3c 78                	cmp    $0x78,%al
c01079fe:	75 0d                	jne    c0107a0d <strtol+0x83>
        s += 2, base = 16;
c0107a00:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0107a04:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0107a0b:	eb 2a                	jmp    c0107a37 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0107a0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107a11:	75 17                	jne    c0107a2a <strtol+0xa0>
c0107a13:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a16:	0f b6 00             	movzbl (%eax),%eax
c0107a19:	3c 30                	cmp    $0x30,%al
c0107a1b:	75 0d                	jne    c0107a2a <strtol+0xa0>
        s ++, base = 8;
c0107a1d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0107a21:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0107a28:	eb 0d                	jmp    c0107a37 <strtol+0xad>
    }
    else if (base == 0) {
c0107a2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107a2e:	75 07                	jne    c0107a37 <strtol+0xad>
        base = 10;
c0107a30:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0107a37:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a3a:	0f b6 00             	movzbl (%eax),%eax
c0107a3d:	3c 2f                	cmp    $0x2f,%al
c0107a3f:	7e 1b                	jle    c0107a5c <strtol+0xd2>
c0107a41:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a44:	0f b6 00             	movzbl (%eax),%eax
c0107a47:	3c 39                	cmp    $0x39,%al
c0107a49:	7f 11                	jg     c0107a5c <strtol+0xd2>
            dig = *s - '0';
c0107a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a4e:	0f b6 00             	movzbl (%eax),%eax
c0107a51:	0f be c0             	movsbl %al,%eax
c0107a54:	83 e8 30             	sub    $0x30,%eax
c0107a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107a5a:	eb 48                	jmp    c0107aa4 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0107a5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a5f:	0f b6 00             	movzbl (%eax),%eax
c0107a62:	3c 60                	cmp    $0x60,%al
c0107a64:	7e 1b                	jle    c0107a81 <strtol+0xf7>
c0107a66:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a69:	0f b6 00             	movzbl (%eax),%eax
c0107a6c:	3c 7a                	cmp    $0x7a,%al
c0107a6e:	7f 11                	jg     c0107a81 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0107a70:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a73:	0f b6 00             	movzbl (%eax),%eax
c0107a76:	0f be c0             	movsbl %al,%eax
c0107a79:	83 e8 57             	sub    $0x57,%eax
c0107a7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107a7f:	eb 23                	jmp    c0107aa4 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0107a81:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a84:	0f b6 00             	movzbl (%eax),%eax
c0107a87:	3c 40                	cmp    $0x40,%al
c0107a89:	7e 3c                	jle    c0107ac7 <strtol+0x13d>
c0107a8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a8e:	0f b6 00             	movzbl (%eax),%eax
c0107a91:	3c 5a                	cmp    $0x5a,%al
c0107a93:	7f 32                	jg     c0107ac7 <strtol+0x13d>
            dig = *s - 'A' + 10;
c0107a95:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a98:	0f b6 00             	movzbl (%eax),%eax
c0107a9b:	0f be c0             	movsbl %al,%eax
c0107a9e:	83 e8 37             	sub    $0x37,%eax
c0107aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0107aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107aa7:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107aaa:	7d 1a                	jge    c0107ac6 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
c0107aac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0107ab0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107ab3:	0f af 45 10          	imul   0x10(%ebp),%eax
c0107ab7:	89 c2                	mov    %eax,%edx
c0107ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107abc:	01 d0                	add    %edx,%eax
c0107abe:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0107ac1:	e9 71 ff ff ff       	jmp    c0107a37 <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c0107ac6:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c0107ac7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107acb:	74 08                	je     c0107ad5 <strtol+0x14b>
        *endptr = (char *) s;
c0107acd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ad0:	8b 55 08             	mov    0x8(%ebp),%edx
c0107ad3:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0107ad5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107ad9:	74 07                	je     c0107ae2 <strtol+0x158>
c0107adb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107ade:	f7 d8                	neg    %eax
c0107ae0:	eb 03                	jmp    c0107ae5 <strtol+0x15b>
c0107ae2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0107ae5:	c9                   	leave  
c0107ae6:	c3                   	ret    

c0107ae7 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0107ae7:	55                   	push   %ebp
c0107ae8:	89 e5                	mov    %esp,%ebp
c0107aea:	57                   	push   %edi
c0107aeb:	83 ec 24             	sub    $0x24,%esp
c0107aee:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107af1:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0107af4:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0107af8:	8b 55 08             	mov    0x8(%ebp),%edx
c0107afb:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0107afe:	88 45 f7             	mov    %al,-0x9(%ebp)
c0107b01:	8b 45 10             	mov    0x10(%ebp),%eax
c0107b04:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0107b07:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0107b0a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0107b0e:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0107b11:	89 d7                	mov    %edx,%edi
c0107b13:	f3 aa                	rep stos %al,%es:(%edi)
c0107b15:	89 fa                	mov    %edi,%edx
c0107b17:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0107b1a:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0107b1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107b20:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0107b21:	83 c4 24             	add    $0x24,%esp
c0107b24:	5f                   	pop    %edi
c0107b25:	5d                   	pop    %ebp
c0107b26:	c3                   	ret    

c0107b27 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0107b27:	55                   	push   %ebp
c0107b28:	89 e5                	mov    %esp,%ebp
c0107b2a:	57                   	push   %edi
c0107b2b:	56                   	push   %esi
c0107b2c:	53                   	push   %ebx
c0107b2d:	83 ec 30             	sub    $0x30,%esp
c0107b30:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b33:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107b36:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b39:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107b3c:	8b 45 10             	mov    0x10(%ebp),%eax
c0107b3f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0107b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b45:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107b48:	73 42                	jae    c0107b8c <memmove+0x65>
c0107b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107b50:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b53:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107b56:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b59:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0107b5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b5f:	c1 e8 02             	shr    $0x2,%eax
c0107b62:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0107b64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107b67:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107b6a:	89 d7                	mov    %edx,%edi
c0107b6c:	89 c6                	mov    %eax,%esi
c0107b6e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0107b70:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0107b73:	83 e1 03             	and    $0x3,%ecx
c0107b76:	74 02                	je     c0107b7a <memmove+0x53>
c0107b78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0107b7a:	89 f0                	mov    %esi,%eax
c0107b7c:	89 fa                	mov    %edi,%edx
c0107b7e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0107b81:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107b84:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0107b87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0107b8a:	eb 36                	jmp    c0107bc2 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0107b8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b8f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107b92:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b95:	01 c2                	add    %eax,%edx
c0107b97:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b9a:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0107b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ba0:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0107ba3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ba6:	89 c1                	mov    %eax,%ecx
c0107ba8:	89 d8                	mov    %ebx,%eax
c0107baa:	89 d6                	mov    %edx,%esi
c0107bac:	89 c7                	mov    %eax,%edi
c0107bae:	fd                   	std    
c0107baf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0107bb1:	fc                   	cld    
c0107bb2:	89 f8                	mov    %edi,%eax
c0107bb4:	89 f2                	mov    %esi,%edx
c0107bb6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0107bb9:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0107bbc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0107bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0107bc2:	83 c4 30             	add    $0x30,%esp
c0107bc5:	5b                   	pop    %ebx
c0107bc6:	5e                   	pop    %esi
c0107bc7:	5f                   	pop    %edi
c0107bc8:	5d                   	pop    %ebp
c0107bc9:	c3                   	ret    

c0107bca <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0107bca:	55                   	push   %ebp
c0107bcb:	89 e5                	mov    %esp,%ebp
c0107bcd:	57                   	push   %edi
c0107bce:	56                   	push   %esi
c0107bcf:	83 ec 20             	sub    $0x20,%esp
c0107bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0107bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107bde:	8b 45 10             	mov    0x10(%ebp),%eax
c0107be1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0107be4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107be7:	c1 e8 02             	shr    $0x2,%eax
c0107bea:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0107bec:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bf2:	89 d7                	mov    %edx,%edi
c0107bf4:	89 c6                	mov    %eax,%esi
c0107bf6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0107bf8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0107bfb:	83 e1 03             	and    $0x3,%ecx
c0107bfe:	74 02                	je     c0107c02 <memcpy+0x38>
c0107c00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0107c02:	89 f0                	mov    %esi,%eax
c0107c04:	89 fa                	mov    %edi,%edx
c0107c06:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0107c09:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107c0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0107c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0107c12:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0107c13:	83 c4 20             	add    $0x20,%esp
c0107c16:	5e                   	pop    %esi
c0107c17:	5f                   	pop    %edi
c0107c18:	5d                   	pop    %ebp
c0107c19:	c3                   	ret    

c0107c1a <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0107c1a:	55                   	push   %ebp
c0107c1b:	89 e5                	mov    %esp,%ebp
c0107c1d:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0107c20:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c23:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0107c26:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c29:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0107c2c:	eb 30                	jmp    c0107c5e <memcmp+0x44>
        if (*s1 != *s2) {
c0107c2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107c31:	0f b6 10             	movzbl (%eax),%edx
c0107c34:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107c37:	0f b6 00             	movzbl (%eax),%eax
c0107c3a:	38 c2                	cmp    %al,%dl
c0107c3c:	74 18                	je     c0107c56 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0107c3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107c41:	0f b6 00             	movzbl (%eax),%eax
c0107c44:	0f b6 d0             	movzbl %al,%edx
c0107c47:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107c4a:	0f b6 00             	movzbl (%eax),%eax
c0107c4d:	0f b6 c0             	movzbl %al,%eax
c0107c50:	29 c2                	sub    %eax,%edx
c0107c52:	89 d0                	mov    %edx,%eax
c0107c54:	eb 1a                	jmp    c0107c70 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0107c56:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0107c5a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0107c5e:	8b 45 10             	mov    0x10(%ebp),%eax
c0107c61:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107c64:	89 55 10             	mov    %edx,0x10(%ebp)
c0107c67:	85 c0                	test   %eax,%eax
c0107c69:	75 c3                	jne    c0107c2e <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0107c6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107c70:	c9                   	leave  
c0107c71:	c3                   	ret    

c0107c72 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0107c72:	55                   	push   %ebp
c0107c73:	89 e5                	mov    %esp,%ebp
c0107c75:	83 ec 38             	sub    $0x38,%esp
c0107c78:	8b 45 10             	mov    0x10(%ebp),%eax
c0107c7b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107c7e:	8b 45 14             	mov    0x14(%ebp),%eax
c0107c81:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0107c84:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107c87:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107c8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107c8d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0107c90:	8b 45 18             	mov    0x18(%ebp),%eax
c0107c93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107c96:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c99:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107c9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107c9f:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0107ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107ca8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107cac:	74 1c                	je     c0107cca <printnum+0x58>
c0107cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cb1:	ba 00 00 00 00       	mov    $0x0,%edx
c0107cb6:	f7 75 e4             	divl   -0x1c(%ebp)
c0107cb9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0107cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cbf:	ba 00 00 00 00       	mov    $0x0,%edx
c0107cc4:	f7 75 e4             	divl   -0x1c(%ebp)
c0107cc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107cca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107cd0:	f7 75 e4             	divl   -0x1c(%ebp)
c0107cd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107cd6:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0107cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107cdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107cdf:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107ce2:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0107ce5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ce8:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0107ceb:	8b 45 18             	mov    0x18(%ebp),%eax
c0107cee:	ba 00 00 00 00       	mov    $0x0,%edx
c0107cf3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107cf6:	77 41                	ja     c0107d39 <printnum+0xc7>
c0107cf8:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107cfb:	72 05                	jb     c0107d02 <printnum+0x90>
c0107cfd:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0107d00:	77 37                	ja     c0107d39 <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
c0107d02:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0107d05:	83 e8 01             	sub    $0x1,%eax
c0107d08:	83 ec 04             	sub    $0x4,%esp
c0107d0b:	ff 75 20             	pushl  0x20(%ebp)
c0107d0e:	50                   	push   %eax
c0107d0f:	ff 75 18             	pushl  0x18(%ebp)
c0107d12:	ff 75 ec             	pushl  -0x14(%ebp)
c0107d15:	ff 75 e8             	pushl  -0x18(%ebp)
c0107d18:	ff 75 0c             	pushl  0xc(%ebp)
c0107d1b:	ff 75 08             	pushl  0x8(%ebp)
c0107d1e:	e8 4f ff ff ff       	call   c0107c72 <printnum>
c0107d23:	83 c4 20             	add    $0x20,%esp
c0107d26:	eb 1b                	jmp    c0107d43 <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0107d28:	83 ec 08             	sub    $0x8,%esp
c0107d2b:	ff 75 0c             	pushl  0xc(%ebp)
c0107d2e:	ff 75 20             	pushl  0x20(%ebp)
c0107d31:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d34:	ff d0                	call   *%eax
c0107d36:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0107d39:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0107d3d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0107d41:	7f e5                	jg     c0107d28 <printnum+0xb6>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0107d43:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107d46:	05 e4 a1 10 c0       	add    $0xc010a1e4,%eax
c0107d4b:	0f b6 00             	movzbl (%eax),%eax
c0107d4e:	0f be c0             	movsbl %al,%eax
c0107d51:	83 ec 08             	sub    $0x8,%esp
c0107d54:	ff 75 0c             	pushl  0xc(%ebp)
c0107d57:	50                   	push   %eax
c0107d58:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d5b:	ff d0                	call   *%eax
c0107d5d:	83 c4 10             	add    $0x10,%esp
}
c0107d60:	90                   	nop
c0107d61:	c9                   	leave  
c0107d62:	c3                   	ret    

c0107d63 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0107d63:	55                   	push   %ebp
c0107d64:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0107d66:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0107d6a:	7e 14                	jle    c0107d80 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0107d6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d6f:	8b 00                	mov    (%eax),%eax
c0107d71:	8d 48 08             	lea    0x8(%eax),%ecx
c0107d74:	8b 55 08             	mov    0x8(%ebp),%edx
c0107d77:	89 0a                	mov    %ecx,(%edx)
c0107d79:	8b 50 04             	mov    0x4(%eax),%edx
c0107d7c:	8b 00                	mov    (%eax),%eax
c0107d7e:	eb 30                	jmp    c0107db0 <getuint+0x4d>
    }
    else if (lflag) {
c0107d80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107d84:	74 16                	je     c0107d9c <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0107d86:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d89:	8b 00                	mov    (%eax),%eax
c0107d8b:	8d 48 04             	lea    0x4(%eax),%ecx
c0107d8e:	8b 55 08             	mov    0x8(%ebp),%edx
c0107d91:	89 0a                	mov    %ecx,(%edx)
c0107d93:	8b 00                	mov    (%eax),%eax
c0107d95:	ba 00 00 00 00       	mov    $0x0,%edx
c0107d9a:	eb 14                	jmp    c0107db0 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0107d9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d9f:	8b 00                	mov    (%eax),%eax
c0107da1:	8d 48 04             	lea    0x4(%eax),%ecx
c0107da4:	8b 55 08             	mov    0x8(%ebp),%edx
c0107da7:	89 0a                	mov    %ecx,(%edx)
c0107da9:	8b 00                	mov    (%eax),%eax
c0107dab:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0107db0:	5d                   	pop    %ebp
c0107db1:	c3                   	ret    

c0107db2 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0107db2:	55                   	push   %ebp
c0107db3:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0107db5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0107db9:	7e 14                	jle    c0107dcf <getint+0x1d>
        return va_arg(*ap, long long);
c0107dbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0107dbe:	8b 00                	mov    (%eax),%eax
c0107dc0:	8d 48 08             	lea    0x8(%eax),%ecx
c0107dc3:	8b 55 08             	mov    0x8(%ebp),%edx
c0107dc6:	89 0a                	mov    %ecx,(%edx)
c0107dc8:	8b 50 04             	mov    0x4(%eax),%edx
c0107dcb:	8b 00                	mov    (%eax),%eax
c0107dcd:	eb 28                	jmp    c0107df7 <getint+0x45>
    }
    else if (lflag) {
c0107dcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107dd3:	74 12                	je     c0107de7 <getint+0x35>
        return va_arg(*ap, long);
c0107dd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0107dd8:	8b 00                	mov    (%eax),%eax
c0107dda:	8d 48 04             	lea    0x4(%eax),%ecx
c0107ddd:	8b 55 08             	mov    0x8(%ebp),%edx
c0107de0:	89 0a                	mov    %ecx,(%edx)
c0107de2:	8b 00                	mov    (%eax),%eax
c0107de4:	99                   	cltd   
c0107de5:	eb 10                	jmp    c0107df7 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0107de7:	8b 45 08             	mov    0x8(%ebp),%eax
c0107dea:	8b 00                	mov    (%eax),%eax
c0107dec:	8d 48 04             	lea    0x4(%eax),%ecx
c0107def:	8b 55 08             	mov    0x8(%ebp),%edx
c0107df2:	89 0a                	mov    %ecx,(%edx)
c0107df4:	8b 00                	mov    (%eax),%eax
c0107df6:	99                   	cltd   
    }
}
c0107df7:	5d                   	pop    %ebp
c0107df8:	c3                   	ret    

c0107df9 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0107df9:	55                   	push   %ebp
c0107dfa:	89 e5                	mov    %esp,%ebp
c0107dfc:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
c0107dff:	8d 45 14             	lea    0x14(%ebp),%eax
c0107e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0107e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e08:	50                   	push   %eax
c0107e09:	ff 75 10             	pushl  0x10(%ebp)
c0107e0c:	ff 75 0c             	pushl  0xc(%ebp)
c0107e0f:	ff 75 08             	pushl  0x8(%ebp)
c0107e12:	e8 06 00 00 00       	call   c0107e1d <vprintfmt>
c0107e17:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c0107e1a:	90                   	nop
c0107e1b:	c9                   	leave  
c0107e1c:	c3                   	ret    

c0107e1d <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0107e1d:	55                   	push   %ebp
c0107e1e:	89 e5                	mov    %esp,%ebp
c0107e20:	56                   	push   %esi
c0107e21:	53                   	push   %ebx
c0107e22:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0107e25:	eb 17                	jmp    c0107e3e <vprintfmt+0x21>
            if (ch == '\0') {
c0107e27:	85 db                	test   %ebx,%ebx
c0107e29:	0f 84 8e 03 00 00    	je     c01081bd <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
c0107e2f:	83 ec 08             	sub    $0x8,%esp
c0107e32:	ff 75 0c             	pushl  0xc(%ebp)
c0107e35:	53                   	push   %ebx
c0107e36:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e39:	ff d0                	call   *%eax
c0107e3b:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0107e3e:	8b 45 10             	mov    0x10(%ebp),%eax
c0107e41:	8d 50 01             	lea    0x1(%eax),%edx
c0107e44:	89 55 10             	mov    %edx,0x10(%ebp)
c0107e47:	0f b6 00             	movzbl (%eax),%eax
c0107e4a:	0f b6 d8             	movzbl %al,%ebx
c0107e4d:	83 fb 25             	cmp    $0x25,%ebx
c0107e50:	75 d5                	jne    c0107e27 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0107e52:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0107e56:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0107e5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107e60:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0107e63:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107e6d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0107e70:	8b 45 10             	mov    0x10(%ebp),%eax
c0107e73:	8d 50 01             	lea    0x1(%eax),%edx
c0107e76:	89 55 10             	mov    %edx,0x10(%ebp)
c0107e79:	0f b6 00             	movzbl (%eax),%eax
c0107e7c:	0f b6 d8             	movzbl %al,%ebx
c0107e7f:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0107e82:	83 f8 55             	cmp    $0x55,%eax
c0107e85:	0f 87 05 03 00 00    	ja     c0108190 <vprintfmt+0x373>
c0107e8b:	8b 04 85 08 a2 10 c0 	mov    -0x3fef5df8(,%eax,4),%eax
c0107e92:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0107e94:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0107e98:	eb d6                	jmp    c0107e70 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0107e9a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0107e9e:	eb d0                	jmp    c0107e70 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0107ea0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0107ea7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107eaa:	89 d0                	mov    %edx,%eax
c0107eac:	c1 e0 02             	shl    $0x2,%eax
c0107eaf:	01 d0                	add    %edx,%eax
c0107eb1:	01 c0                	add    %eax,%eax
c0107eb3:	01 d8                	add    %ebx,%eax
c0107eb5:	83 e8 30             	sub    $0x30,%eax
c0107eb8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0107ebb:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ebe:	0f b6 00             	movzbl (%eax),%eax
c0107ec1:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0107ec4:	83 fb 2f             	cmp    $0x2f,%ebx
c0107ec7:	7e 39                	jle    c0107f02 <vprintfmt+0xe5>
c0107ec9:	83 fb 39             	cmp    $0x39,%ebx
c0107ecc:	7f 34                	jg     c0107f02 <vprintfmt+0xe5>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0107ece:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0107ed2:	eb d3                	jmp    c0107ea7 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0107ed4:	8b 45 14             	mov    0x14(%ebp),%eax
c0107ed7:	8d 50 04             	lea    0x4(%eax),%edx
c0107eda:	89 55 14             	mov    %edx,0x14(%ebp)
c0107edd:	8b 00                	mov    (%eax),%eax
c0107edf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0107ee2:	eb 1f                	jmp    c0107f03 <vprintfmt+0xe6>

        case '.':
            if (width < 0)
c0107ee4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107ee8:	79 86                	jns    c0107e70 <vprintfmt+0x53>
                width = 0;
c0107eea:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0107ef1:	e9 7a ff ff ff       	jmp    c0107e70 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0107ef6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0107efd:	e9 6e ff ff ff       	jmp    c0107e70 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c0107f02:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c0107f03:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107f07:	0f 89 63 ff ff ff    	jns    c0107e70 <vprintfmt+0x53>
                width = precision, precision = -1;
c0107f0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f10:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107f13:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0107f1a:	e9 51 ff ff ff       	jmp    c0107e70 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0107f1f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0107f23:	e9 48 ff ff ff       	jmp    c0107e70 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0107f28:	8b 45 14             	mov    0x14(%ebp),%eax
c0107f2b:	8d 50 04             	lea    0x4(%eax),%edx
c0107f2e:	89 55 14             	mov    %edx,0x14(%ebp)
c0107f31:	8b 00                	mov    (%eax),%eax
c0107f33:	83 ec 08             	sub    $0x8,%esp
c0107f36:	ff 75 0c             	pushl  0xc(%ebp)
c0107f39:	50                   	push   %eax
c0107f3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f3d:	ff d0                	call   *%eax
c0107f3f:	83 c4 10             	add    $0x10,%esp
            break;
c0107f42:	e9 71 02 00 00       	jmp    c01081b8 <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0107f47:	8b 45 14             	mov    0x14(%ebp),%eax
c0107f4a:	8d 50 04             	lea    0x4(%eax),%edx
c0107f4d:	89 55 14             	mov    %edx,0x14(%ebp)
c0107f50:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0107f52:	85 db                	test   %ebx,%ebx
c0107f54:	79 02                	jns    c0107f58 <vprintfmt+0x13b>
                err = -err;
c0107f56:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0107f58:	83 fb 06             	cmp    $0x6,%ebx
c0107f5b:	7f 0b                	jg     c0107f68 <vprintfmt+0x14b>
c0107f5d:	8b 34 9d c8 a1 10 c0 	mov    -0x3fef5e38(,%ebx,4),%esi
c0107f64:	85 f6                	test   %esi,%esi
c0107f66:	75 19                	jne    c0107f81 <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
c0107f68:	53                   	push   %ebx
c0107f69:	68 f5 a1 10 c0       	push   $0xc010a1f5
c0107f6e:	ff 75 0c             	pushl  0xc(%ebp)
c0107f71:	ff 75 08             	pushl  0x8(%ebp)
c0107f74:	e8 80 fe ff ff       	call   c0107df9 <printfmt>
c0107f79:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0107f7c:	e9 37 02 00 00       	jmp    c01081b8 <vprintfmt+0x39b>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0107f81:	56                   	push   %esi
c0107f82:	68 fe a1 10 c0       	push   $0xc010a1fe
c0107f87:	ff 75 0c             	pushl  0xc(%ebp)
c0107f8a:	ff 75 08             	pushl  0x8(%ebp)
c0107f8d:	e8 67 fe ff ff       	call   c0107df9 <printfmt>
c0107f92:	83 c4 10             	add    $0x10,%esp
            }
            break;
c0107f95:	e9 1e 02 00 00       	jmp    c01081b8 <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0107f9a:	8b 45 14             	mov    0x14(%ebp),%eax
c0107f9d:	8d 50 04             	lea    0x4(%eax),%edx
c0107fa0:	89 55 14             	mov    %edx,0x14(%ebp)
c0107fa3:	8b 30                	mov    (%eax),%esi
c0107fa5:	85 f6                	test   %esi,%esi
c0107fa7:	75 05                	jne    c0107fae <vprintfmt+0x191>
                p = "(null)";
c0107fa9:	be 01 a2 10 c0       	mov    $0xc010a201,%esi
            }
            if (width > 0 && padc != '-') {
c0107fae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107fb2:	7e 76                	jle    c010802a <vprintfmt+0x20d>
c0107fb4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0107fb8:	74 70                	je     c010802a <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0107fba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107fbd:	83 ec 08             	sub    $0x8,%esp
c0107fc0:	50                   	push   %eax
c0107fc1:	56                   	push   %esi
c0107fc2:	e8 17 f8 ff ff       	call   c01077de <strnlen>
c0107fc7:	83 c4 10             	add    $0x10,%esp
c0107fca:	89 c2                	mov    %eax,%edx
c0107fcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fcf:	29 d0                	sub    %edx,%eax
c0107fd1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107fd4:	eb 17                	jmp    c0107fed <vprintfmt+0x1d0>
                    putch(padc, putdat);
c0107fd6:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0107fda:	83 ec 08             	sub    $0x8,%esp
c0107fdd:	ff 75 0c             	pushl  0xc(%ebp)
c0107fe0:	50                   	push   %eax
c0107fe1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fe4:	ff d0                	call   *%eax
c0107fe6:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0107fe9:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0107fed:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107ff1:	7f e3                	jg     c0107fd6 <vprintfmt+0x1b9>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0107ff3:	eb 35                	jmp    c010802a <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
c0107ff5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107ff9:	74 1c                	je     c0108017 <vprintfmt+0x1fa>
c0107ffb:	83 fb 1f             	cmp    $0x1f,%ebx
c0107ffe:	7e 05                	jle    c0108005 <vprintfmt+0x1e8>
c0108000:	83 fb 7e             	cmp    $0x7e,%ebx
c0108003:	7e 12                	jle    c0108017 <vprintfmt+0x1fa>
                    putch('?', putdat);
c0108005:	83 ec 08             	sub    $0x8,%esp
c0108008:	ff 75 0c             	pushl  0xc(%ebp)
c010800b:	6a 3f                	push   $0x3f
c010800d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108010:	ff d0                	call   *%eax
c0108012:	83 c4 10             	add    $0x10,%esp
c0108015:	eb 0f                	jmp    c0108026 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
c0108017:	83 ec 08             	sub    $0x8,%esp
c010801a:	ff 75 0c             	pushl  0xc(%ebp)
c010801d:	53                   	push   %ebx
c010801e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108021:	ff d0                	call   *%eax
c0108023:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108026:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010802a:	89 f0                	mov    %esi,%eax
c010802c:	8d 70 01             	lea    0x1(%eax),%esi
c010802f:	0f b6 00             	movzbl (%eax),%eax
c0108032:	0f be d8             	movsbl %al,%ebx
c0108035:	85 db                	test   %ebx,%ebx
c0108037:	74 26                	je     c010805f <vprintfmt+0x242>
c0108039:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010803d:	78 b6                	js     c0107ff5 <vprintfmt+0x1d8>
c010803f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0108043:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108047:	79 ac                	jns    c0107ff5 <vprintfmt+0x1d8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0108049:	eb 14                	jmp    c010805f <vprintfmt+0x242>
                putch(' ', putdat);
c010804b:	83 ec 08             	sub    $0x8,%esp
c010804e:	ff 75 0c             	pushl  0xc(%ebp)
c0108051:	6a 20                	push   $0x20
c0108053:	8b 45 08             	mov    0x8(%ebp),%eax
c0108056:	ff d0                	call   *%eax
c0108058:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010805b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010805f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108063:	7f e6                	jg     c010804b <vprintfmt+0x22e>
                putch(' ', putdat);
            }
            break;
c0108065:	e9 4e 01 00 00       	jmp    c01081b8 <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010806a:	83 ec 08             	sub    $0x8,%esp
c010806d:	ff 75 e0             	pushl  -0x20(%ebp)
c0108070:	8d 45 14             	lea    0x14(%ebp),%eax
c0108073:	50                   	push   %eax
c0108074:	e8 39 fd ff ff       	call   c0107db2 <getint>
c0108079:	83 c4 10             	add    $0x10,%esp
c010807c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010807f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0108082:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108085:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108088:	85 d2                	test   %edx,%edx
c010808a:	79 23                	jns    c01080af <vprintfmt+0x292>
                putch('-', putdat);
c010808c:	83 ec 08             	sub    $0x8,%esp
c010808f:	ff 75 0c             	pushl  0xc(%ebp)
c0108092:	6a 2d                	push   $0x2d
c0108094:	8b 45 08             	mov    0x8(%ebp),%eax
c0108097:	ff d0                	call   *%eax
c0108099:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c010809c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010809f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01080a2:	f7 d8                	neg    %eax
c01080a4:	83 d2 00             	adc    $0x0,%edx
c01080a7:	f7 da                	neg    %edx
c01080a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01080ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01080af:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01080b6:	e9 9f 00 00 00       	jmp    c010815a <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01080bb:	83 ec 08             	sub    $0x8,%esp
c01080be:	ff 75 e0             	pushl  -0x20(%ebp)
c01080c1:	8d 45 14             	lea    0x14(%ebp),%eax
c01080c4:	50                   	push   %eax
c01080c5:	e8 99 fc ff ff       	call   c0107d63 <getuint>
c01080ca:	83 c4 10             	add    $0x10,%esp
c01080cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01080d0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01080d3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01080da:	eb 7e                	jmp    c010815a <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01080dc:	83 ec 08             	sub    $0x8,%esp
c01080df:	ff 75 e0             	pushl  -0x20(%ebp)
c01080e2:	8d 45 14             	lea    0x14(%ebp),%eax
c01080e5:	50                   	push   %eax
c01080e6:	e8 78 fc ff ff       	call   c0107d63 <getuint>
c01080eb:	83 c4 10             	add    $0x10,%esp
c01080ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01080f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c01080f4:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c01080fb:	eb 5d                	jmp    c010815a <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
c01080fd:	83 ec 08             	sub    $0x8,%esp
c0108100:	ff 75 0c             	pushl  0xc(%ebp)
c0108103:	6a 30                	push   $0x30
c0108105:	8b 45 08             	mov    0x8(%ebp),%eax
c0108108:	ff d0                	call   *%eax
c010810a:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c010810d:	83 ec 08             	sub    $0x8,%esp
c0108110:	ff 75 0c             	pushl  0xc(%ebp)
c0108113:	6a 78                	push   $0x78
c0108115:	8b 45 08             	mov    0x8(%ebp),%eax
c0108118:	ff d0                	call   *%eax
c010811a:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010811d:	8b 45 14             	mov    0x14(%ebp),%eax
c0108120:	8d 50 04             	lea    0x4(%eax),%edx
c0108123:	89 55 14             	mov    %edx,0x14(%ebp)
c0108126:	8b 00                	mov    (%eax),%eax
c0108128:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010812b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0108132:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0108139:	eb 1f                	jmp    c010815a <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010813b:	83 ec 08             	sub    $0x8,%esp
c010813e:	ff 75 e0             	pushl  -0x20(%ebp)
c0108141:	8d 45 14             	lea    0x14(%ebp),%eax
c0108144:	50                   	push   %eax
c0108145:	e8 19 fc ff ff       	call   c0107d63 <getuint>
c010814a:	83 c4 10             	add    $0x10,%esp
c010814d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108150:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0108153:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010815a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010815e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108161:	83 ec 04             	sub    $0x4,%esp
c0108164:	52                   	push   %edx
c0108165:	ff 75 e8             	pushl  -0x18(%ebp)
c0108168:	50                   	push   %eax
c0108169:	ff 75 f4             	pushl  -0xc(%ebp)
c010816c:	ff 75 f0             	pushl  -0x10(%ebp)
c010816f:	ff 75 0c             	pushl  0xc(%ebp)
c0108172:	ff 75 08             	pushl  0x8(%ebp)
c0108175:	e8 f8 fa ff ff       	call   c0107c72 <printnum>
c010817a:	83 c4 20             	add    $0x20,%esp
            break;
c010817d:	eb 39                	jmp    c01081b8 <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010817f:	83 ec 08             	sub    $0x8,%esp
c0108182:	ff 75 0c             	pushl  0xc(%ebp)
c0108185:	53                   	push   %ebx
c0108186:	8b 45 08             	mov    0x8(%ebp),%eax
c0108189:	ff d0                	call   *%eax
c010818b:	83 c4 10             	add    $0x10,%esp
            break;
c010818e:	eb 28                	jmp    c01081b8 <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0108190:	83 ec 08             	sub    $0x8,%esp
c0108193:	ff 75 0c             	pushl  0xc(%ebp)
c0108196:	6a 25                	push   $0x25
c0108198:	8b 45 08             	mov    0x8(%ebp),%eax
c010819b:	ff d0                	call   *%eax
c010819d:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c01081a0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01081a4:	eb 04                	jmp    c01081aa <vprintfmt+0x38d>
c01081a6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01081aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01081ad:	83 e8 01             	sub    $0x1,%eax
c01081b0:	0f b6 00             	movzbl (%eax),%eax
c01081b3:	3c 25                	cmp    $0x25,%al
c01081b5:	75 ef                	jne    c01081a6 <vprintfmt+0x389>
                /* do nothing */;
            break;
c01081b7:	90                   	nop
        }
    }
c01081b8:	e9 68 fc ff ff       	jmp    c0107e25 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c01081bd:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c01081be:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01081c1:	5b                   	pop    %ebx
c01081c2:	5e                   	pop    %esi
c01081c3:	5d                   	pop    %ebp
c01081c4:	c3                   	ret    

c01081c5 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01081c5:	55                   	push   %ebp
c01081c6:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01081c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081cb:	8b 40 08             	mov    0x8(%eax),%eax
c01081ce:	8d 50 01             	lea    0x1(%eax),%edx
c01081d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081d4:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c01081d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081da:	8b 10                	mov    (%eax),%edx
c01081dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081df:	8b 40 04             	mov    0x4(%eax),%eax
c01081e2:	39 c2                	cmp    %eax,%edx
c01081e4:	73 12                	jae    c01081f8 <sprintputch+0x33>
        *b->buf ++ = ch;
c01081e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081e9:	8b 00                	mov    (%eax),%eax
c01081eb:	8d 48 01             	lea    0x1(%eax),%ecx
c01081ee:	8b 55 0c             	mov    0xc(%ebp),%edx
c01081f1:	89 0a                	mov    %ecx,(%edx)
c01081f3:	8b 55 08             	mov    0x8(%ebp),%edx
c01081f6:	88 10                	mov    %dl,(%eax)
    }
}
c01081f8:	90                   	nop
c01081f9:	5d                   	pop    %ebp
c01081fa:	c3                   	ret    

c01081fb <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c01081fb:	55                   	push   %ebp
c01081fc:	89 e5                	mov    %esp,%ebp
c01081fe:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0108201:	8d 45 14             	lea    0x14(%ebp),%eax
c0108204:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0108207:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010820a:	50                   	push   %eax
c010820b:	ff 75 10             	pushl  0x10(%ebp)
c010820e:	ff 75 0c             	pushl  0xc(%ebp)
c0108211:	ff 75 08             	pushl  0x8(%ebp)
c0108214:	e8 0b 00 00 00       	call   c0108224 <vsnprintf>
c0108219:	83 c4 10             	add    $0x10,%esp
c010821c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010821f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108222:	c9                   	leave  
c0108223:	c3                   	ret    

c0108224 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0108224:	55                   	push   %ebp
c0108225:	89 e5                	mov    %esp,%ebp
c0108227:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010822a:	8b 45 08             	mov    0x8(%ebp),%eax
c010822d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108230:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108233:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108236:	8b 45 08             	mov    0x8(%ebp),%eax
c0108239:	01 d0                	add    %edx,%eax
c010823b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010823e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0108245:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108249:	74 0a                	je     c0108255 <vsnprintf+0x31>
c010824b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010824e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108251:	39 c2                	cmp    %eax,%edx
c0108253:	76 07                	jbe    c010825c <vsnprintf+0x38>
        return -E_INVAL;
c0108255:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010825a:	eb 20                	jmp    c010827c <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010825c:	ff 75 14             	pushl  0x14(%ebp)
c010825f:	ff 75 10             	pushl  0x10(%ebp)
c0108262:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0108265:	50                   	push   %eax
c0108266:	68 c5 81 10 c0       	push   $0xc01081c5
c010826b:	e8 ad fb ff ff       	call   c0107e1d <vprintfmt>
c0108270:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c0108273:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108276:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0108279:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010827c:	c9                   	leave  
c010827d:	c3                   	ret    

c010827e <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010827e:	55                   	push   %ebp
c010827f:	89 e5                	mov    %esp,%ebp
c0108281:	57                   	push   %edi
c0108282:	56                   	push   %esi
c0108283:	53                   	push   %ebx
c0108284:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0108287:	a1 58 fa 11 c0       	mov    0xc011fa58,%eax
c010828c:	8b 15 5c fa 11 c0    	mov    0xc011fa5c,%edx
c0108292:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0108298:	6b f0 05             	imul   $0x5,%eax,%esi
c010829b:	01 fe                	add    %edi,%esi
c010829d:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c01082a2:	f7 e7                	mul    %edi
c01082a4:	01 d6                	add    %edx,%esi
c01082a6:	89 f2                	mov    %esi,%edx
c01082a8:	83 c0 0b             	add    $0xb,%eax
c01082ab:	83 d2 00             	adc    $0x0,%edx
c01082ae:	89 c7                	mov    %eax,%edi
c01082b0:	83 e7 ff             	and    $0xffffffff,%edi
c01082b3:	89 f9                	mov    %edi,%ecx
c01082b5:	0f b7 da             	movzwl %dx,%ebx
c01082b8:	89 0d 58 fa 11 c0    	mov    %ecx,0xc011fa58
c01082be:	89 1d 5c fa 11 c0    	mov    %ebx,0xc011fa5c
    unsigned long long result = (next >> 12);
c01082c4:	a1 58 fa 11 c0       	mov    0xc011fa58,%eax
c01082c9:	8b 15 5c fa 11 c0    	mov    0xc011fa5c,%edx
c01082cf:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01082d3:	c1 ea 0c             	shr    $0xc,%edx
c01082d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01082d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c01082dc:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c01082e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01082e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01082e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01082ec:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01082ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01082f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01082f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01082f9:	74 1c                	je     c0108317 <rand+0x99>
c01082fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01082fe:	ba 00 00 00 00       	mov    $0x0,%edx
c0108303:	f7 75 dc             	divl   -0x24(%ebp)
c0108306:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108309:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010830c:	ba 00 00 00 00       	mov    $0x0,%edx
c0108311:	f7 75 dc             	divl   -0x24(%ebp)
c0108314:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108317:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010831a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010831d:	f7 75 dc             	divl   -0x24(%ebp)
c0108320:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108323:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108326:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108329:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010832c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010832f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108332:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108335:	83 c4 24             	add    $0x24,%esp
c0108338:	5b                   	pop    %ebx
c0108339:	5e                   	pop    %esi
c010833a:	5f                   	pop    %edi
c010833b:	5d                   	pop    %ebp
c010833c:	c3                   	ret    

c010833d <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010833d:	55                   	push   %ebp
c010833e:	89 e5                	mov    %esp,%ebp
    next = seed;
c0108340:	8b 45 08             	mov    0x8(%ebp),%eax
c0108343:	ba 00 00 00 00       	mov    $0x0,%edx
c0108348:	a3 58 fa 11 c0       	mov    %eax,0xc011fa58
c010834d:	89 15 5c fa 11 c0    	mov    %edx,0xc011fa5c
}
c0108353:	90                   	nop
c0108354:	5d                   	pop    %ebp
c0108355:	c3                   	ret    
